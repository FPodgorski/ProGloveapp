#include "CppBridge.h"
#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QDesktopServices>

#include <QtGui>

//---------------------------------------------------------------------------
TCppBridge::TCppBridge()
{
  sQtInstallDir = "Q:/Qt/Tools/QtCreator/bin/qtcreator.exe";
  bAdminMode = false;
}
//---------------------------------------------------------------------------
void TCppBridge::test_if_bridgable()
{
  qDebug() << "TCppBridge|Yep, 'tis invokable";
}
//---------------------------------------------------------------------------
void TCppBridge::setTranslations(QJsonObject o)
{
  oTranslations = o;
  emit changeOfTranslation();
}
//---------------------------------------------------------------------------
QJsonObject TCppBridge::getTheTranslationChange()
{
  return oTranslations;
}
//---------------------------------------------------------------------------
void TCppBridge::setMainWindow(class MainWindow* ref)
{
  mwRef = ref;


  connect(this, SIGNAL(dialogSignal(QStringList)), mwRef, SLOT(dialogSlot(QStringList)));
  connect(this, SIGNAL(transactionSignal(QMap<QString, QString>)),
          mwRef, SLOT(transactionSlot(QMap<QString, QString>)) );


  connect(this, SIGNAL(permissionSignal(QMap<QString, QString>)), mwRef, SLOT(permissionSlot(QMap<QString, QString>)));


  // DODAJ HENDLANJE NEKAKO, iz droid i win mainwindow h mora bit isti bool
  if(!mwRef->sSerialPort.isEmpty())
  {
    connect(mwRef->getSerialThread(), SIGNAL(serialThreadRead(QString, QString)), this, SLOT(serialInputCaught(QString, QString)));
  }


  QString sIniPath = mwRef->getIniPath();
  QSettings settings(sIniPath, QSettings::IniFormat);

  LogQueue = &mwRef->LogQueue;


  settings.beginGroup("Client");
  sDeviceName = settings.value("DeviceName").toString();
  settings.endGroup();


  settings.beginGroup("ProductionDef");
  const QStringList childKeys = settings.childKeys();
  QStringList values;
  foreach (const QString &childKey, childKeys)
    values << settings.value(childKey).toString();

  sAddress = settings.value("Address").toString();
  sPort = settings.value("Port").toString();

  settings.endGroup();

  settings.beginGroup("VersioningDef");

  sVersioningAddress = settings.value("Address").toString();
  sVersioningPort = settings.value("Port").toString();


  settings.endGroup();
}
//---------------------------------------------------------------------------
void TCppBridge::testMainWindow()
{
  qDebug()<< "mwRef->getDeviceID() = " + mwRef->getDeviceID();
}
//---------------------------------------------------------------------------
QString TCppBridge::call_diagram(QJsonObject jsonObject) // Object Keywords: GroupID, FormName, ObjectName, ModelType, Callback
{
  QVariantMap mVarParams = jsonObject.toVariantMap();

  QString sTransUID = QUuid::createUuid().toString();
  QString sSender = mwRef->getDeviceID();

  QString sXML = load_from_file(":/DiagramsTemplate.xml");;

  //----------------------------------------------------------------------------------------

  QDomDocument xmldoc;
  xmldoc.setContent(sXML);

  QMap<QString, QString> mParams;

  for(int i = 0; i < mVarParams.count(); i++)
  {
    QString sKey = mVarParams.keys()[i];
    QString sValue = mVarParams.values()[i].toString();

    mParams.insert(sKey, sValue);
  }

  QString sGroupID = mParams["GroupID"];
  QString sFormName = mParams["FormName"];
  QString sObjectName = mParams["ObjectName"];
  QString sModelType = mParams["ModelType"];
  QString sCallback = mParams["Callback"];
  QString sCallbackObject = mParams["CallbackObject"];
  QString sCallbackForm = mParams["CallbackForm"];
  QString sQMLFunctionName = mParams["QMLFunctionName"];
  QString sLoginType = mParams["LoginType"];


  QString sGroupUID = mParams["GroupUID"];


  set_node_value(xmldoc, "Root/Header/Group", sGroupID);
  set_node_value(xmldoc, "Root/Header/Sender", sSender);
  set_node_value(xmldoc, "Root/Header/GroupUID", sGroupUID);
  QDomElement nOutput = xmldoc.documentElement().firstChildElement("GVars");

  QStringList slKeys = mParams.keys();
  for(int i = 0; i < slKeys.count(); i++)
  {
    if(slKeys[i] != "CallbackForm" && slKeys[i] != "CallbackObject" &&
       slKeys[i] != "GroupID" && slKeys[i] != "FormName" &&
       slKeys[i] != "ObjectName" && slKeys[i] != "ModelType" &&
       slKeys[i] != "Callback" && slKeys[i] != "GroupUID" &&
       slKeys[i] != "QMLFunctionName" && slKeys[i] != "LoginType")
    {



      if(slKeys[i] == "Raw")
      {

        QDomElement newNode = xmldoc.createElement(slKeys[i]);
        QDomCDATASection sec = xmldoc.createCDATASection(mParams[slKeys[i]]);
        newNode.appendChild(sec);
        nOutput.appendChild(newNode);

      }
      else{
        QDomElement newNode = xmldoc.createElement(slKeys[i]);
        QDomText newNodeText = xmldoc.createTextNode(mParams[slKeys[i]]);
        newNode.appendChild(newNodeText);
        nOutput.appendChild(newNode);

      }


    }
  }

  if(sFormName != "" && sObjectName != "")
  {
    set_node_value(xmldoc, "Root/Header/TUID", sTransUID);


    //      if(sCallbackForm.isEmpty())
    //      {
    //        sCallbackForm = mwRef->getMainForm()->objectName();
    //      }

    //      if(sCallbackObject.isEmpty())
    //      {
    //        sCallbackObject = "root";
    //      }


    QMap<QString, QString> tParams;
    tParams["TUID"] = sTransUID;
    tParams["FormName"] = sFormName;
    tParams["ObjectName"] = sObjectName;
    tParams["ModelType"] = sModelType;
    tParams["Callback"] = sCallback;
    tParams["CallbackObject"] = sCallbackObject;
    tParams["CallbackForm"] = sCallbackForm;
    tParams["QMLFunctionName"] = sQMLFunctionName;

    emit(transactionSignal(tParams));
  }


  TTCPClientWrap client;
  client.post(sAddress, sPort, xmldoc.toString());

  qDebug() << "TCppBridge| call_diagram sending xml with TUID " << sTransUID;

  return sTransUID;
}


//---------------------------------------------------------------------------
QString TCppBridge::call_diagramV(QJsonObject jsonObject, bool bVersioning) // Object Keywords: GroupID, FormName, ObjectName, ModelType, Callback
{
  QVariantMap mVarParams = jsonObject.toVariantMap();

  QString sTransUID = QUuid::createUuid().toString();
  QString sSender = mwRef->getDeviceID();

  QString sXML = load_from_file(":/DiagramsTemplate.xml");;

  //----------------------------------------------------------------------------------------

  QDomDocument xmldoc;
  xmldoc.setContent(sXML);

  QMap<QString, QString> mParams;

  for(int i = 0; i < mVarParams.count(); i++)
  {
    QString sKey = mVarParams.keys()[i];
    QString sValue = mVarParams.values()[i].toString();

    mParams.insert(sKey, sValue);
  }

  QString sGroupID = mParams["GroupID"];
  QString sFormName = mParams["FormName"];
  QString sObjectName = mParams["ObjectName"];
  QString sModelType = mParams["ModelType"];
  QString sCallback = mParams["Callback"];
  QString sCallbackObject = mParams["CallbackObject"];
  QString sCallbackForm = mParams["CallbackForm"];
  QString sQMLFunctionName = mParams["QMLFunctionName"];
  QString sLoginType = mParams["LoginType"];


  QString sGroupUID = mParams["GroupUID"];


  set_node_value(xmldoc, "Root/Header/Group", sGroupID);
  set_node_value(xmldoc, "Root/Header/Sender", sSender);
  set_node_value(xmldoc, "Root/Header/GroupUID", sGroupUID);
  QDomElement nOutput = xmldoc.documentElement().firstChildElement("GVars");

  QStringList slKeys = mParams.keys();
  for(int i = 0; i < slKeys.count(); i++)
  {
    if(slKeys[i] != "CallbackForm" && slKeys[i] != "CallbackObject" &&
       slKeys[i] != "GroupID" && slKeys[i] != "FormName" &&
       slKeys[i] != "ObjectName" && slKeys[i] != "ModelType" &&
       slKeys[i] != "Callback" && slKeys[i] != "GroupUID" &&
       slKeys[i] != "QMLFunctionName" && slKeys[i] != "LoginType")
    {



      if(slKeys[i] == "Raw")
      {

        QDomElement newNode = xmldoc.createElement(slKeys[i]);
        QDomCDATASection sec = xmldoc.createCDATASection(mParams[slKeys[i]]);
        newNode.appendChild(sec);
        nOutput.appendChild(newNode);

      }
      else{
        QDomElement newNode = xmldoc.createElement(slKeys[i]);
        QDomText newNodeText = xmldoc.createTextNode(mParams[slKeys[i]]);
        newNode.appendChild(newNodeText);
        nOutput.appendChild(newNode);

      }


    }
  }

  if(sFormName != "" && sObjectName != "")
  {
    set_node_value(xmldoc, "Root/Header/TUID", sTransUID);


    //      if(sCallbackForm.isEmpty())
    //      {
    //        sCallbackForm = mwRef->getMainForm()->objectName();
    //      }

    //      if(sCallbackObject.isEmpty())
    //      {
    //        sCallbackObject = "root";
    //      }


    QMap<QString, QString> tParams;
    tParams["TUID"] = sTransUID;
    tParams["FormName"] = sFormName;
    tParams["ObjectName"] = sObjectName;
    tParams["ModelType"] = sModelType;
    tParams["Callback"] = sCallback;
    tParams["CallbackObject"] = sCallbackObject;
    tParams["CallbackForm"] = sCallbackForm;
    tParams["QMLFunctionName"] = sQMLFunctionName;

    emit(transactionSignal(tParams));
  }


  TTCPClientWrap client;
  client.post(sVersioningAddress, sVersioningPort, xmldoc.toString());


  qDebug() << "TCppBridge| call_diagram sending xml with TUID " << sTransUID;

  return sTransUID;
}

//---------------------------------------------------------------------------
QString TCppBridge::call_diagram_login(QJsonObject jsonObject) // Object Keywords: GroupID, FormName, ObjectName, ModelType, Callback
{
  QString sLoginUID = QUuid::createUuid().toString();
  QString sTransUID = QUuid::createUuid().toString();

  QString sSender = mwRef->getDeviceID();
  QString sGroupID = jsonObject["GroupID"].toString();
  QString sFormName = jsonObject["FormName"].toString();
  QString sObjectName = jsonObject["ObjectName"].toString();
  QString sModelType = jsonObject["ModelType"].toString();
  QString sCallback = jsonObject["Callback"].toString();
  QString sCallbackObject = jsonObject["CallbackObject"].toString();
  QString sCallbackForm = jsonObject["CallbackForm"].toString();
  QString sQMLFunctionName = jsonObject["QMLFunctionName"].toString();
  QString sLoginType = jsonObject["LoginType"].toString();
  QString sGroupUID = jsonObject["GroupUID"].toString();

  QString sXML = load_from_file(":/DiagramsTemplate.xml");;
  QDomDocument xmldoc;
  xmldoc.setContent(sXML);
  set_node_value(xmldoc, "Root/Header/Group", sGroupID);
  set_node_value(xmldoc, "Root/Header/Sender", sSender);
  QDomElement nOutput = xmldoc.documentElement().firstChildElement("GVars");

  QStringList slKeys = jsonObject.keys();
  for(int i = 0; i < slKeys.count(); i++)
  {
    if(slKeys[i] != "CallbackForm" && slKeys[i] != "CallbackObject" &&
       slKeys[i] != "GroupID" && slKeys[i] != "FormName" &&
       slKeys[i] != "ObjectName" && slKeys[i] != "ModelType" &&
       slKeys[i] != "Callback" && slKeys[i] != "GroupUID" &&
       slKeys[i] != "QMLFunctionName" && slKeys[i] != "LoginType")
    {
      QDomElement newNode = xmldoc.createElement(slKeys[i]);
      QDomText newNodeText = xmldoc.createTextNode(jsonObject[slKeys[i]].toString());
      newNode.appendChild(newNodeText);
      nOutput.appendChild(newNode);
    }
  }

  set_node_value(xmldoc, "Root/Header/TUID", sTransUID);

  QMap<QString, QString> loginParams;
  loginParams["LoginUID"] = sLoginUID;
  loginParams["XMLMessage"] = xmldoc.toString();


  loginParams["TUID"] = sTransUID;
  loginParams["FormName"] = sFormName;
  loginParams["ObjectName"] = sObjectName;
  loginParams["ModelType"] = sModelType;
  loginParams["Callback"] = sCallback;
  loginParams["CallbackObject"] = sCallbackObject;
  loginParams["CallbackForm"] = sCallbackForm;
  loginParams["QMLFunctionName"] = sQMLFunctionName;


  mwRef->mLoginDic[sLoginUID] = loginParams;
  return sTransUID;
}
//---------------------------------------------------------------------------
void TCppBridge::show_form(QJsonObject joParams)
{
  QVariantMap mVarParams = joParams.toVariantMap();
  QMap<QString, QString> mParams;

  for(int i = 0; i < mVarParams.count(); i++)
  {
    QString sKey = mVarParams.keys()[i];
    QString sValue = mVarParams.values()[i].toString();

    mParams.insert(sKey, sValue);
  }

  QString sFormName = mParams["FormName"];
  QString sModal = mParams["Modal"];
  QString sSizable = mParams["Sizable"];
  QString sFrameless = mParams["Frameless"];

  // ------------------------------------------	Provjera jel dialog već podignut

  bool bRepeat = false;
  QQuickView* qv;

  for (int i = 0; i < QApplication::topLevelWindows().count(); i++)
  {
    if(sFormName == QApplication::topLevelWindows().at(i)->objectName())
    {
      qDebug() << "found a repeat of " << sFormName;
      bRepeat = true;

      qv = qobject_cast<QQuickView*>(QApplication::topLevelWindows().at(i));
      delete qv;
      qv = nullptr;
    }
  }

  qv = new QQuickView();
  qv->setObjectName(sFormName);
  qv->setSource(QUrl("qrc:/" + sFormName));

  // --------------------- Modal param handling

  if(sModal.toUpper().contains("TRUE") || sModal == "1")
  {
    qv->setModality(Qt::WindowModality::ApplicationModal);
  }

  if(sFrameless.toUpper().contains("TRUE") || sFrameless == "1")
  {
    qv->setFlags(Qt::FramelessWindowHint | Qt::Tool);
  }


  QObject* root = qv->findChild<QObject*>("root");



  // --------------------- Sizable param handling

  int iHeight = root->property("implicitHeight").toInt();
  int iWidth = root->property("implicitWidth").toInt();


  if(sSizable.toUpper().contains("TRUE") || sSizable == "1")
  {
    qDebug() << "Window set as sizable";
  }
  else
  {
    qv->setMinimumHeight(iHeight);
    qv->setMinimumWidth(iWidth);
    qDebug() << "Window set as NOT sizable";
  }

  for(int i = 0; i < mParams.keys().length(); i++)
  {
    QString sProperty = mParams.keys().at(i);
    QString sValue = mParams[mParams.keys().at(i)];

    if(sProperty != "Modal" || sProperty != "FormName" || sProperty != "Sizable" || sProperty != "Frameless")
    {
      QByteArray ba = sProperty.toLocal8Bit();
      const char* cProperty = ba.data();

      root->setProperty(cProperty, sValue);
    }
  }

  QMetaObject::invokeMethod(root, "init");    // čitat iz inija ili iz qml property?
  qv->setTitle(sFormName.remove(sFormName.indexOf(".qml"), 4));
  //  qv->setGeometry(   QStyle::alignedRect(
  //                       Qt::LeftToRight,
  //                       Qt::AlignCenter,
  //                       QSize(iHeight, iWidth),
  //                       qApp->desktop()->availableGeometry()
  //                   ));



  qv->show();
}
//---------------------------------------------------------------------------
void TCppBridge::close_form(QString sFormName)
{
  QQuickView* qv = form_by_name(sFormName);
  if(qv)
    qv->close();
  return;
}
//---------------------------------------------------------------------------
void TCppBridge::log_to_file(QString sLog)
{
  LogQueue->push("qml\n" + sLog);
}
//---------------------------------------------------------------------------
QString TCppBridge::load_from_file(QString sFileName)
{
  QFile file(sFileName);
  if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    return "0";

  QTextStream in(&file);

  QString sReturn = in.readAll();
  return sReturn;
}
//---------------------------------------------------------------------------
QString TCppBridge::get_root_dir()
{
  return QDir::currentPath();
}
//---------------------------------------------------------------------------
bool TCppBridge::login(QString sUsername, QString sPassword)
{
  QString sXML = load_from_file(":/DiagramsTemplate.xml");;
  QDomDocument xmldoc;
  xmldoc.setContent(sXML);

  set_node_value(xmldoc, "Root/Header/Group", "40170");
  set_node_value(xmldoc, "Root/Header/Sender", mwRef->getDeviceID());

  // Gen GVARS

  QDomElement nGVars = xmldoc.documentElement().firstChildElement("GVars");

  QDomElement newNode = xmldoc.createElement("Username");
  QDomText newNodeText = xmldoc.createTextNode(sUsername);
  newNode.appendChild(newNodeText);
  nGVars.appendChild(newNode);

  QDomElement pwdNode = xmldoc.createElement("Password");
  QDomText pwdText = xmldoc.createTextNode(sPassword);
  pwdNode.appendChild(pwdText);
  nGVars.appendChild(pwdNode);

  TTCPClientWrap client;
  client.post(sVersioningAddress, sVersioningPort, xmldoc.toString());

  return true;
}
//--------------------------------------------------------------------------
void TCppBridge::show_message(QString sMessage)
{
  mwRef->showMessage(sMessage);
}
//--------------------------------------------------------------------------
void TCppBridge::close_message(QString sUID)
{
  mwRef->closeMessage(sUID);
}
//---------------------------------------------------------------------------
bool TCppBridge::check_privilege(QString sObject, QString sPermType, bool bShowWarning)
{
  bool bHasRights = mwRef->checkUserRights(sObject, sPermType);
  if(!bHasRights && bShowWarning)
  {
    // Show message with warning
    QString sMessage = "User doesn't have " + sPermType + " permission on object " + sObject;
    mwRef->showMessage(sMessage);
  }

  qDebug() << "check privilege with bAdminMode = " << bAdminMode;


  if(bAdminMode)
    return true;
  else
    return bHasRights;
}
//---------------------------------------------------------------------------
void TCppBridge::show_main_form()
{
  mwRef->showMain();
}
//---------------------------------------------------------------------------
QString TCppBridge::load_xml(QString sArg)
{
  QString sReturn = "";

  QFile flTmep(sArg);

  if (!flTmep.open(QFile::ReadOnly | QFile::Text))
  {
    qDebug() << "TCppBridge|failed to open file for writing";
  }

  QTextStream in(&flTmep);
  sReturn = in.readAll();

  if (flTmep.isOpen())
  {
    flTmep.close();
  }

  return sReturn;
}
//---------------------------------------------------------------------------
QString TCppBridge::translate(QString msg)
{
  return mwRef->translate(msg);
}
//---------------------------------------------------------------------------
// Backward Compatibility
//---------------------------------------------------------------------------
void TCppBridge::to_serial_que(QString sArg)
{
  mwRef->SerialQueue.push(sArg);
}
//---------------------------------------------------------------------------
void TCppBridge::list_windows()
{
  listWindows();
}
//---------------------------------------------------------------------------
QString TCppBridge::request_permission(QJsonObject joParams)
{
  QVariantMap mVarParams = joParams.toVariantMap();

  QString sTransUID = QUuid::createUuid().toString();
  QString sSender = mwRef->getDeviceID();

  QString sXML = load_from_file(":/DiagramsTemplate.xml");;
  QDomDocument xmldoc;
  xmldoc.setContent(sXML);

  QMap<QString, QString> mParams;

  for(int i = 0; i < mVarParams.count(); i++)
  {
    QString sKey = mVarParams.keys()[i];
    QString sValue = mVarParams.values()[i].toString();

    mParams.insert(sKey, sValue);
  }

  QString sGroupID = mwRef->permissionGroupID;
  QString sFormName = mParams["FormName"];
  QString sObjectName = mParams["ObjectName"];
  QString sFunctionName = mParams["FunctionName"];

  QString sPermissionObject = mParams["PermissionObject"];
  QString sPermissionType = mParams["PermissionType"];
  QString sUserName = mParams["Username"];
  QString sPassword = mParams["Password"];

  mParams["TUID"] = sTransUID;

  set_node_value(xmldoc, "Root/Header/Group", sGroupID);
  set_node_value(xmldoc, "Root/Header/Sender", sSender);
  set_node_value(xmldoc, "Root/Header/TUID", sTransUID);
  QDomElement nOutput = xmldoc.documentElement().firstChildElement("GVars");

  QDomElement newNode = xmldoc.createElement("Username");
  QDomText newNodeText = xmldoc.createTextNode(sUserName);
  newNode.appendChild(newNodeText);
  nOutput.appendChild(newNode);

  newNode = xmldoc.createElement("Password");
  newNodeText = xmldoc.createTextNode(sPassword);
  newNode.appendChild(newNodeText);
  nOutput.appendChild(newNode);

  newNode = xmldoc.createElement("OBJ_CODE");
  newNodeText = xmldoc.createTextNode(sPermissionObject);
  newNode.appendChild(newNodeText);
  nOutput.appendChild(newNode);

  newNode = xmldoc.createElement("PERM_TYPE");
  newNodeText = xmldoc.createTextNode(sPermissionType);
  newNode.appendChild(newNodeText);
  nOutput.appendChild(newNode);

  emit(permissionSignal(mParams));

  TTCPClientWrap client;
  client.post(sAddress, sPort, xmldoc.toString());

  return sTransUID;
}
//---------------------------------------------------------------------------
void TCppBridge::copy_to_clipboard(QString sParam)
{
  QClipboard *clipboard = QGuiApplication::clipboard();
  QString originalText = clipboard->text();

  clipboard->setText(sParam);
}
//---------------------------------------------------------------------------
QString TCppBridge::get_from_clipboard()
{
  return QGuiApplication::clipboard()->text();
}
//---------------------------------------------------------------------------
void TCppBridge::show_dialog(QStringList slParams)
{
  emit(dialogSignal(slParams));
}
//---------------------------------------------------------------------------
void TCppBridge::send_transaction_http(QStringList slParams)
{
  QString sTransUID = QUuid::createUuid().toString();
  QString sSender = mwRef->getDeviceID();
  QString sDelimiter = "|";

  QString sXML = load_from_file(":/DiagramsTemplate.xml");;
  QDomDocument xmldoc;
  xmldoc.setContent(sXML);

  QMap<QString, QString> mParams;

  for(int i = 0; i < slParams.count(); i++)
  {
    QString sParam = slParams[i];
    QStringList slTemp = sParam.split(sDelimiter);
    mParams.insert(slTemp[0], slTemp[1]);
  }

  QString sGroupID = mParams["GroupID"];
  QString sFormName = mParams["FormName"];
  QString sObjectName = mParams["ObjectName"];
  QString sModelType = mParams["ModelType"];


  set_node_value(xmldoc, "Root/Header/Group", sGroupID);
  set_node_value(xmldoc, "Root/Header/TUID", sTransUID);
  set_node_value(xmldoc, "Root/Header/Sender", sSender);
  QDomElement nOutput = xmldoc.documentElement().firstChildElement("GVars");

  QStringList slKeys = mParams.keys();
  for(int i = 0; i < slKeys.count(); i++)
  {
    if(slKeys[i] != "GroupID" && slKeys[i] != "FormName" && slKeys[i] != "ObjectName" && slKeys[i] != "ModelType")
    {
      QDomElement newNode = xmldoc.createElement(slKeys[i]);
      QDomText newNodeText = xmldoc.createTextNode(mParams[slKeys[i]]);
      newNode.appendChild(newNodeText);
      nOutput.appendChild(newNode);
    }
  }

  QMap<QString, QString> tParams;
  tParams["TUID"] = sTransUID;
  tParams["FormName"] = sFormName;
  tParams["ObjectName"] = sObjectName;
  tParams["ModelType"] = sModelType;

  emit(transactionSignal(tParams));

  TTCPClientWrap client;
  client.post(sAddress, sPort, xmldoc.toString());
}
//---------------------------------------------------------------------------
void TCppBridge::send_http(QStringList slParams)
{

  QString sTransUID = QUuid::createUuid().toString();
  QString sSender = mwRef->getDeviceID();
  QString sDelimiter = "|";

  QString sXML = load_from_file(":/DiagramsTemplate.xml");;
  QDomDocument xmldoc;
  xmldoc.setContent(sXML);

  QMap<QString, QString> mParams;

  for(int i = 0; i < slParams.count(); i++)
  {
    QString sParam = slParams[i];
    QStringList slTemp = sParam.split(sDelimiter);
    mParams.insert(slTemp[0], slTemp[1]);
  }

  QString sGroupID = mParams["GroupID"];
  QString sFormName = mParams["FormName"];
  QString sObjectName = mParams["ObjectName"];
  QString sModelType = mParams["ModelType"];


  set_node_value(xmldoc, "Root/Header/Group", sGroupID);
  set_node_value(xmldoc, "Root/Header/TUID", sTransUID);
  set_node_value(xmldoc, "Root/Header/Sender", sSender);
  QDomElement nOutput = xmldoc.documentElement().firstChildElement("GVars");

  QStringList slKeys = mParams.keys();
  for(int i = 0; i < slKeys.count(); i++)
  {
    if(slKeys[i] != "GroupID" && slKeys[i] != "FormName" && slKeys[i] != "ObjectName" && slKeys[i] != "ModelType")
    {
      QDomElement newNode = xmldoc.createElement(slKeys[i]);
      QDomText newNodeText = xmldoc.createTextNode(mParams[slKeys[i]]);
      newNode.appendChild(newNodeText);
      nOutput.appendChild(newNode);
    }
  }

  QMap<QString, QString> tParams;
  tParams["TUID"] = sTransUID;
  tParams["FormName"] = sFormName;
  tParams["ObjectName"] = sObjectName;
  tParams["ModelType"] = sModelType;

  emit(transactionSignal(tParams));

  TTCPClientWrap client;
  client.post(sAddress, sPort, xmldoc.toString());
}
//---------------------------------------------------------------------------
void TCppBridge::send_raw_http(QString sXML)
{
  TTCPClientWrap client;
  client.post(sAddress, sPort, sXML);
}
//---------------------------------------------------------------------------
QString TCppBridge::gen_xml(QStringList slParams)
{
  QString sDelimiter = "|";
  QString sSender = mwRef->getDeviceID();

  QString sXML = load_from_file(":/DiagramsTemplate.xml");;
  QDomDocument xmldoc;
  xmldoc.setContent(sXML);

  QMap<QString, QString> mParams;

  for(int i = 0; i < slParams.count(); i++)
  {
    QString sParam = slParams[i];
    QStringList slTemp = sParam.split(sDelimiter);
    mParams.insert(slTemp[0], slTemp[1]);
  }


  set_node_value(xmldoc, "Root/Header/Group", mParams["GroupID"]);
  set_node_value(xmldoc, "Root/Header/Sender", sSender);
  QDomElement nOutput = xmldoc.documentElement().firstChildElement("GVars");

  QStringList slKeys = mParams.keys();
  for(int i = 0; i < slKeys.count(); i++)
  {
    if(slKeys[i] != "GroupID")
    {
      QDomElement newNode = xmldoc.createElement(slKeys[i]);
      QDomText newNodeText = xmldoc.createTextNode(mParams[slKeys[i]]);
      newNode.appendChild(newNodeText);
      nOutput.appendChild(newNode);
    }
  }

  return xmldoc.toString();
}
//---------------------------------------------------------------------------
void TCppBridge::set_property(QStringList slParams)
{
  QString sDelimiter = "|";

  QMap<QString, QString> mParams;

  for(int i = 0; i < slParams.count(); i++) // samo za FormName??
  {
    QString sParam = slParams[i];
    QStringList slTemp = sParam.split("|");
    mParams.insert(slTemp[0], slTemp[1]);
  }

  QString sDialogName = mParams["FormName"];
  if(sDialogName == "")
    sDialogName = mParams["DialogName"];


  QQuickView* qv = form_by_name(sDialogName);

  // ------------------------------------------ Parametriranje dialoga

  QString sObjectName;
  for(int i = 1; i < slParams.count(); i++)
  {
    QString sLine = slParams[i];
    QStringList slLine = sLine.split(sDelimiter);
    if(slLine[0] == "ObjectName")
    {
      sObjectName = slLine[1];
    }
    else
    {
      QString sProperty = slLine[0];
      QString sValue = slLine[1];

      QByteArray ba = sProperty.toLocal8Bit();
      const char* cProperty = ba.data();

      QObject* tmp = qv->findChild<QObject*>(sObjectName);
      if(tmp)
      {
        tmp->setProperty(cProperty, sValue);
      }
    }
  }
}
//---------------------------------------------------------------------------
void TCppBridge::register_qrc(QString sJson, QString appTitle)
{
  TJsonTableModel* tmDataSet = json_to_model(sJson);
  QString sMainForm = "";
  QDir dir;
  dir.mkpath(QDir::currentPath() + "/SaveFiles/");

  for(int i = 0; i < tmDataSet->rowCount(); i++)
  {

    QString sOrigFileName = tmDataSet->fieldByName(i,"ClassName");
    QString sFileName;

    if(sOrigFileName.contains(".js"))
    {
      sFileName = sOrigFileName;
    }
    else
    {
      sFileName = sOrigFileName + ".qml";
    }

    QString sSavePath = QDir::currentPath() + "/SaveFiles/" + sFileName;
    QString sFileContents = tmDataSet->fieldByName(i, "DFMCode");
    QString sIsMainForm = tmDataSet->fieldByName(i, "IsForm");

    if(sIsMainForm.toUpper() == "TRUE" || sIsMainForm == "1")
    {
      sMainForm = sFileName;
    }
    save_to_file(sFileContents, sSavePath);
  }

  // ------------------------------------------------- REGISTER QRC proc

  QString sResName = "res.qrc";

  // -------------------------
  QString sFileContents = load_from_file(QDir::currentPath() + "/XMLRepo/qrctemplate.xml");
  QDomDocument xmltemp;
  xmltemp.setContent(sFileContents);
  QDomNode nQResource = xmltemp.documentElement().childNodes().at(0);
  // -------------------------

  QDir qmlDir;
  qmlDir.setPath(QDir::currentPath() + "/SaveFiles/");

  foreach(QFileInfo item, qmlDir.entryInfoList())
  {
    if(item.isFile())
    {
      QDomElement tag = xmltemp.createElement("file");
      QDomText txt = xmltemp.createTextNode(item.fileName());

      nQResource.appendChild(tag);
      tag.appendChild(txt);
    }
  }

  QFile flTemp(QDir::currentPath() + "/SaveFiles/" + sResName);

  if(flTemp.open(QFile::WriteOnly | QFile::Text))
  {
    QTextStream out(&flTemp);
    out << xmltemp.toString();
    flTemp.flush();
  }

  flTemp.close();

  QStringList slArgs;
  slArgs.append("-binary");
  slArgs.append(QDir::currentPath() + "/SaveFiles/" + sResName);
  slArgs.append("-o");
  slArgs.append(QDir::currentPath() + "/SaveFiles/tempres.rcc");
  QProcess::execute(QDir::currentPath() + "/XMLRepo/rcc.exe", slArgs);

  if(QResource::unregisterResource(QDir::currentPath() + "/SaveFiles/tempres.rcc"))
    qDebug() << "old .rcc unregistered";

  if(QResource::registerResource(QDir::currentPath() + "/SaveFiles/tempres.rcc"))
    qDebug() << "new .rcc registered";
  else
  {
    QQuickView* qvTemp = new QQuickView();
    qvTemp->setSource(QUrl("qrc:/LocalQMLs/CDShowMessage.qml"));
    qvTemp->setObjectName("RegistrationFailed.qml");

    qvTemp->setHeight(300);
    qvTemp->setWidth(400);
    qvTemp->setProperty("msgText", "Registration of source files has failed");

    qvTemp->show();

    qDebug() << "Failed to register resource";
  }

  // ----------------------------------

  // Čišćenje SaveFiles foldera
  //  QDir qmlDir;
  qmlDir.setPath(QDir::currentPath() + "/SaveFiles/");

  foreach(QFileInfo item, qmlDir.entryInfoList())
  {
    qmlDir.remove(item.fileName());
  }


  // Show main form

  QQuickView* qvMainForm = mwRef->getMainForm();

  TQmlCppBridge qcBridge;
  TJsonTableModel model;
  qmlRegisterType<TQmlCppBridge>("QmlCppBridge", 1, 0, "QmlCppBridge");
  qmlRegisterType<TJsonTableModel>("TableModel", 1, 0, "TableModel");
  qmlRegisterType<MyTreeModel>("qt.test", 1, 0, "TreeModel");
  qmlRegisterType<MyTreeNode>("qt.test", 1, 0, "TreeNode");


  qvMainForm->setSource(QUrl("qrc:/" + sMainForm));
  qvMainForm->setObjectName(sMainForm);

  QObject* oTmp = qvMainForm->findChild<QObject*>("root");
  int iHeight = 250;
  int iWidth = 250;

  iHeight = oTmp->property("implicitHeight").toInt();
  iWidth = oTmp->property("implicitWidth").toInt();


  qvMainForm->setHeight(iHeight);
  qvMainForm->setWidth(iWidth);
  qvMainForm->setTitle("Client");
  qvMainForm->setPosition(0,0);
  qvMainForm->setFramePosition(QPoint(0,0));
  qvMainForm->setWindowState(	Qt::WindowMaximized);
  qvMainForm->showMaximized();


  QMetaObject::invokeMethod(oTmp, "init");
}
//---------------------------------------------------------------------------
void TCppBridge::save_login_credentials(QJsonObject joParams)
{

  // Tu bi išla procedura za spremanje UserRights mape

  QJsonArray ar;
  QJsonObject temp = {};

  temp["UserName"] = "Dindoo";
  temp["OBJ_CODE"] = "ProdOrders";
  temp["PERM_TYPE"] = "Edit";
  temp["HasRights"] = "0";
  ar.push_back(temp);
  temp = {};

  temp["UserName"] = "Dindoo";
  temp["OBJ_CODE"] = "ProdOrders";
  temp["PERM_TYPE"] = "Create";
  temp["HasRights"] = "1";
  ar.push_back(temp);
  temp = {};

  temp["UserName"] = "Dindoo";
  temp["OBJ_CODE"] = "Calibration";
  temp["PERM_TYPE"] = "Toggle";
  temp["HasRights"] = "0";
  ar.push_back(temp);
  temp = {};
}
//---------------------------------------------------------------------------
QJsonArray TCppBridge::parse_json(QJsonValue sJson)
{
  QString sJsonDataSet = sJson.toString();

  QByteArray byteArray = sJsonDataSet.toUtf8();
  QJsonDocument jsonDocument = QJsonDocument::fromJson(byteArray);
  QJsonObject jsonObject = jsonDocument.object();

  // ----------- "Parse Json"
  QJsonObject objFDBS = jsonObject["FDBS"].toObject();
  QJsonObject objManager = objFDBS["Manager"].toObject();
  QJsonArray arrTableList = objManager["TableList"].toArray();
  QJsonObject objTable = arrTableList[0].toObject();
  QJsonArray arrColumnList = objTable["ColumnList"].toArray();
  QJsonArray arrRowList = objTable["RowList"].toArray();


  QJsonArray rows;

  for(int i = 0; i < arrRowList.count(); i++)
  {
    QJsonObject objRow = arrRowList[i].toObject();
    QJsonObject objRowVals = objRow["Original"].toObject();
    rows.append(objRowVals);
  }

  byteArray =  QJsonDocument(rows).toJson(QJsonDocument::Compact);
  QJsonDocument jsonDoc = QJsonDocument::fromJson( byteArray );
  QJsonObject oReturn = jsonDoc.object();

  return rows;
}
//---------------------------------------------------------------------------
QStringList TCppBridge::getLanguages()
{
  return mwRef->getLanguageList();
}
//---------------------------------------------------------------------------
QStringList TCppBridge::getTheLanguageList()
{
  return slLanguages;
}
//---------------------------------------------------------------------------
void TCppBridge::setLanguages(QStringList sl)
{
  slLanguages = sl;
  emit changeOfLanguageList();
}
//---------------------------------------------------------------------------
void TCppBridge::requestTranslations(QString sLanguage)
{
  qDebug() << "requestTranslations called with param " << sLanguage;

  QJsonObject temp;
  // LNG Get translations for specific language
  temp["GroupID"] = "40207"; // ID Dijagrama
  temp["GroupUID"] = "{F78ECC7A-536E-4E62-85D0-23A7EECC0AC5}"; // UID Dijagrama

  // Slijede globalne varijable dijagrama
  temp["Language"] = sLanguage;

  QString sXML = load_from_file(":/DiagramsTemplate.xml");
  QDomDocument xmldoc;
  xmldoc.setContent(sXML);

  QDomElement nOutput = xmldoc.documentElement().firstChildElement("GVars");

  QDomElement newNode = xmldoc.createElement("Language");
  QDomText newNodeText = xmldoc.createTextNode(sLanguage);
  newNode.appendChild(newNodeText);
  nOutput.appendChild(newNode);

  set_node_value(xmldoc, "Root/Header/Group", "40207");
  set_node_value(xmldoc, "Root/Header/Sender", mwRef->getDeviceID());

  TTCPClientWrap client;
  client.post(sVersioningAddress, sVersioningPort, xmldoc.toString());
}
//---------------------------------------------------------------------------
bool TCppBridge::loginWithBarcode(QString sBarcode, QString sObjectName, QString sCallback)
{
  QString sXML = load_from_file(":/DiagramsTemplate.xml");
  QDomDocument xmldoc;
  xmldoc.setContent(sXML);

  set_node_value(xmldoc, "Root/Header/Group", "40170");
  set_node_value(xmldoc, "Root/Header/Sender", mwRef->getDeviceID());

  // Gen GVARS

  QDomElement nGVars = xmldoc.documentElement().firstChildElement("GVars");

  QDomElement newNode = xmldoc.createElement("Barcode");
  QDomText newNodeText = xmldoc.createTextNode(sBarcode);
  newNode.appendChild(newNodeText);
  nGVars.appendChild(newNode);


  QString sTransUID = QUuid::createUuid().toString();
  set_node_value(xmldoc, "Root/Header/TUID", sTransUID);


  QMap<QString, QString> tParams;
  tParams["TUID"] = sTransUID;
  tParams["FormName"] = mwRef->getMainFormName();
  tParams["Callback"] = sCallback;
  tParams["CallbackObject"] = sObjectName;

  emit(transactionSignal(tParams));


  qDebug() << "loginWithBarcode params: " << tParams;

  TTCPClientWrap client;
  client.post(sVersioningAddress, sVersioningPort, xmldoc.toString());

  return true;
}
//---------------------------------------------------------------------------
QString TCppBridge::gen_UID()
{
  return QUuid::createUuid().toString();
}
//---------------------------------------------------------------------------
QString TCppBridge::getDeviceID()
{
  return mwRef->getDeviceID();
}
//---------------------------------------------------------------------------
QString TCppBridge::get_deviceID()
{
  return mwRef->getDeviceID();
}
//---------------------------------------------------------------------------
void TCppBridge::sendLog(QString sAddress, QString sPort)
{
  QString sLogPath = QDir::currentPath();
  sLogPath = "/sdcard/Codel";
  QString sFileName = "Log_" + QDateTime::currentDateTime().toString("yyyyMMdd") + ".txt";
  QString sFilePath = sLogPath + "/Logs/" + sFileName;

  QFile fRead(sFilePath);
  fRead.open(QIODevice::ReadOnly | QIODevice::Text);
  QString sLogContent = fRead.readAll();

  TTCPClientWrap client;
  client.post(sAddress, sPort, sLogContent);

  qDebug() << "sendLog to " << sAddress << sPort;
  qDebug() << "LogContent sample: " << sLogContent.left(15);
}
//---------------------------------------------------------------------------
void TCppBridge::clearLog()
{
  QString sLogPath = QDir::currentPath();
  sLogPath = "/sdcard/Codel";
  QString sFileName = "Log_" + QDateTime::currentDateTime().toString("yyyyMMdd") + ".txt";
  QString sFilePath = sLogPath + "/Logs/" + sFileName;

  QFile fRead(sFilePath);
  fRead.open(QIODevice::WriteOnly | QIODevice::Text);
  fRead.write("");
  fRead.close();
}
//---------------------------------------------------------------------------
bool TCppBridge::save_image_from_hex(QString sHexImg)
{
  qDebug() << "save_image_from_hex called with arg(50) " << sHexImg.left(50);
  QByteArray arr1;
  arr1 = sHexImg.toUtf8();
  QByteArray arr2;
  arr2 = QByteArray::fromHex(arr1);

  QImage imRec;
  imRec.loadFromData(arr2, "PNG");

  return imRec.save(QDir::currentPath() + "/XMLRepo/imgSrc.png");
}
//---------------------------------------------------------------------------
QString TCppBridge::get_device_name()
{
  return mwRef->getDeviceName();
}
//---------------------------------------------------------------------------
QString TCppBridge::stringToHex(QString s)
{
  return s.toLatin1().toHex();
}
//---------------------------------------------------------------------------
void TCppBridge::fetch_language_list()
{
  // Load language list Diagram
  QString sXML = load_from_file(":/DiagramsTemplate.xml");
  QDomDocument xmldoc;
  xmldoc.setContent(sXML);

  QDomElement nOutput = xmldoc.documentElement().firstChildElement("GVars");

  QDomElement newNode = xmldoc.createElement("ProjName");
  QDomText newNodeText = xmldoc.createTextNode(mwRef->getProjName());
  newNode.appendChild(newNodeText);
  nOutput.appendChild(newNode);

  set_node_value(xmldoc, "Root/Header/Group", "40206");
  set_node_value(xmldoc, "Root/Header/Sender", mwRef->getDeviceID());

  qDebug() << "fetch_language_list sending " << xmldoc.toString();

  TTCPClientWrap client;
  client.post(sVersioningAddress, sVersioningPort, xmldoc.toString());
}
//---------------------------------------------------------------------------
void TCppBridge::setImgProviderSource(QString sHex)
{
  mwRef->setImgProviderSource(sHex);
}
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
// Better implementations
void TCppBridge::saveImage(QString sHexBytes, QString sPath, QString sFormat)
{
  QByteArray arr1;
  arr1 = sHexBytes.toUtf8();
  QByteArray arr2;
  arr2 = QByteArray::fromHex(arr1);

  QString sUFormat = sFormat.toUpper();
  QByteArray ba = sUFormat.toLocal8Bit();
  const char* cFormat = ba.data();

  QImage imRec;
  imRec.loadFromData(arr2, cFormat);

  bool b = imRec.save(sPath + "." + sFormat);
}
//---------------------------------------------------------------------------
void TCppBridge::serialInputCaught(QString code, QString hexCode)
{
  qDebug() << "TCppBrige serialInputCaught with " << code;
  emit serialInputRead(code, hexCode);
}
//---------------------------------------------------------------------------
QString TCppBridge::get_file_path(QString sDefaultPath)
{
  QString sFolder = QFileDialog::getExistingDirectory(0, ("Select Output Folder"), QDir::currentPath());
  return sFolder;
}
//---------------------------------------------------------------------------
QStringList TCppBridge::open_file_dialog(QString sDefaultPath, QString sFileRegExp)
{
  QStringList sFiles = QFileDialog::getOpenFileNames(0, ("Select files"), sDefaultPath, sFileRegExp);
  return sFiles;
}
//---------------------------------------------------------------------------
bool TCppBridge::save_file(QString sFileContents, QString sFullPath)
{
  save_to_file(sFileContents, sFullPath);
  return true;
}
//---------------------------------------------------------------------------
bool TCppBridge::copy_folder(const QString &fromDir, const QString &toDir, bool copyAndRemove)
{
  qDebug() << "CppBridge::copy_folder called with fromDir = " << fromDir << ", toDir = " << toDir;

  QDirIterator it(fromDir, QDirIterator::Subdirectories);
  QDir dir(fromDir);
  const int absSourcePathLength = dir.absoluteFilePath(fromDir).length();

  while (it.hasNext()){
    it.next();
    const auto fileInfo = it.fileInfo();
    if(!fileInfo.isHidden()) { //filters dot and dotdot
      const QString subPathStructure = fileInfo.absoluteFilePath().mid(absSourcePathLength);
      const QString constructedAbsolutePath = toDir + subPathStructure;

      if(fileInfo.isDir()){
        //Create directory in target folder
        dir.mkpath(constructedAbsolutePath);
      } else if(fileInfo.isFile()) {
        //Copy File to target directory

        //Remove file at target location, if it exists, or QFile::copy will fail

        if(fileInfo.fileName().contains(".qrc") || fileInfo.fileName().contains(".ini"))
        {
          qDebug() << "Skipping file " << fileInfo.fileName();
        }
        else
        {
          if(QFile::exists(constructedAbsolutePath))
          {
            qDebug() << "Attempting to copy file that already exists";
            qDebug() << "From = " << fileInfo.absoluteFilePath() << ", To = " << constructedAbsolutePath;


            bool r = QFile::remove(constructedAbsolutePath);
            qDebug() << "QFile::remove returned " << r;
            bool b = QFile::copy(fileInfo.absoluteFilePath(), constructedAbsolutePath);
            qDebug() << "QFile::copy returned " << b;
          }
          else
          {
            qDebug() << "Copying a file that doesn't exist";

            QFile::remove(constructedAbsolutePath);
            bool b = QFile::copy(fileInfo.absoluteFilePath(), constructedAbsolutePath);
          }
        }
      }
    }
  }

  if(copyAndRemove)
    dir.removeRecursively();

  return true;
}
//---------------------------------------------------------------------------
bool TCppBridge::copy_files_from_folder(const QString &fromDir, const QString &toDir)
{
  qDebug() << "CppBridge::copy_folder called with fromDir = " << fromDir << ", toDir = " << toDir;

  QDirIterator it(fromDir, QDirIterator::Subdirectories);
  QDir dir(fromDir);
  const int absSourcePathLength = dir.absoluteFilePath(fromDir).length();

  while (it.hasNext()){
    it.next();
    const auto fileInfo = it.fileInfo();
    if(!fileInfo.isHidden()) { //filters dot and dotdot
      const QString subPathStructure = fileInfo.absoluteFilePath().mid(absSourcePathLength);
      const QString constructedAbsolutePath = toDir + subPathStructure;

       if(fileInfo.isFile()) {

        if(QFile::exists(constructedAbsolutePath))
        {
          qDebug() << "Attempting to copy file that already exists";
        }
        else
        {
          qDebug() << "Copying a file that doesn't exist";
          QFile::remove(constructedAbsolutePath);
          bool b = QFile::copy(fileInfo.absoluteFilePath(), constructedAbsolutePath);

          qDebug() << "Copy called with arg1 = " << fileInfo.absoluteFilePath() << ", arg2 = " << constructedAbsolutePath;
          qDebug() << "QFile::copy returned " << b;
        }
      }
    }
  }

  return true;
}
//---------------------------------------------------------------------------
bool TCppBridge::create_edit_environment()
{
  copy_folder("\\\\aldebaran\\CDE_Public\\Grigor\\CDProjectDesigner", "C:/Users/grigorr.PLUTO-GR/Documents/Pasta/CDProjectDesigner", false);
}
//---------------------------------------------------------------------------
bool TCppBridge::create_folder(const QString &folderName)
{
  return QDir().mkdir(folderName);
}
//---------------------------------------------------------------------------
bool TCppBridge::setup_qrc(QString sPathToDesigner, QString sProjectName)
{
  qDebug() << "setup_qrc called with path " << sPathToDesigner;
  QString sResName = "qml.qrc";

  // -------------------------
  QString sFileContents = load_from_file(sPathToDesigner + "/qml.qrc");
  QDomDocument xmltemp;
  xmltemp.setContent(sFileContents);
  QDomNode nQResource = xmltemp.documentElement().childNodes().at(0);
  // -------------------------

  QString sProjFilesPath = sPathToDesigner + "/" + sProjectName;


  QDir qmlDirProject;
  qmlDirProject.setPath(sProjFilesPath);

  // -------------------------

  // Clear all xml nodes that start with sProjectName

  QDomNode rootNode = xmltemp.documentElement().childNodes().at(0);


  int nodesDeleted = 0;
  int iOrgNrNodes = rootNode.childNodes().count();

  for (int i = 0; i < rootNode.childNodes().count(); i++)
  {
    QDomNode node = rootNode.childNodes().at(i);
    qDebug() << "SETUP_QRC found nodeValue = " << node.firstChild().nodeValue();
    qDebug() << "node.firstChild().nodeValue().startsWith(sProjectName)= " << node.firstChild().nodeValue().startsWith(sProjectName);

    if(node.firstChild().nodeValue().startsWith(sProjectName))
    {
      QDomNode nDebug = node.parentNode().removeChild(node);

      qDebug() << "deleted nDebug = " << nDebug.nodeValue();
      qDebug() << "deleted nDebug first child = " << nDebug.firstChild().nodeValue();
      nodesDeleted++;
      i--;
    }
  }

  // -------------------------

  qDebug() << "qmlDirProject.entryInfoList() = " << qmlDirProject.entryInfoList();

  foreach(QFileInfo item, qmlDirProject.entryInfoList())
  {
    if(item.fileName() != "." && item.fileName() != "..")
    {

      if(item.isFile())
      {
        qDebug() << "found qmlItem in item = " << item.fileName();

        QDomElement tag = xmltemp.createElement("file");
        QDomText txt = xmltemp.createTextNode(sProjectName + "/" + item.fileName());

        nQResource.appendChild(tag);
        tag.appendChild(txt);
      }
    }
  }

  qDebug() << "resulting domDoucument = " << xmltemp.toString();

  // -------------------------

  QFile flTemp(sPathToDesigner + "/" +  sResName);
  if(flTemp.exists())
    qDebug() << "file Exists";


  if(flTemp.open(QFile::WriteOnly | QFile::Text))
  {
    qDebug() << "managed to open the file";

    QTextStream out(&flTemp);
    out << xmltemp.toString();
    flTemp.flush();
  }

  flTemp.close();


  xmltemp.clear();
  xmltemp.~QDomDocument();

  return true;
}
//---------------------------------------------------------------------------
QString TCppBridge::get_ID_OP()
{
  return mwRef->sID_OP;
}
//---------------------------------------------------------------------------
void TCppBridge::actionEventsInit(QJsonArray obj)
{
  qDebug() << "TCppBridge::actionEventsInit";
  emit eventsInit(obj);
}
//---------------------------------------------------------------------------
void TCppBridge::onActionEventNotification(QJsonObject obj)
{
  qDebug() << "TCppBridge::onActionEventNotification";
  emit eventNotification(obj);
}
//---------------------------------------------------------------------------
QJsonObject TCppBridge::getTheStyleMapChange()
{
  return oStyleMap;
}
//---------------------------------------------------------------------------
void TCppBridge::setStyleMap(QJsonObject o)
{
  oStyleMap = o;
  emit changeOfStyleMap();
}
//---------------------------------------------------------------------------
bool TCppBridge::paste_to_cmd(QString sCommand)
{
  qDebug() << "CppBridge pasting to cmd: " << sCommand;
  return QProcess::startDetached(sCommand, QStringList());
}

//---------------------------------------------------------------------------
bool TCppBridge::edit_client_ini(QString sPath, QString sProject, QString sVersion)
{
  QFile file(sPath);
  file.open(QIODevice::Text);

  QSettings settings(sPath, QSettings::IniFormat);
  settings.beginGroup("Client");

  settings.setValue("ProjectName", sProject);
  settings.setValue("Version", sVersion);

  settings.endGroup();

  return true;
}
//---------------------------------------------------------------------------
bool TCppBridge::edit_staging_params(QString sIniPath, QString sMainForm, QString bLoginRequired, QString sSourceDir)
{
  QSettings settings(sIniPath, QSettings::IniFormat);
  settings.beginGroup("StagingMode");

  settings.setValue("Enabled", 1);
  settings.setValue("MainForm", sMainForm);
  settings.setValue("LoginRequired", bLoginRequired);
  settings.setValue("SourcePath", sSourceDir);

  QString sProjectName = sSourceDir;
  sProjectName.truncate(sSourceDir.length());
  sProjectName.remove(0, sProjectName.lastIndexOf("/") + 1);

  settings.setValue("ProjectName", sProjectName);

  settings.endGroup();

  return true;
}
//---------------------------------------------------------------------------
bool TCppBridge::reset_staging_params(QString sIniPath)
{
  QSettings settings(sIniPath, QSettings::IniFormat);
  settings.beginGroup("StagingMode");

  settings.setValue("Enabled", 0);
  settings.setValue("MainForm", "");
  settings.setValue("LoginRequired", "");
  settings.setValue("SourcePath", "");
  settings.setValue("ProjectName", "");

  settings.endGroup();

  return true;
}
//---------------------------------------------------------------------------
bool TCppBridge::runProcess(QString sProcess)
{
  return QProcess::startDetached(sProcess, QStringList());
}
//---------------------------------------------------------------------------
QString TCppBridge::get_project_name()
{
  return mwRef->getProjName();
}
//---------------------------------------------------------------------------
QString TCppBridge::save_to_userdefs(QString sName, QString sValue)
{
  QJsonObject temp;
  // QVersioning add something to UserParams
  temp["GroupID"] = "40404"; // ID Dijagrama
  temp["GroupUID"] = "{B9398804-E034-4A60-A503-1B6668D06B8E}"; // UID Dijagrama

  // Slijede globalne varijable dijagrama
  temp["ID_OP"] = get_ID_OP();
  temp["Name"] = sName;
  temp["Value"] = sValue;

  qDebug() << "attempting to call diagram 40404 with: " << QString(QJsonDocument(temp).toJson());

  return call_diagramV(temp, true);
}
//---------------------------------------------------------------------------
QString TCppBridge::get_user_defs(QString sName, QString sObjectName, QString sFunctionName)
{
  QJsonObject temp;

  // QVersioning fetch something from UserParams
  temp["GroupID"] = "40405"; // ID Dijagrama
  temp["GroupUID"] = "{D65E45DB-242D-44E3-BD12-2D37C6477A34}"; // UID Dijagrama
  temp["FormName"] = mwRef->getMainFormName(); // Ime forme na kojoj se objekt nalazi
  temp["ObjectName"] = sObjectName; // Ime samog objekta kojega želimo osvježiti
  temp["QMLFunctionName"] = sFunctionName; // Ime funkcije koju želimo pozvati

  // Slijede globalne varijable dijagrama
  temp["ID_OP"] = get_ID_OP();
  temp["Name"] = sName;

  qDebug() << "attempting to call diagram 40405 with: " << QString(QJsonDocument(temp).toJson());

  return call_diagram(temp);
}
//---------------------------------------------------------------------------
QString TCppBridge::mainFormName()
{
  return mwRef->getMainFormName();
}
//---------------------------------------------------------------------------
QString TCppBridge::getDeviceType()
{
  return mwRef->sDeviceType;
}
//---------------------------------------------------------------------------
QJsonObject TCppBridge::getDeviceParams()
{
  return mwRef->deviceParams;
}
//---------------------------------------------------------------------------
bool TCppBridge::call_qml_function(QString sFunctionName, QObject* obj)
{
  QByteArray ba = sFunctionName.toLocal8Bit();
  const char *c_FuncName = ba.data();

  return QMetaObject::invokeMethod(obj, c_FuncName);
}
//---------------------------------------------------------------------------
bool TCppBridge::openURL(QString sURL)
{
  return QDesktopServices::openUrl(QUrl(sURL));
}
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
