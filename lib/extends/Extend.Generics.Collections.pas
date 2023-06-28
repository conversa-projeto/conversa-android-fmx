(*------------------------------------------------------------------------------
Irmãos Gonçalves Comércio e Indústria LTDA

Classe para auxiliar no uso de Arrays

Autor: Eduardo Rodrigues Pêgo

Data: 23/06/2019
------------------------------------------------------------------------------*)
unit Extend.Generics.Collections;

interface

uses
  System.Math,
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.RTTI;

type
  TCallBackItem<T> = reference to procedure (Item: T);
  TCallBackIndex<T, Integer> = reference to procedure (Item: T; Index: Integer);
  TCallBackSearch<T, Integer, Boolean> = reference to function (Item: T; Index: Integer): Boolean;
  TCallBackFilter<T, Boolean> = reference to function (Item: T): Boolean;
  TCallBackMap<T> = reference to function (Item: T): T;
  TCallBackMapConst<T> = reference to function (const Item: T): T;
  TCallBackMapTypes<T1, T2> = reference to function (Item: T1): T2;
  TCallBackMapTypesConst<T1, T2> = reference to function (const Item: T1): T2;
  TArray = class(System.Generics.Collections.TArray)
  public
    class procedure Add<T>(var Lista: TArray<T>; Item: T; Index: Integer = -1); overload;
    class function Add<T>(const Lista: Array of T; Item: T; Index: Integer = -1): TArray<T>; overload;
    class procedure Move<T>(var Lista: TArray<T>; Source, Destination: Integer);
    class procedure Remove<T>(var Lista: TArray<T>; Item: T);
    class procedure RemoveIndex<T>(var Lista: TArray<T>; Index: Integer);
    class function IndexOf<T>(const Lista: Array of T; Item: T): Integer;
    class function Exists<T>(const Lista: Array of T; Item: T): Boolean; overload;
    class function Exists<T>(const Lista: Array of T; Item: T; out Index: Integer): Boolean; overload;
    class function Exists<T>(const Lista: Array of T; Items: Array of T): Boolean; overload;
    class function AddIfNotExist<T>(var Lista: TArray<T>; Item: T): Boolean;
    class procedure ForEach<T>(const Lista: array of T; Proc: TCallBackItem<T>); overload;
    class procedure ForEach<T>(const Lista: array of T; Proc: TCallBackIndex<T, Integer>); overload;
    class procedure Fill<T>(var Lista: TArray<T>; Item: T; StartIndex: Integer = 0; EndIndex: Integer = 0);
    class function Join<T>(const Lista: Array of T; Separator: String = ','): String;
    class function Make<T>(const Lista: Array of T): TArray<T>; overload;
    class function Make<T>(const pGetItem: TFunc<Integer, T>; const iHigh: Integer; iLow: Integer = 0): TArray<T>; overload;
    class function RealIndex<T>(const Lista: array of T; Index: Integer): Integer;
    class function Item<T>(const Lista: Array of T; Index: Integer): T;
    class function Search<T>(const Lista: array of T; Proc: TCallBackSearch<T, Integer, Boolean>): Boolean;
    class function Merge<T>(const Arrays: TArray<TArray<T>>): TArray<T>;
    class function Filter<T>(const Lista: Array of T; Filter: TCallBackFilter<T, Boolean>): TArray<T>;
    class procedure Reverse<T>(var Lista: TArray<T>);
    class procedure Clear<T>(var Lista: TArray<T>);
    class function Cast<T1, T2>(const Lista: array of T1): TArray<T2>;
    class function IndexOfArrays<T>(Item: T; Listas: TArray<TArray<T>>): Integer;
    class function CaseOf<T>(Item: T; const Lista1: Array of T; const Lista2: Array of T): T; overload;
    class function CaseOf<T>(Item: T; const Lista1: Array of T; const Lista2: Array of T; ItemElse: T): T; overload;
    class function CaseOf<T1, T2>(Item: T1; const Lista1: Array of T1; const Lista2: Array of T2): T2; overload;
    class function Map<T>(const Lista: TArray<T>; Func: TCallBackMap<T>): TArray<T>; overload;
    class function Map<T>(const Lista: TArray<T>; Func: TCallBackMapConst<T>): TArray<T>; overload;
    class function Map<T1, T2>(const Lista: TArray<T1>; Func: TCallBackMapTypes<T1, T2>): TArray<T2>; overload;
    class function Map<T1, T2>(const Lista: TArray<T1>; Func: TCallBackMapTypesConst<T1, T2>): TArray<T2>; overload;
    class function Group<T>(var Lista: TArray<T>): TArray<T>;
  end;

  TIGArray<T> = record
  private
    FArr: TArray<T>;
  private type
    TIGArrayDouble<T2> = record
    private
      FArr: TArray<TArray<T2>>;
      class operator Implicit(const Value: TIGArray<T2>): TIGArrayDouble<T2>;
    end;
  public
    constructor Make(const Value: Array of T); overload;
    class operator Implicit(const Value: TArray<T>): TIGArray<T>;
    class operator Implicit(const Value: TIGArray<T>): TArray<T>;
    class operator Add(const A: TIGArray<T>; B: T): TIGArray<T>;
    class operator Subtract(const A: TIGArray<T>; B: T): TIGArray<T>;
    function Join(Separator: String = ','): String;
    function Add(Item: T; Index: Integer = -1): TIGArray<T>;
    function AddIfNotExist(Item: T): TIGArray<T>;
    function Move(Source, Destination: Integer): TIGArray<T>;
    function Remove(Item: T): TIGArray<T>;
    function RemoveIndex(Index: Integer): TIGArray<T>;
    function IndexOf(Item: T): Integer;
    function Exists(Item: T): Boolean; overload;
    function Exists(Item: T; out Index: Integer): Boolean; overload;
    function Exists(Items: Array of T): Boolean; overload;
    procedure ForEach(Proc: TCallBackItem<T>); overload;
    procedure ForEach(Proc: TCallBackIndex<T, Integer>); overload;
    procedure Fill(Item: T; StartIndex: Integer = 0; EndIndex: Integer = 0);
    function RealIndex(Index: Integer): Integer;
    function Item(Index: Integer): T;
    function Search(Proc: TCallBackSearch<T, Integer, Boolean>): Boolean;
    function Merge(const Arrays: TArray<T>): TIGArray<T>; overload;
    function Merge(const Arrays: TArray<TArray<T>>): TIGArray<T>; overload;
    function Filter(Filter: TCallBackFilter<T, Boolean>): TIGArray<T>;
    function Reverse: TIGArray<T>;
    function Clear: TIGArray<T>; overload;
    function Cast<T2>: TArray<T2>;
    function Map(Func: TCallBackMap<T>): TIGArray<T>; overload;
    function Map(Func: TCallBackMapConst<T>): TIGArray<T>; overload;
    function Map<T2>(Func: TCallBackMapTypes<T, T2>): TIGArray<T2>; overload;
    function Map<T2>(Func: TCallBackMapTypesConst<T, T2>): TIGArray<T2>; overload;
    function Group: TIGArray<T>; overload;
    function Sort: TIGArray<T>; overload;
    function Make(const pGetItem: TFunc<Integer, T>; const iHigh: Integer; iLow: Integer = 0): TArray<T>; overload;
    function IndexOfArrays(Item: T; Listas: TArray<TArray<T>>): Integer;
    function CaseOf(Item: T; const Lista2: TArray<T>): T; overload;
    function CaseOf(Item: T; const Lista2: TArray<T>; ItemElse: T): T; overload;
    function CaseOf<T2>(Item: T; const Lista2: TArray<T2>): T2; overload;
    function IsEmpty: Boolean;
    function Count: Integer;
    function SplitBy(const QuantidadeItems: Integer): TIGArrayDouble<T>;
  end;

implementation

uses
  System.Variants;

{ TArray }

class procedure TArray.Add<T>(var Lista: TArray<T>; Item: T; Index: Integer = -1);
var
  I: Integer;
begin
  if Index >= Length(Lista) then
    raise Exception.Create('TArray.Add<T>: Indice fora da lista!');
  SetLength(Lista, Succ(Length(Lista)));
  Lista[Pred(Length(Lista))] := Item;
  if Index <> -1 then
    TArray.Move<T>(Lista, Pred(Length(Lista)), Index);
end;

class function TArray.Add<T>(const Lista: Array of T; Item: T; Index: Integer = -1): TArray<T>;
begin
  Result := TArray.Make(Lista);
  TArray.Add<T>(Result, Item, Index);
end;

class procedure TArray.Move<T>(var Lista: TArray<T>; Source, Destination: Integer);
var
  I: Integer;
  Item: T;
begin
  Source := TArray.RealIndex<T>(Lista, Source);
  Destination := TArray.RealIndex<T>(Lista, Destination);
  if Source = Destination then
    Exit;
  Item := TArray.Item(Lista, Source);
  if Source < Destination then
    for I := Source to Pred(Destination) do
      Lista[I] := Lista[Succ(I)]
  else
    for I := Pred(Source) downto Destination do
      Lista[Succ(I)] := Lista[I];
  Lista[Destination] := Item;
end;

class procedure TArray.Remove<T>(var Lista: TArray<T>; Item: T);
var
  J: Integer;
begin
  if TArray.Exists(Lista, Item, J) then
    TArray.RemoveIndex<T>(Lista, J);
end;

class procedure TArray.RemoveIndex<T>(var Lista: TArray<T>; Index: Integer);
begin
  TArray.Move<T>(Lista, Index, Pred(Length(Lista)));
  SetLength(Lista, Pred(Length(Lista)));
end;

class function TArray.IndexOf<T>(const Lista: Array of T; Item: T): Integer;
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

class function TArray.Exists<T>(const Lista: Array of T; Item: T): Boolean;
begin
  Result := TArray.IndexOf(Lista, Item) > -1;
end;

class function TArray.Exists<T>(const Lista: Array of T; Item: T; out Index: Integer): Boolean;
begin
  Index := TArray.IndexOf(Lista, Item);
  Result := Index > -1;
end;

class function TArray.Exists<T>(const Lista: Array of T; Items: Array of T): Boolean;
var
  Item: T;
begin
  Result := False;
  for Item in Items do
    if TArray.Exists(Lista, Item) then
       Exit(True);
end;

class function TArray.AddIfNotExist<T>(var Lista: TArray<T>; Item: T): Boolean;
begin
  Result := not TArray.Exists(Lista, Item);
  if Result then
    TArray.Add<T>(Lista, Item);
end;

class procedure TArray.ForEach<T>(const Lista: array of T; Proc: TCallBackItem<T>);
var
  Item: T;
begin
  for Item in Lista do
    Proc(Item)
end;

class procedure TArray.ForEach<T>(const Lista: array of T; Proc: TCallBackIndex<T, Integer>);
var
  I: Integer;
begin
  for I := Low(Lista) to High(Lista) do
    Proc(Lista[I], I);
end;

class procedure TArray.Fill<T>(var Lista: TArray<T>; Item: T; StartIndex, EndIndex: Integer);
var
  I: Integer;
  iStart: Integer;
  iEnd: Integer;
begin
  if StartIndex = 0 then
    iStart := Low(Lista)
  else
    iStart := StartIndex;
  if EndIndex = 0 then
    iEnd := High(Lista)
  else
    iEnd := EndIndex;
  for I := iStart to iEnd do
    Lista[I] := Item;
end;

class function TArray.Join<T>(const Lista: Array of T; Separator: String = ','): String;
var
  Text: String;
begin
  Text := EmptyStr;
  TArray.ForEach<T>(
    Lista,
    procedure(Item: T)
    var
      vTemp: Variant;
    begin
      VarCast(vTemp, TValue.From<T>(Item).AsVariant, varString);
      if Text.IsEmpty then
        Text := vTemp
      else
        Text := Text + Separator + vTemp;
    end
  );
  Result := Text;
end;

class function TArray.Make<T>(const Lista: Array of T): TArray<T>;
var
  Arr: TArray<T>;
begin
  TArray.ForEach<T>(
    Lista,
    procedure(Item: T)
    begin
      TArray.Add<T>(Arr, Item);
    end
  );
  Result := Arr;
end;

class function TArray.Make<T>(const pGetItem: TFunc<Integer, T>; const iHigh: Integer; iLow: Integer = 0): TArray<T>;
var
  I: Integer;
begin
  for I := iLow to iHigh do
    TArray.Add<T>(Result, pGetItem(I));
end;

class function TArray.RealIndex<T>(const Lista: array of T; Index: Integer): Integer;
begin
  if Index < 0 then
    Result := Length(Lista) + Index
  else
    Result := Index;
  if (Result < Low(Lista)) or (Result > High(Lista)) then
    raise Exception.Create('TArray.Item<T>: Indice fora da lista!');
end;

class function TArray.Item<T>(const Lista: array of T; Index: Integer): T;
begin
  Result := Lista[TArray.RealIndex<T>(Lista, Index)];
end;

class function TArray.Search<T>(const Lista: array of T; Proc: TCallBackSearch<T, Integer, Boolean>): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(Lista) to High(Lista) do
    if Proc(Lista[I], I) then
      Exit(True);
end;

class function TArray.Merge<T>(const Arrays: TArray<TArray<T>>): TArray<T>;
var
  List: TArray<T>;
  Item: T;
begin
  for List in Arrays do
    for Item in List do
      TArray.AddIfNotExist<T>(Result, Item)
end;

class function TArray.Filter<T>(const Lista: Array of T; Filter: TCallBackFilter<T, Boolean>): TArray<T>;
var
  Arr: TArray<T>;
begin
  TArray.ForEach<T>(
    Lista,
    procedure (Item: T)
    begin
      if Filter(Item) then
        TArray.Add<T>(Arr, Item);
    end
  );
  Result := Arr;
end;

class procedure TArray.Reverse<T>(var Lista: TArray<T>);
var
  I: Integer;
begin
  for I := Pred(Length(Lista)) downto 1 do
    TArray.Move<T>(Lista, 0, I);
end;

class procedure TArray.Clear<T>(var Lista: TArray<T>);
begin
  SetLength(Lista, 0);
end;

class function TArray.Cast<T1, T2>(const Lista: array of T1): TArray<T2>;
var
  Res: TArray<T2>;
begin
  TArray.ForEach<T1>(
    Lista,
    procedure(Item: T1)
    var
      vTemp: Variant;
      vvT2: T2;
      vT2: TValue;
    begin
      if System.TypeInfo(T2) = System.TypeInfo(Variant) then
      begin
        SetLength(Res, Succ(Length(Res)));
        Res[Pred(Length(Res))] := TValue.From<T1>(Item).AsType<T2>;
      end
      else
      begin
        TValue.Make(@vvT2, System.TypeInfo(T2), vT2);
        VarCast(vTemp, TValue.From<T1>(Item).AsVariant, VarType(vT2.AsVariant));
        SetLength(Res, Succ(Length(Res)));
        Res[Pred(Length(Res))] := TValue.FromVariant(vTemp).AsType<T2>;
      end;
    end
  );
  Result := Res;
end;

class function TArray.IndexOfArrays<T>(Item: T; Listas: TArray<TArray<T>>): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := Low(Listas) to High(Listas) do
    if TArray.Exists<T>(Listas[I], Item) then
      Exit(I);
end;

class function TArray.CaseOf<T>(Item: T; const Lista1: Array of T; const Lista2: Array of T): T;
var
  iIndex: Integer;
begin
  if TArray.Exists(Lista1, Item, iIndex) then
    Result := TArray.Item<T>(Lista2, iIndex)
  else
    raise Exception.Create('TArray.CaseOf<T>: Indice fora da lista!');
end;

class function TArray.CaseOf<T>(Item: T; const Lista1: Array of T; const Lista2: Array of T; ItemElse: T): T;
var
  iIndex: Integer;
begin
  if TArray.Exists(Lista1, Item, iIndex) then
    Result := TArray.Item<T>(Lista2, iIndex)
  else
    Result := ItemElse;
end;

class function TArray.CaseOf<T1, T2>(Item: T1; const Lista1: Array of T1; const Lista2: Array of T2): T2;
var
  iIndex: Integer;
begin
  if TArray.Exists(Lista1, Item, iIndex) then
    Result := TArray.Item<T2>(Lista2, iIndex)
  else
    raise Exception.Create('TArray.CaseOf<T1, T2>: Indice fora da lista!');
end;

class function TArray.Map<T>(const Lista: TArray<T>; Func: TCallBackMap<T>): TArray<T>;
var
  arTemp: TArray<T>;
begin
  TArray.ForEach<T>(
    Lista,
    procedure (Item: T)
    begin
      TArray.Add<T>(arTemp, Func(Item));
    end
  );
  Result := arTemp;
end;

class function TArray.Map<T>(const Lista: TArray<T>; Func: TCallBackMapConst<T>): TArray<T>;
var
  arTemp: TArray<T>;
begin
  TArray.ForEach<T>(
    Lista,
    procedure (Item: T)
    begin
      TArray.Add<T>(arTemp, Func(Item));
    end
  );
  Result := arTemp;
end;

class function TArray.Map<T1, T2>(const Lista: TArray<T1>; Func: TCallBackMapTypes<T1, T2>): TArray<T2>;
var
  arTemp: TArray<T2>;
begin
  TArray.ForEach<T1>(
    Lista,
    procedure (Item: T1)
    begin
      TArray.Add<T2>(arTemp, Func(Item));
    end
  );
  Result := arTemp;
end;

class function TArray.Map<T1, T2>(const Lista: TArray<T1>; Func: TCallBackMapTypesConst<T1, T2>): TArray<T2>;
var
  arTemp: TArray<T2>;
begin
  TArray.ForEach<T1>(
    Lista,
    procedure (Item: T1)
    begin
      TArray.Add<T2>(arTemp, Func(Item));
    end
  );
  Result := arTemp;
end;

class function TArray.Group<T>(var Lista: TArray<T>): TArray<T>;
var
  Arr: TArray<T>;
begin
  TArray.ForEach<T>(
    Lista,
    procedure (Item: T)
    begin
      TArray.AddIfNotExist<T>(Arr, Item);
    end
  );
  Lista := Arr;
  Result := Arr;
end;

{ TArrayIG<T> }

constructor TIGArray<T>.Make(const Value: array of T);
begin
  Self.FArr := TArray.Make<T>(Value);
end;

class operator TIGArray<T>.Implicit(const Value: TArray<T>): TIGArray<T>;
begin
  Result.FArr := Value;
end;

class operator TIGArray<T>.Implicit(const Value: TIGArray<T>): TArray<T>;
begin
  Result := Value.FArr;
end;

class operator TIGArray<T>.Add(const A: TIGArray<T>; B: T): TIGArray<T>;
var
  R: TIGArray<T>;
begin
  R := A;
  TArray.Add<T>(R.FArr, B);
  Result := A;
end;

class operator TIGArray<T>.Subtract(const A: TIGArray<T>; B: T): TIGArray<T>;
var
  R: TIGArray<T>;
begin
  R := A;
  TArray.Remove<T>(R.FArr, B);
  Result := A;
end;

function TIGArray<T>.Join(Separator: String): String;
begin
  Result := TArray.Join<T>(Self.FArr, Separator);
end;

function TIGArray<T>.Add(Item: T; Index: Integer): TIGArray<T>;
begin
  TArray.Add<T>(Self.FArr, Item, Index);
  Result := Self;
end;

function TIGArray<T>.AddIfNotExist(Item: T): TIGArray<T>;
begin
  TArray.AddIfNotExist<T>(Self.FArr, Item);
  Result := Self;
end;

function TIGArray<T>.Move(Source, Destination: Integer): TIGArray<T>;
begin
  TArray.Move<T>(Self.FArr, Source, Destination);
  Result := Self;
end;

function TIGArray<T>.Remove(Item: T): TIGArray<T>;
begin
  TArray.Remove<T>(Self.FArr, Item);
  Result := Self;
end;

function TIGArray<T>.RemoveIndex(Index: Integer): TIGArray<T>;
begin
  TArray.RemoveIndex<T>(Self.FArr, Index);
  Result := Self;
end;

function TIGArray<T>.IndexOf(Item: T): Integer;
begin
  Result := TArray.IndexOf<T>(Self.FArr, Item);
end;

function TIGArray<T>.Exists(Item: T): Boolean;
begin
  Result := TArray.Exists<T>(Self.FArr, Item);
end;

function TIGArray<T>.Exists(Item: T; out Index: Integer): Boolean;
begin
  Result := TArray.Exists<T>(Self.FArr, Item, Index);
end;

function TIGArray<T>.Exists(Items: array of T): Boolean;
begin
  Result := TArray.Exists<T>(Self.FArr, Items);
end;

procedure TIGArray<T>.ForEach(Proc: TCallBackItem<T>);
begin
  TArray.ForEach<T>(Self.FArr, Proc);
end;

procedure TIGArray<T>.ForEach(Proc: TCallBackIndex<T, Integer>);
begin
  TArray.ForEach<T>(Self.FArr, Proc);
end;

procedure TIGArray<T>.Fill(Item: T; StartIndex, EndIndex: Integer);
begin
  TArray.Fill<T>(Self.FArr, Item, StartIndex, EndIndex);
end;

function TIGArray<T>.Make(const pGetItem: TFunc<Integer, T>; const iHigh: Integer; iLow: Integer): TArray<T>;
begin
  Result := TArray.Make<T>(pGetItem, iHigh, iLow);
end;

function TIGArray<T>.RealIndex(Index: Integer): Integer;
begin
  Result := TArray.RealIndex<T>(Self.FArr, Index);
end;

function TIGArray<T>.Item(Index: Integer): T;
begin
  Result := TArray.Item<T>(Self.FArr, Index);
end;

function TIGArray<T>.Search(Proc: TCallBackSearch<T, Integer, Boolean>): Boolean;
begin
  Result := TArray.Search<T>(Self.FArr, Proc);
end;

function TIGArray<T>.Merge(const Arrays: TArray<T>): TIGArray<T>;
begin
  Self.FArr := TArray.Merge<T>([Self.FArr, Arrays]);
  Result := Self;
end;

function TIGArray<T>.Merge(const Arrays: TArray<TArray<T>>): TIGArray<T>;
begin
  Result := TIGArray<T>(TArray.Merge<T>(Arrays));
end;

function TIGArray<T>.Filter(Filter: TCallBackFilter<T, Boolean>): TIGArray<T>;
begin
  Self.FArr := TArray.Filter<T>(Self.FArr, Filter);
  Result := Self;
end;

function TIGArray<T>.Reverse: TIGArray<T>;
begin
  TArray.Reverse<T>(Self.FArr);
  Result := Self;
end;

function TIGArray<T>.Clear: TIGArray<T>;
begin
  TArray.Clear<T>(Self.FArr);
  Result := Self;
end;

function TIGArray<T>.Cast<T2>: TArray<T2>;
begin
  Result := TArray.Cast<T, T2>(Self.FArr);
end;

function TIGArray<T>.IndexOfArrays(Item: T; Listas: TArray<TArray<T>>): Integer;
begin
  Result := TArray.IndexOfArrays<T>(Item, Listas);
end;

function TIGArray<T>.CaseOf(Item: T; const Lista2: TArray<T>): T;
begin
  Result := TArray.CaseOf<T>(Item, Self.FArr, Lista2);
end;

function TIGArray<T>.CaseOf(Item: T; const Lista2: TArray<T>; ItemElse: T): T;
begin
  Result := TArray.CaseOf<T>(Item, Self.FArr, Lista2);
end;

function TIGArray<T>.CaseOf<T2>(Item: T; const Lista2: TArray<T2>): T2;
begin
  Result := TArray.CaseOf<T, T2>(Item, Self.FArr, Lista2);
end;

function TIGArray<T>.Map(Func: TCallBackMap<T>): TIGArray<T>;
begin
  Self.FArr := TArray.Map<T>(Self.FArr, Func);
  Result := Self;
end;

function TIGArray<T>.Map(Func: TCallBackMapConst<T>): TIGArray<T>;
begin
  Self.FArr := TArray.Map<T>(Self.FArr, Func);
  Result := Self;
end;

function TIGArray<T>.Map<T2>(Func: TCallBackMapTypes<T, T2>): TIGArray<T2>;
begin
  Result := TArray.Map<T, T2>(Self.FArr, Func);
end;

function TIGArray<T>.Map<T2>(Func: TCallBackMapTypesConst<T, T2>): TIGArray<T2>;
begin
  Result := TArray.Map<T, T2>(Self.FArr, Func);
end;

function TIGArray<T>.Group: TIGArray<T>;
begin
  Self.FArr := TArray.Group<T>(Self.FArr);
  Result := Self;
end;

function TIGArray<T>.Sort: TIGArray<T>;
begin
  TArray.Sort<T>(Self.FArr);
  Result := Self;
end;

function TIGArray<T>.Count: Integer;
begin
  Result := Length(Self.FArr);
end;

function TIGArray<T>.IsEmpty: Boolean;
begin
  Result := Self.Count = 0;
end;

function TIGArray<T>.SplitBy(const QuantidadeItems: Integer): TIGArrayDouble<T>;
var
  iIdxAtual: Integer;
begin
  if (QuantidadeItems = 0) or (Length(Self.FArr) <= QuantidadeItems) then
  begin
    Result := TIGArray<T>(Self.FArr);
    Exit;
  end;

  iIdxAtual := 0;
  while iIdxAtual < Length(Self.FArr) do
  try
    SetLength(Result.FArr, Succ(Length(Result.FArr))); // Adiciona mais 1 pacote ao result
    SetLength(Result.FArr[Pred(Length(Result.FArr))], Min(QuantidadeItems, Length(Self.FArr) - iIdxAtual)); // Define o tamanho do pacote atual
    TArray.Copy<T>(Self.FArr, Result.FArr[Pred(Length(Result.FArr))], iIdxAtual, 0, Min(QuantidadeItems, Length(Self.FArr) - iIdxAtual)); // Copia os dados
  finally
    Inc(iIdxAtual, QuantidadeItems);
  end;
end;

{ TIGArray<T>.TIGArrayDouble<T2> }

class operator TIGArray<T>.TIGArrayDouble<T2>.Implicit(const Value: TIGArray<T2>): TIGArrayDouble<T2>;
begin
  Result.FArr := [Value.FArr];
end;

{$WARN GARBAGE OFF}

end.
(*
Controle - Versões.
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 02/07/2020]
Adiciona metodo CaseOf para conversão de um item de uma lista para outra
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 23/07/2020]
Adiciona metodo CaseOf com opção de else para conversão de um item de uma lista para outra
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 31/08/2020]
Adiciona metodo Map para execução de um metodo a cada item do array
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 11/12/2020]
Corrige metodo de reordenação dos itens dentro do array, metodo Hight estava retornando um valor incorreto
------------------------------------------------------------------------------------------------------------------------
[Eduardo - 24/03/2021]
Melhora compatibilidade com indice pyton em mais métodos e adiciona método para remover pelo índice
------------------------------------------------------------------------------------------------------------------------
[Daniel Araujo - 03/12/2021 - ISSUE:631]
  - Uso de Fluent Interface
  - Cast implicito entre TArray<T> e TIGArray<T> (class operator)
  - Inclusão e Remoção implícita (class operator)
------------------------------------------------------------------------------------------------------------------------
*)
