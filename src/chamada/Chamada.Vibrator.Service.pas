unit Chamada.Vibrator.Service;

interface

uses
  System.Classes;

type

  IVibratorService = interface
    ['{5459131F-1464-439D-B96C-0AA0CEC232A4}']
    function Call: IVibratorService;
  end;

  TVibratorService = class(TInterfacedObject, IVibratorService)
  public
    class function New: IVibratorService;
    function Call: IVibratorService; virtual; abstract;
  end;

implementation

uses
  Chamada.Vibrator.Service.Android;

{ TVibratorService }

class function TVibratorService.New: IVibratorService;
begin
  Result := Chamada.Vibrator.Service.Android.TVibratorService.Create;
end;

end.
