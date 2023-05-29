import QtQuick 2.15
import QtQuick.Controls 1.4

Item {
  id: root
  width: 200
  height: 60
  property alias rHeader: rHeader
  property alias txtHeader: txtHeader
  property alias calDate: calDate

  implicitHeight: 110
  implicitWidth: 600

  property var dtValue;
  property alias iCalHolder: iCalHolder
  property alias bDatePicker: bDatePicker

  signal manualDateChange()


  Rectangle {
    id: rHeader
    height: 18
    color: "#00ffffff"
    border.width: 0
    border.color: "#343d47"
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.left: parent.left
    anchors.leftMargin: 0
    anchors.bottom: parent.top
    anchors.bottomMargin: 0

    Text {
      id: txtHeader
      color: "#000000"
      text: qsTr("Date:")
      anchors.leftMargin: 2
      verticalAlignment: Text.AlignVCenter
      anchors.bottomMargin: 2
      anchors.topMargin: 2
      anchors.rightMargin: 2
      anchors.fill: parent
      font.pixelSize: 14
    }
  }

  CDButton {
    id: bDatePicker
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    cornerRad: 5
    txtText.text: calDate.selectedDate.toLocaleDateString(Qt.locale(), "dd.MM.yyyy.");
    txtText.font.pixelSize: 24
    mouseArea.onClicked: {
      iCalHolder.visible = !iCalHolder.visible
    }

    Item {
      id: iCalHolder
      x: -32
      y: 42
      z: 5
      width: 450
      height: 400
      anchors.top: parent.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.topMargin: 0
      visible: false

      Calendar {
        id: calDate
        objectName: "calDate"
        anchors.fill: parent
        focus: true

        onClicked: {
          bDatePicker.mouseArea.clicked(null);
          manualDateChange();
        }

        onFocusChanged: {
          if(!focus)
            iCalHolder.visible = false
        }
      }
    }
  }

  function getDate() {
    return calDate.selectedDate.toLocaleDateString(Qt.locale(), "yyyy-MM-dd");
  }
}

