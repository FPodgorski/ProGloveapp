import QtQuick 2.15
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import CDTableModel 1.0
import CDTableProxyModel 1.0

Item {
  id: root
  implicitHeight: 501
  implicitWidth: 500
  height: 501
  width: 501
  focus: true

  property bool bAndroid: false
  property bool bFocus: false

  // Delegate properties (delegate i svi childovi delegatea su unaliasable XD
  property var ipsilon:0
  property var iks:0
  property var tableRefreshAnimation:tableRefreshAnimation
  property int tableFontSize: 0
  // Special delegates
  property var specialColumns: []
  property var editableColumns: []
  property var textEditArray: []
  property var textEditValues: ({})

  function specialDelegateColorProvider(row, column) {
    return "white";
  }

  // Basic properties
  property bool sortEnabled: true
  property bool bSelectionEnabled: true
  property bool bMultiSelection: false
  property var multiSelectionRows: []
  property var sourceSelectionRows: [];
  property bool filterActive: table.filterColumn >= 0
  property bool darkMode: true
  property bool manualFilterEnabled: true

  // Implementirat
  property bool forcedSelection: false // wat

  // Visuals
  property bool backgroundGradient: false
  property int rowHeight: 30;
  property int headerHeight: 40;
  property double bordWidth: 0
  property int defaultColWidth: 200
  property int defaultFontSize: 12
  property int headerFontSize: 13
  property int radius: 5
  property int headerAlignment: Text.AlignLeft
  property int textMargin: 8
  property int headerMargin: 5

  property color selectionFontColor: "white"
  property color headerColor: "#111111"
  property color frameColor: gradientStart.color
  property bool alternateRows: true

  // DarkMode
  property color fontColor: darkMode ? "#EAEAEA" : "black"
  property color bordColor: darkMode ? "#AAAAAA" : "black"
  property color backgroundColor: darkMode ? "#222222" : "#EEEEEE"
  property color selectionColor: darkMode ? Qt.darker(frameColor, 1.25) : "#889eb8"
  property color defaultCellColor: darkMode ? backgroundColor : "white"
  property color alternateCellColor: darkMode ? "#333333" : "#E0E0E0"

  // ------------------------------------ GradientStop

  Gradient {
    id: headerGradient

    orientation: Gradient.Vertical
    GradientStop {
      id: gradientStart
      position: 0
      color: "#333333"
    }

    GradientStop {
      position: 1
      color: "#222222"
    }
  }

  function loadVisualPreset()
  {
    print("Table trying to load visualPreset " + visualPreset);

    if(visualPreset == "")
      return;

    headerFontSize = visualPresets[visualPreset]["headerFontSize"];
    tableFontSize = visualPresets[visualPreset]["tableFontSize"];
    headerHeight = visualPresets[visualPreset]["headerHeight"];
    rowHeight = visualPresets[visualPreset]["rowHeight"];
    textMargin = visualPresets[visualPreset]["textMargin"];
    headerMargin = visualPresets[visualPreset]["headerMargin"];
    bordWidth = visualPresets[visualPreset]["bordWidth"];
    radius = visualPresets[visualPreset]["radius"];
  }

  function loadStylePreset()
  {
    if(stylePreset == "")
      return;

    fontColor = stylePresets[stylePreset]["fontColor"];
    bordColor = stylePresets[stylePreset]["bordColor"];
    backgroundColor = stylePresets[stylePreset]["backgroundColor"];
    defaultCellColor = stylePresets[stylePreset]["defaultCellColor"];
    alternateCellColor = stylePresets[stylePreset]["alternateCellColor"];
    alternateRows = stylePresets[stylePreset]["alternateRows"];
  }

  property string stylePreset: "";
  property string visualPreset: "";

  property var visualPresets: {
    "desktop" : {
      "radius": 5,
      "bordWidth" : 0,
      "headerFontSize": 22,
      "tableFontSize": 15,
      "headerHeight": 40,
      "rowHeight": 30,
      "textMargin": 9,
      "headerMargin": 5,
    },
    "hdpi" : {
      "radius": 15,
      "bordWidth" : 0,
      "headerFontSize": 30,
      "tableFontSize": 24,
      "headerHeight": 75,
      "rowHeight": 60,
      "textMargin": 25,
      "headerMargin": 10,
    },
  }

  property var stylePresets: {
    "light" : {
      "fontColor": "black",
      "bordColor": "black",
      "backgroundColor": "#EEEEEE",
      "defaultCellColor" : "#EEEEEE",
      "alternateCellColor" : "#E0E0E0",
      "alternateRows" : true,
    },
    "dark" : {
      "fontColor": "#EAEAEA",
      "bordColor": "#AAAAAA",
      "backgroundColor": "#222222",
      "defaultCellColor" : "#222222",
      "alternateCellColor" : "#333333",
      "alternateRows" : true,
    },
  }

  // Internal properties
  property bool hasSelection: lastSelected > -1 ? true : false
  property var mColumnDefs: ({})
  property var translatableColumns: []
  property int rowCount: table.rows
  property int boundsBehavior: Flickable.StopAtBounds
  property var rDiagParent: root
  property int copyRow: -1
  property int copyColumn: -1
  property int searchColumn: 0
  onHeightChanged: sourceModel.resetView()
  onWidthChanged: sourceModel.resetView()

  // Aliasing
  property alias sourceModel: sourceModel
  property alias tableModel: tableModel
  property alias table: table
  property alias panel: rFrame
  property alias lastSelected: table.lastSelected
  property alias contextMenu: contextMenu
  property alias headerGradient: headerGradient

  // Signals
  signal tableSelected(int row, int col)
  signal tableUnselected()
  signal unselected()

  signal tableHover(var column,var row, var cellContent)
  signal tableHoverExit()
  signal tableHeaderHover(var headerText)
  signal tableHeaderExit()

  signal rowPressAndHold(int row, int col);

  onRowPressAndHold: {
    lastSelected = row;
    tableSelected(row, col);
  }

  signal columnDefsReconstructed(var colDefs);

  // Width percent column definition
  property bool bColumnWidthPercent: false
  property string parentModule;
  property bool bSaveColDefs: false

  property bool bFetchColDefs: false
  property string uniqueDefsName: cb.get_project_name() + "_" + root.parentModule + "_" + root.objectName

  Connections {
    target: cdBridge
    onChangeOfTranslation: {
      sourceModel.setTranslations(cdBridge.translationMap);
      if(table.sortColumn >= 0)
        sourceModel.reapplySort();
    }
  }

  Component.onCompleted: {
    console.log("CDTables onCompleted triggered");
    sourceModel.setProxyModel(tableModel);

    if(bFetchColDefs)
    {
      console.log("bFetchColDefs = TRUE");
      console.log("cb.get_projectName() " + cb.get_project_name());
      console.log("root.parentModule" + root.parentModule);
      console.log("root.objectName" + root.objectName);
      console.log("uniqueDefsName = " + uniqueDefsName);
      cb.get_user_defs(uniqueDefsName, root.objectName, "receiveColumnDefs");
    }

    loadVisualPreset();
    loadStylePreset();
  }

  function receiveColumnDefs(args)
  {
    console.log("receiveColumnDefs called on table " + root.objectName + " from module " + root.parentModule);

    console.log("receiveColumnDefs called with" + JSON.stringify(args))
    var data = cb.parse_json(args["DataSet"]);
    if(data[0]["Value"])
    {
      mColumnDefs = JSON.parse(data[0]["Value"]);
    }
  }

  CDTableModel {
    objectName: "sourceModel"
    id: sourceModel
  }

  CDTableProxyModel{
    objectName: "tableModel"
    id: tableModel
  }


  Menu {
    id: contextMenu
    property int itemHeight: 40

    MenuItem {
      text: "Export as .csv"
      onTriggered: {
        console.log("exporting to csv...");
        sourceModel.exportCsv();
      }
    }

    MenuItem {
      text: "Copy cell"
      onTriggered: {

        var value = "";
        if(root.copyColumn >= 0 && root.copyRow >= 0)
        {
          value = fieldByName(copyRow, columnName(copyColumn));
          cdBridge.copy_to_clipboard(value);
        }
      }
    }
  }


  Menu {
    id: headerContextMenu

    MenuItem {
      text: "Filter"
      id: miFilter
      onTriggered: {
        filterDialog.open();
      }
    }

    MenuItem {
      text: "Edit cols"
      onTriggered: {
        editColsRoot.setTempDefs(mColumnDefs);
        editColsDialog.open();
      }
    }

    MenuItem {
      text: "Print cols"
      onTriggered: {
        print("mColumnDefs: " + JSON.stringify(mColumnDefs));
      }
    }
  }


  RectangularGlow {
    id: effect
    anchors.fill: rActualFrame
    glowRadius: 2
    spread: 0.5
    color: root.frameColor
    cornerRadius: rActualFrame.radius + glowRadius
    //      visible: tableRefreshAnimation.running

    SequentialAnimation {
      id: tableRefreshAnimation
      property int totalDur: 250

      NumberAnimation { target: effect; property: "glowRadius"; to: 13; duration: tableRefreshAnimation.totalDur / 2 }
      NumberAnimation { target: effect; property: "glowRadius"; to: 2; duration: tableRefreshAnimation.totalDur / 2 }
    }
  }


  Rectangle {
    id: rActualFrame
    anchors.margins: 0
    anchors.fill: parent

    color: "transparent"

    border.width: 3
    border.color: root.frameColor
    radius: root.radius + 3

    Rectangle {
      id: rFrame
      color: root.backgroundColor

      anchors.margins: rActualFrame.border.width / 2
      anchors.leftMargin: 2
      anchors.topMargin: 2
      anchors.rightMargin: 2
      anchors.bottomMargin: 2
      anchors.fill: parent

      radius: root.radius


      property bool rounded: true
      property bool adapt: true
      layer.enabled: rounded


      layer.effect: OpacityMask {
        maskSource: Item {
          anchors.centerIn: rFrame
          width: rFrame.width
          height: rFrame.height
          Rectangle{
            anchors.centerIn: parent
            width: rFrame.adapt ? rFrame.width : Math.min(rFrame.width, rFrame.height)
            height: rFrame.adapt ? rFrame.height : width
            radius: root.radius
          }
        }
      }

      Rectangle {
        id: rBorders
        color: root.bordColor

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: headerHeight

        height: table.rows * (root.rowHeight + 1)

        Rectangle{
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          color: root.backgroundColor
          width: table.width - table.contentWidth - visibleColumns() * 1
        }
      }





      TableView {
        id: table
        objectName: "table"
        anchors.leftMargin: 0.4
        boundsBehavior: Flickable.StopAtBounds
        z: 1

        onRowsChanged:  fixContentHeight()

        ScrollBar.vertical: ScrollBar {
          id: tableVerticalBar;
          policy: "AsNeeded"
        }

        // My defs
        property int lastSelected: -1;

        // sort
        property int sortColumn: -1;
        property int dbgState: 0 // 0 = no sort; 1 = asc sort; 2 = desc sort;

        // filter
        property int filterColumn: -1
        property string sFilterKeyword: ""
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: iHeader.bottom
        anchors.bottom: parent.bottom

        // ----------------------------------------- Ne treba mi ovo onda?
        columnWidthProvider: root.colWProv
        // -------------------------
        rowHeightProvider: function () { return root.rowHeight; }
        // -------------------------
        contentHeight: tableModel.rowCount() * (root.rowHeight + rowSpacing)
        // -------------------------
        model: tableModel
        // -------------------------
        contentWidth: root.contentWidthProvider()
        // -------------------------

        columnSpacing: 1
        rowSpacing: 1
        clip: true


        delegate: Rectangle {
          id: rSecTblDelegate
          border.color: root.bordColor
          border.width: root.bordWidth
          clip: true
          color: root.cellColorProvider(row, column)
          x: root.getColPos(column)
          implicitWidth: root.defaultColWidth
          y: column * root.rowHeight + table.spacing + root.headerHeight

          MouseArea {
            anchors.fill: parent

            anchors.leftMargin: -root.textMargin
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            pressAndHoldInterval: 200
            hoverEnabled: true

            onPressAndHold: {
              rowPressAndHold(row, column);
            }

            onClicked: {
              root.searchColumn = column;
              if(bFocus)
                root.forceActiveFocus();

              if(mouse.button == Qt.RightButton)
              {
                root.tableRightClick(row, column);
              }

              else
              {
                if(root.bMultiSelection)
                {
                  if(!bAndroid)
                  {
                    var rowInMultiSelect = 0; var sourceRow;
                    if(table.dbgState == 0)
                      sourceRow = row;
                    else if(table.dbgState == 1 || table.dbgState == 2) {
                      sourceRow = sourceModel.unfilteredIndex(row);
                    }

                    if(mouse.modifiers == Qt.ControlModifier)
                    {
                      // Je li selektirani row unutar selekcije
                      for(var i = 0; i < sourceSelectionRows.length; i++)
                      {
                        if(sourceRow == sourceSelectionRows[i])
                          rowInMultiSelect = 1;
                      }


                      print("rowInMultiSelect = " + rowInMultiSelect)

                      if(rowInMultiSelect) {
                        sourceSelectionRows.splice(sourceSelectionRows.indexOf(sourceRow), 1);
                      }
                      else {
                        sourceSelectionRows.push(sourceRow);
                        tableSelected(row, column);
                        lastSelected = row;
                      }
                    }

                    else
                    {
                      if(sourceSelectionRows.length == 1 && isRowInMultiSelect(sourceRow)) {
                        sourceSelectionRows = [];
                      }
                      else {
                        sourceSelectionRows = [sourceRow];
                        tableSelected(row, column);
                        lastSelected = row;
                      }
                    }


                    // Please another way
                    var lastSelectedArr = [];

                    if(table.dbgState == 0) {
                      multiSelectionRows = sourceSelectionRows;
                    }
                    else {
                      for (var i = 0; i < sourceSelectionRows.length; i++)
                      {
                        lastSelectedArr.push(sourceModel.mapFromSource(sourceSelectionRows[i]));
                      }

                      multiSelectionRows = lastSelectedArr;
                    }
                  }

                  else
                  {
                    var rowInMultiSelect = 0; var sourceRow;
                    if(table.dbgState == 0)
                      sourceRow = row;
                    else if(table.dbgState == 1 || table.dbgState == 2) {
                      sourceRow = sourceModel.unfilteredIndex(row);
                    }

                    // Je li selektirani row unutar selekcije
                    for(var i = 0; i < sourceSelectionRows.length; i++)
                    {
                      if(sourceRow == sourceSelectionRows[i])
                        rowInMultiSelect = 1;
                    }


                    print("rowInMultiSelect = " + rowInMultiSelect)

                    if(rowInMultiSelect) {
                      sourceSelectionRows.splice(sourceSelectionRows.indexOf(sourceRow), 1);
                    }
                    else {
                      sourceSelectionRows.push(sourceRow);
                      tableSelected(row, column);
                      lastSelected = row;
                    }


                    // Please another way
                    var lastSelectedArr = [];

                    if(table.dbgState == 0) {
                      multiSelectionRows = sourceSelectionRows;
                    }
                    else {
                      for (var i = 0; i < sourceSelectionRows.length; i++)
                      {
                        lastSelectedArr.push(sourceModel.mapFromSource(sourceSelectionRows[i]));
                      }

                      multiSelectionRows = lastSelectedArr;
                    }
                  }


                }


                else
                {
                  if(table.lastSelected === row)
                  {

                    table.lastSelected = -1
                    tableUnselected();
                    unselected();
                  }
                  else
                  {
                    table.lastSelected = row;
                    tableSelected(row, column);
                  }
                }

                root.tablePress();
              }
            }

            /////////////////Eventovi za hover u tablici\\\\\\\\\\\
            onEntered:{
              tableHeaderExit();
              var cellContent = txtSecTblDelegate.text
              tableHover(column, row, cellContent);
            }
            onExited: {
              tableHeaderExit();
              tableHoverExit();
            }
            onPositionChanged: {
              var globalPosition = mapToGlobal(mouse.x, mouse.y)

              var isthisit= JSON.stringify(globalPosition)

              var isthisreallyit=JSON.parse(isthisit)

              ipsilon=isthisreallyit.y
              iks=isthisreallyit.x

            }
          }


          Rectangle {
            z: 1
            anchors.fill: parent
            color: root.cellColorProvider(row, column)
            visible: editableColumns.includes(column)

            clip: true

            TextInput {
              id: txtEditDelegate
              anchors.fill: parent
              //              color: "white"
              font.pixelSize: txtSecTblDelegate.font.pixelSize + 5
              text: textEditValues[row]
              horizontalAlignment: TextInput.AlignHCenter
              verticalAlignment: TextInput.AlignVCenter
              color: "lime"

              enabled: editableColumns.includes(column)
              visible: editableColumns.includes(column)

              validator: IntValidator {bottom: 0; top: root.fieldByName(row, "Kol"); id: kolicinaValidator}
              inputMethodHints: "ImhDigitsOnly"

              onEditingFinished: {
                textEditValues[row] = text;
                txtEditDelegate.text = text;
                print("textEditValues = " + JSON.stringify(textEditValues));
              }
            }
          }


          Rectangle {
            anchors.centerIn: parent
            height: parent.height * 0.75
            width: height
            radius: width
            color: specialDelegateColorProvider(row, column)
            visible: specialColumns.includes(column)

            clip: true

            Rectangle{
              anchors.fill: parent
              radius: width
              gradient: Gradient{
                GradientStop{
                  position: 0
                  color: "#54000000"
                }

                GradientStop{
                  position: 1
                  color: "#22000000"
                }
              }
            }

          }


          Text {
            id: txtSecTblDelegate
            clip: true
            z: 1

            text: (display in cdBridge.translationMap && column in translatableColumns) ? cdBridge.translationMap[display] : display
            color: root.textColorProvider(row, column)

            visible: !specialColumns.includes(column)

            anchors.fill: parent
            anchors.leftMargin: root.textMargin
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: root.tableFontSize


          }
        }
      }

      Item {
        id: iHeader
        height: root.headerHeight
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 1
        clip: true

        Row {
          id: rSecTblHeader
          z: 5
          x: - table.contentX
          spacing: 1
          clip: true

          Repeater {
            model: table.columns
            id: headerRepeater
            y: -headerHeight


            Rectangle {
              id: rHeaderDelegate
              width: splitter.x + 6
              height: headerHeight
              border.width: 0
              border.color: "gray"

              gradient: headerGradient
              clip: true
              Item {
                z: 2
                id: splitter
                visible: !hidden(modelData) ? true : false

                x: splitterWidthProvider(modelData)
                //                width: !hidden(modelData) ? 12 : -6
                width: !hidden(modelData) ? 12 : -6
                height: parent.height + 10

                Rectangle{
                  anchors.fill: parent
                  color: "transparent"

                  MouseArea{
                    cursorShape: Qt.SplitHCursor
                    anchors.fill: parent
                  }
                }

                DragHandler{
                  yAxis.enabled: false
                  dragThreshold: 2

                  onActiveChanged: {
                    if(!active)
                    {
                      reconstructColDefs()
                      table.forceLayout()
                    }
                  }

                  xAxis.minimum:  splitter.width
                }
              }

              Label {
                id: headerTextDelegate
                anchors.fill: parent
                anchors.margins: Math.min(parent.height, parent.width) * 0.1
                text: labelProvider(columnName(index))
                color: table.filterColumn == index ? "red" : '#ffffff'
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: root.headerAlignment
                //                fontSizeMode: Text.Fit

                anchors.leftMargin: root.headerMargin

                font.pixelSize: root.headerFontSize
                padding: 10
                background: Rectangle { color: "transparent" }

                visible: {
                  var colName = columnName(index);
                  if(mColumnDefs[colName])
                  {
                    if(mColumnDefs[colName]["visible"])
                    {
                      if(mColumnDefs[colName]["visible"].toString().toUpperCase() === "FALSE" ||
                          mColumnDefs[colName]["visible"].toString() === "0")
                        return false;
                      else
                        return true;
                    }
                    else
                      return true;
                  }
                  else
                    return true;
                }

                Image {
                  id: imSortIndicator
                  visible: table.sortColumn == index
                  width: height
                  height: 15
                  anchors.right: parent.right
                  anchors.rightMargin: 10

                  anchors.verticalCenter: parent.verticalCenter


                  source: "whiteTriangle.png"

                  fillMode: Image.PreserveAspectCrop
                  rotation: {
                    if(table.dbgState === 1)
                      return 0;
                    else
                      return 180;
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  anchors.rightMargin: 6
                  anchors.margins: -root.bordWidth
                  acceptedButtons: Qt.LeftButton | Qt.RightButton // Left = 1, Right = 2
                  propagateComposedEvents: true
                  hoverEnabled: true

                  pressAndHoldInterval: 250

                  onPressAndHold: {
                    filterDialog.sColumnName = parent.text;
                    filterDialog.iColDex = index;

                    filterDialog.open();
                  }

                  onClicked: {

                    console.log(root.objectName + "'s headerTextDelegate onClicked");


                    sourceModel.setTranslations(cdBridge.translationMap);


                    if(mouse.button == 1 && root.sortEnabled)
                    {
                      if(table.sortColumn == index)
                      {
                        if(table.dbgState == 0)
                        {
                          table.dbgState = 1;
                          sourceModel.sortColumn(index, false);
                          afterFilterSort();
                        }
                        else if (table.dbgState == 1)
                        {
                          table.dbgState = 2;
                          sourceModel.sortColumn(index, true);
                          afterFilterSort();
                        }
                        else
                        {
                          resetSort();
                        }
                      }
                      else
                      {
                        table.sortColumn = index;
                        table.dbgState = 1;
                        sourceModel.sortColumn(index, false);
                        afterFilterSort();
                      }
                    }
                    else if (mouse.button == 2 && root.manualFilterEnabled)
                    {
                      filterDialog.sColumnName = parent.text;
                      filterDialog.iColDex = index;
                      headerContextMenu.popup();
                      return;

                    }
                  }
                  onEntered:{
                    var headerText=headerTextDelegate.text
                    tableHeaderHover(headerText);
                  }
                }
              }
            }
          }
        }
      }
    }

    Text {
      id: txtRowCount
      width: 300
      color: "black"
      anchors.top: rActualFrame.bottom
      anchors.topMargin: 5
      anchors.left: rActualFrame.left
      text: ""

      MouseArea {
        anchors.fill: parent
        onEntered: {
          txtRowCount.text = "Row count: " + table.rows
        }
        onExited: {
          txtRowCount.text = ""
        }
      }
    }


  }

  Dialog{
    id: editColsDialog

    anchors.centerIn: parent
    //    title: "Edit columns"
    width: parent.width * 0.7
    height: parent.height * 0.9
    modal: true

    //    standardButtons: Dialog.Ok | Dialog.Cancel

    contentItem:Item {
      id: editColsRoot
      objectName: "editColsRoot"
      anchors.fill: parent

      property var editColsModel;
      property var mColumnDefsTemp;

      function setTempDefs(defs)
      {
        mColumnDefsTemp = defs;
        var inpJson = mColumnDefsTemp
        var keys = Object.keys(inpJson);

        editColsModel = [];
        for(var i = 0; i < keys.length; i++)
        {
          var editColsModelChunk = inpJson[keys[i]];
          editColsModelChunk["ColumnName"] = keys[i];
          editColsModel.push(editColsModelChunk);
        }

        console.log("Done constructing editColsModel; editColsModel = " + JSON.stringify(editColsModel));
        lvColumns.model = editColsModel;
      }


      Rectangle {
        id: rColsBg
        color: "transparent"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: iColsCtrls.top
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.topMargin: 5
        anchors.bottomMargin: 5

        Item {
          id: iColList
          anchors.fill: parent
          clip: true


          ListView{
            id: lvColumns
            anchors.fill: parent
            model: []
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
              active: true
            }

            delegate: CheckBox{

              text: editColsRoot.editColsModel[index]["ColumnName"]
              checked: editColsRoot.editColsModel[index]["visible"] == "1" || !editColsRoot.editColsModel[index]["visible"]

              anchors.left: parent.left
              anchors.leftMargin: 25

              onCheckedChanged: {
                if(checked)
                {
                  editColsRoot.mColumnDefsTemp[text]["visible"] = "1";
                }
                else
                {
                  editColsRoot.mColumnDefsTemp[text]["visible"] = "0";
                }
              }
            }
          }
        }
      }

      Item {
        id: iColsCtrls
        y: 415
        height: 65
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.rightMargin: 5
        anchors.leftMargin: 5

        Button {
          id: bSaveCols
          width: (parent.width - 3) / 2
          text: qsTr("Save")
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.topMargin: 0
          anchors.leftMargin: 0

          onClicked: {
            mColumnDefs = editColsRoot.mColumnDefsTemp
            editColsDialog.close();
            table.forceLayout()
            resetView();
            updateUserDefs();
          }
        }

        Button {
          id: bCancelCols
          width: (parent.width - 3) / 2
          text: qsTr("Cancel")
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.topMargin: 0
          onClicked: {
            editColsDialog.close();
          }
        }
      }
    }
  }


  Dialog {
    id: filterDialog
    parent: table
    height: 550
    width: 600


    focus: true

    onOpened: {
      tiKeyword.forceActiveFocus();
    }

    onClosed: {
      root.parent.forceActiveFocus();
    }

    Keys.onReleased: {
      if (event.key == Qt.Key_Back ||  event.key == Qt.Key_Escape)
      {
        event.accepted = true;
        filterDialog.discarded();
      }
    }

    x: (parent.width - width) / 2;
    y: (parent.height - height) / 2 - 250;

    property string sColumnName: ""
    property int iColDex: -1

    background: Rectangle {
      id: rFilterMenuBg
      color: "#222222"
      anchors.fill: parent
      radius: 5
      border.color: frameColor
      border.width: 5
    }

    contentItem:   Item {
      id: iFilterMenuContent
      anchors.fill: parent
      anchors.margins: 25

      Item {
        id: iFilterParams
        x: 0
        y: 65
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: iFilterMenuHeader.bottom
        anchors.bottom: iFilterMenuFooter.top
        anchors.leftMargin: 0

        Item {
          id: iFilterKeyword
          height: parent.height * 0.5
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.leftMargin: 0

          Text {
            id: txtKeywordLabel
            width: parent.width / 3
            color: "#ffffff"
            text: qsTr("KljuÄna rijeÄ")
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            font.pixelSize: 30
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            anchors.topMargin: 0
            anchors.leftMargin: 25
          }

          Rectangle {
            id: rKeywordBg
            height: 75
            color: "#ffffff"
            radius: 3
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: txtKeywordLabel.right
            anchors.right: parent.right
            anchors.rightMargin: 25

            TextInput {
              id: tiKeyword
              text: qsTr("")
              anchors.fill: parent
              font.pixelSize: 32
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
            }
          }
        }

        Item {
          id: iFilterType
          x: 0
          y: 97
          height: 97
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: iFilterKeyword.bottom

          Text {
            id: txtFilterTypeLabel
            width: parent.width / 3
            color: "#ffffff"
            text: qsTr("Tip filtera")
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            font.pixelSize: 30
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            anchors.leftMargin: 25
            anchors.topMargin: 0
          }

          ComboBox {
            id: cmbFilterType
            height: 90
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: txtFilterTypeLabel.right
            anchors.right: parent.right
            anchors.leftMargin: 0
            anchors.rightMargin: 25
            model: ["SadrÅ¾i", "PoÄinje", "ZavÅ¡rava", "IdentiÄno"]
          }
        }
      }

      Item {
        id: iFilterMenuFooter
        x: 0
        y: 335
        height: 75
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        CDButton {
          id: bAcceptFilter
          width: 150
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          txtText.text: "Filtriraj"
          idleColConst: "#58db16"
          onClick: {
            filterDialog.accept();
          }
        }

        CDButton {
          id: bDiscardFilter
          width: 150
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          txtText.text: "Odustani"
          idleColConst: "#d00000"
          onClick: {
            filterDialog.close();
          }
        }
      }

      Item {
        id: iFilterMenuHeader
        height: 75
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 0

        CDButton {
          id: bResetFilter
          width: 220
          text: qsTr("Resetiraj filter")
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          idleColConst: "#d00000"
          visible: table.filterColumn >= 0
          onClick: {
            resetFilter();
            filterDialog.close();
          }
        }

        Rectangle {
          id: rFilterMenuTitleBg
          height: 200
          color: "#373737"
          anchors.left: parent.left
          anchors.right: bResetFilter.visible ? bResetFilter.left : parent.right
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.rightMargin: bResetFilter.visible ? 25 : 0
          clip: true

          Text {
            id: txtFilterMenuTitle
            color: "#ffffff"
            text: "Filter po '<font color=\"red\">" + filterDialog.sColumnName + "</font>'"
            anchors.fill: parent
            font.pixelSize: 32
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.Fit
            anchors.leftMargin: 15
            anchors.rightMargin: 15
          }
        }
      }
    }

    onAccepted: {
      var sFK = tiKeyword.text;

      if(cmbFilterType.currentText == "PoÄinje")
        sFK = "^" + sFK;
      else if(cmbFilterType.currentText == "ZavrÅ¡ava")
        sFK = sFK + "$";
      else if(cmbFilterType.currentText == "IdentiÄno")
        sFK = "^" + sFK + "$";

      console.log("sFilterKeywod = " + sFK);
      console.log("iColDex = " + filterDialog.iColDex);

      applyFilter(filterDialog.iColDex, sFK);
    }
  }



  //-----------------------------------------------------------------------------------------------
  //                                ROOT ITEM LOGIC
  //-----------------------------------------------------------------------------------------------
  // Outward methods
  //-------------------------------------------------
  function columnName(col)
  {
    return sourceModel.columnName(col);
  }
  //-------------------------------------------------
  function columnIndex(colName)
  {
    var unfilteredIndex = sourceModel.columnIndex(colName);
    console.log("columnIndex returns " + unfilteredIndex);
    return unfilteredIndex;

    var keys = Object.keys(mColumnDefs);

    var iNrInvisBeforeIndex = 0;
    var header = getHeader();
    for (var i = 0; i < header.length; i++)
    {
      var headerText = header[i];
      if(mColumnDefs[headerText]["visible"] == 0)
      {
        iNrInvisBeforeIndex++;
      }
    }

    console.log("iNrInvisBeforeIndex = " + iNrInvisBeforeIndex);

    return unfilteredIndex - iNrInvisBeforeIndex;


    console.log("unfilteredIndex (old return) = " + unfilteredIndex);



    for (var i = 0; i < keys.length; i++)
    {
      var colDefIndex = sourceModel.columnIndex(keys[i]);
      if(colDefIndex < unfilteredIndex && mColumnDefs[keys[i]]["visible"] == "0")
      {
        iNrInvisBeforeIndex++;
      }
    }

    return unfilteredIndex - iNrInvisBeforeIndex;
  }
  //-------------------------------------------------
  function resetView()
  {
    sourceModel.resetView();
  }
  //-------------------------------------------------
  function fieldByNameUnfiltered(row, colName)
  {
    return sourceModel.fieldByNameUnfiltered(row, colName);
  }
  //-------------------------------------------------
  function rowCountUnfiltered()
  {
    return sourceModel.rowCount();
  }
  //-------------------------------------------------
  function isRowInMultiSelect(row)
  {
    for(var i = 0; i < multiSelectionRows.length; i++)
    {
      if(multiSelectionRows[i] == row)
      {
        return true;
      }
    }
    return false;
  }
  //-------------------------------------------------
  function fieldByName(row, colName)
  {
    return sourceModel.fieldByName(row, colName);
  }
  //-------------------------------------------------
  function selected(colName)
  {
    if(root.lastSelected >= 0)
      return sourceModel.fieldByName(root.lastSelected, colName)
    else
      return "";
  }
  //-------------------------------------------------
  function selectedRowValue(colName)
  {
    if(table.lastSelected > -1)
    {
      return tableModel.fieldByName(table.lastSelected, colName);
    }
    else
      return null;
  }
  //-------------------------------------------------
  function clearData()
  {
    console.log("CDTable::clearData() called");
    tableModel.clearData();
  }
  //-------------------------------------------------
  function setData(data) // Json array ie 2d
  {
    sourceModel.setJson(data);

    // 28.07.22 extras
    table.lastSelected = -1;
    unselected();
    tableUnselected();
    setTranslatableColumns();
    // Wat
    if(!tableRefreshAnimation.running)
      tableRefreshAnimation.start();
  }
  //-------------------------------------------------
  function setHeader(header) // String array ie 1d
  {
    sourceModel.setHeaderQML(header);
  }
  //-------------------------------------------------
  function setModel(data)
  {
    resetSort();

    table.lastSelected = -1;
    unselected();
    tableUnselected();
    sourceModel.setJsonQueryData(data);
    setTranslatableColumns();
    // Wat
    if(!tableRefreshAnimation.running)
      tableRefreshAnimation.start();
  }
  //-------------------------------------------------
  function setContentHeight(height)
  {
    table.contentHeight = height;
  }
  //-------------------------------------------------
  // Mogu?i but sa ovom func - ako nije definiran "translatable" u jednom od colDefs pukne javascript

  function setTranslatableColumns()
  {
    translatableColumns = [];
    var keys = Object.keys(mColumnDefs);

    for(var i = 0; i < keys.length; i++)
    {
      if(mColumnDefs[keys[i]]["translatable"] == "true")
      {
        var iColName = keys[i];
        var iColDex = sourceModel.columnIndex(keys[i]);

        translatableColumns.push(iColDex);
      }
    }

    console.log("setTranslatableColumns return list = " + JSON.stringify(translatableColumns));
    sourceModel.setTranslatableColumns(translatableColumns);
  }
  //------------------------------------------------- ?
  function tablePress() {}
  //------------------------------------------------- ??
  //-------------------------------------------------


  //-------------------------------------------------
  // User definable extra events
  //-------------------------------------------------
  function extraCellColorProvider(row, col) {return "";}
  //-------------------------------------------------
  function extraTextColorProvider(row, col) {return "";}
  //-------------------------------------------------
  function tableRightClick(row, column)
  {
    copyRow = row;
    copyColumn = column;
    contextMenu.popup();

    if(!root.bMultiSelection)
    {
      table.lastSelected = row;
      tableSelected(row, column);
    }
  }

  //-------------------------------------------------
  // Useful Calls 13.12.2021.
  //-------------------------------------------------
  function swapRows(first, second)
  {
    sourceModel.swapRows(first, second);
  }
  //-------------------------------------------------
  function appendRow(row)
  {
    sourceModel.appendRow(row);
  }
  //-------------------------------------------------
  function removeRow(index)
  {
    sourceModel.removeRow(index);
  }
  //-------------------------------------------------
  function selectRow(row)
  {
    table.lastSelected = row;
    tableSelected(row, 0);
  }
  //-------------------------------------------------
  function getData()
  {
    return sourceModel.getRawData();
  }
  //-------------------------------------------------
  function getRow(index)
  {
    return sourceModel.getRow(index);
  }
  //-------------------------------------------------
  function getHeader()
  {
    return sourceModel.getRawHeader();
  }
  //-------------------------------------------------
  function replaceRow(index, row)
  {
    sourceModel.replaceRow(index, row);
  }
  //-------------------------------------------------
  function resetSort()
  {
    table.sortColumn = -1;
    table.dbgState = 0;
    sourceModel.resetSort();
  }

  //-------------------------------------------------
  // Table stuff provideri
  //-------------------------------------------------
  function colWProv(col)
  {
    return headerWidthProvider(col);


    var colName = sourceModel.columnName(col);
    if(mColumnDefs[colName])
    {
      var bVisible = true;
      if(mColumnDefs[colName]["visible"])
      {
        if(mColumnDefs[colName]["visible"].toString().toUpperCase() === "FALSE"
            || mColumnDefs[colName]["visible"].toString() === "0")
          bVisible = false;
      }

      if(bVisible)
      {
        if(mColumnDefs[colName]["width"])
          return mColumnDefs[colName]["width"];
        else
          return root.defaultColWidth;
      }
      else
        return 0;
    }
    return root.defaultColWidth;
  }
  //-------------------------------------------------
  function labelProvider(fieldName)
  {
    if(mColumnDefs[fieldName])
    {
      if(mColumnDefs[fieldName]["label"])
        return mColumnDefs[fieldName]["label"];
    }

    return fieldName;
  }
  //-------------------------------------------------
  function cellColorProvider(row, col)
  {
    if(root.bMultiSelection)
    {
      var rowInMultiSelect = 0;
      for(var i = 0; i < multiSelectionRows.length; i++)
      {
        if(row == multiSelectionRows[i])
          rowInMultiSelect = 1;
      }

      if(rowInMultiSelect)
        return selectionColor;
    }
    else
    {
      var extraReturn = extraCellColorProvider(row, col);
      if(extraReturn)
      {
        return extraReturn;
      }

      if(row === table.lastSelected && bSelectionEnabled)
        return selectionColor;
    }


    var colName = sourceModel.columnName(col);
    if(mColumnDefs[colName])
    {
      if(mColumnDefs[colName]["color"])
        return mColumnDefs[colName]["color"];
    }

    if(root.alternateRows)
    {
      if(row % 2)
        return root.defaultCellColor;
      else
        return root.alternateCellColor;
    }
    return root.defaultCellColor;
  }
  //-------------------------------------------------
  function textColorProvider(row, col)
  {
    var extraReturn = extraTextColorProvider(row, col);

    if(extraReturn)
    {
      return extraReturn;
    }

    if(root.lastSelected == row)
      return root.selectionFontColor

    var colName = sourceModel.columnName(col);
    if(mColumnDefs[colName])
    {
      if(mColumnDefs[colName]["fontColor"])
        return mColumnDefs[colName]["fontColor"];
    }
    return root.fontColor;
  }
  //-------------------------------------------------
  function getColPos(col)
  {
    var colName = sourceModel.columnName(col);
    var colPos = 0;

    for(var i = 0; i < col; i++)
    {
      var tempColName = sourceModel.columnName(i);
      if(mColumnDefs[tempColName])
      {
        var bVisible = true;
        if(mColumnDefs[tempColName]["visible"])
        {
          if(mColumnDefs[tempColName]["visible"].toString().toUpperCase() === "FALSE"
              || mColumnDefs[tempColName]["visible"].toString() === "0")
            bVisible = false;
        }

        if(bVisible)
        {
          if(mColumnDefs[tempColName]["width"])
          {
            colPos += mColumnDefs[tempColName]["width"];
          }
          else
            colPos += root.defaultColWidth;
        }
      }
      else
        colPos += root.defaultColWidth;
    }
    return colPos;
  }
  //-------------------------------------------------
  function contentWidthProvider()
  {
    var w = 0;
    for(var i = 0; i < table.columns; i++)
    {
      w += headerRepeater.itemAt(i).width
    }

    return w;
  }
  //-------------------------------------------------
  function applyFilter(col, regExp)
  {
    console.log("applyFilter called with col = " + col + ", regExp = " + regExp);

    table.filterColumn = col;
    table.sFilterKeyword = regExp;

    sourceModel.setFilterColumn(col);
    //    tableModel.setFilterRegExp(regExp);
    tableModel.setFilterRegularExpression(regExp);

    afterFilterSort();
  }
  //-------------------------------------------------
  function afterFilterSort()
  {
    if(bMultiSelection)
    {

    }


    console.log("The old lastSelected = " + lastSelected);
    root.lastSelected = sourceModel.mapFromSource(lastSelected);
    if(lastSelected > -1)
    {
      tableSelected(lastSelected, 0);
    }
    else
    {
      unselected();
      tableUnselected();
    }
    console.log("The new lastSelected = " + lastSelected);
  }
  //-------------------------------------------------
  function unfilteredIndex(row)
  {
    return sourceModel.unfilteredIndex(row);
  }
  //-------------------------------------------------
  function genRegExp(filterType, keyWord)
  {
    var regExp = "";

    if(filterType == "Starts")
    {
      regExp = "^" + keyWord;
    }
    else if(filterType == "Ends")
    {
      regExp = keyWord + "$";
    }
    else if(filterType == "Equal to")
    {
      regExp = "^" + keyWord + "$";
    }
    else if(filterType == "Contains")
    {
      regExp = keyWord;
    }

    console.log("generated regExp = " + regExp);
    return regExp;
  }
  //-------------------------------------------------
  function enableManualFilter()
  {
    manualFilterEnabled = true;
  }
  //-------------------------------------------------
  function disableManualFilter()
  {
    manualFilterEnabled = false;
  }
  //-------------------------------------------------
  function resetFilter()
  {
    sourceModel.setFilterColumn(-1);
    tableModel.setFilterFixedString("");

    table.filterColumn = -1;
    table.sFilterKeyword = "";

    tiKeyword.text = "";
  }
  //-------------------------------------------------
  function resetContentWidth()
  {
    var c = contentWidthProvider();
    table.contentWidth = c;
    table.contentWidth = Qt.binding(contentWidthProvider);
  }

  //-------------------------------------------------
  // User input
  //-------------------------------------------------

  property int fillers: (table.height / rowHeight) / 2 - 1
  property string concat;

  Keys.onPressed: {

    if(root.bMultiSelection)
      return;

    if(event.key == Qt.Key_Escape || event.key == Qt.Key_Back)
      return;

    if(event.key == Qt.Key_Up && table.lastSelected > 0) // Key Up event
    {
      event.accepted = true;
      table.lastSelected--;
      if(table.lastSelected < rowCount - fillers - 1 && table.lastSelected >= fillers)
        table.contentY = scrollPosCalc();
      tableSelected(table.lastSelected, 0);
    }

    else if (event.key == Qt.Key_Down && table.lastSelected < rowCount - 1) // Key down event
    {
      event.accepted = true;
      table.lastSelected++;
      if(table.lastSelected < rowCount - fillers - 1 && table.lastSelected >= fillers)
        table.contentY = scrollPosCalc();
      tableSelected(table.lastSelected, 0);
    }

    else
    {
      concat += event.text;
      var concatPos = sourceModel.findFirstOccurence(concat, root.searchColumn);

      // Fetch first index that matches from model
      if(concatPos >= 0)
      {
        table.lastSelected = concatPos;
        if(concatPos >= 0  && concatPos <= fillers)
          table.contentY = 0;
        else if (concatPos > fillers && concatPos < table.rows - fillers )
          table.contentY = scrollPosCalc();
        else if (concatPos >= table.rows - fillers)
          table.contentY = table.contentHeight -  table.height;
      }

      searchTimer.stop();
      searchTimer.start();
    }
  }
  //-------------------------------------------------
  function scrollPosCalc()
  {
    return (rowHeight + table.rowSpacing) * table.lastSelected - fillers*(rowHeight + table.rowSpacing);
  }

  Timer {
    id: searchTimer
    interval: 500
    onTriggered: {
      concat = "";
      tableSelected(table.lastSelected, 0);
    }
  }

  //-------------------------------------------------
  function headerWidthProvider(column)
  {
    if(!bColumnWidthPercent)
      return headerRepeater.itemAt(column).width;
    else
    {
      var colName = columnName(column);
      return mColumnDefs[colName]["widthPerc"] * table.width;
    }
  }
  //-------------------------------------------------
  function splitterWidthProvider(column)
  {
    var colName = sourceModel.columnName(column);
    if(mColumnDefs[colName])
    {
      if(mColumnDefs[colName]["visible"] == "0")
        return -6;
      if(mColumnDefs[colName]["width"])
        return mColumnDefs[colName]["width"];
    }
    return root.defaultColWidth
  }


  property var mHiddenColumns: []

  //-------------------------------------------------
  function hidden(colDex)
  {
    var colName = sourceModel.columnName(colDex);
    if(mColumnDefs[colName])
    {
      if(mColumnDefs[colName]["visible"] == "0")
        return true;
      else
        return false;
    }

    return false;
  }
  //-------------------------------------------------
  function visibleColumns()
  {
    var nrCols = sourceModel.columnCount();
    for(var i = 0; i < table.columns; i++)
    {
      var colName = sourceModel.columnName(i);
      if(mColumnDefs[colName])
      {
        if(mColumnDefs[colName]["visible"] == "0")
          nrCols--;
      }
    }
    return nrCols;
  }
  //-------------------------------------------------
  function reconstructColDefs()
  {
    for(var i = 0; i < table.columns; i++)
    {
      var colName = sourceModel.columnName(i);

      if(mColumnDefs[colName])
      {
        mColumnDefs[colName]["width"] = headerRepeater.itemAt(i).width
      }
      else
      {
        var colDef = {};
        colDef = { "width" : headerRepeater.itemAt(i).width };
        mColumnDefs[colName] = colDef;
      }
    }

    console.log("new column defs: " + JSON.stringify(mColumnDefs));
    columnDefsReconstructed(mColumnDefs);
    updateUserDefs();
  }
  //-------------------------------------------------
  function updateUserDefs()
  {
    //    cb.save_to_userdefs(cb.get_project_name() + "_" + root.parentModule + "_" + root.objectName, JSON.stringify(mColumnDefs));
    console.log("updateUserDefs would be called with params " + cb.get_project_name() + "_" + root.parentModule + "_" + root.objectName, JSON.stringify(mColumnDefs));
  }
  //-------------------------------------------------

  function fixContentHeight()
  {
    table.contentHeight = tableModel.rowCount() * (root.rowHeight + table.rowSpacing);
  }
  //-------------------------------------------------
  //-------------------------------------------------
  function resetMultiselection()
  {
    if(sourceSelectionRows.length > 0)
      sourceSelectionRows.splice(0, sourceSelectionRows.length);
    if(multiSelectionRows.length > 0)
      multiSelectionRows.splice(0, multiSelectionRows.length);
    resetView();
  }
  //-------------------------------------------------
  //-------------------------------------------------
  //-------------------------------------------------
  //-------------------------------------------------
  //------------------------------------------------- Server interaction
}
