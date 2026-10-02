import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    width: 720
    height: 470
    visible: true
    title: "Monitor do Sistema"
    color: "#071021"

    function metricColor(value) {
        if (value >= 85) return "#ff5b67"
        if (value >= 65) return "#ffb32f"
        return "#23a8ff"
    }

    Rectangle {
        anchors.fill: parent
        color: "#071021"
        border.width: 1
        border.color: "#285b9b"
        radius: 10
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        RowLayout {
            Layout.fillWidth: true

            Column {
                Text { text: "Monitor do Sistema"; color: "#ffffff"; font.pixelSize: 21; font.bold: true }
                Text { text: "Tempo ligado: " + SevenSystem.uptime; color: "#879cc0"; font.pixelSize: 11 }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: SevenSystem.hostname
                color: "#75baff"
                font.pixelSize: 12
            }
        }

        Repeater {
            model: [
                ["CPU", SevenSystem.cpuPercent],
                ["Memória", SevenSystem.memoryPercent],
                ["Armazenamento", SevenSystem.diskPercent]
            ]

            Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 86
                radius: 12
                color: "#0d192e"
                border.width: 1
                border.color: "#20385f"

                Column {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 8

                    Row {
                        width: parent.width

                        Text {
                            text: modelData[0]
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Item { width: parent.width - 130; height: 1 }

                        Text {
                            text: Math.round(modelData[1]) + "%"
                            color: metricColor(modelData[1])
                            font.pixelSize: 16
                            font.bold: true
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 10
                        radius: 5
                        color: "#182742"

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(1, modelData[1] / 100))
                            height: parent.height
                            radius: 5
                            color: metricColor(modelData[1])
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            radius: 10
            color: "#0b1629"
            border.width: 1
            border.color: "#1b3154"

            Row {
                anchors.centerIn: parent
                spacing: 22

                Text { text: SevenSystem.osName; color: "#c9d6eb"; font.pixelSize: 11 }
                Text { text: SevenSystem.kernel; color: "#7488aa"; font.pixelSize: 10 }
                Text {
                    text: SevenSystem.windowsRuntimeAvailable ? "Windows Runtime: OK" : "Windows Runtime: indisponível"
                    color: SevenSystem.windowsRuntimeAvailable ? "#42d7ad" : "#ff7c87"
                    font.pixelSize: 10
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: SevenSystem.refresh()
    }
}
