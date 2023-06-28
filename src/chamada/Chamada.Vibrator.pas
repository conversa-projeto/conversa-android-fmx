unit Chamada.Vibrator;

interface

uses
  Androidapi.JNI.Os,
  Androidapi.JNIBridge;

type

  IVibrator = interface
    ['{4B251F91-600B-47DB-B109-7A98BC0823C3}']
    function Call: IVibrator;
  end;

  TVibrator = class(TInterfacedObject, IVibrator)
  private
    Vib: JVibrator;
  public
    class function New: IVibrator;
    function Call: IVibrator;
    destructor Destroy; override;
  end;

implementation

uses
  Androidapi.Helpers, Androidapi.JNI.GraphicsContentViewText;

{ TVibrator }

destructor TVibrator.Destroy;
begin
  Vib._Release;
  inherited;
end;

class function TVibrator.New: IVibrator;
begin
  Result := TVibrator.Create;
end;

function TVibrator.Call: IVibrator;
//var
//  timings: TJavaArray<Int64>;
//  amplitudes: TJavaArray<Integer>;
//  ve:JVibrationEffect;
begin
//  Result := Self;
//
//  Vib := TJVibrator.Wrap((TAndroidHelper.Context.getSystemService(TJContext.JavaClass.VIBRATOR_MANAGER_SERVICE) as IlocalObject).GetObjectID);
//  timings:= TJavaArray<Int64>.Create(2);
//  amplitudes:= TJavaArray<Integer>.Create(2);
//
//  timings[0] := 1000;
//  timings[1] := 500;
//  amplitudes[0] := 250;
//  amplitudes[0] := 0;
//
//  ve := TJVibrationEffect.JavaClass.createWaveform(timings,amplitudes, -1);
//  Vib.vibrate(ve);
end;

end.
