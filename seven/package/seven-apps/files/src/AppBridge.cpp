#include "AppBridge.hpp"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QProcessEnvironment>
#include <QStorageInfo>
#include <QTextStream>

#include <algorithm>

namespace {
QString normalizedMode(QString mode)
{
    if (mode.startsWith(QStringLiteral("seven-"))) {
        mode.remove(0, 6);
    }

    if (mode == QStringLiteral("app")) {
        return QStringLiteral("files");
    }

    return mode;
}
}

AppBridge::AppBridge(QString mode, QObject *parent)
    : QObject(parent),
      m_mode(normalizedMode(std::move(mode)))
{
    refresh();
}

QString AppBridge::mode() const
{
    return m_mode;
}

QString AppBridge::title() const
{
    if (m_mode == QStringLiteral("files")) {
        return QStringLiteral("Seven Files");
    }
    if (m_mode == QStringLiteral("settings")) {
        return QStringLiteral("Seven Settings");
    }
    if (m_mode == QStringLiteral("store")) {
        return QStringLiteral("Seven Store");
    }
    if (m_mode == QStringLiteral("monitor")) {
        return QStringLiteral("Seven System Monitor");
    }

    return QStringLiteral("Seven");
}

QString AppBridge::homePath() const
{
    const QString home = QDir::homePath();
    return home.isEmpty() ? QStringLiteral("/") : home;
}

double AppBridge::memoryPercent() const
{
    return m_memoryPercent;
}

double AppBridge::diskPercent() const
{
    return m_diskPercent;
}

QString AppBridge::networkSummary() const
{
    return m_networkSummary;
}

QString AppBridge::windowsSummary() const
{
    return m_windowsSummary;
}

QVariantList AppBridge::listDirectory(const QString &path) const
{
    QVariantList result;
    const QDir directory(path.isEmpty() ? homePath() : path);

    if (!directory.exists()) {
        return result;
    }

    const QFileInfoList entries = directory.entryInfoList(
        QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Hidden,
        QDir::DirsFirst | QDir::IgnoreCase | QDir::Name
    );

    result.reserve(entries.size());

    for (const QFileInfo &entry : entries) {
        QVariantMap item;
        item.insert(QStringLiteral("name"), entry.fileName());
        item.insert(QStringLiteral("path"), entry.absoluteFilePath());
        item.insert(QStringLiteral("directory"), entry.isDir());
        item.insert(QStringLiteral("executable"), entry.isExecutable());
        item.insert(QStringLiteral("size"), entry.isDir() ? 0 : entry.size());
        item.insert(QStringLiteral("suffix"), entry.suffix().toLower());
        result.push_back(item);
    }

    return result;
}

QString AppBridge::parentDirectory(const QString &path) const
{
    QDir directory(path);
    if (directory.cdUp()) {
        return directory.absolutePath();
    }

    return QStringLiteral("/");
}

bool AppBridge::openEntry(const QString &path)
{
    const QFileInfo info(path);
    if (!info.exists()) {
        emit errorOccurred(QStringLiteral("Arquivo não encontrado: %1").arg(path));
        return false;
    }

    if (info.isDir()) {
        return true;
    }

    const QString suffix = info.suffix().toLower();
    if (suffix == QStringLiteral("exe")) {
        return startDetached(QStringLiteral("/usr/bin/seven-winexec"), {info.absoluteFilePath()});
    }
    if (suffix == QStringLiteral("msi")) {
        return startDetached(QStringLiteral("/usr/bin/seven-wininstall"), {info.absoluteFilePath()});
    }

    if (info.isExecutable()) {
        return startDetached(info.absoluteFilePath());
    }

    emit errorOccurred(QStringLiteral("Ainda não há aplicativo associado a %1").arg(info.fileName()));
    return false;
}

bool AppBridge::launch(const QString &program)
{
    return startDetached(program);
}

bool AppBridge::installWindows(const QString &path)
{
    return startDetached(QStringLiteral("/usr/bin/seven-wininstall"), {path});
}

void AppBridge::refresh()
{
    refreshMetrics();

    const QString network = commandOutput(
        QStringLiteral("/usr/bin/nmcli"),
        {QStringLiteral("-t"), QStringLiteral("-f"), QStringLiteral("STATE"), QStringLiteral("general")}
    );
    m_networkSummary = network.isEmpty()
        ? QStringLiteral("NetworkManager indisponível")
        : network.trimmed();

    const QString windows = commandOutput(
        QStringLiteral("/usr/bin/seven-winexec"),
        {QStringLiteral("--status")}
    );
    m_windowsSummary = windows.isEmpty()
        ? QStringLiteral("Seven Windows Runtime indisponível")
        : windows.trimmed();

    emit stateChanged();
}

void AppBridge::powerOff()
{
    if (!startDetached(QStringLiteral("/bin/systemctl"), {QStringLiteral("poweroff")})) {
        emit errorOccurred(QStringLiteral("Não foi possível desligar o sistema."));
    }
}

void AppBridge::reboot()
{
    if (!startDetached(QStringLiteral("/bin/systemctl"), {QStringLiteral("reboot")})) {
        emit errorOccurred(QStringLiteral("Não foi possível reiniciar o sistema."));
    }
}

bool AppBridge::startDetached(const QString &program, const QStringList &arguments)
{
    if (program.trimmed().isEmpty()) {
        return false;
    }

    QProcess process;
    QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
    environment.insert(QStringLiteral("QT_QPA_PLATFORM"), QStringLiteral("wayland"));
    environment.insert(QStringLiteral("WAYLAND_DISPLAY"), QStringLiteral("seven-0"));
    environment.insert(QStringLiteral("XDG_SESSION_TYPE"), QStringLiteral("wayland"));
    environment.insert(QStringLiteral("XDG_CURRENT_DESKTOP"), QStringLiteral("Seven"));

    process.setProcessEnvironment(environment);
    process.setProgram(program);
    process.setArguments(arguments);

    if (process.startDetached()) {
        return true;
    }

    emit errorOccurred(QStringLiteral("Falha ao iniciar %1").arg(program));
    return false;
}

QString AppBridge::commandOutput(const QString &program, const QStringList &arguments) const
{
    QProcess process;
    process.start(program, arguments);

    if (!process.waitForStarted(1500)) {
        return {};
    }

    if (!process.waitForFinished(3000)) {
        process.kill();
        process.waitForFinished();
        return {};
    }

    return QString::fromUtf8(process.readAllStandardOutput()).trimmed();
}

void AppBridge::refreshMetrics()
{
    QFile meminfo(QStringLiteral("/proc/meminfo"));
    if (meminfo.open(QIODevice::ReadOnly | QIODevice::Text)) {
        quint64 totalKb = 0;
        quint64 availableKb = 0;
        QTextStream stream(&meminfo);

        while (!stream.atEnd()) {
            const QString line = stream.readLine();
            const qsizetype separator = line.indexOf(':');
            if (separator <= 0) {
                continue;
            }

            const QString key = line.left(separator);
            bool ok = false;
            const quint64 value = line.mid(separator + 1).trimmed().section(' ', 0, 0).toULongLong(&ok);
            if (!ok) {
                continue;
            }

            if (key == QStringLiteral("MemTotal")) {
                totalKb = value;
            } else if (key == QStringLiteral("MemAvailable")) {
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
