import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "CDCommTest.js" as COMM

Dialog{
    id:addDialog
    property var utovarUID:""
    property var rampaID:""
    property var reqMsg:""
    property var newUid:""
    width: parent.width/2
    height: parent.height/1.2
    implicitHeight: 800
    implicitWidth: 600



    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

  CDSearchTable_new{
      id:srchTbl
      anchors.fill: parent

      tableName: "V_OT_NALOG_UTOVARA_M"
      chooseAfilter: '[{"columnName":"BR_NALOGA_PRIJEVOZA", "label":"SCI"},{"columnName":"ODREDISTE", "label":"Odrediste"}]'


  }



}
