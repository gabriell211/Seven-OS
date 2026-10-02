import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        Label {
            text: "Monitor do Sistema"
            color: "#ffffff"
            font.pixelSize: 26
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            Repeater {
                model: [
                    { title: "Memória", value: SevenApp.memoryPercent, accent: "#8f63ff" },
                    { title: "Armazenamento", value: SevenApp.diskPercent, accent: "#3bcaa3" }
                ]

                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 180
                    radius: 16
                    color: "#1c1626"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18

                        Label { text: modelData.title; color: "#aaa1b2"; font.pixelSize: 13 }

                        Label {
                            text: Math.round(modelData.value) + "%"
                            color: "#ffffff"
                            font.pixelSize: 40
                            font.bold: true
                        }

                        ProgressBar {
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: modelData.value
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: runtimeColumn.implicitHeight + 32
            radius: 16
            color: "#1c1626"

            ColumnLayout {
                id: runtimeColumn
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                Label { text: "Serviços"; color: "#ffffff"; font.pixelSize: 17; font.bold: true }
                Label { text: "Rede: " + SevenApp.networkSummary; color: "#b9b0c1"; wrapMode: Text.Wrap }
                Label { text: SevenApp.windowsSummary; color: "#77bcff"; wrapMode: Text.Wrap }
            }
        }

        Item { Layout.fillHeight: true }

        Timer {
            interval: 3000
            running: true
            repeat: true
            onTriggered: SevenApp.refresh()
        }
    }
}
