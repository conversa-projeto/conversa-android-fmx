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
  IdTCPClient, IdHTTP;

type
  TConfiguracoesView = class(TForm)
    lytClient: TLayout;
    Layout1: TLayout;
    lytServidor: TLayout;
    lbServidor: TLabel;
    edtServidor: TEdit;
    lytUsuario: TLayout;
    lbUsuario: TLabel;
    edtUsuario: TEdit;
    lytSenha: TLayout;
    lbSenha: TLabel;
    edtSenha: TEdit;
    btnConfirmar: TButton;
    IdHTTP1: TIdHTTP;
    procedure FormShow(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
  private
    { Private declarations }
    FLogin: TJSONObject;
    FOnConfigurado: TProc;
    procedure SalvarConfiguracao;
    procedure Validar(joParams: TJSONObject);
  public
    { Public declarations }
    class function EstaConfigurado: Boolean;
    class procedure New(AOwner: TFmxObject; OnConfigurado: TProc);
  end;

implementation

{$R *.fmx}

class function TConfiguracoesView.EstaConfigurado: Boolean;
begin
  with TAndroidHelper.Context.getSharedPreferences(StringToJString('conversa_pref'), TJActivity.JavaClass.MODE_PRIVATE) do
    Result := getBoolean(StringToJString('configurado'), False);
end;

class procedure TConfiguracoesView.New(AOwner: TFmxObject; OnConfigurado: TProc);
begin
  with TConfiguracoesView.Create(AOwner) do
  begin
    FOnConfigurado := OnConfigurado;
    lytClient.Parent := AOwner;
    lytClient.Align := TAlignLayout.Client;
  end;
end;

procedure TConfiguracoesView.btnConfirmarClick(Sender: TObject);
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

procedure TConfiguracoesView.FormShow(Sender: TObject);
begin
  with TAndroidHelper.Context.getSharedPreferences(StringToJString('conversa_pref'), TJActivity.JavaClass.MODE_PRIVATE) do
  begin
    edtServidor.Text :=  JStringToString(getString(StringToJString('host'), StringToJString('54.232.35.143')));
    edtUsuario.Text := IntToStr(getInt(StringToJString('usuario'), 1));
    edtSenha.Text := JStringToString(getString(StringToJString('senha'), StringToJString('')));
  end;
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
          except
            TThread.Synchronize(
              nil,
              procedure
              begin
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
