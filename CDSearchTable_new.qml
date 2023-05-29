//import Qt5Compat.GraphicalEffects
import QtGraphicalEffects 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
//import "CDCommTest2.js" as Comm
import "CDCommTest.js" as Comm

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
    property bool tableClicked:false
    property var selectedRow:""
    property var info: []
    property var stopAutocomplete:false
    property bool chosen:false
    property bool doNot:false
    property bool firstTime:false
    property var firstTimeUid:""

    property var duplicateAnswer:""
    property var isDuplicate:false
    property int labelFontSize:10
    property alias pop: pop
    property alias searchTable: searchTable
    property alias textEdit: textEdit
    property int noOfRecords: 0
    property var whereToShow:"left"
    property bool newVersion:true
    property bool findAuto:true
    property var findAutoInfo:[]
    property var oldVersionColumn:""
    property var oldVersionValue:""
    property var oldVersionShow:""
    property var avoidingAbug:[]
    property var popupContainerWidth:610
    property var popupContainerHeight:280
    property var filterParams: "{}"
    property var display:textEdit.displayText


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
            display = selectedRow[filterColumnName]
            rowSelected(selectedRow);
            if(isDuplicate==true) {
                bReady=true
            }
        }
    }

    function resp_GET_DynamicSelect(response)
    {
        if(doNot)
            return;

        var heder=""
        var success = response["success"];
        var message = response["message"];
        var data = response["data"];

        if(findAuto==true){
            findAutoInfo=response["data"]
            chosen=true
            display=findAutoInfo[0]["Naziv"];
            selectedRow = findAutoInfo[0];
            bReady=true
            stopAutocomplete=true
            chosen=true
        }

        info=response["data"]

        avoidingAbug=info[0]

        if(success === true)
        {
            for (let i = 0; i < data.length; i++) {
                heder=Object.keys(data[i])
                break;
            }

            searchTable.setHeader(heder);
            searchTable.setData(data)
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

                print(" TU netrebam TRENAM BIT ")

                pop.close()
                display = selectedRow[filterColumnName]
                rowSelected(selectedRow);

                if(display != selectedRow[filterColumnName])
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

            print(" ALLDONE ")
        }
        else
        {
            print("resp_GET_DynamicSelect: NEuspjeh " + message);
        }
    }



    function testDataSet(){
        if(doNot)
            return;

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

        if(JSON.stringify(defaultparams).includes("[")){
            finalFilterParams=defaultparams
        }

        if(!JSON.stringify(defaultparams).includes("[")){
            if(filterParams!="{}"){
                finalFilterParams.push(defaultparams);
            }
        }


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


        //'[{"Name":"Dobav", "Value":"1","Cond":"="},{"Name":"Kupac", "Value":"0","Cond":"="}, {"Name":"filterColumnName", "Value":"1","Cond":"="}]'

        temp["TableName"] = tableName;
        if(findAuto==false){
            temp["FilterParams"] = JSON.stringify(finalFilterParams);
        }
        else{
            temp["FilterParams"] ='{"Name":"'+oldVersionColumn+'", "Value":"'+oldVersionValue+'","Cond":"="}'
        }
        temp["OrderBy"] = sortColumnName;
        temp["NoOfRecords"]= noOfRecords;


        activeTransactionUID = cdBridge.call_diagram(temp);

        if(searchTable.rowCount<1&&nosee.visible==false)
            spinnyBoi.running= true;
    }

    function reciveTableData(args){
        if(activeTransactionUID == args["TUID"])
        {

            if(findAuto==true){
                findAutoInfo=cb.parse_json(args["DataSet"])

                chosen=true
                display=findAutoInfo[0]["Naziv"];
                selectedRow = findAutoInfo[0];
                bReady=true
                stopAutocomplete=true
                chosen=true
            }

            info=cb.parse_json(args["DataSet"])

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

                if(display != selectedRow[filterColumnName])
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

    function autoFind(columnName,value,showColumn){
        oldVersionColumn=columnName
        oldVersionValue=value
        oldVersionShow=showColumn
        findAuto=true
        timeout.stop()
        doNot=false
        chosen=false
        filterColumnName=""
        display=""
        spinnyBoi.running=false

        chosen=true
        filterColumnName=showColumn

        if(newVersion==true){
            Comm.http_Request(null, "GET", "DynamicSelect","TableName=" + tableName + "&FilterParams=" + '{"Name":"'+columnName+'", "Value":"'+value+'","Cond":"="}', "", resp_GET_DynamicSelect);
        }
        else{
            testDataSet()
        }
        pop.close()
        timeout.stop()

        if(value==""){
            resetData()
        }
        timeout.stop()
    }


    function resetData(){
        chosen=false
        filterColumnName=""
        display=""
    }

    Rectangle {
        id: editContainer
        // anchors.left: parent.left
        // anchors.top: parent.top
        //  height: 100
        // width: 200
        anchors.fill: parent
        color: root.bReady ? Qt.darker(root.mainColor, 2.25) : "transparent"


        Rectangle{
            id:popupContainer
            visible: {if(whereToShow=="top")
                    true
                else
                    false}
            objectName: "popupContainer"
            anchors.bottom: editContainer.top
            width: popupContainerWidth
            anchors.top: parent.top
            anchors.topMargin: -popupContainerHeight
            anchors.left:editContainer.left
            color:"transparent"
            z:8456
        }
        Rectangle{
            id:popupContainerLeft
            visible: {if(whereToShow=="left")
                    true
                else
                    false}
            objectName: "popupContainerLeft"
            width: popupContainerWidth
            anchors.right: editContainer.left
            height: popupContainerHeight
            anchors.bottom: editContainer.bottom
            color:"transparent"
            z:8456
        }
        Rectangle{
            id:popupContainerRight
            visible: {if(whereToShow=="left")
                    true
                else
                    false}
            objectName: "popupContainerRight"
            width: popupContainerWidth
            anchors.left: editContainer.right
            height: popupContainerHeight
            anchors.bottom: editContainer.bottom
            color:"transparent"
            z:8456
        }

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
                                doNot=false
                                findAuto=false

                                tableClicked=false
                                stopAutocomplete=false
                                duplicateAnswer=""
                                selectedRow =""
                                bReady=false

                                timeout.stop()
                                timeout.start()
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
                display
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
            focus: {if(chosen==true&&findAuto==false){
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
                    if(display.length==0)
                        chosen = false;

                    if(pop.opened)
                        pop.close();
                }
            }

            onPreeditTextChanged: {
               // display=display

                if(display != selectedRow[filterColumnName])
                { if(tableClicked!=true){
                        print("tu trebam bit")
                    bReady = false;
                    selectedRow=""
                    }
                }
                if(findAuto==false){
                    if(tableClicked!=true){
                        print("tu trebam bit također "+display)
                    timeout.stop()
                    timeout.start();
                   }
                }
            }


            Keys.onPressed: (event)=> {
                                if (event.key == Qt.Key_Backspace) {
                                    tableClicked=false
                                    stopAutocomplete=true;
                                    duplicateAnswer=""
                                }
                                else if (event.key == Qt.Key_Delete) {
                                    stopAutocomplete=true;
                                    tableClicked=false
                                    duplicateAnswer=""
                                }
                                else{
                                    stopAutocomplete=false
                                    findAuto=false
                                }
                            }


            onTextChanged: {
                preeditTextChanged(text);
            }

            Text {
                id:iks
                text: "\u0058"
                color: "#aaa"
                font.pixelSize: 15
                width:15
                height: 15
                anchors.right: parent.right
                anchors.rightMargin: 15
                visible: true//display
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height/3

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        tableClicked=false
                        display=""
                        chosen = false;
                        doNot=true
                        tableClicked=false
                        stopAutocomplete=false
                        duplicateAnswer=""
                        selectedRow =""
                        bReady=false
                    }
                }
            }


        }

        Rectangle{
            id:rek
            anchors.top: flickableContainer.bottom
            anchors.horizontalCenter: textEdit.horizontalCenter
            color:textEdit.focus?mainColor: Qt.darker(mainColor, 1.5)
            radius: 5
            height: 5
            width: textEdit.width-15
        }

        Timer {
            id:timeout
            interval: 200;
            repeat:false
            onTriggered:{
                if(newVersion==false){
                    testDataSet()
                }
                else{
                    var finalFilterParams=[]

                    if(filterParams==""){
                        filterParams = "{}";
                    }
                    var defaultparams = JSON.parse(filterParams,true);
                    var additionalparams;

                    if(JSON.stringify(defaultparams).includes("[")){
                        finalFilterParams=defaultparams
                    }

                    if(!JSON.stringify(defaultparams).includes("[")){
                        if(filterParams!="{}"){
                            finalFilterParams.push(defaultparams);
                        }
                    }

                    var tmp_text = display;
                    tmp_text = tmp_text.replace('"', '')
                    if(display.length>0) {
                        print("pun tekst ")
                        additionalparams = JSON.parse('{"Name":"'+filterColumnName+'", "Value":"%'+tmp_text + '%", "Cond": "Like"}');
                    }
                    else {
                        print("prazan tekst ")
                        additionalparams =JSON.parse('{"Name":"'+filterColumnName+'", "Value":"%", "Cond": "Like"}');
                    }
                    finalFilterParams.push(additionalparams);


                    Comm.http_Request(null, "GET", "DynamicSelect","TableName=" + tableName + "&FilterParams=" + JSON.stringify(finalFilterParams)+"&NoOfRecords="+ noOfRecords + "&OrderBy=" + sortColumnName, "", resp_GET_DynamicSelect);
                }
            }
        }
    }


    Popup{
        id:pop
        parent:{if(whereToShow=="top")
                popupContainer
            else if(whereToShow=="bottom")
                root
            else if(whereToShow=="left")
                popupContainerLeft
            else if(whereToShow=="right")
                popupContainerRight}
        x:{if(whereToShow=="bottom")
                rek.x
            else
                0}
        y:{if(whereToShow=="bottom")
                rek.y
            else
                0}
        width:{if(whereToShow=="top")
                popupContainer.width
            else if(whereToShow=="left")
                popupContainerLeft.width
            else if(whereToShow=="right")
                popupContainerRight.width
            else if(whereToShow=="bottom")
                dragQueen.x+45}
        height:{if(whereToShow=="top")
                popupContainer.height
            else if(whereToShow=="left")
                popupContainerLeft.height
            else if(whereToShow=="right")
                popupContainerRight.height
            else if(whereToShow=="bottom")
                dragQueen.y+45}
        background: Rectangle {
            anchors.fill: parent
            color: "transparent"
        }
        onClosed:{

            if(display.length==0){
                if(findAuto==false){
                    if(tableClicked!=true)
                       chosen = false;
                }
            }
        }
        Rectangle{
            id:dragQueen
            visible: {if(whereToShow=="bottom")
                    true
                else
                    false}
            width:30
            height:30
            color:"#80ff6b9a"
            x:500
            y:300
            radius: 3
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

            function extraCellColorProvider(row, col) {
                if(searchTable.columnIndex(filterColumnName) == col)
                    return mainColor;
                else
                    return "#222222"
            }

            onTableSelected: {
                tableClicked=true
                stopAutocomplete=false
                duplicateAnswer=getRow(lastSelected)
                selectedRow = getRow(lastSelected);
                bReady=true
//                pop.close()
//                display = selectedRow[filterColumnName]
//                rowSelected(selectedRow);
            }

            Text{
                id:nosee
                color:"white"
                anchors.centerIn: parent
                text:"NO EXISTING SEARCH RESULTS"
                font.pixelSize: 25
                visible:(searchTable.rowCount==0&&display.length>0&&spinnyBoi.running==false)?true:false
            }

            BusyIndicator {
                id:spinnyBoi
                anchors.centerIn: parent
            }
        }
    }
}
