import QtQuick 2.0

Item {
    id: root
    width: 400
    height: 110
    property alias txtValue: txtValue
    property alias txtHeader: txtHeader
    property alias rHeader: rHeader
    property alias rValue: rValue

    property bool bBackground: false



    property var headerRad: 0
    implicitHeight: 110
    implicitWidth: 400

    Rectangle {
        id: rHeader
        height: 40
        color: "#66000000"
        border.width: 0
        border.color: "#343d47"
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        radius: headerRad

        Text {
            id: txtHeader
            color: "#ffffff"
            text: ""
            anchors.leftMargin: 15
            verticalAlignment: Text.AlignVCenter
            anchors.rightMargin: 15
            anchors.fill: parent
            font.pixelSize: 20
        }
    }

    Rectangle {
        id: rValue
        color: "#a18cd1"
        gradient: Gradient {
            GradientStop {
                position: 0
                color: "#00cfd9df"
            }

            GradientStop {
                position: 1
                color: "#00e2ebf0"
            }
        }
        border.width: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: rHeader.bottom
        anchors.topMargin: 0
        clip: true

        Text {
            id: txtValue
            color: "#ffffff"
            text: ""
//            font.bold: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.fill: parent
            font.pixelSize: 32
            fontSizeMode: Text.Fit
            anchors.leftMargin: 25
            anchors.rightMargin: 25
            wrapMode: Text.WordWrap
        }
    }
}
