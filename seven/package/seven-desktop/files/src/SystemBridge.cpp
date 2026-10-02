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

double SystemBridge::memoryPercent() const
{
    return m_memoryPercent;
}

double SystemBridge::diskPercent() const
{
    return m_diskPercent;
}

bool SystemBridge::launch(const QString &program)
{
    if (program.trimmed().isEmpty()) {
        return false;
    }

    if (QProcess::startDetached(program, {})) {
        return true;
    }

    emit launchFailed(program);
    return false;
}

bool SystemBridge::launchWindows(const QString &path)
{
    if (path.trimmed().isEmpty()) {
        return false;
    }

    if (QProcess::startDetached(QStringLiteral("/usr/bin/seven-winexec"), {path})) {
        return true;
    }

    emit launchFailed(path);
    return false;
}

void SystemBridge::refreshMetrics()
{
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
            m_memoryPercent = std::clamp((used / static_cast<double>(totalKb)) * 100.0, 0.0, 100.0);
        }
    }

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
    QProcess::startDetached(QStringLiteral("/sbin/poweroff"), {});
}

void SystemBridge::reboot()
{
    QProcess::startDetached(QStringLiteral("/sbin/reboot"), {});
}
