import QtQuick 2.15
import QtQuick.Controls 2.15
//import Qt5Compat.GraphicalEffects
import QtGraphicalEffects 1.0
import TTableModel 1.0
import Qt.labs.qmlmodels 1.0

Item {
  id: root

  // Filtriranje
  property string tableName: "d_RadniNalog"
  property var activeFilters: []
  property var constFilters: []
  property string sortColumn: ""
  property string sortOrder: ""

  property alias contextMenu: contextMenu

  function krug_mali_colorProvider(row, column) {
    return color;
  }

  // Logic params
  property int lastSelected: selectedRow; property int cursor: selectedRow;
  property int selectedRow: -1;

  // Antialiasing
  property alias table: table
  property alias mColumnDefs: m_tableModel.mColumnDefs
  property alias choosers: choosers
  property alias krug_mali: krug_mali
  property alias m_tableModel: m_tableModel
  //  property alias r_krug_mali: r_krug_mali

  // UI Parameters
  property int radius: 12
  property int dRowHeight: 35
  property int columnSpacing: 0
  property int headerSpacing: 0
  property double darkFactor: 2.35
  property bool darkDierction: false
  property bool bAlternateRowColors: true

  property color gridColor: baseColor
  property color baseColor: "#171717"
  property color selectedColor: Qt.darker(baseColor, 1.35)
  property color rowColor: Qt.lighter(baseColor, 1.35)
  property color alternateRowColor: Qt.darker(baseColor, 1.35)
  property color highlightColor: "dodgerblue"

  // Signalisasija
  signal searchRequested(string colName, string keyword)
  signal fieldEdited (int column, int row, string value);

  signal headerEntered(string fieldName)
  signal headerExited(string fieldName)
  signal cellEntered(int rowIndex, string fieldName);
  signal cellExited(int rowIndex, string fieldName);
  signal rowPressAndHold(int rowIndex);
  signal headerPressAndHold(string fieldName);


  Gradient {
    id: highlightGradient
    orientation: Gradient.Vertical
    GradientStop {
      position: darkDierction ? 1 : 0
      color: baseColor
    }

    GradientStop {
      position: darkDierction ? 0 : 1
      color: Qt.darker(baseColor, darkFactor)
    }
  }

  focus: true

  MouseArea {
    anchors.fill: parent
    onClicked: {
      print("clicked")
//      root.forceActiveFocus();
    }
  }

  //-------------------------------
  // Key handling
  //-------------------------------
  signal rowSelected(var row);
  signal tableSelected(int rowIndex);
  signal tableUnselected(int rowIndex);
  property bool autoScrollToSelected: false
  //-------------------------------
  function selectRow(index) {
    if(selectedRow != index) {
      selectedRow = index;
      rowSelected(m_tableModel.getRow(index));
      tableSelected(index);
      if(autoScrollToSelected) {
//        table.positionViewAtRow(index, Qt.AlignVertical_Mask, -5 * root.dRowHeight);
      }

      table.forceLayout();
    }
    else {
      selectedRow = -1;
      tableUnselected(index);
    }
  }
  //-------------------------------
  function selectByValue(columnName, value) {
    for(var i = 0; i < table.rows; i++) {
      if(fieldByName(i, columnName) == value) {
        selectRow(i);
        return true;
      }
    }
    return false;
  }
  //-------------------------------
  function getRow(index) {
    return m_tableModel.getRow(index);
  }
  //-------------------------------
  Keys.onPressed: {
    var acc = true;

    if(event.key == Qt.Key_Escape)
      forceActiveFocus(false);
    else if(event.key == Qt.Key_Home)
      table.contentY = 0;
    else if (event.key == Qt.Key_End)
      table.contentY = table.contentHeight - table.height
    else if (event.key == Qt.Key_PageUp)
      handlePageUp();
    else if (event.key == Qt.Key_PageDown)
      handlePageDown();
    else if(event.key == Qt.Key_Up) {
      handleUpArrow();
    }
    else if(event.key == Qt.Key_Down) {
      handleDownArrow();
    }


    else
      acc = false;
    event.accepted = acc;
  }

  //-------------------------------
  function handleUpArrow() {
    if(selectedRow == 0 || selectedRow == -1)
      return;

    selectRow(selectedRow - 1);
  }
  function handleDownArrow() {
    if(selectedRow == table.rows - 1 || selectedRow == -1)
      return;

    selectRow(selectedRow + 1);
  }
  //-------------------------------
  property double pgFactor: 0.1;
  property int pgAmount: pgFactor * table.contentHeight

  function handlePageUp() {
    var testY = table.contentY - pgAmount;

    if(testY > 0)
      table.contentY = testY;
    else
      table.contentY = 0;
  }

  function handlePageDown() {
    var testY = table.contentY + pgAmount;

    if(table.contentHeight - testY > table.height)
      table.contentY = testY;
    else
      table.contentY = table.contentHeight - table.height
  }
  //-------------------------------
  //-------------------------------
  // Key handling


  Rectangle {
    id: rBackground
    radius: root.radius
    anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom;  anchors.right: parent.right;
    //    width: table.contentWidth < parent.width ? table.contentWidth : parent.width // ?? Bugged ako imam col sa < 50 width
    visible: table.columns > 0
    gradient: highlightGradient

    border.width: 2
    border.color: root.highlightColor

    Rectangle {
      id: rFrame
      anchors.fill: parent
      anchors.margins: 15
      color: root.gridColor
      z: 15
      clip: true
      gradient: highlightGradient

      property bool rounded: true
      property bool adapt: true
      layer.enabled: rounded
      radius: root.radius

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

      Item {
        anchors.fill: parent
        clip: true


        Item {
          id: iHeader
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          height: 54
          z: 200

          Rectangle {
            anchors.fill: parent
            color: "transparent"
            clip: true
          }

          Row {
            id: header
            width: table.contentWidth
            height: parent.height
            x: -table.contentX
            z: 1
            spacing: root.headerSpacing

            function forceLayout() {
              headerRepeater.model = 0
              headerRepeater.model = table.model.columnCount()
            }

            Repeater {
              id: headerRepeater
              model: table.columns

              delegate: TColumnHeading {
                initialWidth: m_tableModel.columnWidth(index); height: parent.height
                text: table.model.headerData(index, Qt.Horizontal)
                baseColor: "transparent"//root.rowColor;
                label.x: 12
                label.wrapMode: Text.WordWrap

                //* QuickFix hover events *//

                tap.hoverEnabled: true
                tap.onEntered: root.headerEntered(text)
                tap.onExited: root.headerExited(text)

                label.color: {
                  for(var i = 0; i < activeFilters.length; i++) {
                    if(activeFilters[i]["Name"] == text)
                      return root.highlightColor;
                  }
                  return "gray"
                }
                tiSearchBox.text: {
                  for(var i = 0; i < activeFilters.length; i++) {
                    if(activeFilters[i]["Name"] == text) {
                      return activeFilters[i]["Value"];
                    }
                  }
                  return ""
                }


                state: {
                  if(m_tableModel.columnName(index) != root.sortColumn) // !m_tableModel.m_header[index]["ColumnName"] == root.sortColumn
                    return "";
                  else {
                    if(root.sortOrder == "asc")
                      return "up"
                    else
                      return "down"
                  }
                }

                onSearchRequested: {
                  var colName = columnName(column);
                  print("onSearchRequest with colName = " + colName + " and keyword = " + keyword);
                  //                  callFilterDiag(colName, keyword);

                  modifyFilter(colName, keyword);
                  refreshTable();
                }

                onSortRequested: {
                  var colName = columnName(column);
                  var sortMember = {};

                  if(state != "") {
                    var sortWord = "desc"
                    if(state == "up")
                      sortWord = "asc"

                    sortColumn = colName;
                    sortOrder = sortWord;
                  }
                  else {
                    sortColumn = "";
                    sortOrder = "";
                  }
                  refreshTable();
                }

                onSearchClosed: {
                  //                  root.forceActiveFocus();
                }

                tap.onPressAndHold: {                  
                  headerCtxMenu.colName = columnName(index);
                  headerCtxMenu.open();
                  root.headerPressAndHold(text);
                }

                onDropped: function (x) {
                  m_tableModel.reorderColumn(index, x);
                  header.forceLayout();
                }
                onHeaderResized: function (width) {
                  m_tableModel.resizeColumn(index, width);
                }
                onRightClicked: {
                  headerCtxMenu.colName = columnName(index);
                  headerCtxMenu.open();
                }

                Menu {
                  id: headerCtxMenu
                  property string colName: ""
                  MenuItem {
                    id: miClearFilter
                    text: "Clear filter"

                    enabled: activeFilters.some( item => item["Name"] ==  headerCtxMenu.colName)
                    height: enabled ? implicitHeight: 0

                    onTriggered: {
                      for (var i = 0; i < activeFilters.length; i++) {
                        if(activeFilters[i]["Name"] == headerCtxMenu.colName) {
                          activeFilters.splice(i, 1);
                          activeFilters = activeFilters;
                          refreshTable();
                          return;
                        }
                      }
                    }
                  }
                  MenuItem {
                    id: miEditColumns
                    text: "Edit columns"
                    onTriggered:  {
                      editColsDg.open()
                    }
                  }
                  MenuItem {
                    id: miPrintColumns
                    text: "Print columns"
                    onTriggered: {
                      print("header = " + JSON.stringify(m_tableModel.m_header));
                    }
                  }
                }
              }
            }
          }
        }

        Rectangle { // Literally separator između tablice i headera koji blokira random table content scrollanje
          id: hSeparator
          width: parent.width
          anchors.top: iHeader.bottom
          height: 2
          color: "#464646"
          z: 199
        }


        Flickable {
          clip: true

          z: -1
          anchors.topMargin: 5
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: hSeparator.bottom
          anchors.bottom: parent.bottom
//          enabled: false
//          visible: false

          contentY: table.contentY
          //          contentX: table.contentX


          Column {

            anchors.fill: parent
            spacing : 5
            Repeater {
              id: tableRows
              z: 0
              clip: true
              model: table.rows

              delegate: Rectangle {
                id: rowDel
                height: root.dRowHeight;
                width: table.contentWidth
                color: root.bAlternateRowColors ? (index % 2 ? rowColor : alternateRowColor) : root.rowColor
                border.width: index == lastSelected ? 2 : 0
                border.color: root.highlightColor;

                radius: 5
              }
            }
          }
        }

        TableView {
          id: table
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: hSeparator.bottom
          anchors.bottom: parent.bottom
          anchors.topMargin: rowSpacing
          z: 2
          clip: true

          ScrollBar.vertical: ScrollBar {
            active: true
          }
          boundsBehavior: Flickable.StopAtBounds
          columnSpacing: root.columnSpacing
          rowSpacing: 5

          columnWidthProvider: function(column) {
            return headerRepeater.itemAt(column).width
          }

          rowHeightProvider: function (row) {
            return root.dRowHeight;
          }

          model: m_tableModel


          Timer {
            id: hehe
            running: false; repeat: false; interval: 1;
            onTriggered: {
              print("hehe")
              table.forceLayout();
            }
          }

          delegate: DelegateChooser {
            id: choosers
            role: "delegateChoice"
            DelegateChoice {
              roleValue: ""

              Item {
                clip: true
                z: column

                Item {
                  anchors.top: parent.top
                  anchors.left: parent.left
                  anchors.right: parent.right
                  height: root.dRowHeight

                  TextInput {
                    id:information
                    anchors.fill: parent
                    anchors.leftMargin: 5
                    text: display
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    enabled: m_tableModel.getHeader()[column]["Editable"] == true


                    onTextEdited: {

                    }

                    onEditingFinished: {
                      print("column " + column)
                      print("finished " + JSON.stringify(mColumnDefs))
                      fieldEdited(column, row, information.text);
                    }

                    onAccepted: {
                      // Gazim model
                    }
                  }

                  MouseArea {
                    anchors.fill: parent
                    z: 1
                    enabled: !m_tableModel.getHeader()[column]["Editable"]
                    acceptedButtons: Qt.RightButton | Qt.LeftButton
                    hoverEnabled: true

                    onEntered: root.cellEntered(row, information.text)
                    onExited:  root.cellExited(row, information.text)
                    onPressAndHold: root.rowPressAndHold(row)

                    onReleased: {
                      if(mouse.button == Qt.RightButton)
                        tableRightClick(row, column);
                      else
                        selectRow(row);
                    }
                  }
                }
              }
            }
            DelegateChoice {
              id: krug_mali
              roleValue: "krug_mali"

              Item {
                id: i_krug_mali
                Rectangle {
                  id: r_krug_mali
                  width: 15
                  height: 15
                  radius: height
                  color: krug_mali_colorProvider(row, column)
                  anchors.centerIn: parent

                  MouseArea {
                    anchors.fill: parent
                    onClicked: {
                      lastSelected = row;
                    }
                  }

                  Rectangle {
                    anchors.fill: parent
                    radius: height
                    gradient: Gradient {
                      GradientStop {
                        position: 0
                        color: "#42000000"
                      }
                      GradientStop {
                        position: 1
                        color: "#04000000"
                      }
                    }
                  }
                }
              }
            }
            DelegateChoice {
              roleValue: "checkDg"

              Item {
                CheckDelegate {
                  anchors.top: parent.top
                  anchors.left: parent.left
                  anchors.right: parent.right
                  height: root.dRowHeight
                  onCheckedChanged: {
                    selectRow(row)
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  //-------------------------------------------------
  //-------------------------------------------------
  //-------------------------------------------------
  RectangularGlow {
    id: effect
    anchors.fill: rBackground
    glowRadius: 0
    spread: 0.5
    color: root.highlightColor
    cornerRadius: rBackground.radius + glowRadius
    z: -1
    visible: table.columns > 0

    SequentialAnimation {
      id: tableRefreshAnimation
      property int totalDur: 250

      NumberAnimation { target: effect; property: "glowRadius"; to: 13; duration: tableRefreshAnimation.totalDur / 2 }
      NumberAnimation { target: effect; property: "glowRadius"; to: 0; duration: tableRefreshAnimation.totalDur / 2 ; }
    }
  }
  //-------------------------------------------------

  Dialog {
    id: filterDialog
    width: 500
    height: 300

    contentItem: Rectangle {
      anchors.fill: parent
      color: "pink"
    }
  }

  Dialog {
    id: editColsDg
    width: 500
    height: 500
    anchors.centerIn: parent
    clip: true;

    property var editHeader: []

    onOpened: {
      editHeader = m_tableModel.m_header
    }


    contentItem: Item {
      anchors.fill: parent
      clip: true
      GridView {
        id: editColsGrid
        anchors.fill: parent
        model: editColsDg.editHeader.length
        //        spacing: 15
        cellWidth: parent.width / 2
        cellHeight: 50

        delegate: CheckDelegate {
          height: editColsGrid.cellHeight
          width: editColsGrid.cellWidth
          text: editColsDg.editHeader[index]["ColumnName"]
          checked: editColsDg.editHeader[index]["Visible"]
          onCheckedChanged: editColsDg.editHeader[index]["Visible"] = checked;
        }
      }
    }

    standardButtons: Dialog.Cancel | Dialog.Ok

    onAccepted: {
      m_tableModel.setHeader(editColsDg.editHeader);
      //      table.forceLayout();
      trialByForce();
    }
  }


  Timer {
    id: setModelTimer
    interval: 25
    onTriggered: {
      header.forceLayout();
      table.forceLayout();
    }
  }

  function setModel(jsonString) { // JSONQUERYMODEL
    return;
    m_tableModel.setJsonQueryData(jsonString);

    setModelTimer.start();

    if(!tableRefreshAnimation.running)
      tableRefreshAnimation.start();
  }

  function setBasicModel(header, data) {
    m_tableModel.setBasicModel(header, data);

    setModelTimer.start();

    if(!tableRefreshAnimation.running)
      tableRefreshAnimation.start();

    tableRefreshed();
  }

  signal tableRefreshed();

  function setBasicHeader(columnList) {
    m_tableModel.setBasicHeader(columnList);
  }

  function setData(data) {
    m_tableModel.setJson(data);
    setModelTimer.start();
  }

  function setHeader(header) {
    m_tableModel.setHeader(header);
    setModelTimer.start();
  }

  function columnName(index) {
    return m_tableModel.columnName(index);
  }

  function columnIndex(columnName) {
    return m_tableModel.columnIndex(columnName)
  }

  function trialByForce() {
    table.forceLayout();
    header.forceLayout();
  }

  function hardReset() {
    m_tableModel.hardReset();
  }

  signal rowClicked(int row);

  onRowClicked: {
    selectedRow = row;
//    root.forceActiveFocus();
  }

  PropertyAnimation{
    id: widthChanger
    target: root
    property: "width"
    from: 0
    to: 0
    duration: 75
    onStopped: {
      nrButtons--;
    }
  }

  TTableModel {
    id: m_tableModel

    onColumnOrderChanged: {
      hehe.start();
    }
  }

  function setExplicitModel(model) {
    setHeader(model.getHeader());
    setData(model.getJson());

  }

  property bool autoInitRefresh: true
  Component.onCompleted: {

    if(autoInitRefresh) {
      print("cdBridge.getDataConnServerUrl() = "  + cdBridge.getDataConnServerUrl())
      request(cdBridge.getDataConnServerUrl() + "/DynamicSelect", receiveFilterFunction,
              "TableName=" + tableName +
              "&FilterParams=" + JSON.stringify(constFilters) +
              "&OrderBy=" + sortColumn + " " + sortOrder);
    }
  }
  //-------------------------------------------------
  function request(url, callback, params) {

    var xhr = new XMLHttpRequest();

    xhr.onreadystatechange = (function(myxhr) {
      return function() {
        if(myxhr.readyState === 4) { callback(myxhr); }
      }
    })(xhr);

    xhr.open("GET", url+"?"+params);
    var user="nikolak"
    var pass="123"
    xhr.setRequestHeader('Content-type', 'application/json');
    xhr.setRequestHeader( 'Authorization', 'Basic ' +  Qt.btoa( user + ':' + pass )  );
    xhr.withCredentials = true;
    xhr.send();
  }
  //-------------------------------------------------
  // Procedura za poslati request po trenutnim stanjima filtera
  //-------------------------------------------------
  function refreshTable() {
    var sParams = 'TableName=' + root.tableName + '&FilterParams=';
    var params = [];

    // Push constFilters
    var newParam = {};
    for(var i = 0; i < constFilters.length; i++) {
      newParam = {"Name": constFilters[i]["Name"],
        "Cond": constFilters[i]["Cond"]};

      if(newParam["Cond"].toUpperCase() == "LIKE")
        newParam["Value"] = "%" + constFilters[i]["Value"] + "%";
      else
        newParam["Value"] = constFilters[i]["Value"];

      params.push(newParam);
    }

    // Push userFilters
    for(var i = 0; i < activeFilters.length; i++) {
      newParam = {"Name": activeFilters[i]["Name"],
        "Cond": activeFilters[i]["Cond"]};


      if(newParam["Cond"].toUpperCase() == "LIKE")
        newParam["Value"] = "%" + activeFilters[i]["Value"] + "%";
      else
        newParam["Value"] = activeFilters[i]["Value"];

      params.push(newParam);
    }
    sParams += JSON.stringify(params);


    if(sortColumn != "")
      sParams += "&OrderBy=" + root.sortColumn + " " + root.sortOrder;


    print("Calling dynamicSelect with params = " + sParams);


    request(cdBridge.getDataConnServerUrl() + "/DynamicSelect", receiveFilterFunction, sParams);
  }
  //-------------------------------------------------
  function modifyFilter (colName, keyword) {

    print("modifyFilter called");
    var dex = activeFilters.findIndex( item => item["Name"] == colName);
    if(dex >= 0) {
      if(keyword != "")
        activeFilters[dex]["Value"] = keyword;
      else
        activeFilters.splice(dex, 1);
    }

    else {
      var newParam = {"Name":colName, "Value": keyword, "Cond":"Like"};
      activeFilters.push(newParam);
    }

    print("activeFilters = " + JSON.stringify(activeFilters));
  }
  //-------------------------------------------------
  function callFilterDiag (colName, keyword) {

    var sParams = 'TableName=' + root.tableName + '&FilterParams=';
    var params = [];

    // Provjera da li imma već aktivan filter na tom columnu?
    var bActiveFilter = false;
    for (var i = 0; i < activeFilters.length; i++) {
      if(activeFilters[i]["Name"] == colName) {
        activeFilters[i]["Value"] = keyword
        bActiveFilter = true;
      }
    }

    if(!bActiveFilter) {
      var newParam = {"Name":colName, "Value": keyword, "Cond":"Like"};
      activeFilters.push(newParam);
    }

    // Push constFilters
    for(var i = 0; i < constFilters.length; i++) {
      newParam = {"Name": constFilters[i]["Name"],
        "Cond": constFilters[i]["Cond"]};

      if(newParam["Cond"].toUpperCase() == "LIKE")
        newParam["Value"] = "%" + constFilters[i]["Value"] + "%";
      else
        newParam["Value"] = constFilters[i]["Value"];

      params.push(newParam);
    }

    // Push userFilters
    for(var i = 0; i < activeFilters.length; i++) {
      newParam = {"Name": activeFilters[i]["Name"],
        "Cond": activeFilters[i]["Cond"]};


      if(newParam["Cond"].toUpperCase() == "LIKE")
        newParam["Value"] = "%" + activeFilters[i]["Value"] + "%";
      else
        newParam["Value"] = activeFilters[i]["Value"];

      params.push(newParam);
    }

    sParams += JSON.stringify(params);

    print("Calling dynamicSelect with params = " + sParams);
    request(cdBridge.getDataConnServerUrl() + "/DynamicSelect", receiveFilterFunction, sParams);
  }
  //-------------------------------------------------
  function receiveFilterFunction(o) {
    console.log(o.status);
    if (o.status >= 200 && o.status <300) {

      var rows = JSON.parse(o["responseText"])["data"];
      if(rows.length > 0) {
        var row = rows[0];
        var columns = Object.keys(row);
        setBasicModel(columns, JSON.parse(o["responseText"])["data"]);
      }
      else {
        setBasicModel([], {});
      }
    }
    else {
      console.log("receiveFilterFunction Some error has occurred");
      console.log(o.responseText);
    }
  }
  // --------------------------------------------- Filtriranje
  Menu {
    id: contextMenu
    property int itemHeight: 40


    MenuItem {
      id: miRefeshTable
      text: "Refresh"
      onTriggered: {
        refreshTable();
      }
    }

    MenuItem {
      text: "Copy cell"
      onTriggered: {
        var value = "";
        if(root.copyColumn >= 0 && root.copyRow >= 0) {
          value = fieldByName(copyRow, columnName(copyColumn));
          cb.copy_to_clipboard(value);
        }
      }
    }
    MenuItem {
      id: miExportCsv
      text: "Export as .csv"
      onTriggered: {
      }
    }
  }
  //-------------------------------------------------
  function fieldByName(iRow, sFieldName) {
    return m_tableModel.fieldByName(iRow, sFieldName);
  }
  //-------------------------------------------------
  property int copyRow; property int copyColumn;
  //-------------------------------------------------
  function tableRightClick(row, column)
  {
    copyRow = row;
    copyColumn = column;
    contextMenu.popup();
  }
}
