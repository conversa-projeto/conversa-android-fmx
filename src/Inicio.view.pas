unit Inicio.view;

interface

uses
  System.Android.Service,
  System.Permissions,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  FMX.Controls,
  FMX.Dialogs,
  FMX.Forms,
  FMX.Graphics,
  FMX.Types,
  FMX.Layouts,
  Androidapi.Helpers,
  Androidapi.JNI.App,
  Conversa.Notify.Inicio,
  Conversa.Configuracoes.View,
  Contato.Lista.view,
  Inicio.Antigo.view,
  Chamada.view,
  Tipos,
  Androidapi.Jni.JavaTypes,
  Androidapi.JNI.Os, IdTCPConnection, IdTCPClient, IdBaseComponent, IdComponent,
  IdUDPBase, IdUDPClient, Androidapi.JNI.GraphicsContentViewText,
  FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  FMX.StdCtrls;

type
  TInicioView = class(TForm)
    lytClient: TLayout;
    S2: TIdTCPClient;
    S: TIdUDPClient;
    Memo1: TMemo;
    Button1: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FInicio: TInicioAView;
    ServiceConnection: TLocalServiceConnection;
    Service: TConversaNotifyServiceModule;
//    FLista: TContatoListaView;
    FChamadaView: TChamadaView;
    procedure ServiceConnected(const LocalService: TAndroidBaseService);
    procedure ServiceDisconnected;
    procedure ExibirTelaInicial;
    procedure AddLog(sMsg: String);
  public
    { Public declarations }

    procedure OnAtenderChamada;
    procedure OnReceberChamada;
    procedure OnRecusarChamada;
    procedure OnFinalizarChamada;
    procedure OnCancelarChamada;
    procedure VivaVoz(Value: Boolean);
    procedure IniciarChamada(User: TUsuario);
    procedure AtenderChamada(bEnviaComando: Boolean = True);
    procedure FinalizarChamada(bEnviarComando: Boolean = True);
    procedure RecusarChamada(bEnviarComando: Boolean = True);

    procedure TrazerPraFrente;
  end;

var
  InicioView: TInicioView;

implementation

{$R *.fmx}

procedure TInicioView.FormCreate(Sender: TObject);
var
    vFlags: integer;
begin
  ServiceConnection := TLocalServiceConnection.Create;
  ServiceConnection.OnConnected := ServiceConnected;
  ServiceConnection.OnDisconnected := ServiceDisconnected;
  ServiceConnection.BindService(TConversaNotifyServiceModule.ServiceClassName);


  vFlags :=
    TJWindowManager_LayoutParams.JavaClass.FLAG_TURN_SCREEN_ON or
//    TJWindowManager_LayoutParams.JavaClass.FLAG_DISMISS_KEYGUARD or
    TJWindowManager_LayoutParams.JavaClass.FLAG_SHOW_WHEN_LOCKED or
    TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON;




  with TAndroidHelper.Activity.getWindow do
  begin
    setFlags(vFlags, vFlags);
    getDecorView.setSystemUiVisibility(
TJView.JavaClass.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or TJView.JavaClass.SYSTEM_UI_FLAG_FULLSCREEN
                or TJView.JavaClass.SYSTEM_UI_FLAG_VISIBLE
                or TJView.JavaClass.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or TJView.JavaClass.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or TJView.JavaClass.SYSTEM_UI_FLAG_IMMERSIVE
                or TJView.JavaClass.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
    )
  end;

end;

procedure TInicioView.FormDestroy(Sender: TObject);
begin
  ServiceConnection.UnbindService;
  FreeAndNil(ServiceConnection);
end;

procedure TInicioView.FormShow(Sender: TObject);
begin
  TPermissionsService.DefaultService.RequestPermissions(
    [
      JStringToString(TJManifest_permission.JavaClass.ACCESS_COARSE_LOCATION),
      JStringToString(TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION),
      JStringToString(TJManifest_permission.JavaClass.ACCESS_LOCATION_EXTRA_COMMANDS),
      JStringToString(TJManifest_permission.JavaClass.ACCESS_NOTIFICATION_POLICY),
      JStringToString(TJManifest_permission.JavaClass.ACCESS_WIFI_STATE),
      JStringToString(TJManifest_permission.JavaClass.CALL_PHONE),
      JStringToString(TJManifest_permission.JavaClass.CAMERA),
      JStringToString(TJManifest_permission.JavaClass.CHANGE_NETWORK_STATE),
      JStringToString(TJManifest_permission.JavaClass.CHANGE_WIFI_STATE),
      JStringToString(TJManifest_permission.JavaClass.CHANGE_WIFI_MULTICAST_STATE),
      JStringToString(TJManifest_permission.JavaClass.INTERNET),
      JStringToString(TJManifest_permission.JavaClass.READ_EXTERNAL_STORAGE),
      JStringToString(TJManifest_permission.JavaClass.READ_PHONE_STATE),
      JStringToString(TJManifest_permission.JavaClass.RECORD_AUDIO),
      JStringToString(TJManifest_permission.JavaClass.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS),
      JStringToString(TJManifest_permission.JavaClass.SYSTEM_ALERT_WINDOW),
      JStringToString(TJManifest_permission.JavaClass.VIBRATE),
      JStringToString(TJManifest_permission.JavaClass.WAKE_LOCK),
      JStringToString(TJManifest_permission.JavaClass.WRITE_EXTERNAL_STORAGE),
      JStringToString(TJManifest_permission.JavaClass.ACCESS_NETWORK_STATE)
    ],
    procedure(const Permissions: TClassicStringDynArray; const GrantResults: TClassicPermissionStatusDynArray)
    begin
//      if (Length(GrantResults) = 2) and ((GrantResults[0] = TPermissionStatus.Granted) or (GrantResults[1] = TPermissionStatus.Granted)) then
//        StartLocationTracking;
    end,
    procedure(const Permissions: TClassicStringDynArray; const PostRationaleProc: TProc)
    begin
//      TDialogService.ShowMessage('The location permission is needed for tracking the user''s location',
//      procedure(const &Result: TModalResult)
//      begin
//        PostRationaleProc;
//      end);
    end);

  if not TConfiguracoesView.EstaConfigurado then
    TConfiguracoesView.New(Self, ExibirTelaInicial)
  else
    ExibirTelaInicial;
end;

procedure TInicioView.ExibirTelaInicial;
begin
  FInicio := TInicioAView.New(lytClient);
  FInicio.ClientView := lytClient;
  FInicio.OnIniciaChamada(Self.IniciarChamada);
end;

procedure TInicioView.ServiceConnected(const LocalService: TAndroidBaseService);
begin
  // Called when the connection between the native activity and the service has been established. It is used to obtain the
  // binder object that allows the direct interaction between the native activity and the service.
  Service := TConversaNotifyServiceModule(LocalService);
  Service.FAddLog := AddLog;
  Service.OnAtenderChamada := OnAtenderChamada;
  Service.OnRecusarChamada := OnRecusarChamada;
  Service.OnReceberChamada := OnReceberChamada;
  Service.OnFinalizarChamada := OnFinalizarChamada;
  Service.OnCancelarChamada := OnFinalizarChamada;
  Service.TrazerPraFrente := TrazerPraFrente;

  if Service.FRecebendoChamada then
  begin
    OnReceberChamada;
    Service.FRecebendoChamada := False;
  end;
end;

procedure TInicioView.ServiceDisconnected;
begin
  // Called when the connection between the native activity and the service has been unexpectedly lost (e.g. when the user
  // manually stops the service using the 'Settings' system application).
  Service := nil;
end;

procedure TInicioView.TrazerPraFrente;
var
  I: JIntent;
begin
  I := TAndroidHelper.Activity.getIntent;
  I.setFlags(TJIntent.JavaClass.FLAG_ACTIVITY_REORDER_TO_FRONT);
  TAndroidHelper.Activity.startActivity(I);
end;

procedure TInicioView.AddLog(sMsg: String);
begin
  TThread.Synchronize(
    nil,
    procedure
    begin
      Memo1.Lines.Insert(0, sMsg);
    end
  );
end;

procedure TInicioView.OnReceberChamada;
begin
  AddLog('ThreadID View: '+ TThread.Current.ThreadID.ToString);
  TThread.Synchronize(
    nil,
    procedure
    begin
      if not Assigned(FChamadaView) then
        FChamadaView := TChamadaView.New(lytClient)
      else
      begin
        FChamadaView.lytClient.Visible := True;
        FChamadaView.Rectangle1.Visible := True;
      end;

      FChamadaView
        .Nome(Service.FRemetente.ID.ToString)
        .Informacoes(Service.FRemetente.UDP.IP +':'+ Service.FRemetente.UDP.Porta.ToString)
        .SetStatus(TChamadaStatus.Recebendo)
        .OnAtender(
          procedure
          begin
            AtenderChamada(True)
          end)
        .OnVivaVoz(VivaVoz)
        .OnRecusar(
          procedure
          begin
            RecusarChamada(True);
          end
        );
    end
  );
end;

procedure TInicioView.OnRecusarChamada;
begin
  OnFinalizarChamada;
end;

procedure TInicioView.OnAtenderChamada;
begin
  FChamadaView
    .SetStatus(TChamadaStatus.EmAndamento)
    .OnRecusar(
      procedure
      begin
        FinalizarChamada(True);
      end
    );
end;

procedure TInicioView.OnCancelarChamada;
begin
  OnFinalizarChamada;
end;

procedure TInicioView.OnFinalizarChamada;
begin
  FChamadaView.lytClient.Visible := False;
  FChamadaView.Rectangle1.Visible := False;
end;

procedure TInicioView.IniciarChamada(User: TUsuario);
begin
  FChamadaView := TChamadaView.New(lytClient)
    .Status(TChamadaStatus.Chamando)
    .Nome(User.Nome)
    .Informacoes(User.Email)
    .SetStatus(TChamadaStatus.Chamando)
    .OnVivaVoz(VivaVoz)
    .OnRecusar(
      procedure
      begin
        TThread.CreateAnonymousThread(
          procedure
          begin
            Service.CancelarChamada(TOrigemComando.Local);
            OnFinalizarChamada;
          end
        ).Start;
      end
    );

  TThread.CreateAnonymousThread(
    procedure
    begin
      Service.IniciarChamada(User.ID);
    end
  ).Start;
end;

procedure TInicioView.AtenderChamada(bEnviaComando: Boolean);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      Service.AtenderChamada(TOrigemComando.Local);
    end
  ).Start;

  FChamadaView
    .SetStatus(TChamadaStatus.EmAndamento)
    .OnRecusar(
      procedure
      begin
        FinalizarChamada(True);
      end
    );
end;

procedure TInicioView.Button1Click(Sender: TObject);
begin
  Service.NotificarLigacao;
end;

procedure TInicioView.RecusarChamada(bEnviarComando: Boolean);
begin
  FChamadaView.lytClient.Visible := False;
  FChamadaView.Rectangle1.Visible := False;
  TThread.CreateAnonymousThread(
    procedure
    begin
      Service.RecusarChamada(TOrigemComando.Local);
    end
  ).Start;
end;

procedure TInicioView.FinalizarChamada(bEnviarComando: Boolean);
begin
  FChamadaView.lytClient.Visible := False;
  FChamadaView.Rectangle1.Visible := False;
  TThread.CreateAnonymousThread(
    procedure
    begin
      Service.FinalizarChamada(TOrigemComando.Local);
    end
  ).Start;
end;

procedure TInicioView.VivaVoz(Value: Boolean);
begin
  Service.VivaVoz(Value);
end;

end.
