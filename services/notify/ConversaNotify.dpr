program ConversaNotify;

uses
  System.Android.ServiceApplication,
  Conversa.Notify.Inicio in 'src\Conversa.Notify.Inicio.pas' {ConversaNotifyServiceDM: TAndroidService},
  Tipos in '..\..\lib\Tipos.pas',
  Androidapi.JNI.PowerManager in '..\..\src\chamada\Androidapi.JNI.PowerManager.pas',
  Chamada.Audio.Android in '..\..\src\chamada\Chamada.Audio.Android.pas',
  Chamada.Audio in '..\..\src\chamada\Chamada.Audio.pas',
  Chamada.Vibrator in '..\..\src\chamada\Chamada.Vibrator.pas',
  Chamada.Vibrator.Service.Android in '..\..\src\chamada\Chamada.Vibrator.Service.Android.pas',
  Chamada.Vibrator.Service in '..\..\src\chamada\Chamada.Vibrator.Service.pas',
  Chamada.WakeLock in '..\..\src\chamada\Chamada.WakeLock.pas',
  Conversa.App.Events in '..\..\lib\Conversa.App.Events.pas',
  Android.KeyguardManager in '..\..\lib\android\Android.KeyguardManager.pas',
  DW.Androidapi.JNI.KeyguardManager in '..\..\lib\android\DW.Androidapi.JNI.KeyguardManager.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TConversaNotifyServiceModule, ConversaNotifyServiceModule);
  Application.Run;
end.
