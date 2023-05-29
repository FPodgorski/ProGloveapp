import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

Dialog {
  id: root
  height: 500
  width: 500

  modal: true
  closePolicy: "NoAutoClose"

  x: (parent.width - width) / 2;
  y: (parent.height - height) / 2;

  property alias iContent: iContent;
  property alias rBg: rBackground;
  property alias txtHeader: txtHeader;
  property alias iContentHeader: iContentHeader

  property alias bAccept: bOK
  property alias bDiscard: bDiscard
  property alias iFooter: iDestControls

  property int footerHeight: 35;
  property int headerHeight: 35

  // Disco
  property color deleteColor: "firebrick"
  property color addColor: "#4acc09"
  property color highlightColor: "dodgerblue"

  onOpened: iFocus.forceActiveFocus()

  Item {
    id: iFocus
    focus: true
    Keys.onPressed: {
      print("CDGenericDialog keys.onPressed with " + event.key)
      if(event.key == Qt.Key_Return) {
        root.accept();
      }
    }

    states: [
      State {
        when: cb.platform == "mobile90"
        PropertyChanges {
          target: root; footerHeight: 65
        }
        PropertyChanges {
          target: bAccept; width: 125
        }
        PropertyChanges {
          target: bDiscard; width: 125
        }
      }
    ]
  }

  background: Rectangle {
    id: rBackground
    anchors.fill: parent
    radius: 5
    clip: true

    border.width: 3
    border.color: root.highlightColor
    color: "#222222"
  }

  contentItem: Item {
    id: container
    anchors.fill: parent
    anchors.margins: rBackground.border.width

    layer.enabled: true
    layer.effect: OpacityMask {
      maskSource: rContainerMask
    }


    Rectangle {
      id: iContentHeader
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right

      height: root.headerHeight
      clip: true

      color: "#111111"

      gradient: Gradient {
        GradientStop{
          position: 0
          color: "#111111"
        }

        GradientStop{
          position: 0.7
          color: "#171717"
        }

        GradientStop{
          position: 1
          color: "#111111"
        }
      }

      Text {
        id: txtHeader
        anchors.fill: parent
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        anchors.leftMargin: 15
        anchors.rightMargin: 5
        fontSizeMode: Text.Fit
        wrapMode: Text.WordWrap

        color: "white"
        verticalAlignment: Text.AlignVCenter        
//        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 32
        text: "Header"
      }
    }

    Item {
      id: iContent

      anchors.top: iContentHeader.bottom
      anchors.bottom: iDestControls.top
      anchors.left: parent.left
      anchors.right: parent.right

      anchors.bottomMargin: 25
      z: 1
    }

    Item {
      id: iDestControls
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      height: root.footerHeight
      z: 0
      anchors.margins: 15

      CDButton {
        id: bOK
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 150

        idleColConst: root.addColor
        txtText.text: "Potvrdi"

        onClick: {
          root.accept();
        }
      }

      CDButton {
        id: bDiscard
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 150

        idleColConst: root.deleteColor
        txtText.text: "Odustani"

        onClick: {
          root.reject();
        }
      }
    }
  }

  Rectangle {
    id: rContainerMask
    width: container.width
    height: container.height
    radius: rBg.radius - 2
    visible: false
  }
}
