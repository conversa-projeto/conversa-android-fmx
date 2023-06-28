unit Chamada.view;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Objects, FMX.Layouts;

type
  TChamadaStatus = (Chamando, Recebendo, EmAndamento);
  TChamadaView = class(TForm)
    lytClient: TLayout;
    Layout2: TLayout;
    Rectangle1: TRectangle;
    Layout4: TLayout;
    Circle1: TCircle;
    Image1: TImage;
    Layout3: TLayout;
    Layout5: TLayout;
    btnAtender: TSpeedButton;
    Image2: TImage;
    btnVivaVoz: TSpeedButton;
    Image4: TImage;
    Image5: TImage;
    Circle2: TCircle;
    btnFinalizar: TSpeedButton;
    Circle3: TCircle;
    Image3: TImage;
    Layout6: TLayout;
    lbNome: TLabel;
    lbInformacao: TLabel;
    procedure btnFinalizarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnVivaVozClick(Sender: TObject);
    procedure btnAtenderClick(Sender: TObject);
  private
    { Private declarations }
    FVivavoz: Boolean;
    FOnAtender: TProc;
    FOnVivaVoz: TProc<Boolean>;
    FOnRecusar: TProc;
    procedure SetStatusVivaVoz(Value: Boolean);
  public
    { Public declarations }
    class function New(AOwner: TFmxObject): TChamadaView;
    function Status(Value: TChamadaStatus): TChamadaView;
    function Nome(Value: String): TChamadaView;
    function Informacoes(Value: String): TChamadaView;

    function SetStatus(const Value: TChamadaStatus): TChamadaView;
    function OnAtender(Proc: TProc): TChamadaView;
    function OnVivaVoz(Proc: TProc<Boolean>): TChamadaView;
    function OnRecusar(Proc: TProc): TChamadaView;
  end;

var
  ChamadaView: TChamadaView;

implementation

{$R *.fmx}

{ TForm1 }

class function TChamadaView.New(AOwner: TFmxObject): TChamadaView;
begin
  Result := TChamadaView.Create(AOwner);
  Result.lytClient.Parent := AOwner;
  Result.lytClient.Align := TAlignLayout.Contents;
  Result.Rectangle1.Parent := AOwner;
  Result.Rectangle1.Align := TAlignLayout.Contents;
  Result.Rectangle1.BringToFront;
  Result.lytClient.BringToFront;
end;

procedure TChamadaView.btnVivaVozClick(Sender: TObject);
begin
  SetStatusVivaVoz(not FVivavoz);
end;

procedure TChamadaView.FormCreate(Sender: TObject);
begin
  FVivavoz := False;
  Informacoes('');
end;

function TChamadaView.Status(Value: TChamadaStatus): TChamadaView;
begin
  Result := Self;
  case Value of
    TChamadaStatus.Chamando:
    begin
      btnAtender.Visible := False;
      btnVivaVoz.Visible := False;
      btnFinalizar.Align := TAlignLayout.HorzCenter;
    end;
    TChamadaStatus.Recebendo:
    begin
      btnAtender.Visible := True;
      btnVivaVoz.Visible := False;
      btnFinalizar.Visible := True;
    end;
    TChamadaStatus.EmAndamento:
    begin
      btnAtender.Visible := False;
      btnVivaVoz.Visible := True;
      btnFinalizar.Visible := True;
    end;
  end;
end;

function TChamadaView.Nome(Value: String): TChamadaView;
begin
  Result := Self;
  lbNome.Text := Value;
end;

function TChamadaView.SetStatus(const Value: TChamadaStatus): TChamadaView;
begin
  Result := Self;
  case Value of
    TChamadaStatus.Chamando:
    begin
      btnAtender.Visible := False;
      btnVivaVoz.Visible := False;
    end;
    TChamadaStatus.Recebendo:
    begin
      btnAtender.Visible := True;
      btnVivaVoz.Visible := False;
    end;
    TChamadaStatus.EmAndamento:
    begin
      btnAtender.Visible := False;
      btnVivaVoz.Visible := True;
    end;
  end;
end;

function TChamadaView.OnAtender(Proc: TProc): TChamadaView;
begin
  Result := Self;
  FOnAtender := Proc;
end;

function TChamadaView.OnVivaVoz(Proc: TProc<Boolean>): TChamadaView;
begin
  Result := Self;
  FOnVivaVoz := Proc;
end;

function TChamadaView.OnRecusar(Proc: TProc): TChamadaView;
begin
  Result := Self;
  FOnRecusar := Proc;
end;

procedure TChamadaView.btnAtenderClick(Sender: TObject);
begin
  FOnAtender;
end;

procedure TChamadaView.btnFinalizarClick(Sender: TObject);
begin
//  lytClient.Visible := False;
//  Rectangle1.Visible := False;
  FOnRecusar;
//  Self.DisposeOf;
end;

function TChamadaView.Informacoes(Value: String): TChamadaView;
begin
  Result := Self;
  lbInformacao.Text := Value;
end;

procedure TChamadaView.SetStatusVivaVoz(Value: Boolean);
begin
  btnVivaVoz.Pressed := Value;
  FVivavoz := Value;
//  VivaVozDesativado.Visible := not Value;
//  imgVivaVozAtivado.Visible := Value;
  FOnVivaVoz(Value);
end;

end.
