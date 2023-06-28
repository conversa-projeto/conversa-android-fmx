unit Contato.Lista.view;

interface

uses
  System.Bindings.Outputs,
  System.Classes,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  Data.Bind.Components,
  Data.Bind.DBScope,
  Data.Bind.EngExt,
  Data.DB,
  Datasnap.DBClient,
  Fmx.Bind.DBEngExt,
  Fmx.Bind.Editors,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Layouts,
  FMX.ListView,
  FMX.ListView.Adapters.Base,
  FMX.ListView.Appearances,
  FMX.ListView.Types,
  FMX.StdCtrls,
  FMX.Types,
  Tipos,
  Helper.dataSet,
  Extend.DataSet,
  Androidapi.JNI.JavaTypes,
  Chamada.view, IdUDPBase, IdUDPClient, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, Androidapi.Helpers, Androidapi.JNI.App;

type
  TContatoListaView = class(TForm)
    lytClient: TLayout;
    cdsContatos: TClientDataSet;
    cdsContatosid: TIntegerField;
    cdsContatosuser_name: TStringField;
    cdsContatosnome: TStringField;
    cdsContatosnumero: TStringField;
    ListView1: TListView;
    BindSourceDB1: TBindSourceDB;
    BindingsList: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    cdsContatosuser: TStringField;
    cdsContatostelefone: TStringField;
    cdsContatosemail: TStringField;
    procedure ListView1ItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure ListView1PullRefresh(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    IniciarChamada: TProc<TUsuario>;
    class function New(AOwner: TFmxObject): TContatoListaView;
    procedure PrepararDataSet;
  end;

var
  ContatoListaView: TContatoListaView;

implementation

{$R *.fmx}

{ TContatoListaView }

procedure TContatoListaView.ListView1PullRefresh(Sender: TObject);
begin
  cdsContatos
    .RESTClose
    .RESTOpen;
end;

class function TContatoListaView.New(AOwner: TFmxObject): TContatoListaView;
begin
  Result := TContatoListaView.Create(AOwner);
  Result.lytClient.Parent := AOwner;
  Result.lytClient.Align := TAlignLayout.Client;

  with Result, TAndroidHelper.Context.getSharedPreferences(StringToJString('conversa_pref'), TJActivity.JavaClass.MODE_PRIVATE) do
    cdsContatos
      .RESTCreate('http://'+ JStringToString(getString(StringToJString('host'), StringToJString('54.232.35.143'))) +':90/usuario/contatos')
      .RESTUserID(getInt(StringToJString('id'), 0))
      .RESTRootElement('');

  Result.cdsContatos
    .RESTClose
    .RESTOpen;
end;

procedure TContatoListaView.ListView1ItemClick(const Sender: TObject; const AItem: TListViewItem);
var
  U: TUsuario;
begin
  U.ID := cdsContatos.IGGetInt('id');
  U.Nome := cdsContatos.IGGetStr('nome');
  U.Email := cdsContatos.IGGetStr('email');
  U.Telefone := cdsContatos.IGGetStr('telefone');
  if Assigned(IniciarChamada) then
    IniciarChamada(U)
  else
    raise Exception.Create('Método não atribuído!');
end;

procedure TContatoListaView.PrepararDataSet;
begin
  cdsContatos
    .RESTClose
    .RESTOpen;
end;

end.
