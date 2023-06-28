unit Chamada.Vibrator.Service.Android;

interface

uses
  System.SysUtils,
  System.Threading,
  System.Classes,
  Chamada.Vibrator.Service
, Androidapi.JNI.Os
, Androidapi.Helpers
, Androidapi.JNI.GraphicsContentViewText
, Androidapi.JNIBridge
;

type
  TVibratorService = class(Chamada.Vibrator.Service.TVibratorService)
  private
    FFinalizou: Boolean;
    FVib: JVibrator;
    FTask: ITask;
  public
    constructor Create;
    destructor Destroy; override;
    function Call: IVibratorService; override;
  end;

implementation

{ TVibratorService }

constructor TVibratorService.Create;
begin
  FFinalizou := False;
  FVib := TJVibrator.Wrap((TAndroidHelper.Context.getSystemService(TJContext.JavaClass.VIBRATOR_SERVICE) as IlocalObject).GetObjectID);
end;

destructor TVibratorService.Destroy;
begin
  FFinalizou := True;
  FTask.Wait(1000);
  inherited;
end;

function TVibratorService.Call: IVibratorService;
begin
  Result := Self;
  FTask := TTask.Run(
    procedure
    begin
      while not FFinalizou do
      begin
        FVib.vibrate(1000);
        Sleep(2000);
      end;
    end
  );
end;

end.
