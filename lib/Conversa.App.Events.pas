unit Conversa.App.Events;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils;

type
  TConversaAppEventType = (
    List,
    Conectado,
    TemaAtualizado
  );

  TConversaAppEventProc = TProc;

  TConversaAppEvents = class
  private type
    TConversaAppEvent = record
      EventType: TConversaAppEventType;
      EventProc: TConversaAppEventProc;
      Events: TConversaAppEvents;
    end;
  private
    FList: TThreadList<TConversaAppEvent>;
    constructor Create;
  public
    destructor Destroy; override;
    class function Instance: TConversaAppEvents;
    function Add(EventType: TConversaAppEventType; Proc: TConversaAppEventProc): TConversaAppEvents; overload;
    function Add(Events: TConversaAppEvents): TConversaAppEvents; overload;
    function Run(EventType: TConversaAppEventType): TConversaAppEvents;
  end;

implementation

var
  FLista: TConversaAppEvents;

{ TConnectionRegisterList }

constructor TConversaAppEvents.Create;
begin
  FList := TThreadList<TConversaAppEvent>.Create;
end;

destructor TConversaAppEvents.Destroy;
begin
  FreeAndNil(FList);
  inherited;
end;

class function TConversaAppEvents.Instance: TConversaAppEvents;
begin
  Result := FLista;
end;

function TConversaAppEvents.Add(EventType: TConversaAppEventType; Proc: TConversaAppEventProc): TConversaAppEvents;
var
  Event: TConversaAppEvent;
begin
  Result := Self;
  Event.EventType := EventType;
  Event.EventProc := Proc;
  FList.Add(Event);
end;

function TConversaAppEvents.Add(Events: TConversaAppEvents): TConversaAppEvents;
var
  Event: TConversaAppEvent;
begin
  Result := Self;
  Event.EventType := TConversaAppEventType.List;
  Event.Events := Events;
  FList.Add(Event);
end;

function TConversaAppEvents.Run(EventType: TConversaAppEventType): TConversaAppEvents;
var
  Item: TConversaAppEvent;
  Proc: TProc;
begin
  Result := Self;
  try
    for Item in FList.LockList do
    begin
      if Item.EventType = TConversaAppEventType.List then
        Item.Events.Run(EventType)
      else
      if Item.EventType = EventType then
      begin
        try
          Proc := Item.EventProc;
          Proc;
        except
        end;
      end;
    end;
  finally
    FList.UnlockList;
  end;
end;

initialization
  FLista := TConversaAppEvents.Create;

finalization
  FreeAndNil(FLista);

end.
