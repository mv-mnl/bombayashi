import QtQuick

// Barra de progreso / slider. Si "interactive", se puede arrastrar.
Item {
    id: bar

    property real value: 0          // 0..1
    property bool interactive: false
    property color fill: Theme.accent
    signal moved(real v)

    implicitHeight: 6

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.track
    }

    Rectangle {
        height: parent.height
        radius: height / 2
        width: Math.max(height, parent.width * Math.max(0, Math.min(1, bar.value)))
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: Theme.fgDim }
            GradientStop { position: 1; color: bar.fill }
        }
        Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -8
        enabled: bar.interactive
        cursorShape: Qt.PointingHandCursor
        function emitAt(x) { bar.moved(Math.max(0, Math.min(1, (x - 8) / bar.width))) }
        onPressed: m => emitAt(m.x)
        onPositionChanged: m => { if (pressed) emitAt(m.x) }
    }
}
