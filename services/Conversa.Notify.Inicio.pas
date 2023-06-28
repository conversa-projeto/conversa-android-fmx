unit Conversa.Notify.Inicio;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Android.Service,
  System.Threading,
  AndroidApi.Jni.App,
  AndroidApi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Os,
  IdBaseComponent,
  IdComponent,
  IdTCPConnection,
  IdTCPClient,
  Tipos, IdGlobal, System.Generics.Collections;

type
  TDM = class(TAndroidService)
    IdTCPClient: TIdTCPClient;
    function AndroidServiceStartCommand(const Sender: TObject; const Intent: JIntent; Flags, StartId: Integer): Integer;
    procedure AndroidServiceCreate(Sender: TObject);
    procedure AndroidServiceDestroy(Sender: TObject);
  private
    { Private declarations }
    FThreads: TObjectList<TThread>;
    procedure LoopService;
    procedure EnviarCommand;
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDM.AndroidServiceCreate(Sender: TObject);
begin
  FThreads := TObjectList<TThread>.Create;
end;

procedure TDM.AndroidServiceDestroy(Sender: TObject);
begin
  FreeAndNil(FThreads);
end;

function TDM.AndroidServiceStartCommand(const Sender: TObject; const Intent: JIntent; Flags, StartId: Integer): Integer;
begin
  Result := TJService.JavaClass.START_STICKY;

  IdTCPClient.Connect;
  EnviarCommand;

  FThreads.Add(TThread.CreateAnonymousThread(LoopService));
  FThreads[0].Start;
end;

procedure TDM.EnviarCommand;
var
  Tamanho: Integer;
  Bytes: TIdBytes;
begin
  Bytes := [];
  Tamanho := 0;
  IdTCPClient.IOHandler.Write(Byte(TMethod.ConexoesAtivas));
  IdTCPClient.IOHandler.Write(Tamanho);
  IdTCPClient.IOHandler.Write(Bytes);
end;

procedure TDM.LoopService;
begin
  while True do
  begin
    try
      EnviarCommand;
      try
        // Verifica se desconectou
        IdTCPClient.IOHandler.CheckForDisconnect;
      except
        IdTCPClient.Connect;
      end;

      // Espera receber os dados
      IdTCPClient.IOHandler.CheckForDataOnSource(10);
//      AddLog('3');

      // Verifica se tem dados
      if IdTCPClient.IOHandler.InputBufferIsEmpty then
        Continue;
    except
    end;
  end;
end;

end.
