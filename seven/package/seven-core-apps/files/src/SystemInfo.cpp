#include "SystemInfo.hpp"

#include <QFile>
#include <QProcess>
#include <QStorageInfo>
#include <QSysInfo>
#include <QTextStream>

#include <algorithm>

SystemInfo::SystemInfo(QObject *parent)
    : QObject(parent)
{
    refresh();
}

QString SystemInfo::hostname() const
{
    return QSysInfo::machineHostName().isEmpty()
        ? QStringLiteral("seven")
        : QSysInfo::machineHostName();
}

QString SystemInfo::osName() const
{
    const QString name = QSysInfo::prettyProductName();
    return name.isEmpty() ? QStringLiteral("Seven OS") : name;
}

QString SystemInfo::kernel() const
{
    return QSysInfo::kernelType() + QStringLiteral(" ") + QSysInfo::kernelVersion();
}

QString SystemInfo::uptime() const
{
    return m_uptime;
}

double SystemInfo::cpuPercent() const
{
    return m_cpuPercent;
}

double SystemInfo::memoryPercent() const
{
    return m_memoryPercent;
}

double SystemInfo::diskPercent() const
{
    return m_diskPercent;
}

bool SystemInfo::windowsRuntimeAvailable() const
{
    return m_windowsRuntimeAvailable;
}

void SystemInfo::refresh()
{
    QFile stat(QStringLiteral("/proc/stat"));
    if (stat.open(QIODevice::ReadOnly | QIODevice::Text)) {
        const QStringList fields = QString::fromUtf8(stat.readLine())
            .trimmed()
            .split(' ', Qt::SkipEmptyParts);

        if (fields.size() >= 5 && fields[0] == QStringLiteral("cpu")) {
            quint64 values[10]{};
            const int count = std::min(10, fields.size() - 1);

            for (int i = 0; i < count; ++i) {
                bool ok = false;
                values[i] = fields[i + 1].toULongLong(&ok);
                if (!ok) {
                    values[i] = 0;
                }
            }

            const quint64 idle = values[3] + values[4];
            quint64 total = 0;
            for (int i = 0; i < count; ++i) {
                total += values[i];
            }

            if (m_previousCpuTotal > 0 && total > m_previousCpuTotal) {
                const quint64 totalDelta = total - m_previousCpuTotal;
                const quint64 idleDelta = idle >= m_previousCpuIdle
                    ? idle - m_previousCpuIdle
                    : 0;

                if (totalDelta > 0) {
                    m_cpuPercent = std::clamp(
                        (1.0 - static_cast<double>(idleDelta) /
                            static_cast<double>(totalDelta)) * 100.0,
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

    const QStorageInfo root = QStorageInfo::root();
    if (root.isValid() && root.bytesTotal() > 0) {
        const auto used = root.bytesTotal() - root.bytesAvailable();
        m_diskPercent = std::clamp(
            static_cast<double>(used) / static_cast<double>(root.bytesTotal()) * 100.0,
            0.0,
            100.0
        );
    }

    QFile uptimeFile(QStringLiteral("/proc/uptime"));
    if (uptimeFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        bool ok = false;
        const double seconds = QString::fromUtf8(uptimeFile.readAll())
            .section(' ', 0, 0)
            .toDouble(&ok);

        if (ok) {
            const quint64 totalMinutes = static_cast<quint64>(seconds / 60.0);
            const quint64 days = totalMinutes / 1440;
            const quint64 hours = (totalMinutes % 1440) / 60;
            const quint64 minutes = totalMinutes % 60;

            m_uptime = days > 0
                ? QStringLiteral("%1d %2h %3min").arg(days).arg(hours).arg(minutes)
                : QStringLiteral("%1h %2min").arg(hours).arg(minutes);
        }
    }

    m_windowsRuntimeAvailable =
        QFile::exists(QStringLiteral("/usr/bin/wine")) &&
        QFile::exists(QStringLiteral("/usr/bin/seven-winexec"));

    emit changed();
}

bool SystemInfo::launch(const QString &program)
{
    const QString executable = program.trimmed();
    if (executable.isEmpty()) {
        return false;
    }

    const bool started = QProcess::startDetached(
        QStringLiteral("/usr/bin/env"),
        {
            QStringLiteral("XDG_RUNTIME_DIR=/run/seven"),
            QStringLiteral("WAYLAND_DISPLAY=wayland-0"),
            QStringLiteral("QT_QPA_PLATFORM=wayland"),
            executable
        }
    );

    if (!started) {
        emit launchFailed(executable);
    }

    return started;
}

void SystemInfo::powerOff()
{
    QProcess::startDetached(QStringLiteral("/bin/systemctl"), {QStringLiteral("poweroff")});
}

void SystemInfo::reboot()
{
    QProcess::startDetached(QStringLiteral("/bin/systemctl"), {QStringLiteral("reboot")});
}
