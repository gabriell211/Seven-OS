import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtWayland.Compositor
import QtWayland.Compositor.XdgShell

WaylandCompositor {
    id: compositor
    socketName: "wayland-0"

    property color neonBlue: "#1488ff"
    property color neonPurple: "#923cff"
    property color panelColor: "#d0071022"

    ListModel {
        id: shellSurfaces
    }

    XdgShell {
        onToplevelCreated: (toplevel, xdgSurface) => {
            shellSurfaces.append({ shellSurface: xdgSurface })
        }
    }

    WaylandOutput {
        sizeFollowsWindow: true

        window: Window {
            id: rootWindow

            width: 1536
            height: 864
            visible: true
            visibility: Window.FullScreen
            color: "#020615"
            title: "Seven OS"

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#03091c" }
                    GradientStop { position: 0.42; color: "#071c55" }
                    GradientStop { position: 0.72; color: "#28185d" }
                    GradientStop { position: 1.0; color: "#020712" }
                }
            }

            Rectangle {
                width: rootWindow.width * 0.62
                height: rootWindow.height * 0.72
                radius: width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: "#1e4cb4"
                opacity: 0.18
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 65
                text: "7"
                color: "#246cff"
                opacity: 0.20
                font.pixelSize: Math.min(rootWindow.width, rootWindow.height) * 0.45
                font.bold: true
                rotation: -7
            }

            Item {
                id: clientArea
                anchors.fill: parent
                anchors.leftMargin: 182
                anchors.rightMargin: 272
                anchors.topMargin: 48
                anchors.bottomMargin: 92

                Repeater {
                    model: shellSurfaces

                    ShellSurfaceItem {
                        id: surfaceItem

                        shellSurface: modelData
                        x: 44 + (index % 5) * 28
                        y: 74 + (index % 4) * 24
                        width: Math.min(820, clientArea.width - 80)
                        height: Math.min(560, clientArea.height - 100)

                        onSurfaceDestroyed: shellSurfaces.remove(index)

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -1
                            color: "transparent"
                            border.width: 1
                            border.color: "#467bd0"
                            radius: 10
                            z: -1
                        }
                    }
                }
            }

            Rectangle {
                id: topBar
                height: 48
                anchors.left: sidebar.right
                anchors.right: parent.right
                anchors.top: parent.top
                color: "#b0050b1a"

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 18

                    Text { text: "⌕"; color: "#d6e4ff"; font.pixelSize: 22 }
                    Rectangle { width: 1; height: 22; color: "#355388" }
                    Text { text: "▣"; color: "#97bdff"; font.pixelSize: 16 }
                    Text { text: "◖"; color: "#d6e4ff"; font.pixelSize: 18 }
                    Text { text: "⌁"; color: "#d6e4ff"; font.pixelSize: 20 }
                    Text { text: "▤"; color: "#d6e4ff"; font.pixelSize: 16 }

                    Text {
                        id: topClock
                        color: "#ffffff"
                        font.pixelSize: 13
                        text: Qt.formatDateTime(new Date(), "ddd, dd MMM  hh:mm")

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: topClock.text = Qt.formatDateTime(new Date(), "ddd, dd MMM  hh:mm")
                        }
                    }
                }
            }

            GlassPanel {
                id: sidebar
                width: 164
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.top: parent.top
                anchors.topMargin: 32
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 32
                radius: 15

                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 5

                    Item {
                        width: parent.width
                        height: 66

                        Row {
                            anchors.centerIn: parent
                            spacing: 10

                            Text {
                                text: "7"
                                color: "#1488ff"
                                font.pixelSize: 34
                                font.bold: true
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: "SEVEN"
                                    color: "#ffffff"
                                    font.pixelSize: 16
                                    font.bold: true
                                }
                                Text {
                                    text: "OS"
                                    color: "#29a1ff"
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                            }
                        }
                    }

                    SidebarButton { text: "Início"; glyph: "⌂"; selected: true }
                    SidebarButton { text: "Aplicativos"; glyph: "▦" }
                    SidebarButton { text: "Arquivos"; glyph: "▰"; onClicked: SevenSystem.launch("seven-files") }
                    SidebarButton { text: "Configurações"; glyph: "⚙"; onClicked: SevenSystem.launch("seven-settings") }
                    SidebarButton { text: "Loja"; glyph: "▣"; onClicked: SevenSystem.launch("seven-store") }
                    SidebarButton { text: "Terminal"; glyph: "▤"; onClicked: SevenSystem.launch("seven-terminal") }
                    SidebarButton { text: "Monitor do Sistema"; glyph: "▥"; onClicked: SevenSystem.launch("seven-monitor") }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#203154"
                        opacity: 0.8
                    }

                    Text {
                        text: "Favoritos"
                        color: "#8997b5"
                        font.pixelSize: 11
                        leftPadding: 9
                        topPadding: 8
                    }

                    SidebarButton { text: "Navegador"; glyph: "◉" }
                    SidebarButton { text: "E-mail"; glyph: "✉" }
                    SidebarButton { text: "Mídia"; glyph: "▶" }
                    SidebarButton { text: "Editor"; glyph: "{ }" }

                    Item { width: 1; height: Math.max(4, sidebar.height - 690) }

                    Row {
                        width: parent.width
                        height: 42
                        spacing: 8
                        Rectangle {
                            width: 34
                            height: 34
                            radius: 17
                            color: "#3c64dc"
                            Text {
                                anchors.centerIn: parent
                                text: "●"
                                color: "#ffffff"
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text { text: "Administrador"; color: "#ffffff"; font.pixelSize: 12 }
                            Text { text: "Seven OS"; color: "#8798b8"; font.pixelSize: 10 }
                        }
                    }

                    Button {
                        width: 44
                        height: 44
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: SevenSystem.powerOff()

                        background: Rectangle {
                            radius: 22
                            color: parent.hovered ? "#26365c" : "#101a32"
                        }

                        contentItem: Text {
                            text: "⏻"
                            color: "#ffffff"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            Column {
                anchors.left: sidebar.right
                anchors.leftMargin: 48
                anchors.top: topBar.bottom
                anchors.topMargin: 54
                spacing: 6

                Text {
                    id: heroClock
                    text: Qt.formatDateTime(new Date(), "hh:mm")
                    color: "#ffffff"
                    font.pixelSize: 78
                    font.weight: Font.Light

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: heroClock.text = Qt.formatDateTime(new Date(), "hh:mm")
                    }
                }

                Text {
                    text: Qt.formatDate(new Date(), "dddd, dd 'de' MMMM yyyy")
                    color: "#d7dcf0"
                    font.pixelSize: 18
                }

                Rectangle {
                    width: 395
                    height: 46
                    radius: 23
                    color: "#7a162344"
                    border.width: 1
                    border.color: "#6e73d8"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 14
                        spacing: 12

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "⌕"
                            color: "#ffffff"
                            font.pixelSize: 23
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Pesquisar no Seven OS..."
                            color: "#c7bdd8"
                            font.pixelSize: 14
                        }

                        Item { width: 88; height: 1 }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 58
                            height: 27
                            radius: 7
                            color: "#1a2748"
                            border.width: 1
                            border.color: "#536184"

                            Text {
                                anchors.centerIn: parent
                                text: "Ctrl + K"
                                color: "#aebbd4"
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }

            Column {
                id: rightRail
                width: 248
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.top: topBar.bottom
                anchors.topMargin: 10
                spacing: 10

                GlassPanel {
                    width: parent.width
                    height: 138

                    Column {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 8

                        Text {
                            text: SevenSystem.hostname
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Row {
                            spacing: 12
                            Text { text: "☁"; color: "#d9ebff"; font.pixelSize: 43 }
                            Column {
                                Text { text: "--°C"; color: "#ffffff"; font.pixelSize: 28; font.bold: true }
                                Text { text: "Clima indisponível"; color: "#b2bfd8"; font.pixelSize: 11 }
                                Text { text: "Aguardando Seven Weather"; color: "#71809d"; font.pixelSize: 9 }
                            }
                        }
                    }
                }

                GlassPanel {
                    width: parent.width
                    height: 128

                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 9

                        Text {
                            text: "Desempenho do Sistema"
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        Row {
                            spacing: 8

                            MetricCard { title: "CPU"; value: SevenSystem.cpuPercent; accent: "#19a7ff" }
                            MetricCard { title: "RAM"; value: SevenSystem.memoryPercent; accent: "#8b5cff" }
                            MetricCard { title: "SSD"; value: SevenSystem.diskPercent; accent: "#34d5ad" }
                        }
                    }
                }

                GlassPanel {
                    width: parent.width
                    height: 176

                    Column {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        Text {
                            text: "Sistema"
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        Text { text: SevenSystem.osName; color: "#dce6f8"; font.pixelSize: 12 }
                        Text { text: SevenSystem.kernel; color: "#8fa1c2"; font.pixelSize: 10; wrapMode: Text.Wrap }
                        Rectangle { width: parent.width; height: 1; color: "#263856" }
                        Text { text: "Compatibilidade Windows"; color: "#dce6f8"; font.pixelSize: 11 }
                        Text { text: "Wine 11 • Win32/Win64 • NTSYNC"; color: "#64b5ff"; font.pixelSize: 10 }
                    }
                }
            }

            GlassPanel {
                id: dock
                height: 66
                width: 590
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                radius: 22

                Row {
                    anchors.centerIn: parent
                    spacing: 12

                    Repeater {
                        model: [
                            ["7", "#147cff"],
                            ["▰", "#f5b536"],
                            ["◉", "#1ebcff"],
                            ["✉", "#5796ff"],
                            ["▶", "#9b42e8"],
                            ["{ }", "#2589ff"],
                            ["▣", "#4ea4ff"],
                            ["⚙", "#cad7ec"],
                            ["▥", "#4aa7ff"]
                        ]

                        Rectangle {
                            required property var modelData
                            width: 42
                            height: 42
                            radius: 10
                            color: mouse.containsMouse ? "#274678" : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: modelData[0]
                                color: modelData[1]
                                font.pixelSize: 22
                                font.bold: true
                            }

                            MouseArea {
                                id: mouse
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }
                    }

                    Rectangle {
                        width: 1
                        height: 34
                        color: "#34456b"
                    }

                    Text {
                        text: "▱"
                        color: "#7684a0"
                        font.pixelSize: 25
                    }
                }
            }

            Timer {
                interval: 5000
                running: true
                repeat: true
                onTriggered: SevenSystem.refreshMetrics()
            }

            Connections {
                target: SevenSystem

                function onLaunchFailed(program) {
                    launchToast.text = "Aplicativo ainda não disponível: " + program
                    launchToast.visible = true
                    toastTimer.restart()
                }
            }

            Rectangle {
                id: launchToast
                property alias text: toastText.text

                visible: false
                width: 350
                height: 50
                radius: 12
                color: "#ed101a31"
                border.width: 1
                border.color: "#3d78d5"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: dock.top
                anchors.bottomMargin: 12

                Text {
                    id: toastText
                    anchors.centerIn: parent
                    color: "#dbe8ff"
                    font.pixelSize: 12
                }

                Timer {
                    id: toastTimer
                    interval: 2500
                    onTriggered: launchToast.visible = false
                }
            }
        }
    }
}
