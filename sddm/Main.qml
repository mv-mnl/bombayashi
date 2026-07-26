import QtQuick
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
import SddmComponents 2.0

Rectangle {
    readonly property real s: Screen.height / 768
    id: root; width: Screen.width; height: Screen.height; color: "#000000"
    property int sessionIndex: (sessionModel && sessionModel.lastIndex >= 0) ? sessionModel.lastIndex : 0
    property int userIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property real ui: 0
    readonly property color latte: "#ffffff"
    readonly property color steel: "#777777"
    readonly property color textDim: "#555555"

    FolderListModel { id: fontFolder; folder: Qt.resolvedUrl("font"); nameFilters: ["*.ttf", "*.otf"] }
    FontLoader { id: pf; source: fontFolder.count > 0 ? "font/" + fontFolder.get(0, "fileName") : "" }
    ListView { id: sessionHelper; model: sessionModel; currentIndex: root.sessionIndex; opacity: 0; width: 100; height: 100; z: -100; delegate: Item { property string sName: model.name || "" } }
    ListView { id: userHelper; model: userModel; currentIndex: root.userIndex; opacity: 0; width: 100; height: 100; z: -100; delegate: Item { property string uName: model.realName || model.name || ""; property string uLogin: model.name || "" } }

    Timer { interval: 300; running: true; onTriggered: pwdInput.forceActiveFocus() }

    Component.onCompleted: fadeAnim.start()
    NumberAnimation { id: fadeAnim; target: root; property: "ui"; from: 0; to: 1; duration: 800; easing.type: Easing.OutCubic }

    // BackgroundVideo deshabilitado para fondo negro puro

    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 160 * s; gradient: Gradient { GradientStop { position: 0.0; color: "#d8000000" } GradientStop { position: 1.0; color: "transparent" } } }
    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 320 * s; gradient: Gradient { GradientStop { position: 0.0; color: "transparent" } GradientStop { position: 1.0; color: "#e8000000" } } }

    // ── Abajo Izquierda: Reloj + Session Picker ──────────────────────────
    Column {
        anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 60 * s
        spacing: 24 * s; opacity: root.ui

        Column {
            spacing: 4 * s
            Row {
                spacing: 8 * s
                Rectangle { width: 4 * s; height: 4 * s; color: root.latte; anchors.verticalCenter: parent.verticalCenter }
                Text { text: Qt.formatDate(new Date(), "dddd, MMMM d").toUpperCase(); color: root.steel; font.family: pf.name; font.pixelSize: 12 * s; font.letterSpacing: 1.5 * s; anchors.verticalCenter: parent.verticalCenter }
            }
            Text {
                id: clockText; text: Qt.formatTime(new Date(), "HH:mm"); color: "white"; font.family: pf.name; font.pixelSize: 76 * s
                Timer { interval: 1000; running: true; repeat: true; onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm") }
            }
        }

        Row {
            spacing: 10 * s

            Item {
                width: 28 * s; height: 28 * s
                Rectangle { anchors.fill: parent; color: "transparent"; border.color: root.steel; border.width: 1 * s; opacity: prevSession.containsMouse ? 0.9 : 0.35; Behavior on opacity { NumberAnimation { duration: 150 } } }
                Text { anchors.centerIn: parent; text: "◀"; color: "white"; font.pixelSize: 10 * s }
                MouseArea {
                    id: prevSession; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: { if (sessionModel && sessionModel.rowCount() > 0) root.sessionIndex = (root.sessionIndex - 1 + sessionModel.rowCount()) % sessionModel.rowCount() }
                }
            }

            Item {
                width: 180 * s; height: 28 * s
                Rectangle { anchors.fill: parent; color: "transparent"; border.color: root.steel; border.width: 1 * s; opacity: 0.4 }
                Text {
                    anchors.centerIn: parent
                    text: (sessionHelper.currentItem && sessionHelper.currentItem.sName ? sessionHelper.currentItem.sName : "Session").toUpperCase()
                    color: "white"; font.family: pf.name; font.pixelSize: 10 * s; font.letterSpacing: 1 * s
                }
            }

            Item {
                width: 28 * s; height: 28 * s
                Rectangle { anchors.fill: parent; color: "transparent"; border.color: root.steel; border.width: 1 * s; opacity: nextSession.containsMouse ? 0.9 : 0.35; Behavior on opacity { NumberAnimation { duration: 150 } } }
                Text { anchors.centerIn: parent; text: "▶"; color: "white"; font.pixelSize: 10 * s }
                MouseArea {
                    id: nextSession; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: { if (sessionModel && sessionModel.rowCount() > 0) root.sessionIndex = (root.sessionIndex + 1) % sessionModel.rowCount() }
                }
            }
        }
    }

    // ── Abajo Derecha: Usuario + Contraseña + Login ───────────────────────
    Item {
        anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 60 * s
        opacity: root.ui; width: 320 * s; height: loginCol.implicitHeight

        Column {
            id: loginCol; width: parent.width; spacing: 18 * s

            Item {
                width: parent.width; height: 36 * s
                Rectangle { anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; width: parent.width; height: 1 * s; color: root.steel; opacity: 0.3 }
                Row {
                    anchors.fill: parent
                    Item {
                        width: 28 * s; height: parent.height
                        Text { anchors.centerIn: parent; text: "◀"; color: "white"; font.pixelSize: 10 * s; opacity: prevUser.containsMouse ? 0.9 : 0.35; Behavior on opacity { NumberAnimation { duration: 150 } } }
                        MouseArea {
                            id: prevUser; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: { if (userModel && userModel.rowCount() > 0) root.userIndex = (root.userIndex - 1 + userModel.rowCount()) % userModel.rowCount() }
                        }
                    }
                    Item {
                        width: parent.width - 56 * s; height: parent.height
                        Text {
                            anchors.centerIn: parent
                            text: (userHelper.currentItem && userHelper.currentItem.uName) ? userHelper.currentItem.uName : "usuario"
                            color: "white"; font.family: pf.name; font.pixelSize: 18 * s; font.letterSpacing: 1.5 * s
                            elide: Text.ElideRight; width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    Item {
                        width: 28 * s; height: parent.height
                        Text { anchors.centerIn: parent; text: "▶"; color: "white"; font.pixelSize: 10 * s; opacity: nextUser.containsMouse ? 0.9 : 0.35; Behavior on opacity { NumberAnimation { duration: 150 } } }
                        MouseArea {
                            id: nextUser; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: { if (userModel && userModel.rowCount() > 0) root.userIndex = (root.userIndex + 1) % userModel.rowCount() }
                        }
                    }
                }
            }

            Item {
                width: parent.width; height: 36 * s
                Rectangle { anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; width: parent.width; height: 1 * s; color: root.steel; opacity: pwdInput.activeFocus ? 1.0 : 0.3 }
                Rectangle { anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; width: pwdInput.activeFocus ? parent.width : 0; height: 2 * s; color: root.latte; Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } } }
                TextInput {
                    id: pwdInput; anchors.fill: parent; color: root.latte; font.family: pf.name; font.pixelSize: 18 * s; font.letterSpacing: 1.5 * s
                    echoMode: TextInput.Password; passwordCharacter: "─"; clip: true; horizontalAlignment: TextInput.AlignHCenter; verticalAlignment: TextInput.AlignVCenter
                    cursorVisible: false; cursorDelegate: Item { width: 0; height: 0 }
                    selectionColor: root.latte
                    property bool wasClicked: false
                    onActiveFocusChanged: if (!activeFocus && text.length === 0) wasClicked = false
                    Keys.onReturnPressed: doLogin()
                    Keys.onEnterPressed: doLogin()
                }
                Text {
                    anchors.centerIn: parent; text: "contraseña..."; color: root.textDim; font.family: pf.name; font.pixelSize: 14 * s; font.letterSpacing: 1.5 * s
                    opacity: pwdInput.text.length === 0 ? 0.5 : 0
                    Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutSine } }
                }
                Rectangle {
                    id: customCursor; width: 2 * s; height: 20 * s; color: root.latte
                    anchors.verticalCenter: parent.verticalCenter
                    x: pwdInput.cursorRectangle.x
                    visible: pwdInput.focus && (pwdInput.text.length > 0 || pwdInput.wasClicked)
                    SequentialAnimation {
                        loops: Animation.Infinite; running: customCursor.visible
                        NumberAnimation { target: customCursor; property: "opacity"; from: 1; to: 0.05; duration: 450 }
                        NumberAnimation { target: customCursor; property: "opacity"; from: 0.05; to: 1; duration: 450 }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: { pwdInput.forceActiveFocus(); pwdInput.wasClicked = true }
                }
            }

            Item {
                anchors.horizontalCenter: parent.horizontalCenter; width: 140 * s; height: 36 * s
                Rectangle { anchors.fill: parent; color: loginBtn.containsMouse ? root.latte : "transparent"; border.color: root.latte; border.width: 1; Behavior on color { ColorAnimation { duration: 150 } } }
                Text { anchors.centerIn: parent; text: "LOGIN"; color: loginBtn.containsMouse ? "#000" : root.latte; font.family: pf.name; font.pixelSize: 12 * s; font.letterSpacing: 1.5 * s; Behavior on color { ColorAnimation { duration: 150 } } }
                MouseArea { id: loginBtn; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: doLogin() }
            }

            Text { id: err; text: ""; color: "#ffffff"; anchors.horizontalCenter: parent.horizontalCenter; font.family: pf.name; font.pixelSize: 10 * s }
        }
    }

    // ── Arriba Derecha: Restart + Shutdown ────────────────────────────────
    Row {
        anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 40 * s
        spacing: 20 * s; opacity: root.ui
        Repeater {
            model: [{l: "RESTART", a: 0}, {l: "SHUT DOWN", a: 1}]
            delegate: Item {
                width: pmt.implicitWidth + 24 * s; height: 28 * s
                Rectangle { anchors.fill: parent; color: "transparent"; border.color: root.steel; border.width: 1 * s; opacity: pm.containsMouse ? 1.0 : 0.3; Behavior on opacity { NumberAnimation { duration: 150 } } Rectangle { anchors.fill: parent; anchors.margins: 1 * s; color: root.steel; radius: 2 * s; opacity: pm.containsMouse ? 0.3 : 0; Behavior on opacity { NumberAnimation { duration: 150 } } } }
                Text { id: pmt; anchors.centerIn: parent; text: modelData.l; color: "white"; font.family: pf.name; font.pixelSize: 10 * s; font.letterSpacing: 1 * s }
                MouseArea { id: pm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { if (modelData.a === 0) sddm.reboot(); else sddm.powerOff() } }
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() { err.text = "DECLINED"; pwdInput.text = ""; pwdInput.forceActiveFocus() }
    }

    function doLogin() {
        var u = (userHelper.currentItem && userHelper.currentItem.uLogin) ? userHelper.currentItem.uLogin : userModel.lastUser
        sddm.login(u, pwdInput.text, root.sessionIndex)
    }
}
