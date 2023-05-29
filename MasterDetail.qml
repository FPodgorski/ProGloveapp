import QtQuick 2.0
import QtQuick.Layouts 1.15

Item {
    id:root
    anchors.fill:parent
    Rectangle{
        anchors.fill:parent
        color:"#31302d"
        Item{
            id:header
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.top:parent.top
            height:200
            CDButton{
                id:but1
                anchors.right:parent.horizontalCenter
                anchors.top:parent.top
                anchors.topMargin: parent.height*0.1

                width:200
                height:100
                text:"tab1"
                onClick:{
                    tabLayout.currentIndex=0
                }
            }
            CDButton{
                id:but2
                anchors.left:but1.right
                anchors.top:parent.top
                anchors.topMargin: parent.height*0.1
                width:200
                height:100
                text:"tab2"
                onClick:{
                    tabLayout.currentIndex=1
                }
            }
        }
        Item{
            id:content
            anchors.top:header.bottom
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom:parent.bottom
            StackLayout {
                id: tabLayout
                anchors.fill: parent
                currentIndex:0
                Item{
                    id:tab1
                    anchors.fill: parent
                    Rectangle{
                        anchors.fill:parent
                        color:"yellow"
                        CDBTable{
                            id:table1
                            anchors.fill:parent
                        }
                    }
                }
                Item{
                    id:tab2
                    anchors.fill: parent
                    Rectangle{
                        anchors.fill:parent
                        color:"green"

                    }
                }
            }
        }
    }
}
