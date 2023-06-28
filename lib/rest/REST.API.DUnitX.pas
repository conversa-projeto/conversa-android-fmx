(*----------------------------------------------------------------------------------------------------------------------
Irmãos Gonçalves Comércio e Indústria LTDA

Classe de teste unitário para conexão com servidor REST API

Autor: Eduardo Rodrigues Pêgo

Data: 26/08/2021
----------------------------------------------------------------------------------------------------------------------*)
unit REST.API.DUnitX;

interface

uses
  DUnitX.TestFramework,
  REST.API;

type
  [TestFixture]
  TDUnitXRESTAPI = class
  strict private
    REST: TRESTAPI;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [TestCase('GET','get')]
    [TestCase('POST','post')]
    [TestCase('PUT','put')]
    [TestCase('DELET','delete')]
    procedure Chamadas(const Method: String);

    [TestCase()]
    procedure GET;

    [TestCase()]
    procedure POSTJSON;

    [TestCase()]
    procedure POSTSTREAM;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Classes,
  System.IOUtils,
  System.JSON;

{ TDUnitXRESTAPI }

procedure TDUnitXRESTAPI.Setup;
begin
  REST := TRESTAPI.Create.Host('https://httpbin.org/');
end;

procedure TDUnitXRESTAPI.TearDown;
begin
  FreeAndNil(REST);
end;

procedure TDUnitXRESTAPI.Chamadas(const Method: String);
begin
  Assert.WillNotRaise(
    procedure
    begin
      REST.Route(Method);
      case IndexStr(Method, ['get', 'post', 'put', 'delete']) of
        0: REST.GET;
        1: REST.POST;
        2: REST.PUT;
        3: REST.DELETE;
      end;
    end
  );

  Assert.IsTrue(REST.Response.Status = TResponseStatus.Sucess);
end;

procedure TDUnitXRESTAPI.GET;
begin
  REST.Route('get');
  REST.Query(
    TJSONObject.Create
      .AddPair('parametro1', 'valor1')
      .AddPair('parametro2', 2)
      .AddPair('parametro3', True)
      .AddPair('parametro4', TJSONNull.Create)
  );
  REST.GET;
  Assert.IsTrue(REST.Response.Status = TResponseStatus.Sucess);
  Assert.IsTrue(REST.Response.ToJSON is TJSONObject);
  Assert.IsTrue(Assigned(REST.Response.ToJSON.FindValue('args')), 'Erro ao validar os argumentos');
  Assert.IsTrue(Assigned(REST.Response.ToJSON.FindValue('args.parametro1')), 'Erro ao obter resposta do parametro 1');
  Assert.IsTrue(Assigned(REST.Response.ToJSON.FindValue('args.parametro2')), 'Erro ao obter resposta do parametro 2');
  Assert.IsTrue(Assigned(REST.Response.ToJSON.FindValue('args.parametro3')), 'Erro ao obter resposta do parametro 3');
  Assert.IsTrue(Assigned(REST.Response.ToJSON.FindValue('args.parametro4')), 'Erro ao obter resposta do parametro 4');
  Assert.IsTrue(REST.Response.ToJSON.GetValue<String>('args.parametro1').Equals('valor1'));
  Assert.IsTrue(REST.Response.ToJSON.GetValue<Integer>('args.parametro2') = 2);
  Assert.IsTrue(REST.Response.ToJSON.GetValue<Boolean>('args.parametro3') = True);
  Assert.IsTrue(REST.Response.ToJSON.GetValue<TJSONValue>('args.parametro4').Value.Equals('null'));
end;

procedure TDUnitXRESTAPI.POSTJSON;
begin
  REST.Route('post');
  REST.Body(
    TJSONObject.Create
      .AddPair('parametro1', 'valor1')
      .AddPair('parametro2', 2)
      .AddPair('parametro3', True)
      .AddPair('parametro4', TJSONNull.Create)
  );
  REST.POST;
  Assert.IsTrue(REST.Response.Status = TResponseStatus.Sucess);
  Assert.IsTrue(REST.Response.ToJSON is TJSONObject);
  Assert.IsTrue(Assigned(REST.Response.ToJSON.FindValue('json')), 'Erro ao validar os argumentos');
  Assert.IsTrue(Assigned(REST.Response.ToJSON.FindValue('json.parametro1')), 'Erro ao obter resposta do parametro 1');
  Assert.IsTrue(Assigned(REST.Response.ToJSON.FindValue('json.parametro2')), 'Erro ao obter resposta do parametro 2');
  Assert.IsTrue(Assigned(REST.Response.ToJSON.FindValue('json.parametro3')), 'Erro ao obter resposta do parametro 3');
  Assert.IsTrue(Assigned(REST.Response.ToJSON.FindValue('json.parametro4')), 'Erro ao obter resposta do parametro 4');
  Assert.IsTrue(REST.Response.ToJSON.GetValue<String>('json.parametro1').Equals('valor1'));
  Assert.IsTrue(REST.Response.ToJSON.GetValue<Integer>('json.parametro2') = 2);
  Assert.IsTrue(REST.Response.ToJSON.GetValue<Boolean>('json.parametro3') = True);
  Assert.IsTrue(REST.Response.ToJSON.GetValue<TJSONValue>('json.parametro4').Value.Equals('null'));
end;

procedure TDUnitXRESTAPI.POSTSTREAM;
var
  fs: TFileStream;
  iSize: Int64;
begin
  if TFile.Exists('exemplo.txt') then
    TFile.Delete('exemplo.txt');

  with TStringStream.Create('exemplo') do
  try
    SaveToFile('exemplo.txt');
  finally
    Free;
  end;

  fs := TFileStream.Create('exemplo.txt', fmOpenRead);
  iSize := fs.Size;
  REST.Route('post');
  REST.Body(fs);
  REST.POST;
  Assert.IsTrue(REST.Response.Status = TResponseStatus.Sucess);
  Assert.IsTrue(REST.Response.ToJSON is TJSONObject);
  Assert.IsTrue(Assigned(REST.Response.ToJSON.FindValue('data')), 'Erro ao validar os dados do arquivo');
  Assert.IsTrue(Length(REST.Response.ToJSON.GetValue<String>('data')) = iSize);
end;

initialization
  TDUnitX.RegisterTestFixture(TDUnitXRESTAPI);

end.
