import QtQuick 2.15
import QtQuick.Controls 2.15
//import Qt5Compat.GraphicalEffects
import Qt.labs.qmlmodels 1.0
import TTableModel 1.0

Rectangle {
  id: root
  width: 400; height: 240
  color: baseColor
  radius: 6

  clip: true

  property var expandedRows: []
  property var leadingHeaders: ["title","ingredients"];
  property var detailFields: {
    if(m_model.length == 0)
      return [];

    var cols = [];
    cols = Object.keys(m_model[0]);

    for(var i = 0; i < root.leadingHeaders.length; i++) {
      cols.splice(cols.indexOf(root.leadingHeaders[i]), 1);
    }

    return cols;
  }

  property var m_model: [
    //    {"title" : "asdf", "picture" : "", "ingredients" : "1234", "method" : "5678", },
    //    {"title" : "asdf", "picture" : "", "ingredients" : "1234", "method" : "5678", },
    //    {"title" : "asdf", "picture" : "", "ingredients" : "1234", "method" : "5678", },
    //    {"title" : "asdf", "picture" : "", "ingredients" : "1234", "method" : "5678", },
  ]


  // Aliasing

  property color baseColor: "#171717"
  property int detailsHeight: 250
  property bool multiExpansion: false
  property bool maDetailsEnabled: false

  // Signalisasja
  signal tableTouched(int rowIndex)
  signal rowExpanded(int rowIndex)
  signal rowShrunk(int rowIndex)

  signal headerEntered(string fieldName)
  signal headerExited(string fieldName)
  signal cellEntered(int rowIndex, string fieldName);
  signal cellExited(int rowIndex, string fieldName);
  signal rowPressAndHold(int rowIndex);
  signal headerPressAndHold(string fieldName);
  signal tableRightClick(int rowIndex);

  // ------------------------------------ LE ANDROID STATE XD
  property int iDelHeaderHeight: 35
  property int iDelValueFontSize: 24
  property int iDelHeaderFontSize: 18
  property int iDelWidth: (root.width - 20) / 3
  property int iDelHeight: 100

  property int detailGridHeight: 0

  property var headerColumnWidths: []
  property var detailColumnWidths: ({})

  onRowPressAndHold: {
    if(rowIndex != expandedRows[0])
      selectRow(rowIndex);
  }

  function selectRow(rowIndex) {
    if(multiExpansion) {
      if(expandedRows.includes(rowIndex)) {
        expandedRows.splice(expandedRows.indexOf(rowIndex), 1);
        expandedRows = expandedRows;
        rowShrunk(rowIndex);
      }
      else {
        expandedRows.push(rowIndex);
        expandedRows = expandedRows;
        rowExpanded(rowIndex);
      }
    }
    else {
      if(expandedRows.includes(rowIndex)) {
        expandedRows = [];
        rowShrunk(rowIndex);
      }

      else {
        expandedRows = [rowIndex];
        rowExpanded(rowIndex);
      }
    }
  }


  Component {
    id: recipeDelegate

    Item {
      id: iLeader
      property int rowIndex: index
      property real detailsOpacity : 0

      width: listView.width
      height: iDelHeight

      Rectangle {
        id: background
        x: 2; y: 2; width: parent.width - x*2; height: parent.height - y*2
        color: index % 2 ? Qt.lighter(root.baseColor, 1.5) : Qt.lighter(root.baseColor, 2)
        border.width: 0
        border.color: "dodgerblue"
        radius: 5
      }

      MouseArea {
        id: maRow
        anchors.fill: parent
        pressAndHoldInterval: 200
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        onPressAndHold: {
          rowPressAndHold(index);
        }

        onClicked: {
          tableTouched(index);
          if(mouse != undefined && mouse.button == Qt.RightButton) {
              tableRightClick(index);
          }

          else {
            print("yay dodged rightclick");
            if(multiExpansion) {
              if(expandedRows.includes(index)) {
                expandedRows.splice(expandedRows.indexOf(index), 1);
                expandedRows = expandedRows;
                rowShrunk(index);
              }
              else {
                expandedRows.push(index);
                expandedRows = expandedRows;
                rowExpanded(index);
              }
            }
            else {
              if(expandedRows.includes(index)) {
                expandedRows = [];
                rowShrunk(index);
              }

              else {
                expandedRows = [index];
                rowExpanded(index);
              }
            }
          }

          print("ExpandedRows = " + JSON.stringify(root.expandedRows))
        }
      }

      Item {
        id: topLayout
        x: 5; y: 5;
        height: iDelHeight; width: parent.width

        Row {
          anchors.fill: parent
          spacing: 5

          Repeater {
            id: rLeaders
            model: leadingHeaders.length

            delegate: Rectangle {
              id: leaderDelegate
              property string fieldName: m_model[iLeader.rowIndex][leadingHeaders[index]]
              visible: true
              //              width: headerColumnWidths.length == leadingHeaders.length ?  headerColumnWidths[index] : topLayout.width / leadingHeaders.length
              width: headerColumnWidths[index]
              height: parent.height
              color: "transparent"

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                onEntered: root.headerEntered(leaderDelegate.fieldName);
                onExited: root.headerEntered(leaderDelegate.fieldName);
                onPressAndHold: {
                  root.headerPressAndHold(leaderDelegate.fieldName)
                  root.rowPressAndHold(iLeader.rowIndex)
                }
              }

              Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                  GradientStop {
                    color: "#239999AA"
                    position: 0
                  }
                  GradientStop {
                    color: "#119999AA"
                    position: 0.85
                  }
                }
              }

              DetailDelegate {
                anchors.fill: parent
                value: m_model[iLeader.rowIndex][leadingHeaders[index]];
                label: leadingHeaders[index];

                txtLabel.font.pixelSize: root.iDelHeaderFontSize
                txtValue.font.pixelSize: root.iDelValueFontSize
              }

              Text {
                visible: false
                anchors.fill: parent
                text: m_model[iLeader.rowIndex][leadingHeaders[index]];
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true; font.pointSize: 16
                color: "black"
              }
            }
          }
        }
      }

      Item {
        id: details
        x: 10; width: parent.width - 20

        anchors { top: topLayout.bottom; topMargin: 10; bottom: parent.bottom; bottomMargin: 10 }
        opacity: iLeader.detailsOpacity

        GridView {
          id: detailsGrid
          anchors.fill: parent
          model: root.detailFields.length
          //          model: 16
          boundsBehavior: Flickable.StopAtBounds

          MouseArea {
            id: maDetails
            enabled: maDetailsEnabled
            anchors.fill: parent
            onClicked: {
              maRow.onClicked(null)
            }
            onPressAndHold:  {
              rowPressAndHold(index);
            }
          }

          onEnabledChanged: {
            if(enabled)
              root.detailGridHeight = contentHeight;
          }

          clip: true
          //          cellWidth: parent.width
          cellWidth: iDelWidth
          cellHeight: iDelHeight


          delegate: DetailDelegate {
            id: detailDelegate
            width: detailsGrid.cellWidth
            height: detailsGrid.cellHeight
            label: root.detailFields[index]
            value: m_model[iLeader.rowIndex][root.detailFields[index]];

            txtValue.font.pixelSize: root.iDelValueFontSize
            txtLabel.font.pixelSize: root.iDelHeaderFontSize

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onEntered: root.cellEntered(index, detailDelegate.label)
              onExited:  root.cellExited(index, detailDelegate.label)
            }
          }
        }
      }

      states: State {
        name: "Details"
        when: expandedRows.includes(iLeader.rowIndex);

        PropertyChanges {
          target: background;
          color: Qt.lighter(baseColor, 2.5);
          border.width: 3
        }
        PropertyChanges {
          target: iLeader;
          detailsOpacity: 1
          x: 0
          height: {
            //            return detailsHeight;
            return detailsGrid.contentHeight + iDelHeight + 25
          }
        }
        PropertyChanges {
          target: detailsGrid;
          enabled: true
          model: root.detailFields
        }
      }

      transitions: Transition {
        // Make the state changes smooth
        ParallelAnimation {
          ColorAnimation { property: "color"; duration: 500 }
          NumberAnimation { duration: 300; properties: "detailsOpacity,x,contentY,height,width" }
        }
      }
    }
  }

  Item {
    id: iHeader
    height: 0
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    Rectangle {
      anchors.fill: parent
      color: Qt.darker(baseColor, 1.25)
    }
  }

  ListView {
    id: listView
    anchors.top: iHeader.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.topMargin: 5

    model: m_model.length
    delegate: recipeDelegate

    ScrollBar.vertical: ScrollBar {
      active: true
    }
  }

  function setExplicitModel(model) {
    m_model = model.getJson();
  }

  function setBasicModel(data) {
    m_model = data;
    expandedRows = [];
  }

  function fieldByName(fieldName, rowIndex) {
    return m_model[rowIndex][fieldName];
  }

  TTableModel {
    id: m_tableModel
  }
}
