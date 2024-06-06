unit Contato.Lista.Item.frame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, Conversa.Gravatar,

  System.StrUtils,
  System.DateUtils;

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
    Text1: TText;
    procedure rctClientClick(Sender: TObject);
  private
    { Private declarations }
    FIniciarChamada: TProc<Integer>;
    function FormatDateTime(Value: TDateTime): String;
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
//  Exit;
  s := TStringStream.Create;
  try
    with TGravatar.Instance.GetGravatar(Value[1], value[1]+'@teste.com') do
    begin
      Result.Text1.Text := Value[1];
      Result.imgFoto.Visible := False;
      crclFoto.Fill.Color := Color;
//      Image.SaveToStream(s);
    end;
//    s.Position := 0;
//    Result.imgFoto.MultiResBitmap.LoadItemFromStream(s, 50);
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

function TContatoItem.FormatDateTime(Value: TDateTime): String;
var
  Between: Int64;
begin
  Between := SecondsBetween(Value, Now);
  if Between = 0 then
    Exit('agora');

  if Between <= SecsPerMin then
    Exit(Between.ToString +' segundo'+ IfThen(Between = 1, '', 's') +' atrás');

  Between := MinutesBetween(Value, Now);
  if Between <= MinsPerHour then
    Exit(Between.ToString +' minuto'+ IfThen(Between = 1, '', 's') +' atrás');

  Between := HoursBetween(Value, Now);
  if Between <= HoursPerDay then
    Exit(Between.ToString +' hora'+ IfThen(Between = 1, '', 's') +' atrás');

  Between := DaysBetween(Value, Now);
  if Between = 1 then
    Exit('ontem')
  else
  if YearOf(Value) <> YearOf(Now) then
  begin
    Exit(System.DateUtils.FormatDateTime(Value, FormatSettings.ShortDateFormat));
  end
  else
    Exit(DateToStr(Value))
end;

end.
