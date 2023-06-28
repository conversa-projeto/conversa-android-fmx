unit Inicio.Antigo.view;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  System.Messaging,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Forms,
  FMX.Graphics,
  FMX.Layouts,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types,

  System.Permissions,

  Conversa.Notify.Inicio,

  System.Android.Service,

  AndroidApi.Jni.App,
  AndroidApi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Os,
  Androidapi.JNIBridge,
  Androidapi.Helpers,
  Androidapi.JNI.Support,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Net,
  Androidapi.JNI.Provider,

  Contato.Lista.view, IdTCPConnection, IdTCPClient, IdBaseComponent,
  IdComponent, IdUDPBase, IdUDPClient, IdGlobal,
  Chamada.view, FMX.Edit, Datasnap.DBClient, FMX.Memo.Types, FMX.ScrollBox,
  Tipos,
  FMX.Memo;

type
  TInicioAView = class(TForm)
    lytClient: TLayout;
    lytTitleBox: TLayout;
    Rectangle1: TRectangle;
    btnMenu: TButton;
    lytTitle: TLayout;
    btnAcao: TButton;
    lbTitle: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnAcaoClick(Sender: TObject);
  private
    { Private declarations }
    FLista: TContatoListaView;
  public
    { Public declarations }
    ClientView: TLayout;
    IniciarChamada: TProc<TUsuario>;
    class function New(AOwner: TFmxObject): TInicioAView;
    function OnIniciaChamada(Value: TProc<TUsuario>): TInicioAView;
  end;

var
  InicioAView: TInicioAView;

implementation

{$R *.fmx}

class function TInicioAView.New(AOwner: TFmxObject): TInicioAView;
begin
  Result := TInicioAView.Create(AOwner);
  Result.lytClient.Parent := AOwner;
  Result.lytClient.Align := TAlignLayout.Client;
end;

function TInicioAView.OnIniciaChamada(Value: TProc<TUsuario>): TInicioAView;
begin
  Result := Self;
  IniciarChamada := Value;
  FLista.IniciarChamada := Value;
end;

procedure TInicioAView.btnAcaoClick(Sender: TObject);
begin
  FLista.PrepararDataSet;
end;

procedure TInicioAView.FormCreate(Sender: TObject);
begin
  FLista := TContatoListaView.New(lytClient);
end;

end.
