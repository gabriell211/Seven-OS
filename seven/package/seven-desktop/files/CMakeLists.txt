cmake_minimum_required(VERSION 3.21)

project(SevenDesktop VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    WaylandCompositor
)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(seven-desktop
    src/main.cpp
    src/SystemBridge.cpp
    src/SystemBridge.hpp
)

qt_add_qml_module(seven-desktop
    URI Seven.Desktop
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/GlassPanel.qml
        qml/SidebarButton.qml
        qml/MetricCard.qml
)

target_link_libraries(seven-desktop PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::WaylandCompositor
)

install(TARGETS seven-desktop
    RUNTIME DESTINATION bin
)
