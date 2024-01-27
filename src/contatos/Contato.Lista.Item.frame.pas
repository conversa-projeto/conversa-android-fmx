unit Contato.Lista.Item.frame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, Conversa.Gravatar;

type
  TContatoItem = class(TFrame)
    rctClient: TRectangle;
    lytFoto: TLayout;
    crclFoto: TCircle;
    lytInformacoes: TLayout;
    lblNome: TLabel;
    lblInformacao1: TLabel;
    Line1: TLine;
    lytClient: TLayout;
    imgFoto: TImage;
    procedure rctClientClick(Sender: TObject);
  private
    { Private declarations }
    FIniciarChamada: TProc<Integer>;
  public
    { Public declarations }
    ID: Integer;
    class function New(AOwner: TComponent; AID: Integer): TContatoItem;
    function Nome(Value: String): TContatoItem;
    function Informacao1(Value: String): TContatoItem;
    function IniciarChamada(Proc: TProc<Integer>): TContatoItem;
  end;

implementation

{$R *.fmx}

{ TContatoItem }

class function TContatoItem.New(AOwner: TComponent; AID: Integer): TContatoItem;
begin
  Result := TContatoItem.Create(AOwner);
  Result.Parent := TFmxObject(AOwner);
  Result.Align := TAlignLayout.Client;
  Result.ID := AID;
end;

function TContatoItem.Nome(Value: String): TContatoItem;
var
  s: TStringStream;
begin
  Result := Self;
  Result.lblNome.Text := Value;
  Result.imgFoto.MultiResBitmap.Clear;
  s := TStringStream.Create;
  try
    with TGravatar.Instance.GetGravatar(Value[1], value[1]+'@teste.com') do
    begin
      crclFoto.Fill.Color := Color;
      Image.SaveToStream(s);
    end;
    s.Position := 0;
    Result.imgFoto.MultiResBitmap.LoadItemFromStream(s, 50);
  finally
    s.DisposeOf;
  end;
end;

procedure TContatoItem.rctClientClick(Sender: TObject);
begin
//  FIniciarChamada(FID);
end;

function TContatoItem.Informacao1(Value: String): TContatoItem;
begin
  Result := Self;
  Result.lblInformacao1.Text := Value;
end;

function TContatoItem.IniciarChamada(Proc: TProc<Integer>): TContatoItem;
begin
  Result := Self;
  FIniciarChamada := Proc ;
end;

end.
