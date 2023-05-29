import QtQuick 2.0

//import "../CDComponents"


CDGenericDialog {
  id: newMasterDialog
  height: 650
  width: 550
  property string intent: "new"

  property alias dpNewMaster: dpNewMaster
  property alias tiNapomena: tiNapomena
  property alias stPartnerOtpremnice: stPartnerOtpremnice

  Item {
    parent: newMasterDialog.iContent
    anchors.fill: parent

    CDDatePicker {
      id: dpNewMaster
      width: 200
      height: 75


      iCalHolder.width: 450
      iCalHolder.height: 350
      iCalHolder.anchors.top: parent.top


      anchors.top: parent.top
      anchors.topMargin: 25
      anchors.horizontalCenter: parent.horizontalCenter
      z: 1

      txtHeader.color: "white"
      txtHeader.text: "Datum inventure"

      bDatePicker.txtText.font.pixelSize: 25
    }


    Item {
      id: iKupac
      anchors.topMargin: 25
      height: 120
      anchors.top: dpNewMaster.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      CDSearchTable_new {
        id: stPartnerOtpremnice
        objectName: "stPartnerOtpremnice"
        anchors.centerIn: parent
        width: 320
        height: 80

        tableName: "i_Tvrtke"
        sortColumnName: "Naziv"

        mainColor: highlightColor

        chooseAfilter: '[{"columnName":"Naziv", "label":"Kupac"}]'
        filterParams: '{"Name" : "Sp", "Value" : "1", "Cond" : "="}'
        labelFontSize: 32

        textEdit.font.pointSize: 32
        searchTable.headerHeight:35
        searchTable.defaultColWidth: searchTable.width / 2

        searchTable.visualPreset: "hdpi"
        searchTable.stylePreset: "dark"
      }
    }


    CDTextField {
      id: tfNapomena      
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: iKupac.bottom
      anchors.bottom: parent.bottom
      anchors.topMargin: 25

      txtHeader.text: "Napomena"
      txtValue.text: ""

      txtHeader.font.pixelSize: 18
      txtHeader.anchors.margins: 5

      rHeader.height: 40
      z: 0

      TextInput {
        id: tiNapomena
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        anchors.fill: parent
        anchors.topMargin: tfNapomena.rHeader.height
        font.pixelSize: 36
        color: "white"
      }
    }
  }
}

