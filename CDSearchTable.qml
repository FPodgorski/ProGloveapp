//import Qt5Compat.GraphicalEffects
import QtGraphicalEffects 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item{
  id: root
  objectName: "root"
  property color mainColor: "#ff6b9a"
  property string filterColumnName : ""
  property var chooseAfilter:[]
  property var chosenFilter:JSON.parse(chooseAfilter)
  property var filterSpecificData:""
  property string tableName : ""
  property string sortColumnName : ""
  property string activeTransactionUID: ""
  property bool bReady: false
  property var selectedRow:""
  property var info:0
  property var stopAutocomplete:false
  property bool chosen:false

  property var duplicateAnswer:""
  property var isDuplicate:false
  property int labelFontSize:10
  property alias pop: pop
  property alias searchTable: searchTable
  property alias textEdit: textEdit

  property var filterParams: "{}"

  function selected(columnName){
    if(bReady==true)
    {
      return selectedRow[columnName]
    }
    else
    {
      return "";
    }
  }

  signal rowSelected(var rowData);

  onBReadyChanged: {

    if(bReady&&!stopAutocomplete) {
      pop.close()
      textEdit.text = selectedRow[filterColumnName]
      rowSelected(selectedRow);
      if(isDuplicate==true) {
        bReady=true
      }
    }
  }

  function testDataSet(){
    var temp = {};
    var finalFilterParams =[]

    // DynamicSelect filter
    temp["GroupID"] = "40456"; // ID Dijagrama
    temp["GroupUID"] = "{65702AF5-CF28-433C-A2A9-E994B2DBB2C9}"; // UID Dijagrama
    temp["FormName"] = cdBridge.mainFormName(); // Ime forme na kojoj se objekt nalazi
    temp["ObjectName"] = root.objectName; // Ime samog objekta kojega želimo osvježiti
    temp["QMLFunctionName"] = "reciveTableData"; // Ime funkcije koju želimo pozvati

    if(filterParams==""){
        filterParams = "{}";
    }
    var defaultparams = JSON.parse(filterParams,true);
    var additionalparams;
    finalFilterParams = [];
    if(filterParams!="{}")
      finalFilterParams.push(defaultparams);

    // Globalne varijable dijagrama



    var tmp_text = textEdit.displayText;
    tmp_text = tmp_text.replace('"', '')
    if(textEdit.displayText.length>0) {
      additionalparams = JSON.parse('{"Name":"'+filterColumnName+'", "Value":"%'+tmp_text + '%", "Cond": "Like"}');
    }
    else {
      additionalparams =JSON.parse('{"Name":"'+filterColumnName+'", "Value":"%", "Cond": "Like"}');
    }
    finalFilterParams.push(additionalparams);

    temp["TableName"] = tableName;
    temp["FilterParams"] = JSON.stringify(finalFilterParams);
    temp["OrderBy"] = sortColumnName;


    activeTransactionUID = cdBridge.call_diagram(temp);

    if(searchTable.rowCount<1&&nosee.visible==false)
      spinnyBoi.running= true;
  }

  function reciveTableData(args){
    if(activeTransactionUID == args["TUID"])
    {
      info= cb.parse_json(args["DataSet"])

      searchTable.setModel(args["DataSet"])

      spinnyBoi.running= false;

      const hasDuplicate = (info, filterColumnName) => {
        var hash = Object.create(null);
        return info.some((arr) => {
                           return arr[filterColumnName] && (hash[arr[filterColumnName]] || !(hash[arr[filterColumnName]] = true));
                         });
      };
      isDuplicate = hasDuplicate(info, filterColumnName);

      if(info.length==1){
        selectedRow = info[0];
        bReady=true
        stopAutocomplete=true

        if(textEdit.text != selectedRow[filterColumnName])
        {

          bReady=false
          pop.open();
          selectedRow=""
          duplicateAnswer=""
        }
        else{
          pop.close();
        }
      }
      else {

        if(textEdit.length==0){
          duplicateAnswer=""
        }
        selectedRow=duplicateAnswer
        stopAutocomplete=false

        if(isDuplicate==false){

          bReady = false;
          selectedRow=""
          duplicateAnswer=""
          pop.open();
          stopAutocomplete=false
        }
      }
    }
  }

  function autoFind(columnName,value){
    chosen=false
    filterColumnName=""
    textEdit.text=""


    chosen=true
    filterColumnName=columnName
    textEdit.text=value
    spinnyBoi.running=false
  }

  function resetData(){
    chosen=false
    filterColumnName=""
    textEdit.text=""
  }

  Rectangle {
    id: editContainer
    // anchors.left: parent.left
    // anchors.top: parent.top
    //  height: 100
    // width: 200
    anchors.fill: parent
    color: root.bReady ? Qt.darker(root.mainColor, 2.25) : "transparent"

    Item{
      id:flickableContainer
      // anchors.centerIn: parent
      anchors.fill: parent
      width:editContainer.width-12
      height: (textEdit.height/2)


      Flickable {
        id: problem
        anchors.fill: parent
        contentWidth: contentItem.childrenRect.width
        contentHeight: contentItem.childrenRect.height
        visible: !chosen
        focus: true

        Component.onCompleted: {
          problem.forceActiveFocus();
        }

        Keys.onLeftPressed: scrollBar.decrease()
        Keys.onRightPressed: scrollBar.increase()

        ScrollBar.horizontal: ScrollBar { id: scrollBar }
        clip: true
        z:-20


        MouseArea{
          anchors.fill: parent
          onWheel: {
            if(wheel.angleDelta.y>0){
              scrollBar.decrease()
            }
            else{
              scrollBar.increase()
            }
          }
        }

        Row {
          Repeater {
            model: chosenFilter.length
            Button {
              id:cuze
              width:{if(chosenFilter.length!==1&& labelFontSize<=15)
                  editContainer.width/chosenFilter.length
                else if(chosenFilter.length>2&& labelFontSize>15)
                  cuze.implicitWidth
                else if(chosenFilter.length==1)
                  editContainer.width-12}
              height:flickableContainer.height
              flat:true
              contentItem: Text {
                  text: chosenFilter[index]["label"]
                  font.pixelSize: labelFontSize
                  color:"white"
                  horizontalAlignment: Text.AlignHCenter
                  verticalAlignment: Text.AlignVCenter
                  wrapMode: Text.WordWrap
              }

              onClicked:{
                filterColumnName=chosenFilter[index]["columnName"]
                chosen=true
              }
            }
          }
        }
      }
    }

    TextField {
      id: textEdit
      visible:{if(chosen==true)
          true
        else
          false}
      color: "#ffffff"
      text:{
        ""
      }
      background: Rectangle {
        anchors.fill: parent
        color:"transparent"
        border.color:"transparent"
      }
      placeholderText: ""
      anchors.fill: parent
      font.pixelSize:12
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      focus: {if(chosen==true){
          timeout.start()
          pop.open()
          true
        }
        else{
          pop.close()
          false
        }
      }
      wrapMode: TextEdit.Wrap

      onAccepted: {
        if(pop.opened)
          pop.close();
      }

      onReleased:  {
        if(!pop.opened){
          pop.open();
        }
      }

      onActiveFocusChanged:{
        if(!activeFocus)
        {
          if(textEdit.text.length==0)
            chosen = false;

          if(pop.opened)
            pop.close();
        }
      }

      onPreeditTextChanged: {
        if(textEdit.text != selectedRow[filterColumnName])
        {
          bReady = false;
          selectedRow=""
        }
        timeout.stop()
        timeout.start();
      }


      Keys.onPressed: (event)=> {
                        if (event.key == Qt.Key_Backspace) {
                          stopAutocomplete=true;
                          duplicateAnswer=""
                        }
                        else if (event.key == Qt.Key_Delete) {
                          stopAutocomplete=true;
                          duplicateAnswer=""
                        }
                        else
                          stopAutocomplete=false
                      }


      onTextChanged: {
        preeditTextChanged(text);
      }
    }

    Rectangle{
      id:rek
      anchors.top: flickableContainer.bottom
      anchors.horizontalCenter: textEdit.horizontalCenter
      color:textEdit.focus?mainColor: Qt.darker(mainColor, 1.5)
      radius: 5
      height: 5
      anchors.topMargin: -18
      width: textEdit.width-15
    }

    Timer {
      id:timeout
      interval: 200;
      repeat:false
      onTriggered:{testDataSet()
      }
    }
  }


  Popup{
    id:pop
    x:rek.x
    y:rek.y
    width:dragQueen.x+45
    height:dragQueen.y+45
    background: Rectangle {
      anchors.fill: parent
      color: "transparent"
    }
    onClosed:{
      if(textEdit.text.length==0)
        chosen = false;
    }

    Rectangle{
      id:dragQueen
      width:30
      height:30
      color:"#80ff6b9a"
      x:500
      y:300
      radius: 3
      visible: false
      MouseArea {
        id:dragKlik
        anchors.fill: parent
        drag.target: dragQueen
        drag.axis: Drag.XAndYAxis
        drag.minimumX: 50
        drag.minimumY: 50
      }
    }

    CDTable_Qt5{
      id:searchTable
      objectName: "searchTable"
      anchors.fill: parent
      frameColor: mainColor
      darkMode: false
      bordColor: "Transparent"
      defaultCellColor:"Transparent"
      alternateCellColor: "transparent"
      fontColor:"#EAEAEA"
      backgroundColor: "#1c1c1c"
      selectionColor: mainColor
      clip: true

      function extraCellColorProvider(row, col) {
        if(searchTable.columnIndex(filterColumnName) == col)
          return mainColor;
      }

      onTableSelected: {
        stopAutocomplete=false
        duplicateAnswer=getRow(lastSelected)
        selectedRow = getRow(lastSelected);
        bReady=true
      }

      Text{
        id:nosee
        color:"white"
        anchors.centerIn: parent
        text:"NO EXISTING SEARCH RESULTS"
        font.pixelSize: 25
        visible:(searchTable.rowCount==0&&textEdit.text.length>0&&spinnyBoi.running==false)?true:false
      }

      BusyIndicator {
        id:spinnyBoi
        anchors.centerIn: parent
      }
    }
  }
}
