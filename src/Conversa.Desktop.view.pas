unit Conversa.Desktop.view;

interface

uses
  FMX.Objects,
  System.Android.Service,
  System.Classes,
  System.JSON,
  System.Permissions,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  System.IOUtils,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Forms,
  FMX.Graphics,
  FMX.Layouts,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.Types,
  IdBaseComponent,
  IdComponent,
  IdTCPClient,
  IdTCPConnection,
  IdUDPBase,
  IdUDPClient,
  Androidapi.Helpers,
  Androidapi.JNI.App,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.Jni.JavaTypes,
  Androidapi.JNI.Os,
  Chamada.view,
  Contato.Lista.view,
  Conversa.Configuracoes.View,
  Conversa.Notify.Inicio,
  Conversa.Inicio.view,
  Tipos;

type
  TDesktopView = class(TForm)
    lytClient: TLayout;
    tmrTeste: TTimer;
    TCP: TIdTCPClient;
    UDP: TIdUDPClient;
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmrTesteTimer(Sender: TObject);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
  private
    { Private declarations }
    FKBBounds: TRectF;
    FNeedOffset: Boolean;

    AddLog: TProc<String>;
    FInicio: TInicioView;
    ServiceConnection: TLocalServiceConnection;
    Service: TConversaNotifyServiceModule;
    FChamadaView: TChamadaView;
    procedure ServiceConnected(const LocalService: TAndroidBaseService);
    procedure ServiceDisconnected;
    procedure ExibirTelaInicial;
    procedure ShowLog(sMsg: String; bErro: Boolean);
    procedure ConfigurarTelaLigacao;
  public
    { Public declarations }
    procedure OnAtenderChamada;
    procedure OnReceberChamada;
    procedure OnRecusarChamada;
    procedure OnFinalizarChamada;
    procedure OnCancelarChamada;
    procedure OnDestinatarioOcupado;
    procedure VivaVoz(Value: Boolean);
    procedure IniciarChamada(User: TUsuario);
    procedure AtenderChamada(bEnviaComando: Boolean = True);
    procedure FinalizarChamada(bEnviarComando: Boolean = True);
    procedure RecusarChamada(bEnviarComando: Boolean = True);
    procedure TrazerPraFrente;
    procedure ConectarServico;
    procedure ExibirTelaConfiguracao;
  end;

var
  DesktopView: TDesktopView;

implementation

uses
  Conversa.App.Events,
  Helper.JSON;

{$R *.fmx}

procedure TDesktopView.FormCreate(Sender: TObject);
var
    vFlags: integer;
begin
  VKAutoShowMode := TVKAutoShowMode.Always;

  tmrTeste.Enabled := True;

  vFlags :=
    TJWindowManager_LayoutParams.JavaClass.FLAG_TURN_SCREEN_ON or
//    TJWindowManager_LayoutParams.JavaClass.FLAG_DISMISS_KEYGUARD or
    TJWindowManager_LayoutParams.JavaClass.FLAG_SHOW_WHEN_LOCKED or
    TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON;


  with TAndroidHelper.Activity.getWindow do
  begin
    setFlags(vFlags, vFlags);
    getDecorView.setSystemUiVisibility(
      TJView.JavaClass.SYSTEM_UI_FLAG_LAYOUT_STABLE or
      TJView.JavaClass.SYSTEM_UI_FLAG_FULLSCREEN or
      TJView.JavaClass.SYSTEM_UI_FLAG_VISIBLE or
      TJView.JavaClass.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
      TJView.JavaClass.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
      TJView.JavaClass.SYSTEM_UI_FLAG_IMMERSIVE or
      TJView.JavaClass.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
    )
  end;
end;

procedure TDesktopView.FormDestroy(Sender: TObject);
begin
  Service.FShowLog := nil;
  ServiceConnection.UnbindService;
  FreeAndNil(ServiceConnection);
end;

procedure TDesktopView.FormShow(Sender: TObject);
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
    ExibirTelaConfiguracao
  else
    ExibirTelaInicial;
end;

procedure TDesktopView.ExibirTelaConfiguracao;
begin
  TConfiguracoesView.New(
    lytClient,
    procedure
    begin
      ExibirTelaInicial;
      Service.Desconectar;
    end,
    AddLog
  );
end;

procedure TDesktopView.ExibirTelaInicial;
begin
//  Self.Left := -5;
//  Self.Width := Self.Width + 10;
//
//  Self.Top := -5;
//  Self.Height := Self.Height + 10;
//
//  Rectangle1.Height := Self.Height + 100;
//  Rectangle1.Width := Self.Width + 100;
//  Rectangle1.Position.Y := - 50;
//  Rectangle1.Position.X := - 50;

//  Exit;
  if Assigned(FInicio) then
    Exit;

  FInicio := TInicioView.New(lytClient);
  FInicio.ClientView := lytClient;
  FInicio.OnIniciaChamada(Self.IniciarChamada);
end;

procedure TDesktopView.ServiceConnected(const LocalService: TAndroidBaseService);
begin
  // Called when the connection between the native activity and the service has been established. It is used to obtain the
  // binder object that allows the direct interaction between the native activity and the service.
  Service := TConversaNotifyServiceModule(LocalService);
  Service.FShowLog := ShowLog;
  AddLog :=
    procedure(Value: String)
    begin
      Service.AddLog(Value);
    end;
  Service.OnAtenderChamada := OnAtenderChamada;
  Service.OnRecusarChamada := OnRecusarChamada;
  Service.OnReceberChamada := OnReceberChamada;
  Service.OnFinalizarChamada := OnFinalizarChamada;
  Service.OnCancelarChamada := OnFinalizarChamada;
  Service.OnDestinatarioOcupado := OnDestinatarioOcupado;
  Service.TrazerPraFrente := TrazerPraFrente;
  Service.AppEvents.Add(TConversaAppEvents.Instance);

  if Service.FRecebendoChamada then
  begin
    OnReceberChamada;
    Service.FRecebendoChamada := False;
  end;
end;

procedure TDesktopView.ServiceDisconnected;
begin
  // Called when the connection between the native activity and the service has been unexpectedly lost (e.g. when the user
  // manually stops the service using the 'Settings' system application).
  Service.FShowLog := nil;
  Service := nil;
end;

procedure TDesktopView.TrazerPraFrente;
var
  I: JIntent;
begin
  I := TAndroidHelper.Activity.getIntent;
  I.setFlags(TJIntent.JavaClass.FLAG_ACTIVITY_REORDER_TO_FRONT);
  TAndroidHelper.Activity.startActivity(I);
end;

procedure TDesktopView.ShowLog(sMsg: String; bErro: Boolean);
begin
  TThread.Synchronize(
    nil,
    procedure
    begin
      try
        if bErro then
          ShowMessage(sMsg);

//      Button1.Visible := False;
//        Memo1.Visible := True;
//        Memo1.Lines.Insert(0, sMsg);
      except
      end;
    end
  );
end;

procedure TDesktopView.tmrTesteTimer(Sender: TObject);
begin
  tmrTeste.Enabled := False;
  ConectarServico;
end;

procedure TDesktopView.OnReceberChamada;
begin
  AddLog('ThreadID View: '+ TThread.Current.ThreadID.ToString);
  TThread.Synchronize(
    nil,
    procedure
    begin
      ConfigurarTelaLigacao;
      FChamadaView
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

procedure TDesktopView.OnRecusarChamada;
begin
  OnFinalizarChamada;
end;

procedure TDesktopView.OnAtenderChamada;
begin
  ConfigurarTelaLigacao;
  FChamadaView
    .SetStatus(TChamadaStatus.EmAndamento)
    .OnRecusar(
      procedure
      begin
        FinalizarChamada(True);
      end
    );
end;

procedure TDesktopView.OnCancelarChamada;
begin
  OnFinalizarChamada;
end;

procedure TDesktopView.OnDestinatarioOcupado;
begin
  FChamadaView.lytClient.Visible := False;
  FChamadaView.Rectangle1.Visible := False;
  TThread.Synchronize(
    nil,
    procedure
    begin
      ShowMessage('O destinatário está ocupado em outra ligação!');
    end
  );
end;

procedure TDesktopView.OnFinalizarChamada;
begin
  if not Assigned(FChamadaView) then
    Exit;

  FChamadaView.lytClient.Visible := False;
  FChamadaView.Rectangle1.Visible := False;
end;

procedure TDesktopView.IniciarChamada(User: TUsuario);
begin
  ConfigurarTelaLigacao;
  AddLog('S.FR.I.'+ Service.FRemetente.Identificador);
  FChamadaView
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

procedure TDesktopView.AtenderChamada(bEnviaComando: Boolean);
begin
  ConfigurarTelaLigacao;

  TThread.CreateAnonymousThread(
    procedure
    begin
      Service.AtenderChamada(TOrigemComando.Local, False);
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

procedure TDesktopView.ConfigurarTelaLigacao;
var
  joIdentificador: TJSONObject;
begin
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

      AddLog('S.FR.I.'+ Service.FRemetente.Identificador);
      joIdentificador := IGStrToJSONObject(Service.FRemetente.Identificador);
      try
        if Assigned(joIdentificador) then
          FChamadaView
            .Nome(joIdentificador.IGGetStrDef('nome'))
            .Informacoes(joIdentificador.IGGetStrDef('email'))
      finally
        FreeAndNil(joIdentificador);
      end;
    end
  );
end;

procedure TDesktopView.RecusarChamada(bEnviarComando: Boolean);
begin
  FChamadaView.lytClient.Visible := False;
  FChamadaView.Rectangle1.Visible := False;
  TThread.CreateAnonymousThread(
    procedure
    begin
      Service.RecusarChamada(TOrigemComando.Local);
    end
  ).Start;
  if Assigned(FChamadaView) then
    FreeAndNil(FChamadaView);
end;

procedure TDesktopView.FinalizarChamada(bEnviarComando: Boolean);
begin
  FChamadaView.lytClient.Visible := False;
  FChamadaView.Rectangle1.Visible := False;
  TThread.CreateAnonymousThread(
    procedure
    begin
      Service.FinalizarChamada(TOrigemComando.Local);
    end
  ).Start;
  if Assigned(FChamadaView) then
    FreeAndNil(FChamadaView);
end;

procedure TDesktopView.VivaVoz(Value: Boolean);
begin
  Service.VivaVoz(Value);
end;

procedure TDesktopView.ConectarServico;
begin
  ServiceConnection := TLocalServiceConnection.Create;
  ServiceConnection.OnConnected := ServiceConnected;
  ServiceConnection.OnDisconnected := ServiceDisconnected;
  ServiceConnection.BindService(TConversaNotifyServiceModule.ServiceClassName);
end;

procedure TDesktopView.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FKBBounds.Create(0, 0, 0, 0);
  FNeedOffset := False;
  lytClient.Align := TAlignLayout.Client;
end;

procedure TDesktopView.FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  FKBBounds := TRectF.Create(Bounds);
  FKBBounds.TopLeft := ScreenToClient(FKBBounds.TopLeft);
  FKBBounds.BottomRight := ScreenToClient(FKBBounds.BottomRight);
  lytClient.Align := TAlignLayout.Top;
  lytClient.Height := Self.ClientHeight - FKBBounds.Height;
end;

end.
