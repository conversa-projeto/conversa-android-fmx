(*----------------------------------------------------------------------------------------------------------------------
Irmãos Gonçalves Comércio e Indústria LTDA

Helper.DataSet (LIB064.PAS Refatorado por 40088-DANIEL - 08/11/2017 as 13:43)

Helper para extender e adicionar funcionalidades às classes da unit Data.DB.

Autor: Francis Soares de Oliveira

Data: 26/09/2014 as 17:52
----------------------------------------------------------------------------------------------------------------------*)
unit Helper.DataSet;

interface

uses
  Data.DB,
  Datasnap.DBClient,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Types,
  System.TypInfo,
  System.JSON,
  System.SysUtils,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  System.UITypes,
  System.Classes,
  FMX.Forms,
  System.RTTI, System.NetEncoding;

type
  TDoubleArray = array of Double;
  TslSelecao = (slMarcar, slDesmarcar, slInverter);
  TIGField = class helper for TField
  private
    function GetIGChanged: Boolean;

    function IndexOf<T>(const Lista: Array of T; Item: T): Integer;
  public
    //Retorna se o valor do TField corrente foi alterado
    property IGChanged: Boolean read GetIGChanged;
    function AsDateSqlServer: String;

    {$IFDEF MSWINDOWS}
    function IGGetLabel: String;

(*
    function IGGetControl<T>: T; overload;
    function IGGetControls<T>(bOnlyOne: Boolean = False): TArray<T>; overload;
    function IGGetControl(aAllowedTypes: TArray<TClass> = []): TObject; overload;
    function IGGetControls(aAllowedTypes: TArray<TClass> = []; bOnlyOne: Boolean = False): TArray<TObject>; overload;
*)
    procedure IGRaise(sMessage: String); overload;
    {$ENDIF}

    ///<summary>
    ///  Permite o usuário ordenar registro por registro no cds
    ///</summary>
    ///<param name="iDistancia">
    ///  Distancia desde o ponto inicial
    ///</param>
    ///<param name="bUp">
    ///  Subir ou descer a linha
    ///</param>
    ///<remarks>
    ///  Eduardo - 24/01/2017 às 14:30
    ///</remarks>
    procedure MoverCampo(iDistancia : Integer; bUp : Boolean);

    function IGMatchValue(Values: TArray<String>): Boolean; overload;
    function IGMatchValue(Values: TArray<Integer>): Boolean; overload;
    function IGMatchValue(Values: TArray<Double>): Boolean; overload;
    function IGMatchValue(Values: TArray<Extended>): Boolean; overload;
    function IGMatchValue(Values: TArray<TDate>): Boolean; overload;
    function IGMatchValue(Values: TArray<TDateTime>): Boolean; overload;
    function IGMatchValue(Values: TArray<Boolean>): Boolean; overload;
    function IGIndexOf(Values: TArray<String>): Integer; overload;
    function IGIndexOf(Values: TArray<Integer>): Integer; overload;
    function IGIndexOf(Values: TArray<Double>): Integer; overload;
    function IGIndexOf(Values: TArray<Extended>): Integer; overload;
    function IGIndexOf(Values: TArray<TDate>): Integer; overload;
    function IGIndexOf(Values: TArray<TDateTime>): Integer; overload;
    function IGIndexOf(Values: TArray<Boolean>): Integer; overload;
  end;

  // Controla como os valores do tipo de enumeração serão usados
  // Será necessário TDateTimeOption.[Name] ao invés de apenas [Name]
  {$SCOPEDENUMS ON}
  TDateTimeOption = (
    ClearFieldIfZero, // Irá limpar o campo se o valor informado for zero
    NotChangeIfZero // Não irá alterar o valor do campo, se o novo valor informado for zero
  );
  TDateTimeOptions = set of TDateTimeOption;

  TSameValueOption = (
    EmtpyEquals // Irá considerar que Vazio é igual ao valor informado
  );
  TSameValueOptions = set of TSameValueOption;
  {$SCOPEDENUMS OFF}

  TIGDataSet = class helper for TDataSet
  public type
    IIGDataSetSmartAction = interface
    ['{03A59179-9F78-421A-AD43-35A49C42DB72}']
    end;
  private type
    TIGSmartDisableControls = class(TInterfacedObject, IIGDataSetSmartAction)
    private
      FDataSet: TDataSet;
      constructor Create(DataSet: TDataSet);
      class function New(DataSet: TDataSet): IIGDataSetSmartAction;
    public
      destructor Destroy; override;
    end;

    TIGSmartBookmark = class(TInterfacedObject, IIGDataSetSmartAction)
    private
      FDataSet: TDataSet;
      FBookmark: TBookmark;
      constructor Create(DataSet: TDataSet);
      class function New(DataSet: TDataSet): IIGDataSetSmartAction;
    public
      destructor Destroy; override;
    end;

    TIGSmartGotoRecno = class(TInterfacedObject, IIGDataSetSmartAction)
    private
      FDataSet: TDataSet;
      FRecno: Integer;
      constructor Create(DataSet: TDataSet);
      class function New(DataSet: TDataSet): IIGDataSetSmartAction;
    public
      destructor Destroy; override;
    end;

    TIGSmartFilter = class(TInterfacedObject, IIGDataSetSmartAction)
    private
      FDataSet: TDataSet;
      FBFilter: Boolean;
      FFilter: String;
      constructor Create(DataSet: TDataSet; sFilter: String);
      class function New(DataSet: TDataSet; sFilter: String): IIGDataSetSmartAction;
    public
      destructor Destroy; override;
    end;

    TIGSmartSaveValue = class(TInterfacedObject, IIGDataSetSmartAction)
    private
      FDataSet: TDataSet;
      FFieldKey: String;
      FFieldValue: String;
      FData: TArray<TPair<Variant, Variant>>;
      constructor Create(DataSet: TDataSet; sFieldKey, sFieldValue: String);
      class function New(DataSet: TDataSet; sFieldKey, sFieldValue: String): IIGDataSetSmartAction;
    public
      destructor Destroy; override;
    end;

    TIGSmartAction = class(TInterfacedObject, IIGDataSetSmartAction)
    private
      FDataSet: TDataSet;
      constructor Create(DataSet: TDataSet);
      procedure Finalizar; virtual; abstract;
    public
      destructor Destroy; override;
    end;

    TIGSmartOrderBy = class(TIGSmartAction)
    private
      FOld: String;
      // ATENÇÃO! Não mudar tipo do parâmetro saFIelds, sujeito a alterar a ordem de funcionamento da função
      //   RSP-41353
      class function New(DataSet: TClientDataSet; saFields: array of string): IIGDataSetSmartAction;
      procedure Finalizar; override;
    end;

    THackDataSource = class (Data.DB.TDataSource);
    TDataSetStates = set of TDataSetState;
  private
//    function GetClassByName(sClassName: String): TArray<TClass>;
//    function GetClassFromType(ATypeInfo: Pointer): TClass;
  public
    procedure Required(sFields: TArray<String>); overload;
    procedure Required(sFields: String = ''); overload;
    procedure ConfigRequired(aString: Array of String);
    procedure ToJSONArray(var aResult: TJSONArray);
    function ToJSONObject: TJSONObject; overload;
    procedure ToJSONObject(var oResult: TJSONObject); overload;
    function IGGetRecord(sFields: TArray<String>): TJSONObject; overload;
    function IGGetRecord(sFields: String = ''): TJSONObject; overload;

    function IGGetField(sFieldName: string): TField;
    function IGGetStr(sFieldName: string): string;
    function IGGetStrQt(sFieldName: string): string;
    function IGGetFormat(const sExpressao: String): String;
    function IGGetInt(sFieldName: string): Integer;
    function IGGetFloat(sFieldName: string): Double;
    function IGGetFloatRound(sFieldName: string; iDigits: Integer = 2): Double;
    function IGGetExtended(sFieldName: string): Extended;
    function IGGetDate(sFieldName: string): TDate;
    function IGGetDateSql(sFieldName: string): string;
    function IGGetDateTime(sFieldName: string): TDateTime;
    function IGGetDateTimeSql(sFieldName: string): string;
    function IGGetBoolean(sFieldName: string): Boolean;
    function IGGetJSONValue(sFieldName: String): TJSONValue;
    function IGGetJSONPair(sFieldName: String): TJSONPair;
    function IGGetSplit(sFieldName: String; Separator: Char = ','): TArray<String>; overload;
    function IGGetSplit<T>(sFieldName: String; Separator: Char = ','): TArray<T>; overload;

    procedure IGSetValue(sFieldName: String; Value: String); overload;
    procedure IGSetValue(sFieldName: String; Value: Integer); overload;
    procedure IGSetValue(sFieldName: String; Value: Double); overload;
    procedure IGSetValue(sFieldName: String; Value: Extended); overload;
    procedure IGSetValue(sFieldName: String; Value: TDate; Options: TDateTimeOptions = [TDateTimeOption.ClearFieldIfZero]); overload;
    procedure IGSetValue(sFieldName: String; Value: TDateTime; Options: TDateTimeOptions = [TDateTimeOption.ClearFieldIfZero]); overload;
    procedure IGSetValue(sFieldName: String; Value: Boolean); overload;
    procedure IGSetValue(sFieldName: String; Value: TStream); overload;

    procedure IGClearField(sFieldName: string);
    procedure IGClearFields(sFieldsNames: String);
    function IGFieldIsEmpty(sFieldName: string): Boolean;
    function IGFieldNotIsEmpty(sFieldName: string): Boolean;

    function IGSameValue(sFieldName, Value: String): Boolean; overload;
    function IGSameValue(sFieldName: String; Value: Integer; Options: TSameValueOptions = []): Boolean; overload;
    function IGSameValue(sFieldName: String; Value: Double; Options: TSameValueOptions = []): Boolean; overload;
    function IGSameValue(sFieldName: String; Value: Extended; Options: TSameValueOptions = []): Boolean; overload;
    function IGSameValue(sFieldName: String; Value: TDate; Options: TSameValueOptions = []): Boolean; overload;
    function IGSameValue(sFieldName: String; Value: TDateTime; Options: TSameValueOptions = []): Boolean; overload;
    function IGSameValue(sFieldName: String; Value: Boolean; Options: TSameValueOptions = []): Boolean; overload;

    function IGChanged(sFieldName: string): Boolean;
    function IGAllIsEmpty(sFields: String = ''): Boolean;
    function IGOneIsEmpty(sFields: String = ''): Boolean;

    function IGMatchStr(sFieldName, sValues: String): Boolean; overload;
    function IGMatchStr(const sFieldName: string; const AValues: Array of String): Boolean; overload;
    function IGMatchValue(sFieldName: String; Values: TArray<String>): Boolean; overload;
    function IGMatchValue(sFieldName: String; Values: TArray<Integer>): Boolean; overload;
    function IGMatchValue(sFieldName: String; Values: TArray<Double>): Boolean; overload;
    function IGMatchValue(sFieldName: String; Values: TArray<Extended>): Boolean; overload;
    function IGMatchValue(sFieldName: String; Values: TArray<TDate>): Boolean; overload;
    function IGMatchValue(sFieldName: String; Values: TArray<TDateTime>): Boolean; overload;
    function IGMatchValue(sFieldName: String; Values: TArray<Boolean>): Boolean; overload;
    function IGIndexOf(sFieldName: String; Values: TArray<String>): Integer; overload;
    function IGIndexOf(sFieldName: String; Values: TArray<Integer>): Integer; overload;
    function IGIndexOf(sFieldName: String; Values: TArray<Double>): Integer; overload;
    function IGIndexOf(sFieldName: String; Values: TArray<Extended>): Integer; overload;
    function IGIndexOf(sFieldName: String; Values: TArray<TDate>): Integer; overload;
    function IGIndexOf(sFieldName: String; Values: TArray<TDateTime>): Integer; overload;
    function IGIndexOf(sFieldName: String; Values: TArray<Boolean>): Integer; overload;

    function IGIndexStr(const sFieldName: string; const AValues: array of string): Integer;
    function IGContains(sFieldName, Value: string): Boolean;

    function IGInc(sFieldName: String; dValue: Double = 1): Double;
    function IGDec(sFieldName: String; dValue: Double = 1): Double;

    procedure IGSetProperty(saFields, sProperty: String; vValue: TValue); overload;
    procedure IGSetProperty(saFields, saProperty: String; vaValue: Array of TValue); overload;

    function IGStateIn(dsStates: TDataSetStates): Boolean;

    {$IFDEF MSWINDOWS}
//    function IGGetControl<T>(sFieldName: String = ''): T; overload;
//    function IGGetControls<T>(sFieldName: String = ''; bOnlyOne: Boolean = False): TArray<T>; overload;
//    function IGGetControl(sFieldName, sClasses: String): TObject; overload;
//    function IGGetControls(sFieldName, sClasses: String; bOnlyOne: Boolean = False): TArray<TObject>; overload;
//    function IGGetControl(sFieldName: String = ''; aAllowedTypes: TArray<TClass> = []): TObject; overload;
//    function IGGetControls(sFieldName: String = ''; aAllowedTypes: TArray<TClass> = []; bOnlyOne: Boolean = False): TArray<TObject>; overload;
//
//    function IGHighlightControls<T>(sFields: String = ''; cColor: TColor = TColorRec.Pink; cBorder: TColor = TColorRec.Red): TArray<IInterface>; overload;
//    function IGHighlightControls(sFields: String = ''; aAllowedTypes: TArray<TClass> = []; cColor: TColor = TColorRec.Pink; cBorder: TColor = TColorRec.Red): TArray<IInterface>; overload;
//    function IGHighlightControls(sFields: String; sClasses: String; cColor: TColor = clWebPink; cBorder: TColor = clRed): TArray<IInterface>; overload;

    procedure IGSetRequired(sFields: String; bRequired: Boolean);
    procedure IGRaise(sMessage: String; sHighlightFields: String = ''; sFieldControl: String = ''; aAllowedTypes: TArray<TClass> = []); overload;

//    function IGCalculaExpressao(sExpressao: String): Double;
    {$ENDIF}

    function IGFind(Prc: TFunc<Boolean>): TDataSet;
    function IGGetLink(sFields: String): String;
    procedure IGSetLink(sLink: String);

    function IGSmartDisableControls: IIGDataSetSmartAction;
    function IGSmartBookmark: IIGDataSetSmartAction;
    function IGSmartGotoRecno: IIGDataSetSmartAction;
    function IGSmartFilter(sFilter: String = ''): IIGDataSetSmartAction;
    function IGSmartSaveValue(sFieldKey, sFieldValue: String): IIGDataSetSmartAction;
    function IGSmartOrderBy(saFields: array of string): IIGDataSetSmartAction;
  end;

  TIGClientDataSet = class helper for TClientDataSet
  public type
    {$SCOPEDENUMS ON}
    TAgregateMethod = (SELECT, SUM, AVG, MAX, MIN, COUNT, STRING_AGG);
    {$SCOPEDENUMS OFF}
    TAgregateField = TPair<TAgregateMethod, String>;
    TIGGroup = class
      private
        FDataSet: TClientDataSet;
        FDivStringAgg: String;
        FFields: TList<TAgregateField>;
        function GetKey: String;
        function InternalAdd(AFields: TArray<String>; agMethod: TAgregateMethod): TIGGroup;
        procedure Ordering;
        function CountFields(Method: TAgregateMethod): Integer;
      public
        constructor Create(DataSet: TClientDataSet);
        destructor Destroy; override;
        function By(AFields: TArray<String>): TIGGroup;
        function Sum(AFields: TArray<String>): TIGGroup;
        function Avg(AFields: TArray<String>): TIGGroup;
        function Max(AFields: TArray<String>): TIGGroup;
        function Min(AFields: TArray<String>): TIGGroup;
        function Count(AFields: TArray<String>): TIGGroup;
        function StringAgg(AFields: TArray<String>; sDiv: String = ','): TIGGroup;
        function Execute: TJSONArray;
      end;
  private
  public
    /// <summary>
    ///   Ordena o ClientDataSet em ordem crescente e descrescente caso ja esteja
    ///  em ordem crescente
    /// </summary>
    /// <param name="pFieldName">
    ///   Nome do campo a ser ordenado
    /// </param>
    /// <remarks>
    ///   Marco Aurelio - 15/10/2014 às 10:35
    /// </remarks>
    procedure IGOrderBy(pFieldName: String);

    /// <summary>
    ///  Retorna um Double com o valor totalizando pelo campo Informado
    /// </summary>
    /// <param name="pCampoComValor">
    ///  Campo que contém o valor a ser totalizado
    /// </param>
    /// <param name="pFiltro">
    ///  Filtro a ser aplicado nos registros
    /// </param>
    /// <remarks>
    ///  Alan Miranda - 12/02/2015 às 13:46
    /// </remarks>
    function IGTotalize(pCampoComValor: String; pFiltro: String = ''): Double;

    /// <summary>
    ///  Retorna um Double com o valor totalizando pelo campo Informado
    /// </summary>
    /// <param name="pCampoComValor">
    ///  Campo que contém o valor a ser totalizado
    /// </param>
    /// <param name="pFiltro">
    ///  Filtro a ser aplicado nos registros
    /// </param>
    /// <remarks>
    ///  Eduardo - 15/03/2017 às 14:00
    /// </remarks>
    function IGCloneTotalize(pCampoComValor: String; pFiltro: String = '') : Double;

    /// <summary>
    ///  Retorna Array de Valores totalizados de acordo com os campos Informados
    /// </summary>
    /// <param name="ACampos">
    ///  Array de Campos a serem totalizados
    /// </param>
    /// <param name="pFiltro">
    ///  Filtro a ser aplicado nos registros
    /// </param>
    /// <remarks>
    ///  Eduardo - 27/03/2017 às 16:00
    /// </remarks>
    function IGMultiTotalize(ACampos: array of String; pFiltro: String = ''): TDoubleArray;
    function IGFilterTotalize(sCampo: String; sFiltros: Array of String): TDoubleArray;

    /// <summary>
    ///  Retorna o maior valor do campo Informado, ordenando o dataset de
    ///   forma ascendente, como Double;
    /// </summary>
    /// <param name="pCampo">
    ///  Campo que contém o valor a ser totalizado
    /// </param>
    /// <param name="pFiltro">
    ///  Filtro a ser aplicado nos registros
    /// </param>
    /// <remarks>
    ///  Rafael - 20/02/2015 às 11:25
    /// </remarks>
    function IGMaxValue(pCampo: String; pFiltro: String = ''): Double;

    /// <summary>
    ///  Retorna True se possuir algum registro com  pCampo = 'S'
    /// </summary>
    /// <param name="pCampo">
    ///  Nome do campo de check
    /// </param>
    /// <remarks>
    ///  Alan Miranda - 06/07/2015 às 17:47
    /// </remarks>
    function IGTemRegistroMarcado(pCampo: String; pValor: String = 'S'): Boolean;

    /// <summary>
    ///  Fica trocando o valor do pCampo entre 'S' e 'N' cada vez que é executado.
    /// </summary>
    /// <param name="pCampo">
    ///  Nome do campo que deverá receber o 'S' ou 'N'
    /// </param>
    /// <remarks>
    ///  Alan Miranda - 06/07/2015 às 16:53
    /// </remarks>
    procedure IGMarcarRegistro(pCampo: String);

    {$IFDEF MSWINDOWS}

    /// <summary>
    ///   Exibe no formulário os campos que estão diferentes entre vários registros
    /// </summary>
    /// <param name="fForm">
    ///  Formulário
    /// </param>
    /// <remarks>
    ///  Eduardo - 29/09/2016 às 10:43
    /// </remarks>
//    procedure IGDivergencia(fForm : TForm);

//    class function Criptografia(Action, Src : String) : String;

    /// <summary>
    ///   Carrega o cds temporário com dados salvos anteriormente, deve ser usado
    ///   no FormCreate do Formulário. Ex: cdsParam.IGLoadStream(Self.Name);
    /// </summary>
    /// <remarks>
    ///  Eduardo - 29/09/2016 às 10:43
    /// </remarks>
//    procedure IGLoadStream(sFonte: String; bTudo: Boolean = False);

    /// <summary>
    ///   Salva o cds temporário, deve ser usado no FormDestroy
    ///   Ex: cdsParam.IGSaveStream(Self.Name);
    /// </summary>
    /// <remarks>
    ///  Eduardo - 29/09/2016 às 10:43
    /// </remarks>
//    procedure IGSaveStream(pFonte: String);
    {$ENDIF}

    /// <summary>
    ///  Filtra os Cds de acordo com o Filtro passado.
    ///  (EX: cds.IGFilter('IC_CHECK = ' + QuotedStr('S')))
    /// </summary>
    /// <param name="sFilter">
    ///  Filtro que o cds Ira receber.
    ///  (EX: 'IC_CHECK = ' + QuotedStr('S')
    /// </param>
    /// <remarks>
    ///  Robson Souza - 13/03/2017 às 09:33
    /// </remarks>
    procedure IGFilter(sFilter: String = '');

    /// <summary>
    ///  Função padrão para retornar a quantidade de registro selecionados
    ///  no Checkbox das rotinas que utilizam TBookmark.
    /// </summary>
    /// <param name="pFiltro">
    ///  Filtro da pesquisa. É informado o campo e o valor contido no mesmo.
    /// </param>
    /// <remarks>
    ///  Willian Almeida - 06/01/2016 às 15:50
    /// </remarks>
    function IGCountFiltro(pFiltro: String = ''): Integer;

    /// <summary>
    ///  Função para clonar o registro atual de um ClientDataSet.
    ///
    ///   Nota: Ao usar esta função verifique se no CDS que esta tendo o registro
    ///   clonado existe somente o registro a ser clonado, se existir mais registros
    ///   corre o risco de clonar um registro que não é o registro que o usuário
    ///   esta selecinando. Pedro, 18/10/2016
    ///
    /// </summary>
    /// <remarks>
    ///  Alan Miranda - 26/01/2016 às 14:48
    /// </remarks>
    procedure IGCloneRecord(bPost: Boolean = True);

    /// <summary>
    ///  Contar os registros do cds passado filtrando o fieldname
    /// </summary>
    /// <param name="pFieldName">
    ///  Campo onde será feito o filtro
    /// </param>
    /// <param name="pCriterio">
    ///  Critério do filtro
    /// </param>
    /// <returns>
    ///  Total de registros com o critério passado
    /// </returns>
    /// <remarks>
    ///  Alan Miranda - 03/09/2014 às 17:25
    /// </remarks>
    function CountRegCDS(pFieldName, pCriterio: String): Integer;

    procedure IGLoadFromJSONArray(aJSON: TJSONArray);

    function LoadFromJSONArray(jaValue: TJSONArray): TClientDataSet;

    procedure CreateFromJSONArray(aJSON: TJSONArray);

    /// <summary>
    ///   Ordena o cds
    ///   Ex: cdsParam.IGSaveStream(Self.Name);
    /// </summary>
    /// <param name="pFieldName">
    ///  Nome do campo da ordenação
    /// </param>
    /// <param name="bDesc">
    ///  Ordem Decrescente
    /// </param>
    /// <remarks>
    ///  Eduardo - 18/11/2016 às 15:00
    /// </remarks>
    procedure IGSetOrderBy(pFieldName : String; bDesc : Boolean = False);

    function IGParamPesq(asFields : Array of String) : String;

    {$Region '/// Documentação '}
    ///<summary>
    ///  Função responsável por contar o número de registros que estão checados ou não checados
    ///  Pode ser utilizada dentro do onDataChange.
    ///  Conta Checados, count Check, count_check
    ///</summary>
    ///<param name="pCampo">
    ///  Campo do Cds que será o CHECK
    ///</param><param name="----------------------------------------------------"></param>
    ///<param name="pVlr_Checado">
    ///  Valor do campo, que será considerado como checado
    ///</param><param name="----------------------------------------------------"></param>
    ///<param name="pCds_DataSet">
    ///  cds Que será verificado quantos registros estão checados
    ///</param><param name="----------------------------------------------------"></param>
    ///<param name="pChecado">
    ///  Boolean, para informar se retorna o count de itens checados ou não checados
    ///</param><param name="----------------------------------------------------"></param>
    ///<remarks>
    ///  Alisson - 27/06/2017 - 21:57
    ///</remarks>
    {$EndREgion}
    function IGCount_Check(pCampo, pVlr_Checado: String; pChecado: Boolean = True): Integer ;

    /// <summary>
    ///   Executa o FieldByName do cds
    /// </summary>
    /// <param name="pFieldName">
    ///  Nome do campo da ordenação
    /// </param>
    /// <remarks>
    ///  Yuri - 20/03/2018 às 11:23
    /// </remarks>
    function FName(pFieldName: String): TField;

    function IGGetValuesToInSql(sFieldName: String; bQuoted: Boolean = False; iPadL: Integer = 0;
  sFilter: string = ''; bGroup : Boolean = False): String;

    {$Region '// Documentação '}
    /// <remarks>
    ///   Função utilizada para obter uma Lista com as informações dos fields que passamos por parâmetro
    ///  uses System.Types
    /// </remarks>
    /// <param name="Parametros">
    /// <para/> pArrayFields: Array de String contendo os fields
    /// <para/> pUsarQt: Informa se a cada item deve ser utilizado quotedeStr
    /// <para/> pUsarEnabled_Disabled: Informa se o processo irá disabilitar e habilitar o enabled controls
    /// <para/> pFiltro: Informa o filtro a ser utilizado nos registros
    /// </param>
    /// <returns>
    ///   Retorna TStringDynArray contento o array com as listas
    /// </returns>
    {$EndREGION}
    function ObterListaCds(
      pArrayFields: TStringDynArray;
      pUsarQt : Boolean = True;
      pUsarEnabled_Disabled : Boolean = True;
      pFiltro : String = ''
    ): TStringDynArray;

    procedure DenseRank(Field_Item: string; Field_Group: string = '');

    function IGCountFilter(sFilter: string; bReset: Boolean = False): Integer;

    procedure IGSetParam(sParam: string; Value: Variant);
    function IGGetParam(sParam: string): Variant;
    procedure IGOpenParams(sParams: String; aVariant: Variant); overload;
    procedure IGOpenParams(sParams: String; aVariant: TArray<Variant>); overload;

    function IGGroup: TIGGroup;
  end;

  TIGFDQuery = class helper for TFDQuery
    procedure IGOrderBy(pFieldName: String);
    procedure IGFilter(sFilter: String);
    procedure IGMarcarTodosRegistros(slSelecao : TslSelecao; sField: String);
  end;

  TIGFDMemTable = class helper for TFDMemTable
    procedure IGOrderBy(pFieldName: String);
  end;

  TIGFDDataSet = class helper for TFDDataSet
    procedure IGOrderBy(pFieldName: String);
  end;

implementation

uses
  System.StrUtils,
  System.DateUtils,
  System.Variants,
  System.Math,
  System.RegularExpressions,
  {$IFDEF MSWINDOWS}
//  Mensagem.Resources,
//  Mensagem.Detalhe,
//  Mensagem.Functions,
//  Vcl.Dialogs,
//  Vcl.Controls,
//  Winapi.Windows,
//  IGCalculadora,
  {$ENDIF}
  REST.Response.Adapter,
  Extend.Generics.Collections, FMX.Graphics;

const
  sl = sLineBreak;
  sl2 = sl + sl;

function Qt(Value: String): String;
begin
  Result := QuotedStr(Value);
end;

procedure Include(var sText: String; const sMod: String; sDiv: String = ',');
begin
  if sText.IsEmpty then
    sText := sMod
  else
  if not sMod.IsEmpty then
    sText := Concat(sText, sDiv, sMod);
end;

{ TIGField }

function TIGField.GetIGChanged: Boolean;
begin
  if Trim(Self.AsString).IsEmpty then
    Result := False
  else
    Result := not VarSameValue(Self.OldValue, Self.NewValue);
end;

function TIGField.AsDateSqlServer: String;
begin
  DateTimeToString(Result, 'yyyy-mm-dd', Self.AsDateTime );
end;

{$IFDEF MSWINDOWS}
function TIGField.IGGetLabel: String;
//var
//  cFieldControl: TControl;
//  I: Integer;
begin
//  Result := FieldName;
//
//  if DisplayLabel <> FieldName then
//    Exit(DisplayLabel);
//
//  cFieldControl := IGGetControl<TControl>;
//  if (not Assigned(cFieldControl)) or (not Assigned(cFieldControl.Parent)) then
//    Exit;
//
//  for I := 0 to Pred(cFieldControl.Parent.ControlCount) do
//  begin
//    if not Assigned(cFieldControl.Parent.Controls[I]) then
//      Continue;
//    if csDestroying in cFieldControl.Parent.Controls[I].ComponentState then
//      Continue;
//
//    if cFieldControl.Parent.Controls[I].InheritsFrom(Vcl.StdCtrls.TLabel) then
//    begin
//      if Assigned(TLabel(cFieldControl.Parent.Controls[I]).FocusControl) then
//        if TLabel(cFieldControl.Parent.Controls[I]).FocusControl = TWinControl(cFieldControl) then
//          Exit(TLabel(cFieldControl.Parent.Controls[I]).Caption);
//    end
//    else
//    if cFieldControl.Parent.Controls[I].InheritsFrom(Vcl.DBCtrls.TDBCheckBox) then
//      if Vcl.DBCtrls.TDBCheckBox(cFieldControl.Parent.Controls[I]).Field = Self then
//        Exit(Vcl.DBCtrls.TDBCheckBox(cFieldControl.Parent.Controls[I]).Caption);
//  end;
end;
(*
function TIGField.IGGetControl<T>: T;
begin
  Result := Self.DataSet.IGGetControl<T>(Self.FieldName);
end;

function TIGField.IGGetControls<T>(bOnlyOne: Boolean): TArray<T>;
begin
  Result := Self.DataSet.IGGetControls<T>(Self.FieldName, bOnlyOne);
end;

function TIGField.IGGetControl(aAllowedTypes: TArray<TClass>): TObject;
begin
  Result := Self.DataSet.IGGetControl(Self.FieldName, aAllowedTypes);
end;

function TIGField.IGGetControls(aAllowedTypes: TArray<TClass>; bOnlyOne: Boolean): TArray<TObject>;
begin
  Result := Self.DataSet.IGGetControls(Self.FieldName, aAllowedTypes, bOnlyOne);
end;
*)
procedure TIGField.IGRaise(sMessage: String);
begin
  Self.DataSet.IGRaise(sMessage, FieldName, FieldName);
end;

{$ENDIF}

procedure TIGField.MoverCampo(iDistancia: Integer; bUp: Boolean);
var
  dVLR1 : Double;
  dVLR2 : Double;
  I,X   : Integer;
begin
  // Verifica se tem registros no cds
  if Self.DataSet.IsEmpty then
    Exit;

  // Verifica se o cds tem mais de um registro
  if Self.DataSet.RecordCount < 1 then
    Exit;

  // Valida a quantidade de movimentos
  if iDistancia <= 0 then
    Exit;

  // Define o valor inicial
  dVLR1 := Self.AsFloat;

  // Loop na quantidade de movimentos
  for I := 1 to iDistancia do
  begin
    // Localiza o campo que vai ser alterado
    if not Self.DataSet.Locate(Self.FieldName, dVLR1, []) then
      Exit;

    // Se for para cima
    if bUp then
    begin
      // Se ja for o primeiro registro, não tem como subir mais
      if Self.DataSet.RecNo = 1 then
        Exit;
      // Sobe
      Self.DataSet.Prior
    end
    else
    begin
      // Se ja for o ultimo registro, não tem como descer mais
      if Self.DataSet.RecNo = Self.DataSet.RecordCount then
        Exit;
      // Desce
      Self.DataSet.Next;
    end;

    // Obtem o valor do campo 2
    dVLR2 := Self.DataSet.FieldByName(Self.FieldName).AsFloat;
    // Edita o campo 2 inserindo o valor negativo do campo 1
    Self.DataSet.Edit;
    Self.DataSet.FieldByName(Self.FieldName).AsFloat := (dVLR1 * -1);
    Self.DataSet.Post;
    // Localiza o campo 1
    Self.DataSet.Locate(Self.FieldName, dVLR1, []);
    // Edita o campo 1 colocando o valor do campo 2
    Self.DataSet.Edit;
    Self.DataSet.FieldByName(Self.FieldName).AsFloat := dVLR2;
    Self.DataSet.Post;
    // Localiza o campo 2
    Self.DataSet.Locate(Self.FieldName, dVLR1 * -1, []);
    // Edita o campo 2 colocando o valor do campo 1
    Self.DataSet.Edit;
    Self.DataSet.FieldByName(Self.FieldName).AsFloat := dVLR1;
    Self.DataSet.Post;

    // Define o campo 2 como o campo 1 em caso de loop
    dVLR1 := dVLR2;
  end;
  try
    Self.DataSet.DisableControls;
    // Passa por todos os fields
    for I := 0 to Pred(Self.DataSet.FieldCount) do
    begin
      // Se o cds possui o field LINHA
      if Self.DataSet.Fields[I].FieldName.Equals('LINHA') then
      begin
        // Inicializa contador
        X := 1;
        // Reordena
        Self.DataSet.First;
        while not Self.DataSet.Eof do
        begin
          Self.DataSet.Edit;
          Self.DataSet.FieldByName('LINHA').AsString := IntToStr(X);
          Self.DataSet.Post;
          // Incrementa contador
          Inc(X);
          // Vai para o próximo registro
          Self.DataSet.Next;
        end;
        // Sai do loop dos Fields
        Break;
      end;
    end;
  finally
    Self.DataSet.EnableControls;
  end;
  // Para na posição definida
  Self.DataSet.Locate(Self.FieldName,dVLR1,[]);
end;

function TIGField.IndexOf<T>(const Lista: array of T; Item: T): Integer;
var
  I: Integer;
  Comparer: IEqualityComparer<T>;
begin
  Result := -1;
  Comparer := TEqualityComparer<T>.Default;
  for I := Low(Lista) to High(Lista) do
    if Comparer.Equals(Lista[I], Item) then
      Exit(I);
end;

function TIGField.IGMatchValue(Values: TArray<String>): Boolean;
begin
  Result := IndexOf<String>(Values, AsString) <> -1;
end;

function TIGField.IGMatchValue(Values: TArray<Integer>): Boolean;
begin
  Result := IndexOf<Integer>(Values, AsInteger) <> -1;
end;

function TIGField.IGMatchValue(Values: TArray<Double>): Boolean;
begin
  Result := IndexOf<Double>(Values, AsFloat) <> -1;
end;

function TIGField.IGMatchValue(Values: TArray<Extended>): Boolean;
begin
  Result := IndexOf<Extended>(Values, AsExtended) <> -1;
end;

function TIGField.IGMatchValue(Values: TArray<TDate>): Boolean;
begin
  Result := IndexOf<TDate>(Values, TDate(Trunc(AsDateTime))) <> -1;
end;

function TIGField.IGMatchValue(Values: TArray<TDateTime>): Boolean;
begin
  Result := IndexOf<TDateTime>(Values, AsDateTime) <> -1;
end;

function TIGField.IGMatchValue(Values: TArray<Boolean>): Boolean;
begin
  Result := IndexOf<Boolean>(Values, AsBoolean) <> -1;
end;

function TIGField.IGIndexOf(Values: TArray<String>): Integer;
begin
  Result := IndexOf<String>(Values, AsString);
end;

function TIGField.IGIndexOf(Values: TArray<Integer>): Integer;
begin
  Result := IndexOf<Integer>(Values, AsInteger);
end;

function TIGField.IGIndexOf(Values: TArray<Double>): Integer;
begin
  Result := IndexOf<Double>(Values, AsFloat);
end;

function TIGField.IGIndexOf(Values: TArray<Extended>): Integer;
begin
  Result := IndexOf<Extended>(Values, AsExtended);
end;

function TIGField.IGIndexOf(Values: TArray<TDate>): Integer;
begin
  Result := IndexOf<TDate>(Values, TDate(Trunc(AsDateTime)));
end;

function TIGField.IGIndexOf(Values: TArray<TDateTime>): Integer;
begin
  Result := IndexOf<TDateTime>(Values, AsDateTime);
end;

function TIGField.IGIndexOf(Values: TArray<Boolean>): Integer;
begin
  Result := IndexOf<Boolean>(Values, AsBoolean);
end;

{ TIGClientDataSet }

{$IFDEF MSWINDOWS}
//class function TIGClientDataSet.Criptografia(Action, Src: String): String;
//var
//  KeyLen : Integer;
//  KeyPos : Integer;
//  OffSet : Integer;
//  Dest, Key : String;
//  SrcPos : Integer;
//  SrcAsc : Integer;
//  TmpSrcAsc : Integer;
//  Range : Integer;
//begin
//  Result := Src;
//  if Src.IsEmpty Then
//    Exit;
//  Key := 'T6WQNIW5BS240CF3B6G3LSD1JKR6F1MY6QHYUTBQJH44B55LJFFLY39HC7PJF6CF5J8T0IN5K05NLNB7CDO062IDWG9CMDG1A4UMZNOU46Z0BOAIFQCBYP0JG82Y5W51RZQOCXXSTY0PDT58BFQRIIUNOXAV1IML6AZ6UID3XPEKKINREMRBF7JMVJD9KPZGUYFK74ZF5JE83EET9LIKX1XP7XY8UDLYCQ055I4P6KTXPUN2C1Y9OUV9OH71BFU';
//  Dest := '';
//  KeyLen := Length(Key);
//  KeyPos := 0;
//  Range := 256;
//  if (Action = UpperCase('C')) then
//  begin
//    Randomize;
//    OffSet := Random(Range);
//    Dest := Format('%1.2x',[OffSet]);
//    for SrcPos := 1 to Length(Src) do
//    begin
//      Application.ProcessMessages;
//      SrcAsc := (Ord(Src[SrcPos]) + OffSet) mod 255;
//      if KeyPos < KeyLen then
//        KeyPos := KeyPos + 1
//      else
//        KeyPos := 1;
//      SrcAsc := SrcAsc xor Ord(Key[KeyPos]);
//      Dest := Dest + Format('%1.2x',[SrcAsc]);
//      OffSet := SrcAsc;
//    end;
//  end
//  else
//  if (Action = UpperCase('D')) then
//  begin
//    OffSet := StrToInt('$'+ copy(Src,1,2));
//    SrcPos := 3;
//    repeat
//      SrcAsc := StrToInt('$'+ copy(Src,SrcPos,2));
//      if (KeyPos < KeyLen) then
//        KeyPos := KeyPos + 1
//      else
//        KeyPos := 1;
//      TmpSrcAsc := SrcAsc xor Ord(Key[KeyPos]);
//      if TmpSrcAsc <= OffSet then
//        TmpSrcAsc := 255 + TmpSrcAsc - OffSet
//      else
//        TmpSrcAsc := TmpSrcAsc - OffSet;
//      Dest := Dest + Chr(TmpSrcAsc);
//      OffSet := SrcAsc;
//      SrcPos := SrcPos + 2;
//    until (SrcPos >= Length(Src));
//  end;
//  Result := Dest;
//end;
//
//procedure TIGClientDataSet.IGMarcarTodosRegistros(AColumn: TColumn);
//var
//  bMarcar: Boolean;
//begin
//  if RecordCount = 0 then
//    Exit;
//
//  try
//    DisableControls;
//
//    // Definir se deverá marcar os registros
//    bMarcar := AColumn.Title.Caption.Equals('R');
//
//    // Passar por todos os registros do dataset
//    First;
//    while not Eof do
//    begin
//      Edit;
//
//      // Marcar ou desmarcar todos os registros
//      if bMarcar then
//        AColumn.Field.AsString := 'S'
//      else
//        AColumn.Field.AsString := 'N';
//
//      // Proximo registro
//      Next;
//    end;
//
//    // Definir qual será o título da coluna
//    if bMarcar then
//      AColumn.Title.Caption := 'T'
//    else
//      AColumn.Title.Caption := 'R';
//
//  finally
//    First;
//    EnableControls;
//    AColumn.Grid.Invalidate;
//  end;
//end;
//
//procedure TIGClientDataSet.IGDivergencia(fForm: TForm);
//var
//  I      : Integer;
//  J      : Integer;
//  sPrior : String;
//begin
//  DisableControls;
//  try
//    // Se tiver mais de um registro para comparação
//    if RecordCount > 1 then
//    begin
//      // Percorre todo o cds
//      First;
//      while not Eof do
//      begin
//        // Percorre todos os fields
//        for I := 0 to Pred(FieldCount) do
//        begin
//          // Obtem o valor do ultimo registro
//          Prior;
//          sPrior := Fields[I].AsString;
//          Next;
//
//          // Verifica se os valores são diferentes
//          if Fields[I].AsString <> sPrior then
//          begin
//            // Percorre todos componentes da tela
//            for J := 0 to Pred(fForm.ComponentCount) do
//            begin
//              // Se o componente for um TDBEdit
//              if (fForm.Components[J] is TDBEdit) then
//                // Se o dbedt tiver o DataSet igual a cdsT0E1List
//                if TDBEdit(fForm.Components[J]).DataSource.DataSet = Self then
//                  // Verifica se é o mesmo field
//                  if TDBEdit(fForm.Components[J]).DataField = Fields[I].FieldName then
//                    // Se a cor do dbedt ja não for de divergencia
//                    if TDBEdit(fForm.Components[J]).Color <> $00C4C4FF then
//                    begin
//                      // Altera a cor do dbedt
//                      TDBEdit(fForm.Components[J]).Color := $00C4C4FF;
//                    end;
//            end;
//          end;
//        end;
//        Next;
//      end;
//      First;
//    end;
//  finally
//    EnableControls;
//  end;
//end;
//
//procedure TIGClientDataSet.IGLoadStream(sFonte: String; bTudo: Boolean = False);
//var
//  ss: TStringStream;
//  arq: TextFile;
//  sArq: String;
//  sLinha: String;
//  cdsXML: TClientDataSet;
//  I: Integer;
//  FieldCDS: TField;
//  FieldXML: TField;
//begin
//  try
//    try
//      // Cria o dataset
//      if not Self.Active then
//        Self.CreateDataSet;
//
//      // Verifica se existe arquivo salvo
//      sArq := ExtractFilePath(Application.ExeName) +'XML\'+ sFonte +'\'+ Self.Name +'.xml';
//      if not FileExists(sArq) then
//        Exit;
//
//      // Cria dataset temporário para receber os dados
//      cdsXML := TClientDataSet.Create(nil);
//      try
//        // Lê os dados criptografados do arquivo
//        AssignFile(arq, sArq);
//        try
//          Reset(arq);
//          while not System.Eof(arq) do
//            ReadLn(arq, sLinha);
//        finally
//          CloseFile(arq);
//        end;
//
//        // Faz a descriptografia
//        ss := TStringStream.Create(Criptografia('D', sLinha));
//        try
//          cdsXML.LoadFromStream(ss);
//        finally
//          FreeAndNil(ss);
//        end;
//
//        // Verifica se tem dados
//        if cdsXML.IsEmpty then
//          Exit;
//
//        // Se está carregando tudo, posiciona no primeiro, se não, posiciona no ultimo
//        if bTudo then
//          cdsXML.First
//        else
//          cdsXML.Last;
//
//        repeat
//          // Insere a linha no dataset atual
//          Self.Append;
//
//          // Percorre todos os campos do dataset atual
//          for I := 0 to Pred(Self.FieldCount) do
//          begin
//            // Obtem os fields
//            FieldCDS := Self.Fields[I];
//            FieldXML := cdsXML.FindField(FieldCDS.FieldName);
//
//            // Valida se encontrou, se não foi alterado o tipo e tamanho dos dados
//            if Assigned(FieldXML) and (FieldCDS.DataType = FieldXML.DataType) and (FieldCDS.Size = FieldXML.Size) then
//              FieldCDS.Value := FieldXML.Value;
//          end;
//
//          Self.Post;
//          cdsXML.Next;
//        until cdsXML.Eof;
//        Self.Last;
//      finally
//        FreeAndNil(cdsXML);
//      end;
//    finally
//      Self.Edit;
//    end;
//  except
//  end;
//end;
//
//procedure TIGClientDataSet.IGSaveStream(pFonte: String);
//var
//  ss: TStringStream;
//  arq: TextFile;
//  sArq: String;
//begin
//  try
//    // Remove histórico de alterações
//    Self.MergeChangeLog;
//
//    // Obtem o local para salvar
//    sArq := ExtractFilePath(ParamStr(0)) +'XML\'+ pFonte +'\';
//    ExisteDir(sArq);
//    AssignFile(arq, sArq + Self.Name +'.xml');
//
//    ss := TStringStream.Create;
//    try
//      // Salva os dados na stream
//      Self.Cancel;
//      Self.SaveToStream(ss, dfXMLUTF8);
//      try
//        // Grava criptografado no arquivo
//        ReWrite(arq);
//        WriteLn(arq, Criptografia('C', ss.DataString));
//      except
//      end;
//    finally
//      Self.Edit;
//      FreeAndNil(ss);
//      CloseFile(arq);
//    end;
//  except
//  end;
//end;
//
//function TIGClientDataSet.ExecuteGravar(bAvisar: Boolean): Boolean;
//begin
//  Result := False;
//
//  if State in [dsInsert, dsEdit] then
//    Post;
//
//  try
//    ApplyUpdates(0);
//
//    if bAvisar then
//      IGMsgCustom('Gravado com sucesso!');
//
//    Result := True;
//  except
//    on E: Exception do
//    begin
//      Edit;
//      IGMsgRaise('Não foi possível gravar!' + sLineBreak + sLineBreak + e.Message);
//    end;
//  end;
//end;
//
//function TIGClientDataSet.ExecuteConfirmar(bAvisar: Boolean): Boolean;
//begin
//  Result := False;
//
//  // Verifica se todos os campos foram informados
//  if State in [dsInsert, dsEdit] then
//    Post;
//
//  try
//    // Informar ao usuário
//    if bAvisar then
//      IGMsgCustom('Confirmação efetuada!'+ sLineBreak + 'Realize a gravação para persistir na base!');
//
//    Result := True;
//  except
//    on E: Exception do
//    begin
//      IGMsgRaise('Não foi possível confirmar!' + sLineBreak + sLineBreak + e.Message);
//    end;
//  end;
//end;
//
//function TIGClientDataSet.ExecuteCancelarTudo(bPerguntar: Boolean): Boolean;
//begin
//  Result := False;
//
//  if State in [dsInsert, dsEdit] then
//    if bPerguntar then
//      if not(IGMsgQuestion('Há registros em edição cancelar mesmo assim?')) then
//        Abort;
//
//  try
//    CancelUpdates;
//    Result := True;
//  except
//    on E: Exception do
//    begin
//      IGMsgRaise('Não foi possível cancelar!' + sLineBreak + sLineBreak + e.Message);
//    end;
//  end;
//end;
//
//function TIGClientDataSet.ExecuteCancelarAtual(bPerguntar: Boolean): Boolean;
//begin
//  Result := False;
//
//  if State in [dsInsert, dsEdit] then
//    if bPerguntar then
//      if not(IGMsgQuestion('Há registros em edição cancelar mesmo assim?')) then
//        Abort;
//
//  try
//    Cancel;
//    Result := True;
//  except
//    on E: Exception do
//    begin
//      IGMsgRaise('Não foi possível cancelar!' + sLineBreak + sLineBreak + e.Message);
//    end;
//  end;
//end;
//
//function TIGClientDataSet.ExecuteDeletarNaBase(bPerguntar, bAvisar: Boolean): Boolean;
//begin
//  Result := False;
//
//  if bPerguntar then
//    if not (IGMsgQuestion('Confirma a Exclusão?')) then
//      Abort;
//
//  try
//    Delete;
//    ApplyUpdates(0);
//
//    // Informar ao usuário
//    if bAvisar then
//      IGMsgCustom('Deletado com sucesso!');
//    Result := True;
//  except
//    on E: Exception do
//    begin
//      IGMsgRaise('Não foi possível deletar!' + sLineBreak + sLineBreak + e.Message);
//    end;
//  end;
//end;
//
//function TIGClientDataSet.ExecuteDeletarNoCDS(bPerguntar: Boolean): Boolean;
//begin
//  Result := False;
//
//  if bPerguntar then
//    if not (IGMsgQuestion('Confirma a Exclusão?')) then
//      Abort;
//
//  try
//    Delete;
//    IGMsgCustom('Exclusão Confirmada!'+ sLineBreak +
//                'Realize a gravação para persistir na base!');
//
//    Result := True;
//  except
//    on E: Exception do
//    begin
//      IGMsgRaise('Não foi possível deletar!' + sLineBreak + sLineBreak + e.Message);
//    end;
//  end;
//end;
{$ENDIF}

procedure TIGClientDataSet.IGOrderBy(pFieldName: String);
var
  FieldName : string;
  Option    : Boolean;
begin

  // Ocorre erro ao ordenar a grid por um campo de lookup
  if Self.FieldByName(pFieldName).FieldKind = fkLookup then
    Exit;

  //Inicializa as variaveis
  FieldName := pFieldName + '_ASC';
  Option := False;
  //Verifica se ja existe alguma ordenação
  if Self.IndexDefs.Count > 0 then
  begin
    //Verifica se o campo a ser ordenado ja foi ordenado
    if Self.IndexDefs.Items[0].Fields.Equals(pFieldName) then
    begin
      //Verifica se o campo ja foi ordenado em ordem crescente
      if Self.IndexDefs.Items[0].Name.Equals(pFieldName + '_ASC') then
      begin
        FieldName := pFieldName + '_DESC';
        Option := True;
      end;
    end;
    Self.IndexDefs.Delete(0);
  end;
  //Define a ordenação
  with Self.IndexDefs.AddIndexDef do
  begin
    Name   := FieldName;
    Fields := pFieldName;
    if Option then
      Options := [ixDescending]
    else
      Options := [];
  end;
  //Ordena
  Self.IndexName := FieldName;
end;

function TIGClientDataSet.IGTotalize(pCampoComValor, pFiltro: String): Double;
var
  dTotal   : Double;
  bkBookmark : TBookmark;
begin
  dTotal := 0;

  DisableControls;
  bkBookmark := Bookmark;

  // Se foi informado um filtro então filtrar
  if not(Trim(pFiltro).IsEmpty) then
  begin
    Filtered := False;
    Filter   := pFiltro;
    Filtered := True;
  end;

  // Enquanto não for o fim do cdsClone
  First;
  while not(eof) do
  begin
    dTotal := dTotal + FieldByName(pCampoComValor).AsFloat;
    Next;
  end;

  // Se foi informado um filtro então filtrar
  if not(Trim(pFiltro).IsEmpty) then
    Filtered := False;

  First;

  GotoBookmark(bkBookmark);
  FreeBookmark(bkBookmark);
  EnableControls;

  // Retorna o valor totalizado
  Result := dTotal;
end;

function StrJsonToDateTime(sData: String): Variant;
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

function TIGClientDataSet.LoadFromJSONArray(jaValue: TJSONArray): TClientDataSet;
var
  I,J: Integer;
  oJSONROW: TJSONObject;
  oJSONCEL: TJSONPair;
  DField: TField;
  sDados: String;
  sValor: String;
  ss: TStringStream;
  Data: Variant;
begin
  sDados := EmptyStr;
  for I := 0 to Pred(jaValue.Count) do
  begin
    oJSONROW := TJSONObject(jaValue.Items[I]);
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
end;

function TIGClientDataSet.IGCloneTotalize(pCampoComValor, pFiltro: String): Double;
var
  dTotal     : Double;
  cdsClone   : TClientDataSet;
begin
  dTotal := 0;

  cdsClone := TClientDataSet.Create(nil);
  try
    // Clona o cds
    cdsClone.CloneCursor(Self, False);

    // Se foi informado um filtro então filtrar
    if not(Trim(pFiltro).IsEmpty) then
    begin
      cdsClone.Filtered := False;
      cdsClone.Filter   := pFiltro;
      cdsClone.Filtered := True;
    end;

    // Enquanto não for o fim do cdsClone
    cdsClone.First;
    while not(cdsClone.Eof) do
    begin
      dTotal := dTotal + cdsClone.FieldByName(pCampoComValor).AsFloat;
      cdsClone.Next;
    end;

    // Se foi informado um filtro então filtrar
    if not(Trim(pFiltro).IsEmpty) then
      cdsClone.Filtered := False;
  finally
    cdsClone.Close;
    FreeAndNil(cdsClone);
  end;

  // Retorna o valor totalizado
  Result := dTotal;
end;

function TIGClientDataSet.IGMultiTotalize(ACampos: array of String; pFiltro: String): TDoubleArray;
var
  cdsClone : TClientDataSet;
  I: Integer;
begin
  // Se o cds estiver vazio retorna zero
  if Self.IsEmpty or (TClientDataSet(Self).RecordCount = 0) then
  begin
    SetLength(Result, Length(ACampos));
    for I := 0 to Pred(Length(ACampos)) do
      Result[I] := 0;

    Exit;
  end;

  cdsClone := TClientDataSet.Create(nil);
  try
    // Clona o cds
    cdsClone.CloneCursor(Self, False);

    // Se foi informado um filtro então filtrar
    if not(Trim(pFiltro).IsEmpty) then
    begin
      cdsClone.Filtered := False;
      cdsClone.Filter   := pFiltro;
      cdsClone.Filtered := True;
    end;

    // Limpa Result
    SetLength(Result, 0);

    // Define tamanho do Array dos valores de acordo com a quantidade de campos
    SetLength(Result, Length(ACampos));

    // Enquanto não for o fim do cdsClone
    cdsClone.First;
    while not(cdsClone.Eof) do
    begin
      // Passa por todos os campos somando e adicionando ao Resultado
      for I := 0 to Pred(Length(ACampos)) do
        Result[I] := Result[I] + cdsClone.FieldByName(ACampos[I]).AsFloat;
      cdsClone.Next;
    end;

    // Se foi informado um filtro então filtrar
    if not(Trim(pFiltro).IsEmpty) then
      cdsClone.Filtered := False;
  finally
    cdsClone.Close;
    FreeAndNil(cdsClone);
  end;
end;

function TIGClientDataSet.IGFilterTotalize(sCampo: String; sFiltros: Array of String): TDoubleArray;
var
  cdsClone : TClientDataSet;
  I: Integer;
begin
  // Inicializa
  SetLength(Result, Length(sFiltros));
  for I := 0 to High(sFiltros) do
    Result[I] := 0;

  // Se o cds estiver vazio retorna zero
  if Self.IsEmpty or (TClientDataSet(Self).RecordCount = 0) then
    Exit;

  cdsClone := TClientDataSet.Create(nil);
  try
    // Clona o cds
    cdsClone.CloneCursor(Self, False);

    // Popula
    for I := 0 to High(sFiltros) do
    begin
      cdsClone.IGFilter(sFiltros[I]);
      cdsClone.First;
      while not cdsClone.Eof do
      begin
        Result[I] := Result[I] + cdsClone.FieldByName(sCampo).AsFloat;
        cdsClone.Next;
      end;
    end;
  finally
    FreeAndNil(cdsClone);
  end;
end;

function TIGClientDataSet.IGMaxValue(pCampo, pFiltro: String): Double;
var
  sFieldName: String;
  cdsClone: TClientDataSet;
begin
  cdsClone := TClientDataSet.Create(Self);

  //Clona o DataSet
  cdsClone.CloneCursor(Self,False);

  {Ao copiar o Data, o estado do cds é alterado para Browser}
  //cdsClone.Data := Self.Data;

  // Verificar se o dataset esta vazio
  if cdsClone.IsEmpty then
  begin
    Result := 0;
    Exit;
  end;

  //Se foi informado um filtro então filtrar
  if not(Trim(pFiltro).IsEmpty) then
  begin
    cdsClone.Filtered := False;
    cdsClone.Filter   := pFiltro;
    cdsClone.Filtered := True;
  end;

  //Inicializa as variaveis
  sFieldName := pCampo + '_ASC';

  //Define a ordenação
  with cdsClone.IndexDefs.AddIndexDef do
  begin
    Name   := sFieldName;
    Fields := pCampo;
  end;

  //Ordena
  cdsClone.IndexName := sFieldName;

  cdsClone.Last;
  //Pega o valor do último registro do DataSet
  Result := cdsClone.FieldByName(pCampo).AsFloat;

  //cdsClone.IndexDefs.Delete(0);
  FreeAndNil(cdsClone);
end;

function TIGClientDataSet.IGTemRegistroMarcado(pCampo, pValor: String): Boolean;
var
  bkBookmark : TBookmark;
begin
  Result := False;

  if RecordCount = 0 then
    Exit;

  try
    DisableControls;
    bkBookmark := Bookmark;
    Result := Locate(pCampo, pValor, []);
  finally
    GotoBookmark(bkBookmark);
    FreeBookmark(bkBookmark);
    EnableControls;
  end;
end;

procedure TIGClientDataSet.IGMarcarRegistro(pCampo: String);
begin
  if RecordCount = 0 then
    Exit;

  try
    Edit;
    if FieldByName(pCampo).AsString.Equals('S') then
      FieldByName(pCampo).AsString := ('N')
    else
      FieldByName(pCampo).AsString := ('S');
    Post;
  except on E: Exception do
    raise Exception.Create('> ' + Self.UnitName + ' : IGMarcarRegistro' + #13 + E.Message);
  end;
end;

procedure TIGClientDataSet.IGFilter(sFilter: String = '');
begin
  Self.Filtered := False;
  Self.Filter   := sFilter;
  Self.Filtered := not sFilter.IsEmpty;
end;

function TIGClientDataSet.FName(pFieldName: String): TField;
begin
  Result := Self.FieldByName(pFieldName);
end;

function TIGClientDataSet.IGGetValuesToInSql(sFieldName: String; bQuoted: Boolean = False; iPadL: Integer = 0;
  sFilter: string = ''; bGroup : Boolean = False): String;
var
  cdsAux: TClientDataSet;
  sl    : TStringList;
  sTemp : String;
begin
  // Retorna uma string com todos os valores encontradados
  // separados por virgula para o field do cds passado por
  // parametro

  // Se o cds estiver vazio
  if RecordCount = 0 then
    Exit;

  Result := EmptyStr;
  cdsAux := TClientDataSet.Create(nil);
  sl     := TStringList.Create; // Separa por vírgula
  try
    cdsAux.CloneCursor(Self, False);

    // Se informou algum filtro
    if not sFilter.Trim.IsEmpty then
      cdsAux.IGFilter(sFilter);

    // Verifica se deve agrupar
    if bGroup then
    begin
      sl.Sorted     := True;
      sl.Duplicates := dupIgnore;
    end;

    // Percorre o cdsAux montando a string de retorno
    cdsAux.First;
    while not cdsAux.Eof do
    begin
      // Armazena valor inicial
      sTemp := cdsAux.IGGetStr(sFieldName);

      // Verifica se deve adicionar PadL
      if iPadL <> 0 then
        sTemp := sTemp.PadLeft(iPadL, '0');

      // Verifica se deve adicionar Quoted
      if bQuoted then
        sTemp := Qt(sTemp);

      // Adiciona ao retorno o valor
      sl.Add(sTemp);

      // Vai para o próximo registro
      cdsAux.Next;
    end;

    // Retorna
    sl.Delimiter := ',';
    sl.StrictDelimiter := True; // Ex.: 'Texto com Espaço' seria duplamente Quoted caso bQuoted estivesse marcado
    Result := sl.DelimitedText;
  finally
    FreeAndNil(sl);
    FreeAndNil(cdsAux);
  end;
end;

procedure TIGClientDataSet.IGCloneRecord(bPost: Boolean = True);
var
  cdsCopia : TClientDataSet;
  I        : Integer;
begin
  try
    // Criar o CDS
    cdsCopia := TClientDataSet.Create(nil);
    try
      // Clona o DataSet
      cdsCopia.CloneCursor(Self, true);

      // Inserir um novo registro no cds original
      Self.Insert;

      // Obter todos os valores do cds clone
      for I := 0 to Pred(FieldCount) do
      begin
        if not (pfInKey in Fields[i].ProviderFlags) and not (LeftStr(Fields[i].FieldName, 3) = 'IG_') and
           not (Fields[i].FieldKind = fkCalculated) and not (LeftStr(Fields[i].FieldName, 3) = 'qry') and
           not (Fields[i].FieldKind = fkLookup)  then
        begin
          // Obter o valor dos campos
          Fields[I].Assign(cdsCopia.FindField(Fields[I].FieldName));
        end;
      end;

      // Postar o novo registro
      if bPost then
        Self.Post;
    finally
      FreeAndNil(cdsCopia);
    end;
  except
    on E: Exception do
    begin
      Cancel;
      raise Exception.Create('> ' + Self.UnitName + ' : IGCloneRecord' + sLineBreak + E.Message);
    end;
  end;
end;

function TIGClientDataSet.CountRegCDS(pFieldName, pCriterio: String): Integer;
var
  isInteger : Boolean;
  cdsClone: TClientDataSet;
begin
  try
    { Desabilita o filtro atual }
    Filtered := false;

    { Cria o dataset clone e copia os dados do pCDS }
    cdsClone := TClientDataSet.Create(Nil);
    cdsClone.CloneCursor(Self, False);

    { Desabilita o filtro atual }
    cdsClone.Filtered := false;

    { Se não passar critério conta todos os registros }
    if (pCriterio <> '') then
    begin
      { Define o novo filtro }
      isInteger := FieldByName(pFieldName).DataType = ftInteger;
      cdsClone.Filter := (pFieldName + ' = ' + ifthen(isInteger, pCriterio, QuotedStr(pCriterio)));

      { Aplica o filtro definido }
      cdsClone.Filtered := true;
    end;

    Result := cdsClone.RecordCount;

  finally
    FreeAndNil(cdsClone);
  end;
end;

function TIGClientDataSet.IGCountFilter(sFilter: string; bReset: Boolean = False): Integer;
var
  cdsClone: TClientDataSet;
begin
  {
    Daniel - 24/05
    Clona o cds e conta quantos registros correspondem ao filtro informado;
    bReset = Reseta as configurações, Ex.: Caso o dataset esteja com um filtro anteriormente, irá removê-lo.
  }
  cdsClone := TClientDataSet.Create(nil);
  try
    // Clona o cds
    cdsClone.CloneCursor(Self, bReset);

    // Adiciona o filtro
    cdsClone.Filter   := sFilter;
    cdsClone.Filtered := not sFilter.Trim.IsEmpty;

    // Obtém a Qtd de Registros
    Result := cdsClone.RecordCount;
  finally
    FreeAndNil(cdsClone);
  end;
end;

function TIGClientDataSet.IGCountFiltro(pFiltro: String): Integer;
var
  nContar   : integer;
  bkBookmark : TBookmark;
begin
  nContar   := 0;

  DisableControls;
  bkBookmark := Bookmark;

  // Se foi informado um filtro então filtrar
  if not(Trim(pFiltro).IsEmpty) then
  begin
    Filtered := False;
    Filter   := pFiltro;
    Filtered := True;
  end;

  // Enquanto não for o fim do cdsClone
  First;
  while not(eof) do
  begin
    nContar := nContar + 1;
    Next;
  end;

  Filtered := False;
  First;

  GotoBookmark(bkBookmark);
  FreeBookmark(bkBookmark);
  EnableControls;

  // Retorna o valor totalizado
  Result := nContar;
end;

procedure TIGClientDataSet.IGSetOrderBy(pFieldName: String; bDesc: Boolean);
begin
  if Self.IsEmpty then
    Exit;

  // Verifica se ja existe alguma ordenação
  while IndexDefs.Count > 0 do
    IndexDefs.Delete(0);

  // Define a ordenação
  with IndexDefs.AddIndexDef do
  begin
    Name := pFieldName +'_ASC';
    Fields := pFieldName;

    // Ordenação crescente ou decrescente
    if bDesc then
      Options := [ixDescending]
    else
      Options := [];
    IndexName := pFieldName +'_ASC';
  end;
end;

procedure TIGClientDataSet.IGSetParam(sParam: string; Value: Variant);
var
  I: Integer;
begin
  if not Assigned(Params.FindParam(sParam)) then
    raise Exception.Create('Parâmetro "'+ sParam +'" não encontrado!');

  for I := 0 to Pred(Params.Count) do
    if Params[I].Name.Equals(sParam) then
      Params[I].Value := Value;
end;

function TIGClientDataSet.IGGetParam(sParam: string): Variant;
begin
  if not Assigned(Params.FindParam(sParam)) then
    raise Exception.Create('Parâmetro "'+ sParam +'" não encontrado!');

  Result:= ParamByName(sParam).Value;
end;

function TIGClientDataSet.IGParamPesq(asFields: array of String): String;
var
  sField : String;
  function StrRplce(str : String) : String;
  begin
    Result := StringReplace(str ,',',' ',[rfReplaceAll]);
    str    := StringReplace(Result ,':',' ',[rfReplaceAll]);
    Result := Trim(str);
  end;
begin
  for sField in asFields do
  begin
    if not (Self.FindField(sField) = nil) then
      if not Self.FieldByName(sField).AsString.Trim.IsEmpty then
        Result := IfThen(not Result.Trim.IsEmpty, Result +',') + StrRplce(Self.FieldByName(sField).DisplayLabel) +':'+ StrRplce(Self.FieldByName(sField).AsString);
  end;
end;

function TIGClientDataSet.IGCount_Check(pCampo, pVlr_Checado: String; pChecado: Boolean): Integer;
var
  cdsClone : TClientDataSet;
begin
  cdsClone := TClientDataSet.Create(nil);
  try
    cdsClone.CloneCursor(Self, False);

    // Atualiza o Filtro
    cdsClone.Filtered := False;
    cdsClone.Filter   := '';
    cdsClone.Filter   := IFTHEN(not(pChecado),'NOT ') + pCampo + ' = ' + QuotedStr( pVlr_Checado );
    cdsClone.Filtered := True;

    Result := cdsClone.RecordCount;

  finally
    // Desabilita os Filtros
   cdsClone.Filtered := False;
   cdsClone.Filter   := '';

   FreeAndNil(cdsClone);
  end;
end;

procedure TIGClientDataSet.DenseRank(Field_Item, Field_Group: string);
var
  iItemAtual: Integer;
  bmkRegistroAtual: TBookmark;
  sKeyAnterior: string;
begin

  // Se não foi informado o campo item, sai fora
  if Field_Item.Trim.IsEmpty then
    Exit;

  // Se Estiver Vazio sai fora
  if Self.IsEmpty then
    Exit;

  // Salva Posicao Atual
  bmkRegistroAtual:= Self.GetBookmark;

  // Se for Ordedar por Grupos
//  if not Field_Group.Trim.IsEmpty then
//    IGOrderBy(Field_Group,'_ASC');

  if not Field_Group.Trim.IsEmpty then
    Field_Group := Field_Group.Split([';'])[0];

  iItemAtual:= 1;
  // Posiciona no Primeiro Registro
  Self.First;
  // Passa por todos os Registros
  while not TCustomClientDataSet(Self).Eof do
  begin
    // Se estiver Ordenando por Grupos
    if not Field_Group.Trim.IsEmpty then
    begin
      if not sKeyAnterior.Trim.IsEmpty then
      begin
        // Se mudou o grupo zera o contador
        if not sKeyAnterior.Trim.Equals(FieldByName(Field_Group).AsString.Trim) then
          iItemAtual:=1;
      end;
      sKeyAnterior:=FieldByName(Field_Group).AsString;
    end;

    // Edita e Numera
    Edit;
    FieldByName(Field_Item).AsString := iItemAtual.ToString;
    Post;

    // Proximo Item
    Inc(iItemAtual);
    Next;
  end;
  GotoBookMark(bmkRegistroAtual);
  FreeBookmark(bmkRegistroAtual);
end;


function Formatar_Add(pNovoADD, pLista: String; pRemover_Identico : Boolean = True): String;
var
  iPos : Integer;
  sNew_Lista : String;
begin
  // Verifica se o código informado já esta relacionado na lista.
  sNew_Lista := pLista;

  iPos := Pos(pNovoADD,sNew_Lista);

  // Se tiver encontrado remove o que existe, se não existir ainda é porque tem de adicionar
  if (iPos > 0) and pRemover_Identico then
    sNew_Lista := ReplaceStr(sNew_Lista,pNovoADD,'')
  else
  begin
    if sNew_Lista.Trim.IsEmpty then
      sNew_Lista := pNovoADD
    else
      sNew_Lista := sNew_Lista +',' + pNovoADD;
  end;

  sNew_Lista := ReplaceStr(sNew_Lista,',,',',');

  if (sNew_Lista.Trim.Length > 1) then
  begin
    if (sNew_Lista[1] = ',') then
    begin
      sNew_Lista := Copy(sNew_Lista,2,sNew_Lista.Length);
    end;

    if (sNew_Lista[sNew_Lista.Length] = ',') then
    begin
      sNew_Lista := Copy(sNew_Lista,1,pred(sNew_Lista.Length));
    end;
  end
  else
  if sNew_Lista = ',' then
    sNew_Lista:= '';

  Result := sNew_Lista;
end;


function TIGClientDataSet.ObterListaCds(pArrayFields: TStringDynArray;
  pUsarQt : Boolean; pUsarEnabled_Disabled : Boolean;
  pFiltro: String ): TStringDynArray; //System.Types
var
  bookMark : TBookMark;
  I: Integer;
  sItemAdd : String;
begin

  if pUsarEnabled_Disabled then
    Self.DisableControls;

  bookMark := Self.GetBookmark;

  if not pFiltro.Trim.IsEmpty then
  begin
    Self.Filtered := False;
    Self.Filter   := pFiltro;
    Self.Filtered := True;
  end;

  try
    if not Self.RecordCount > 0 then
      Exit;



    //System.StrUtils
    Result := pArrayFields;

    Self.First;
    for I := Low(pArrayFields) to High(pArrayFields) do
    begin
      if pUsarQt then
        sItemAdd := Qt(Self.FieldByName(pArrayFields[i]).AsString)
      else
        sItemAdd := Self.FieldByName(pArrayFields[i]).AsString;

      Result[I] := sItemAdd;
    end;
    Self.Next;

    while not(Self.Eof) do
    begin
      for I := Low(pArrayFields) to High(pArrayFields) do
      begin
        if pUsarQt then
          sItemAdd := Qt(Self.FieldByName(pArrayFields[i]).AsString)
        else
          sItemAdd := Self.FieldByName(pArrayFields[i]).AsString;

        Result[I] := Formatar_Add(sItemAdd,Result[I],False);
      end;

      Self.Next;
    end;

  finally
    if not pFiltro.Trim.IsEmpty then
    begin
      Self.Filtered := False;
      Self.Filter   := pFiltro;
    end;

    Self.GotoBookmark(bookMark);
    Self.FreeBookmark(bookMark);

    if pUsarEnabled_Disabled then
      Self.EnableControls;
  end;
end;

procedure TIGClientDataSet.IGOpenParams(sParams: String; aVariant: Variant);
begin
  IGOpenParams(sParams, [aVariant]);
end;

procedure TIGClientDataSet.IGOpenParams(sParams: String; aVariant: TArray<Variant>);
var
  arr: TStringDynArray;
  I: Integer;
begin
  Close;
  arr := SplitString(sParams, ',');

  if High(arr) <> High(aVariant) then
    raise Exception.Create('Quantidade de parâmetros diferente dos valores!');

  for I := 0 to High(arr) do
    IGSetParam(arr[I], aVariant[I]);

  Open;
end;

function TIGClientDataSet.IGGroup: TIGGroup;
begin
  Result := TIGGroup.Create(TClientDataSet(Self));
end;

{ TIGDataSet }

(*
function TIGDataSet.GetClassByName(sClassName: String): TArray<TClass>;
var
  rttiType: TRttiType;
  procedure Add;
  begin
    SetLength(Result, Succ(Length(Result)));
    Result[Pred(Length(Result))] := rttiType.AsInstance.MetaclassType;
    rttiType := nil;
  end;
begin
  Result := [];
  // Cria o RTTIContext para Obter os tipos
  with TRttiContext.Create do
  begin
    for sClassName in sClassName.Split([',']) do // Percorre a Lista de Classes
    begin
      if sClassName.Trim.IsEmpty then
        Continue;

      // Tenta localizar o Tipo através do QualifiedName. QualifiedName: "NomeUnit.NomeClasse"
      //   Ex.: Extend.DBCtrls.TDBEdit, Extend.DBGrids.TDBGrid
      rttiType := FindType(sClassName);
      if Assigned(rttiType) then
        Add // Adiciona à lista
      else // Se não encontrar através do QualifiedName
      for rttiType in GetTypes do // Percorre a lista de tipos disponíveis
      begin
        // Valida pelo Name ou parte do QualifiedName. Ex.: TDBEdit ou DBCtrls.TDBEdit
        if not (rttiType.Name.Equals(sClassName) or rttiType.QualifiedName.EndsWith(sClassName)) then
          Continue;

        Add; // Adiciona à Lista
        Break; // Vai para a próxima classe da lista
      end;
    end;
  end;
end;

function TIGDataSet.GetClassFromType(ATypeInfo: Pointer): TClass;
var
  RTTIContext: TRttiContext;
  RTTIType   : TRttiType;
begin
  // \o/ Daniel Araujo | 19/11/2019
  //   Retorna a Classe a partir do TypeInfo
  try
    // Cria o RTTiContext
    RTTIContext := TRttiContext.Create;
    // Obtém o RTTIType do Tipo Genérico
    RTTIType := RTTIContext.GetType(ATypeInfo);
    try
      // Obtém a Classe
      Result := RTTIType.AsInstance.MetaclassType;
    finally
      FreeAndNil(RTTIType);
    end;
  except
    Result := nil;
  end;
end;

function TIGDataSet.IGGetControl<T>(sFieldName: String = ''): T;
var
  cControl: TObject;
begin
  // \o/ Daniel Araujo | 19/11/2019
  //   Retorna o Primeiro controle do tipo T encontrado para o campo informado
  try
    cControl := IGGetControl(sFieldName, [GetClassFromType(TypeInfo(T))]);
    if Assigned(cControl) then
      Result := TValue.From(cControl).AsType<T>
    else
      Result := T(nil);
  except
    Result := T(nil);
  end;
end;

function TIGDataSet.IGGetControls<T>(sFieldName: String = ''; bOnlyOne: Boolean = False): TArray<T>;
var
  aControls: TArray<TObject>;
  cControl : TObject;
  vtControl: T;
begin
  // \o/ Daniel Araujo | 19/11/2019
  //   Retorna a Lista de Controles do Tipo T encontrados para o campo informado
  try
    // Obtém a Lista de Controls
    aControls:= IGGetControls(sFieldName, [GetClassFromType(TypeInfo(T))], bOnlyOne);
    // Percorre a Lista Adicionando Ao Result
    for cControl in aControls do
    begin
      try
        // Tenta Converter
        vtControl := TValue.From(cControl).AsType<T>;
        // Adiciona ao Result
        SetLength(Result, Succ(Length(Result)));
        Result[Pred(Length(Result))] := vtControl;
      except
        // Se der erro, não adiciona ao result
      end;
    end;
  except
    Result := [];
  end;
end;

function TIGDataSet.IGGetControl(sFieldName, sClasses: String): TObject;
begin
  Result := IGGetControl(sFieldName, GetClassByName(sClasses));
end;

function TIGDataSet.IGGetControls(sFieldName, sClasses: String; bOnlyOne: Boolean): TArray<TObject>;
begin
  Result := IGGetControls(sFieldName, GetClassByName(sClasses), bOnlyOne)
end;

function TIGDataSet.IGGetControl(sFieldName: String = ''; aAllowedTypes: TArray<TClass> = []): TObject;
var
  aControls: TArray<TObject>;
begin
  // \o/ Daniel Araujo | 19/11/2019
  // Retorna o Primeiro Controle encontrado para o Campo Informado
  aControls := IGGetControls(sFieldName, aAllowedTypes, True);
  if Length(aControls) > 0 then
    Result := aControls[0]
  else
    Result := nil;
end;

type
  TDBLookupControlH = class(TDBLookupControl);
  TDataSourceLinkH = class Helper for Vcl.DBCtrls.TDataSourceLink
    function GetControl: TObject;
  end;

{ TDataSourceLinkH }

function TDataSourceLinkH.GetControl: TObject;
var
  RTTIContext   : TRttiContext;
  RTTIType      : TRttiType;
  RTTIField     : TRttiField;
  RTTIFieldValue: TValue;
begin
  // Cria o Contexto
  RTTIContext := TRttiContext.Create;
  // Obtém o RTTIType do TClientDataSet
  RTTIType := RTTIContext.GetType(Vcl.DBCtrls.TDataSourceLink);
  // Obtém o ClassField que contém a Lista de DataSources
  RTTIField := RTTIType.GetField('FDBLookupControl');
  if not Assigned(RTTIType) then
    raise Exception.Create('Falha ao obter o ClassField: FDBLookupControl!');

  // Obtém o RTTIFieldValue do ClassField
  RTTIFieldValue := RTTIField.GetValue(Self);
  // Obtém o valor (A Lista)
  Result := RTTIFieldValue.AsObject;
end;

function TIGDataSet.IGGetControls(sFieldName: String = ''; aAllowedTypes: TArray<TClass> = []; bOnlyOne: Boolean = False): TArray<TObject>;
var
  RTTIContext   : TRttiContext;
  RTTIType      : TRttiType;
  RTTIField     : TRttiField;
  RTTIFieldValue: TValue;
  FDataSources  : TList<TDataSource>;
  FDataSource   : TDataSource;
  FDataLink     : TDataLink;
  cControl      : TObject;
  cType         : TClass;
  bAllowed      : Boolean;
  bObterTColumn : Boolean;
  bContemColuna : Boolean;
  iColumn: Integer;
begin
  // \o/ Daniel Araujo | 19/11/2019
  // Retorna a Lista de Controles encontrados para o Campo Informado

  if sFieldName.Trim.IsEmpty then
  begin
    if Length(aAllowedTypes) > 1 then
      raise Exception.Create(Self.Name +'.IGGetControls: Para obter mais de 1 tipo de controle é necessário informar o nome do campo!');
    if (Length(aAllowedTypes) = 1) and (not aAllowedTypes[0].InheritsFrom(Vcl.DBGrids.TDBGrid)) then
      raise Exception.Create(Self.Name +'.IGGetControls: Nome do campo não informado!');
  end;

  // Inicializa o Result
  Result := [];

  // Cria o Contexto
  RTTIContext := TRttiContext.Create;
  // Obtém o RTTIType do TClientDataSet
  RTTIType := RTTIContext.GetType(TDataSet);
  if not Assigned(RTTIType) then
    raise Exception.Create('Falha ao obter o RTTIType do TDataSet!');

  try
    // Obtém o ClassField que contém a Lista de DataSources
    RTTIField := RTTIType.GetField('FDataSources');
    if not Assigned(RTTIType) then
      raise Exception.Create('Falha ao obter o ClassField: FDataSources!');

    // Obtém o RTTIFieldValue do ClassField
    RTTIFieldValue := RTTIField.GetValue(Self);
    // Obtém o valor (A Lista)
    FDataSources := TList<TDataSource>(RTTIFieldValue.AsObject);
    if not Assigned(FDataSources) then
      raise Exception.Create('Falha ao obter a Lista de DataSources do ClassField: FDataSources!');

    // Percorre a Lista de DataSources
    for FDataSource in FDataSources do
    begin
      // Valida se está criado
      if not Assigned(FDataSources) then
        Continue;

      // Obtém a Lista de DataLinks do DataSource
      for FDataLink in THackDataSource(FDataSource).DataLinks do
      begin
        // Valida se está Criado
        if not Assigned(FDataLink) then
          Continue;

        // Valida se é um tipo de DataLink permitido
        // Se for TDataLink de um component da Unit Vcl.DBCtrls(TDBEdit e outros)
        if FDataLink.InheritsFrom(Vcl.DBCtrls.TFieldDataLink) then
        begin
          // Valida se o Control está criado
          if not Assigned(Vcl.DBCtrls.TFieldDataLink(FDataLink).Control) then
            Continue;

          // Valida se é o Campo desejado
          if not Vcl.DBCtrls.TFieldDataLink(FDataLink).FieldName.Equals(sFieldName) then
            Continue;

          // Obtém o Control
          cControl := Vcl.DBCtrls.TFieldDataLink(FDataLink).Control;
        end
        else // Se for TDataLink de um component da Unit Vcl.DBCtrls(TDBLookupControl, TDBLookupComboBox e outros)
        if FDataLink.InheritsFrom(Vcl.DBCtrls.TDataSourceLink) then
        begin
          // Obtém o Control e Valida se o Control está criado
          cControl := TDataSourceLink(FDataLink).GetControl;
          if not Assigned(cControl) then
            Continue;

          // Valida se é o Campo desejado
          if not TDBLookupControlH(cControl).DataField.Equals(sFieldName) then
            Continue;
        end
        else // Se for TGridDataLink de um component da TDBGrid
        if FDataLink.InheritsFrom(Vcl.DBGrids.TGridDataLink) then
        begin
          // Valida se a Grid está criada
          if not Assigned(Vcl.DBGrids.TGridDataLink(FDataLink).Grid) then
            Continue;

          // Obtém o Control
          cControl := Vcl.DBGrids.TGridDataLink(FDataLink).Grid;

          if not sFieldName.IsEmpty then
          begin
            bObterTColumn := False;
            if Length(aAllowedTypes) > 0 then // Se existe Tipos Pré-Definidos, Valida se é um Tipo Permitido
              for cType in aAllowedTypes do // Percorre a Lista de Tipos
                if Assigned(cType) and (not bObterTColumn) then // Se ainda não encontrou o tipo
                  bObterTColumn := cType.InheritsFrom(Vcl.DBGrids.TColumn); // Valida se é um tipo permitido

            // Se é para obter a TColumn
            if bObterTColumn then
            begin
              bContemColuna := False;
              with Vcl.DBGrids.TDBGrid(cControl) do
              begin
                // Percorre a Lista de Colunas da DBGrid
                for iColumn := 0 to Pred(Columns.Count) do
                begin
                  // Valida se o Campo está Assinado
                  if Assigned(Columns[iColumn].Field) then
                  begin
                    // Valida se o Field da Coluna é o Field Requerido
                    bContemColuna := Columns[iColumn].FieldName.Equals(sFieldName);
                    // Se for o mesmo campo, então a GRID contém uma ou mais colunas relacionadas ao Field
                    if bContemColuna then
                    begin
                      cControl := Columns[iColumn];
                      Break;
                    end;
                  end;
                end;
                if not bContemColuna then
                  Continue;
              end;
            end;
          end;
        end
        else // Tipo desconhecido
          Continue;

        // Se existe Tipos Pré-Definidos, Valida se é um Tipo Permitido
        if Length(aAllowedTypes) > 0 then
        begin
          bAllowed := False;
          // Percorre a Lista de Tipos
          for cType in aAllowedTypes do
          begin
            // Se não for um tipo permitido vai para o Próximo Tipo
            if not cControl.InheritsFrom(cType) then
              Continue;

            // É um Tipo Permitido
            bAllowed := True;
            Break;
          end;
          // Se não for um tipo permitido vai para o próximo FDataLink
          if not bAllowed then
            Continue;
        end;

        // Atribui o Control ao Result
        SetLength(Result, Succ(Length(Result)));
        Result[Pred(Length(Result))] := cControl;
        if bOnlyOne then
          Break;
      end;
      if bOnlyOne and (Length(Result) = 1) then
        Break;
    end;
  finally
    FreeAndNil(RTTIType);
  end;
end;
*)

(*
function TIGDataSet.IGHighlightControls(sFields: String = ''; aAllowedTypes: TArray<TClass> = []; cColor: TColor = clWebPink; cBorder: TColor = clRed): TArray<IInterface>;
var
  sField   : String;
  aControls: TArray<TObject>;
  cControl : TObject;
  iField: Integer;
  procedure AddToResult(Highlight: IInterface);
  begin
    SetLength(Result, Succ(Length(Result)));
    Result[Pred(Length(Result))] := Highlight;
  end;
begin
  // Se não informou algum campo, deve Destacar todos
  if sFields.Trim.IsEmpty then
    for iField := 0 to Pred(Fields.Count) do
      sFields := sFields + IfThen(not sFields.Trim.IsEmpty, ',') + Fields[iField].FieldName;

  for sField in sFields.Split([',']) do
  begin
    if sField.Trim.IsEmpty then
      Continue;

    if Length(aAllowedTypes) = 0 then
      aAllowedTypes := [Extend.DBCtrls.TDBEdit, Extend.DBCtrls.TDBCheckBox, Extend.DBCtrls.TDBLookupComboBox];

    // Obtém os Controles do Campo
    aControls := IGGetControls(sField, aAllowedTypes);
    for cControl in aControls do
    begin
      if not Assigned(cControl) then
        Continue;

      // Se herda de Extend.DBCtrls.TDBEdit
      if cControl.InheritsFrom(Extend.DBCtrls.TDBEdit) then
        AddToResult(Extend.DBCtrls.TDBEdit(cControl).Highlight(cColor, cBorder))
      else
      // Se herda de Extend.DBCtrls.TDBCheckBox
      if cControl.InheritsFrom(Extend.DBCtrls.TDBCheckBox) then
        AddToResult(Extend.DBCtrls.TDBCheckBox(cControl).Highlight(cBorder))
      else // Se herda de Extend.DBCtrls.TDBLookupComboBox
      if cControl.InheritsFrom(Extend.DBCtrls.TDBLookupComboBox) then
        AddToResult(Extend.DBCtrls.TDBLookupComboBox(cControl).Highlight)
      else // Se herda de Extend.DBGrids.TDBGrid
      if cControl.InheritsFrom(Extend.DBGrids.TDBGrid) then
        AddToResult(Extend.DBGrids.TDBGrid(cControl).Highlight);
    end;
  end;
end;

function TIGDataSet.IGHighlightControls<T>(sFields: String = ''; cColor: TColor = clWebPink; cBorder: TColor = clRed): TArray<IInterface>;
begin
  Result := IGHighlightControls(sFields, [GetClassFromType(TypeInfo(T))], cColor, cBorder);
end;

function TIGDataSet.IGHighlightControls(sFields, sClasses: String; cColor: TColor = clWebPink; cBorder: TColor = clRed): TArray<IInterface>;
begin
  Result := IGHighlightControls(sFields, GetClassByName(sClasses), cColor, cBorder);
end;
*)

//procedure TIGDataSet.IGSetRequired(sFields: String; bRequired: Boolean);
////var
////  cControl: TObject;
////  cCtrl: TControl;
////  sField: String;
////  I: Integer;
//begin
////  if sFields.CountChar(',') > 0 then
////  begin
////    for sField in sFields.Split([',']) do
////      IGSetRequired(sField, bRequired);
////    Exit;
////  end;
////  sField := sFields;
////
////  IGGetField(sField).Required := bRequired;
////
////  for cControl in IGGetControls(sField, [Extend.DBCtrls.TDBEdit, Extend.DBCtrls.TDBLookupComboBox]) do
////  begin
////    if not Assigned(cControl) then
////      Continue;
////
////    for I := 0 to Pred(TCustomControl(cControl).Parent.ControlCount) do
////    begin
////      cCtrl := TCustomControl(cControl).Parent.Controls[I];
////
////      if (cCtrl is TLabel) and (TLabel(cCtrl).FocusControl = cControl) then
////      begin
////        if bRequired then
////          TLabel(cCtrl).Font.Style := [TFontStyle.fsBold]
////        else
////          TLabel(cCtrl).Font.Style := [];
////        Break;
////      end;
////    end;
////  end;
//end;

//procedure TIGDataSet.IGRaise(sMessage: String; sHighlightFields: String = ''; sFieldControl: String = ''; aAllowedTypes: TArray<TClass> = []);
//begin
////  if not sFieldControl.Trim.IsEmpty and (Length(aAllowedTypes) = 0) then
////    aAllowedTypes := [Extend.DBCtrls.TDBEdit, Extend.DBCtrls.TDBCheckBox, Extend.DBCtrls.TDBLookupComboBox];
////
////  try
////    IGHighlightControls(sHighlightFields);
////    IGMsgRaiseControl(sMessage, TWinControl(IGGetControl(sFieldControl, aAllowedTypes)));
////  finally
////  end;
//end;

//function TIGDataSet.IGCalculaExpressao(sExpressao: String): Double;
////var
////  fField: TField;
//begin
////  {
////    Daniel Araujo - 28/11/2019
////      Substitui os nomes de campos pelo valor do campo e executa a expressão utilizando o IGCalculadora.TCalculadora
////      Obs.: Utiliza TRegEx para encontrar campos com precisão, e não substituir campos pela metade;
////        Ex.: C000_CAMPO1_DESC seria substituído por C000_CAMPO1
////  }
////  for fField in Fields do
////    if TRegEx.IsMatch(sExpressao, '\b'+fField.FieldName+'\b', [roIgnoreCase]) then
////      if fField.AsString.Trim.IsEmpty then
////        sExpressao := TRegEx.Replace(sExpressao, '\b'+fField.FieldName+'\b', '0', [roIgnoreCase])
////      else
////        sExpressao := TRegEx.Replace(sExpressao, '\b'+fField.FieldName+'\b', fField.AsString, [roIgnoreCase]);
////
////  Result := TCalculadora.CalculaExpressao(sExpressao);
//end;

function TIGDataSet.IGAllIsEmpty(sFields: String = ''): Boolean;
var
  aFields: TStringDynArray;
  sField : String;
  Field  : TField;
begin
  { Parametros:
      Recebe uma string delimitada por virgula, com o nome dos fields
      a serem validados, se não for informado nada, valida pelos
      provider flags que estiverem marcados como pfInWhere
    Retorno:
      Retorna true se todos os fields estiverem vazios }

  // Inicializa
  Result := True;

  // Se não foi informados os campos, valida pelos ProviderFlags
  if sFields.Trim.IsEmpty then
    for Field in Self.Fields do
      if pfInWhere in Field.ProviderFlags then
        sFields := IfThen(not sFields.IsEmpty, sFields +',') + Field.FieldName;

  // Valida se há algum field para ser validado
  if sFields.IsEmpty then
    raise Exception.Create('Nenhum campo informado para validação!');

  // Obtem os fields
  aFields := SplitString(sFields,',');

  // Passa por todos os fields validando se está vazio
  for sField in aFields do
    if not Self.IGFieldIsEmpty(sField) then
      Exit(False);
end;

function TIGDataSet.IGMatchStr(sFieldName, sValues: String): Boolean;
begin
  Result := IGMatchStr(sFieldName, SplitString(sValues, ','));
end;

function TIGDataSet.IGMatchStr(const sFieldName: string; const AValues: Array of String): Boolean;
begin
  Result := MatchStr(IGGetStr(sFieldName), AValues);
end;

function TIGDataSet.IGMatchValue(sFieldName: String; Values: TArray<String>): Boolean;
begin
  Result := IGGetField(sFieldName).IGMatchValue(Values);
end;

function TIGDataSet.IGMatchValue(sFieldName: String; Values: TArray<Integer>): Boolean;
begin
  Result := IGGetField(sFieldName).IGMatchValue(Values);
end;

function TIGDataSet.IGMatchValue(sFieldName: String; Values: TArray<Double>): Boolean;
begin
  Result := IGGetField(sFieldName).IGMatchValue(Values);
end;

function TIGDataSet.IGMatchValue(sFieldName: String; Values: TArray<Extended>): Boolean;
begin
  Result := IGGetField(sFieldName).IGMatchValue(Values);
end;

function TIGDataSet.IGMatchValue(sFieldName: String; Values: TArray<TDate>): Boolean;
begin
  Result := IGGetField(sFieldName).IGMatchValue(Values);
end;

function TIGDataSet.IGMatchValue(sFieldName: String; Values: TArray<TDateTime>): Boolean;
begin
  Result := IGGetField(sFieldName).IGMatchValue(Values);
end;

function TIGDataSet.IGMatchValue(sFieldName: String; Values: TArray<Boolean>): Boolean;
begin
  Result := IGGetField(sFieldName).IGMatchValue(Values);
end;

function TIGDataSet.IGIndexOf(sFieldName: String; Values: TArray<String>): Integer;
begin
  Result := IGGetField(sFieldName).IGIndexOf(Values);
end;

function TIGDataSet.IGIndexOf(sFieldName: String; Values: TArray<Integer>): Integer;
begin
  Result := IGGetField(sFieldName).IGIndexOf(Values);
end;

function TIGDataSet.IGIndexOf(sFieldName: String; Values: TArray<Double>): Integer;
begin
  Result := IGGetField(sFieldName).IGIndexOf(Values);
end;

function TIGDataSet.IGIndexOf(sFieldName: String; Values: TArray<Extended>): Integer;
begin
  Result := IGGetField(sFieldName).IGIndexOf(Values);
end;

function TIGDataSet.IGIndexOf(sFieldName: String; Values: TArray<TDate>): Integer;
begin
  Result := IGGetField(sFieldName).IGIndexOf(Values);
end;

function TIGDataSet.IGIndexOf(sFieldName: String; Values: TArray<TDateTime>): Integer;
begin
  Result := IGGetField(sFieldName).IGIndexOf(Values);
end;

function TIGDataSet.IGIndexOf(sFieldName: String; Values: TArray<Boolean>): Integer;
begin
  Result := IGGetField(sFieldName).IGIndexOf(Values);
end;

function TIGDataSet.IGOneIsEmpty(sFields: String = ''): Boolean;
var
  aFields: TStringDynArray;
  sField : String;
  Field  : TField;
begin
  { Parametros:
      Recebe uma string delimitada por virgula, com o nome dos fields
      a serem validados, se não for informado nada, valida todos
      campos do ClientDataSet
    Retorno:
      Retorna true se algum fields estiver vazios }

  // Inicializa
  Result := False;
 
  // Se não foi informados os campos, valida por todos
  if sFields.Trim.IsEmpty then
    for Field in Self.Fields do
      sFields := IfThen(not sFields.IsEmpty, sFields +',') + Field.FieldName;

  // Obtem os fields
  aFields := SplitString(sFields,',');
  
  // Passa por todos os fields validando se está vazio
  for sField in aFields do
    if Self.IGFieldIsEmpty(sField) then
      Exit(True);
end;

procedure TIGDataSet.ConfigRequired(aString: Array of String);
var
  fField: TField;
begin
  for fField in Fields do
    fField.Required := MatchStr(fField.FieldName, aString)
end;

procedure TIGDataSet.Required(sFields: String = '');
  function RequieredFieldsToStringArray: TArray<string>;
  var
    I: Integer;
  begin
    for I := 0 to Pred(Self.Fields.Count) do
      if Self.Fields[i].Required then
        TArray.Add<String>(Result, Self.Fields[I].FieldName);
  end;
begin
  if sFields.IsEmpty then
    Required(RequieredFieldsToStringArray)
  else
    Required(sFields.Replace(';',',').Split([',']));
end;

procedure TIGDataSet.Required(sFields: TArray<String>);
var
  slDescricao: TStringList;
  sField: String;
  sFieldContros: String;
begin
  slDescricao := TStringList.Create;
  try
    for sField in sFields do
    begin
      if Self.IGFieldIsEmpty(sField) then
      begin
        sFieldContros := sFieldContros + IfThen(not sFieldContros.Trim.IsEmpty, ',') + sField;
        {$IFDEF MSWINDOWS}
        slDescricao.Add('- '+ IGGetField(sField).IGGetLabel);
        {$ELSE}
        slDescricao.Add('- '+ IGGetField(sField).DisplayText);
        {$ENDIF}
      end;
    end;

    if sFieldContros.Trim.IsEmpty then
      Exit;

    {$IFDEF MSWINDOWS}
//    IGHighlightControls(sFieldContros);
//    IGMsgDetalhe('Aviso do Sistema', 'Campos obrigatórios não preenchidos!', slDescricao.Text, MsgWarning, True);
//    raise EAbort.Create('');
    {$ELSE}
    raise Exception.Create('Campos obrigatórios não preenchidos!');
    {$ENDIF}
  finally
    FreeAndNil(slDescricao);
  end;
end;

procedure TIGDataSet.ToJSONArray(var aResult: TJSONArray);
Var
  oRecord: TJSONObject;
  myField: TField;
begin
  Self.First;
  while Not(Self.Eof) do
  begin
    oRecord := TJSONObject.Create;

    // Adicionar os dados das colunas da linha no JSON
    for myField in Self.Fields do
    begin
      // Definir se vai ser número ou string
      case myField.DataType of
        // Numerico
        ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD, ftLargeint,
        ftFMTBcd, ftLongWord, ftShortint, TFieldType.ftExtended:
        begin
          oRecord.AddPair(myField.FieldName, TJSONNumber.Create(myField.AsFloat));
        end;
      else
        // string
        oRecord.AddPair(myField.FieldName, TJSONString.Create(myField.AsString));
      end;
    end;

    // Add a linha no array
    aResult.AddElement(oRecord);

    Self.Next;
  end;
end;

function TIGDataSet.ToJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  ToJSONObject(Result);
end;

procedure TIGDataSet.ToJSONObject(var oResult: TJSONObject);
begin
  for var Field in Self.Fields do
    if Field.IsNull then
      oResult.AddPair(Field.FieldName, TJSONNull.Create)
    else
    if Field.InheritsFrom(TNumericField) then
      oResult.AddPair(Field.FieldName, Field.AsExtended)
    else
    if Field.InheritsFrom(TDateTimeField) or Field.InheritsFrom(TSQLTimeStampField) then
      oResult.AddPair(Field.FieldName, DateToISO8601(Field.AsDateTime))
    else
    if Field.InheritsFrom(TBooleanField) then
      oResult.AddPair(Field.FieldName, Field.AsBoolean)
    else
      oResult.AddPair(Field.FieldName, Field.AsString);
end;

function TIGDataSet.IGGetField(sFieldName: string): TField;
var
  sInfoCds: string;
begin
  // Verifica se campo existe no cds, se nao existir, mostra IGMsgRaise

  // Tenta encontrar o Campo
  Result:= Self.FindField(sFieldName);

  // Se encontrou o campo sai fora do procedimento
  if Assigned(Result) then
    Exit;

  // Informacoes do cds "cdsT001.IGGetField('IG_RECNO')"
  sInfoCds:= Self.Name +'.IGGetField('+ Qt(sFieldName) +')';

  // Informacoes do Controller
  if Assigned(Self.Owner) then
    // TCL0000A.cdsT001.IGGetField('IG_RECNO')
    sInfoCds := Self.Owner.ClassName +'.'+ sInfoCds;

  // Exibe o Raise
  raise Exception.Create('Campo "'+ sFieldName +'" não encontrado!'+ sl2 + sInfoCds);
end;

function TIGDataSet.IGGetStr(sFieldName: string): string;
begin
  // Retorna Valor String do Campo passado por parametro
  Result:= IGGetField(sFieldName).AsString;
end;

function TIGDataSet.IGGetStrQt(sFieldName: string): string;
begin
  Result := Qt(Self.IGGetStr(sFieldName));
end;

function TIGDataSet.IGGetFormat(const sExpressao: String): String;
begin
  Result := sExpressao;
  for var Field in Fields do
    if TRegEx.IsMatch(Result, '\b'+ Field.FieldName +'\b', []) then
      Result := TRegEx.Replace(Result, '\b'+ Field.FieldName +'\b', Field.DisplayText, []);
end;

function TIGDataSet.IGIndexStr(const sFieldName: string; const AValues: array of string): Integer;
begin
  Result := IndexStr(IGGetStr(sFieldName), AValues);
end;

function TIGDataSet.IGGetInt(sFieldName: string): Integer;
begin
  // Retorna Valor Integer do Campo passado por parametro
  if IGGetField(sFieldName) is TAggregateField then
    Result := StrToIntDef(IGGetStr(sFieldName), 0)
  else
    Result := IGGetField(sFieldName).AsInteger;
end;

function TIGDataSet.IGGetFloat(sFieldName: string): Double;
begin
  // Retorna Valor Float do Campo passado por parametro
  if IGGetField(sFieldName) is TAggregateField then
    Result := StrToFloatDef(IGGetStr(sFieldName), 0)
  else
    Result := IGGetField(sFieldName).AsFloat;
end;

function TIGDataSet.IGGetFloatRound(sFieldName: string; iDigits: Integer = 2): Double;
begin
  // Retorna valor float arredondado do campo passado por parametro
  Result := SimpleRoundTo(IGGetFloat(sFieldName), -iDigits);
end;

function TIGDataSet.IGGetExtended(sFieldName: string): Extended;
begin
  // Retorna Valor Extended do Campo passado por parametro
  Result := IGGetField(sFieldName).AsExtended;
end;

function TIGDataSet.IGGetDate(sFieldName: string): TDate;
begin
  // Retorna Valor TDate do Campo passado por parametro
  Result := Trunc(IGGetField(sFieldName).AsDateTime);
end;

function TIGDataSet.IGGetDateSql(sFieldName: string): string;
begin
  // Se o field não estiver vazio, retorna valor string do campo passado por parametro, formatado para consulta sql
  if not IGGetField(sFieldName).IsNull then
    DateTimeToString(Result, 'yyyy-mm-dd', IGGetField(sFieldName).AsDateTime);
end;

function TIGDataSet.IGGetDateTime(sFieldName: string): TDateTime;
begin
  // Retorna Valor TDateTime do Campo passado por parametro
  Result := IGGetField(sFieldName).AsDateTime;
end;

function TIGDataSet.IGGetDateTimeSql(sFieldName: string): string;
begin
  // Se o field não estiver vazio, retorna valor string do campo passado por parametro, formatado para consulta sql
  if not IGGetField(sFieldName).IsNull then
    DateTimeToString(Result, 'yyyy-mm-dd hh:mm:ss.zzz', IGGetField(sFieldName).AsDateTime);
end;

function TIGDataSet.IGGetBoolean(sFieldName: string): Boolean;
begin
  Result := IGGetField(sFieldName).AsBoolean;
end;

function TIGDataSet.IGGetJSONPair(sFieldName: String): TJSONPair;
begin
  if IGGetField(sFieldName).IsNull then
    Result := TJSONPair.Create(sFieldName, TJSONNull.Create)
  else
  if IGGetField(sFieldName) is TNumericField then
    Result := TJSONPair.Create(sFieldName, TJSONNumber.Create(IGGetFloat(sFieldName)))
  else
  if (IGGetField(sFieldName) is TDateTimeField) or (IGGetField(sFieldName) is TSQLTimeStampField) then
    Result := TJSONPair.Create(sFieldName, TJSONString.Create(IGGetDateTimeSql(sFieldName)))
  else
    Result := TJSONPair.Create(sFieldName, TJSONString.Create(IGGetStr(sFieldName)));
end;

function TIGDataSet.IGGetJSONValue(sFieldName: String): TJSONValue;
begin
  if IGGetField(sFieldName).IsNull then
    Result := TJSONNull.Create
  else
  if IGGetField(sFieldName) is TNumericField then
    Result := TJSONNumber.Create(IGGetFloat(sFieldName))
  else
  if (IGGetField(sFieldName) is TDateTimeField) or (IGGetField(sFieldName) is TSQLTimeStampField) then
  begin
    if IGGetDateTime(sFieldName) = 0 then
      Result := TJSONNull.Create
    else
      Result := TJSONString.Create(IGGetDateTimeSql(sFieldName))
  end
  else
    Result := TJSONString.Create(IGGetStr(sFieldName));
end;

function TIGDataSet.IGGetRecord(sFields: String): TJSONObject;
  function FieldsToStringArray: TArray<string>;
  var
    I: Integer;
  begin
    for I := 0 to Pred(Self.Fields.Count) do
        TArray.Add<String>(Result, Self.Fields[I].FieldName);
  end;
begin
  if sFields.IsEmpty then
    Result := IGGetRecord(FieldsToStringArray)
  else
    Result := IGGetRecord(sFields.Replace(';',',').Split([',']));
end;

function TIGDataSet.IGGetRecord(sFields: TArray<String>): TJSONObject;
var
  sField: String;
begin
  Result := TJSONObject.Create;

  for sField in sFields do
  begin
    if Self.IGFieldNotIsEmpty(sField) then
    begin
      // Definir se vai ser número ou string
      case Self.IGGetField(sField).DataType of
        // Numerico
        ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD, ftLargeint,
        ftFMTBcd, ftLongWord, ftShortint, TFieldType.ftExtended:
        begin
          Result.AddPair(sField, TJSONNumber.Create(Self.IGGetFloat(sField)));
        end;
      else
        // string
        Result.AddPair(sField, Self.IGGetStr(sField));
      end;
    end
    else
      Result.AddPair(sField, Self.IGGetStr(sField));
  end;
end;

function TIGDataSet.IGGetSplit(sFieldName: String; Separator: Char = ','): TArray<String>;
begin
  Result := IGGetStr(sFieldName).Split([Separator]);
end;

function TIGDataSet.IGGetSplit<T>(sFieldName: String; Separator: Char = ','): TArray<T>;
begin
  Result := TArray.Cast<String, T>(IGGetStr(sFieldName).Split([Separator]));
end;

function TIGDataSet.IGFieldIsEmpty(sFieldName: string): Boolean;
begin
  if IGGetField(sFieldName) is TStringField then
    Result := IGGetField(sFieldName).AsString.Trim.IsEmpty
  else
    Result := IGGetField(sFieldName).IsNull;
end;

function TIGDataSet.IGFieldNotIsEmpty(sFieldName: string): Boolean;
begin
  Result := not IGFieldIsEmpty(sFieldName);
end;

function TIGDataSet.IGFind(Prc: TFunc<Boolean>): TDataSet;
begin
  Result := Self;
  Self.First;
  while not Self.Eof do
  begin
    if Prc then
      Break;
    Self.Next;
  end;
end;

function TIGDataSet.IGGetLink(sFields: String): String;
var
  Item: String;
  Par: TArray<String>;
  Field: TField;
begin
  // Exemplo: <campo do cds de parâmetro>=<campo do dataset da listagem>&...
  // CODEMP=C0XL_CODEMP&CODIGO=IG_RECNO
  Result := EmptyStr;

  if Self.IsEmpty then
    Exit;

  for Item in sFields.Split(['&']) do
  begin
    Par := Item.Split(['=']);
    Field := Self.FindField(Par[1]);

    if not Assigned(Field) then
      Continue;

    if Field.InheritsFrom(TNumericField) then
      Include(Result, Par[0] +'='+ FloatToStr(Field.AsExtended), '&')
    else
    if Field.InheritsFrom(TDateTimeField) or Field.InheritsFrom(TSQLTimeStampField) then
      Include(Result, Par[0] +'='+ DateToISO8601(Field.AsDateTime), '&')
    else
    if Field.InheritsFrom(TBooleanField) then
      Include(Result, Par[0] +'='+ BoolToStr(Field.AsBoolean, True), '&')
    else
      Include(Result, Par[0] +'='+ Field.AsString, '&')
  end;

  if not Result.IsEmpty then
    Result := '?'+ Result;
end;

procedure TIGDataSet.IGSetLink(sLink: String);
var
  Item: String;
  Par: TArray<String>;
  Field: TField;
begin
  // Exemplo: <campo do cds de parâmetro>=<valor>&...
  // CODEMP=MTZ&CODIGO=4
  for Item in sLink.Split(['&']) do
  begin
    Par := Item.Split(['=']);
    Field := Self.FindField(Par[0]);

    if not Assigned(Field) then
      Continue;

    if Field.InheritsFrom(TNumericField) then
      Field.AsExtended := StrToFloat(Par[1])
    else
    if Field.InheritsFrom(TDateTimeField) or Field.InheritsFrom(TSQLTimeStampField) then
      Field.AsDateTime := ISO8601ToDate(Par[1])
    else
    if Field.InheritsFrom(TBooleanField) then
      Field.AsBoolean := StrToBool(Par[1])
    else
      Field.AsString := Par[1];
  end;
end;

function TIGDataSet.IGChanged(sFieldName: string): Boolean;
begin
  Result := IGGetField(sFieldName).IGChanged;
end;

procedure TIGDataSet.IGClearField(sFieldName: string);
begin
  IGGetField(sFieldName).Clear;
end;

procedure TIGDataSet.IGClearFields(sFieldsNames: String);
begin
  if not sFieldsNames.Trim.IsEmpty then
    for sFieldsNames in SplitString(sFieldsNames, ',') do
      IGClearField(sFieldsNames.Trim);
end;

procedure TIGDataSet.IGSetValue(sFieldName, Value: String);
begin
  // Atribui o Valor no Campo informado no parametro
  IGGetField(sFieldName).AsString := Value;
end;

procedure TIGDataSet.IGSetValue(sFieldName: String; Value: Integer);
begin
  // Atribui o Valor no Campo informado no parametro
  IGGetField(sFieldName).AsInteger := Value;
end;

procedure TIGDataSet.IGSetValue(sFieldName: String; Value: Double);
begin
  // Atribui o Valor no Campo informado no parametro
  IGGetField(sFieldName).AsFloat := Value;
end;

procedure TIGDataSet.IGSetValue(sFieldName: String; Value: Extended);
begin
  // Atribui o Valor no Campo informado no parametro
  IGGetField(sFieldName).AsExtended := Value;
end;

procedure TIGDataSet.IGSetValue(sFieldName: String; Value: TDate; Options: TDateTimeOptions = [TDateTimeOption.ClearFieldIfZero]);
begin
  // Se informou uma data zerada
  if Value = 0 then
  begin
    // Está definido para Não alterar o valor do campo
    if TDateTimeOption.NotChangeIfZero in Options then
      Exit;

    // Está definido para Limpar o campo
    if TDateTimeOption.ClearFieldIfZero in Options then
    begin
      IGClearField(sFieldName);
      Exit;
    end;
  end;

  // Atribui o Valor no Campo informado no parametro
  IGGetField(sFieldName).AsDateTime := Value;
end;

procedure TIGDataSet.IGSetValue(sFieldName: String; Value: TDateTime; Options: TDateTimeOptions = [TDateTimeOption.ClearFieldIfZero]);
begin
  // Se informou uma data zerada
  if Value = 0 then
  begin
    // Está definido para Não alterar o valor do campo
    if TDateTimeOption.NotChangeIfZero in Options then
      Exit;

    // Está definido para Limpar o campo
    if TDateTimeOption.ClearFieldIfZero in Options then
    begin
      IGClearField(sFieldName);
      Exit;
    end;
  end;

  // Atribui o Valor no Campo informado no parametro
  IGGetField(sFieldName).AsDateTime := Value;
end;

procedure TIGDataSet.IGSetValue(sFieldName: String; Value: Boolean);
begin
  // Atribui o Valor no Campo informado no parametro
  IGGetField(sFieldName).AsBoolean := Value;
end;

procedure TIGDataSet.IGSetValue(sFieldName: String; Value: TStream);
var
  fField: TField;
begin
  fField := IGGetField(sFieldName);
  if fField.InheritsFrom(TBlobField) then
    TBlobField(fField).LoadFromStream(Value)
  else
  if fField.InheritsFrom(TStringField) then
    TStringField(Value).AsString := TStringStream(Value).DataString
  else
    raise Exception.Create('Tipo de campo não suportado!');
end;

function TIGDataSet.IGSameValue(sFieldName, Value: String): Boolean;
begin
  Result := IGGetStr(sFieldName).Equals(Value);
end;

function TIGDataSet.IGSameValue(sFieldName: String; Value: Integer; Options: TSameValueOptions = []): Boolean;
begin
  // Se é para considerar vazio igual ao valor informado
  if (TSameValueOption.EmtpyEquals in Options) and IGFieldIsEmpty(sFieldName) then
    Exit(True);

  Result := IGFieldNotIsEmpty(sFieldName) and (IGGetField(sFieldName).AsExtended = Value);
end;

function TIGDataSet.IGSameValue(sFieldName: String; Value: Double; Options: TSameValueOptions = []): Boolean;
begin
  // Se é para considerar vazio igual ao valor informado
  if (TSameValueOption.EmtpyEquals in Options) and IGFieldIsEmpty(sFieldName) then
    Exit(True);

  Result := IGFieldNotIsEmpty(sFieldName) and (IGGetField(sFieldName).AsExtended = Value);
end;

function TIGDataSet.IGSameValue(sFieldName: String; Value: Extended; Options: TSameValueOptions = []): Boolean;
begin
  // Se é para considerar vazio igual ao valor informado
  if (TSameValueOption.EmtpyEquals in Options) and IGFieldIsEmpty(sFieldName) then
    Exit(True);

  Result := IGFieldNotIsEmpty(sFieldName) and (IGGetField(sFieldName).AsExtended = Value);
end;

function TIGDataSet.IGSameValue(sFieldName: String; Value: TDate; Options: TSameValueOptions = []): Boolean;
begin
  // Se é para considerar vazio igual ao valor informado
  if (TSameValueOption.EmtpyEquals in Options) and IGFieldIsEmpty(sFieldName) then
    Exit(True);

  Result := IGGetField(sFieldName).AsDateTime = Value;
end;

function TIGDataSet.IGSameValue(sFieldName: String; Value: TDateTime; Options: TSameValueOptions = []): Boolean;
begin
  // Se é para considerar vazio igual ao valor informado
  if (TSameValueOption.EmtpyEquals in Options) and IGFieldIsEmpty(sFieldName) then
    Exit(True);

  Result := IGGetField(sFieldName).AsDateTime = Value;
end;

function TIGDataSet.IGSameValue(sFieldName: String; Value: Boolean; Options: TSameValueOptions = []): Boolean;
begin
  // Se é para considerar vazio igual ao valor informado
  if (TSameValueOption.EmtpyEquals in Options) and IGFieldIsEmpty(sFieldName) then
    Exit(True);

  Result := IGGetField(sFieldName).AsBoolean = Value;
end;

function TIGDataSet.IGInc(sFieldName: String; dValue: Double = 1): Double;
begin
  // Atribui o valor no campo informado no parametro
  Result := IGGetFloat(sFieldName) + dValue;
  IGSetValue(sFieldName, Result);
end;

function TIGDataSet.IGDec(sFieldName: String; dValue: Double = 1): Double;
begin
  Result := IGInc(sFieldName, - dValue);
end;

function TIGDataSet.IGContains(sFieldName, Value: string): Boolean;
begin
  Result := Value.Contains(IGGetStr(sFieldName));
end;

procedure TIGDataSet.IGSetProperty(saFields, sProperty: String; vValue: TValue);
begin
  IGSetProperty(saFields, sProperty, [vValue]);
end;

procedure TIGDataSet.IGSetProperty(saFields, saProperty: String; vaValue: Array of TValue);
var 
  I        : Integer;
  fields   : TStringDynArray;
  props    : TStringDynArray;
  field    : String;
  ctxRtti  : TRttiContext;
  typeRtti : TRttiType;
  propRtti : TRttiProperty;
begin
  fields := SplitString(saFields,   ';');
  props  := SplitString(saProperty, ';');
  for field in fields do
  begin
    ctxRtti := TRttiContext.Create;
    try
      typeRtti := ctxRtti.GetType(Self.IGGetField(field).ClassType);
      for I := 0 to High(props) do
      begin
        propRtti := typeRtti.GetProperty(props[I]);
        if Assigned(propRtti) then
          propRtti.SetValue(Self.IGGetField(field), vaValue[I]);
      end;
    finally
      ctxRtti.Free;  
    end;
  end;                  
end;

function TIGDataSet.IGStateIn(dsStates: TDataSetStates): Boolean;
begin
  Result := State in dsStates;
end;

function TIGDataSet.IGSmartDisableControls: IIGDataSetSmartAction;
begin
  Result := TIGSmartDisableControls.New(Self);
end;

function TIGDataSet.IGSmartBookmark: IIGDataSetSmartAction;
begin
  Result := TIGSmartBookmark.New(Self);
end;

function TIGDataSet.IGSmartFilter(sFilter: String = ''): IIGDataSetSmartAction;
begin
  Result := TIGSmartFilter.New(Self, sFilter);
end;

function TIGDataSet.IGSmartGotoRecno: IIGDataSetSmartAction;
begin
  Result := TIGSmartGotoRecno.New(Self);
end;

function TIGDataSet.IGSmartSaveValue(sFieldKey, sFieldValue: String): IIGDataSetSmartAction;
begin
  Result := TIGSmartSaveValue.New(Self, sFieldKey, sFieldValue);
end;

function TIGDataSet.IGSmartOrderBy(saFields: array of string): IIGDataSetSmartAction;
begin
  if not Self.InheritsFrom(TClientDataSet) then
    raise Exception.Create('Classe "'+ Self.ClassName +'" não tem suporte para OrderBy!');

  Result := TIGSmartOrderBy.New(TClientDataSet(Self), saFields);
end;

{ TIGFDQuery }

procedure TIGFDQuery.IGOrderBy(pFieldName: String);
var
  FieldName : String;
  bOption   : Boolean;
  AIndex    : TFDIndex;
begin
  //Inicializa as variaveis
  FieldName := pFieldName + '_ASC';
  bOption := False;

  // Verifica se ja existe alguma ordenação
  if Self.Indexes.Count > 0 then
  begin
    // Verifica se o campo a ser ordenado ja foi ordenado
    if Self.Indexes.Items[0].Fields.Equals(pFieldName) then
    begin
      // Verifica se o campo ja foi ordenado em ordem crescente
      if Self.Indexes.Items[0].Name.Equals(pFieldName + '_ASC') then
      begin
        FieldName := pFieldName + '_DESC';
        bOption := True;
      end;
    end;
    Self.Indexes.Delete(0);
  end;

  //Define a ordenação
  AIndex := Self.Indexes.Add;
  with AIndex do
  begin
    Name   := FieldName;
    Fields := pFieldName;
    Active := True;

    if bOption then
      Fields := Fields + ':D';

  end;

  //Ordena
  Self.IndexName := FieldName;
end;

procedure TIGFDQuery.IGFilter(sFilter: String);
begin
  Self.Filtered := False;
  if sFilter.Trim.IsEmpty then
    Exit;
  Self.Filter   := sFilter;
  Self.Filtered := True;
end;

procedure TIGFDQuery.IGMarcarTodosRegistros(slSelecao : TslSelecao; sField: String);
begin
  if RecordCount = 0 then
    Exit;

  try
    DisableControls;

    // Passar por todos os registros do dataset
    First;
    while not Eof do
    begin
      Edit;

      // Marcar ou desmarcar todos os registros
      case slSelecao of
        slMarcar    : FieldByName(sField).AsString := 'S';
        slDesmarcar : FieldByName(sField).AsString := 'N';
        slInverter  : FieldByName(sField).AsString := IfThen(FieldByName(sField).AsString.Equals('S'),'N','S');
      end;

      // Proximo registro
      Next;
    end;

  finally
    First;
    EnableControls;
  end;
end;

{ TIGFDMemTable }

procedure TIGFDMemTable.IGOrderBy(pFieldName: String);
var
  FieldName : String;
  bOption   : Boolean;
  AIndex    : TFDIndex;
begin
  //Inicializa as variaveis
  FieldName := pFieldName + '_ASC';
  bOption := False;

  // Verifica se ja existe alguma ordenação
  if Self.Indexes.Count > 0 then
  begin
    // Verifica se o campo a ser ordenado ja foi ordenado
    if Self.Indexes.Items[0].Fields.Equals(pFieldName) then
    begin
      // Verifica se o campo ja foi ordenado em ordem crescente
      if Self.Indexes.Items[0].Name.Equals(pFieldName + '_ASC') then
      begin
        FieldName := pFieldName + '_DESC';
        bOption := True;
      end;
    end;
    Self.Indexes.Delete(0);
  end;

  //Define a ordenação
  AIndex := Self.Indexes.Add;
  with AIndex do
  begin
    Name   := FieldName;
    Fields := pFieldName;
    Active := True;

    if bOption then
      Fields := Fields + ':D';

  end;

  //Ordena
  Self.IndexName := FieldName;
end;

{ TFDDataSet }

procedure TIGFDDataSet.IGOrderBy(pFieldName: String);
var
  FieldName : String;
  bOption   : Boolean;
  AIndex    : TFDIndex;
begin
  //Inicializa as variaveis
  FieldName := pFieldName + '_ASC';
  bOption := False;

  // Verifica se ja existe alguma ordenação
  if Self.Indexes.Count > 0 then
  begin
    // Verifica se o campo a ser ordenado ja foi ordenado
    if Self.Indexes.Items[0].Fields.Equals(pFieldName) then
    begin
      // Verifica se o campo ja foi ordenado em ordem crescente
      if Self.Indexes.Items[0].Name.Equals(pFieldName + '_ASC') then
      begin
        FieldName := pFieldName + '_DESC';
        bOption := True;
      end;
    end;
    Self.Indexes.Delete(0);
  end;

  //Define a ordenação
  AIndex := Self.Indexes.Add;
  with AIndex do
  begin
    Name   := FieldName;
    Fields := pFieldName;
    Active := True;
    if bOption then
      Fields := Fields + ':D';
  end;

  //Ordena
  Self.IndexName := FieldName;
end;

{$WARN GARBAGE OFF}

{ TIGDataSet.TIGSmartDisableControls }

class function TIGDataSet.TIGSmartDisableControls.New(DataSet: TDataSet): IIGDataSetSmartAction;
begin
  Result := TIGDataSet.TIGSmartDisableControls.Create(DataSet);
end;

constructor TIGDataSet.TIGSmartDisableControls.Create(DataSet: TDataSet);
begin
  FDataSet := DataSet;
  FDataSet.DisableControls;
end;

destructor TIGDataSet.TIGSmartDisableControls.Destroy;
begin
  FDataSet.EnableControls;
  FDataSet := nil;
  inherited;
end;

{ TIGDataSet.TIGSmartBookmark }

class function TIGDataSet.TIGSmartBookmark.New(DataSet: TDataSet): IIGDataSetSmartAction;
begin
  Result := TIGDataSet.TIGSmartBookmark.Create(DataSet);
end;

constructor TIGDataSet.TIGSmartBookmark.Create(DataSet: TDataSet);
begin
  FDataSet  := DataSet;
  FBookmark := FDataSet.Bookmark;
end;

destructor TIGDataSet.TIGSmartBookmark.Destroy;
begin
  if FDataSet.BookmarkValid(FBookmark) then
    FDataSet.GotoBookmark(FBookmark);

  FDataSet  := nil;
  inherited;
end;

{ TIGDataSet.TIGSmartGotoRecno }

class function TIGDataSet.TIGSmartGotoRecno.New(DataSet: TDataSet): IIGDataSetSmartAction;
begin
  Result := TIGDataSet.TIGSmartGotoRecno.Create(DataSet);
end;

constructor TIGDataSet.TIGSmartGotoRecno.Create(DataSet: TDataSet);
begin
  FDataSet := DataSet;
  FRecno := 0;
  if FDataSet.Active then
    FRecno := FDataSet.Recno;
end;

destructor TIGDataSet.TIGSmartGotoRecno.Destroy;
begin
  if (FRecno <> 0) and (FRecno <= FDataSet.RecordCount) then
    FDataSet.Recno := FRecno;
  FDataSet := nil;
  inherited;
end;

{ TIGDataSet.TIGSmartFilter }

class function TIGDataSet.TIGSmartFilter.New(DataSet: TDataSet; sFilter: String): IIGDataSetSmartAction;
begin
  Result := TIGDataSet.TIGSmartFilter.Create(DataSet, sFilter);
end;

constructor TIGDataSet.TIGSmartFilter.Create(DataSet: TDataSet; sFilter: String);
begin
  FDataSet := DataSet;
  FBFilter := FDataSet.Filtered;
  FFilter := FDataSet.Filter;
  if sFilter.Trim.IsEmpty then
  begin
    FDataSet.Filtered := False;
    FDataSet.Filter := EmptyStr;
  end
  else
  begin    
    FDataSet.Filter := sFilter;
    FDataSet.Filtered := True;
  end;
end;

destructor TIGDataSet.TIGSmartFilter.Destroy;
begin
  FDataSet.Filter := FFilter;
  FDataSet.Filtered := FBFilter;
  FDataSet := nil;
  inherited;
end;

{ TIGDataSet.TIGSmartSaveValue }

class function TIGDataSet.TIGSmartSaveValue.New(DataSet: TDataSet; sFieldKey, sFieldValue: String): IIGDataSetSmartAction;
begin
  Result := TIGDataSet.TIGSmartSaveValue.Create(DataSet, sFieldKey, sFieldValue);
end;

constructor TIGDataSet.TIGSmartSaveValue.Create(DataSet: TDataSet; sFieldKey, sFieldValue: String);
var
  mark: TBookmark;
begin
  FDataSet := DataSet;
  FFieldKey := sFieldKey;
  FFieldValue := sFieldValue;

  FDataSet.DisableControls;
  mark := FDataSet.GetBookmark;
  try
    FDataSet.First;
    while not FDataSet.Eof do
    begin
      TArray.Add<TPair<Variant, Variant>>(FData, TPair<Variant, Variant>.Create(FDataSet.IGGetField(FFieldKey).Value, FDataSet.IGGetField(FFieldValue).Value));
      FDataSet.Next;
    end;
  finally
    FDataSet.GotoBookmark(mark);
    FDataSet.EnableControls;
  end;
end;

destructor TIGDataSet.TIGSmartSaveValue.Destroy;
var
  mark: TBookmark;
begin
  FDataSet.DisableControls;
  mark := FDataSet.GetBookmark;
  try
    TArray.ForEach<TPair<Variant, Variant>>(
      FData,
      procedure(Item: TPair<Variant, Variant>)
      begin
        if FDataSet.Locate(FFieldKey, Item.Key, []) then
        begin
          FDataSet.Edit;
          FDataSet.IGGetField(FFieldValue).Value := Item.Value;
          FDataSet.Post;
        end;
      end
    );
  finally
    FDataSet.GotoBookmark(mark);
    FDataSet.EnableControls;
  end;
  FDataSet := nil;
  inherited;
end;

{ TIGClientDataSet.TIGGroup }

constructor TIGClientDataSet.TIGGroup.Create(DataSet: TClientDataSet);
begin
  FDataSet := TClientDataSet.Create(nil);
  FDataSet.CloneCursor(DataSet, False);
  FFields := TList<TAgregateField>.Create;
end;

destructor TIGClientDataSet.TIGGroup.Destroy;
begin
  FreeAndNil(FDataSet);
  FreeAndNil(FFields);
  inherited;
end;

function TIGClientDataSet.TIGGroup.By(AFields: TArray<String>): TIGGroup;
begin
  Result := InternalAdd(AFields, TAgregateMethod.SELECT);  
end;

function TIGClientDataSet.TIGGroup.Sum(AFields: TArray<String>): TIGGroup;
begin
  Result := InternalAdd(AFields, TAgregateMethod.SUM);  
end;

function TIGClientDataSet.TIGGroup.Avg(AFields: TArray<String>): TIGGroup;
begin
  Result := InternalAdd(AFields, TAgregateMethod.AVG);  
end;

function TIGClientDataSet.TIGGroup.Max(AFields: TArray<String>): TIGGroup;
begin
  Result := InternalAdd(AFields, TAgregateMethod.MAX);  
end;

function TIGClientDataSet.TIGGroup.Min(AFields: TArray<String>): TIGGroup;
begin
  Result := InternalAdd(AFields, TAgregateMethod.MIN);  
end;

function TIGClientDataSet.TIGGroup.Count(AFields: TArray<String>): TIGGroup;
begin
  Result := InternalAdd(AFields, TAgregateMethod.COUNT);
end;

function TIGClientDataSet.TIGGroup.StringAgg(AFields: TArray<String>; sDiv: String = ','): TIGGroup;
begin
  Result := InternalAdd(AFields, TAgregateMethod.STRING_AGG);
  FDivStringAgg := sDiv;
end;

function TIGClientDataSet.TIGGroup.InternalAdd(AFields: TArray<String>; agMethod: TAgregateMethod): TIGGroup;
var
  Item: String; 
begin
  Result := Self;
  for Item in AFields do
    FFields.Add(TAgregateField.Create(agMethod, Item));
end;

function TIGClientDataSet.TIGGroup.GetKey: String;
var
  Item: TAgregateField; 
begin
  Result := EmptyStr;
  for Item in FFields do
    if Item.Key = TAgregateMethod.SELECT then
      Include(Result, FDataSet.FieldByName(Item.Value).AsString, '|');
end;

procedure TIGClientDataSet.TIGGroup.Ordering;
var
  Item: TAgregateField; 
  sFields: String;
begin
  sFields := EmptyStr;
  for Item in FFields do
    if Item.Key = TAgregateMethod.SELECT then
      Include(sFields, Item.Value, ';');

  FDataSet.IndexDefs.Clear;
  with FDataSet.IndexDefs.AddIndexDef do
  begin
    Sleep(1);
    Name := 'IX_GROUP_'+ FormatDateTime('HHnnsszzz', Now);
    Fields := sFields;
    FDataSet.IndexName := Name;
  end;
end;

function TIGClientDataSet.TIGGroup.CountFields(Method: TAgregateMethod): Integer;
var
  Item: TAgregateField;
begin
  Result := 0;
  for Item in FFields do
    if Item.Key = Method then
      Inc(Result);
end;

function TIGClientDataSet.TIGGroup.Execute: TJSONArray;
var
  aRow: TJSONArray;
  sKey: String;
  sOldKey: String;
  aValores: TArray<TValue>;
  iCount: Integer;
  dTotal: Double;
  dAtual: Double;
  sTemp: String;
  I: Integer;
  bGroup: Boolean;
begin
  try
    // Inicializa retorno
    Result := TJSONArray.Create;

    // Se não tem registros, não faz nada
    if FDataSet.IsEmpty then
      Exit;

    // Ordenação pelos campos do SELECT
    Ordering;

    aRow := nil;
    iCount := 0;

    // Verifica se deve agrupar
    bGroup := CountFields(TAgregateMethod.SELECT) > 0;

    // Se não vai agrupar, cria a unica linha do retorno
    if not bGroup then
    begin
      // Cria a linha
      aRow := TJSONArray.Create;
      Result.AddElement(aRow);

      // Inicializa contador
      iCount := 0;

      // Define o tamanho da lista de valores
      SetLength(aValores, FFields.Count);
    end;

    // Passa por todos os registros
    FDataSet.First;
    while not FDataSet.Eof do
    begin
      // Se tem de agrupar
      if bGroup then
      begin
        // Obtem a chave dos campos SELECT
        sKey := GetKey;

        // Se a chave é diferente da anterior, significa que tem que criar um novo registro para essa chave
        if sOldKey <> sKey then
        begin
          // Se tem itens da ultima chave, adiciona ao retorno
          if Assigned(aRow) then
            for I := 0 to Pred(FFields.Count) do
              if FFields[I].Key in [TAgregateMethod.SUM, TAgregateMethod.AVG, TAgregateMethod.MAX, TAgregateMethod.MIN, TAgregateMethod.COUNT] then
                aRow.Add(aValores[I].AsExtended)
              else
              if FFields[I].Key in [TAgregateMethod.STRING_AGG] then
                aRow.Add(aValores[I].AsString);

          // Limpa lista e armazena a chave atual
          Finalize(aValores);
          iCount := 0;
          sOldKey := sKey;

          // Cria a linha para a chave atual
          aRow := TJSONArray.Create;
          Result.AddElement(aRow);

          // Passa por todos os campos adicionando os fields do SELECT
          for var Item in FFields do
            if Item.Key = TAgregateMethod.SELECT then
              if FDataSet.FieldByName(Item.Value).IsNull then
                aRow.AddElement(TJSONNull.Create)
              else
              if FDataSet.FieldByName(Item.Value) is TNumericField then
                aRow.AddElement(TJSONNumber.Create(FDataSet.FieldByName(Item.Value).AsFloat))
              else
              if not (FDataSet.FieldByName(Item.Value) is TTimeField) and ((FDataSet.FieldByName(Item.Value) is TDateTimeField) or (FDataSet.FieldByName(Item.Value) is TSQLTimeStampField)) then
                aRow.Add(DateToISO8601(FDataSet.FieldByName(Item.Value).AsDateTime))
              else
                aRow.Add(FDataSet.FieldByName(Item.Value).AsString);

          // Define o tamanho da lista de valores
          SetLength(aValores, FFields.Count);
        end;
      end;

      // Incrementa contador de registros
      Inc(iCount);

      // Passa por todos os campos
      for I := 0 to Pred(FFields.Count) do
      begin
        if FFields[I].Key = TAgregateMethod.SELECT then
           Continue;

        // Métodos numericos
        if FFields[I].Key in [TAgregateMethod.SUM, TAgregateMethod.AVG, TAgregateMethod.MAX, TAgregateMethod.MIN, TAgregateMethod.COUNT] then
        begin
          // Obtem o valor armazenado e o atual do campo
          dTotal := aValores[I].AsExtended;
          dAtual := FDataSet.FieldByName(FFields[I].Value).AsFloat;

          // De acordo com o tipo de operação, faz o calculo
          case FFields[I].Key of
            TAgregateMethod.SUM:   dTotal := dTotal + dAtual;
            TAgregateMethod.AVG:   dTotal := ((dTotal * Pred(iCount)) + dAtual) / iCount;
            TAgregateMethod.MAX:   dTotal := IfThen(iCount = 1, dAtual, System.Math.Max(dTotal, dAtual));
            TAgregateMethod.MIN:   dTotal := IfThen(iCount = 1, dAtual, System.Math.Min(dTotal, dAtual));
            TAgregateMethod.COUNT: dTotal := dTotal + 1;
          end;

          // Atualoza o valor armazenado
          aValores[I] := dTotal;
        end
        else // Métodos não numéricos
        if FFields[I].Key in [TAgregateMethod.STRING_AGG] then
        begin
          sTemp := aValores[I].AsString;
          Include(sTemp, FDataSet.FieldByName(FFields[I].Value).AsString, FDivStringAgg);
          aValores[I] := sTemp;
        end;
      end;

      FDataSet.Next;
    end;

    // Se tem itens da ultima chave, adiciona ao retorno
    if Assigned(aRow) then
      for I := 0 to Pred(FFields.Count) do
        if FFields[I].Key in [TAgregateMethod.SUM, TAgregateMethod.AVG, TAgregateMethod.MAX, TAgregateMethod.MIN, TAgregateMethod.COUNT] then
          aRow.Add(aValores[I].AsExtended)
        else
        if FFields[I].Key in [TAgregateMethod.STRING_AGG] then
          aRow.Add(aValores[I].AsString);
  finally
    Self.DisposeOf;
  end;
end;

procedure TIGClientDataSet.IGLoadFromJSONArray(aJSON: TJSONArray);
var
  vItem: TJSONValue;
  I: Integer;
  Field: TField;
begin
  Self.DisableControls;
  try
    Self.Close;
    Self.CreateDataSet;
    for vItem in aJSON do
    begin
      Self.Append;
      for I := 0 to Pred(TJSONObject(vItem).Count) do
      begin
        Field := Self.FindField(TJSONObject(vItem).Pairs[I].JsonString.Value);

        if not Assigned(Field) then
          Continue;

        if TJSONObject(vItem).Pairs[I].JsonValue is TJSONNull then
          Field.Clear
        else
        if Field is TNumericField then
          Field.AsFloat := TJSONNumber(TJSONObject(vItem).Pairs[I].JsonValue).AsDouble
        else
        if Field is TBooleanField then
          Field.AsBoolean := TJSONBool(TJSONObject(vItem).Pairs[I].JsonValue).AsBoolean
        else
        if (Field is TDateField) or (Field is TDateTimeField) then
          Field.AsDateTime := ISO8601ToDate(TJSONString(TJSONObject(vItem).Pairs[I].JsonValue).Value)
        else
          Field.AsString := TJSONString(TJSONObject(vItem).Pairs[I].JsonValue).Value;
      end;
      Self.Post;
    end;
    Self.First;
  finally
    Self.EnableControls;
  end;
end;

procedure TIGClientDataSet.CreateFromJSONArray(aJSON: TJSONArray);
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

{ TIGDataSet.TIGSmartAction }

constructor TIGDataSet.TIGSmartAction.Create(DataSet: TDataSet);
begin
  FDataSet := DataSet;
end;

destructor TIGDataSet.TIGSmartAction.Destroy;
begin
  Finalizar;
  inherited;
end;

{ TIGDataSet.TIGSmartOrderBy }

class function TIGDataSet.TIGSmartOrderBy.New(DataSet: TClientDataSet; saFields: array of string): IIGDataSetSmartAction;
var
  sItem: String;
  sField: String;
  sFields: String;
  sDescFields: String;
begin
  sFields := EmptyStr;
  sDescFields := EmptyStr;
  for sItem in saFields do
  begin
    sField := LeftStr(sItem, sItem.Length - IfThen(MatchStr(RightStr(sItem.ToUpper.Trim, 5), [' ASC', ' DESC']), 5));
    sFields := sFields + IfThen(not sFields.Trim.IsEmpty, ';') + sField;
    if sItem.ToUpper.Trim.EndsWith(' DESC') then
      sDescFields := sDescFields + IfThen(not sDescFields.Trim.IsEmpty, ';') + sField;
  end;

  Result := TIGSmartOrderBy.Create(DataSet);
  TIGSmartOrderBy(Result).FOld := DataSet.IndexName;

  with DataSet.IndexDefs.AddIndexDef do
  begin
    Sleep(1); // Para não duplicar
    Name := 'IX_'+ FormatDateTime('yyyymmddHHnnsszzz', Now);
    Fields := sFields;
    DescFields := sDescFields;
    DataSet.IndexName := Name;
  end;
end;

procedure TIGDataSet.TIGSmartOrderBy.Finalizar;
begin
  TClientDataSet(FDataSet).IndexName := FOld;
  inherited;
end;

end.
(*
Controle de Versões.
------------------------------------------------------------------------------------------------------------------------
Adiciona IGGetDateSql, IGGetDateTimeSql e IGFieldIsEmpty; Alan Miranda - 08/02/2019;
------------------------------------------------------------------------------------------------------------------------
[João Felberg - 11/02/2019 às 11:06]
Adiciona método 'IGGetFieldsToInSql';
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 19/02/2019]
Adiciona métodos IGChanged e IGSameValue;
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 19/02/2019]
Adiciona método IGGetStrQt;
------------------------------------------------------------------------------------------------------------------------
[Pedro Stoco - 08/05/2019]
Adiciona método IGContains
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 10/07/2019]
Adiciona possibilidade de agrupar os dados na função IGGetValuesToInSql
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 18/07/2019]
Adiciona IGSetProperty para definir várias propriedades para vários fiels simultâneamente
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 03/10/2019]
Ajusta IGFilter para remover o filtro se não informado nada
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 20/11/2019]
  - Adiciona IGGetControls (e Overloads)
    - Função que retorna os controles encontrados para o campo informado
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 25/11/2019]
  - Adiciona IGGetExtended
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 22/10/2019]
Adiciona IGStateIn para faciliar verificação de estado do dataset
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 25/11/2019]
  - Adiciona IGCalculaExpressao
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 12/12/2019]
Melhoria no IGClearFields
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 16/12/2019]
Corrige IGLoadStrem para não inserir mais de um item no dateset de parâmetros
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 29/01/2020]
Corrige funções do Helper.DataSet (Padronização e Lógica de Programação)
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 30/01/2020]
Adiciona IGFilterTotalize para totalizar field com mais de um tipo de filtro
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 14/02/2020]
Ajusta Requiered para exibir os fields vazios passados por parâmetro
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 14/02/2020]
  - Refatoração de ShowComponents para IGHighlightControls
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 16/04/2020]
  - Adiciona Overload de IGHighlightControls para trabalhar com nome de classe
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 08/05/2020]
  - Adiciona IGRaise, que une IGHighlightControls com Mensagem.Functions.IGMsgRaiseControl para
      destacar componentes e exibir mensagem de erro, também possibilita posicionar a mensagem
      de baixo de um componente.
  - Adiciona overload IGGetControl para trabalhar com nome da classe
  - Adiciona parâmetro de cor no IGHighlightControls
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 23/06/2020]
  - Adiciona IGSmartDisableControls e IGSmartBookmark
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 22/10/2020 - ISSUE:457]
  - Adiciona IGGetJSONValue e IGGetJSONPair
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 17/11/2020 - ISSUE:463]
  - Melhoria na função IGCountFilter, adiciona opção de Reset e configura o filtro apenas se tiver
    algo informado.
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 20/11/2020]
Adiciona método para obter valor já arredondado do Field no DataSet
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 30/11/2020 - ISSUE:473]
  - Adiciona options para SetValue e SameValue
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 27/02/2021 - ISSUE:516]
  - Adiciona funções IGIndexOf e IGMatchValue
    - IGIndexOf - Retorna o Index da posição que o valor do campo de encontra no array informado
    - IGMatchValue - Retorna True/False indicando a existência/inexistência do valor do campo
      no array informado.
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 10/04/2021]
  - Melhoria no IGGetControls para obter também componentes que Herdem de TDBLookupControl
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 28/04/2021]
Corrige erro de indice já existente ao ordenar dataset
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 23/06/2021 - ISSUE:558]
  - Configura Highlight para TDBCheckBox
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 19/08/2021]
Adiciona IGGroup, para efetuar agrupamento de valores semelhante ao SQL
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 26/10/2021]
Adiciona IGSmartFilter para filtrar e voltar o filtro original automaticamente após o método ser executado
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 24/11/2021]
Adiciona no IGGroup método para fazer string aggregate dos campos
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 29/11/2021]
Adiciona método IGSetRequired, para configurar automaticamente o requiered do campo e os labels relacionados
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 31/08/2022 - TICK:61959]
  - Correção no carregamento do IGLoadStream
------------------------------------------------------------------------------------------------------------------------
*)