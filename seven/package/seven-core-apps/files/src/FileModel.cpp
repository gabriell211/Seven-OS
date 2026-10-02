#include "FileModel.hpp"

#include <QDir>
#include <QFileInfo>
#include <QProcess>

FileModel::FileModel(QObject *parent)
    : QAbstractListModel(parent),
      m_currentPath(QDir::homePath())
{
    if (m_currentPath.isEmpty() || !QDir(m_currentPath).exists()) {
        m_currentPath = QStringLiteral("/");
    }
    load();
}

int FileModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_entries.size();
}

QVariant FileModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_entries.size()) {
        return {};
    }

    const QFileInfo &entry = m_entries.at(index.row());

    switch (role) {
    case NameRole:
        return entry.fileName();
    case PathRole:
        return entry.absoluteFilePath();
    case DirectoryRole:
        return entry.isDir();
    case SizeRole:
        return entry.isDir() ? QVariant{} : QVariant::fromValue(entry.size());
    case ModifiedRole:
        return entry.lastModified();
    case ExtensionRole:
        return entry.suffix().toLower();
    default:
        return {};
    }
}

QHash<int, QByteArray> FileModel::roleNames() const
{
    return {
        {NameRole, "name"},
        {PathRole, "path"},
        {DirectoryRole, "isDirectory"},
        {SizeRole, "size"},
        {ModifiedRole, "modified"},
        {ExtensionRole, "extension"}
    };
}

QString FileModel::currentPath() const
{
    return m_currentPath;
}

void FileModel::setPath(const QString &path)
{
    const QDir directory(path);
    if (!directory.exists()) {
        emit error(QStringLiteral("Pasta não encontrada: %1").arg(path));
        return;
    }

    m_currentPath = directory.absolutePath();
    load();
    emit currentPathChanged();
}

void FileModel::home()
{
    setPath(QDir::homePath());
}

void FileModel::up()
{
    QDir directory(m_currentPath);
    if (directory.cdUp()) {
        setPath(directory.absolutePath());
    }
}

void FileModel::refresh()
{
    load();
}

bool FileModel::activate(int row)
{
    if (row < 0 || row >= m_entries.size()) {
        return false;
    }

    const QFileInfo entry = m_entries.at(row);
    if (entry.isDir()) {
        setPath(entry.absoluteFilePath());
        return true;
    }

    const QString extension = entry.suffix().toLower();
    QString program;

    if (extension == QStringLiteral("exe")) {
        program = QStringLiteral("/usr/bin/seven-winexec");
    } else if (extension == QStringLiteral("msi")) {
        program = QStringLiteral("/usr/bin/seven-wininstall");
    } else if (entry.isExecutable()) {
        return QProcess::startDetached(
            QStringLiteral("/usr/bin/env"),
            {
                QStringLiteral("XDG_RUNTIME_DIR=/run/user/0"),
                QStringLiteral("WAYLAND_DISPLAY=wayland-0"),
                entry.absoluteFilePath()
            }
        );
    } else {
        emit error(QStringLiteral("Ainda não há aplicativo associado a %1").arg(entry.fileName()));
        return false;
    }

    const bool launched = QProcess::startDetached(
        QStringLiteral("/usr/bin/env"),
        {
            QStringLiteral("XDG_RUNTIME_DIR=/run/user/0"),
            QStringLiteral("WAYLAND_DISPLAY=wayland-0"),
            program,
            entry.absoluteFilePath()
        }
    );

    if (!launched) {
        emit error(QStringLiteral("Não foi possível abrir %1").arg(entry.fileName()));
    }

    return launched;
}

void FileModel::load()
{
    beginResetModel();

    QDir directory(m_currentPath);
    directory.setFilter(QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Readable);
    directory.setSorting(QDir::DirsFirst | QDir::Name | QDir::IgnoreCase);
    m_entries = directory.entryInfoList();

    endResetModel();
}
