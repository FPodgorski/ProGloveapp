import QtQuick 2.0

Item {
  id: iDetailsTitle
  height: minHeight;
  width: 350
  clip: true

  property bool bExpanded: false
  property int maxHeight: 400
  property int minHeight: 50
  property string buttonText: "Detalji"

  // Aliasing
  property alias txtDetailTitle: txtDetailTitle
  property alias titleDetails: titleDetails

  Rectangle {
    id: rDetailsHeader
    anchors.fill: parent
    border.color: "dodgerblue"
    border.width: 3
    radius: 5
    color: "#292929"

    MouseArea {
      id: maDetailsHeader
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      height: 50
      hoverEnabled: true

      onClicked: {
        if(iDetailsTitle.bExpanded) {
          paShrink.start();
          iDetailsTitle.bExpanded = !iDetailsTitle.bExpanded;
        }
        else {
          paExpand.start();
          iDetailsTitle.bExpanded = !iDetailsTitle.bExpanded;
        }
      }
    }

    Rectangle {
      id: rDetailTitleShade
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      height: iDetailsTitle.minHeight - 2 * rDetailsHeader.border.width
      color: maDetailsHeader.containsMouse ? "#414141" : "#141414"
      anchors.margins: rDetailsHeader.border.width
      property bool isHovering: false
//                visible: false

      Text {
        id: txtDetailTitle; anchors.fill: parent
        color: "white"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 25
        text: buttonText
        fontSizeMode: Text.Fit
      }
    }

    Item {
      id: ree
      anchors.top: rDetailTitleShade.bottom
      anchors.right: parent.right; anchors.left: parent.left
      anchors.bottom: parent.bottom
      anchors.margins: rDetailsHeader.border.width

      CDGridDetails {
        id: titleDetails
      }
    }
  }
  PropertyAnimation {
    id: paExpand; target: iDetailsTitle; property: "height"
    duration: 250; from: iDetailsTitle.minHeight; to: iDetailsTitle.maxHeight
    easing.type: Easing.InCirc; easing.amplitude: 2.0; easing.period: 1.5;
  }

  PropertyAnimation {
    id: paShrink; target: iDetailsTitle; property: "height"
    duration: 250; from: iDetailsTitle.maxHeight; to: iDetailsTitle.minHeight
    easing.type: Easing.OutCirc; easing.amplitude: 2.0; easing.period: 1.5
  }

  function setModel(model) {
    titleDetails.m_model = model;
  }
}

