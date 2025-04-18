unit Conversa.FormularioBase;

interface

uses
  System.Classes,
  System.Math,
  System.StrUtils,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  FMX.Ani,
  FMX.Controls,
  FMX.Dialogs,
  FMX.Forms,
  FMX.Graphics,
  FMX.Layouts,
  FMX.Objects,
  FMX.Types,
  PascalStyleScript;

type
  TFormularioBase = class(TForm)
    rctFundo: TRectangle;
    lytClient: TLayout;
    lytClientForm: TLayout;
    lytLogo: TLayout;
    imgLogo: TImage;
    lytTitleBarClient: TLayout;
    rctTitleBar: TRectangle;
  private
    function GetPSSClassName: String;
  protected
    procedure CreateHandle; override;
    procedure DestroyHandle; override;
    procedure DoConversaRestore; virtual;
    procedure DoConversaClose; virtual;
    procedure DoConversaMaximize;
    procedure DoConversaMinimize;
    procedure ShowOnTaskBar;
    procedure HideOfTaskBar;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

constructor TFormularioBase.Create(AOwner: TComponent);
begin
  inherited;
  TPascalStyleScript.Instance.RegisterObject(Self, GetPSSClassName);
end;

procedure TFormularioBase.CreateHandle;
begin
  inherited;
  //
end;

procedure TFormularioBase.DestroyHandle;
begin
  //
  inherited;
end;

function TFormularioBase.GetPSSClassName: String;
begin
  Result := ClassName.Substring(1);
end;

procedure TFormularioBase.DoConversaMinimize;
begin
  Self.WindowState := TWindowState.wsMinimized;
end;

procedure TFormularioBase.DoConversaRestore;
begin
  //
end;

procedure TFormularioBase.DoConversaMaximize;
begin
  if Self.WindowState = TWindowState.wsNormal then
    Self.WindowState := TWindowState.wsMaximized
  else
    Self.WindowState := TWindowState.wsNormal;
end;

procedure TFormularioBase.DoConversaClose;
begin
  Self.Close;
end;

end.
