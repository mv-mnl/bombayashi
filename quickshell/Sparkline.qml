import QtQuick

// Gráfica de línea con relleno degradado (historial de CPU/RAM)
Canvas {
    id: sp
    property var values: []
    property color color: Theme.accent
    property real maxValue: 100
    onValuesChanged: requestPaint()
    onColorChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        const n = values.length;
        if (n < 2) return;
        const step = width / 59;
        const x0 = width - (n - 1) * step;
        const y = v => height - 2 - (Math.min(v, maxValue) / maxValue) * (height - 4);
        ctx.beginPath();
        ctx.moveTo(x0, y(values[0]));
        for (let i = 1; i < n; i++) ctx.lineTo(x0 + i * step, y(values[i]));
        ctx.lineWidth = 2;
        ctx.strokeStyle = sp.color;
        ctx.lineJoin = "round";
        ctx.stroke();
        ctx.lineTo(x0 + (n - 1) * step, height);
        ctx.lineTo(x0, height);
        ctx.closePath();
        const grad = ctx.createLinearGradient(0, 0, 0, height);
        grad.addColorStop(0, Qt.rgba(sp.color.r, sp.color.g, sp.color.b, 0.35));
        grad.addColorStop(1, Qt.rgba(sp.color.r, sp.color.g, sp.color.b, 0));
        ctx.fillStyle = grad;
        ctx.fill();
    }
}
