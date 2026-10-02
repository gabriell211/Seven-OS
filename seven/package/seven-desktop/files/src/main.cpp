#include "SystemBridge.hpp"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName(QStringLiteral("Seven OS"));
    QCoreApplication::setApplicationName(QStringLiteral("Seven Desktop"));

    QGuiApplication app(argc, argv);

    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    SystemBridge system;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("SevenSystem"), &system);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(EXIT_FAILURE); },
        Qt::QueuedConnection
    );

    engine.loadFromModule(QStringLiteral("Seven.Desktop"), QStringLiteral("Main"));

    return app.exec();
}
