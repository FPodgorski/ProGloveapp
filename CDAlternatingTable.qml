import QtQuick 2.0

Item {
  anchors.fill: parent
  id: root

  property alias verticalTable: verticalTable
  property alias classicTable: classicTable

  property string tableName: ""

  property var verticalHeaders: []
  property var verticalDetails: []
  property var constFilters: []
  property var activeFilters: []
  property var selectedRows: []
  property bool hasSelection: selectedRows.length > 0

  property bool autoInitRefresh: true

  onSelectedRowsChanged: {
    print("selectedRows are now = " + JSON.stringify(selectedRows));
  }

  // Signals
  signal tableRefreshed();
  signal tableSelected(int rowIndex);
  signal tableUnselected(int rowIndex);

  signal headerEntered(string fieldName);
  signal headerExited(string fieldName);

  signal cellEntered(int rowIndex, string fieldName);
  signal cellExited(int rowIndex, string fieldName);

  signal rowPressAndHold(int rowIndex);
  signal headerPressAndHold(string fieldName);

  // Single selection za sad
  onTableSelected: {
    selectedRows = [rowIndex];
  }

  onTableRefreshed: {
    selectedRows = [];
  }

  onTableUnselected: {
    selectedRows = [];
  }

  Component.onCompleted: {
    if(autoInitRefresh)
      classicTable.refreshTable();
  }

  function refreshTable() {
    classicTable.refreshTable();
  }

  function fieldByName(rowIndex, fieldName) {
    print("AltTable fbn called with rowIndex = " + rowIndex + " and fieldName = " + fieldName)
    return classicTable.fieldByName(rowIndex, fieldName);
  }

  function selected(fieldName) {
    return classicTable.fieldByName(selectedRows[0], fieldName);
  }

  Item {
    id: loaderItem
    anchors.fill: parent

    CDVerticalTable {
      id: verticalTable
      anchors.fill: parent
      visible: loaderItem.width < 800 // Defaultni changeover condition
      leadingHeaders: verticalHeaders
      detailFields: root.verticalDetails
      onTableRightClick: classicTable.contextMenu.popup();

      onRowPressAndHold: root.rowPressAndHold(rowIndex)
      onHeaderEntered: root.headerEntered(fieldName)
      onHeaderExited: root.headerExited(fieldName)
      onHeaderPressAndHold: root.headerPressAndHold(fieldName)

      onCellEntered: root.cellEntered(rowIndex, fieldName)
      onCellExited: root.cellExited(rowIndex, fieldName)

      onRowExpanded: {
        root.tableSelected(rowIndex)
      }
      onRowShrunk:  {
        root.tableUnselected(rowIndex);
      }
    }

    CDBTable {
      id: classicTable
      anchors.fill: parent
      visible: !verticalTable.visible
      tableName: root.tableName

      autoInitRefresh: root.autoInitRefresh

      onHeaderEntered: root.headerEntered(fieldName)
      onHeaderExited: root.headerExited(fieldName)
      onHeaderPressAndHold: root.headerPressAndHold(fieldName)

      onCellEntered: root.cellEntered(rowIndex, fieldName)
      onCellExited: root.cellExited(rowIndex, fieldName)

      constFilters: root.constFilters
      activeFilters: root.activeFilters

      onTableSelected: {
        root.tableSelected(rowIndex)
      }

      onTableUnselected: {
        root.tableUnselected(rowIndex);
      }

      onTableRefreshed: {
        verticalTable.setBasicModel(m_tableModel.getData());
        root.tableRefreshed();
      }
    }
  }
}
