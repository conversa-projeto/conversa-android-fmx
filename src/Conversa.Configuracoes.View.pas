unit Conversa.Configuracoes.View;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Types,
  System.JSON,
  Androidapi.Helpers,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.App, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, FMX.TabControl, FMX.Objects, FMX.Effects;

type
  TConfiguracoesView = class(TForm)
    lytClient: TLayout;
    IdHTTP1: TIdHTTP;
    Layout1: TLayout;
    TabControl1: TTabControl;
    StyleBook1: TStyleBook;
    tshServidor: TTabItem;
    tshUsuario: TTabItem;
    tshSenha: TTabItem;
    lytServidor: TLayout;
    rctServidor: TRectangle;
    edtServidor: TEdit;
    lnServidor: TLine;
    lytUsuario: TLayout;
    rctUsuario: TRectangle;
    txtUsuario: TText;
    edtUsuario: TEdit;
    lnUsuario: TLine;
    lytSenha: TLayout;
    rctSenha: TRectangle;
    txtSenha: TText;
    edtSenha: TEdit;
    lnSenha: TLine;
    rctProximo: TRectangle;
    btnProximo: TSpeedButton;
    Label1: TLabel;
    effShdProximo: TShadowEffect;
    rctAnterior: TRectangle;
    btnAnterior: TSpeedButton;
    lblAnterior: TLabel;
    effShdAnterior: TShadowEffect;
    lytLogo: TLayout;
    lytLogoCenter: TLayout;
    txtServidor: TText;
    tmrCarregar: TTimer;
    rctFundo: TRectangle;
    imgLogoMarca: TImage;
    procedure btnProximoClick(Sender: TObject);
    procedure btnAnteriorClick(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure tmrCarregarTimer(Sender: TObject);
  private type
    TMove = (Inicio, Proximo, Anterior);
  private
    { Private declarations }
    FLogin: TJSONObject;
    FOnConfigurado: TProc;
    FOnAddLog: TProc<String>;
    procedure SalvarConfiguracao;
    procedure Validar(joParams: TJSONObject);
    procedure Mover(Direcao: TMove);
  public
    { Public declarations }
    class function EstaConfigurado: Boolean;
    class procedure New(AOwner: TFmxObject; OnConfigurado: TProc; OnAddLog: TProc<String>);
  end;

implementation

{$R *.fmx}

class function TConfiguracoesView.EstaConfigurado: Boolean;
begin
  with TAndroidHelper.Context.getSharedPreferences(StringToJString('conversa_pref'), TJActivity.JavaClass.MODE_PRIVATE) do
    Result := getBoolean(StringToJString('configurado'), False);
end;

class procedure TConfiguracoesView.New(AOwner: TFmxObject; OnConfigurado: TProc; OnAddLog: TProc<String>);
begin
  with TConfiguracoesView.Create(AOwner) do
  begin
    Mover(TMove.Inicio);
    FOnAddLog := OnAddLog;
    FOnConfigurado := OnConfigurado;
    lytClient.Parent := AOwner;
    lytClient.Align := TAlignLayout.Client;
    tmrCarregar.Enabled := True;
  end;
end;

procedure TConfiguracoesView.btnAnteriorClick(Sender: TObject);
begin
  Mover(TMove.Anterior);
end;

procedure TConfiguracoesView.btnProximoClick(Sender: TObject);
begin
  Mover(TMove.Proximo);
end;

procedure TConfiguracoesView.Mover(Direcao: TMove);
begin
  if (Direcao = TMove.Proximo) and (TabControl1.ActiveTab.Index = 2) then
  begin
    if edtServidor.Text.Trim.IsEmpty then
      raise Exception.Create('Informe o servidor!');

    if edtUsuario.Text.Trim.IsEmpty then
      raise Exception.Create('Informe o email!');

    if edtSenha.Text.Trim.IsEmpty then
      raise Exception.Create('Informe a senha!');

    Validar(
      TJSONObject.Create
        .AddPair('host', edtServidor.Text)
        .AddPair('email', edtUsuario.Text)
        .AddPair('senha', edtSenha.Text)
    );
  end;

  case Direcao of
    TMove.Inicio: TabControl1.First(TTabTransition.None);
    TMove.Proximo: TabControl1.Next;
    TMove.Anterior: TabControl1.Previous;
  end;
  rctAnterior.Visible := TabControl1.ActiveTab.Index > 0;
end;

procedure TConfiguracoesView.SalvarConfiguracao;
begin
  with TAndroidHelper.Context.getSharedPreferences(StringToJString('conversa_pref'), TJActivity.JavaClass.MODE_PRIVATE).edit do
  begin
    putString(StringToJString('host'), StringToJString(edtServidor.Text));
    putInt(StringToJString('id'), FLogin.GetValue<Integer>('id'));
    putString(StringToJString('nome'), StringToJString(FLogin.GetValue<String>('nome')));
    putString(StringToJString('email'), StringToJString(FLogin.GetValue<String>('email')));
    putString(StringToJString('telefone'), StringToJString(FLogin.GetValue<String>('telefone')));
    putBoolean(StringToJString('configurado'), True);
    putBoolean(StringToJString('conectar_automatico'), True);
    apply;
  end;
end;

procedure TConfiguracoesView.TabControl1Change(Sender: TObject);
begin
  rctAnterior.Visible := TabControl1.ActiveTab.Index > 0;
end;

procedure TConfiguracoesView.tmrCarregarTimer(Sender: TObject);
begin
  tmrCarregar.Enabled := False;
  with TAndroidHelper.Context.getSharedPreferences(StringToJString('conversa_pref'), TJActivity.JavaClass.MODE_PRIVATE) do
  begin
    try
      edtServidor.Text :=  JStringToString(getString(StringToJString('host'), StringToJString('54.232.35.143')));
      edtServidor.Text := '192.168.1.5';
    except
    end;
    try
    edtUsuario.Text := JStringToString(getString(StringToJString('email'), StringToJString('')));
    edtUsuario.Text := 'd1@hotmail.com';
    except
    end;
    try
    edtSenha.Text := JStringToString(getString(StringToJString('senha'), StringToJString('')));
    edtSenha.Text := '123';
    except
    end;
  end;
end;

procedure TConfiguracoesView.Validar(joParams: TJSONObject);
begin
  TThread.CreateAnonymousThread(
    procedure
    var
//      Get: TIdHTTP;
      Data: TStringStream;
      joRetorno: TJSONObject;
    begin
      try
        Data := TStringStream.Create(UTF8Encode(joParams.ToJSON));
        with TIdHTTP.Create(nil) do
        try
          Request.ContentType := 'application/json';
          Request.ContentEncoding := 'utf-8';
          try
            joRetorno := TJSONObject(TJSONValue.ParseJSONValue(Post('http://'+ joParams.GetValue<String>('host') +':90/login', data)));
            if not Assigned(joRetorno) then
              raise Exception.Create('Sem retorno');

            TThread.Synchronize(
              nil,
              procedure
              begin
                FLogin := joRetorno;
                TThread.CreateAnonymousThread(
                  procedure
                  begin
                    TThread.Synchronize(
                      nil,
                      procedure
                      begin
                        lytClient.Visible := False;
                        SalvarConfiguracao;
                        FreeAndNil(FLogin);
                        FOnConfigurado;
                      end
                    );
                  end
                ).Start;
              end
            );
          except on E: Exception do
            TThread.Synchronize(
              nil,
              procedure
              begin
                FOnAddLog('Falha no Login'+ sLineBreak + E.Message);
                raise Exception.Create('Falha no login!');
              end
            );
          end;
        finally
          Free;
        end;
      finally
        if Assigned(Data) then
          FreeAndNil(Data);
        FreeAndNil(joParams);
      end;
    end
  ).Start;
end;

end.
