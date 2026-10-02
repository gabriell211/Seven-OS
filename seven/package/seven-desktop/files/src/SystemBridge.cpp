#include "SystemBridge.hpp"

#include <QFile>
#include <QProcess>
#include <QStorageInfo>
#include <QSysInfo>
#include <QTextStream>

#include <algorithm>

SystemBridge::SystemBridge(QObject *parent)
    : QObject(parent)
{
    refreshMetrics();
}

QString SystemBridge::hostname() const
{
    return QSysInfo::machineHostName().isEmpty()
        ? QStringLiteral("seven")
        : QSysInfo::machineHostName();
}

QString SystemBridge::osName() const
{
    const QString pretty = QSysInfo::prettyProductName();
    return pretty.isEmpty() ? QStringLiteral("Seven OS") : pretty;
}

QString SystemBridge::kernel() const
{
    return QSysInfo::kernelType() + QStringLiteral(" ") + QSysInfo::kernelVersion();
}

double SystemBridge::cpuPercent() const
{
    return m_cpuPercent;
}

double SystemBridge::memoryPercent() const
{
    return m_memoryPercent;
}

double SystemBridge::diskPercent() const
{
    return m_diskPercent;
}

bool SystemBridge::windowsRuntimeAvailable() const
{
    return m_windowsRuntimeAvailable;
}

bool SystemBridge::launch(const QString &program)
{
    const QString executable = program.trimmed();
    if (executable.isEmpty()) {
        return false;
    }

    if (QProcess::startDetached(
            QStringLiteral("/usr/bin/env"),
            {
                QStringLiteral("XDG_RUNTIME_DIR=/run/seven"),
                QStringLiteral("WAYLAND_DISPLAY=wayland-0"),
                QStringLiteral("QT_QPA_PLATFORM=wayland"),
                executable
            })) {
        return true;
    }

    emit launchFailed(executable);
    return false;
}

bool SystemBridge::launchWindows(const QString &path)
{
    const QString executable = path.trimmed();
    if (executable.isEmpty()) {
        return false;
    }

    if (QProcess::startDetached(
            QStringLiteral("/usr/bin/env"),
            {
                QStringLiteral("XDG_RUNTIME_DIR=/run/seven"),
                QStringLiteral("WAYLAND_DISPLAY=wayland-0"),
                QStringLiteral("/usr/bin/seven-winexec"),
                executable
            })) {
        return true;
    }

    emit launchFailed(executable);
    return false;
}

void SystemBridge::refreshMetrics()
{
    QFile stat(QStringLiteral("/proc/stat"));
    if (stat.open(QIODevice::ReadOnly | QIODevice::Text)) {
        const QString line = QString::fromUtf8(stat.readLine()).trimmed();
        const QStringList fields = line.split(' ', Qt::SkipEmptyParts);

        if (fields.size() >= 5 && fields[0] == QStringLiteral("cpu")) {
            quint64 values[10]{};
            const int valueCount = std::min(10, static_cast<int>(fields.size() - 1));

            for (int i = 0; i < valueCount; ++i) {
                bool ok = false;
                values[i] = fields[i + 1].toULongLong(&ok);
                if (!ok) {
                    values[i] = 0;
                }
            }

            const quint64 idle = values[3] + values[4];
            quint64 total = 0;
            for (int i = 0; i < valueCount; ++i) {
                total += values[i];
            }

            if (m_previousCpuTotal > 0 && total > m_previousCpuTotal) {
                const quint64 totalDelta = total - m_previousCpuTotal;
                const quint64 idleDelta = idle >= m_previousCpuIdle
                    ? idle - m_previousCpuIdle
                    : 0;

                if (totalDelta > 0) {
                    m_cpuPercent = std::clamp(
                        (1.0 - (static_cast<double>(idleDelta) / static_cast<double>(totalDelta))) * 100.0,
                        0.0,
                        100.0
                    );
                }
            }

            m_previousCpuTotal = total;
            m_previousCpuIdle = idle;
        }
    }

    QFile meminfo(QStringLiteral("/proc/meminfo"));
    if (meminfo.open(QIODevice::ReadOnly | QIODevice::Text)) {
        quint64 totalKb = 0;
        quint64 availableKb = 0;

        QTextStream stream(&meminfo);
        while (!stream.atEnd()) {
            const QString line = stream.readLine();
            const auto parts = line.split(':');
            if (parts.size() != 2) {
                continue;
            }

            bool ok = false;
            const quint64 value = parts[1].trimmed().section(' ', 0, 0).toULongLong(&ok);
            if (!ok) {
                continue;
            }

            if (parts[0] == QStringLiteral("MemTotal")) {
                totalKb = value;
            } else if (parts[0] == QStringLiteral("MemAvailable")) {
                availableKb = value;
            }
        }

        if (totalKb > 0) {
            const double used = static_cast<double>(totalKb - std::min(totalKb, availableKb));
            m_memoryPercent = std::clamp(
                (used / static_cast<double>(totalKb)) * 100.0,
                0.0,
                100.0
            );
        }
    }

    m_windowsRuntimeAvailable =
        QFile::exists(QStringLiteral("/usr/bin/wine")) &&
        QFile::exists(QStringLiteral("/usr/bin/seven-winexec"));

    const QStorageInfo root = QStorageInfo::root();
    if (root.isValid() && root.bytesTotal() > 0) {
        const auto used = root.bytesTotal() - root.bytesAvailable();
        m_diskPercent = std::clamp(
            (static_cast<double>(used) / static_cast<double>(root.bytesTotal())) * 100.0,
            0.0,
            100.0
        );
    }

    emit metricsChanged();
}

void SystemBridge::powerOff()
{
    QProcess::startDetached(QStringLiteral("/usr/bin/loginctl"), {QStringLiteral("poweroff")});
}

void SystemBridge::reboot()
{
    QProcess::startDetached(QStringLiteral("/usr/bin/loginctl"), {QStringLiteral("reboot")});
}
