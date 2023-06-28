(*----------------------------------------------------------------------------------------------------------------------
Irmãos Gonçalves Comércio e Indústria LTDA

Classe para extender eventos de comunicação REST HTTP ao ClienteDataSet

Autor: Eduardo Rodrigues

Data: 31/12/2018
----------------------------------------------------------------------------------------------------------------------*)

unit Extend.DataSet;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.DateUtils,
  Data.DB,
  Datasnap.DBClient,
  System.JSON,
  REST.API;

type
  // Class Inseptor
  TClientDataSet = class(Datasnap.DBClient.TClientDataSet)
  strict private
    FParams     : String;
    FRESTState  : TDataSetState;

    // Converte o retorno String Data do REST Json para DateTime; Yuri - 10/01/2018
    function StrJsonToDateTime(sData: String): Variant;

    // Retorna os parametros com encode para URL; Alan - 16/01/2019
    function GetParams: string;
  private
    FURL        : String;
    FRootElement: String;
    FUser       : String;
    FPassword   : String;
    FFieldCount : Integer;
    aChanged    : Array of Boolean;
    aOnValidate : Array of TFieldNotifyEvent;
    FUserID: Integer;
    FNotAdd: Integer;
    FRastreamento: TJSONObject;
    FRESTLookUpValidate: Boolean;
    procedure ValidaRESTClientDataSet;
    procedure FieldOnValidate(Sender: TField);
    procedure JSON2DataSet(aFields: TJSONArray);
    procedure LoadFromJSONArray(aJSON: TJSONArray);
    procedure CreateFromJSONArray(aJSON: TJSONArray);
    procedure SetFRESTLookUpValidate(const Value: Boolean);
  protected
    function GetRecordCount: Integer; override;
  public
    class function TemResposta(API: TRESTAPI): Boolean;
    class procedure RESTArrayCreate(HOST: String; const Recurso : Array of Const);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function RESTCreate(sURL: String): TClientDataSet;
    function RESTRootElement(sRootElement: String = ''): TClientDataSet;
    function RESTAuth(sUser, sPassword: String): TClientDataSet;
    function RESTAddParam(sParam, sValor : String): TClientDataSet; overload;
    function RESTAddParam(sParam : String; iValor : Integer): TClientDataSet; overload;
    function RESTAddParam(sParam : String; dValor : Double): TClientDataSet; overload;
    function RESTAddParam(sParam : String; dValor : TDateTime): TClientDataSet; overload;
    function RESTAddIf(bCondicao: Boolean; iLenAdd: Integer = 1): TClientDataSet;
    function RESTCloneParams(cdsSource : TClientDataSet): TClientDataSet;
    function RESTSetRastreamento(sClasse, sMetodo: String; joCustom: TJSONObject = nil): TClientDataSet;
    function RESTOpen(joParam: TJSONObject = nil): TClientDataSet;
    function RESTClose: TClientDataSet;
    function RESTAppend: TClientDataSet;
    function RESTEdit: TClientDataSet;
    function RESTPost: TClientDataSet;
    function RESTCancel: TClientDataSet;
    function RESTDelete: TClientDataSet;
    function RESTUserID(Value: Integer): TClientDataSet;
    function Lookup(const KeyFields: string; const KeyValues: Variant; const ResultFields: string): Variant; override;
    property RESTState: TDataSetState read FRESTState;
    property RESTLookupValidate: Boolean read FRESTLookUpValidate write SetFRESTLookUpValidate;
    property RESTURL: String read FURL write FURL;
  end;

implementation

uses
  System.RTTI,
  REST.Response.Adapter,
  REST.Types,
  System.Generics.Collections,
//  Extend.Generics.Collections,
  System.StrUtils,
  System.NetEncoding;

const
  sl = sLineBreak;
  sl2 = sl + sl;

function FloatToSql(pValue: Double): String;
begin
  Result := FloatToStr(pValue);
  Result := StringReplace(Result, '.', '', [rfReplaceAll]);
  Result := StringReplace(Result, ',', '.', []);
end;

procedure Include(var sText: String; const sMod: String; sDiv: String = ',');
begin
  if sText.IsEmpty then
    sText := sMod
  else
  if not sMod.IsEmpty then
    sText := Concat(sText, sDiv, sMod);
end;

{ TClientDataSet }

class procedure TClientDataSet.RESTArrayCreate(HOST: String; const Recurso : Array of Const);
var
  I: Integer;
begin
  for I := 0 to High(Recurso) do
    if not Odd(I) then
      TClientDataSet(Recurso[I].VClass).RESTCreate(HOST + String(Recurso[Succ(I)].VString));
end;

constructor TClientDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRESTLookUpValidate := False;
end;

destructor TClientDataSet.Destroy;
begin
  if Assigned(FRastreamento) then
    FreeAndNil(FRastreamento);
  inherited;
end;

function TClientDataSet.GetParams: string;
begin
  Result := FParams;
end;

function TClientDataSet.GetRecordCount: Integer;
begin
  if Active then
    Result := inherited
  else
    Result := 0;
end;

function TClientDataSet.StrJsonToDateTime(sData: String): Variant;
var
  fmt: TFormatSettings;
  dData: TDateTime;
begin
  if sData.Contains('T') and TryISO8601ToDate(sData, dData) then
    Exit(dData);

  fmt := TFormatSettings.Invariant;
  fmt.DateSeparator   := '-';
  fmt.TimeSeparator   := ':';
  fmt.ShortDateFormat := 'YYYY-MM-DD';
  fmt.ShortTimeFormat := 'HH:nn';
  fmt.LongTimeFormat  := 'HH:nn:ss';
  if TryStrToDateTime(sData, dData, fmt) then
    Exit(dData);

  Result := Null;
end;

procedure TClientDataSet.ValidaRESTClientDataSet;
begin
  if not Self.ProviderName.IsEmpty then
    raise Exception.Create(Self.Name +': REST só disponível para ClientDataSet temporário!');
end;

function TClientDataSet.RESTCreate(sURL: String): TClientDataSet;
var
  I: Integer;
begin
  ValidaRESTClientDataSet;
  Result := Self;

  // Armazena URL REST
  Self.FURL    := sURL;
  Self.FRootElement := 'result[0]';

  {$IF Defined(MD006) or Defined(MD009) }
  FUser     := Sistema.LOGIN;
  FPassword := Sistema.SENHA;
  {$ENDIF}
  // Armazena a quantidade de fields do ClientDataSet
  FFieldCount := Self.FieldCount;
  FNotAdd     := 0;

  // Se não tem fields não cria agora
  if FFieldCount = 0 then
    Exit;

  // Cria o DataSet
  Self.CreateDataSet;

  // Cria arrays para armazenar os dados dos fields
  SetLength(aOnValidate, FFieldCount);
  SetLength(aChanged,    FFieldCount);

  // Sobrescreve eventos dos fields
  for I := 0 to Pred(FFieldCount) do
  begin
    // Armazena os eventos originais do field e sobescreve
    aOnValidate[I] := Self.Fields[I].OnValidate;
    Self.Fields[I].OnValidate := FieldOnValidate;
  end;
end;

function TClientDataSet.RESTRootElement(sRootElement: String = ''): TClientDataSet;
begin
  Result := Self;
  FRootElement := sRootElement;
end;

function TClientDataSet.RESTAuth(sUser, sPassword: String): TClientDataSet;
begin
  Result    := Self;
  FUser     := sUser;
  FPassword := sPassword;
end;

function TClientDataSet.RESTUserID(Value: Integer): TClientDataSet;
begin
  Result := Self;
  FUserID := Value;
end;

procedure TClientDataSet.FieldOnValidate(Sender: TField);
var
  I: Integer;
begin
  // Obtem a posição dos dados do field nos arrays
  I := Sender.Index;
  // Se tem evento de validação para ser executado, executa
  if Assigned(aOnValidate[I]) then
    aOnValidate[I](Sender);
  // Define que os dados do field foram alterados
  aChanged[I] := True;
end;

function TClientDataSet.RESTCloneParams(cdsSource : TClientDataSet): TClientDataSet;
begin
  ValidaRESTClientDataSet;
  Result := Self;

  // Valida se o ClientDataSet de origem também é REST
  if not cdsSource.ProviderName.IsEmpty then
    raise Exception.Create(cdsSource.Name +': REST só disponível para ClientDataSet temporário!');

  // Atribui os parâmetros
  Self.FParams := cdsSource.GetParams;
end;

function TClientDataSet.RESTAddParam(sParam, sValor : String): TClientDataSet;
begin
  if FNotAdd > 0 then
  begin
    Dec(FNotAdd);
    Exit(Self);
  end;

  ValidaRESTClientDataSet;
  Result := Self;

  // Não adiciona parâmetro nem valor vazio
  if sParam.Trim.IsEmpty or sValor.Trim.IsEmpty then
    Exit;

  // Prepara parâmetros para URL
  sValor := TNetEncoding.URL.Encode(sValor);

  // Formata
  if FParams.Trim.IsEmpty then
    FParams := '?'+ sParam +'='+ sValor
  else
    FParams := FParams +'&'+ sParam +'='+ sValor;
end;

function TClientDataSet.RESTAddParam(sParam : String; iValor : Integer): TClientDataSet;
begin
  Result := RESTAddParam(sParam, iValor.ToString);
end;

function TClientDataSet.RESTAddParam(sParam : String; dValor : Double): TClientDataSet;
begin
  Result := RESTAddParam(sParam, dValor.ToString);
end;

function TClientDataSet.RESTAddParam(sParam : String; dValor : TDateTime): TClientDataSet;
var
  sTemp : String;
begin
  DateTimeToString(sTemp, 'yyyy-mm-dd hh:nn:ss.zzz', dValor);
  Result := RESTAddParam(sParam, sTemp);
end;

function TClientDataSet.RESTAddIf(bCondicao: Boolean; iLenAdd: Integer = 1): TClientDataSet;
begin
  { \o/ - Eduardo 21/02/2020 }
  if FNotAdd > 0 then
  begin
    Dec(FNotAdd);
    Exit(Self);
  end;

  if bCondicao then
    FNotAdd := 0
  else
    FNotAdd := iLenAdd;
  Result := Self;
end;

function TClientDataSet.RESTSetRastreamento(sClasse, sMetodo: String; joCustom: TJSONObject = nil): TClientDataSet;
var
  joDataSet: TJSONObject;
begin
  Result := Self;

  if Assigned(FRastreamento) then
    FreeAndNil(FRastreamento);
  FRastreamento := TJSONObject.Create;
  FRastreamento.AddPair('classe', sClasse);
  FRastreamento.AddPair('metodo', sMetodo);
  FRastreamento.AddPair('custom', joCustom);
  joDataSet := TJSONObject.Create;
  FRastreamento.AddPair('dataset', joDataSet);
  joDataSet.AddPair('classname', Self.ClassName);
  joDataSet.AddPair('unitname', Self.UnitName);
  joDataSet.AddPair('name', IfThen(String(Self.Name).Trim.IsEmpty, '(vazio)', String(Self.Name)));
  if Assigned(Self.Owner) then
  begin
    joDataSet.AddPair('owner', TJSONObject.Create).GetValue<TJSONObject>('owner')
      .AddPair('classname', Self.Owner.ClassName)
      .AddPair('unitname', Self.Owner.UnitName)
      .AddPair('name', IfThen(String(Self.Owner.Name).Trim.IsEmpty, '(vazio)', String(Self.Owner.Name)));
  end;
end;

procedure TClientDataSet.CreateFromJSONArray(aJSON: TJSONArray);
var
  adJSON : TCustomJSONDataSetAdapter;
begin
  // Cria adaptador
  adJSON := TCustomJSONDataSetAdapter.Create(nil);
  try
    // Informa o ClientDataSet que vai receber os dados
    adJSON.Dataset := TDataSet(Self);
    // Executa
    adJSON.UpdateDataSet(aJSON);
  finally
    // Limpa da memória
    FreeAndNil(adJSON);
  end;
end;

procedure TClientDataSet.LoadFromJSONArray(aJSON: TJSONArray);
var
  jvItem: TJSONValue;
  joItem: TJSONObject;
  I: Integer;
  function IsDateTime(sText: String): Boolean;
  begin
    Result :=
      (Length(sText) = 24) and
      (System.Copy(sText, 5,  1) = '-') and
      (System.Copy(sText, 8,  1) = '-') and
      (System.Copy(sText, 11, 1) = 'T') and
      (System.Copy(sText, 14, 1) = ':') and
      (System.Copy(sText, 17, 1) = ':') and
      (System.Copy(sText, 20, 1) = '.') and
      (System.Copy(sText, 24, 1) = 'Z');
  end;
begin
  Self.Close;
  Self.CreateDataSet;
  Self.DisableControls;
  try
    for jvItem in aJSON do
    begin
      joItem := TJSONObject(jvItem);
      Self.Append;
      for I := 0 to Pred(joItem.Count) do
      begin
        if joItem.Pairs[I].JsonValue is TJSONNull then
          Self.FieldByName(joItem.Pairs[I].JsonString.Value).Clear
        else
        if joItem.Pairs[I].JsonValue is TJSONNumber then
          Self.FieldByName(joItem.Pairs[I].JsonString.Value).AsFloat := TJSONNumber(joItem.Pairs[I].JsonValue).AsDouble
        else
        if joItem.Pairs[I].JsonValue is TJSONString then
          if IsDateTime(TJSONString(joItem.Pairs[I].JsonValue).Value) then
            Self.FieldByName(joItem.Pairs[I].JsonString.Value).AsDateTime := ISO8601ToDate(joItem.Pairs[I].JsonValue.Value)
          else
            Self.FieldByName(joItem.Pairs[I].JsonString.Value).AsString := joItem.Pairs[I].JsonValue.Value;
      end;
      Self.Post;
    end;
    Self.First;
  finally
    Self.EnableControls;
  end;
end;

procedure TClientDataSet.JSON2DataSet(aFields: TJSONArray);
var
  jvItem: TJSONValue;
  Field: TField;
  FieldType: TFieldType;
begin
  for jvItem in aFields do
  begin
    FieldType := TRTTIEnumerationType.GetValue<TFieldType>(jvItem.GetValue<String>('type'));
    Field := DefaultFieldClasses[FieldType].Create(Self);
    Field.Name := Self.Name + jvItem.GetValue<String>('name').Replace(' ', '');
    Field.FieldName := jvItem.GetValue<String>('name');
    Field.DisplayLabel := jvItem.GetValue<String>('name');
    Field.Size := jvItem.GetValue<Integer>('size');
    Field.DataSet := Self;
    Field.FieldKind := fkData;

    if Field.InheritsFrom(TFMTBCDField) then
      TFMTBCDField(Field).Precision := jvItem.GetValue<Integer>('precision');

    if Field.InheritsFrom(TBCDField) then
      TBCDField(Field).Precision := jvItem.GetValue<Integer>('precision');

    if Field.InheritsFrom(TDateTimeField) then
      Field.Alignment := taCenter
    else
    if Field.InheritsFrom(TNumericField) then
      Field.Alignment := taRightJustify
    else
      Field.Alignment := taLeftJustify;
  end;
end;

class function TClientDataSet.TemResposta(API: TRESTAPI): Boolean;
var
  Cabecalhos: TJSONObject;
begin
  Result := False;

  // Verifica se houve retorno
  if API.Response.ToString.Trim.IsEmpty then
    Exit;

  // Caso de falha
  if API.Response.Status = TResponseStatus.Unknown then
    raise Exception.Create(API.Response.ToString);

  // Valida o se o Retorno obtido é um JSON
  Cabecalhos := API.Response.Headers;
  if Assigned(Cabecalhos) and Assigned(API.Response.Headers.FindValue('ContentType')) then
    if ContentTypeFromString(API.Response.Headers.GetValue<String>('ContentType')) <> TRESTContentType.ctAPPLICATION_JSON then
      Exit;

  if (API.Response.ToJSON = nil) then
    Exit;

  if (API.Response.ToJSON.ToString.Trim.IsEmpty) then
    Exit;

  if API.Response.ToJSON.ToString.Trim.Equals('null') then
    Exit;

  if API.Response.ToJSON.ToString.Trim.Equals('{"result":[null]}') then
    Exit;

  if Assigned(API.Response.ToJSON.FindValue('error')) then
    raise Exception.Create(API.Response.ToJSON.GetValue<String>('error'));

  if Assigned(API.Response.ToJSON.FindValue('erro')) then
    raise Exception.Create(API.Response.ToJSON.GetValue<String>('erro'));

  Result := True;
end;

function TClientDataSet.RESTOpen(joParam: TJSONObject = nil): TClientDataSet;
var
  API: TRESTAPI;
  I,J: Integer;
  aJSONTBL: TJSONArray;
  oJSONROW: TJSONObject;
  oJSONCEL: TJSONPair;
  vResponse: TJSONValue;
  DField: TField;
  sDados: String;
  sValor: String;
  ss: TStringStream;
  Data: Variant;
begin
  ValidaRESTClientDataSet;
  Result := Self;

  // Se estiver ativo, limpa os dados atuais
  if Self.Active then
    Self.EmptyDataSet;

  // Envia ao servidor
  API := TRESTAPI.Create;
  try
    API.Authorization(TAuthBasic.New(FUser, FPassword));
    API.Timeout(1000 * 60 * 30); // 30 minutos
    API.Headers(TJSONObject.Create.AddPair('uid', FUserID));

    if Assigned(joParam) then
    begin
      API.Host(FURL);
      API.Body(joParam);
      API.POST;

      // Verificar se tem dados de resposta
      if not TemResposta(API) then
        Exit;

      vResponse := API.Response.ToJSON;
    end
    else
    begin
      API.Host(FURL + GetParams);
      API.GET;

      // Verificar se tem dados de resposta
      if not TemResposta(API) then
        Exit;

      if not FRootElement.Trim.IsEmpty then
        vResponse := API.Response.ToJSON.GetValue<TJSONValue>(FRootElement)
      else
        vResponse := API.Response.ToJSON
    end;

    // Se o ClientDataSet não possui campos
    if FFieldCount = 0 then
    begin
      if Assigned(vResponse.FindValue('fields')) and Assigned(vResponse.FindValue('data')) then
      begin
        // Cria campos conforme a estrutura do banco
        if Self.FieldCount = 0 then
          Self.JSON2DataSet(vResponse.GetValue<TJSONArray>('fields'));

        // Insere os dados no dataset
        Self.LoadFromJSONArray(vResponse.GetValue<TJSONArray>('data'));
      end
      else // Cria o dataset automaticamente e insere os dados
        Self.CreateFromJSONArray(TJSONArray(vResponse));

      // Posiciona no primeiro registro
      if not Self.IsEmpty then
        Self.First;

      // Coloca o ClientDataSet em estado de Navegacao
      Self.FRESTState := dsBrowse;

      // Sai da função
      Exit;
    end;

    aJSONTBL := TJSONArray(vResponse);
    sDados := EmptyStr;
    for I := 0 to Pred(aJSONTBL.Count) do
    begin
      oJSONROW := TJSONObject(aJSONTBL.Items[I]);
      sDados := sDados +'<ROW RowState="4"';
      for J := 0 to Pred(oJSONROW.Count) do
      begin
        sValor := EmptyStr;
        oJSONCEL := oJSONROW.Pairs[J];
        DField := Self.FindField(oJSONCEL.JsonString.Value);
        if DField = nil then
          Continue
        else
        if not (DField is TTimeField) and ((DField is TDateTimeField) or (DField is TSQLTimeStampField)) then
        begin
          Data := StrJsonToDateTime(oJSONCEL.JsonValue.Value);
          if Data = Null then
            sValor := EmptyStr
          else
          if DField is TSQLTimeStampField then
            sValor := FormatDateTime('yyyymmdd', TDateTime(Data)) +'T'+ FormatDateTime('hh:nn:sszzz', TDateTime(Data))
          else
            sValor := FormatDateTime('yyyy-mm-dd', TDateTime(Data)) +'T'+ FormatDateTime('hh:nn:ss.zzz', TDateTime(Data));
        end
        else
          sValor := oJSONCEL.JsonValue.Value;
        sDados := sDados +' '+ oJSONCEL.JsonString.Value +'="'+ TNetEncoding.HTML.Encode(sValor) +'"';
      end;
      sDados := sDados +'/>';
    end;

    ss := TStringStream.Create;
    try
      Self.SaveToStream(ss, dfXMLUTF8);
      sDados := ss.DataString.Replace('<ROWDATA></ROWDATA>', '<ROWDATA>'+ sDados +'</ROWDATA>');
      ss.Clear;
      ss.WriteString(sDados);
      ss.Position := 0;
      Self.LoadFromStream(ss);
    finally
      FreeAndNil(ss);
    end;

    // Coloca o ClientDataSet em estado de Navegacao
    Self.FRESTState := dsBrowse;
  finally
    FreeAndNil(API);
  end;
end;

function TClientDataSet.RESTClose: TClientDataSet;
begin
  ValidaRESTClientDataSet;
  Result  := Self;
  FParams := EmptyStr;
  if Self.Active then
    Self.EmptyDataSet;
end;

function TClientDataSet.RESTAppend: TClientDataSet;
begin
  ValidaRESTClientDataSet;
  Result := Self;
  Self.Append;
  Self.FRESTState := dsInsert;
  // Inicializa informação sobre alteração dos dados
  Finalize(aChanged);
  SetLength(aChanged, FFieldCount);
end;

function TClientDataSet.RESTEdit: TClientDataSet;
begin
  ValidaRESTClientDataSet;
  Result := Self;
  Self.Edit;
  Self.FRESTState := dsEdit;
  // Inicializa informação sobre alteração dos dados
  Finalize(aChanged);
  SetLength(aChanged, FFieldCount);
end;

function TClientDataSet.RESTPost: TClientDataSet;
var
  API         : TRESTAPI;
  I           : Integer;
  oJSON       : TJSONObject;
  oRETURN     : TJSONObject;
  RField      : TField;
  RBeforePost : TDataSetNotifyEvent;
  ROnPosError : TDataSetErrorEvent;
  ROnChange   : TFieldNotifyEvent;
  ROnSetText  : TFieldSetTextEvent;
  ROnValidate : TFieldNotifyEvent;
  OleData     : OleVariant;
begin
  ValidaRESTClientDataSet;
  Result := Self;

  // Se estiver inserindo ou editando
  if FRESTState in [dsInsert, dsEdit] then
  begin
    try
      // Executa validação dos dados
      Self.Post;
    except on E: Exception do
      begin
        // Volta para edicao, caso der erro, ja estara em edicao
        Self.Edit;

        // Retorna mensagem de erro original
        raise EAbort.Create(E.Message);
      end;
    end;
  end
  else
  begin
    // Se não for tratado, o registro não será gravado e o usuário não será avisado
    raise Exception.Create(Self.Name +': Registro não está em edição!');
  end;

  // Executa evento antes de enviar os dados ao servidor
  OleData := Self.Data;
  if Assigned(Self.BeforeApplyUpdates) then
    Self.BeforeApplyUpdates(Self, OleData);

  oJSON := TJSONObject.Create;

  // Obtem os dados do cds
  for I := 0 to Pred(FFieldCount) do
  begin
    // Será enviado ao Servidor apenas fields do tipo fkData
    if Self.Fields[I].FieldKind <> fkData then
      Continue;

    // Se o campo não é Update, Where e nem Key, não será enviado ao Servidor
    if ((Self.Fields[I].ProviderFlags * [pfInUpdate, pfInWhere, pfInKey]) = []) then
      Continue;

    // Inserção envia todos os campos
    if (FRESTState = dsEdit)                               and  // Se for edição
       (not aChanged[Self.Fields[I].Index])                and  // Se o campo não foi alterado
       (not Self.Fields[I].FieldName.Equals('IG_RECNO'))   and  // Se for o IG_RECNO envia sempre
       (not Self.Fields[I].FieldName.Equals('IG_BANCO'))   then // Se for o IG_BANCO envia sempre
      Continue;

    // Só envia ao servidor campos com UPDATED exceto IG_RECNO, IG_BANCO
    if ((not (pfInUpdate in Self.Fields[I].ProviderFlags)) and
        (not Self.Fields[I].FieldName.Equals('IG_RECNO'))  and
        (not Self.Fields[I].FieldName.Equals('IG_BANCO'))) then
      Continue;

    // Não envia os campos ao servidor
    if ((Self.Fields[I].FieldName.Equals('IG_USRALT'))  or
        (Self.Fields[I].FieldName.Equals('IG_UPDALT'))) then
      Continue;

    // Se estiver nulo, não enviar vazio ao servidor, se não, converter para tipo correto
    if Self.Fields[I].IsNull then
      oJSON.AddPair(Self.Fields[I].FieldName, TJSONNull.Create)
    else
    if Self.Fields[I] is TStringField then
      oJSON.AddPair(Self.Fields[I].FieldName, Self.Fields[I].AsString)
    else
    if Self.Fields[I] is TNumericField then
      oJSON.AddPair(Self.Fields[I].FieldName, FloatToSql(Self.Fields[I].AsFloat))
    else
    if (Self.Fields[I] is TDateTimeField) or (Self.Fields[I] is TSQLTimeStampField) then
      oJSON.AddPair(Self.Fields[I].FieldName, FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Self.Fields[I].AsDateTime))
    else
    begin
      FreeAndNil(oJSON);
      raise Exception.Create(Self.Name +': Tipo do campo não esperado!'+ sl +'Campo: '+ Self.Fields[I].FieldName +' - Tipo: '+ TRTTIEnumerationType.GetName(Self.Fields[I].DataType));
    end;
  end;

  // Se está enviando somente o IG_RECNO, não faz nada
  if (oJSON.Count = 1) and (oJSON.Pairs[0].JsonString.Value = 'IG_RECNO') then
  begin
    // Informa que o processo requisitado foi concluído
    Self.FRESTState := dsBrowse;
    FreeAndNil(oJSON);
    Exit;
  end;

  // Envia ao servidor
  API := TRESTAPI.Create;
  try
    API.Authorization(TAuthBasic.New(FUser, FPassword));
    API.Timeout(1000 * 60 * 30); // 30 minutos
    API.Host(FURL);
    API.Body(oJSON);

    if FRESTState = dsInsert then
      API.PUT
    else
    if FRESTState = dsEdit then
      API.POST;

    // Obtem o retorno do servidor
    if not TemResposta(API) then
      Exit;

    // Passa por todos os campos informando que não estão mais alterados
    Finalize(aChanged);
    SetLength(aChanged, FFieldCount);

    // Se for inserção, o servidor irá retornar o registro para os campos auto incremento do banco
    if FRESTState = dsInsert then
    begin
      // Define a raiz do json
      if not FRootElement.Trim.IsEmpty then
        oRETURN := API.Response.ToJSON.GetValue<TJSONObject>(FRootElement)
      else
        oRETURN := API.Response.ToJSONObject;

      // Armazena eventos originais
      RBeforePost      := Self.BeforePost;
      ROnPosError      := Self.OnPostError;
      Self.BeforePost  := nil;
      Self.OnPostError := nil;
      try
        // Insere os dados no cds
        Self.Edit;

        // Passar por todas os campos retornados pelo servidor
        for I := 0 to Pred(oRETURN.Count) do
        begin
          // Atribui field
          RField := Self.FindField(oRETURN.Pairs[I].JSONString.Value);
          if RField <> nil then
          begin
            // Armazena evntos do field
            ROnChange         := RField.OnChange;
            ROnSetText        := RField.OnSetText;
            ROnValidate       := RField.OnValidate;
            RField.OnChange   := nil;
            RField.OnSetText  := nil;
            RField.OnValidate := nil;
            try
              RField.AsString := oRETURN.Pairs[I].JSONValue.Value;
            finally
              // Reatribui os eventos do field
              RField.OnChange   := ROnChange;
              RField.OnSetText  := ROnSetText;
              RField.OnValidate := ROnValidate;
            end;
          end;
        end;

        // Posta informações
        Self.Post;
      finally
        // Reatribui eventos do dataset
        Self.BeforePost  := RBeforePost;
        Self.OnPostError := ROnPosError;
      end;
    end;

    // Informa que o processo requisitado foi concluído
    Self.FRESTState := dsBrowse;
  finally
    FreeAndNil(API);
  end;

  // Executa evento depois de enviar os dados ao servidor
  OleData := Self.Data;
  if Assigned(Self.AfterApplyUpdates) then
    Self.AfterApplyUpdates(Self, OleData);
end;

function TClientDataSet.RESTCancel: TClientDataSet;
begin
  ValidaRESTClientDataSet;
  Result := Self;

  // Cancela as alterações do registro atual
  Self.Cancel;

  // Atualiza o tipo de requisição do usuário
  Self.FRESTState := dsBrowse;
end;

function TClientDataSet.RESTDelete: TClientDataSet;
begin
  ValidaRESTClientDataSet;
  Result := Self;

  if Self.FindField('IG_RECNO') = nil then
    raise Exception.Create(Self.Name +': Não é possível deletar o registro sem um campo chave!');

  if Self.FieldByName('IG_RECNO').AsString.Trim.IsEmpty then
    raise Exception.Create(Self.Name +': Não é possível deletar o registro com campo chave vazio!');

  // Envia ao servidor
  with TRESTAPI.Create do
  try
    Authorization(TAuthBasic.New(FUser, FPassword));
    Host(FURL);
    Query(
      TJSONObject.Create
        .AddPair('IG_RECNO', Self.FieldByName('IG_RECNO').AsString)
    );
    TemResposta(DELETE);
  finally
    Free;
  end;

  // Deleta o registro do cds
  Self.Delete;

  // Atualiza o tipo de requisição do usuário
  Self.FRESTState := dsBrowse;
end;

procedure TClientDataSet.SetFRESTLookUpValidate(const Value: Boolean);
var
  I: Integer;
begin
  FRESTLookUpValidate := Value;

  // Percorre os campos informando que devem validar
  for I := 0 to Pred(FieldCount) do
    if (Fields[I].FieldKind = fkLookup) and Assigned(Fields[I].LookupDataSet) and Fields[I].LookupDataSet.InheritsFrom(Extend.DataSet.TClientDataSet) then
      Extend.DataSet.TClientDataSet(Fields[I].LookupDataSet).FRESTLookupValidate := Value;
end;

function TClientDataSet.Lookup(const KeyFields: string; const KeyValues: Variant; const ResultFields: string): Variant;
begin
  // Método para adicionar no lookup validação e limpeza automática, é necessário definir quando retornará raise alteando a propriedade RESTLookUpValidate
  if VarIsNull(KeyValues) or EmptyStr.Equals(KeyValues) then
    Exit(Unassigned);

  if LocateRecord(KeyFields, KeyValues, [], False) then
  begin
    SetTempState(dsCalcFields);
    try
      CalculateFields(TempBuffer);
      Result := FieldValues[ResultFields];

      if VarIsNull(Result) then
        VarClear(Result);
    finally
      RestoreState(dsBrowse);
    end;
  end
  else
  if FRESTLookUpValidate then
    raise Exception.Create(
      'Erro ao localizar "'+ String(KeyValues) +'"'+ sl +
      'no campo "'+ Self.FieldByName(KeyFields).DisplayName +'"'+ sl +
      'ao obter o valor do campo "'+ Self.FieldByName(ResultFields).DisplayName +'"!'+ sl2 +
      (function: String
       begin
         if Assigned(Self.Owner) then
           Result := Self.Owner.Name;
         Include(Result, Self.Name, '.');
       end)()
    );
end;

{$WARN GARBAGE OFF}

end.
(*
Controle - Versões.
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 05/02/2019]
Alinhado com Alan Miranda, envio de dados para Servidor não terá QuotedStr
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 19/02/2019]
Corrige Envio de Dados do JSON
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 08/10/2019]
Altera de protected para public "RESTState"
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 14/12/2019]
  - Corrige alteração do RESTState no RESTPost
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 21/02/2020]
Adiciona RESTAddIf para adição condicional de parâmetros da pesquisa
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 21/02/2020]
  - Adiciona RESTSetRastreamento, para informar os parâmetros de rastreamento.
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 12/04/2021]
Adiciona criação de dataset com estrutura de dados vinda do servidor. Exemplo servidor em: MD030 > SM0397
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 02/04/2021]
Adiciona no lookup validação e limpeza automática
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 18/10/2021]
TICK:50035 - Corrige erro ao usar like em pesquisa REST na URL
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 04/03/2022]
TICK:55619 - Adiciona uso do REST.API e define time out para 30 minutos
------------------------------------------------------------------------------------------------------------------------
*)
