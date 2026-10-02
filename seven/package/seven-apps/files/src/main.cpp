#include "AppBridge.hpp"

#include <QCoreApplication>
#include <QFileInfo>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName(QStringLiteral("Seven OS"));

    const QString executable = argc > 0
        ? QFileInfo(QString::fromLocal8Bit(argv[0])).fileName()
        : QStringLiteral("seven-files");

    QCoreApplication::setApplicationName(executable);

    QGuiApplication app(argc, argv);
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    AppBridge bridge(executable);
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("SevenApp"), &bridge);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(EXIT_FAILURE); },
        Qt::QueuedConnection
    );

    engine.loadFromModule(QStringLiteral("Seven.Apps"), QStringLiteral("Main"));

    return app.exec();
}
