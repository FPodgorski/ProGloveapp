#ifndef CPPBRIDGE_H
#define CPPBRIDGE_H

#include <QObject>
#include <QTimer>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>

// FROM EX QMLCPPBRIDGE

#include "TCPClientWrap.h"
#include "CommonFuncLib.h"
#include "ConcurrentQueue.h"
#include <QClipboard>

#include "mytreemodel.h"
#include "mytreenode.h"



class TCppBridge : public QObject
{
  Q_OBJECT
  Q_PROPERTY( QJsonObject translationMap READ getTheTranslationChange NOTIFY changeOfTranslation )
  Q_PROPERTY( QStringList languageList READ getTheLanguageList NOTIFY changeOfLanguageList);
  Q_PROPERTY( QJsonObject styleMap READ getTheStyleMapChange WRITE setStyleMap NOTIFY changeOfStyleMap );



public:

  // ----------------------------------------- Material verification exclusive

  Q_INVOKABLE bool save_image_from_hex(QString sHexImg);
  Q_INVOKABLE QString get_device_name();
  Q_INVOKABLE QString stringToHex(QString s);

  // ----------------------------------------- INVOKABLES

  Q_INVOKABLE void test_if_bridgable();
  Q_INVOKABLE QJsonArray parse_json(QJsonValue sJson);
  Q_INVOKABLE QStringList getLanguages();
  Q_INVOKABLE void requestTranslations(QString sLanguage);
  Q_INVOKABLE QString gen_UID();
  Q_INVOKABLE QString getDeviceID();
  Q_INVOKABLE QString get_deviceID();
  Q_INVOKABLE void sendLog(QString sAddress, QString sPort);
  Q_INVOKABLE void clearLog();
  Q_INVOKABLE void fetch_language_list();

  Q_INVOKABLE void setImgProviderSource(QString sHex);
  Q_INVOKABLE void saveImage(QString sHexBytes, QString sPath, QString sFormat);
  Q_INVOKABLE void setStyleMap(QJsonObject o);
  Q_INVOKABLE bool call_qml_function(QString sFunctionName, QObject* obj);
  Q_INVOKABLE bool openURL(QString sURL);



  // ---------------- Ex QmlCppBridge STANDARD

  Q_INVOKABLE QString call_diagram(QJsonObject jsonObject);
  Q_INVOKABLE QString call_diagramV(QJsonObject jsonObject, bool bVersioning);
  Q_INVOKABLE QString call_diagram_login(QJsonObject jsonObject);
  Q_INVOKABLE void show_form(QJsonObject joParams);
  Q_INVOKABLE void close_form(QString sFormName);
  Q_INVOKABLE void log_to_file(QString sLog);
  Q_INVOKABLE QString load_from_file(QString sFileName);
  Q_INVOKABLE QString get_root_dir();
  Q_INVOKABLE bool login(QString sUsername, QString sPassword);
  Q_INVOKABLE bool loginWithBarcode(QString sBarcode, QString sObjectName, QString sCallback);
  Q_INVOKABLE void show_message(QString sMessage);
  Q_INVOKABLE void close_message(QString sUID);
  Q_INVOKABLE bool check_privilege(QString sObject, QString sPermType, bool bShowWarning = true);
  Q_INVOKABLE void show_main_form();
  Q_INVOKABLE QString translate(QString msg);

  // ---------------- Ex QmlCppBridge BACKWARD COMPATIBILITY

  Q_INVOKABLE void to_serial_que(QString sArg);
  Q_INVOKABLE void list_windows();
  Q_INVOKABLE QString request_permission(QJsonObject joParams);
  Q_INVOKABLE void copy_to_clipboard(QString sParam);
  Q_INVOKABLE QString get_from_clipboard();
  Q_INVOKABLE void show_dialog(QStringList slParams);
  Q_INVOKABLE void send_transaction_http(QStringList slParams);
  Q_INVOKABLE void send_http(QStringList slParams);
  Q_INVOKABLE void send_raw_http(QString sXML);
  Q_INVOKABLE QString gen_xml(QStringList slParams);
  Q_INVOKABLE void set_property(QStringList slParams);
  Q_INVOKABLE void register_qrc(QString sJson, QString appTitle);
  Q_INVOKABLE void save_login_credentials(QJsonObject joParams);

  // CDClient Versioning essentials
  Q_INVOKABLE QString get_file_path(QString sDefaultPath);
  Q_INVOKABLE QStringList open_file_dialog(QString sDefaultPath, QString sFileRegExp);
  Q_INVOKABLE bool save_file(QString sFileContents, QString sFullPath);
  Q_INVOKABLE bool copy_folder(const QString &fromDir, const QString &toDir, bool copyAndRemove = false);
  Q_INVOKABLE bool copy_files_from_folder(const QString &fromDir, const QString &toDir);
  Q_INVOKABLE bool create_edit_environment();
  Q_INVOKABLE bool create_folder(const QString &folderName);
  Q_INVOKABLE bool setup_qrc(QString sPathToDesigner, QString sProjectName);
  Q_INVOKABLE QString get_ID_OP();

  Q_INVOKABLE bool runProcess(QString sProcess);
  Q_INVOKABLE bool paste_to_cmd(QString sCommand);
  Q_INVOKABLE bool edit_client_ini(QString sPath, QString sProject, QString sVersion);
  Q_INVOKABLE bool edit_staging_params(QString sIniPath, QString sMainForm, QString bLoginRequired, QString sSourceDir);
  Q_INVOKABLE bool reset_staging_params(QString sIniPath);

  // Svi novi idu bez __ nez zaš sam to opće tak počeo pisat u bridgeu
  Q_INVOKABLE QString mainFormName();


  // Saving tableDefs
  Q_INVOKABLE QString get_project_name();
  Q_INVOKABLE QString save_to_userdefs(QString sName, QString sValue);
  Q_INVOKABLE QString get_user_defs(QString sName, QString sObjectName, QString sFunctionName);

  //
  Q_INVOKABLE QString getDeviceType();
  Q_INVOKABLE QJsonObject getDeviceParams();


  // Classic API
  void setDeviceName(QString s);
  void setTranslations(QJsonObject o);
  void setLanguages(QStringList sl);
  void setMainWindow(class MainWindow* ref);        

  QJsonObject getTheTranslationChange();
  QStringList getTheLanguageList();
  QJsonObject getTheStyleMapChange();

  TCppBridge();

  bool bAdminMode;
  void testMainWindow();
  void actionEventsInit(QJsonArray obj);

public slots:
  void onActionEventNotification(QJsonObject obj);

private slots:
  void serialInputCaught(QString code, QString hexCode);


private:
 QJsonObject oTranslations;
 QStringList slLanguages;
 QJsonObject oStyleMap;
 class MainWindow* mwRef;

 // EX QMLCPPBRIDGE
 QString load_xml(QString sArg);

 //Comm
 QString sAddress;
 QString sPort;

 QString sVersioningAddress;
 QString sVersioningPort;

 // Log
 TConcurrentQueue<QString> *LogQueue;
 QMap<QString, QString> mTransTest;

 //
 QString sAppDir;
 QString sDeviceName;

 //
 QString sQtInstallDir;


signals:
  void changeOfTranslation();
  void changeOfLanguageList();
  void changeOfStyleMap();
  void dialogSignal(QStringList slParams);
  void transactionSignal(QMap<QString, QString> mParams);
  void permissionSignal(QMap<QString, QString> mParams);
  void transChanged(QMap<QString, QString>);
//  void newTranslationsLoaded();
  void serialInputRead(QString, QString);
  void creatorLaunchReady(QString sPath);
  void eventNotification(QJsonObject eventParams);
  void eventsInit(QJsonArray eventsParams);
};

#endif // BINDERCLASS_H
