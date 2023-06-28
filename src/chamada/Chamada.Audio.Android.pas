unit Chamada.Audio.Android;

interface

uses
  System.Classes,
  System.Permissions,
  System.SysUtils,
  System.Threading,
  System.Types,
  IdGlobal,
{$IFDEF ANDROID}
  Androidapi.Jni,
  Androidapi.JNI.Net,
  Androidapi.JNIBridge,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Media,
  Androidapi.Jni.Os,
  Androidapi.Helpers,
{$ENDIF ANDROID}
  Chamada.Audio;

type
  TAudioState = (Stopped, Playing);

  TAudioPlayStreamTypeH = record Helper for TAudioPlayStreamType
    function Get: Integer;
  end;

  TAudioCapture = class(Chamada.Audio.TAudioCapture)
  private
    FRecorder: JAudioRecord;
    FBytes: TJavaArray<Byte>;
    FStatus: TAudioState;
    FThread: ITask;
    FOnCapture: TProc<IAudioCapture>;
    FCallBackRequestPermissions: TAudioCaptureRequestPermission;
  public
    constructor Create;
    destructor Destroy; override;
    function Start(OnCapture: TProc<IAudioCapture>): IAudioCapture; override;
    function Stop: IAudioCapture; override;
    function Read: IAudioCapture; override;
    function ToIdBytes: TIdBytes; override;
    function PermissionGranted: Boolean; override;
    procedure RequestPermissions(CallBack: TAudioCaptureRequestPermission); override;
  end;

  TAudioPlay = class(Chamada.Audio.TAudioPlay)
  private
    FPlay: JAudioTrack;
    FStatus: TAudioState;
    FStreamType: TAudioPlayStreamType;
    function InternalWrite(const ABytes: TJavaArray<Byte>): IAudioPlay;
    function ChangeStatus(Status: TAudioState): IAudioPlay;
    procedure CreateAudioPlay;
  public
    constructor Create;
    destructor Destroy; override;
    function Start: IAudioPlay; override;
    function Stop: IAudioPlay; override;
    function StreamType(const Value: TAudioPlayStreamType): IAudioPlay; override;
    function Write(const ABytes: TIdBytes): IAudioPlay; override;
  end;

implementation

const
  sampleRate: Integer = 11025;

{ TAudioCapture }

constructor TAudioCapture.Create;
var
  channelConfig: Integer;
  audioFormat: Integer;
  minBufSize: Integer;
begin
  FStatus := TAudioState.Stopped;
  channelConfig := TJAudioFormat.JavaClass.CHANNEL_IN_MONO;
  audioFormat := TJAudioFormat.JavaClass.ENCODING_PCM_16BIT;
  minBufSize := TJAudioRecord.JavaClass.getMinBufferSize(sampleRate, channelConfig, audioFormat);

  FBytes := TJavaArray<Byte>.Create(minBufSize * 4);
  FRecorder := TJAudioRecord.JavaClass.init(TJMediaRecorder_AudioSource.JavaClass.MIC, sampleRate, channelConfig, audioFormat, minBufSize * 4);
end;

destructor TAudioCapture.Destroy;
begin
  Stop;
  FBytes.DisposeOf;
  inherited;
end;

function TAudioCapture.Start(OnCapture: TProc<IAudioCapture>): IAudioCapture;
begin
  Result := Self;

  if FStatus = TAudioState.Playing then
    Exit;

  FOnCapture := OnCapture;
  (FRecorder as JAudioRecord).startRecording;
  FStatus := TAudioState.Playing;

  FThread := TTask.Run(
    procedure
    begin
      while FStatus = TAudioState.Playing do
        FOnCapture(Self);
    end
  );
end;

function TAudioCapture.Stop: IAudioCapture;
begin
  Result := Self;
  if FStatus = TAudioState.Stopped then
    Exit;

  (FRecorder as JAudioRecord).stop;
  FStatus := TAudioState.Stopped;
  FThread.Wait(500);
end;

function TAudioCapture.Read: IAudioCapture;
begin
  Result := Self;
  (FRecorder as JAudioRecord).read(FBytes, 0, FBytes.Length);
end;

function TAudioCapture.ToIdBytes: TIdBytes;
var
  Len: Integer;
begin
  Read;
  Len := FBytes.Length;
  SetLength(Result, Len);
  if Len > 0 then
    System.Move(FBytes.Data^, Result[0], Len);
end;

function TAudioCapture.PermissionGranted: Boolean;
begin
  Result := PermissionsService.IsPermissionGranted(JStringToString(TJManifest_permission.JavaClass.RECORD_AUDIO));
end;

procedure TAudioCapture.RequestPermissions(CallBack: TAudioCaptureRequestPermission);
begin
  FCallBackRequestPermissions := CallBack;
  PermissionsService.RequestPermissions(
    [JStringToString(TJManifest_permission.JavaClass.RECORD_AUDIO)],
    procedure(const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray)
    var
      Status: TPermissionStatus;
    begin
      Status := TPermissionStatus.Denied;
      if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then
        Status := AGrantResults[0];

      FCallBackRequestPermissions(Status, Self);
    end
  );
end;

{ TAudioPlay }

constructor TAudioPlay.Create;
begin
  FStreamType := TAudioPlayStreamType.Call;
  FStatus := TAudioState.Stopped;
  CreateAudioPlay;
end;

destructor TAudioPlay.Destroy;
begin
  Stop;
  inherited;
end;

procedure TAudioPlay.CreateAudioPlay;
var
  trackmin: Integer;
begin
  trackmin := TJAudioTrack.JavaClass.getMinBufferSize(
    sampleRate,
    TJAudioFormat.JavaClass.CHANNEL_OUT_MONO,
    TJAudioFormat.JavaClass.ENCODING_PCM_16BIT
  );

  ChangeStatus(TAudioState.Stopped);

  if Assigned(FPlay) then
    FPlay.release;

  FPlay := TJAudioTrack.JavaClass.init(
    FStreamType.Get,
    sampleRate,
    TJAudioFormat.JavaClass.CHANNEL_OUT_MONO,
    TJAudioFormat.JavaClass.ENCODING_PCM_16BIT,
    trackmin,
    TJAudioTrack.JavaClass.MODE_STREAM
  );

  ChangeStatus(TAudioState.Playing);
end;

function TAudioPlay.ChangeStatus(Status: TAudioState): IAudioPlay;
begin
  Result := Self;
  if FStatus = Status then
    Exit;

  if not Assigned(FPlay) then
    Exit;

  case Status of
    TAudioState.Playing : (FPlay as JAudioTrack).play;
    TAudioState.Stopped : (FPlay as JAudioTrack).stop;
  end;
  FStatus := Status;
end;

function TAudioPlay.Start: IAudioPlay;
begin
  Result := ChangeStatus(TAudioState.Playing);
end;

function TAudioPlay.Stop: IAudioPlay;
begin
  Result := ChangeStatus(TAudioState.Stopped);
end;

function TAudioPlay.StreamType(const Value: TAudioPlayStreamType): IAudioPlay;
begin
  Result := Self;
  if FStreamType = Value then
    Exit;

  FStreamType := Value;
  CreateAudioPlay;
end;

function TAudioPlay.InternalWrite(const ABytes: TJavaArray<Byte>): IAudioPlay;
begin
  Result := Start;
  if Assigned(FPlay) then
    (FPlay AS JAudioTrack).write(ABytes, 0, ABytes.Length);
end;

function TAudioPlay.Write(const ABytes: TIdBytes): IAudioPlay;
var
  ja: TJavaArray<Byte>;
begin
  Result := Self;
  ja := TJavaArray<Byte>.Create(Length(ABytes));
  try
    if Length(ABytes) > 0 then
      System.Move(ABytes[0], ja.Data^, Length(ABytes));
  finally
    Result := InternalWrite(ja);
  end;
end;

{ TAudioPlayStreamTypeH }

function TAudioPlayStreamTypeH.Get: Integer;
begin
  if Self = TAudioPlayStreamType.Call then
    Result := TJAudioManager.JavaClass.STREAM_VOICE_CALL
  else
    Result := TJAudioManager.JavaClass.STREAM_MUSIC;
end;

end.
