unit Conversa.Connection.List;

interface

uses
  System.Classes,
  System.Generics.Collections,
//  System.Types,
  System.SysUtils;

type

  TConnectionRegister = TProc;

  TConnectionRegisterList = class(TThreadList<TConnectionRegister>)
  public
    class function Instance: TConnectionRegisterList;
    procedure AvisoConexao;
  end;

implementation

var
  FLista: TConnectionRegisterList;

{ TConnectionRegisterList }

procedure TConnectionRegisterList.AvisoConexao;
var
  Item: TProc;
begin
  try
    for Item in Self.LockList do
    begin
      try
        Item;
      except
      end;
    end;
  finally
    Self.UnlockList;
  end;
end;

class function TConnectionRegisterList.Instance: TConnectionRegisterList;
begin
  Result := FLista;
end;

initialization
  FLista := TConnectionRegisterList.Create;

finalization
  FreeAndNil(FLista);

end.
