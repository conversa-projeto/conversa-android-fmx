(*----------------------------------------------------------------------------------------------------------------------
Irmãos Gonçalves Comércio e Indústria LTDA

Classe de conexão com servidor REST API utilizando TRESTAPI e threads

Autor: Daniel Araujo

Data: 21/08/2021
----------------------------------------------------------------------------------------------------------------------*)
unit REST.API.Thread;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.JSON,
  System.Math,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.Net.URLClient,
  System.SysUtils,
  System.Threading,
  REST.API;

{$SCOPEDENUMS ON} // Controla como os valores do tipo de enumeração serão usados

type
  TResponseThread = class(REST.API.TResponse)
  private
    FCount: Integer;
    FIndex: Integer;
    FCompleted: Integer;
    FException: String;
  public
    property Index: Integer read FIndex;
    property Completed: Integer read FCompleted;
    property Count: Integer read FCount;
    property Exception: String read FException;
  end;

  TRESTThreadItem = class
  private
    FAPI: TObjectList<TRESTAPI>;
    FAtual: Integer;
    FOnPrepare: TProc<TRESTThreadItem>;
    FException: String;
    FParar: Boolean;
    FPular: Boolean;
    procedure Execute;
  public
    constructor Create;
    destructor Destroy; override;
    function OnPrepare(Method: TProc<TRESTThreadItem>): TRESTThreadItem;
    function Add(Items: TArray<TRESTAPI>): TRESTThreadItem; overload;
    function Add(Item: TRESTAPI): TRESTThreadItem; overload;
    property API: TObjectList<TRESTAPI> read FAPI;
    property Atual: Integer read FAtual;
    property Parar: Boolean read FParar write FParar;
    property Pular: Boolean read FPular write FPular;
    function Response: TResponseThread;
    function Responses: TArray<TResponseThread>;
  end;

  TRESTAPIThread = class
  private
    FTask: TList<ITask>;
    FItems: TObjectList<TRESTThreadItem>;
    FQtdFinalizado: Integer;
    FOnComplete: TProc<TResponseThread>;
    FOnCompleteItem: TProc<TRESTThreadItem>;
    FOnTerminate: TProc<TArray<TResponseThread>>;
    FRuning: Boolean;
    FFinalizou: Boolean;
    FFreeOnTerminate: Boolean;
    procedure InternalStart;
    function InternalAdd(Item: TRESTThreadItem): TRESTAPIThread;
    procedure InternalWaitForAll;
    procedure CheckRuning;
    procedure DoComplete(Item: TRESTThreadItem);
    procedure DoTerminate;
    function GetResponses: TArray<TResponseThread>;
    procedure ExecuteTask(Item: TRESTThreadItem);
  public
    constructor Create(FreeOnTerminate: Boolean = True);
    destructor Destroy; override;
    function Add(Item: TRESTThreadItem): TRESTAPIThread; overload;
    function Add(API: TArray<TRESTAPI>): TRESTAPIThread; overload;
    function GET(API: TRESTAPI): TRESTAPIThread;
    function POST(API: TRESTAPI): TRESTAPIThread;
    function PUT(API: TRESTAPI): TRESTAPIThread;
    function DELETE(API: TRESTAPI): TRESTAPIThread;
    function Start(OnComplete: TProc<TResponseThread> = nil): TRESTAPIThread; overload;
    function Start(OnComplete: TProc<TRESTThreadItem>): TRESTAPIThread; overload;
    function WaitForAll(OnTerminate: TProc<TArray<TResponseThread>> = nil): TRESTAPIThread;
    function OnTerminate(AProc: TProc<TArray<TResponseThread>>): TRESTAPIThread;
    class procedure Cancel(Threads: TRESTAPIThread);
  end;

implementation

{ TRESTAPIThread }

constructor TRESTAPIThread.Create(FreeOnTerminate: Boolean = True);
begin
  FTask := TList<ITask>.Create;
  FItems := TObjectList<TRESTThreadItem>.Create;
  FRuning := False;
  FQtdFinalizado := 0;
  FFinalizou := False;
  FFreeOnTerminate := FreeOnTerminate;
end;

destructor TRESTAPIThread.Destroy;
begin
  // Para não limpar caso não tenha finalizado
  InternalWaitForAll;

  FItems.Clear;
  FTask.Clear;
  FQtdFinalizado := 0;
  FRuning := False;

  FreeAndNil(FItems);
  FreeAndNil(FTask);
  inherited;
end;

function TRESTAPIThread.Add(Item: TRESTThreadItem): TRESTAPIThread;
begin
  Result := InternalAdd(Item);
end;

function TRESTAPIThread.Add(API: TArray<TRESTAPI>): TRESTAPIThread;
begin
  Result := InternalAdd(TRESTThreadItem.Create.Add(API));
end;

function TRESTAPIThread.GET(API: TRESTAPI): TRESTAPIThread;
begin
  Result := Add([API.Method(TRESTMethod.GET)]);
end;

function TRESTAPIThread.POST(API: TRESTAPI): TRESTAPIThread;
begin
  Result := Add([API.Method(TRESTMethod.POST)]);
end;

function TRESTAPIThread.PUT(API: TRESTAPI): TRESTAPIThread;
begin
  Result := Add([API.Method(TRESTMethod.PUT)]);
end;

function TRESTAPIThread.DELETE(API: TRESTAPI): TRESTAPIThread;
begin
  Result := Add([API.Method(TRESTMethod.DELETE)]);
end;

type
  TRESTAPIH = class(TRESTAPI);

function TRESTAPIThread.InternalAdd(Item: TRESTThreadItem): TRESTAPIThread;
begin
  Result := Self;

  FItems.Add(Item);
  FTask.Add(
    TTask.Create(
    procedure
    begin
      ExecuteTask(Item);
    end)
  );
end;

function TRESTAPIThread.OnTerminate(AProc: TProc<TArray<TResponseThread>>): TRESTAPIThread;
begin
  Result := Self;
  FOnTerminate := AProc;
end;

function TRESTAPIThread.Start(OnComplete: TProc<TResponseThread> = nil): TRESTAPIThread;
begin
  Result := Self;
  FOnComplete := OnComplete;
  InternalStart;
end;

function TRESTAPIThread.Start(OnComplete: TProc<TRESTThreadItem>): TRESTAPIThread;
begin
  Result := Self;
  FOnCompleteItem := OnComplete;
  InternalStart;
end;

class procedure TRESTAPIThread.Cancel(Threads: TRESTAPIThread);
var
  Task: ITask;
begin
  if Assigned(Threads) then
  try
    Threads.CheckRuning;
    for Task in Threads.FTask do
      Task.Cancel;
  except
  end;
end;

procedure TRESTAPIThread.InternalStart;
var
  Task: ITask;
begin
  // Inicializa todas as tarefas
  for Task in FTask do
    if Task.Status = TTaskStatus.Created then
      Task.Start;

  FRuning := True;
end;

function TRESTAPIThread.WaitForAll(OnTerminate: TProc<TArray<TResponseThread>> = nil): TRESTAPIThread;
begin
  Result := Self;
  FOnTerminate := OnTerminate;
  InternalWaitForAll;
end;

procedure TRESTAPIThread.InternalWaitForAll;
var
  Threads: TArray<ITask>;
begin
  CheckRuning;
  try
    Threads := FTask.ToArray;
    // \o/ Daniel Araujo - 21/08/2021
    // Processa qualquer Thread.Syncronize e Thread.Queue que esteja pendente
    //   http://chee-yang.blogspot.com/2015/12/delphi-multi-threading_4.html
    //   https://stackoverflow.com/questions/31999429/delphi-ttask-waitforall-vs-synchronise
    while not FFinalizou and not TTask.WaitForAll(Threads, 10) do
      if not FFinalizou then
        CheckSynchronize(0);
  except on E: EOperationCancelled do
    // Não executar nada pois foi solicitado o cancelamento manualmente
  end;
end;

procedure TRESTAPIThread.CheckRuning;
begin
  if Assigned(FItems) and (FItems.Count > 0) and not FRuning then
    raise Exception.Create('Tarefas não inicializadas!');
end;

procedure TRESTAPIThread.DoComplete(Item: TRESTThreadItem);
begin
  if Assigned(FOnComplete) or Assigned(FOnCompleteItem) then
    TThread.Synchronize(
      TThread.Current,
      procedure
      begin
        if Assigned(FOnComplete) then
          FOnComplete(Item.Response)
        else
          FOnCompleteItem(Item)
      end
    );
end;

procedure TRESTAPIThread.DoTerminate;
begin
  if Assigned(FOnTerminate) then
    TThread.Synchronize(
      TThread.Current,
      procedure
      begin
        FOnTerminate(GetResponses);
      end
    );
end;

function TRESTAPIThread.GetResponses: TArray<TResponseThread>;
var
  I: Integer;
  aResponses: TArray<TResponseThread>;
  Item: TRESTThreadItem;
begin
  for Item in FItems do
  begin
    aResponses := Item.Responses;
    SetLength(Result, Length(Result) + Length(aResponses));

    for I := Length(Result) - Length(aResponses) to Pred(Length(Result)) do
      Result[I] := TResponseThread(aResponses[I - (Length(Result) - Length(aResponses))]);
  end;
end;

procedure TRESTAPIThread.ExecuteTask(Item: TRESTThreadItem);
var
  Res: TResponseThread;
begin
  // Executa todas as requisições agendadas
  Item.Execute;
  try
    System.TMonitor.Enter(Self);
    try
      Inc(FQtdFinalizado);
      try
        // Finaliza os retornos
        for Res in Item.Responses do
        begin
          Res.FException := Item.FException;
          Res.FIndex     := FItems.IndexOf(Item);
          Res.FCount     := FItems.Count;
          Res.FCompleted := FQtdFinalizado;
        end;

        DoComplete(Item);
      finally
        if FQtdFinalizado = FItems.Count then
        begin
          DoTerminate;
          FFinalizou := True;
        end;
      end;
    finally
      System.TMonitor.Exit(Self);
    end;
  finally
    if FFreeOnTerminate and FFinalizou then
      Self.Free;
  end;
end;

{ TRESTThreadItem }

constructor TRESTThreadItem.Create;
begin
  FAPI := TObjectList<TRESTAPI>.Create;
  FAtual := -1;
end;

destructor TRESTThreadItem.Destroy;
begin
  FreeAndNil(FAPI);
  inherited;
end;

function TRESTThreadItem.Add(Item: TRESTAPI): TRESTThreadItem;
begin
  Result := Self;
  FAPI.Add(Item);

  with TRESTAPIH(Item)do
  begin
    // Valida de informou a classe
    if not Assigned(ResponseClass) then
      raise Exception.Create('Informe o tipo de response!');

    // Valida se o Response é um TResponseThread
    if not ResponseClass.InheritsFrom(TResponseThread) then
    begin
      // Valida se o response não é o TREsponse Base
      if ResponseClass <> TResponse then
        raise Exception.Create(
          'Tipo de response "'+ ResponseClass.ClassName +'" é inválido!'+ sLineBreak + sLineBreak +
          'Utilize um "TResponseThread"!'
        );

      // Altera para TResponseThread
      ResponseClass := TResponseThread;
    end;
  end;
end;

function TRESTThreadItem.Add(Items: TArray<TRESTAPI>): TRESTThreadItem;
var
  Item: TRESTAPI;
begin
  Result := Self;
  for Item in Items do
    Add(Item);
end;

function TRESTThreadItem.OnPrepare(Method: TProc<TRESTThreadItem>): TRESTThreadItem;
begin
  Result := Self;
  FOnPrepare := Method;
end;

function TRESTThreadItem.Response: TResponseThread;
begin
  Result := TResponseThread(FAPI[Pred(FAPI.Count)].Response);
end;

function TRESTThreadItem.Responses: TArray<TResponseThread>;
var
  I: Integer;
begin
  SetLength(Result, FAPI.Count);
  for I := 0 to Pred(FAPI.Count) do
    Result[I] := TResponseThread(FAPI[I].Response);
end;

procedure TRESTThreadItem.Execute;
begin
  try
    FPular := False;
    FAtual := Max(FAtual, 0);
    while FAtual <= Pred(FAPI.Count) do
    try
      if Assigned(FOnPrepare) then
        FOnPrepare(Self);

      if FPular then
        Continue;

      if FParar then
        Break;

      try
        TRESTAPIH(FAPI[FAtual]).InternalExecute;
      except on E: Exception do
        FException := E.Message;
      end;

      if not FException.Trim.IsEmpty then
        Break;
    finally
      FPular := False;
      Inc(FAtual);
    end;
  except on E: Exception do
    FException := E.Message;
  end;
end;

{$WARN GARBAGE OFF}
end.
(*----------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 29/09/2021 - ISSUE:593]
  - Adiciona lista para fila de requisições na mesma thread
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 07/10/2021 - TICK:49629]
  - Correção na execução do terminate
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 05/11/2021 - ISSUE:614]
  - Correção para validar finalização do processo
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 19/11/2021 - TICK:51193]
  - Substitui Waitforall(proc) por OnTerminate padrão, corrigindo erros de excução
  - Melhoria na forma de limpeza de memória
----------------------------------------------------------------------------------------------------------------------*)