unit Conversa.Notify.Inicio;

interface

uses
  System.Android.Service, System.Classes, System.Notification, System.Sensors, System.Sensors.Components,

  System.JSON,
//  Androidapi.JNI.App, Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.Os,
//  System.Android.Service,
//  System.Classes,
//  System.Notification,
//  System.Sensors,
//  System.Sensors.Components,
  System.Threading,
  System.Permissions,
  Androidapi.Helpers, Androidapi.JNI.JavaTypes, Androidapi.JNI.Support, Androidapi.Log,
//  FMX.Types,
  System.SysUtils,
  System.StrUtils,
  //Androidapi.app.KeyguardManager,
  IdBaseComponent,
  IdComponent,
  IdTCPClient,
  IdTCPConnection,
  IdUDPBase,
  IdUDPClient,
  IdGlobal,
//  Androidapi.JNI.WiFiManager,
//
  Chamada.Audio,
  Chamada.WakeLock,
  Chamada.Vibrator.Service,
//  Chamada.view,
  Tipos,
//
//
  Androidapi.JNI.App,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Media,
  Androidapi.Jni.Net,
  Androidapi.JNI.Os;

type
  TOrigemComando = (Desconhecida, Local, Remoto);
  TLocationUpdated = procedure(const NewLocation: TLocationCoord2D) of object;

  TConversaNotifyServiceModule = class(TAndroidService)
    NotificationCenter: TNotificationCenter;
    IdUDPClient1: TIdUDPClient;
    IdTCPClient1: TIdTCPClient;

    procedure AndroidServiceCreate(Sender: TObject);
    function AndroidServiceStartCommand(const Sender: TObject; const Intent: JIntent; Flags, StartId: Integer): Integer;
    function AndroidServiceBind(const Sender: TObject; const AnIntent: JIntent): JIBinder;
    procedure AndroidServiceRebind(const Sender: TObject; const AnIntent: JIntent);
    function AndroidServiceUnBind(const Sender: TObject; const AnIntent: JIntent): Boolean;
    procedure AndroidServiceTaskRemoved(const Sender: TObject; const ARootIntent: JIntent);
    procedure TimerUDPTimer(Sender: TObject);
  private const
    NotificationId = -1;
    NotificationChannelId = 'com_conversa_notify_service_channel_id';
    NotificationCallId = -2;
    NotificationChannelCallId = 'com_conversa_notify_service_call_channel_id';
  private
    FForeground: Boolean;
    FNotificationManager: JNotificationManager;
    FNotificationBuilder: Japp_NotificationCompat_Builder;

    FNotificationBuilderCall: Japp_NotificationCompat_Builder;
    FCallNotify: JNotification;
//    FWifiM: JWiFiManager;

    FThreadTCP: TThread;
    FThreadRecebeAudio: ITask;
    FPararThreadAudio: Boolean;

    FAudioCapture: IAudioCapture;
    FAudioPlay: IAudioPlay;
//
//
    FWakeLock: IWakeLock;
    FVibrator: IVibratorService;
//
//    FChamadaView: TChamadaView;
    FRing: JRingtone;

    function GetIntent(const ClassName: string): JIntent;
    function GetNotification: JNotification;

    procedure LoopTCP;
    procedure TCPSendCommand(Method: TMethod; Bytes: TIdBytes);
    procedure ReceberChamada;
    procedure IniciarEnvioAudio;
    procedure IniciaAudio;


    procedure AddLog(sMsg: String; bErro: Boolean = False);

    procedure AbrirTela;

    procedure EncerrarChamada;
    procedure InicializarUDP;
  public const
    ActivityClassName = 'com.embarcadero.firemonkey.FMXNativeActivity';
    ServiceClassName = 'com.embarcadero.services.ConversaNotify';
  public
//    MainThread: TThread;
    Host: String;
    ID: Integer;
    FAddLog: TProc<String>;
    FLocalPonta: TPonta;
    FRemetente: TPonta;
    OnAtenderChamada: TProc;
    OnRecusarChamada: TProc;
    OnReceberChamada: TProc;
    OnFinalizarChamada: TProc;
    OnCancelarChamada: TProc;
    FRecebendoChamada: Boolean;

    TrazerPraFrente: TProc;

//    function GetSynThread: TThread;

    function ConectarAoIniciar: Boolean;
    procedure ManterSegundoPlano;
    procedure Conectar;
    procedure StopLocationTracking;
    procedure IniciarChamada(ID: Integer);
    procedure AtenderChamada(Origem: TOrigemComando);
    procedure FinalizarChamada(Origem: TOrigemComando);
    procedure RecusarChamada(Origem: TOrigemComando);
    procedure CancelarChamada(Origem: TOrigemComando);
    procedure VivaVoz(Value: Boolean);
    procedure ConectarThread;
    procedure NotificarLigacao;
  end;

var
  ConversaNotifyServiceModule: TConversaNotifyServiceModule;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

function LOGDEF(Text: MarshaledAString): Integer;
begin
  Result := __android_log_write(android_LogPriority.ANDROID_LOG_DEFAULT, 'default', Text);
end;

function LOGV(Text: MarshaledAString): Integer;
begin
  Result := __android_log_write(android_LogPriority.ANDROID_LOG_VERBOSE, 'verbose', Text);
end;

function LOGDBG(Text: MarshaledAString): Integer;
begin
  Result := __android_log_write(android_LogPriority.ANDROID_LOG_DEBUG, 'debug', Text);
end;

function LOGS(Text: MarshaledAString): Integer;
begin
  Result := __android_log_write(android_LogPriority.ANDROID_LOG_SILENT, 'silent', Text);
end;

procedure TConversaNotifyServiceModule.AndroidServiceCreate(Sender: TObject);
begin
  // Creates the notification channel that is used by the ongoing notification that presents location updates to the user.
  var NotificationChannel := NotificationCenter.CreateChannel;
  NotificationChannel.Id := NotificationChannelId;
  NotificationChannel.Title := 'Conversa - Serviços';
  NotificationChannel.Importance := TImportance.Default;

  NotificationCenter.CreateOrUpdateChannel(NotificationChannel);

  // Creates the notification channel that is used by the ongoing notification that presents location updates to the user.
  var NotificationChannelCall := NotificationCenter.CreateChannel;
  NotificationChannelCall.Id := NotificationChannelCallId;
  NotificationChannelCall.Title := 'Conversa - Ligações';
  NotificationChannelCall.Importance := TImportance.Default;
  NotificationCenter.CreateOrUpdateChannel(NotificationChannelCall);

  // The Run-Time Library does not allow all customizations needed for the ongoing notification used in this demo application.
  // For the mentioned reason, this demo application uses the native APIs for handling notifications.
  FNotificationManager := TJNotificationManager.Wrap(TAndroidHelper.Context.getSystemService(TJContext.JavaClass.NOTIFICATION_SERVICE));
  OnReceberChamada := nil;
  OnFinalizarChamada := nil;
  ManterSegundoPlano;

  AddLog('Conversa - Serviço de Notificação Criado');

  if ConectarAoIniciar then
    ConectarThread;
end;

function TConversaNotifyServiceModule.AndroidServiceStartCommand(const Sender: TObject; const Intent: JIntent; Flags, StartId: Integer): Integer;
begin
//  // Checks if the intent object contains an extra indicating that the user tapped on the 'Stop location tracking' notification action.
//  if JStringToString(Intent.getAction) = ActionStopLocationTracking then
//    StopLocationTracking;

  AddLog('Conversa - Serviço de Notificação Iniciado');
  Result := TJService.JavaClass.START_NOT_STICKY;
end;

procedure TConversaNotifyServiceModule.AndroidServiceTaskRemoved(const Sender: TObject; const ARootIntent: JIntent);
var
  Intent: JIntent;
  PendingIntent: JPendingIntent;

  function getTimeAfterInSecs(Seconds: Integer): Int64;
  var
    Calendar: JCalendar;
  begin
    Calendar := TJCalendar.JavaClass.getInstance;
    Calendar.add(TJCalendar.JavaClass.MILLISECOND, Seconds);
    Result := Calendar.getTimeInMillis;
  end;
begin
//  AbrirTela;
  Intent := TJIntent.Create;
  Intent.setClassName(TAndroidHelper.Context, StringToJString(TConversaNotifyServiceModule.ServiceClassName)).setPackage(TAndroidHelper.Context.getPackageName);
  PendingIntent := TJPendingIntent.JavaClass.getActivity(TAndroidHelper.Context, 1, Intent, TJPendingIntent.JavaClass.FLAG_ONE_SHOT);
  TAndroidHelper.AlarmManager.&set(TJAlarmManager.JavaClass.RTC_WAKEUP, getTimeAfterInSecs(100), PendingIntent);
end;

function TConversaNotifyServiceModule.AndroidServiceBind(const Sender: TObject; const AnIntent: JIntent): JIBinder;
begin
//  // Called when the native activity starts to be visible (goes back to the foreground state) and binds to this service.
//  // The native activity started to be visible and, therefore, this service is no longer needed to run in the foreground
//  // to avoid being affected by the 'background location limits' introduced as part of Android 8.0.
//  JavaService.stopForeground(True);
  Result := GetBinder;
end;

procedure TConversaNotifyServiceModule.AndroidServiceRebind(const Sender: TObject; const AnIntent: JIntent);
begin
//  // Called when the native activity starts to be visible (goes back to the foreground state) and binds once again to this service.
//  JavaService.stopForeground(True);
end;

function TConversaNotifyServiceModule.AndroidServiceUnBind(const Sender: TObject; const AnIntent: JIntent): Boolean;
begin
//  // Called when the native activity stops to be visible (goes to the background state) and unbinds from this service.
//  // The native activity stopped to be visible and, therefore, this service needs to run in the foreground, otherwise,
//  // it is affected by the background location limits introduced as part of Android 8.0. Running a service in the foreground
//  // requires an ongoing notification to be present to the user in order to indicate that the application is actively running.
//  JavaService.startForeground(NotificationId, GetNotification);
//
//  FIsRunningInForeground := True;
  Result := True;
end;

function TConversaNotifyServiceModule.ConectarAoIniciar: Boolean;
begin
  Result :=
    TAndroidHelper.Context.getSharedPreferences(StringToJString('conversa_pref'), TJActivity.JavaClass.MODE_PRIVATE)
      .getBoolean(StringToJString('conectar_automatico'), False);
end;

procedure TConversaNotifyServiceModule.ConectarThread;
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      while True do
      begin
        try
          Conectar;
          LOGV(PAnsiChar('Conectado!'));
          Break;
        except on E: Exception do
          AddLog('Erro na Conexão!: '+E.Message, True);
        end;
      end;
    end
  ).Start;
end;

function TConversaNotifyServiceModule.GetIntent(const ClassName: string): JIntent;
begin
  Result := TJIntent.JavaClass.init;
  Result.setClassName(TAndroidHelper.Context.getPackageName, TAndroidHelper.StringToJString(ClassName));
end;

function TConversaNotifyServiceModule.GetNotification: JNotification;

  function GetNotificationIconId: Integer;
  begin
    // Gets the notification icon's resource id. Otherwise, fall backs to the application icon's resource id.
    Result := TAndroidHelper.Context.getResources.getIdentifier(StringToJString('drawable/ic_notification'), nil, TAndroidHelper.Context.getPackageName);
  end;

  function GetActivityPendingIntent: JPendingIntent;
  begin
    // Gets the intent used to start the native activity after the user taps on the ongoing notification that presents
    // location updates to the user.
    var Intent := GetIntent(ActivityClassName);
    Result := TJPendingIntent.JavaClass.getActivity(TAndroidHelper.Context, 0, Intent, TJPendingIntent.JavaClass.FLAG_IMMUTABLE);
  end;

//  function GetServicePendingIntent: JPendingIntent;
//  begin
//    // Gets the intent used to stop this service after the user taps on the 'Stop location tracking' notification action
//    // button from the ongoing notification that presents location updates to the user.
//    var Intent := GetIntent(ServiceClassName);
//    Intent.setAction(StringToJString(ActionStopLocationTracking));
//
//    Result := TJPendingIntent.JavaClass.getService(TAndroidHelper.Context, 0, Intent, TJPendingIntent.JavaClass.FLAG_IMMUTABLE);
//  end;

begin
  if not Assigned(FNotificationBuilder) then
  begin
    FNotificationBuilder := TJapp_NotificationCompat_Builder.JavaClass.init(TAndroidHelper.Context, StringToJString(NotificationChannelId));
    FNotificationBuilder
      .setPriority(TJNotification.JavaClass.PRIORITY_HIGH)
      .setOngoing(True)
      .setSmallIcon(GetNotificationIconId)
      .setContentIntent(GetActivityPendingIntent)
      .setContentTitle(StrToJCharSequence('Conexão com Servidor'))
      .setContentText(StrToJCharSequence('Mantendo a conexão'))
      .setTicker(StrToJCharSequence('Mantendo a conexão'))
  end;

  Result :=
    FNotificationBuilder
      .setWhen(TJDate.Create.getTime)
      .build;
end;

//function TConversaNotifyServiceModule.GetSynThread: TThread;
//begin
//  if Assigned(MainThread) then
//    Result := MainThread
//  else
//    Result := TThread.Current;
//end;

procedure TConversaNotifyServiceModule.ManterSegundoPlano;
begin
  if FForeground then
    Exit;

  // Starting this service turns it into a started service and, therefore, it can run in the foreground for undefined
  // time and provide real-time location updates. After calling the 'startService' procedure, this service becomes
  // a bound and started service. That beind said, this service is destroyed only after the native activity unbinds
  // from it and this service calls the 'stopSelf' procedure.
  TAndroidHelper.Context.startService(GetIntent(ServiceClassName));

  // Called when the native activity stops to be visible (goes to the background state) and unbinds from this service.
  // The native activity stopped to be visible and, therefore, this service needs to run in the foreground, otherwise,
  // it is affected by the background location limits introduced as part of Android 8.0. Running a service in the foreground
  // requires an ongoing notification to be present to the user in order to indicate that the application is actively running.
  JavaService.startForeground(NotificationId, GetNotification);

  FForeground := True;
end;

procedure TConversaNotifyServiceModule.StopLocationTracking;
begin
  // Stopping this service turns it into only a bound service and, therefore, it is destroyed after the native activity
  // unbinds from it.
  JavaService.stopSelf;
end;

procedure TConversaNotifyServiceModule.TimerUDPTimer(Sender: TObject);
begin
  // Mantem a conexão ativa
  IdUdpClient1.SendBuffer([]);
end;

procedure TConversaNotifyServiceModule.Conectar;
var
  sIdentificador: string;
begin
  FForeground := False;
  FLocalPonta := Default(TPonta);
  FRemetente := Default(TPonta);

  with TAndroidHelper.Context.getSharedPreferences(StringToJString('conversa_pref'), TJActivity.JavaClass.MODE_PRIVATE) do
  begin
    Host :=  JStringToString(getString(StringToJString('host'), StringToJString('54.232.35.143')));
    ID := getInt(StringToJString('id'), 1);
    FLocalPonta.ID := ID;

    with TJSONObject.Create do
    try
      AddPair('id', ID);
      AddPair('nome', JStringToString(getString(StringToJString('nome'), StringToJString('nao-informado'))));
      sIdentificador := ToJSON;
    finally
      Free;
    end;
  end;

  FThreadTCP := TThread.CreateAnonymousThread(LoopTCP);

  IdTCPClient1.Host := Host;
  // Deixa conexão UDP preparada
  IdUDPClient1.Host := Host;
  IdUDPClient1.Active := False;
  try
    IdTCPClient1.Disconnect;
    IdTCPClient1.Connect;

    TCPSendCommand(TMethod.Registrar, TSerializer<Integer>.ParaBytes(ID));

    FThreadTCP.Start;

    // Se identifica no servidor
    TCPSendCommand(TMethod.AtribuirIdentificador, TSerializer<String>.ParaBytes(sIdentificador));
  except on E: Exception do
    raise Exception.Create('Falha ao registrar!'+ sLineBreak + E.Message);
  end;
end;

procedure TConversaNotifyServiceModule.LoopTCP;
var
  Tamanho: Integer;
  Bytes: TIdBytes;
  Metod: TMethod;
begin
  while IdTCPClient1.Connected do
  begin
    try
      TMonitor.Enter(IdTCPClient1);
      try
        // Verifica se desconectou
        IdTCPClient1.IOHandler.CheckForDisconnect;
        // Espera receber os dados
        IdTCPClient1.IOHandler.CheckForDataOnSource(10);
        // Verifica se tem dados
        if IdTCPClient1.IOHandler.InputBufferIsEmpty then
          Continue;

        Metod := TMethod(IdTCPClient1.IOHandler.ReadByte);
        Bytes := [];

        case Metod of
          TMethod.Erro: AddLog('R - Erro');
          TMethod.Registrar: AddLog('R - Registrar');
          TMethod.IniciarChamada: AddLog('R - IniciarChamada');
          TMethod.CancelarChamada: AddLog('R - CancelarChamada');
          TMethod.ReceberChamada: AddLog('R - ReceberChamada');
          TMethod.AtenderChamada: AddLog('R - AtenderChamada');
          TMethod.RetomarChamada: AddLog('R - RetomarChamada');
          TMethod.RecusarChamada: AddLog('R - RecusarChamada');
          TMethod.FinalizarChamada: AddLog('R - FinalizarChamada');
          TMethod.ChamadasAtivas: AddLog('R - ChamadasAtivas');
          TMethod.FinalizarTodasChamadas: AddLog('R - FinalizarTodasChamadas');
        end;

        Tamanho := IdTCPClient1.IOHandler.ReadInt32;
        AddLog('RT: '+ Tamanho.ToString);

        if Tamanho > 0 then
          IdTCPClient1.IOHandler.ReadBytes(Bytes, Tamanho)
        else
          Bytes := [];

        AddLog('RC: '+ BytesToString(Bytes));
        AddLog('ThreadID: '+ TThread.Current.ThreadID.ToString);

        if Metod = TMethod.AtenderChamada then
          FRemetente.ID := TSerializer<Integer>.DeBytes(Bytes)
        else
        if Metod in [TMethod.ReceberChamada, TMethod.AtenderChamada, TMethod.RetomarChamada] then
          FRemetente := TSerializer<TPonta>.DeBytes(Bytes);

        case Metod of
          TMethod.ReceberChamada: ReceberChamada;
          TMethod.AtenderChamada,
          TMethod.RetomarChamada: AtenderChamada(TOrigemComando.Remoto);
          TMethod.RecusarChamada: RecusarChamada(TOrigemComando.Remoto);
          TMethod.FinalizarChamada: FinalizarChamada(TOrigemComando.Remoto);
          TMethod.CancelarChamada: CancelarChamada(TOrigemComando.Remoto);
        end;
      finally
        TMonitor.Exit(IdTCPClient1);
      end;
    except on E: Exception do
      AddLog('LoopTCP: '+ E.Message, True);
    end;
  end;
  AddLog('ERRO - TCP desconectado!');
end;

procedure TConversaNotifyServiceModule.TCPSendCommand(Method: TMethod; Bytes: TIdBytes);
var
  Tamanho: Integer;
begin
  try
    TMonitor.Enter(IdTCPClient1);
    try
      AddLog(IndyTextEncoding_UTF8.GetString(Bytes));
      case Method of
        TMethod.Erro: AddLog('E - Erro');
        TMethod.Registrar: AddLog('E - Registrar');
        TMethod.IniciarChamada: AddLog('E - IniciarChamada');
        TMethod.CancelarChamada: AddLog('E - CancelarChamada');
        TMethod.ReceberChamada: AddLog('E - ReceberChamada');
        TMethod.AtenderChamada: AddLog('E - AtenderChamada');
        TMethod.AtribuirUDP: AddLog('E - AtribuirUDP');
        TMethod.RetomarChamada: AddLog('E - RetomarChamada');
        TMethod.RecusarChamada: AddLog('E - RecusarChamada');
        TMethod.FinalizarChamada: AddLog('E - FinalizarChamada');
        TMethod.ChamadasAtivas: AddLog('E - ChamadasAtivas');
        TMethod.FinalizarTodasChamadas: AddLog('E - FinalizarTodasChamadas');
      end;

      Tamanho := Length(Bytes);

      AddLog('T: '+ Tamanho.ToString);
      AddLog('C: '+ BytesToString(Bytes));
      IdTCPClient1.IOHandler.Write(Byte(Method));
      IdTCPClient1.IOHandler.Write(Tamanho);
      IdTCPClient1.IOHandler.Write(Bytes);
      AddLog('E.F.');
    finally
      TMonitor.Exit(IdTCPClient1);
    end;
  except on E: Exception do
    begin
      AddLog('TCPSendCommand: '+ E.Message, True);
      raise;
    end;
  end;
end;

procedure TConversaNotifyServiceModule.IniciarChamada(ID: Integer);
begin
  if ID = 0 then
    raise Exception.Create('Informe um ID válido!');

  FWakeLock := TWakeLock.New;
  FRemetente.ID := ID;
  TCPSendCommand(TMethod.IniciarChamada, TSerializer<Integer>.ParaBytes(ID));
end;

procedure TConversaNotifyServiceModule.ReceberChamada;
var
  aUri: Jnet_Uri;
begin
  FRecebendoChamada := True;
  AddLog('ReceberChamada');

//  TThread.Synchronize(
//    TThread.CurrentThread,
//  procedure
//  begin
//
//    NotificarLigacao;
//  end
//
//  );
  if Assigned(OnReceberChamada) then
  begin
    AddLog('Método de Recebimento de Chamada!');
    TrazerPraFrente;
    OnReceberChamada;
  end
  else
  begin
    AddLog('Tentando iniciar o app!');
    AbrirTela;
  end;

  aUri := TJRingtoneManager.JavaClass.getActualDefaultRingtoneUri(TAndroidHelper.Context, TJRingtoneManager.JavaClass.TYPE_RINGTONE);
  FRing := TJRingtoneManager.JavaClass.getRingtone(TAndroidHelper.Context, aUri);
  FRing.play;

  FWakeLock := TWakeLock.New;
  FVibrator := TVibratorService.New.Call;
end;

procedure TConversaNotifyServiceModule.IniciarEnvioAudio;
begin
  FAudioCapture.Start(
    procedure(Capture: IAudioCapture)
    var
      ID: TIdBytes;
    begin
      ID := Capture.ToIdBytes;
      IdUDPClient1.SendBuffer(ID);
//      AddLog('Gravação: '+ Length(ID).ToString);
    end
  );
end;

procedure TConversaNotifyServiceModule.AtenderChamada(Origem: TOrigemComando);
begin
  if (Origem = TOrigemComando.Remoto) and Assigned(OnAtenderChamada) then
    OnAtenderChamada
  else
  if Origem = TOrigemComando.Local then
    TCPSendCommand(TMethod.AtenderChamada, TSerializer<Integer>.ParaBytes(FRemetente.ID));

  if Assigned(FRing) then
    FRing.stop;

  FVibrator := nil;
  FRing := nil;

  InicializarUDP;
  IniciaAudio;
end;

procedure TConversaNotifyServiceModule.InicializarUDP;
var
  Bytes: TIdBytes;
  lenUDP: Integer;
begin
  Bytes := [];
  IdUdpClient1.SendBuffer(Bytes);
  SetLength(Bytes, IdUDPClient1.BufferSize);
  lenUDP := IdUdpClient1.ReceiveBuffer(Bytes);
  SetLength(Bytes, lenUDP);
  FLocalPonta.UDP := Bytes;
  AddLog('InicializarUDP-7');

  // Atribui UDP
  TCPSendCommand(TMethod.AtribuirUDP, FLocalPonta.UDP);
  AddLog('InicializarUDP-8');
end;

procedure TConversaNotifyServiceModule.RecusarChamada(Origem: TOrigemComando);
begin
  if (Origem = TOrigemComando.Remoto) and Assigned(OnRecusarChamada) then
    OnRecusarChamada
  else
  if Origem = TOrigemComando.Local then
    TCPSendCommand(TMethod.RecusarChamada, TSerializer<Integer>.ParaBytes(FRemetente.ID));

  if Assigned(FRing) then
    FRing.stop;

  FVibrator := nil;
  FRing := nil;

  EncerrarChamada;
end;

procedure TConversaNotifyServiceModule.IniciaAudio;
begin
  try
    FAudioPlay := TAudioPlay.New;
  except on E: Exception do
    begin
      AddLog('Falha ao criar audio play! Erro: '+ E.Message, True);
      Exit;
    end;
  end;

  if not Assigned(FAudioCapture) then
    FAudioCapture := TAudioCapture.New;

  AddLog('FAudioCapture');

  if FAudioCapture.PermissionGranted then
    IniciarEnvioAudio
  else
    FAudioCapture.RequestPermissions(
      procedure(Status: TPermissionStatus; Capture: IAudioCapture)
      begin
        if Status = TPermissionStatus.Granted then
          IniciarEnvioAudio;
      end
    );

  AddLog('FAudioCapture');

  FPararThreadAudio := False;

  FThreadRecebeAudio := TTask.Create(
    procedure
    var
      lenUDP: Integer;
      Bytes: TIdBytes;
    begin
      AddLog('Reprodução - Início');
      while not FPararThreadAudio do
      begin
        try
          // Recebe dados UDP do servidor
          SetLength(Bytes, IdUDPClient1.BufferSize);
          lenUDP := IdUdpClient1.ReceiveBuffer(Bytes, 10);
          SetLength(Bytes, lenUDP);

//          AddLog('Reprodção - '+ lenUDP.ToString);
          if lenUDP > 1 then
          begin
            FAudioPlay.Write(Bytes);
//            AddLog('Reprodção - '+ lenUDP.ToString);
          end;
        except on E: Exception do
          AddLog('IniciaAudio.LoopReproducao: '+ E.Message, True);
        end;
      end;
      FAudioPlay.Stop;
      AddLog('Reprodução - Fim');
    end
  );

  FThreadRecebeAudio.Start;
end;

procedure TConversaNotifyServiceModule.CancelarChamada(Origem: TOrigemComando);
begin
  if (Origem = TOrigemComando.Remoto) and Assigned(OnCancelarChamada) then
    OnCancelarChamada
  else
  if Origem = TOrigemComando.Local then
    TCPSendCommand(TMethod.CancelarChamada, TSerializer<Integer>.ParaBytes(FRemetente.ID));

  EncerrarChamada;
end;

procedure TConversaNotifyServiceModule.FinalizarChamada(Origem: TOrigemComando);
begin
  if (Origem = TOrigemComando.Remoto) and Assigned(OnFinalizarChamada) then
    OnFinalizarChamada
  else
  if Origem = TOrigemComando.Local then
    TCPSendCommand(TMethod.FinalizarChamada, TSerializer<Integer>.ParaBytes(FLocalPonta.ID));

  EncerrarChamada;
end;

procedure TConversaNotifyServiceModule.EncerrarChamada;
begin
  if Assigned(FWakeLock) then
    FWakeLock := nil;

  if Assigned(FRing) then
    FRing.stop;

  if Assigned(FVibrator) then
    FVibrator := nil;

  if Assigned(FRing) then
    FRing := nil;

  AddLog('Finalizar ThreadAudio');
  FPararThreadAudio := True;
  if Assigned(FThreadRecebeAudio) then
    FThreadRecebeAudio.Wait(500);

  if Assigned(FAudioCapture) then
  begin
    FAudioCapture.Stop;
    FAudioCapture := nil;
  end;

  if Assigned(FAudioPlay) then
  begin
    FAudioPlay.Stop;
    FAudioPlay := nil;
  end;

  AddLog('ThreadAudio Finalizada');
  FRemetente := Default(TPonta);
end;

procedure TConversaNotifyServiceModule.VivaVoz(Value: Boolean);
begin
  if not Assigned(FAudioPlay) then
    raise Exception.Create('Sem acesso à api de áudio!');

  if Value then
    FAudioPlay.StreamType(TAudioPlayStreamType.Music)
  else
    FAudioPlay.StreamType(TAudioPlayStreamType.Call)
end;

procedure TConversaNotifyServiceModule.AbrirTela;
var
  Intent: JIntent;
//  PendingIntent: JPendingIntent;

  function getTimeAfterInSecs(Seconds: Integer): Int64;
  var
    Calendar: JCalendar;
  begin
    Calendar := TJCalendar.JavaClass.getInstance;
    Calendar.add(TJCalendar.JavaClass.MILLISECOND, Seconds);
    Result := Calendar.getTimeInMillis;
  end;
begin
  Intent := TJIntent.Create;
  Intent
    .setClassName(TAndroidHelper.Context.getPackageName, StringToJString('com.embarcadero.firemonkey.FMXNativeActivity'))
    .setPackage(TAndroidHelper.Context.getPackageName)


//    .setAction(StringToJString('android.intent.action.MAIN'))
    .setAction(TJIntent.JavaClass.ACTION_MAIN)

//    .addCategory(StringToJString('android.intent.category.LAUNCHER'))
    .addCategory(TJIntent.JavaClass.CATEGORY_LAUNCHER)
//    .set
    .addFlags(TJIntent.JavaClass.FLAG_ACTIVITY_NEW_TASK)
    .addFlags(TJIntent.JavaClass.FLAG_ACTIVITY_SINGLE_TOP)

//    .addFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_DISMISS_KEYGUARD)
//    .addFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_SHOW_WHEN_LOCKED)
//    .addFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_TURN_SCREEN_ON)
//    .addFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON)
//    .addFlags(TJWindowManager_LayoutParams.JavaClass.TYPE_APPLICATION_OVERLAY)

//    .addFlags(TJWindowManager_LayoutParams.JavaClass.FLAG_DISMISS_KEYGUARD or
//      TJWindowManager_LayoutParams.JavaClass.FLAG_SHOW_WHEN_LOCKED or
//      TJWindowManager_LayoutParams.JavaClass.FLAG_TURN_SCREEN_ON or
//      TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON or
//      TJWindowManager_LayoutParams.JavaClass.TYPE_APPLICATION_OVERLAY
//    )

    .putExtra(StringToJString('conversa-action'), StringToJString('ReceberChamada'));

  TAndroidHelper.Context.startActivity(Intent);

//  PendingIntent := TJPendingIntent.JavaClass.getActivity(TAndroidHelper.Context, 1, Intent, TJPendingIntent.JavaClass.FLAG_ONE_SHOT);
//  TAndroidHelper.AlarmManager.&set(TJAlarmManager.JavaClass.RTC_WAKEUP, getTimeAfterInSecs(30), PendingIntent);
end;

procedure TConversaNotifyServiceModule.AddLog(sMsg: String; bErro: Boolean = False);
begin
//  if not bErro then
//    Exit;

  LOGV(PAnsiChar(AnsiString('Conversa: '+ sMsg)));

  if Assigned(FAddLog) then
    FAddLog(sMsg);
end;

procedure TConversaNotifyServiceModule.NotificarLigacao;

var
  JP: JPendingIntent;

  function GetNotificationIconId: Integer;
  begin
    // Gets the notification icon's resource id. Otherwise, fall backs to the application icon's resource id.
    Result := TAndroidHelper.Context.getResources.getIdentifier(StringToJString('drawable/ic_notification'), nil, TAndroidHelper.Context.getPackageName);
  end;

  function GetActivityPendingIntent: JPendingIntent;
  begin
    // Gets the intent used to start the native activity after the user taps on the ongoing notification that presents
    // location updates to the user.
    var Intent := GetIntent(ActivityClassName);
    Result := TJPendingIntent.JavaClass.getActivity(TAndroidHelper.Context, 0, Intent, TJPendingIntent.JavaClass.FLAG_IMMUTABLE);
  end;

//  function GetServicePendingIntent: JPendingIntent;
//  begin
//    // Gets the intent used to stop this service after the user taps on the 'Stop location tracking' notification action
//    // button from the ongoing notification that presents location updates to the user.
//    var Intent := GetIntent(ServiceClassName);
//    Intent.setAction(StringToJString(ActionStopLocationTracking));
//
//    Result := TJPendingIntent.JavaClass.getService(TAndroidHelper.Context, 0, Intent, TJPendingIntent.JavaClass.FLAG_IMMUTABLE);
//  end;

begin
  if not Assigned(FNotificationBuilderCall) then
  begin
    AddLog('Criando Builder');

    JP := GetActivityPendingIntent;

//    TJapp_NotificationCompat_Style.

    FNotificationBuilderCall := TJapp_NotificationCompat_Builder.JavaClass.init(TAndroidHelper.Context, StringToJString(NotificationChannelCallId));
    FNotificationBuilderCall
      .setSmallIcon(GetNotificationIconId)
      .setContentTitle(StrToJCharSequence('Recebendo Ligação'))
      .setContentText(StrToJCharSequence('Recebendo Ligação'))

      .setContentIntent(JP)
      .setFullScreenIntent(JP, true)
//      .setPriority(TJNotification.JavaClass.PRIORITY_HIGH)
      .setOngoing(True);

//      .setTicker(StrToJCharSequence('Recebendo Ligação'));
    AddLog('Builder Criado');
  end;

  FCallNotify := FNotificationBuilderCall
    .setCategory(TJNotification.JavaClass.CATEGORY_CALL)
//    .setWhen(TJDate.Create.getTime)
    .build;

  FNotificationManager.notify(NotificationCallId, FCallNotify);

  AddLog('Notificado');
end;

(*

  // If this service is running in the foreground, this service updates its ongoing notification to present the updated location.
  // If this service is running in the background, this service sends the updated location to the native activity.
  if FIsRunningInForeground then
    FNotificationManager.notify(NotificationId, GetNotification)
  else
  begin
    if Assigned(FLocationUpdated) then
      FLocationUpdated(NewLocation);
  end;


*)

end.
