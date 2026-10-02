#pragma once

#include <QObject>
#include <QString>

class SystemBridge final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString hostname READ hostname CONSTANT)
    Q_PROPERTY(QString osName READ osName CONSTANT)
    Q_PROPERTY(QString kernel READ kernel CONSTANT)
    Q_PROPERTY(double cpuPercent READ cpuPercent NOTIFY metricsChanged)
    Q_PROPERTY(double memoryPercent READ memoryPercent NOTIFY metricsChanged)
    Q_PROPERTY(double diskPercent READ diskPercent NOTIFY metricsChanged)

public:
    explicit SystemBridge(QObject *parent = nullptr);

    [[nodiscard]] QString hostname() const;
    [[nodiscard]] QString osName() const;
    [[nodiscard]] QString kernel() const;
    [[nodiscard]] double cpuPercent() const;
    [[nodiscard]] double memoryPercent() const;
    [[nodiscard]] double diskPercent() const;

    Q_INVOKABLE bool launch(const QString &program);
    Q_INVOKABLE bool launchWindows(const QString &path);
    Q_INVOKABLE void refreshMetrics();
    Q_INVOKABLE void powerOff();
    Q_INVOKABLE void reboot();

signals:
    void metricsChanged();
    void launchFailed(const QString &program);

private:
    quint64 m_previousCpuTotal{0};
    quint64 m_previousCpuIdle{0};
    double m_cpuPercent{0.0};
    double m_memoryPercent{0.0};
    double m_diskPercent{0.0};
};
