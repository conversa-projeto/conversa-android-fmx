unit Chamada.WakeLock;

interface

uses
  System.SysUtils
{$IFDEF Android}
, Androidapi.Jni.PowerManager
, Androidapi.Helpers
, Androidapi.JNI.JavaTypes
{$ENDIF}
;

type

  IWakeLock = interface
    ['{3F8AF680-CF4C-4A95-B9B7-51F4D8997F41}']
  end;

  TWakeLock = class(TInterfacedObject, IWakeLock)
  private
    {$IFDEF Android}
    FObject: JWakeLock;
    procedure CreateObject;
    {$ENDIF}
  public
    class function New: IWakeLock;
    destructor Destroy; override;
  end;

implementation

{ TWakeLock }

class function TWakeLock.New: IWakeLock;
begin
  Result := TWakeLock.Create;
  {$IFDEF Android}
  TWakeLock(Result).CreateObject;
  {$ENDIF}
end;

destructor TWakeLock.Destroy;
begin
  {$IFDEF Android}
  FObject.release;
  FObject := nil;
  {$ENDIF}
  inherited;
end;

{$IFDEF Android}
procedure TWakeLock.CreateObject;
var
  PowerManager: JPowerManager;
begin
  PowerManager := GetPowerManager;
  FObject := PowerManager.newWakeLock(TJPowerManager.JavaClass.PROXIMITY_SCREEN_OFF_WAKE_LOCK, StringToJString('{4D9BA098-BA3B-4054-A70F-BAB085B5B8A1}'));
  if Assigned(FObject) and not FObject.isHeld then
    FObject.acquire;
end;
{$ENDIF}

end.

