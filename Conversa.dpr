program Conversa;

uses
  System.StartUpCopy,
  FMX.Forms,
  Chamada.Teclado.view in 'src\call\Chamada.Teclado.view.pas' {TecladoNumerico},
  Inicio.Antigo.view in 'src\Inicio.Antigo.view.pas' {InicioAView},
  Contato.Lista.view in 'src\contatos\Contato.Lista.view.pas' {ContatoListaView},
  Androidapi.JNI.PowerManager in 'src\jni\Androidapi.JNI.PowerManager.pas',
  Chamada.Audio.Android in 'src\chamada\Chamada.Audio.Android.pas',
  Chamada.Audio in 'src\chamada\Chamada.Audio.pas',
  Chamada.Vibrator in 'src\chamada\Chamada.Vibrator.pas',
  Chamada.Vibrator.Service.Android in 'src\chamada\Chamada.Vibrator.Service.Android.pas',
  Chamada.Vibrator.Service in 'src\chamada\Chamada.Vibrator.Service.pas',
  Chamada.view in 'src\chamada\Chamada.view.pas' {ChamadaView},
  Chamada.WakeLock in 'src\chamada\Chamada.WakeLock.pas',
  Inicio.view in 'src\Inicio.view.pas' {InicioView},
  Conversa.Configuracoes.View in 'src\Conversa.Configuracoes.View.pas' {ConfiguracoesView},
  REST.API in 'lib\rest\REST.API.pas',
  REST.API.Thread in 'lib\rest\REST.API.Thread.pas',
  Extend.Generics.Collections in 'lib\extends\Extend.Generics.Collections.pas',
  Helper.DataSet in 'lib\helper\Helper.DataSet.pas',
  Tipos in 'lib\Tipos.pas',
  Helper.JSON in 'lib\helper\Helper.JSON.pas',
  Conversa.Notify.Inicio in 'services\notify\src\Conversa.Notify.Inicio.pas' {ConversaNotifyServiceModule: TAndroidService},
  Contato.Lista.Item.frame in 'src\contatos\Contato.Lista.Item.frame.pas' {ContatoItem: TFrame},
  Conversa.Connection.List in 'services\notify\src\Conversa.Connection.List.pas',
  Conversa.Gravatar in 'lib\Conversa.Gravatar.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TInicioView, InicioView);
  Application.Run;
end.
