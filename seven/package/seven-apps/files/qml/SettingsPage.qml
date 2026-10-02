import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ScrollView {
    clip: true

    ColumnLayout {
        width: parent.width
        spacing: 14

        Label {
            text: "Sistema"
            color: "#ffffff"
            font.pixelSize: 24
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: aboutColumn.implicitHeight + 28
            radius: 14
            color: "#1c1626"

            ColumnLayout {
                id: aboutColumn
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                Label { text: "Seven OS Developer Preview"; color: "#ffffff"; font.pixelSize: 16; font.bold: true }
                Label { text: "Interface nativa Seven • Qt 6 • Wayland"; color: "#a69cad" }
                Label { text: "Aplicativos Windows: Wine 11 / new WoW64 / NTSYNC"; color: "#77bcff" }
            }
        }

        Label {
            text: "Rede"
            color: "#ffffff"
            font.pixelSize: 18
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: networkText.implicitHeight + 30
            radius: 14
            color: "#1c1626"

            Label {
                id: networkText
                anchors.fill: parent
                anchors.margins: 15
                text: SevenApp.networkSummary
                color: "#d8d1e0"
                wrapMode: Text.Wrap
            }
        }

        Label {
            text: "Compatibilidade Windows"
            color: "#ffffff"
            font.pixelSize: 18
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: windowsText.implicitHeight + 30
            radius: 14
            color: "#1c1626"

            Label {
                id: windowsText
                anchors.fill: parent
                anchors.margins: 15
                text: SevenApp.windowsSummary
                color: "#d8d1e0"
                font.family: "DejaVu Sans Mono"
                wrapMode: Text.Wrap
            }
        }

        Label {
            text: "Energia"
            color: "#ffffff"
            font.pixelSize: 18
            font.bold: true
        }

        RowLayout {
            spacing: 10

            Button {
                text: "Reiniciar"
                onClicked: SevenApp.reboot()
            }

            Button {
                text: "Desligar"
                onClicked: SevenApp.powerOff()
            }
        }

        Item { Layout.fillHeight: true }
    }
}
