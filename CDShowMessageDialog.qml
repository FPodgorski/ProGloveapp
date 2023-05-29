import QtQuick 2.0
import QtQuick.Controls 2.12

Dialog {
  id: root
  width: 550
  height: 350
  implicitHeight: 200
  implicitWidth: 550

  x: (parent.width - width) / 2
  y: (parent.height - height) / 2
  title: ""

  onAccepted: {
    acceptAction();
    root.close()
  }

  property alias txtMsg: txtMsg
  property var acceptAction: function () {console.log("YNDialog accepted")}

  property alias element: element

  focus: true
  Keys.onEnterPressed: {
    acceptAction();
  }

  property color highlightColor: "dodgerblue"


  background: Rectangle {
    anchors.fill: parent
    color: "transparent"
  }

  contentItem: Rectangle {
    id: rBg
    color: "#222222"
    anchors.fill: parent
    border.width: 5
    border.color: root.highlightColor
    radius: 9

    Item {
      id: element
      anchors.fill: parent

      Text {
        id: txtMsg
        objectName: "txtMsg"
        text: "Yes or no?"
        font.family: "Segoe UI"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.fill: parent
        anchors.margins: 15
        color: "white"
        font.pixelSize: 54


        MouseArea {
          anchors.fill: parent
          onClicked: {
            root.close();
          }
        }
      }
    }
  }
}
