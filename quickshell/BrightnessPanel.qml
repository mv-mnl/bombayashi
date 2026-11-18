import Quickshell
import QtQuick

// Panel de brillo (brightnessctl, solo pantallas con backlight)
Item {
    id: root

    function set(v) {
        Stats.brightness = v;
        Quickshell.execDetached(["brightnessctl", "-c", "backlight", "s", `${Math.max(1, v)}%`]);
    }

    Component.onCompleted: Stats.refreshLevels()

    Column {
        anchors.fill: parent
        spacing: 14

        PanelHeader {
            icon: "󰃠"
            title: "Brillo"
            subtitle: Stats.brightness >= 0 ? `${Stats.brightness}%` : "Esta pantalla no tiene control de brillo"
            active: Stats.brightness >= 0
        }

        LevelBar {
            visible: Stats.brightness >= 0
            width: parent.width
            height: 12
            interactive: true
            value: Stats.brightness / 100
            onMoved: v => root.set(Math.round(v * 100))
        }

        Row {
            visible: Stats.brightness >= 0
            spacing: 8
            Repeater {
                model: [10, 25, 50, 75, 100]
                Button {
                    required property int modelData
                    text: modelData + "%"
                    color: Math.abs(Stats.brightness - modelData) < 3 ? Theme.track : Theme.bgAlt
                    onClicked: root.set(modelData)
                }
            }
        }
    }
}
