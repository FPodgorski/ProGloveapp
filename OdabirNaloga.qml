import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

import "CDCommTest.js" as COMM

//import "CDComponents"

//import "Inventura"
//import "Izdatnice"
//import "Otpremnice"
//import "Primke"
//import "Zaliha"
//import "Smjestajnica"
//import "GrupneRadneListe"


// ET51 2550 x 1600
// TC77 1280(1230) x 720

Item {
  id: root
  objectName: "maybeNotRoot"
  anchors.fill: parent

  property var images: [];
  property var m_imageModel: [];

  property var idutovar:"1"

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
      tableName: "v_Ot_Nalog_Utovara_M"

      verticalHeaders:  ["BR_NALOGA_PRIJEVOZA", "ODREDISTE", "NazivPrijevoznika"]
      classicTable.constFilters: [{"Name" : "Status", "Value" : "2", "Cond" : "!="}]

      classicTable.visible: false
      verticalTable.visible: true
      verticalTable.detailsHeight: verticalTable.detailGridHeight
      verticalTable.maDetailsEnabled: true
      verticalTable.headerColumnWidths: [width * 0.25, width*0.25, width*0.5]


      classicTable.onTableRefreshed: {
        var data = classicTable.m_tableModel.getData();
        if(data.length == 1) {
          verticalTable.expandedRows = [0];
        }
      }

      verticalTable.onRowExpanded: {
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
      text: "Odaberi utovarni nalog"

      highlighted: true
      Material.accent: "dodgerblue"
//      font.capitalization: Font.Normal
      font.pixelSize: 36

      enabled: altTable.verticalTable.expandedRows.length > 0
    }
  }

  Component.onCompleted: {
      COMM.http_Request(null, "GET", "SearchAktivanNalog","idutovar=" + idutovar, "", resp_GET_SearchAktivanNalog);

  }

  //poziv dijagrama (40598) GET SearchAktivanNalog

  function resp_GET_SearchAktivanNalog(response)
  {
          var success = response["success"];
          var message = response["message"];
          var data = response["data"];

          if(success === true)
          {
              print("resp_GET_SearchAktivanNalog: " + JSON.stringify(data));
          }
          else
          {
              print("resp_GET_SearchAktivanNalog: " + message);
          }
  }

}
