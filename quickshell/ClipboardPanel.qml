import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick

// Historial del portapapeles (cliphist) con búsqueda y miniaturas de imágenes.
// Escribe para filtrar · ↑/↓ para moverte · Enter copia · clic derecho borra
Item {
    id: root

    property var items: []
    property string thumbDir: ""
    property int selected: 0
    readonly property var filtered: {
        const q = search.text.toLowerCase();
        return q ? items.filter(i => i.text.toLowerCase().includes(q)) : items;
    }
    onFilteredChanged: selected = 0

    function load() { listProc.running = true }

    function copy(item) {
        Quickshell.execDetached(["sh", "-c", `cliphist decode ${item.id} | wl-copy`]);
        Panels.close();
    }

    function remove(item) {
        Quickshell.execDetached(["sh", "-c", `cliphist list | grep -P '^${item.id}\\t' | cliphist delete`]);
        items = items.filter(i => i.id !== item.id);
    }

    Component.onCompleted: { load(); thumbs.running = true; }
    // La isla se enfoca a sí misma al abrir (para Esc); el buscador toma el foco
    // después, y lo reintenta hasta que la ventana reciba el teclado
    Timer {
        id: focusTimer
        running: true
        interval: 60
        repeat: true
        property int tries: 0
        onTriggered: {
            search.forceActiveFocus();
            if (search.activeFocus || ++tries > 15) stop();
        }
    }

    Process {
        id: listProc
        command: ["sh", "-c", "cliphist list | head -150"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.items = text.split("\n").filter(l => l.includes("\t")).map(l => {
                    const tab = l.indexOf("\t");
                    const id = l.slice(0, tab), t = l.slice(tab + 1);
                    const img = t.match(/^\[\[ binary data (.+?) (png|jpe?g|webp|bmp) (\d+x\d+) \]\]$/);
                    return { id, text: img ? `Imagen ${img[3]} · ${img[1]}` : t.trim(), image: !!img };
                });
            }
        }
    }

    Process {
        id: thumbs
        command: [Quickshell.shellPath("scripts/clip-thumbs.sh")]
        stdout: StdioCollector { onStreamFinished: root.thumbDir = text.trim() }
    }

    Column {
        anchors.fill: parent
        spacing: 12

        PanelHeader {
            icon: "󰅍"
            title: "Portapapeles"
            subtitle: `${root.items.length} elementos`
            Button {
                text: "󰆴  Borrar todo"
                onClicked: {
                    Quickshell.execDetached(["cliphist", "wipe"]);
                    root.items = [];
                }
            }
        }

        // Búsqueda
        Rectangle {
            width: parent.width
            height: 40
            radius: 20
            color: Theme.base
            border.color: search.activeFocus ? Theme.accent : Theme.track
            Behavior on border.color { ColorAnimation { duration: 200 } }
            Txt { x: 16; anchors.verticalCenter: parent.verticalCenter; text: "󰍉"; color: Theme.fgDim; font.pixelSize: 15 }
            TextInput {
                id: search
                anchors.fill: parent
                anchors.leftMargin: 42
                anchors.rightMargin: 16
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.fg
                selectionColor: Theme.accent
                font.family: Theme.font
                font.pixelSize: 13
                Keys.onDownPressed: root.selected = Math.min(root.filtered.length - 1, root.selected + 1)
                Keys.onUpPressed: root.selected = Math.max(0, root.selected - 1)
                Keys.onReturnPressed: if (root.filtered.length) root.copy(root.filtered[root.selected])
                Keys.onEscapePressed: Panels.close()
                Keys.onPressed: e => {
                    const n = e.key - Qt.Key_1;
                    if (search.text.length === 0 && n >= 0 && n < 9 && n < root.filtered.length) {
                        root.copy(root.filtered[n]);
                        e.accepted = true;
                    }
                }
                Txt {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Buscar en el historial…"
                    color: Theme.fgDim
                    visible: search.text.length === 0
                }
            }
        }

        ListView {
            id: listView
            width: parent.width
            height: parent.height - y
            clip: true
            spacing: 4
            model: root.filtered
            currentIndex: root.selected
            boundsBehavior: Flickable.StopAtBounds
            highlightMoveDuration: 150
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

            delegate: PanelRow {
                id: clipRow
                required property var modelData
                required property int index
                width: listView.width
                height: modelData.image && root.thumbDir ? 96 : 46
                icon: modelData.image ? "" : "󰅍"
                title: modelData.image ? "" : modelData.text.replace(/\s+/g, " ")
                trailing: index < 9 && !search.text ? "" + (index + 1) : ""
                active: index === root.selected
                onClicked: root.copy(modelData)
                onSecondary: root.remove(modelData)

                ClippingRectangle {
                    visible: clipRow.modelData.image && root.thumbDir !== ""
                    parent: clipRow
                    x: 12; y: 8
                    width: 140; height: 80
                    radius: 10
                    color: Theme.base
                    Image {
                        anchors.fill: parent
                        source: clipRow.modelData.image && root.thumbDir ? `file://${root.thumbDir}/${clipRow.modelData.id}.png` : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 280
                    }
                }
                Txt {
                    visible: clipRow.modelData.image
                    parent: clipRow
                    x: 166
                    anchors.verticalCenter: parent.verticalCenter
                    text: clipRow.modelData.text
                    color: Theme.fgDim
                    font.pixelSize: 11
                }
            }
        }
    }
}
