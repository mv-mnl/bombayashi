import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick

// Centro de notificaciones: historial, acciones, descartar y No molestar
Item {
    id: root

    property int expandedId: -1

    Column {
        anchors.fill: parent
        spacing: 12

        PanelHeader {
            icon: Notifs.dnd ? "󰂛" : Notifs.count ? "󰂚" : "󰂜"
            title: "Notificaciones"
            active: !Notifs.dnd
            subtitle: (Notifs.dnd ? "No molestar activado" : Notifs.count ? `${Notifs.count} sin leer` : "Estás al día") + (Notifs.count ? "  ·  clic expande, clic medio descarta" : "")

            Button {
                visible: Notifs.count > 0
                text: "󰆴  Limpiar"
                onClicked: Notifs.clearAll()
            }
        }

        // No molestar
        Rectangle {
            width: parent.width
            height: 54
            radius: 16
            color: Notifs.dnd ? Theme.alpha(Theme.accent, 0.14) : Theme.bgAlt
            Behavior on color { ColorAnimation { duration: 200 } }
            Toggle {
                x: 16
                width: parent.width - 32
                anchors.verticalCenter: parent.verticalCenter
                label: "󰂛  No molestar"
                hint: "Sin avisos; se guardan aquí. Las urgentes sí salen"
                checked: Notifs.dnd
                onToggled: Notifs.toggleDnd()
            }
        }

        // Lista
        Flickable {
            width: parent.width
            height: parent.height - y
            contentHeight: list.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: list
                width: parent.width
                spacing: 8

                Repeater {
                    model: Notifs.newest

                    Rectangle {
                        id: card
                        required property var modelData
                        required property int index
                        readonly property var n: modelData
                        readonly property bool critical: n.urgency === NotificationUrgency.Critical
                        readonly property bool open: root.expandedId === n.id

                        width: list.width
                        height: content.implicitHeight + 24
                        radius: 18
                        color: hover.containsMouse ? Theme.track : Theme.bgAlt
                        border.width: critical ? 1 : 0
                        border.color: Theme.urgent
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                        // Entrada escalonada
                        opacity: 0
                        transform: Translate { id: slide; x: 24 }
                        Component.onCompleted: appear.start()
                        SequentialAnimation {
                            id: appear
                            PauseAnimation { duration: Math.min(card.index, 10) * 35 }
                            ParallelAnimation {
                                NumberAnimation { target: card; property: "opacity"; to: 1; duration: 260 }
                                NumberAnimation { target: slide; property: "x"; to: 0; duration: 380; easing.type: Easing.OutBack }
                            }
                        }

                        MouseArea {
                            id: hover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            // Clic: expandir/contraer el texto. Clic medio: descartar
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                            onClicked: e => {
                                if (e.button === Qt.MiddleButton) card.n.dismiss();
                                else root.expandedId = card.open ? -1 : card.n.id;
                            }
                        }

                        Row {
                            id: content
                            x: 12; y: 12
                            width: parent.width - 24
                            spacing: 12

                            ClippingRectangle {
                                width: 40; height: 40; radius: 13
                                color: Theme.base
                                IconImage {
                                    id: icon
                                    anchors.fill: parent
                                    anchors.margins: (card.n.image || "").startsWith("image://icon/") || !card.n.image ? 7 : 0
                                    source: Notifs.iconFor(card.n)
                                }
                                Txt {
                                    anchors.centerIn: parent
                                    visible: icon.source == ""
                                    text: "󰂚"
                                    font.pixelSize: 18
                                    color: Theme.fgDim
                                }
                            }

                            Column {
                                width: parent.width - 40 - 12 - 30
                                spacing: 3
                                Row {
                                    width: parent.width
                                    spacing: 6
                                    Txt { text: card.n.appName || "Notificación"; color: Theme.fgDim; font.pixelSize: 10; font.bold: true }
                                    Txt { text: "·  " + Notifs.ago(card.n); color: Theme.fgDim; font.pixelSize: 10 }
                                }
                                Txt {
                                    width: parent.width
                                    text: card.n.summary
                                    font.bold: true
                                    font.pixelSize: 13
                                    wrapMode: card.open ? Text.Wrap : Text.NoWrap
                                }
                                Txt {
                                    width: parent.width
                                    visible: text.length > 0
                                    text: card.n.body
                                    color: Theme.fgDim
                                    font.pixelSize: 11
                                    wrapMode: Text.Wrap
                                    maximumLineCount: card.open ? 12 : 2
                                }
                                // Acciones de la notificación (Responder, Abrir, ...)
                                Flow {
                                    width: parent.width
                                    spacing: 6
                                    topPadding: 4
                                    visible: card.n.actions.length > 0
                                    Repeater {
                                        model: card.n.actions
                                        Button {
                                            required property var modelData
                                            height: 30
                                            text: modelData.text || "Abrir"
                                            onClicked: modelData.invoke()
                                        }
                                    }
                                }
                            }

                            // Descartar
                            Rectangle {
                                width: 26; height: 26; radius: 13
                                color: xa.containsMouse ? Theme.urgent : "transparent"
                                opacity: hover.containsMouse || xa.containsMouse ? 1 : 0.35
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                Txt { anchors.centerIn: parent; text: "󰅖"; font.pixelSize: 13; color: xa.containsMouse ? Theme.base : Theme.fg }
                                MouseArea {
                                    id: xa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: card.n.dismiss()
                                }
                            }
                        }
                    }
                }

                // Vacío
                Column {
                    visible: Notifs.count === 0
                    width: list.width
                    topPadding: 50
                    spacing: 10
                    Txt {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Notifs.dnd ? "󰂛" : "󰂜"
                        font.pixelSize: 46
                        color: Theme.track
                    }
                    Txt {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No hay notificaciones"
                        color: Theme.fgDim
                    }
                }
            }
        }
    }

}
