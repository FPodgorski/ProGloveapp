import QtQuick 2.0

Item {
  id: root

  implicitWidth: 175
  implicitHeight: 75

  property string label
  property string value

  property alias txtLabel: txtLabel
  property alias txtValue: txtValue

  Item {
    id: item1
    height: 20
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.leftMargin: 0
    anchors.topMargin: 0

    Rectangle {
      id: rectangle
      color: "#44000000"
      anchors.fill: parent

      Text {
        id: txtLabel
        text: root.label
        anchors.fill: parent
        font.pixelSize: 12
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        anchors.leftMargin: 15
        color: "#aaaaaa"
      }
    }
  }

  Item {
    id: item3
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: item1.bottom
    anchors.bottom: parent.bottom
    anchors.leftMargin: 0
    clip: true

    Text {
      id: txtValue
      text: root.value
      anchors.fill: parent
      font.pixelSize: 16
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      fontSizeMode: Text.Fit
      anchors.leftMargin: 5
      anchors.rightMargin: 5
      wrapMode:  Text.WordWrap
      color: "white"
    }
  }
}
