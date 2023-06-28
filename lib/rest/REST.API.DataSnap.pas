(*----------------------------------------------------------------------------------------------------------------------
Irmãos Gonçalves Comércio e Indústria LTDA

Classe de conexão com servidor REST API do MD066

Autor: Daniel Araujo; Eduardo Rodrigues Pêgo

Data: 27/08/2021
----------------------------------------------------------------------------------------------------------------------*)
unit REST.API.DataSnap;

interface

uses
  System.Net.HttpClient,
  System.Generics.Collections,
  System.SysUtils,
  REST.API;

type
  TRESTAPIDataSnap = class(REST.API.TRESTAPI)
  private
    FNome: String;
    FLogin: String;
    FPassword: String;
    FRootElement: Boolean;
    function Auth: String;
    function TemResposta: Boolean;
  protected
    function InternalExecute: TRESTAPI; override;
  public
    constructor Create;
    function DisableRootElement: TRESTAPI;
  end;

implementation

uses
  IGERP.Sistema,
  System.JSON,
  System.Net.URLClient,
  System.NetEncoding;

{ TMD066 }

constructor TRESTAPIDataSnap.Create;
begin
  inherited;
  FLogin := Sistema.LOGIN;
  FPassword := Sistema.SENHA;
  FNome := ClassName;
  FRootElement := True;
end;

function TRESTAPIDataSnap.Auth: String;
var
  LBase64: TNetEncoding;
begin
  // REST.Authenticator.Basic
  // ARequest.AddAuthParameter
  // Não utilizar TNetEncoding.Base64 aqui, porque pode quebrar com linhas grandes
  LBase64 := TBase64Encoding.Create(0, '');
  try
    Result := 'Basic '+ LBase64.Encode(FLogin +':'+ FPassword);
  finally
    FreeAndNil(LBase64);
  end;
end;

function TRESTAPIDataSnap.DisableRootElement: TRESTAPI;
begin
  Result := Self;
  FRootElement := False;
end;

function TRESTAPIDataSnap.InternalExecute: TRESTAPI;
const
  Erros: Array[0..1] of String = ('erro', 'error');
var
  vJSON: TJSONValue;
  sErro: String;
begin
  Headers.Value(TJSONObject.Create.AddPair('Authorization', Auth));

  Result := inherited;

  if Self.Response.Status = TResponseStatus.Sucess then
    Exit;

  if not TemResposta then
    raise Exception.Create('Sem resposta do servidor!');

  // Valida o Response
  vJSON := Self.Response.ToJSON;
  if not Assigned(vJSON) then
    raise Exception.Create('Falha ao obter resposta do servidor!');

  // Se está utilizando RootElement e o response é um TJSONArray
  if FRootElement and (vJSON is TJSONArray) then
    with TJSONArray(vJSON) do
      if (Count > 0) and (Items[0] is TJSONObject) then
        vJSON := TJSONObject(Items[0]);

  // Valida se o retorno teve algum erro
  if vJSON is TJSONObject then
    for sErro in Erros do
      if Assigned(vJSON.FindValue(sErro)) then
        raise Exception.Create('Erro no servidor!'+ sl + vJSON.GetValue<String>(sErro));
end;

function TRESTAPIDataSnap.TemResposta: Boolean;
var
  jvR: TJSONValue;
begin
  Result := False;

  // Verifica se houve retorno
  if Response.ToString.Trim.IsEmpty then
    Exit;

  jvR := Response.ToJSON;

  if (jvR = nil) or (jvR is TJSONNull) then
    Exit;

  if FRootElement and (jvR is TJSONArray) and (TJSONArray(jvR).Items[0] is TJSONNull) then
    Exit;

  Result := True;
end;

{$WARN GARBAGE OFF}
end.
(*----------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 29/09/2021 - ISSUE:593]
  - Refatoração do método InternalExecute no base
(*----------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 07/10/2021 - ISSUE:598]
  - Informar usuário do sistema na requisição
----------------------------------------------------------------------------------------------------------------------*)