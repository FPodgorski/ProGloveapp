import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
  id: root
  objectName: "mattersNot"
  anchors.fill: parent

  property var images: [];
  property var m_imageModel: [];

  Rectangle {
    anchors.fill: parent
    color: "#161616"
    z: -1
  }

  Item {
    id: iFilters
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 305

    Column {
      anchors.fill: parent
      spacing: 15
      anchors.topMargin: 25
      anchors.leftMargin: 50
      anchors.rightMargin: 25

      CDTextInput {
        id: tiBrNaloga
        width: parent.width
        height: 75
        label: "SCI"
        textInput.onTextChanged: applyFilters()
      }

      CDTextInput {
        id: tiOdrediste
        width: parent.width
        height: 75
        label: "Odredište"
        textInput.onTextChanged:  applyFilters()
      }

      CDTextInput {
        id: tiNazivPrijevoznika
        width: parent.width
        height: 75
        label: "Prijevoznik"

        textInput.onTextChanged: {
          print("Event trigger " + textInput.text)
          applyFilters();
        }
      }

      Button {
        text: "Apply filters"
        visible: false
        height: 75
        width: 250
        onClicked: applyFilters()
      }
    }
  }

  function applyFilters() {
    var filters = [];
    var filter;

    if(tiBrNaloga.textInput.text != "") {
      filter = {"Name" : "BR_NALOGA_PRIJEVOZA", "Value" : tiBrNaloga.textInput.text, "Cond" : "LIKE"}
      filters.push(filter);
    }

    if(tiOdrediste.textInput.text != "") {
      filter = {"Name" : "ODREDISTE", "Value" :  tiOdrediste.textInput.text, "Cond" : "LIKE"}
      filters.push(filter);
    }

    if(tiNazivPrijevoznika.textInput.text != "") {
      filter = {"Name" : "NazivPrijevoznika", "Value" : tiNazivPrijevoznika.textInput.text , "Cond" : "LIKE"}
      filters.push(filter);
    }

    altTable.classicTable.activeFilters = filters;
    altTable.classicTable.refreshTable();
  }

  Item {
    id: iTable
    anchors.top: iFilters.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: iControls.top

    anchors.leftMargin: 50
    anchors.rightMargin: 50
    anchors.bottomMargin: 25

    CDAlternatingTable {
      id: altTable
      anchors.fill: parent


      // Izgled vertikale
      verticalHeaders:  ["BR_NALOGA_PRIJEVOZA", "ODREDISTE", "NazivPrijevoznika"]
      verticalTable.headerColumnWidths: [width * 0.25, width*0.25, width*0.5]
      verticalDetails: ["CREATED_AT", "DOC_DATE", "ID_OP_CHECK", "ID_UTOVARNOG_MJESTA", "IS_CHECKED", "NAZIV", "STATUS", "REG_OZN_VOZILA"]

      // DataSet
      tableName: "v_Ot_Nalog_Utovara_M"
      constFilters: [{"Name" : "Status", "Value" : "2", "Cond" : "!="}]

      // HC samo vertikalna
      classicTable.visible: false
      verticalTable.visible: true

      // Šminka
      verticalTable.detailsHeight: verticalTable.detailGridHeight
      verticalTable.maDetailsEnabled: true

      // Autoselect
      classicTable.onTableRefreshed: {
        var data = classicTable.m_tableModel.getData();
        if(data.length == 1) {
          verticalTable.selectRow(0);
        }
      }

      // Get data
      onTableSelected: {
        print("You've selected Nalog " + fieldByName(rowIndex, "BR_NALOGA_PRIJEVOZA"));
      }
    }
  }

  Item {
    id: iControls
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 25
    height: 75

    Button {
      height: parent.height

      width: parent.width * 0.5
      anchors.centerIn: parent
      text: enabled ? "Disable me" : "Enable me"

      highlighted: true
      Material.accent: "dodgerblue"
      font.pixelSize: 36

      enabled: altTable.hasSelection
    }
  }
}
