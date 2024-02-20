program Conversa;

uses
  System.StartUpCopy,
  FMX.Forms,
  Chamada.Teclado.view in 'src\call\Chamada.Teclado.view.pas' {TecladoNumerico},
  Conversa.Inicio.view in 'src\Conversa.Inicio.view.pas' {InicioView},
  Contato.Lista.view in 'src\contatos\Contato.Lista.view.pas' {ContatoListaView},
  Androidapi.JNI.PowerManager in 'src\jni\Androidapi.JNI.PowerManager.pas',
  Chamada.Audio.Android in 'src\chamada\Chamada.Audio.Android.pas',
  Chamada.Audio in 'src\chamada\Chamada.Audio.pas',
  Chamada.Vibrator in 'src\chamada\Chamada.Vibrator.pas',
  Chamada.Vibrator.Service.Android in 'src\chamada\Chamada.Vibrator.Service.Android.pas',
  Chamada.Vibrator.Service in 'src\chamada\Chamada.Vibrator.Service.pas',
  Chamada.view in 'src\chamada\Chamada.view.pas' {ChamadaView},
  Chamada.WakeLock in 'src\chamada\Chamada.WakeLock.pas',
  Conversa.Desktop.view in 'src\Conversa.Desktop.view.pas' {DesktopView},
  Conversa.Configuracoes.View in 'src\Conversa.Configuracoes.View.pas' {ConfiguracoesView},
  REST.API in 'lib\rest\REST.API.pas',
  REST.API.Thread in 'lib\rest\REST.API.Thread.pas',
  Extend.Generics.Collections in 'lib\extends\Extend.Generics.Collections.pas',
  Helper.DataSet in 'lib\helper\Helper.DataSet.pas',
  Tipos in 'lib\Tipos.pas',
  Helper.JSON in 'lib\helper\Helper.JSON.pas',
  Conversa.Notify.Inicio in 'services\notify\src\Conversa.Notify.Inicio.pas' {ConversaNotifyServiceModule: TAndroidService},
  Contato.Lista.Item.frame in 'src\contatos\Contato.Lista.Item.frame.pas' {ContatoItem: TFrame},
  Conversa.Gravatar in 'lib\Conversa.Gravatar.pas',
  Conversa.App.Events in 'lib\Conversa.App.Events.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDesktopView, DesktopView);
  Application.Run;
end.
