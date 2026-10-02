import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    width: 800
    height: 560
    visible: true
    title: "Seven Store"
    color: "#071021"

    Rectangle {
        anchors.fill: parent
        color: "#071021"
        border.width: 1
        border.color: "#285b9b"
        radius: 10
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        RowLayout {
            Layout.fillWidth: true

            Column {
                Text { text: "Seven Store"; color: "#ffffff"; font.pixelSize: 24; font.bold: true }
                Text { text: "Aplicativos e componentes do Seven OS"; color: "#879cc0"; font.pixelSize: 11 }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "Rede: " + SevenSystem.networkState
                color: SevenSystem.networkState === "connected" ? "#42d7ad" : "#8aa0c0"
                font.pixelSize: 11
            }
        }

        Repeater {
            model: [
                {
                    title: "Aplicativos Seven",
                    description: "Arquivos, Configurações, Terminal e Monitor do Sistema fazem parte da imagem oficial.",
                    action: "Abrir Arquivos",
                    command: "seven-files"
                },
                {
                    title: "Aplicativos Windows",
                    description: SevenSystem.windowsRuntimeAvailable
                        ? "Wine 11 está disponível. Abra .exe ou .msi pelo Seven Files para executar ou instalar."
                        : "O runtime Windows ainda não está disponível nesta imagem.",
                    action: "Procurar instalador",
                    command: "seven-files"
                },
                {
                    title: "Atualizações assinadas",
                    description: "O mecanismo de imagem e recuperação está preparado localmente. Um repositório remoto não é inventado nesta Developer Preview.",
                    action: "",
                    command: ""
                }
            ]

            Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 118
                radius: 14
                color: "#0d192e"
                border.width: 1
                border.color: "#20385f"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Rectangle {
                        width: 58
                        height: 58
                        radius: 16
                        color: "#163d78"

                        Text {
                            anchors.centerIn: parent
                            text: "7"
                            color: "#72baff"
                            font.pixelSize: 30
                            font.bold: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text { text: modelData.title; color: "#ffffff"; font.pixelSize: 15; font.bold: true }
                        Text {
                            Layout.fillWidth: true
                            text: modelData.description
                            color: "#91a5c5"
                            font.pixelSize: 11
                            wrapMode: Text.Wrap
                        }
                    }

                    Button {
                        visible: modelData.action !== ""
                        text: modelData.action
                        onClicked: SevenSystem.launch(modelData.command)
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        Text {
            Layout.fillWidth: true
            text: "Seven Store não baixa software de uma origem fictícia: catálogo remoto e assinatura de pacotes só serão ativados quando houver infraestrutura publicada."
            color: "#667a9c"
            font.pixelSize: 10
            wrapMode: Text.Wrap
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: SevenSystem.refresh()
    }
}
