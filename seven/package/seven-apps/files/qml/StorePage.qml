import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        Label {
            text: "Seven Store"
            color: "#ffffff"
            font.pixelSize: 26
            font.bold: true
        }

        Label {
            Layout.fillWidth: true
            text: "Central de software do Seven OS. Nesta Developer Preview, os componentes nativos são entregues pela imagem do sistema e aplicativos Windows podem ser instalados pelo Seven Files."
            color: "#aaa1b2"
            wrapMode: Text.Wrap
        }

        GridLayout {
            Layout.fillWidth: true
            columns: width > 700 ? 2 : 1
            columnSpacing: 14
            rowSpacing: 14

            Repeater {
                model: [
                    {
                        title: "Aplicativos Seven",
                        body: "Seven Files, Settings, Terminal e System Monitor já fazem parte da imagem base.",
                        action: "Abrir Arquivos",
                        command: "seven-files"
                    },
                    {
                        title: "Aplicativos Windows",
                        body: "Instale .exe e .msi com Wine 11 e isolamento por aplicativo. Abra o instalador pelo Seven Files.",
                        action: "Procurar instalador",
                        command: "seven-files"
                    },
                    {
                        title: "Atualizações do sistema",
                        body: "As atualizações serão aplicadas como imagens assinadas e verificadas. O backend remoto ainda não está publicado.",
                        action: "",
                        command: ""
                    },
                    {
                        title: "Status do Runtime",
                        body: SevenApp.windowsSummary,
                        action: "Atualizar status",
                        command: "__refresh__"
                    }
                ]

                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 180
                    radius: 16
                    color: "#1c1626"
                    border.width: 1
                    border.color: "#30243e"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 10

                        Label {
                            text: modelData.title
                            color: "#ffffff"
                            font.pixelSize: 17
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: modelData.body
                            color: "#a79daf"
                            wrapMode: Text.Wrap
                        }

                        Button {
                            visible: modelData.action !== ""
                            text: modelData.action
                            onClicked: {
                                if (modelData.command === "__refresh__") {
                                    SevenApp.refresh()
                                } else if (modelData.command !== "") {
                                    SevenApp.launch(modelData.command)
                                }
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
