#pragma once

#include <QAbstractListModel>
#include <QFileInfoList>
#include <QString>

class FileModel final : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString currentPath READ currentPath NOTIFY currentPathChanged)

public:
    enum Role {
        NameRole = Qt::UserRole + 1,
        PathRole,
        DirectoryRole,
        SizeRole,
        ModifiedRole,
        ExtensionRole
    };
    Q_ENUM(Role)

    explicit FileModel(QObject *parent = nullptr);

    [[nodiscard]] int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;
    [[nodiscard]] QHash<int, QByteArray> roleNames() const override;
    [[nodiscard]] QString currentPath() const;

    Q_INVOKABLE void setPath(const QString &path);
    Q_INVOKABLE void home();
    Q_INVOKABLE void up();
    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool activate(int row);

signals:
    void currentPathChanged();
    void error(const QString &message);

private:
    void load();

    QString m_currentPath;
    QFileInfoList m_entries;
};
