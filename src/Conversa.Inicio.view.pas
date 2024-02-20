unit Conversa.Inicio.view;

interface

uses
  System.Android.Service,
  System.Classes,
  System.Messaging,
  System.Permissions,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  Datasnap.DBClient,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Layouts,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.Objects,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.Types,
  IdBaseComponent,
  IdComponent,
  IdGlobal,
  IdTCPClient,
  IdTCPConnection,
  IdUDPBase,
  IdUDPClient,
  Androidapi.Helpers,
  AndroidApi.Jni.App,
  AndroidApi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Net,
  Androidapi.JNI.Os,
  Androidapi.JNI.Provider,
  Androidapi.JNI.Support,
  Androidapi.JNIBridge,
  Chamada.view,
  Contato.Lista.view,
  Conversa.Notify.Inicio,
  Conversa.Configuracoes.View,
  Tipos;

type
  TInicioView = class(TForm)
    lytClient: TLayout;
    lytTitleBox: TLayout;
    Rectangle1: TRectangle;
    lytTitle: TLayout;
    btnAcao: TButton;
    lbTitle: TLabel;
    rctFundo: TRectangle;
    btnMenu: TButton;
    Rectangle2: TRectangle;
    procedure FormCreate(Sender: TObject);
    procedure btnAcaoClick(Sender: TObject);
    procedure btnMenuClick(Sender: TObject);
  private
    { Private declarations }
    FLista: TContatoListaView;
  public
    { Public declarations }
    ClientView: TLayout;
    IniciarChamada: TProc<TUsuario>;
    class function New(AOwner: TFmxObject): TInicioView;
    function OnIniciaChamada(Value: TProc<TUsuario>): TInicioView;
  end;

var
  InicioView: TInicioView;

implementation

{$R *.fmx}

uses Conversa.Desktop.view;

class function TInicioView.New(AOwner: TFmxObject): TInicioView;
begin
  Result := TInicioView.Create(AOwner);
  Result.lytClient.Parent := AOwner;
  Result.lytClient.Align := TAlignLayout.Client;
end;

function TInicioView.OnIniciaChamada(Value: TProc<TUsuario>): TInicioView;
begin
  Result := Self;
  IniciarChamada := Value;
  FLista.IniciarChamada := Value;
end;

procedure TInicioView.btnAcaoClick(Sender: TObject);
begin
  FLista.PrepararDataSet;
end;

procedure TInicioView.btnMenuClick(Sender: TObject);
begin
  DesktopView.ExibirTelaConfiguracao;
end;

procedure TInicioView.FormCreate(Sender: TObject);
begin
  FLista := TContatoListaView.New(lytClient);
//  btnAcao.Visible := False;
//  btnMenu.Visible := False;
end;

end.
