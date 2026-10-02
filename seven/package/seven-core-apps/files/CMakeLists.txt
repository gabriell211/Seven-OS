cmake_minimum_required(VERSION 3.21)

project(SevenCoreApps VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

qt_standard_project_setup(REQUIRES 6.5)

set(SEVEN_COMMON_SOURCES
    src/SystemInfo.cpp
    src/SystemInfo.hpp
    src/FileModel.cpp
    src/FileModel.hpp
)

function(add_seven_app target qml_file)
    qt_add_executable(${target}
        src/main.cpp
        ${SEVEN_COMMON_SOURCES}
    )

    target_compile_definitions(${target} PRIVATE
        SEVEN_APP_NAME="${target}"
        SEVEN_QML_URL="qrc:/seven/${qml_file}"
    )

    qt_add_resources(${target} "seven_qml"
        PREFIX "/seven"
        FILES
            qml/${qml_file}
    )

    target_link_libraries(${target} PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
    )

    install(TARGETS ${target} RUNTIME DESTINATION bin)
endfunction()

add_seven_app(seven-files Files.qml)
add_seven_app(seven-settings Settings.qml)
add_seven_app(seven-monitor Monitor.qml)
