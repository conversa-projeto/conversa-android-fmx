unit Conversa.Tela.Inicial.view;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  Conversa.Login,
  Conversa.Dados,
  FMX.Objects,
  FMX.Layouts,
  FMX.Ani,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  Conversa.Configuracoes,
  Conversa.Principal,
  Conversa.ModalView,
  Conversa.Visualizador.Midia,
  Conversa.Eventos,
  PascalStyleScript, FMX.Gestures;

type
  TTelaInicial = class(TForm)
    tmrShow: TTimer;
    rctFundo: TRectangle;
    lytClient: TLayout;
    rctTitleBar: TRectangle;
    lytLogo: TLayout;
    imgLogo: TImage;
    lytTitleBarClient: TLayout;
    rctAvisoConexao: TRectangle;
    txtAvisoConexao: TText;
    txtTitulo: TText;
    lytClientForm: TLayout;
    procedure FormShow(Sender: TObject);
    procedure tmrShowTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState);
  private
    procedure Iniciar;
    procedure ExibirTelaPrincipal;
    procedure StatusConexao(const Sender: TObject; const M: Conversa.Eventos.TMessage);
  protected
    procedure CreateHandle; override;
    procedure DestroyHandle; override;
    procedure DoConversaClose;
  public
    ModalView: TModalView;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoConversaRestore;
  end;

var
  TelaInicial: TTelaInicial;

implementation

uses
  FMX.VirtualKeyboard,
  FMX.Platform,
  Conversa.Conexao.AvisoInicioSistema,
  Conversa.Configurar.Conexao,
  Conversa.Chat.Listagem;

{$R *.fmx}

constructor TTelaInicial.Create(AOwner: TComponent);
begin
  inherited;
  rctAvisoConexao.Visible := False;
  TMessageManager.DefaultManager.SubscribeToMessage(TEventoStatusConexao, StatusConexao);

  if (Configuracoes.Escala <> 0) and (Configuracoes.Escala <> lytClient.Scale.X) then
  begin
    lytClient.Scale.X := Configuracoes.Escala;
    lytClient.Scale.Y := Configuracoes.Escala;
  end;
end;

destructor TTelaInicial.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TEventoStatusConexao, StatusConexao);
  inherited;
end;

procedure TTelaInicial.CreateHandle;
begin
  inherited;
  //
end;

procedure TTelaInicial.DestroyHandle;
begin
  //
  inherited;
end;

procedure TTelaInicial.FormActivate(Sender: TObject);
begin
  inherited;
  if Assigned(Chats) and Assigned(Chats.Chat) then
    Chats.Chat.ValidarVisualizacao;
end;

procedure TTelaInicial.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var
  FService: IFMXVirtualKeyboardService;
begin
  if Key = vkHardwareBack then
  begin
    TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(FService));
    // Se está exibindo o teclado, apenas sai fora, pois não pode sobrescrever
    if Assigned(FService) and (TVirtualKeyboardState.Visible in FService.VirtualKeyboardState) then
      Exit
    else
    if Assigned(Chats) and Assigned(Chats.Chat) and Chats.Chat.Visible then
      Chats.Chat.OcultarChat
    else
      Exit;

    Key := 0;
  end;
end;

procedure TTelaInicial.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  if not (ssCtrl in Shift) then
    Exit;

  if WheelDelta > 0 then
  begin
    if lytClient.Scale.X > 1.5 then
      Exit;

    lytClient.Scale.X := lytClient.Scale.X + 0.1;
    lytClient.Scale.Y := lytClient.Scale.Y + 0.1;

    Width := Width + 10;
  end
  else
  begin
    if lytClient.Scale.X < 0.5 then
      Exit;

    lytClient.Scale.X := lytClient.Scale.X - 0.1;
    lytClient.Scale.Y := lytClient.Scale.Y - 0.1;

    Width := Width - 10;
  end;

  Configuracoes.Escala := lytClient.Scale.X;
  Configuracoes.Save;

  Application.ProcessMessages;
end;

procedure TTelaInicial.FormShow(Sender: TObject);
begin
  inherited;
  ModalView := TModalView.Create(lytClientForm);
  tmrShow.Enabled := True;
end;

procedure TTelaInicial.tmrShowTimer(Sender: TObject);
begin
  inherited;
  tmrShow.Enabled := False;
  Iniciar;
end;

procedure TTelaInicial.Iniciar;
begin
  if TConfigurarConexao.PrecisaConfigurar(Iniciar) then
    Exit;

  if TConexaoFalhaInicio.FalhaConexao(Iniciar) then
    Exit;

  TLogin.New(lytClientForm, ExibirTelaPrincipal);
end;

procedure TTelaInicial.DoConversaClose;
begin
  {$IFDEF DEBUG}
  Close;
  {$ELSE}
//  ShowWindow(FormToHWND(Self), SW_HIDE);
  {$ENDIF}
end;

procedure TTelaInicial.DoConversaRestore;
begin
  Self.Activate;
end;

procedure TTelaInicial.ExibirTelaPrincipal;
begin
  TChatListagem.New(lytClientForm);
//  with TPrincipalView.New(lytClientForm) do
//  begin
//    lytTitleBarClient.Parent := Self.lytTitleBarClient;
//    lytTitleBarClient.Align := TAlignLayout.Client;
//    txtUserLetra.Text := Dados.FDadosApp.Usuario.Abreviatura;
//  end;
  Dados.CarregarContatos;
  Dados.CarregarConversas;
  Dados.tmrAtualizarMensagens.Enabled := True;
end;

procedure TTelaInicial.StatusConexao(const Sender: TObject; const M: Conversa.Eventos.TMessage);
begin
  rctAvisoConexao.Visible := TEventoStatusConexao(M).Value <> 1;
end;

procedure TTelaInicial.FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
var
  FKBBounds: TRectF;
begin
  FKBBounds := TRectF.Create(Bounds);
  FKBBounds.TopLeft := ScreenToClient(FKBBounds.TopLeft);
  FKBBounds.BottomRight := ScreenToClient(FKBBounds.BottomRight);
  rctFundo.Align := TAlignLayout.Top;
  rctFundo.Height := Self.ClientHeight - FKBBounds.Height;
  if Assigned(Chats) and Assigned(Chats.Chat) and Chats.Chat.Visible then
    Chats.Chat.PosicionarUltima;
end;

procedure TTelaInicial.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  rctFundo.Align := TAlignLayout.Client
end;

end.
