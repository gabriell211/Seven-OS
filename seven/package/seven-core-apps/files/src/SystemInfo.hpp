#pragma once

#include <QObject>
#include <QString>

class SystemInfo final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString hostname READ hostname CONSTANT)
    Q_PROPERTY(QString osName READ osName CONSTANT)
    Q_PROPERTY(QString kernel READ kernel CONSTANT)
    Q_PROPERTY(QString uptime READ uptime NOTIFY changed)
    Q_PROPERTY(double cpuPercent READ cpuPercent NOTIFY changed)
    Q_PROPERTY(double memoryPercent READ memoryPercent NOTIFY changed)
    Q_PROPERTY(double diskPercent READ diskPercent NOTIFY changed)
    Q_PROPERTY(bool windowsRuntimeAvailable READ windowsRuntimeAvailable NOTIFY changed)

public:
    explicit SystemInfo(QObject *parent = nullptr);

    [[nodiscard]] QString hostname() const;
    [[nodiscard]] QString osName() const;
    [[nodiscard]] QString kernel() const;
    [[nodiscard]] QString uptime() const;
    [[nodiscard]] double cpuPercent() const;
    [[nodiscard]] double memoryPercent() const;
    [[nodiscard]] double diskPercent() const;
    [[nodiscard]] bool windowsRuntimeAvailable() const;

    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool launch(const QString &program);
    Q_INVOKABLE void powerOff();
    Q_INVOKABLE void reboot();

signals:
    void changed();
    void launchFailed(const QString &program);

private:
    quint64 m_previousCpuTotal{0};
    quint64 m_previousCpuIdle{0};
    QString m_uptime;
    double m_cpuPercent{0.0};
    double m_memoryPercent{0.0};
    double m_diskPercent{0.0};
    bool m_windowsRuntimeAvailable{false};
};
