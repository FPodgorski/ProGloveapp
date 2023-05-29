import QtQuick 2.15

Rectangle {
  id: root
  color: "transparent"
  property int initialSortOrder: Qt.AscendingOrder
  property alias text: label.text

  // Gree
  property alias label: label
  property alias splitter: splitter
  property alias tap: tap
  property alias tiSearchBox: tiSearchBox

  property color highlightColor: "dodgerblue"
  property color baseColor: "#222222"
  clip: true

  property real initialWidth: 100

  signal headerResized(real width)
  signal sorting
  signal dropped(real x)
  signal rightClicked
  signal searchClosed
  signal searchRequested(int column, string keyword)

  width: splitter.x + 6
  z: dragHandler.active ? 1 : 0

  function stopSorting() {
    state = ""
  }

  signal sortRequested(int column, string state)


  NumberAnimation { id: showSearch; target: rSearchBox;
    property: "height"; to: labelAndSearch.height / 2; duration: 150;
    onFinished: {tiSearchBox.forceActiveFocus()}}
  NumberAnimation { id: hideSearch; target: rSearchBox;
    property: "height"; to: 0; duration: 150;
    onFinished: {searchClosed()}}

  Rectangle {
    anchors.left: parent.left; anchors.right: parent.right
    anchors.top: parent.bottom
    height: 50
    color: "slateblue"
    border.width: 3
    border.color: "green"
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.RightButton
    propagateComposedEvents: true
    onClicked: {
      if(mouse.button == Qt.RightButton) {
        rightClicked();
      }
      else {
        clicked();
      }
    }
  }


  Item {
    id: labelAndSearch
    anchors.top: parent.top; anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: upDownIndicator.visible ? upDownIndicator.left : upDownIndicator.right
    clip: true


    Item {
      id: iLabAndSort
      anchors.left: parent.left; anchors.right: parent.right
      anchors.top: parent.top; anchors.bottom: rSearchBox.top

      Text {
        id: label
        anchors.left: parent.left; anchors.right: sortButton.left
        anchors.top: parent.top; anchors.bottom: parent.bottom

        text: table.model.headerData(index, Qt.Horizontal)
  //      color: tiSearchBox.text != "" ? root.highlightColor : "gray"
        color: "white"
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter

        anchors.leftMargin:5

        elide: Text.ElideRight

        MouseArea {
          anchors.fill: parent
          id: tap;
          pressAndHoldInterval: 200


          onReleased: {
            if(rSearchBox.height != labelAndSearch.height / 2) {
              showSearch.start();
            }
            else
              hideSearch.start();
          }
        }
      }

      Rectangle {
        id: sortButton
        height: 15
        width: 15
        color: "transparent"
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
          anchors.fill: parent
          onClicked:  {
            print("Clicked sort button")
            nextState();
          }
        }

        Text {
          id: txtSortIndicator
          text: "^"
          color: "white"
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          anchors.fill: parent
          font.pointSize: 12
          visible: false
        }
      }
    }


    Rectangle {
      id: rSearchBox
      color: "#44000000"
      anchors.left: parent.left; anchors.right: parent.right
      anchors.bottom: parent.bottom
      clip: true
      height: 0
      radius: 5
      anchors.rightMargin: 0
      anchors.bottomMargin: 5
      anchors.topMargin: 5

      TextInput {
        id: tiSearchBox
        color: activeFocus ? "white" : "#9A9A9A"
        verticalAlignment: TextInput.AlignVCenter
        anchors.top: parent.top; anchors.bottom: parent.bottom
        anchors.left: parent.left; anchors.right: searchGlass.right
        anchors.leftMargin: 5
        onActiveFocusChanged: {
          if(activeFocus)
            selectAll();
          else {
            hideSearch.start();
          }
        }

        onAccepted: searchRequested(index, text)

        focus: true
        Keys.onReleased: {
          if(event.key == Qt.Key_Escape) {
            tiSearchBox.text = "";
            hideSearch.start();
          }
        }
      }

      Image {
        id: searchGlass
        width: height
//        source: "magnifyingGlass.svg"
        anchors.right: parent.right
        anchors.top: parent.top; anchors.bottom: parent.bottom
        anchors.margins: 7

        visible: tiSearchBox.contentWidth + width + 18 < parent.width
      }
    }
  }

  Text {
    id: upDownIndicator
    anchors.right: parent.right
    anchors.rightMargin: 10
    anchors.verticalCenter: parent.verticalCenter
    text: "^"
    visible: false
    font.bold: true
    font.pixelSize: 18
  }



  Rectangle {
    x: splitter.x
    width: 1
    color: "#23FFFFFF"
    anchors.verticalCenter: parent.verticalCenter
    height: 16
  }


  Item {
    id: splitter
    x: root.initialWidth - 6
    width: 12
    height: parent.height + 10
    onXChanged: table.forceLayout()


    MouseArea{
      id:tuSAM
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.SplitHCursor
    }


    DragHandler {
      yAxis.enabled: false
      xAxis.minimum: 50
      onActiveChanged: {
        if (!active) table.forceLayout()

        // Zapisat možda u columnWidths?
        headerResized(width);
      }
    }
  }

  DragHandler {
    id: dragHandler
    yAxis.enabled:  false
    onActiveChanged: if (!active) root.dropped(centroid.scenePosition.x)
  }

  function nextState() {
    if (state == "")
      state = "up"
    else if (state == "up")
      state = "down"
    else
      state = ""

    print("state set as " + state);
    root.sorting()
    root.sortRequested(index, state);
  }

  state: ""

  states: [
    State {
      name: "up"
      PropertyChanges { target: txtSortIndicator; visible: true; rotation: 0 }
    },
    State {
      name: "down"
      PropertyChanges { target: txtSortIndicator; visible: true; rotation: 180 }
    },
    State {
      name: ""
      PropertyChanges { target: txtSortIndicator; visible: false; rotation: 0 }
    }
  ]
}
