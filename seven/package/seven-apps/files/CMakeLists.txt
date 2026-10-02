cmake_minimum_required(VERSION 3.21)

project(SevenApps VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Network)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(seven-app
    src/main.cpp
    src/AppBridge.cpp
    src/AppBridge.hpp
)

qt_add_qml_module(seven-app
    URI Seven.Apps
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/FilesPage.qml
        qml/SettingsPage.qml
        qml/StorePage.qml
        qml/MonitorPage.qml
)

target_link_libraries(seven-app PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Network
)

install(TARGETS seven-app RUNTIME DESTINATION bin)
