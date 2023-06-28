unit Chamada.Teclado.view;

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
  FMX.Effects,
  FMX.Filter.Effects,
  FMX.Forms,
  FMX.Graphics,
  FMX.Layouts,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.Objects,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.Styles.Objects,
  FMX.Types;

type
  TTecladoNumerico = class(TForm)
    GridPanelLayout1: TGridPanelLayout;
    Image1: TImage;
    SpeedButton1: TSpeedButton;
    Image2: TImage;
    Button13: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    lytEdit: TLayout;
    Edit1: TEdit;
    lytClient: TLayout;
    procedure Button1Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TecladoNumerico: TTecladoNumerico;

implementation

{$R *.fmx}

procedure TTecladoNumerico.Button13Click(Sender: TObject);
begin
  Edit1.Text := Edit1.Text.Remove(Pred(Edit1.SelStart), 1);
end;

procedure TTecladoNumerico.Button1Click(Sender: TObject);
var
  iTextLenght: Integer;
  iSelStart: Integer;
begin
  iTextLenght := Edit1.Text.Length;
  iSelStart := Edit1.SelStart;
  if (iSelStart = 0) and (iTextLenght > 0) then
    iSelStart := iTextLenght;

  Edit1.Text := Edit1.Text.Insert(iSelStart, TButton(Sender).Text);

  Edit1.SelStart := iSelStart + 1;
end;

procedure TTecladoNumerico.FormCreate(Sender: TObject);
begin
  VKAutoShowMode := TVKAutoShowMode.Never;
end;

end.
