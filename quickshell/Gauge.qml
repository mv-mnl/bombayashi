import QtQuick

// Medidor circular animado (arco) con valor y etiqueta al centro
Item {
    id: g
    property real value: 0          // 0..100
    property string label
    property string icon
    property real shown: value
    Behavior on shown { NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }
    onShownChanged: canvas.requestPaint()

    implicitWidth: 104
    implicitHeight: 128

    Canvas {
        id: canvas
        width: 104; height: 104
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const c = width / 2, r = c - 8, start = Math.PI * 0.75, span = Math.PI * 1.5;
            ctx.lineCap = "round";
            ctx.lineWidth = 9;
            ctx.strokeStyle = Theme.track;
            ctx.beginPath(); ctx.arc(c, c, r, start, start + span); ctx.stroke();
            const v = Math.max(0, Math.min(100, g.shown)) / 100;
            if (v > 0) {
                const grad = ctx.createLinearGradient(0, height, width, 0);
                grad.addColorStop(0, Theme.fgDim);
                grad.addColorStop(1, g.shown >= 90 ? Theme.urgent : Theme.accent);
                ctx.strokeStyle = grad;
                ctx.beginPath(); ctx.arc(c, c, r, start, start + span * v); ctx.stroke();
            }
        }
        Connections {
            target: Theme
            function onAccentChanged() { canvas.requestPaint() }
            function onTrackChanged() { canvas.requestPaint() }
        }

        Column {
            anchors.centerIn: parent
            Txt { anchors.horizontalCenter: parent.horizontalCenter; text: g.icon; color: Theme.fgDim; font.pixelSize: 14 }
            Txt { anchors.horizontalCenter: parent.horizontalCenter; text: Math.round(g.shown) + "%"; font.pixelSize: 19; font.bold: true }
        }
    }
    Txt {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: g.label
        color: Theme.fgDim
        font.pixelSize: 11
    }
}
