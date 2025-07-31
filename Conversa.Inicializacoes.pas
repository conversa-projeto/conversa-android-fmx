// Eduardo - 18/09/2024
unit Conversa.Inicializacoes;

interface

function Iniciar: Boolean;
procedure Finalizar;

implementation

uses
  System.SysUtils,
  System.IOUtils,
//  PascalStyleScript,
  Conversa.Configuracoes,
  Conversa.Log;

function Iniciar: Boolean;
begin
  Result := True;
  ReportMemoryLeaksOnShutdown := True;
  TConfiguracoes.Load;
//  TPascalStyleScript.Start;
end;

procedure Finalizar;
begin
//  TPascalStyleScript.Stop;
  PararLog;
end;

end.
