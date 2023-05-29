import QtQuick 2.0
import QtQuick.Controls 2.12

Dialog {
  id: yesNoDialog
  width: 550
  height: 350
  implicitHeight: 200
  implicitWidth: 550

  modal: true
  closePolicy: "NoAutoClose"

  property color deleteColor: "firebrick"
  property color addColor: "#4acc09"

  x: (parent.width - width) / 2
  y: (parent.height - height) / 2
  title: ""

  onAccepted: {
    acceptAction();
    yesNoDialog.close()
  }


  function setText(text) {
    txtMsg.text = text;
  }

  property alias txtMsg: txtMsg
  property var acceptAction: function () {console.log("YNDialog accepted")}

  property alias element: element

  onOpened: {
    iFocus.forceActiveFocus();
  }

  Item {
    id: iFocus
    focus: true
    Keys.onPressed: {
      print("yesNoDialog keys.onPressed with " + event.key)
      if(event.key == Qt.Key_Return) {
        yesNoDialog.accept();
      }
    }


    states: [
      State {
        when: cb.platform == "mobile90"
        PropertyChanges {
          target: item1
          height: 65
        }
        PropertyChanges {
          target: bCancel
          width: 125
        }
        PropertyChanges {
          target: bConfirm
          width: 125
        }
      }
    ]
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
    border.color: yesNoDialog.highlightColor
    radius: 9

    Item {
      id: element
      anchors.right: parent.right
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.bottom: item1.top

      Text {
        id: txtMsg
        objectName: "txtMsg"
        text: "Yes or no?"
        font.family: "Segoe UI"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        fontSizeMode: Text.Fit
        clip: true
        anchors.fill: parent
        anchors.margins: 15
        color: "white"
        font.pixelSize: 54
      }
    }

    Item {
      id: item1
      height: 75
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.margins: 15


      CDButton {
        id: bCancel
        width: 150
//        text: "No"
        text: "Ne"

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        idleColConst: deleteColor
        anchors.topMargin: 0
        anchors.leftMargin: 0
        txtText.font.pixelSize: 28
        onClick: {
          yesNoDialog.reject()
        }
      }

      CDButton {
        id: bConfirm
        width: 150
//        text: "Yes"
        text: "Da"


        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        idleColConst: addColor
        anchors.topMargin: 0
        txtText.font.pixelSize: 28
        onClick: {
          yesNoDialog.accept()
        }
      }
    }
  }
}
