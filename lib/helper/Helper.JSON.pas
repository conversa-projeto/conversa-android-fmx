(*----------------------------------------------------------------------------------------------------------------------
Irmãos Gonçalves Comércio e Indústria LTDA

LIB071.PAS

Helper para estender e adicionar funcionalidades às classes contidas na unit
System.JSON.

Autor: Francis Soares de Oliveira

Data: 13/11/2014 as 11:12
----------------------------------------------------------------------------------------------------------------------*)
unit Helper.JSON;

interface

uses
  System.JSON,
  System.Generics.Collections,
  System.Classes,
  Data.SqlExpr,
  Data.DB,
  System.Variants;

type

  TCallBackItem<T> = reference to procedure (Item: T);
  TCallBackIndex<T, Integer> = reference to procedure (Item: T; Index: Integer);
  TIGJSONArray = class helper for TJSONArray
  public
    procedure ForEach<T>(Proc: TCallBackItem<T>); overload;
    procedure ForEach<T>(Proc: TCallBackIndex<T, Integer>); overload;

    function IGAdd(Values: TArray<String>): TJSONArray; overload;
    function IGAdd(Values: TArray<Integer>): TJSONArray; overload;
    function IGAdd(Values: TArray<Double>): TJSONArray; overload;
    function IGAdd(Values: TArray<Boolean>): TJSONArray; overload;

    function IGExists(Value: String; sPath: String = ''): Boolean; overload;
    function IGExists(Value: Integer): Boolean; overload;
    function IGExists(Value: Double): Boolean; overload;
    function IGExists(Value: Boolean): Boolean; overload;

    function ToArray<T>: TArray<T>;
  end;

  {$SCOPEDENUMS ON}
  TJSONSQL = (EmptyToNull, AllowNull, AllowEmpty, NoQT);
  TJSONSQLOptions = set of TJSONSQL;

  {$Region '/// Helper de TJSONObject '}

  TIGJSONObject = class helper for TJSONObject
  private
    const sqlNULL = 'NULL';
    const DefaultStrSQL = [TJSONSQL.EmptyToNull, TJSONSQL.AllowNull, TJSONSQL.AllowEmpty];
    function EGetPair(const Index: Integer): TJSONPair;
  public
    property Pairs[const Index: Integer]: TJSONPair read EGetPair;

    /// <summary>
    ///  Adiciona um par no JSON igual ao Delphi Berlin
    /// </summary>
    /// <remarks>
    ///  Eduardo - 01/06/2017 às 17:00
    /// </remarks>
    function AddPair(const Pair: TJSONPair): TJSONObject; overload;
    function AddPair(const Str: TJSONString; const Val: TJSONValue): TJSONObject; overload;
    function AddPair(const Str: string; const Val: TJSONValue): TJSONObject; overload;
    function AddPair(const Str: string; const Val: string): TJSONObject; overload;

    ///	<summary>
    ///	  Adiciona um par
    ///	</summary>
    ///	<param name="APair">
    ///   Nome do Par
    ///	</param>
    ///	<param name="AValue">
    ///   Valor que será adicionado no par
    ///	</param>
    ///	<remarks>
    ///	  Francis - 13/11/2014 às 11:20
    ///	</remarks>
    function IGAddPair(const Pair: TJSONPair): TJSONObject; overload;
    function IGAddPair(const Str: TJSONString; const Val: TJSONValue): TJSONObject; overload;
    function IGAddPair(const Str: string; const Val: TJSONValue): TJSONObject; overload;
    function IGAddPair(const APair, AValue: String): TJSONObject; overload;
    function IGAddPair(const APair: String; const Value: Integer): TJSONObject; overload;
    function IGAddPair(const APair: string; const Value: Double): TJSONObject; overload;
    function IGAddPairDate(const APair: string; const Value: TDate; const sFormat: String = 'yyyy-mm-dd'; const bDateToISO8601: Boolean = False; const bInputIsUTC: Boolean = True): TJSONObject; overload;
    function IGAddPairDateTime(const APair: string; const Value: TDateTime; const sFormat: String = 'yyyy-mm-dd HH:nn:ss.zzz'; const bDateToISO8601: Boolean = False; const bInputIsUTC: Boolean = True): TJSONObject; overload;
    function IGAddPair(const APair: string; const Value: Boolean): TJSONObject; overload;
    procedure IGRemovePair(const PairName: string); overload;

    function IGGetStr(sPairName: string): string;
    function IGGetStrDef(sPairName: string; Default: String = ''): string;
    function IGGetStrQt(sPairName: string): string;
    function IGGetStrDefQt(sPairName: string; Default: String): string;
    function IGGetStrSQL(sPairName: string; Options: TJSONSQLOptions = DefaultStrSQL): string;
    function IGTryGetStr(sPair: String; sNotExist: String = ''): String;
    function IGGetInt(sPairName: string): Integer;
    function IGGetIntDef(sPairName: string; Default: Integer): Integer;
    function IGGetFloat(sPairName: string): Double;
    function IGGetFloatDef(sPairName: string; Default: Double): Double;
    function IGGetFloatSql(sPairName: string; Options: TJSONSQLOptions = []): string;
    function IGGetFloatSqlDef(sPairName: String; Default: Double): String;
    function IGGetDate(sPairName: string; sShortDateFormat: String = 'yyyy-mm-dd'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): TDate;
    function IGGetDateDef(sPairName: string; Default: TDate; sShortDateFormat: String = 'yyyy-mm-dd'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): TDate;
    function IGGetDateSql(sPairName: string; sShortDateFormat: String = 'yyyy-mm-dd'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): string;
    function IGGetDateSqlQt(sPairName: string; sShortDateFormat: String = 'yyyy-mm-dd'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): string;
    function IGGetDateSqlDef(sPairName: string; Default: TDate; sShortDateFormat: String = 'yyyy-mm-dd'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): string;
    function IGGetDateTime(sPairName: string; sShortDateFormat: String = 'yyyy-mm-dd'; sLongTimeFormat: String = 'HH:nn:ss'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): TDateTime;
    function IGGetDateTimeDef(sPairName: string; Default: TDateTime; sShortDateFormat: String = 'yyyy-mm-dd'; sLongTimeFormat: String = 'HH:nn:ss'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): TDateTime;
    function IGGetDateTimeSql(sPairName: string; sShortDateFormat: String = 'yyyy-mm-dd'; sLongTimeFormat: String = 'HH:nn:ss'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): string;
    function IGGetDateTimeSqlDef(sPairName: string; Default: TDateTime; sShortDateFormat: String = 'yyyy-mm-dd'; sLongTimeFormat: String = 'HH:nn:ss'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): string;
    function IGGetBoolean(sPairName: string): Boolean;
    function IGGetBooleanDef(sPairName: string; DefValue: Boolean): Boolean;
    function IGGetValueCoalesce<T>(sPairsNames: TArray<String>;  Default: T; bEmptyIsNull: Boolean = False): T; overload;

    function IGIsNull(sPairName: String): Boolean;
    function IGNotIsNull(sPairName: String): Boolean;
    function IGIsEmpty(sPairName: String): Boolean;
    function IGNotIsEmpty(sPairName: String): Boolean;
    function IGIsNullOrEmpty(sPairName: String): Boolean;
    function IGNotIsNullOrEmpty(sPairName: String): Boolean;

    function IGSameValue(const APair, AValue: String): Boolean; overload;
    function IGSameValue(const APair: string; const Value: Double): Boolean; overload;
    function IGSameDate(const APair: string; const Value: TDate; const sFormat: String = 'yyyy-mm-dd'; const bDateToISO8601: Boolean = False; const bInputIsUTC: Boolean = True): Boolean; overload;
    function IGSameDateTime(const APair: string; const Value: TDateTime; const sFormat: String = 'yyyy-mm-dd HH:nn:ss.zzz'; const bDateToISO8601: Boolean = False; const bInputIsUTC: Boolean = True): Boolean; overload;
    function IGSameValue(const APair: string; const Value: Boolean): Boolean; overload;

    ///	<summary>
    ///	  Retorna o valor do Par do objeto JSON tratando as excessões.
    ///	</summary>
    ///	<param name="oJson">
    ///	  Objeto JSON
    ///	</param>
    ///	<param name="sPair">
    ///	  Par que será retornado o Valor
    ///	</param>
    ///	<remarks>
    ///	  Francis - 13/11/2014 as 11:20
    ///	</remarks>
    function IGetPair(sPair: String): String; Overload;

    // Devolve o valor do par já com quoted, ou gera exception
    function IGetPairQt(sPair: String): String;

    ///	<summary>
    ///   Verifica se existe o par no objeto JSON
    ///	</summary>
    ///	<param name="sPair">
    ///	  Par que deseja verifica se existe
    ///	</param>
    ///	<param name="bCriarRaise">
    ///	  Booleano para definir se vai criar raise ou retornar false
    ///	</param>
    ///	<remarks>
    ///	  Alan Miranda - 11/12/2015 às 08:03
    ///	</remarks>
    function IGExistPair(sPair: String; bCriarRaise: Boolean = False; sMsg: string = ''): Boolean;
    function IGNotExistPair(sPair: String): Boolean;

    /// Se o par não existir vai criar uma exception de validação
    procedure IGCheckPair(sPair: String; sMsg: string = '');
    procedure IGCheckIsNull(sPairName: String; sMsg: String = '');
    procedure IGCheckIsEmtpy(sPairName: String; sMsg: String = '');
    procedure IGCheckIsNullOrEmpty(sPairName: String; sMsg: String = '');

    function IGExistItens :Boolean;

    // Retornar os campos e valores padronizados para script de update
    function SQLFieldsAndValues(sIgnore: String = ''): string;

    // Retornar os campos
    function SQLFields(sIgnore: String = ''): string;

    // Retornar os valores
    function SQLValues(sIgnore: String = ''): string;

    function This: TJSONObject;
  end;

  {$EndRegion}

  {$Region '/// Helper de TJSONPair '}

  TIGJSONPair = class helper for TJSONPair
  public
    function IGGetChave: string;
    function IGGetValor: string;
  end;

  {$EndRegion}

  TJSONDataSet = class
  private type
    TJSONDataSetState = (Browse, Edit, Insert);
  private
    FJSON: TJSONArray;
    FITEM: TJSONObject;
    FTEMP: TJSONObject;
    FIndex: Integer;
    FBof: Boolean;
    FEof: Boolean;
    FState: TJSONDataSetState;
    function Value(const sPar: String): TJSONValue;
    function RemovePair(const oJSON: TJSONObject; const sPar: String): TJSONDataSet;
    function Path(const sPath: String): TJSONObject;
    function PreparePair(const sPar: String): TPair<String, TJSONObject>;
  public
    constructor Create;
    destructor Destroy; override;
    function Open(const JSON: TJSONArray): TJSONDataSet;
    function Clone(const JSON: TJSONArray): TJSONDataSet;
    function First: TJSONDataSet;
    function Last: TJSONDataSet;
    function Prior: TJSONDataSet;
    function Next: TJSONDataSet;
    function RecordCount: Integer;
    function IsEmpty: Boolean;
    function Bof: Boolean;
    function Eof: Boolean;
    function Append: TJSONDataSet;
    function Edit: TJSONDataSet;
    function Cancel: TJSONDataSet;
    function Post: TJSONDataSet;
    function Delete: TJSONDataSet;
    function State: TJSONDataSetState;
    function Exists(sPares: String; aValores: Array of Variant): Boolean;
    function Str(const sPar: String): String; overload;
    function Str(const sPar, sValor: String): TJSONDataSet; overload;
    function Date(const sPar: String): TDate; overload;
    function Date(const sPar: String; const dValor: TDate): TJSONDataSet; overload;
    function DateTime(const sPar: String): TDateTime; overload;
    function DateTime(const sPar: String; const dValor: TDateTime): TJSONDataSet; overload;
    function Int(const sPar: String): Integer; overload;
    function Int(const sPar: String; const iValor: Integer): TJSONDataSet; overload;
    function Float(const sPar: String): Double; overload;
    function Float(const sPar: String; const dValor: Double): TJSONDataSet; overload;
    function JSON: TJSONArray;
  end;

  {$Region '/// Funções comuns para manipulação de JSON '}

  ///	<summary>
  ///	  Obter um arquivo no formato string JSONArray
  ///	</summary>
  ///	<param name="pDir">
  ///	  Local para obter o arquivo desejado
  ///	</param>
  ///	<remarks>
  ///	  Alan Miranda - 14/03/2015 às 08:18
  ///	</remarks>
  function  IGFileToJSON(pDir: string): string;

  ///	<summary>
  ///	  Salvar um arquivo JSON em uma pasta passada pelo parametro
  ///	</summary>
  ///	<param name="sArquivoJSON">
  ///	  Arquivo de string no Formato JSONArray
  ///	</param>
  ///	<param name="pDir">
  ///	  Local para salvar o arquivo passado
  ///	</param>
  ///	<remarks>
  ///	  Alan Miranda - 14/03/2015 às 08:16
  ///	</remarks>
  procedure IGJSONToFile(sArquivoJSON: String; pDir: string);

  ///	<summary>
  ///	  Converte uma string no formato JSON em um Objeto JSON
  ///	</summary>
  ///	<param name="str">
  ///	  String a ser convertida
  ///	</param>
  ///	<remarks>
  ///	  Francis - 13/11/2014 as 07:13
  ///	</remarks>
  function IGStrToJSONObject(str: String): TJSONObject;

  ///	<summary>
  ///	  Converte uma string no formato JSONArray em um Objeto JSONArray
  ///	</summary>
  ///	<param name="str">
  ///	  String a ser convertida
  ///	</param>
  ///	<remarks>
  ///	  Alan Miranda - 14/03/2015 às 08:12
  ///	</remarks>
  function IGStrToJSONArray(str: String): TJSONArray;

  ///	<summary>
  ///	  Monta condição where com base nos pares passados no JSONObject
  ///	</summary>
  ///	<param name="oJSON">
  ///	  Objeto JSON que será utilizado para montar a sintaxe
  ///	</param>
  ///	<remarks>
  ///	  Francis - 04/12/2014 as 10:44
  ///	</remarks>
  function IGJSONToWhere(oJson: TJSONObject): String;

  ///	<summary>
  ///	  Transforma um arquivo StringStream em um array json
  ///	</summary>
  ///	<param name="pArquivoStream">
  ///	  Arquivo StringStream que deseja transformar array json
  ///	</param>
  ///	<remarks>
  ///	  Alan Miranda - 26/02/2015 às 13:15
  ///	</remarks>
  function IGStrStreamToJSONArray(pArquivoStream: TStringStream): TJSONArray;

  ///	<summary>
  ///	  Passa um arquivo array json em string stream
  ///	</summary>
  ///	<param name="pArrayJSON">
  ///	  Parametro com o arquivo no formato array json
  ///	</param>
  ///	<remarks>
  ///	  Alan Miranda - 26/02/2015 às 13:15
  ///	</remarks>
  function IGJSONArrayToStrStream(pArrayJSON: TJSONArray): TStringStream;

  function IGStrToJSONValue(str: String): TJSONValue;

  {$EndRegion}

implementation

{$Region '/// Uses - Implementation '}
uses
  System.DateUtils,
  System.StrUtils,
  System.SysUtils;

{$EndRegion}

const
  sl = sLineBreak;

function Qt(Value: String): String;
begin
  Result := QuotedStr(Value);
end;

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

{$Region '/// Extensão da classe TJSONObject '}

{ TIGJSONObject }

function TIGJSONObject.IGAddPair(const Pair: TJSONPair): TJSONObject;
begin
  Result := Self.AddPair(Pair);
end;

function TIGJSONObject.IGAddPair(const Str: string; const Val: TJSONValue): TJSONObject;
begin
  Result := Self.AddPair(Str, Val);
end;

function TIGJSONObject.IGAddPair(const Str: TJSONString; const Val: TJSONValue): TJSONObject;
begin
  Result := Self.AddPair(Str, Val);
end;

function TIGJSONObject.IGAddPair(const APair, AValue: String): TJSONObject;
begin
  Result := Self;
  IGRemovePair(APair);
  Self.AddPair(APair, TJSONString.Create(IfThen(AValue.Trim.IsEmpty, ' ', AValue)));
end;

function TIGJSONObject.IGAddPair(const APair: String; const Value: Integer): TJSONObject;
begin
  Result := Self;
  IGRemovePair(APair);
  AddPair(APair, TJSONNumber.Create(Value));
end;

function TIGJSONObject.IGAddPair(const APair: String; const Value: Double): TJSONObject;
begin
  Result := Self;
  IGRemovePair(APair);
  AddPair(APair, TJSONNumber.Create(Value));
end;

function TIGJSONObject.IGAddPairDate(const APair: string; const Value: TDate; const sFormat: String = 'yyyy-mm-dd'; const bDateToISO8601: Boolean = False; const bInputIsUTC: Boolean = True): TJSONObject;
begin
  Result := Self;
  IGRemovePair(APair);
  if Value = 0 then
    AddPair(APair, TJSONNull.Create)
  else
  if bDateToISO8601 then
    AddPair(APair, TJSONString.Create(DateToISO8601(Value, bInputIsUTC)))
  else
    AddPair(APair, TJSONString.Create(FormatDateTime(sFormat, Value)));
end;

function TIGJSONObject.IGAddPairDateTime(const APair: string; const Value: TDateTime; const sFormat: String = 'yyyy-mm-dd HH:nn:ss.zzz'; const bDateToISO8601: Boolean = False; const bInputIsUTC: Boolean = True): TJSONObject;
begin
  Result := Self;
  IGRemovePair(APair);
  if Value = 0 then
    AddPair(APair, TJSONNull.Create)
  else
  if bDateToISO8601 then
    AddPair(APair, TJSONString.Create(DateToISO8601(Value, bInputIsUTC)))
  else
    AddPair(APair, TJSONString.Create(FormatDateTime(sFormat, Value)));
end;

function TIGJSONObject.IGAddPair(const APair: String; const Value: Boolean): TJSONObject;
begin
  Result := Self;
  IGRemovePair(APair);
  AddPair(APair, TJSONBool.Create(Value));
end;

procedure TIGJSONObject.IGRemovePair(const PairName: string);
var
  jp: TJSONPair;
begin
  if not IGExistPair(PairName) then
    Exit;

  jp := Self.RemovePair(PairName);
  FreeAndNil(jp);
end;

function TIGJSONObject.IGSameValue(const APair, AValue: String): Boolean;
begin
  Result := IGGetStr(APair).Equals(AValue);
end;

function TIGJSONObject.IGSameValue(const APair: string; const Value: Double): Boolean;
begin
  Result := IGNotIsEmpty(APair) and (IGGetFloat(APair) = Value);
end;

function TIGJSONObject.IGSameDate(const APair: string; const Value: TDate; const sFormat: String; const bDateToISO8601, bInputIsUTC: Boolean): Boolean;
begin
  Result := IGGetDate(APair) = Value;
end;

function TIGJSONObject.IGSameDateTime(const APair: string; const Value: TDateTime; const sFormat: String; const bDateToISO8601, bInputIsUTC: Boolean): Boolean;
begin
  Result := IGGetDateTime(APair) = Value;
end;

function TIGJSONObject.IGSameValue(const APair: string; const Value: Boolean): Boolean;
begin
  Result := IGNotIsEmpty(APair) and (IGGetBoolean(APair) = Value);
end;

function TIGJSONObject.IGGetBoolean(sPairName: string): Boolean;
begin
  IGCheckPair(sPairName);
  Result := Self.GetValue(sPairName).AsType<Boolean>;
end;

function TIGJSONObject.IGGetBooleanDef(sPairName: string; DefValue: Boolean): Boolean;
begin
  if IGNotIsEmpty(sPairName) then
    Result := IGGetBoolean(sPairName)
  else
    Result := DefValue;
end;

function TIGJSONObject.IGGetDate(sPairName: string; sShortDateFormat: String = 'yyyy-mm-dd'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): TDate;
var
  fsDate: TFormatSettings;
begin
  IGCheckPair(sPairName);

  if IGIsEmpty(sPairName) then
    Result := 0
  else
  if bISO8601ToDate then
    Result := ISO8601ToDate(Self.IGGetStr(sPairName), bReturnIsUTC)
  else
  begin
    fsDate := TFormatSettings.Create;
    fsDate.ShortDateFormat := sShortDateFormat;
    fsDate.DateSeparator   :=
      sShortDateFormat
        .Replace('y', '', [rfReplaceAll, rfIgnoreCase])
        .Replace('m', '', [rfReplaceAll, rfIgnoreCase])
        .Replace('d', '', [rfReplaceAll, rfIgnoreCase])
        .ToUpper[1];
    Result := StrToDate(Self.IGGetStr(sPairName), fsDate);
  end;
end;

function TIGJSONObject.IGGetDateDef(sPairName: string; Default: TDate; sShortDateFormat: String = 'yyyy-mm-dd'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): TDate;
begin
  if IGNotIsEmpty(sPairName) then
    Result := IGGetDate(sPairName, sShortDateFormat, bISO8601ToDate, bReturnIsUTC)
  else
    Exit(Default);
end;

function TIGJSONObject.IGGetDateSql(sPairName: string; sShortDateFormat: String = 'yyyy-mm-dd'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): string;
begin
  IGCheckPair(sPairName);

  if IGNotIsEmpty(sPairName) then
    DateTimeToString(Result, 'yyyy-mm-dd', IGGetDate(sPairName, sShortDateFormat, bISO8601ToDate, bReturnIsUTC))
  else
    Result := sqlNULL;
end;

function TIGJSONObject.IGGetDateSqlQt(sPairName: string; sShortDateFormat: String = 'yyyy-mm-dd'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): string;
begin
  Result := IGGetDateSql(sPairName, sShortDateFormat, bISO8601ToDate, bReturnIsUTC);
  if not Result.Equals(sqlNULL) then
    Result := Qt(Result);
end;

function TIGJSONObject.IGGetDateSqlDef(sPairName: string; Default: TDate; sShortDateFormat: String = 'yyyy-mm-dd'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): string;
begin
  if IGNotIsEmpty(sPairName) then
    Result := IGGetDateSql(sPairName, sShortDateFormat, bISO8601ToDate, bReturnIsUTC)
  else
    DateTimeToString(Result, 'yyyy-mm-dd', Default);
end;

function TIGJSONObject.IGGetDateTime(sPairName: string; sShortDateFormat: String = 'yyyy-mm-dd'; sLongTimeFormat: String = 'HH:nn:ss'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): TDateTime;
var
  fsDate: TFormatSettings;
begin
  IGCheckPair(sPairName);
  if IGIsEmpty(sPairName) then
    Exit(0);

  if bISO8601ToDate then
    Result := ISO8601ToDate(Self.IGGetStr(sPairName), bReturnIsUTC)
  else
  begin
    fsDate := TFormatSettings.Create;
    fsDate.ShortDateFormat := sShortDateFormat;
    fsDate.LongTimeFormat  := sLongTimeFormat;
    fsDate.DateSeparator   :=
      sShortDateFormat
        .Replace('y', '', [rfReplaceAll, rfIgnoreCase])
        .Replace('m', '', [rfReplaceAll, rfIgnoreCase])
        .Replace('d', '', [rfReplaceAll, rfIgnoreCase])
        .ToUpper[1];
    fsDate.TimeSeparator :=
      sLongTimeFormat
        .Replace('H', '', [rfReplaceAll, rfIgnoreCase])
        .Replace('n', '', [rfReplaceAll, rfIgnoreCase])
        .Replace('s', '', [rfReplaceAll, rfIgnoreCase])
        .ToUpper[1];
    fsDate.DecimalSeparator := '.';
    Result := StrToDateTime(Self.IGGetStr(sPairName), fsDate);
  end;
end;

function TIGJSONObject.IGGetDateTimeDef(sPairName: string; Default: TDateTime; sShortDateFormat: String = 'yyyy-mm-dd'; sLongTimeFormat: String = 'HH:nn:ss'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): TDateTime;
begin
  if IGNotIsEmpty(sPairName) then
    Result := IGGetDateTime(sPairName, sShortDateFormat, sLongTimeFormat, bISO8601ToDate, bReturnIsUTC)
  else
    Result := Default;
end;

function TIGJSONObject.IGGetDateTimeSql(sPairName: string; sShortDateFormat: String = 'yyyy-mm-dd'; sLongTimeFormat: String = 'HH:nn:ss'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): string;
begin
  IGCheckPair(sPairName);

  if IGNotIsEmpty(sPairName) then
    DateTimeToString(Result, 'yyyy-mm-dd hh:mm:ss.zzz', IGGetDateTime(sPairName, sShortDateFormat, sLongTimeFormat, bISO8601ToDate, bReturnIsUTC))
  else
    Result := sqlNULL;
end;

function TIGJSONObject.IGGetDateTimeSqlDef(sPairName: string; Default: TDateTime; sShortDateFormat: String = 'yyyy-mm-dd'; sLongTimeFormat: String = 'HH:nn:ss'; const bISO8601ToDate: Boolean = False; const bReturnIsUTC: Boolean = True): string;
begin
  if IGNotIsEmpty(sPairName) then
    Result := IGGetDateTimeSql(sPairName, sShortDateFormat, sLongTimeFormat, bISO8601ToDate, bReturnIsUTC)
  else
    DateTimeToString(Result,'yyyy-mm-dd hh:mm:ss.zzz', Default);
end;

function TIGJSONObject.IGGetFloat(sPairName: string): Double;
begin
  IGCheckPair(sPairName);
  Result := Self.GetValue(sPairName).AsType<Double>;
end;

function TIGJSONObject.IGGetFloatDef(sPairName: string; Default: Double): Double;
begin
  if IGNotIsEmpty(sPairName) then
    Result := IGGetFloat(sPairName)
  else
    Result := Default;
end;

function TIGJSONObject.IGGetFloatSql(sPairName: string; Options: TJSONSQLOptions = []): string;
begin
  if (TJSONSQL.AllowNull in Options) and IGIsNullOrEmpty(sPairName) then
    Exit(sqlNULL);

  Result := FloatToStr(IGGetFloat(sPairName)).Replace('.', '', [rfReplaceAll]).Replace(',', '.');
end;

function TIGJSONObject.IGGetFloatSqlDef(sPairName: String; Default: Double): String;
begin
  if IGNotIsEmpty(sPairName) then
    Result := IGGetFloatSql(sPairName)
  else
    Result := FloatToStr(Default).Replace('.', '', [rfReplaceAll]).Replace(',', '.');
end;

function TIGJSONObject.IGGetInt(sPairName: string): Integer;
begin
  IGCheckPair(sPairName);
  Result := Self.GetValue(sPairName).AsType<Integer>;
end;

function TIGJSONObject.IGGetIntDef(sPairName: string; Default: Integer): Integer;
begin
  if IGNotIsEmpty(sPairName) then
    Result := IGGetInt(sPairName)
  else
    Result := Default;
end;

function TIGJSONObject.IGGetStr(sPairName: string): string;
begin
  IGCheckPair(sPairName);
  Result := Self.GetValue(sPairName).AsType<String>;
end;

function TIGJSONObject.IGGetStrDef(sPairName: string; Default: String = ''): string;
begin
  if IGNotIsEmpty(sPairName) then
    Result := IGGetStr(sPairName)
  else
    Result := Default;
end;

function TIGJSONObject.IGGetStrQt(sPairName: string): string;
begin
  Result := QuotedStr(IGGetStr(sPairName));
end;

function TIGJSONObject.IGGetStrDefQt(sPairName, Default: String): string;
begin
  if IGNotIsEmpty(sPairName) then
    Result := IGGetStrQt(sPairName)
  else
    Result := QuotedStr(Default);
end;

function TIGJSONObject.IGGetStrSQL(sPairName: string; Options: TJSONSQLOptions = DefaultStrSQL): string;
begin
  // Inicializa com Nulo
  Result := sqlNULL;

  if IGIsNull(sPairName) then
  begin
    // Se não pode permitir valor nulo
    if not (TJSONSQL.AllowNull in Options) then
      raise Exception.Create('Valor nulo não permitido');
  end
  else
  if IGIsEmpty(sPairName) then
  begin
    // Se Vazio deve ser transformado para nulo
    if TJSONSQL.EmptyToNull in Options then
    begin
      // Se permite null
      if TJSONSQL.AllowNull in Options then
        Exit;

      raise Exception.Create('Valor nulo não permitido')
    end;

    // Se permite vazio
    if TJSONSQL.AllowEmpty in Options then
      Exit(Qt(EmptyStr));

    raise Exception.Create('Valor vazio não permitido');
  end
  else // Finaliza o texto sem Quoted
  if TJSONSQL.NoQT in Options then
    Result := IGGetStr(sPairName)
  else // Finaliza com Texto com Quoted
    Result := IGGetStrQt(sPairName);
end;

function TIGJSONObject.IGGetValueCoalesce<T>(sPairsNames: TArray<String>; Default: T; bEmptyIsNull: Boolean): T;
var
  bOk: Boolean;
  sPair: String;
begin
  bOk   := False;
  sPair := EmptyStr;
  for sPair in sPairsNames do
  begin
    // Se está Null, então vai para o próximo
    if IGIsNull(sPair) then
      Continue;

    // Se Empty é considerado NULL e está Empty, vai para o próximo
    if bEmptyIsNull and IGIsEmpty(sPair) then
      Continue;

    // Encontrou, então finaliza e vai obter o valor
    bOk := True;
    Break;
  end;

  // Se não encontrou, finaliza com valor padrão
  if not bOk or sPair.Trim.IsEmpty then
    Exit(Default);

  Result := Self.GetValue<T>(sPair);
end;

function TIGJSONObject.IGIsEmpty(sPairName: String): Boolean;
var
  jv: TJSONValue;
begin
  // Vazio se = ((Não existe o Pair) ou (Se existe o Pair E Está vazio))
  if IGExistPair(sPairName) then
  begin
    jv := GetValue(sPairName);
    if jv is TJSONArray then
      Result := TJSONArray(jv).Count = 0
    else
    if jv is TJSONObject then
      Result := TJSONObject(jv).Count = 0
    else
      Result := IGGetStr(sPairName).Trim.IsEmpty;
  end
  else
    Result := True;
end;

function TIGJSONObject.IGIsNull(sPairName: String): Boolean;
begin
  // Null = ((Não existe o Pair) or (Se existe o Pair é do tipo TJSONNull))
  Result := not IGExistPair(sPairName) or (Self.GetValue(sPairName) is TJSONNull);
end;

function TIGJSONObject.IGNotExistPair(sPair: String): Boolean;
begin
  Result := not IGExistPair(sPair, False, EmptyStr);
end;

function TIGJSONObject.IGNotIsEmpty(sPairName: String): Boolean;
begin
  Result := not IGIsEmpty(sPairName);
end;

function TIGJSONObject.IGNotIsNull(sPairName: String): Boolean;
begin
  Result := not IGIsNull(sPairName);
end;

function TIGJSONObject.IGIsNullOrEmpty(sPairName: String): Boolean;
begin
  Result := IGIsNull(sPairName) or IGIsEmpty(sPairName);
end;

function TIGJSONObject.IGNotIsNullOrEmpty(sPairName: String): Boolean;
begin
  Result := not IGIsNullOrEmpty(sPairName);
end;

function TIGJSONObject.IGetPair(sPair: String): String;
begin
  IGCheckPair(sPair);

  if Self.GetValue(sPair) is TJSONNumber then
    Result := TJSONNumber(Self.GetValue(sPair)).AsDouble.ToString
  else
    Result := Self.GetValue(sPair).Value;
end;

function TIGJSONObject.IGetPairQt(sPair: String): String;
begin
  IGCheckPair(sPair);

  if Self.GetValue(sPair) is TJSONNumber then
    Result := TJSONNumber(Self.GetValue(sPair)).AsDouble.ToString
  else
  if Self.GetValue(sPair) is TJSONNull then
    Result := sqlNULL
  else
  if UpperCase(Self.GetValue(sPair).Value).Trim.Equals(sqlNULL) then
    Result := sqlNULL
  else
    Result := QuotedStr(Self.GetValue(sPair).Value);
end;

function TIGJSONObject.IGExistPair(sPair: String; bCriarRaise: Boolean = False; sMsg: string = ''): Boolean;
begin
  Result := False;

  // Se existir result true e sair fora
  if Assigned(Self) and Assigned(Self.GetValue(sPair)) then
    Exit(True);

  // Se não for válido mas não quer que crie exception
  if not bCriarRaise then
    Exit;

  // Se não informou uma mensagem de erro, utiliza a padrão
  if sMsg.Trim.IsEmpty then
    sMsg := 'Par '+ sPair +' inexistente no objeto JSON';

  // Exibir mensagem de erro
  raise Exception.Create(sMsg);
end;

function TIGJSONObject.IGTryGetStr(sPair: String; sNotExist: String = ''): String;
begin
  if not Self.TryGetValue<String>(sPair, Result) then
    Result := sNotExist;
end;

procedure TIGJSONObject.IGCheckPair(sPair: String; sMsg: string = '');
begin
  IGExistPair(sPair, True, sMsg);
end;

procedure TIGJSONObject.IGCheckIsNull(sPairName: String; sMsg: String = '');
begin
  // Se não está NULL, finaliza o método
  if not IGIsNull(sPairName) then
    Exit;

  // Se não informou uma mensagem de erro, utiliza a padrão
  if sMsg.Trim.IsEmpty then
    sMsg := 'Pair '+ sPairName +' está '+ sqlNULL +'!';

  // Exibe mensagem de erro
  raise Exception.Create(sMsg);
end;

procedure TIGJSONObject.IGCheckIsEmtpy(sPairName: String; sMsg: String = '');
begin
  // Se não está vazio, finaliza o método
  if not IGIsEmpty(sPairName) then
    Exit;

  // Se não informou uma mensagem de erro, utiliza a padrão
  if sMsg.Trim.IsEmpty then
    sMsg := 'Pair '+ sPairName +' está vazio!';

  // Exibe mensagem de erro
  raise Exception.Create(sMsg);
end;

procedure TIGJSONObject.IGCheckIsNullOrEmpty(sPairName, sMsg: String);
begin
  // Se não está vazio, finaliza o método
  if not IGIsNullOrEmpty(sPairName) then
    Exit;

  // Se não informou uma mensagem de erro, utiliza a padrão
  if sMsg.Trim.IsEmpty then
    sMsg := 'Pair '+ sPairName +' está vazio ou nulo!';

  // Exibe mensagem de erro
  raise Exception.Create(sMsg);
end;

function TIGJSONObject.IGExistItens: Boolean;
begin
  Result := Self.Count > 0;
end;

function TIGJSONObject.SQLFields(sIgnore: String = ''): string;
var
  I: Integer;
begin
  // Monta os campos
  for I := 0 to Pred(Self.Count) do
  begin
    // IG_RECNO e IG_BANCO não podem ser alterados
    if MatchStr(Self.Pairs[I].JsonString.Value, ['IG_RECNO', 'IG_BANCO']) then
      Continue;

    // ignorando campos informados pelo usuário
    if not sIgnore.Trim.IsEmpty then
      if MatchStr(Self.Pairs[I].JsonString.Value, SplitString(sIgnore,',')) then
        Continue;

    // Identação
    if not Result.Trim.IsEmpty then
      Result := Result +'      , ';

    // Concatena os campos
    Result := Result + Self.Pairs[I].JsonString.Value + sl;
  end;

  // Limpar espaços antes e depois
  Result := Trim(Result);
end;

function TIGJSONObject.SQLValues(sIgnore: String = ''): string;
const
  Ident = sl +'      , ';
var
  I: Integer;
  sValue: String;
begin
  // Monta os campos
  for I := 0 to Pred(Self.Count) do
  begin
    // IG_RECNO e IG_BANCO não podem ser alterados
    if MatchStr(Self.Pairs[I].JsonString.Value, ['IG_RECNO', 'IG_BANCO']) then
      Continue;

    // ignorando campos informados pelo usuário
    if not sIgnore.Trim.IsEmpty then
      if MatchStr(Self.Pairs[I].JsonString.Value, SplitString(sIgnore,',')) then
        Continue;

    if Self.Pairs[I].JsonValue is TJSONNumber then
      sValue := FloatToSql(TJSONNumber(Self.Pairs[I].JsonValue).AsDouble)
    else
    if Self.Pairs[I].JsonValue is TJSONNull then
      sValue := sqlNULL
    else
    if Self.Pairs[I].JsonValue is TJSONBool then
      sValue := TJSONBool(Self.Pairs[I].JsonValue).AsBoolean.ToString(True)
    else
    if Self.Pairs[I].JsonValue is TJSONObject then
    begin
      if TJSONObject(Self.Pairs[I].JsonValue).IGNotIsNullOrEmpty('sql') then
        sValue := '('+ TJSONString(TJSONObject(Self.Pairs[I].JsonValue).GetValue('sql')).Value +')'
      else
      if TJSONObject(Self.Pairs[I].JsonValue).IGNotIsNullOrEmpty('SQL') then
        sValue := '('+ TJSONString(TJSONObject(Self.Pairs[I].JsonValue).GetValue('SQL')).Value +')';
    end
    else
      sValue := Qt(Self.Pairs[I].JsonValue.Value);

    Include(Result, sValue, Ident);
  end;
end;

function TIGJSONObject.SQLFieldsAndValues(sIgnore: String = ''): string;
var
  I: Integer;
  sField: string;
  iQtdFields: Integer;
  sValue: string;
begin
  // Contar apenas uma vez
  iQtdFields := Pred(Self.Count);

  // Monta os campos
  for I := 0 to iQtdFields do
  begin
    // IG_RECNO e IG_BANCO não podem ser alterados
    if Self.Pairs[I].JsonString.Value.Equals('IG_RECNO') or
       Self.Pairs[I].JsonString.Value.Equals('IG_BANCO') then
      Continue;

    // ignorando campos informados pelo usuário
    if not sIgnore.Trim.IsEmpty then
      if MatchStr(Self.Pairs[I].JsonString.Value, SplitString(sIgnore,',')) then
        Continue;

    // Identação
    if not(Result.Trim.IsEmpty) then
      Result := Result + '     , ';

    // Obter o campo e o valor
    sField := Self.Pairs[I].JsonString.Value;
    sValue := Self.Pairs[I].JsonValue.Value;

    // Não é número?
    if not (Self.Pairs[I].JsonValue is TJSONNumber) then
    begin
      // Não é "NULL" ?
      if not UpperCase(sValue).Equals(sqlNULL) then
        // Adiciona aspas porque é string
        sValue := QuotedStr(sValue);
    end;

    // Concatena o campo com o valor
    Result := Result + sField  + ' = ' +  sValue + sLineBreak;
  end;

  // Limpar espaços antes e depois
  Result := Trim(Result);
end;

function TIGJSONObject.This: TJSONObject;
begin
  Result := Self;
end;

{$EndRegion}

{$Region' Correção Berlin para Tokyo '}

function TIGJSONObject.AddPair(const Pair: TJSONPair): TJSONObject;
begin
  if Pair <> nil then
    AddDescendant(Pair);
  Result := Self;
end;

function TIGJSONObject.AddPair(const Str: TJSONString; const Val: TJSONValue): TJSONObject;
begin
  if (Str <> nil) and (Val <> nil) then
    AddPair(TJSONPair.Create(Str, Val));
  Result := Self;
end;

function TIGJSONObject.AddPair(const Str: string; const Val: TJSONValue): TJSONObject;
begin
  if (not Str.IsEmpty) and (Val <> nil) then
    AddPair(TJSONPair.Create(Str, Val));
  Result := Self;
end;

function TIGJSONObject.AddPair(const Str: string; const Val: string): TJSONObject;
begin
  if (not Str.IsEmpty) and (not Val.IsEmpty) then
    AddPair(TJSONPair.Create(Str, Val));
  Result := Self;
end;
{$EndRegion}

{$Region' Correção Tokyo para Rio '}

function TIGJSONObject.EGetPair(const Index: Integer): TJSONPair;
begin
  Result := nil;
  if Count > 0 then
    Result := System.JSON.TJSONObject(Self).GetPair(Index);
end;

{$EndRegion}

{$Region '/// Funções comuns para manipulação de JSON '}

function IGFileToJSON(pDir: string): string;
var
  sBytesArquivo   : string;
  aArquivoJSON    : TJSONArray;
  iCont           : Integer;
  iTamanhoArquivo : Integer;
  ssArquivoStream : TStringStream;
begin
  try
    // Instanciando o objeto JSON que conterá o arquivo serializado
    aArquivoJSON := TJSONArray.Create;

    // Instanciando o objeto stream que carregará o arquivo para memoria
    ssArquivoStream := TStringStream.Create;
    try
      // Se o arquivo existir então carregar o JSONArray
      if (FileExists(pDir)) then
      begin
        // Carregando o arquivo para memoria
        ssArquivoStream.LoadFromFile(pDir);

        // Pegando o tamanho do arquivo
        iTamanhoArquivo := ssArquivoStream.Size;

        sBytesArquivo := '';

        // Fazendo um lanço no arquivo que está na memoria para pegar os bytes do mesmo
        for iCont := 0 to iTamanhoArquivo - 1 do
        begin
          // A medida que está fazendo o laço para pegar os bytes, os mesmos são jogados para
          // uma variável do tipo string separado por ","
          sBytesArquivo := sBytesArquivo + IntToStr(ssArquivoStream.Bytes[iCont]) + ', ';
        end;

        // Como é colocado uma vírgula após o byte, fica sempre sobrando uma vírgula, que é deletada
        Delete(sBytesArquivo, Length(sBytesArquivo)-1, 2);

        // 0. Adiciona a string que contém os bytes para o array JSON
        aArquivoJSON.Add(sBytesArquivo);

        // 1. Adiciona para o array JSON o tamanho do arquivo
        aArquivoJSON.AddElement(TJSONNumber.Create(iTamanhoArquivo));

        // Passa o result da função
        Result := aArquivoJSON.ToString;

      end;
    except
      on E: Exception do
        raise Exception.Create(e.Message);
    end;
  finally
    FreeAndNil(ssArquivoStream);
    FreeAndNil(aArquivoJSON);
  end;
end;

procedure IGJSONToFile(sArquivoJSON: String; pDir: string);
var
  sNomeArquivo          : String;
  sBytesArquivo         : String;
  aArquivoJSON          : TJSONArray;
  iCont                 : Integer;
  iTamanhoArquivo       : Integer;
  byArquivoBytes        : Tbytes;
  ssArquivoStream       : TStringStream;
  slArrayStringsArquivo : TStringList;
begin
   try
    try
      // Transforma a string recebida em Array JSON
      aArquivoJSON := IGStrToJSONArray(sArquivoJSON);;
      try
        // Cria um objeto do tipo TStringList para emparelhar os bytes
        slArrayStringsArquivo := TStringList.Create;

        {$Region '/// Items[0] - Bytes do arquivo'}

        // Pega a posição 0 do array que contem os bytes do arquivo
        sBytesArquivo := aArquivoJSON.Items[0].ToString;

        // Deleta a última aspas da string
        Delete(sBytesArquivo, Length(sBytesArquivo), 1);

        // Deleta a primeira aspas da string
        Delete(sBytesArquivo, 1, 1);

        // Coloca cada byte em uma linha no objeto TStringList
        ExtractStrings([','], [' '], PChar(sBytesArquivo), slArrayStringsArquivo);

        {$EndRegion}

        {$Region '/// Items[1] - Tamanho do arquivo'}

        // Pega na posição 1 o tamanho do arquivo
        iTamanhoArquivo := TJSONNumber(aArquivoJSON.Items[1]).AsInt;

        {$EndRegion}

        {$Region '/// Items[2] - Nome do arquivo'}

        // Pega o nome do arquivo que está na posição 2
        sNomeArquivo := aArquivoJSON.Items[2].ToString;

        // Deleta a última aspas da string
        Delete(sNomeArquivo, Length(sNomeArquivo), 1);

        // Deleta a primeira aspas da string
        Delete(sNomeArquivo, 1, 1);

        {$EndRegion}

        {$Region '/// Pegar os Bytes do StringList'}

        // Seta o tamanho do array de bytes igual ao tamanho do arquivo
        SetLength(byArquivoBytes, iTamanhoArquivo);

        // Faz um laço para pegar os bytes do objeto TStringList
        for iCont := 0 to iTamanhoArquivo - 1 do
        begin
          //Pega os bytes do TStringList e adiciona no array de bytes
          byArquivoBytes[iCont] := StrToInt(slArrayStringsArquivo[iCont]);
        end;

        {$EndRegion}

        {$Region '/// Salvar o Arquivo'}

        // Instancia o objeto TStringStream para salvar o arquivo
        ssArquivoStream := TStringStream.Create(byArquivoBytes);
        try
          // Verifica se o diretório passado por parâmetro não existe
          if not DirectoryExists(pDir) then
            // Se não existir o diretório vai ser criado
            ForceDirectories(pDir);

          // Salvar o arquivo no HD
          ssArquivoStream.SaveToFile(pDir + sNomeArquivo);
        finally
          // Liberar o TStringStream da memória
          FreeAndNil(ssArquivoStream);
        end;

        {$EndRegion}

      finally
        FreeAndNil(slArrayStringsArquivo);
      end;
    except
      on E: Exception do
        raise Exception.Create('Erro ao armazenar a Imagem! ' + #13 + 'Mensagem original: ' + #13 + e.Message);
    end;
  finally
    if Assigned(aArquivoJSON) then
      FreeAndNil(aArquivoJSON);
  end;
end;

function IGStrToJSONObject(str: String): TJSONObject;
begin
  try
    Result := TJSONObject(TJsonObject.ParseJSONValue(Str));
  except on E: Exception do
    raise Exception.Create('String com formato JSON inválido!' + sLineBreak + e.Message);
  end;
end;

function IGStrToJSONArray(str: String): TJSONArray;
begin
  try
    Result := TJSONObject.ParseJSONValue(Str) as TJSONArray;
  except on E: Exception do
    raise Exception.Create('String com formato JSON inválido!' + sLineBreak + e.Message);
  end;
end;

function IGStrToJSONValue(str: String): TJSONValue;
begin
  try
    Result := TJSONObject.ParseJSONValue(str);
  except on E: Exception do
    raise Exception.Create('String com formato JSON inválido!' + sLineBreak + e.Message);
  end;
end;

function IGJSONToWhere(oJson: TJSONObject): String;
var
  i   : Integer;
  k   : Integer;
  aStr: TStringList;
  sAux: String;
begin
  aStr := TStringList.Create;
  Result := ' WHERE ';

  try
    for i := 0 to Pred(oJson.Count) do
    begin
      {$Region ' --> Se possuir "|" usar OR '}
      if Pos('|', oJson.Pairs[i].JsonString.Value) > 0 then
      begin
        // Limpar a lista
        aStr.Clear;

        // Explode as '|'
        ExtractStrings(['|'], [' '], pChar(oJson.Pairs[i].JsonString.Value), aStr);

        // Adiciona os novos parametros no result
        Result := Result +'('+ aStr[0] +' = '+ QuotedStr(oJson.Pairs[i].JsonValue.Value) + ' OR ' +
                               aStr[1] +' = '+ QuotedStr(oJson.Pairs[i].JsonValue.Value) + ')';
      end
      {$EndRegion}

      {$Region ' --> Se possuir "~" usar BETWEEN '}
      else if Pos('~', oJson.Pairs[i].JsonValue.Value) > 0 then
      begin
        // Limpar a lista
        aStr.Clear;

        // Explode as '~'
        ExtractStrings(['~'], [' '], pChar(oJson.Pairs[i].JsonValue.Value), aStr);

        // Adiciona os novos parametros no result
        Result := Result + oJson.Pairs[i].JsonString.Value + ' BETWEEN ' + QuotedStr(aStr[0]) + ' AND ' + QuotedStr(aStr[1]);
      end
      {$EndRegion}

      {$Region ' --> Se possuir "$" usar IN '}
      else if Pos('$', oJson.Pairs[i].JsonValue.Value) > 0 then
      begin
        aStr.Clear;

        // Remove '$' da String
        sAux := StringReplace(oJson.Pairs[i].JsonValue.Value, '$', '', [rfReplaceAll]);

        // Explode as ','
        ExtractStrings([','], [' '], pChar(sAux), aStr);

        // Limpar a variavel para armazenar os parametros
        sAux := '';

        // Passar por todos os itens preparando para pesquisa
        for k := 0 to Pred(aStr.Count) do
        begin
          if not Trim(aStr[k]).IsEmpty then
          begin
            sAux := sAux + QuotedStr(Trim(aStr[k]));
            sAux := sAux + IfThen(k < Pred(aStr.Count) , ',', '');
          end;
        end;

        // Se o último caractere for uma virgula então remove-la
        if RightStr(Trim(sAux), 1).Equals(',') then
          Delete(sAux, Length(sAux), 1);

        // Se a variavel sAux estiver vazia voltar no inicio
        if Trim(sAux).IsEmpty then
          Continue;

        // Adiciona os novos parametros no result
        Result := Result + oJson.Pairs[i].JsonString.Value + ' IN (' + sAux + ')';
      end
      {$EndRegion}

      {$Region ' --> Se possuir "%" usar LIKE, senão usar = '}
      else
        Result := Result + oJson.Pairs[i].JsonString.Value +
          IfThen(Pos('%', oJson.Pairs[i].JsonValue.Value) > 0, ' LIKE ', ' = ') + QuotedStr(oJson.Pairs[i].JsonValue.Value);
      {$EndRegion}

      {$Region ' --> Definir o result da função '}
      if oJson.Count = 1 then
        Result := Result + ' AND 1 = 0 '
      else
        Result := Result + IfThen(I < Pred(oJson.Count), sLineBreak + ' AND ', '');
      {$EndRegion}
    end;
  finally
    FreeAndNil(aStr);
  end;
end;

function IGStrStreamToJSONArray(pArquivoStream: TStringStream): TJSONArray;
var
  sBytesArquivo: string;
  iTamanhoArquivo, iCont: Integer;
begin
  try
    // Instanciando o objeto JSON que conterá o arquivo serializado
    Result := TJSONArray.Create;

	  // pegando o tamanho do arquivo
    iTamanhoArquivo := pArquivoStream.Size;

    sBytesArquivo := '';

    // Fazendo um lanço no arquivo que está na memoria para pegar os bytes do mesmo
    for iCont := 0 to iTamanhoArquivo - 1 do
    begin
      // A medida que está fazendo o laço para pegar os bytes, os mesmos são jogados para
      // uma variável do tipo string separado por ","
      sBytesArquivo := sBytesArquivo + IntToStr(pArquivoStream.Bytes[iCont]) + ', ';
    end;

    // Como é colocado uma vírgula após o byte, fica sempre sobrando uma vígugula, que é deletada
    Delete(sBytesArquivo, Length(sBytesArquivo)-1, 2);

    // Adiciona a string que contém os bytes para o array JSON
    Result.Add(sBytesArquivo);

    // Adiciona para o array JSON o tamanho do arquivo
    Result.AddElement(TJSONNumber.Create(iTamanhoArquivo));

  except
    on E: Exception do
      raise Exception.Create(e.Message);
  end;
end;

procedure Split(const Delimiter: Char; Input: string; const Strings: TStrings);
begin
   Assert(Assigned(Strings)) ;
   Strings.Clear;
   Strings.Delimiter := Delimiter;
   Strings.DelimitedText := Input;
end;

function IGJSONArrayToStrStream(pArrayJSON: TJSONArray): TStringStream;
var
  sArquivo  : string;
  iTamanho  : Integer;
  iCont     : Integer;
  byArquivo : Tbytes;
  slArquivo : TStringList;
begin
  try
    // Na posicao zero temos o arquivo enviado
    sArquivo := (pArrayJSON as TJSONArray).Items[0].ToString;

    // Retira as aspas do JSON
    Delete(sArquivo, Length(sArquivo), 1);
    Delete(sArquivo, 1, 1);

    // Na posicao um temos o tamanho do arquivo enviado
    iTamanho := StrToInt((pArrayJSON as TJSONArray).Items[1].ToString);

    // Cria uma StringList, que receberá o arquivo como string
    slArquivo := TStringList.Create;

    // Transforma o arquivo string em uma lista
    Split(',',sArquivo, slArquivo);

    // Define o tamanho do arquivo de bytes
    SetLength(byArquivo, iTamanho);

    // Obtém os bytes fazendo um loop na StringList do arquivo recebido
    for iCont := 0 to iTamanho - 1 do
    begin
      byArquivo[iCont] := StrToInt(slArquivo[iCont]);
    end;

    // Devolve o arquivo recebido em TJSONArray como TStringStream
    Result := TStringStream.Create(byArquivo);

  except
    on E: Exception do
      raise Exception.Create(e.Message);
  end;
end;

{$EndRegion}

{ TIGJSONPair }

function TIGJSONPair.IGGetChave: string;
begin
  Result := Self.JsonString.Value;
end;

function TIGJSONPair.IGGetValor: string;
begin
  Result := Self.JsonValue.Value;
end;

{ TIGJSONArray }

procedure TIGJSONArray.ForEach<T>(Proc: TCallBackIndex<T, Integer>);
var
  I: Integer;
begin
  for I := 0 to Pred(Self.Count) do
    Proc(Self.Items[I].AsType<T>, I);
end;

procedure TIGJSONArray.ForEach<T>(Proc: TCallBackItem<T>);
var
  I: Integer;
begin
  for I := 0 to Pred(Self.Count) do
    Proc(Self.Items[I].AsType<T>);
end;

function TIGJSONArray.IGAdd(Values: TArray<String>): TJSONArray;
var
  Value: String;
begin
  Result := Self;
  for Value in Values do
    Self.Add(Value);
end;

function TIGJSONArray.IGAdd(Values: TArray<Integer>): TJSONArray;
var
  Value: Integer;
begin
  Result := Self;
  for Value in Values do
    Self.Add(Value);
end;

function TIGJSONArray.IGAdd(Values: TArray<Double>): TJSONArray;
var
  Value: Double;
begin
  Result := Self;
  for Value in Values do
    Self.Add(Value);
end;

function TIGJSONArray.IGAdd(Values: TArray<Boolean>): TJSONArray;
var
  Value: Boolean;
begin
  Result := Self;
  for Value in Values do
    Self.Add(Value);
end;

function TIGJSONArray.IGExists(Value: String; sPath: String = ''): Boolean;
var
  bResult: Boolean;
begin
  if Count = 0 then
    Exit(False);

  try
    bResult := False;
    ForEach<TJSONValue>(
      procedure(Item: TJSONValue)
      var
        vItem: TJSONValue;
      begin
        if sPath.IsEmpty then
          vItem := Item
        else
          vItem := Item.GetValue<TJSONValue>(sPath);

        if Assigned(vItem) and vItem.InheritsFrom(TJSONString) then
          bResult := bResult or TJSONString(vItem).Value.Equals(Value);
      end
    );
  finally
    Result := bResult;
  end;
end;

function TIGJSONArray.IGExists(Value: Integer): Boolean;
var
  bResult: Boolean;
begin
  if Count = 0 then
    Exit(False);

  try
    bResult := False;
    ForEach<TJSONValue>(
      procedure(Item: TJSONValue)
      begin
        if Assigned(Item) and Item.InheritsFrom(TJSONNumber) then
          bResult := bResult or (TJSONNumber(Item).AsInt = Value);
      end
    );
  finally
    Result := bResult;
  end;
end;

function TIGJSONArray.IGExists(Value: Double): Boolean;
var
  bResult: Boolean;
begin
  if Count = 0 then
    Exit(False);

  try
    bResult := False;
    ForEach<TJSONValue>(
      procedure(Item: TJSONValue)
      begin
        if Assigned(Item) and Item.InheritsFrom(TJSONNumber) then
          bResult := bResult or (TJSONNumber(Item).AsDouble = Value);
      end
    );
  finally
    Result := bResult;
  end;
end;

function TIGJSONArray.IGExists(Value: Boolean): Boolean;
var
  bResult: Boolean;
begin
  if Count = 0 then
    Exit(False);

  try
    bResult := False;
    ForEach<TJSONValue>(
      procedure(Item: TJSONValue)
      begin
        if Assigned(Item) and Item.InheritsFrom(TJSONBool) then
          bResult := bResult or TJSONBool(Item).AsBoolean;
      end
    );
  finally
    Result := bResult;
  end;
end;

function TIGJSONArray.ToArray<T>: TArray<T>;
var
  arR: TArray<T>;
begin
  arR := [];
  Result := arR;
  ForEach<TJSONValue>(
  procedure(Item: TJSONValue)
  begin
    arR := arR + [Item.AsType<T>];
  end
  );
  Result := arR;
end;

{ TJSONDataSet }

constructor TJSONDataSet.Create;
begin
  FJSON := TJSONArray.Create;
end;

destructor TJSONDataSet.Destroy;
begin
  if Assigned(FTEMP) then
    FreeAndNil(FTEMP);

  if Assigned(FJSON) then
    FreeAndNil(FJSON);
end;

function TJSONDataSet.Open(const JSON: TJSONArray): TJSONDataSet;
begin
  Result := Self;
  if Assigned(FJSON) then
    FreeAndNil(FJSON);
  FJSON := JSON;
  First;
end;

function TJSONDataSet.Clone(const JSON: TJSONArray): TJSONDataSet;
begin
  Result := Self;
  if Assigned(FJSON) then
    FreeAndNil(FJSON);
  FJSON := TJSONArray(JSON.Clone);
  First;
end;

function TJSONDataSet.First: TJSONDataSet;
begin
  Result := Self;
  FBof   := False;
  FEof   := False;
  FState := TJSONDataSetState.Browse;
  FIndex := 0;
  if IsEmpty then
    FITEM := nil
  else
    FITEM := TJSONObject(FJSON.Items[FIndex]);
end;

function TJSONDataSet.Last: TJSONDataSet;
begin
  Result := Self;
  FBof   := False;
  FEof   := False;
  FState := TJSONDataSetState.Browse;
  FIndex := Pred(FJSON.Count);
  FITEM  := TJSONObject(FJSON.Items[FIndex]);
end;

function TJSONDataSet.Prior: TJSONDataSet;
begin
  Result := Self;
  FState := TJSONDataSetState.Browse;
  FBof := FIndex <= 1;
  if not FBof then
    Dec(FIndex);
  if not IsEmpty then
    FITEM := TJSONObject(FJSON.Items[FIndex]);
end;

function TJSONDataSet.Next: TJSONDataSet;
begin
  Result := Self;
  FState := TJSONDataSetState.Browse;
  FEof := Succ(FIndex) >= FJSON.Count;
  if not FEof then
    Inc(FIndex);
  FITEM := TJSONObject(FJSON.Items[FIndex]);
end;

function TJSONDataSet.RecordCount: Integer;
begin
  Result := FJSON.Count;
end;

function TJSONDataSet.IsEmpty: Boolean;
begin
  Result := RecordCount = 0;
end;

function TJSONDataSet.Bof: Boolean;
begin
  Result := FBof or IsEmpty;
end;

function TJSONDataSet.Eof: Boolean;
begin
  Result := FEof or IsEmpty;
end;

function TJSONDataSet.Append: TJSONDataSet;
begin
  Result := Self;
  if FState <> TJSONDataSetState.Browse then
    Post;
  if Assigned(FTEMP) then
    FreeAndNil(FTEMP);
  FTEMP := TJSONObject.Create;
  FState := TJSONDataSetState.Insert;
end;

function TJSONDataSet.Edit: TJSONDataSet;
var
  Item: TJSONPair;
begin
  Result := Self;
  if FState <> TJSONDataSetState.Browse then
    Exit;
  if Assigned(FTEMP) then
    FreeAndNil(FTEMP);
  FTEMP := TJSONObject.Create;
  for Item in FITEM do
    FTEMP.AddPair(TJSONPair(Item.Clone));
  FState := TJSONDataSetState.Edit;
end;

function TJSONDataSet.Cancel: TJSONDataSet;
begin
  Result := Self;
  if Assigned(FTEMP) then
    FreeAndNil(FTEMP);
  FState := TJSONDataSetState.Browse;
end;

function TJSONDataSet.Post: TJSONDataSet;
var
  Item: TJSONPair;
begin
  Result := Self;
  case FState of
    TJSONDataSetState.Insert:
    begin
      FJSON.AddElement(TJSONObject(FTEMP.Clone));
      Last;
    end;
    TJSONDataSetState.Edit:
    begin
      for Item in FTEMP do
      begin
        RemovePair(FITEM, Item.JsonString.Value);
        FITEM.AddPair(TJSONPair(Item.Clone));
      end;
    end;
  end;
  FState := TJSONDataSetState.Browse;
end;

function TJSONDataSet.Delete: TJSONDataSet;
var
  vItem: TJSONValue;
begin
  Result := Self;
  if IsEmpty then
    Exit;
  vItem := FJSON.Remove(FIndex);
  if Assigned(vItem) then
    FreeAndNil(vItem);
  Prior;
  FState := TJSONDataSetState.Browse;
end;

function TJSONDataSet.State: TJSONDataSetState;
begin
  Result := FState;
end;

function TJSONDataSet.Value(const sPar: String): TJSONValue;
begin
  if FState = TJSONDataSetState.Browse then
    Result := FITEM.FindValue(sPar)
  else
    Result := FTEMP.FindValue(sPar);
  if not Assigned(Result) then
    raise Exception.Create('Par "'+ sPar +'" não encontrado no objeto JSON!');
end;

function TJSONDataSet.RemovePair(const oJSON: TJSONObject; const sPar: String): TJSONDataSet;
var
  Par: TJSONPair;
begin
  Result := Self;
  Par := oJSON.RemovePair(sPar);
  if Assigned(Par) then
    FreeAndNil(Par);
end;

function TJSONDataSet.Path(const sPath: String): TJSONObject;
var
  vPath: TJSONValue;
  sPart: String;
begin
  vPath := FTEMP.FindValue(sPath);
  if Assigned(vPath) then
  begin
    if vPath is TJSONObject then
      Exit(TJSONObject(vPath))
    else
      raise Exception.Create('Par já foi atribuido e não é um Objeto!');
  end;

  Result := FTEMP;
  for sPart in sPath.Split(['.']) do
  begin
    Result.AddPair(sPart, TJSONObject.Create);
    Result := TJSONObject(Result.Pairs[Pred(Result.Count)].JsonValue);
  end;
end;

function TJSONDataSet.PreparePair(const sPar: String): TPair<String, TJSONObject>;
var
  aPath: TArray<String>;
  iCount: Integer;
  sPath: String;
  sRealPar: String;
  I: Integer;
begin
  if sPar.Contains('.') then
  begin
    aPath := sPar.Split(['.']);
    iCount := Length(aPath);

    for I := 0 to Pred(iCount) do
      if I < Pred(iCount) then
        sPath := sPath + IfThen(not sPath.IsEmpty, '.') + aPath[I]
      else
        sRealPar := aPath[I];

    Result.Key   := sRealPar;
    Result.Value := Path(sPath);
  end
  else
  begin
    Result.Key   := sPar;
    Result.Value := FTEMP;
  end;

  RemovePair(Result.Value, Result.Key);
end;

function TJSONDataSet.Exists(sPares: String; aValores: Array of Variant): Boolean;
var
  pItem: Variant;
  aPares: TArray<String>;
  sPar: String;
  vPath: TJSONValue;
  vItem: TJSONValue;
  bTemp: Boolean;
  I: Integer;
begin
  aPares := sPares.Split([',']);
  if Length(aPares) <> Length(aValores) then
    raise Exception.Create('Numero de pares diferente do numero de valores!');

  Result := False;
  for vItem in FJSON do
  begin
    bTemp := True;
    for I := 0 to Pred(Length(aPares)) do
    begin
      sPar := aPares[I];
      pItem := aValores[I];

      vPath := vItem.FindValue(sPar);

      if not Assigned(vPath) or
         (VarIsStr(pItem) and not vPath.Value.Equals(String(pItem))) or
         (VarIsNumeric(pItem) and (TJSONNumber(vPath).AsDouble <> Double(pItem))) then
      begin
        bTemp := False;
        Break;
      end;
    end;
    if bTemp then
      Exit(True);
  end;
end;

function TJSONDataSet.Str(const sPar: String): String;
begin
  Result := Value(sPar).AsType<String>;
end;

function TJSONDataSet.Str(const sPar, sValor: String): TJSONDataSet;
begin
  Result := Self;
  with PreparePair(sPar) do
    Value.AddPair(Key, sValor);
end;

function TJSONDataSet.Date(const sPar: String): TDate;
begin
  Result := Trunc(DateTime(sPar));
end;

function TJSONDataSet.Date(const sPar: String; const dValor: TDate): TJSONDataSet;
begin
  Result := Str(sPar, FormatDateTime('yyyy-mm-dd', dValor));
end;

function TJSONDataSet.DateTime(const sPar: String): TDateTime;
begin
  Result := ISO8601ToDate(Value(sPar).AsType<String>);
end;

function TJSONDataSet.DateTime(const sPar: String; const dValor: TDateTime): TJSONDataSet;
begin
  Result := Self;
  with PreparePair(sPar) do
    Value.AddPair(Key, DateToISO8601(dValor));
end;

function TJSONDataSet.Int(const sPar: String): Integer;
begin
  Result := Value(sPar).AsType<Integer>;
end;

function TJSONDataSet.Int(const sPar: String; const iValor: Integer): TJSONDataSet;
begin
  Result := Float(sPar, iValor);
end;

function TJSONDataSet.Float(const sPar: String): Double;
begin
  Result := Value(sPar).AsType<Double>;
end;

function TJSONDataSet.Float(const sPar: String; const dValor: Double): TJSONDataSet;
begin
  Result := Self;
  with PreparePair(sPar) do
    Value.AddPair(Key, dValor);
end;

function TJSONDataSet.JSON: TJSONArray;
begin
  Result := FJSON;
end;

{$WARN GARBAGE OFF}
end.
(*
Controle - Versões.
------------------------------------------------------------------------------------------------------------------------
[Alan Miranda, 14/03/2015 às 08:23]
Adicionado funções para manipulação de JSON, Seguintes funções:
IGStrToJSONObject, IGStrToJSONArray e IGJSONToWhere
------------------------------------------------------------------------------------------------------------------------
[Rafael, 24/03/2016 às 10:32]
Alterado função IGJSONToWhere para usar 'OR' (campo1|campo2, valor);
------------------------------------------------------------------------------------------------------------------------
[Silvio, 27/04/2016 às 15:32]
Alterado função IGStrToJSONObject para dar um  raise caso a análise da
matriz de bytes do JSON for igual a nil.
------------------------------------------------------------------------------------------------------------------------
[Marco Aurélio, 02/05/2016 às 15:36]
Alterada a função IGStrToJSONObject para evitar memoryleak. Criado uma variável
auxiliar para tratar o objeto json.
------------------------------------------------------------------------------------------------------------------------
[Eduardo, 01/06/2017 às 17:00]
Ajustado problema da migração do Delphi Berlin para o Tokyo
Adicionadas Funções de AddPair para substituir da biblioteca nativa
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 19/02/2019]
Corrige IGetPairQt para nao pegar 'NULL' e sim NULL
------------------------------------------------------------------------------------------------------------------------
Pedro Stoco - 20/03/2019
Correção para o delphi RIO - IGQryToJson
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 14/11/2019]
Remove memoryleak ao readicionar um par no JSON
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 19/02/2019]
  - Adiciona funções para Adicionar e Obter Pairs com diferentes tipos de dados.
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 21/02/2020]
Ajusta para obter o valor do par a partir do TJSONValue, possibilitando
navegação nos objetos via string root element
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 21/02/2020]
  - Ajusta para não utilizar navegação nos objetos via string root element
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 02/03/2020]
Adiciona IGStrToJSONValue para obter o JSON Value a partir de String
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 03/03/2020]
  - Melhoria na Manipução de Datas
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 03/03/2020]
  - Adiciona IGGetFloatSql para retornar o valor float preparado p/ SQL
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 17/04/2020]
Adiciona metodo para tentar obter valor do json, com padrão em caso de erro
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 17/04/2020]
  - ISSUE:342 - Altera IGAddPairDate e IGAddPairDateTime para utilizar
      padrão de data: yyyy-mm-dd e yyyy-mm-dd HH:mm:ss
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 22/06/2020]
  - Adiciona IGSameValue
  - Adiciona IGGet%*%Def para retornar valor Default, informado, caso o pair
      não exista ou esteja vazio
  - Padroniza IGAddPairDate e IGAddPairDate para inserir TJSONNull caso a data
      seja zero
  - Padroniza IGAddPairDate e IGAddPairDate para padrão de data yyyy-mm-dd
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 29/06/2020]
Ajusta IGIsEmpty para retornar false caso seja zero conforme definição.
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 29/06/2020 - ISSUE:380]
  - Melhoria ao Obter Datas e Horas no JSON: Ao obter um Pair de
      Date ou DateTime onde o separador era diferente de "-" ou ":",
      o sistema não conseguia converter a data devido a configuração errada.
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 26/08/2020 - ISSUE:418]
  - Adiciona ForEach no TJSONArray
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 08/09/2020 - TICK:34037]
  - Correção no IGGetDateTime, corrige Separador Decimal, que está com padrão
    uma Vírgula, e é utilizado para identificar os Millisegundos, que estão com
    um Ponto.
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 19/03/2021 - ISSUE:524]
  - Melhoria na função IGIsEmpty quando validar um TJSONArray
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 29/03/2021]
Corrige conversão de String para JSON
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 07/06/2021]
Ajusta métodos SQLValues para fazer tratativas de acordo com o tipo do JSON
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 02/07/2021 - ISSUE:567]
  - Melhoria na IGGetStrSQL e IGGetFloatSql, para utilizar Set Of Options facilitando o entendimento e aumentando
    as possibilidades
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 31/08/2021 - TICK:40012]
  - Adiciona IGGetValueCoalese no TJSONObject
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 06/09/2021 - ISSUE:582]
  - Correção no IGIsEmpty para validação de TJSONObject
------------------------------------------------------------------------------------------------------------------------
[Willian Almeida - 11/05/2023]
  - Ajuste no parametro dos métodos  SQLFieldsAndValues, SQLFields e SQLValues. Pode ser informado campos a serem 
  ignorados.
------------------------------------------------------------------------------------------------------------------------
*)
