import Quickshell
import Quickshell.Hyprland
import QtQuick

// Indicador de workspaces: el activo se estira en una píldora animada
Row {
    id: ws
    spacing: Theme.s(6)

    readonly property int activeId: Hyprland.focusedWorkspace?.id ?? 1
    readonly property var occupied: {
        const s = {};
        for (const w of Hyprland.workspaces.values)
            if (w.id > 0 && (w.toplevels?.values?.length ?? 1) > 0) s[w.id] = true;
        return s;
    }
    readonly property int count: {
        let max = 5;
        for (const w of Hyprland.workspaces.values) if (w.id > max) max = w.id;
        return Math.min(max, 10);
    }

    function go(id) { Hyprland.dispatch(`hl.dsp.focus({ workspace = ${id} })`) }

    Repeater {
        model: ws.count

        Item {
            id: cell
            required property int index
            readonly property int wsId: index + 1
            readonly property bool active: wsId === ws.activeId
            readonly property bool used: ws.occupied[wsId] === true

            width: dot.width
            height: Theme.barHeight - 10
            anchors.verticalCenter: parent?.verticalCenter

            Rectangle {
                id: dot
                anchors.verticalCenter: parent.verticalCenter
                width: cell.active ? Theme.s(30) : hover.containsMouse ? Theme.s(14) : Theme.s(9)
                height: Theme.s(9)
                radius: height / 2
                color: cell.active ? Theme.accent : cell.used ? Theme.fgDim : Theme.track
                Behavior on width { SpringAnimation { spring: 5; damping: 0.35; epsilon: 0.25 } }
                Behavior on color { ColorAnimation { duration: 250 } }
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                anchors.margins: -3
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ws.go(cell.wsId)
                onWheel: w => ws.go(w.angleDelta.y > 0 ? Math.max(1, ws.activeId - 1) : ws.activeId + 1)
            }
        }
    }
}
