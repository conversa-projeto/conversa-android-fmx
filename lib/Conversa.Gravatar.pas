{******************************************}
{                                          }
{               Conversa                   }
{                                          }
{   Autor: Eduardo Rodrigues Pêgo          }
{   Data.: 05/04/2020                      }
{                                          }
{******************************************}
unit Conversa.Gravatar;

interface

uses
  FMX.Graphics,
  System.UITypes,
  System.Generics.Collections;

type
  TGravatar = class
  private type
    TGravatarItem = record
      Color: TAlphaColor;
      FontColor: TAlphaColor;
      Image: TBitmap;
    end;
  private
    FImages: TDictionary<String, TGravatarItem>;
    FColors: TArray<TAlphaColor>;
  public
    constructor Create;
    destructor Destroy; override;
    function GetGravatar(sName: String; sEmail: String): TGravatarItem;
    class function Instance: TGravatar;
//    class function GenerateRandomColor(const Mix: TAlphaColor = TAlphaColors.White): TAlphaColor; static;
  end;

implementation

uses
  System.Classes,
  IdHashMessageDigest,
  IdHTTP,
  System.SysUtils,
  System.Types,
  FMX.Types;

var
  FLista: TGravatar;

constructor TGravatar.Create;
begin
  FImages := TDictionary<String, TGravatarItem>.Create;

  FColors :=
    [TAlphaColorF.Create(163, 169, 72).ToAlphaColor,
     TAlphaColorF.Create(237, 185, 46).ToAlphaColor,
     TAlphaColorF.Create(248, 89,  49).ToAlphaColor,
     TAlphaColorF.Create(206, 24,  54).ToAlphaColor,
     TAlphaColorF.Create(0,   153, 137).ToAlphaColor];
end;

//class function TGravatar.GenerateRandomColor(const Mix: TAlphaColor = TAlphaColors.White): TAlphaColor;
//begin
//
//end;

destructor TGravatar.Destroy;
var
  Gravatar: TGravatarItem;
//  bImagem: TBitmap;
begin
  for Gravatar in FImages.Values do
    Gravatar.Image.DisposeOf;

  FImages.DisposeOf;
  inherited;
end;

function TGravatar.GetGravatar(sName: String; sEmail: String): TGravatarItem;
const
  SCALE = 1;
var
//  Item: TGravatarItem;
  ss: TStringStream;
//  sb: TBrush;
  Red, Green, Blue: Integer;
begin
  // Cria hash MD5
  with TIdHashMessageDigest5.Create do
  try
    sEmail := HashStringAsHex(sEmail);
  finally
    DisposeOf;
  end;

  if FImages.TryGetValue(sEmail, Result) then
    Exit;


  Randomize;
  Red := Random(255);
  Randomize;
  Green := Random(255);
  Randomize;
  Blue := Random(255);

  Result.Color := TAlphaColorF.Create(Red, Green, Blue).ToAlphaColor;

  if ((0.299 * Red + 0.587 * Green + 0.114 * Blue) / 255) > 0.5 then
    Result.FontColor := TAlphaColors.Black
  else
    Result.FontColor := TAlphaColors.White;

  Result.Image := TBitmap.Create;
  ss := TStringStream.Create;
  try
//    with TIdHTTP.Create(nil) do
//    try
//      try
//        // Obtem imagem
//        Get('https://www.gravatar.com/avatar/'+ sEmail.ToLower +'.bmp?default=404', ss);
//
//        // Carrega para arquivo
//        Result.Image.LoadFromStream(ss);
//      except on E: Exception do
//        begin
          // Criar icone
          Result.Image.SetSize(50, 50);
          Result.Image.Canvas.BeginScene;

//          sb := TBrush.Create(TBrushKind.Solid, FColors[Random(Length(FColors))]);
//          try
//            Result.Image.Canvas.FillEllipse(TRectF.Create(0, 0, 50, 50), 100, sb);
//          finally
//            sb.DisposeOf;
//          end;

          Result.Image.Canvas.Stroke.Kind := TBrushKind.Solid;
          Result.Image.Canvas.Fill.Color  := Result.FontColor;
          Result.Image.Canvas.Font.Size := 20;
          Result.Image.Canvas.FillText(TRectF.Create(0, 0, 50, 50), sName[1], False, 100, [TFillTextFlag.RightToLeft], TTextAlign.Center, TTextAlign.Center);
          Result.Image.Canvas.EndScene;
//        end;
//      end;
//
//      FImages.Add(sEmail, Result.Image);
//    finally
//      DisposeOf;
//    end;
  finally
    FreeAndNil(ss);
  end;
end;

class function TGravatar.Instance: TGravatar;
begin
  Result := FLista;
end;

initialization
  FLista := TGravatar.Create;

finalization
  FreeAndNil(FLista);

end.
