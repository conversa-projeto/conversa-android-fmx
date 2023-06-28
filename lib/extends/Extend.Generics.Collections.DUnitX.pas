unit Extend.Generics.Collections.DUnitX;

interface

uses
  DUnitX.TestFramework,
  System.StrUtils,
  System.SysUtils,
  Extend.Generics.Collections;

type
  [TestFixture]
  TDUnitXTArray = class
  private
    procedure ValidaEsperado(sEsperado: String);
  public
    [TestCase('A','0,0')]
    [TestCase('B','1,01')]
    [TestCase('C','2,012')]
    [TestCase('D','3,0123')]
    procedure Add(const Item: Integer; sEsperado: String);

    [TestCase('A','0,2,1203')]
    [TestCase('B','3,0,3120')]
    [TestCase('C','1,3,3201')]
    [TestCase('D','0,3,2013')]
    [TestCase('E','4,0,2013')]
    procedure Move(const Source, Destination: Integer; sEsperado: String);

    [TestCase('A','0123')]
    procedure Sort(sEsperado: String);

    [TestCase('A','1,0123,False')]
    [TestCase('B','3,0123,False')]
    [TestCase('C','4,01234,True')]
    [TestCase('D','-1,01234-1,True')]
    procedure AddIfNotExist(Item: Integer; sEsperado: String; bEsperado: Boolean);

    [TestCase('A','-1,01234')]
    [TestCase('B','4,0123')]
    [TestCase('C','1,023')]
    [TestCase('D','2,03')]
    [TestCase('E','2,03')]
    procedure Remove(Item: Integer; sEsperado: String);

    [TestCase('A','2,1,023')]
    [TestCase('B','1,1,0123')]
    [TestCase('C','4,5,0123')]
    procedure AddIndex(const Item: Integer; Index: Integer; sEsperado: String);

    [TestCase('A','2,2')]
    [TestCase('B','3,3')]
    [TestCase('C','4,-1')]
    [TestCase('D','-1,-1')]
    procedure IndexOf(Item: Integer; iEsperado: Integer);

    [TestCase('A','2,True')]
    [TestCase('B','3,True')]
    [TestCase('C','0,True')]
    [TestCase('D','-1,False')]
    [TestCase('E','4,False')]
    [TestCase('F','5,False')]
    procedure Exists(Item: Integer; bEsperado: Boolean);

    [TestCase('A','0123')]
    procedure ForEach(sEsperado: String);

    [TestCase('A','0,1,2,0003')]
    [TestCase('B','5,0,0,5555')]
    [TestCase('C','0,0,0,0000')]
    [TestCase('D','1,1,1,0100')]
    [TestCase('E','2,2,2,0120')]
    [TestCase('F','3,3,3,0123')]
    procedure Fill(Item, StartIndex, EndIndex: Integer; sEsperado: String);

    [TestCase('A','|0123', '|')]
    [TestCase('B',' |0 1 2 3', '|')]
    [TestCase('C','-|0-1-2-3', '|')]
    [TestCase('D','x|0x1x2x3', '|')]
    [TestCase('E','0|0010203', '|')]
    procedure Join(sSeparador, sEsperado: String);

    [TestCase('A','1,1,True')]
    [TestCase('B','3,3,True')]
    [TestCase('C','0,0,True')]
    [TestCase('D','5,-1,False')]
    [TestCase('E','-1,3,True')]
    [TestCase('F','-3,1,True')]
    [TestCase('G','-4,0,True')]
    [TestCase('H','-5,-1,False')]
    procedure Item(Index: Integer; iEsperado: Integer; bEsperado: Boolean);

    [TestCase('A','1,True')]
    [TestCase('B','0,True')]
    [TestCase('C','5,False')]
    procedure Search(Item: Integer; bEsperado: Boolean);

    [TestCase('A','0|1|2|3-0|1|2|3,0123')]
    [TestCase('B','0|2|2|3-4|5|6,023456')]
    [TestCase('C',',')]
    [TestCase('D','0|1|2|3-0|1|2|3|4|5|6,0123456')]
    [TestCase('E','0|1|2|3-0|1|2|3|4-3|2|1|0-6|7|8,01234678')]
    procedure Merge(sArrays: String; sEsperado: String);

    [TestCase('A','1,1')]
    [TestCase('B','3,3')]
    [TestCase('C','5,')]
    procedure Filter(iFiltro: Integer; sEsperado: String);

    [TestCase('A','3210')]
    [TestCase('B','0123')]
    procedure Reverse(sEsperado: String);

    [TestCase('A','3,0|1|2|3-4|5|6-7|8|9,0')]
    [TestCase('B','5,0|1|2|3-4|5|6-7|8|9,1')]
    [TestCase('C','9,0|1|2|3-4|5|6-7|8|9,2')]
    [TestCase('D','10,0|1|2|3-4|5|6-7|8|9,-1')]
    procedure IndexOfArrays(iItem: Integer; sArrays: String; iEsperado: Integer);

    [TestCase('A','0,0|1|2|3,3|2|1|0,3')]
    [TestCase('B','1,0|1|2|3,3|2|1|0,2')]
    [TestCase('C','2,0|1|2|3,3|2|1|0,1')]
    [TestCase('D','3,0|1|2|3,3|2|1|0,0')]
    [TestCase('E','4,0|1|2|3,3|2|1|0,-1')]
    procedure CaseOf(iItem: Integer; sArray1, sArray2: String; iEsperado: Integer);

    [TestCase('A','4,0|1|2|3,3|2|1|0,5,5')]
    [TestCase('B','0,0|1|2|3,3|2|1|0,5,3')]
    procedure CaseOf2(iItem: Integer; sArray1, sArray2: String; iElse, iEsperado: Integer);

    [TestCase('A','abc|def|ghj|klm,cba|fed|jhg|mlk')]
    procedure Map(sArray: String; sEsperado: String);

    [TestCase('B','0|1|2|3|15,0|1|2|3|15')]
    procedure Map2(sArray: String; sEsperado: String);

    [TestCase('A','0|1|2|3,0|1|2|3')]
    [TestCase('B','0|0|1|1,0|1')]
    [TestCase('C','0|1|2|3|0|1|2|3,0|1|2|3')]
    [TestCase('D','0|1|2|2,0|1|2')]
    procedure Group(sArray: String; sEsperado: String);

    [TestCase('A','')]
    procedure Clear(sEsperado: String);
  end;

var
  Arr: TArray<Integer>;

implementation

{ TDUnitXTArray }

procedure TDUnitXTArray.ValidaEsperado(sEsperado: String);
var
  sAtual: String;
begin
  Assert.WillNotRaise(
    procedure
    begin
      sAtual := TArray.Join<Integer>(Arr);
    end,
    Exception,
    'Erro ao obter o array atual!'
  );

  Assert.AreEqual(sEsperado, sAtual.Replace(',', EmptyStr), 'Array diferente do esperado!');
  TDUnitX.CurrentRunner.Log('['+ sAtual +']');
end;

procedure TDUnitXTArray.Add(const Item: Integer; sEsperado: String);
begin
  TArray.Add<Integer>(Arr, Item);
  ValidaEsperado(sEsperado);
end;

procedure TDUnitXTArray.Move(const Source, Destination: Integer; sEsperado: String);
begin
  if Source >= Length(Arr) then
    Assert.WillRaise(
      procedure
      begin
        TArray.Move<Integer>(Arr, Source, Destination);
      end,
      Exception,
      'Erro ao mover item do array!'
    )
  else
    TArray.Move<Integer>(Arr, Source, Destination);

  ValidaEsperado(sEsperado);
end;

procedure TDUnitXTArray.Sort;
begin
  TArray.Sort<Integer>(Arr);
  ValidaEsperado(sEsperado);
end;

procedure TDUnitXTArray.AddIfNotExist(Item: Integer; sEsperado: String; bEsperado: Boolean);
begin
  Assert.AreEqual(TArray.AddIfNotExist<Integer>(Arr, Item), bEsperado, 'Resultado diferente do esperado!');
  ValidaEsperado(sEsperado);
end;

procedure TDUnitXTArray.Remove(Item: Integer; sEsperado: String);
begin
  TArray.Remove<Integer>(Arr, Item);
  ValidaEsperado(sEsperado);
end;

procedure TDUnitXTArray.AddIndex(const Item: Integer; Index: Integer; sEsperado: String);
begin
  if Index >= Length(Arr) then
    Assert.WillRaise(
      procedure
      begin
        TArray.Add<Integer>(Arr, Item, Index);
      end,
      Exception,
      'Erro ao adicionar item do array na posição definida!'
    )
  else
    TArray.Add<Integer>(Arr, Item, Index);

  ValidaEsperado(sEsperado);
end;

procedure TDUnitXTArray.IndexOf(Item: Integer; iEsperado: Integer);
begin
  Assert.AreEqual(TArray.IndexOf<Integer>(Arr, Item), iEsperado, 'Posição no array diferente do esperado!');
end;

procedure TDUnitXTArray.Exists(Item: Integer; bEsperado: Boolean);
begin
  Assert.AreEqual(TArray.Exists<Integer>(Arr, Item), bEsperado, 'Resultado diferente do esperado!');
end;

procedure TDUnitXTArray.ForEach(sEsperado: String);
var
  sItems: String;
begin
  sItems := EmptyStr;
  TArray.ForEach<Integer>(
    Arr,
    procedure(Item: Integer)
    begin
      sItems := sItems + IntToStr(Item);
    end
  );
  Assert.AreEqual(sEsperado, sItems, 'Erro ao percorrer os itens do array!');
end;

procedure TDUnitXTArray.Fill(Item, StartIndex, EndIndex: Integer; sEsperado: String);
begin
  TArray.Fill<Integer>(Arr, Item, StartIndex, EndIndex);
  ValidaEsperado(sEsperado);
end;

procedure TDUnitXTArray.Join(sSeparador, sEsperado: String);
begin
  Assert.AreEqual(sEsperado, TArray.Join<Integer>(Arr, sSeparador));
end;

procedure TDUnitXTArray.Item(Index: Integer; iEsperado: Integer; bEsperado: Boolean);
begin
  if bEsperado then
    Assert.AreEqual(iEsperado, TArray.Item<Integer>(Arr, Index))
  else
    Assert.WillRaise(
      procedure
      begin
        Assert.AreEqual(iEsperado, TArray.Item<Integer>(Arr, Index));
      end,
      Exception,
      'Erro ao obter o item do array!'
    );
end;

procedure TDUnitXTArray.Search(Item: Integer; bEsperado: Boolean);
begin
  Assert.AreEqual(
    bEsperado,
    TArray.Search<Integer>(
      Arr,
      function (iItem, Index: Integer): Boolean
      begin
        Result := iItem = Item;
      end
    )
  );
end;

procedure TDUnitXTArray.Merge(sArrays: String; sEsperado: String);
var
  sTemp: String;
  arrTemp: TArray<TArray<Integer>>;
begin
  for sTemp in SplitString(sArrays, '-') do
    TArray.Add<TArray<Integer>>(arrTemp, TArray.Cast<String, Integer>(SplitString(sTemp, '|')));

  Assert.AreEqual(sEsperado, TArray.Join<Integer>(TArray.Merge<Integer>(arrTemp), EmptyStr));
end;

procedure TDUnitXTArray.Filter(iFiltro: Integer; sEsperado: String);
begin
  Assert.AreEqual(
    sEsperado,
    TArray.Join<Integer>(
      TArray.Filter<Integer>(
        Arr,
        function (Item: Integer): Boolean
        begin
          Result := Item = iFiltro;
        end),
      EmptyStr
    )
  );
end;

procedure TDUnitXTArray.Reverse(sEsperado: String);
begin
  TArray.Reverse<Integer>(Arr);
  ValidaEsperado(sEsperado);
end;

procedure TDUnitXTArray.IndexOfArrays(iItem: Integer; sArrays: String; iEsperado: Integer);
var
  sTemp: String;
  arrTemp: TArray<TArray<Integer>>;
begin
  for sTemp in SplitString(sArrays, '-') do
    TArray.Add<TArray<Integer>>(arrTemp, TArray.Cast<String, Integer>(SplitString(sTemp, '|')));

  Assert.AreEqual(iEsperado, TArray.IndexOfArrays<Integer>(iItem, arrTemp));
end;

procedure TDUnitXTArray.CaseOf(iItem: Integer; sArray1, sArray2: String; iEsperado: Integer);
begin
  if TArray.Exists<Integer>(TArray.Cast<String, Integer>(SplitString(sArray1, '|')), iItem) then
    Assert.AreEqual(
      iEsperado,
      TArray.CaseOf<Integer>(
        iItem,
        TArray.Cast<String, Integer>(SplitString(sArray1, '|')),
        TArray.Cast<String, Integer>(SplitString(sArray2, '|'))
      )
      )
  else
    Assert.WillRaise(
      procedure
      begin
        TArray.CaseOf<Integer>(
          iItem,
          TArray.Cast<String, Integer>(SplitString(sArray1, '|')),
          TArray.Cast<String, Integer>(SplitString(sArray2, '|'))
        );
      end,
      Exception,
      'Erro ao obter o item do array!'
    );
end;

procedure TDUnitXTArray.CaseOf2(iItem: Integer; sArray1, sArray2: String; iElse, iEsperado: Integer);
begin
  Assert.AreEqual(
    iEsperado,
    TArray.CaseOf<Integer>(
      iItem,
      TArray.Cast<String, Integer>(SplitString(sArray1, '|')),
      TArray.Cast<String, Integer>(SplitString(sArray2, '|')),
      iElse
    )
  );
end;

procedure TDUnitXTArray.Map(sArray: String; sEsperado: String);
begin
  Assert.AreEqual(
    TArray.Join<String>(SplitString(sEsperado, '|')),
    TArray.Join<String>(TArray.Map<String>(SplitString(sArray, '|'), ReverseString))
  );

  Assert.AreEqual(
    TArray.Join<String>(SplitString(sEsperado, '|')),
    TArray.Join<String>(TArray.Map<String>(SplitString(sArray, '|'),
      function(sItem: String): String
      begin
        Result := ReverseString(sItem);
      end
    ))
  );
end;

procedure TDUnitXTArray.Map2(sArray: String; sEsperado: String);
begin
  Assert.AreEqual(
    TArray.Join<String>(SplitString(sEsperado, '|')),
    TArray.Join<Integer>(TArray.Map<String, Integer>(SplitString(sArray, '|'), StrToInt))
  );

  Assert.AreEqual(
    TArray.Join<String>(SplitString(sEsperado, '|')),
    TArray.Join<Integer>(TArray.Map<String, Integer>(SplitString(sArray, '|'),
      function(sItem: String): Integer
      begin
        Result := StrToInt(sItem);
      end
    ))
  );
end;

procedure TDUnitXTArray.Group(sArray: String; sEsperado: String);
var
  arrTemp: TArray<String>;
begin
  Assert.WillNotRaise(
    procedure
    begin
      arrTemp := SplitString(sArray, '|');
      TArray.Group<String>(arrTemp);
    end
  );

  Assert.AreEqual(
    TArray.Join<String>(SplitString(sEsperado, '|')),
    TArray.Join<String>(arrTemp)
  );
end;

procedure TDUnitXTArray.Clear(sEsperado: String);
begin
  TArray.Clear<Integer>(Arr);
  ValidaEsperado(sEsperado);
end;

initialization
  TDUnitX.RegisterTestFixture(TDUnitXTArray);

{$WARN GARBAGE OFF}

end.