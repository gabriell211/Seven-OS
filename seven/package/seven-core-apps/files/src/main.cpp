#include "FileModel.hpp"
#include "SystemInfo.hpp"

#include <QFileInfo>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QUrl>

#ifndef SEVEN_APP_NAME
#define SEVEN_APP_NAME "seven-app"
#endif

#ifndef SEVEN_QML_URL
#define SEVEN_QML_URL "qrc:/seven/Settings.qml"
#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName(QStringLiteral("Seven OS"));
    QCoreApplication::setApplicationName(QStringLiteral(SEVEN_APP_NAME));

    QGuiApplication app(argc, argv);
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    SystemInfo system;
    FileModel files;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("SevenSystem"), &system);
    engine.rootContext()->setContextProperty(QStringLiteral("SevenFiles"), &files);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(EXIT_FAILURE); },
        Qt::QueuedConnection
    );

    engine.load(QUrl(QStringLiteral(SEVEN_QML_URL)));
    return app.exec();
}
