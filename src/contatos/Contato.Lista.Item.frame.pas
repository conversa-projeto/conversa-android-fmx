unit Contato.Lista.Item.frame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation;

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
    lblLetraFoto: TLabel;
    procedure rctClientClick(Sender: TObject);
  private
    { Private declarations }
    FID: Integer;
    FIniciarChamada: TProc<Integer>;
  public
    { Public declarations }
    class function New(AOwner: TComponent; ID: Integer): TContatoItem;
    function Nome(Value: String): TContatoItem;
    function Informacao1(Value: String): TContatoItem;
    function IniciarChamada(Proc: TProc<Integer>): TContatoItem;
  end;

implementation

{$R *.fmx}

{ TContatoItem }

class function TContatoItem.New(AOwner: TComponent; ID: Integer): TContatoItem;
begin
  Result := TContatoItem.Create(AOwner);
  Result.Parent := TFmxObject(AOwner);
  Result.Align := TAlignLayout.Client;
  Result.FID := ID;
end;

function TContatoItem.Nome(Value: String): TContatoItem;
begin
  Result := Self;
  Result.lblNome.Text := Value;
  lblLetraFoto.Text := UpperCase(Value[1]);

end;

procedure TContatoItem.rctClientClick(Sender: TObject);
begin
  FIniciarChamada(FID);
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
