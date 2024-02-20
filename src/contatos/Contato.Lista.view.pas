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
  Conversa.App.Events,
  Tipos,
  Helper.dataSet,
  Androidapi.JNI.JavaTypes,
  Chamada.view, IdUDPBase, IdUDPClient, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, Androidapi.Helpers, Androidapi.JNI.App,
  Contato.Lista.Item.frame,
  REST.API,
  REST.API.Thread,
  FMX.ListBox, System.JSON;

type
  TListBoxItem = class(FMX.ListBox.TListBoxItem)
  public
    ContatoItem: TContatoItem;
  end;
  TContatoListaView = class(TForm)
    lytClient: TLayout;
    cdsContatos: TClientDataSet;
    cdsContatosid: TIntegerField;
    cdsContatosuser_name: TStringField;
    cdsContatosnome: TStringField;
    cdsContatosnumero: TStringField;
    cdsContatosuser: TStringField;
    cdsContatostelefone: TStringField;
    cdsContatosemail: TStringField;
    tmrCarregar: TTimer;
    lstContatos: TListBox;
    procedure tmrCarregarTimer(Sender: TObject);
    procedure lvContatosClick(Sender: TObject);
    procedure lstContatosItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
  private
    { Private declarations }
    FHost: String;
    FUserID: Integer;
    procedure PrepararRes;
    procedure ObterHost;
  public
    { Public declarations }
    IniciarChamada: TProc<TUsuario>;
    class function New(AOwner: TFmxObject): TContatoListaView;
    procedure PrepararDataSet;
    procedure CarregarLista;
    procedure Iniciar(ID: Integer);
  end;

var
  ContatoListaView: TContatoListaView;

implementation

{$R *.fmx}

{ TContatoListaView }

class function TContatoListaView.New(AOwner: TFmxObject): TContatoListaView;
begin
  Result := TContatoListaView.Create(AOwner);
  Result.lytClient.Parent := AOwner;
  Result.lytClient.Align := TAlignLayout.Client;
  Result.PrepararRes;
  Result.cdsContatos.CreateDataSet;
  Result.ObterHost;



//  Result.CarregarLista;

//  Result.lvContatos.StyleLookup := 'ListView1Style1';
//  Result.lvContatos.Repaint;
//  Result.lvContatos.ItemAppearanceObjects.HeaderObjects.Text.TextColor := TAlphaColors.Red;
//  Result.lvContatos.ItemAppearanceObjects.FooterObjects.Text.TextColor := TAlphaColors.Red;

  Result.tmrCarregar.Enabled := True;
end;

procedure TContatoListaView.ObterHost;
begin
  with TAndroidHelper.Context.getSharedPreferences(StringToJString('conversa_pref'), TJActivity.JavaClass.MODE_PRIVATE) do
  begin
    FHost := 'http://'+ JStringToString(getString(StringToJString('host'), StringToJString('54.232.35.143'))) +':90/usuario/contatos';
    FUserID := getInt(StringToJString('id'), 0);
  end;
end;

procedure TContatoListaView.lstContatosItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  Iniciar(Item.ContatoItem.ID);
end;

procedure TContatoListaView.lvContatosClick(Sender: TObject);
//var
//  U: TUsuario;
begin
//  U.ID := cdsContatos.IGGetInt('id');
//  U.Nome := cdsContatos.IGGetStr('nome');
//  U.Email := cdsContatos.IGGetStr('email') + ' - '+ cdsContatos.RecNo.ToString;
//  U.Telefone := cdsContatos.IGGetStr('telefone');
//  if Assigned(IniciarChamada) then
//    IniciarChamada(U)
//  else
//    raise Exception.Create('Método não atribuído!');
end;

procedure TContatoListaView.PrepararDataSet;
begin
  CarregarLista
end;

procedure TContatoListaView.PrepararRes;
begin
  TConversaAppEvents.Instance.Add(
    TConversaAppEventType.Conectado,
    procedure
    begin
      TThread.Synchronize(
        nil,
        procedure
        begin
          ObterHost;
          CarregarLista;
        end
      );
    end
  );
end;

procedure TContatoListaView.tmrCarregarTimer(Sender: TObject);
begin
  CarregarLista;
end;

procedure TContatoListaView.CarregarLista;
var
  Item: TListBoxItem;
begin
  tmrCarregar.Enabled := False;

  lstContatos.Clear;
  cdsContatos.EmptyDataSet;
  TRESTAPIThread.Create
    .GET(
      TRESTAPI.Create
        .Headers(TJSONObject.Create.AddPair('uid', FUserID))
        .Host(FHost)
    )
    .Start(
      procedure(Response: TResponseThread)
      begin
        if Response.Status = TResponseStatus.Sucess then
        begin
          cdsContatos.LoadFromJSONArray(Response.ToJSON.AsType<TJSONArray>);
          cdsContatos.First;
          lstContatos.BeginUpdate;
          try
            while not cdsContatos.Eof do
            try
              Item := TListBoxItem.Create(nil);
              Item.Text := '';
              Item.Height := 60;
              Item.Selectable := False;
              Item.Tag := cdsContatos.IGGetInt('id');
              Item.ContatoItem :=
                TContatoItem.New(Item, cdsContatos.IGGetInt('id'))
                  .Nome(cdsContatos.IGGetStr('nome'))
                  .Informacao1(cdsContatos.IGGetStr('email'))
                  .IniciarChamada(Iniciar);
              lstContatos.AddObject(Item);
            finally
              cdsContatos.Next;
            end;
          finally
            lstContatos.EndUpdate;
          end;
        end;
      end
    );
end;

procedure TContatoListaView.Iniciar(ID: Integer);
var
  U: TUsuario;
begin
  if not cdsContatos.Locate('id', ID, []) then
    raise Exception.Create('Contato não encontrado!');

  U.ID := cdsContatos.IGGetInt('id');
  U.Nome := cdsContatos.IGGetStr('nome');
  U.Email := cdsContatos.IGGetStr('email');
  U.Telefone := cdsContatos.IGGetStr('telefone');
  if Assigned(IniciarChamada) then
    IniciarChamada(U)
  else
    raise Exception.Create('Método não atribuído!');
end;

end.
