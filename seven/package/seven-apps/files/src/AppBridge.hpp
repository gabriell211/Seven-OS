#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>

class AppBridge final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString mode READ mode CONSTANT)
    Q_PROPERTY(QString title READ title CONSTANT)
    Q_PROPERTY(QString homePath READ homePath CONSTANT)
    Q_PROPERTY(double memoryPercent READ memoryPercent NOTIFY metricsChanged)
    Q_PROPERTY(double diskPercent READ diskPercent NOTIFY metricsChanged)
    Q_PROPERTY(QString networkSummary READ networkSummary NOTIFY stateChanged)
    Q_PROPERTY(QString windowsSummary READ windowsSummary NOTIFY stateChanged)

public:
    explicit AppBridge(QString mode, QObject *parent = nullptr);

    [[nodiscard]] QString mode() const;
    [[nodiscard]] QString title() const;
    [[nodiscard]] QString homePath() const;
    [[nodiscard]] double memoryPercent() const;
    [[nodiscard]] double diskPercent() const;
    [[nodiscard]] QString networkSummary() const;
    [[nodiscard]] QString windowsSummary() const;

    Q_INVOKABLE QVariantList listDirectory(const QString &path) const;
    Q_INVOKABLE QString parentDirectory(const QString &path) const;
    Q_INVOKABLE bool openEntry(const QString &path);
    Q_INVOKABLE bool launch(const QString &program);
    Q_INVOKABLE bool installWindows(const QString &path);
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void powerOff();
    Q_INVOKABLE void reboot();

signals:
    void metricsChanged();
    void stateChanged();
    void errorOccurred(const QString &message);

private:
    [[nodiscard]] bool startDetached(const QString &program, const QStringList &arguments = {});
    [[nodiscard]] QString commandOutput(const QString &program, const QStringList &arguments) const;
    void refreshMetrics();

    QString m_mode;
    double m_memoryPercent{0.0};
    double m_diskPercent{0.0};
    QString m_networkSummary;
    QString m_windowsSummary;
};
