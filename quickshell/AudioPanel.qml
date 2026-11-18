import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import QtQuick

// Panel de sonido: volumen general, salida y mezclador por aplicación
Item {
    id: root

    readonly property var nodes: Pipewire.nodes.values
    readonly property var sinks: nodes.filter(n => n.isSink && !n.isStream && n.audio)
    readonly property var streams: nodes.filter(n => n.isStream && !n.isSink && n.audio
                                                   && !/easyeffects|cava/i.test((n.name ?? "") + " " + (n.properties?.["application.name"] ?? "")))

    PwObjectTracker { objects: root.sinks.concat(root.streams) }

    function setMaster(v) {
        Stats.volume = v;
        Quickshell.execDetached(["sh", "-c", `~/.config/hypr/scripts/audio.sh set ${v}`]);
    }

    Component.onCompleted: Stats.refreshLevels()

    Flickable {
        anchors.fill: parent
        contentHeight: col.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: col
            width: parent.width
            spacing: 10

            PanelHeader {
                icon: Osd.icon
                title: "Sonido"
                active: !Stats.muted
                subtitle: Pipewire.defaultAudioSink?.description ?? ""

                Rectangle {
                    width: 34; height: 34; radius: 17
                    color: Stats.muted ? Theme.accent : ma.containsMouse ? Theme.track : Theme.bgAlt
                    Txt { anchors.centerIn: parent; text: "󰝟"; font.pixelSize: 15; color: Stats.muted ? Theme.base : Theme.fg }
                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Stats.muted = !Stats.muted;
                            Quickshell.execDetached(["sh", "-c", "~/.config/hypr/scripts/audio.sh mute-toggle"]);
                        }
                    }
                }
            }

            Slider {
                label: "Volumen general"
                suffix: "%"
                value: Stats.volume
                onMoved: v => root.setMaster(v)
            }

            Txt { text: "SALIDA"; color: Theme.fgDim; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1.5; topPadding: 4 }
            Repeater {
                model: root.sinks
                PanelRow {
                    required property var modelData
                    required property int index
                    readonly property bool isDefault: Pipewire.defaultAudioSink === modelData
                    icon: {
                        const d = (modelData.description ?? "").toLowerCase();
                        return d.includes("hdmi") ? "󰍹" : d.includes("easy") ? "󰺢" : d.includes("usb") ? "󰋋" : "󰓃";
                    }
                    title: modelData.nickname || modelData.description || modelData.name
                    subtitle: modelData.description !== title ? (modelData.description ?? "") : ""
                    trailing: isDefault ? "󰄬" : ""
                    active: isDefault
                    onClicked: Pipewire.preferredDefaultAudioSink = modelData
                }
            }

            Txt { text: "APLICACIONES"; color: Theme.fgDim; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1.5; topPadding: 4 }
            Txt {
                visible: root.streams.length === 0
                text: "Ninguna app está reproduciendo audio"
                color: Theme.fgDim
                font.pixelSize: 11
            }
            Repeater {
                model: root.streams
                Rectangle {
                    id: app
                    required property var modelData
                    readonly property var props: modelData.properties ?? {}
                    readonly property string appName: props["application.name"] || modelData.description || modelData.name
                    readonly property string iconName: props["application.icon-name"] || props["application.process.binary"] || ""
                    width: col.width
                    height: 60
                    radius: 15
                    color: Theme.bgAlt

                    PwNodePeakMonitor { id: peak; node: app.modelData; enabled: true }

                    IconImage {
                        id: appIcon
                        x: 14
                        anchors.verticalCenter: parent.verticalCenter
                        implicitSize: 30
                        source: Quickshell.iconPath(app.iconName.toLowerCase(), true)
                        visible: source != ""
                    }
                    Txt {
                        x: 14
                        anchors.verticalCenter: parent.verticalCenter
                        width: 30
                        horizontalAlignment: Text.AlignHCenter
                        visible: !appIcon.visible
                        text: "󰎈"
                        font.pixelSize: 20
                    }
                    Column {
                        x: 58
                        width: parent.width - 58 - 60
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6
                        Txt {
                            width: parent.width
                            text: app.appName + (app.props["media.name"] ? `  <font color="${Theme.fgDim}">${app.props["media.name"]}</font>` : "")
                            textFormat: Text.StyledText
                            font.pixelSize: 12
                        }
                        Item {
                            width: parent.width
                            height: 8
                            LevelBar {
                                anchors.fill: parent
                                interactive: true
                                value: (app.modelData.audio?.volume ?? 0)
                                fill: app.modelData.audio?.muted ? Theme.fgDim : Theme.accent
                                onMoved: v => { if (app.modelData.audio) app.modelData.audio.volume = v }
                            }
                        }
                        // Medidor de nivel en vivo
                        Rectangle {
                            width: parent.width * Math.min(1, peak.peak)
                            height: 2
                            radius: 1
                            color: Theme.alpha(Theme.accent, 0.6)
                            Behavior on width { NumberAnimation { duration: 60 } }
                        }
                    }
                    Txt {
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: app.modelData.audio?.muted ? "󰝟" : Math.round((app.modelData.audio?.volume ?? 0) * 100) + "%"
                        color: Theme.fgDim
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            cursorShape: Qt.PointingHandCursor
                            onClicked: app.modelData.audio.muted = !app.modelData.audio.muted
                        }
                    }
                }
            }
        }
    }
}
