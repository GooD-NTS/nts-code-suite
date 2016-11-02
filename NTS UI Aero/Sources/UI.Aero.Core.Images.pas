{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Core.Images;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils,
  System.Classes,
  System.Types,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.GDIPAPI,
  Winapi.GDIPOBJ,
  Winapi.GDIPUTIL,
  Vcl.Graphics,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.JPEG,
  {$ELSE}
  SysUtils, Classes, Types, Windows, Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  Winapi.GDIPUTIL, Graphics, PNGImage, JPEG,
  {$ENDIF}
  NTS.Code.Helpers,
  NTS.Code.Common.Types,
  UI.Aero.Core.BaseControl,
  UI.Aero.Globals;

type
  TAeroPartImage = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    fPartWidth: Integer;
    fImage: TImageFileName;
    fPartHeight: Integer;
    fOrientation: TPartOrientation;
    procedure SetImage(const Value: TImageFileName);
    procedure SetOrientation(const Value: TPartOrientation);
    procedure SetPartSize(const Index, Value: Integer);
  Protected
    Procedure Change; virtual;
    function UpDateValue(var IntValue: Integer; const Value: Integer): BooLean;
  Public
    Data: TBitmap;
    Constructor Create; virtual;
    Destructor Destroy; override;
    Property OnChange: TNotifyEvent read FOnChange write FOnChange;
    function DataLoaded: BooLean;
  Published
    Property FileName: TImageFileName Read fImage Write SetImage;
    Property Orientation: TPartOrientation Read fOrientation Write SetOrientation default ioHorizontal;
    Property PartHeight: Integer Index 0 Read fPartHeight Write SetPartSize default 0;
    Property PartWidth : Integer Index 1 Read fPartWidth  Write SetPartSize default 0;
  end;

  TAeroButtonImage = class(TAeroPartImage)
  private
    fPartDown: Integer;
    fPartNormal: Integer;
    fPartDisabled: Integer;
    fPartHightLight: Integer;
    fPartFocused: Integer;
    procedure SetImagePart(const Index, Value: Integer);
  Public
    Constructor Create; OverRide;
    function PartSize: TSize;
  Published
    Property PartNormal    : Integer Index 0 Read fPartNormal     Write SetImagePart default 0;
    Property PartHightLight: Integer Index 1 Read fPartHightLight Write SetImagePart default 0;
    Property PartDown      : Integer Index 2 Read fPartDown       Write SetImagePart default 0;
    Property PartDisabled  : Integer Index 3 Read fPartDisabled   Write SetImagePart default 0;
    Property PartFocused   : Integer Index 4 Read fPartFocused    Write SetImagePart default 0;
  end;

  AeroPicture = Class
  const
    Blend: TBlendFunction = (
      BlendOp: AC_SRC_OVER;
      BlendFlags: 0;
      SourceConstantAlpha: 255;
      AlphaFormat: AC_SRC_ALPHA );
  Private
    class function BitMapFromPNG(AFileName: String): TBitmap;
    class function BitMapFromBMP(AFileName: String): TBitmap;
    class function BitMapFromJPG(AFileName: String): TBitmap;
  Public
    class function LoadImage(AFileName: String): TBitmap;
    class procedure Draw(DC: hDC;Image: TBitMap;Pos: TPoint;Size: TSize); OverLoad;
    class procedure Draw(DC: hDC;Image: TBitMap;Pos: TPoint); OverLoad;
    class procedure StretchDraw(DC: hDC;Image: TBitMap;Pos: TPoint;Size: TSize); OverLoad;
    class procedure StretchDraw(DC: hDC;Image: TBitMap;ImgRect: TRect); OverLoad;
    class procedure DrawPart(Surface: hDC; Part: hDC; PartPos: TPoint; PartSize: TSize; Index: Integer;Orientation: TPartOrientation); OverLoad;
  End;

implementation

{ TAeroPicture }

class function AeroPicture.BitMapFromBMP(AFileName: String): TBitmap;
var
  I, J: Integer;
  AArray32: pByteArray;
  BMPFile: TBitmap;
begin
  BMPFile:= TBitmap.Create;
  BMPFile.LoadFromFile(AFileName);
  if BMPFile.PixelFormat = pf32bit then
  begin
    Result:= TBitmap.Create;
    Result.LoadFromFile(AFileName);
  end
  else
  begin
    Result:= TBitmap.Create;
    Result.PixelFormat:= pf32bit;
    Result.SetSize(BMPFile.Width,BMPFile.Height);
    Result.Canvas.Brush.Color := clBlack;
    Result.Canvas.FillRect(Result.Canvas.ClipRect);
    Result.Canvas.Draw(0,0,BMPFile);
    for J:=0 to Result.Height-1 do
    begin
      AArray32:= Result.ScanLine[J];
      for I:=0 to Result.Width-1 do
        AArray32[I*4+3]:= 255;
    end;
  end;
  BMPFile.Free;
end;

class function AeroPicture.BitMapFromJPG(AFileName: String): TBitmap;
var
  I, J: Integer;
  AArray32: pByteArray;
  JPG: TJPEGImage;
begin
  JPG:= TJPEGImage.Create;
  JPG.LoadFromFile(AFileName);
  Result:= TBitmap.Create;
  Result.PixelFormat:= pf32bit;
  Result.SetSize(JPG.Width,JPG.Height);
  Result.Canvas.Brush.Color := clBlack;
  Result.Canvas.FillRect(Result.Canvas.ClipRect);
  Result.Canvas.Draw(0,0,JPG);
  for J:=0 to Result.Height-1 do
  begin
    AArray32:= Result.ScanLine[J];
    for I:=0 to Result.Width-1 do
      AArray32[I*4+3]:= 255;
  end;
  JPG.Free;
end;

class function AeroPicture.BitMapFromPNG(AFileName: String): TBitmap;
var
  I, J: Integer;
  AArray32,
  AArrayAlpha: pByteArray;
  PNGFile: TPNGImage;
begin
  PNGFile:= TPNGImage.Create;
  PNGFile.LoadFromFile(AFileName);
  Result:= TBitmap.Create;
  if PNGFile.TransparencyMode = ptmNone then
  begin
    Result.PixelFormat:= pf32bit;
    Result.SetSize(PNGFile.Width,PNGFile.Height);
    Result.Canvas.Brush.Color := clBlack;
    Result.Canvas.FillRect(Result.Canvas.ClipRect);
    Result.Canvas.Draw(0,0,PNGFile);
    for J:=0 to Result.Height-1 do
    begin
      AArray32:= Result.ScanLine[J];
      for I:=0 to Result.Width-1 do
        AArray32[I*4+3]:= 255;
    end;
  end
  else
  with Result do
  begin
    PixelFormat:= pf32bit;
    Width:= PNGFile.Width;
    Height:= PNGFile.Height;
    Canvas.Brush.Color := clBlack;
    Canvas.FillRect(Canvas.ClipRect);
    PNGFile.Draw(Canvas,Rect(0,0,Width,Height));
    for J:=0 to Height-1 do
    begin
      AArray32:= ScanLine[J];
      AArrayAlpha:= PNGFile.AlphaScanline[J];
      for I:=0 to PNGFile.Width-1 do
        AArray32[I*4+3]:= AArrayAlpha[I];
    end;
  end;
  PNGFile.Free;
end;

class function AeroPicture.LoadImage(AFileName: String): TBitmap;
begin
  Result:= nil;
  if FileExists(AFileName) then
  case AnsiLowerCase(ExtractFileExt(AFileName))[2] of
    'p': Result:= BitMapFromPNG(AFileName);{.png}
    'b': Result:= BitMapFromBMP(AFileName);{.bmp}
    'j': Result:= BitMapFromJPG(AFileName);{.jpg}
  end;
end;

class procedure AeroPicture.StretchDraw(DC: hDC; Image: TBitMap; ImgRect: TRect);
begin
  if Assigned(Image) then
    AlphaBlend(DC, ImgRect.Left, ImgRect.Top, ImgRect.Right, ImgRect.Bottom, Image.Canvas.Handle, 0, 0, Image.Width, Image.Height, Blend);
end;

class Procedure AeroPicture.Draw(DC: hDC;Image: TBitMap; Pos: TPoint; Size: TSize);
begin
  if Assigned(Image) then
    AlphaBlend(DC, Pos.X, Pos.Y, Size.cx, Size.cy, Image.Canvas.Handle, 0, 0, Size.cx, Size.cy, Blend);
end;

class procedure AeroPicture.Draw(DC: hDC; Image: TBitMap; Pos: TPoint);
begin
  if Assigned(Image) then
    AlphaBlend(DC, Pos.X, Pos.Y, Image.Width, Image.Height, Image.Canvas.Handle, 0, 0, Image.Width, Image.Height, Blend);
end;

class procedure AeroPicture.DrawPart(Surface, Part: hDC; PartPos: TPoint; PartSize: TSize; Index: Integer; Orientation: TPartOrientation);
var
  PartX,
  PartY: Integer;
begin
  PartY:= 0;
  PartX:= 0;
  case Orientation of
    ioHorizontal: PartX:= PartSize.cx*Index;
    ioVertical  : PartY:= PartSize.cy*Index;
  end;
  AlphaBlend(Surface, PartPos.X, PartPos.Y, PartSize.cx, PartSize.cy, Part,
    PartX, PartY, PartSize.cx, PartSize.cy, Blend);
end;

Class Procedure AeroPicture.StretchDraw(DC: hDC; Image: TBitMap; Pos: TPoint; Size: TSize);
begin
  AlphaBlend(DC, Pos.X, Pos.Y, Size.cx, Size.cy, Image.Canvas.Handle, 0, 0,
    Image.Width, Image.Height, Blend);
end;

{ TAeroPartImage }

Constructor TAeroPartImage.Create;
begin
  Data:= nil;
  FOnChange:= nil;
  fImage:= '';
  fOrientation:= ioHorizontal;
  fPartWidth:= 0;
  fPartHeight:= 0;
end;

function TAeroPartImage.DataLoaded: BooLean;
begin
  Result:= Assigned(Data);
end;

destructor TAeroPartImage.Destroy;
begin
  if Assigned(Data) then
    Data.Free;
  inherited Destroy;
end;

procedure TAeroPartImage.SetImage(const Value: TImageFileName);
begin
  if fImage <> Value then
  begin
    fImage := Value;

    if Assigned(Data) then
    begin
      Data.Free();
      Data := nil;
    end;

    if FileExists(fImage) then
      Data := AeroPicture.LoadImage(fImage);

    Change();
  end;
end;

procedure TAeroPartImage.SetOrientation(const Value: TPartOrientation);
begin
  if fOrientation <> Value then
  begin
    fOrientation:= Value;
    Change;
  end;
end;

procedure TAeroPartImage.SetPartSize(const Index, Value: Integer);
begin
  case Index of
    0: if UpDateValue(fPartHeight,Value) then Change;
    1: if UpDateValue(fPartWidth,Value) then Change;
  end;
end;

function TAeroPartImage.UpDateValue(var IntValue: Integer; const Value: Integer): BooLean;
begin
  if IntValue <> Value then
  begin
    IntValue:= Value;
    Result:= True;
  end
  else
    Result:= False;
end;

procedure TAeroPartImage.Change;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

{ TAeroButtonImage }

Constructor TAeroButtonImage.Create;
begin
  Inherited Create;
  fPartDown:= 0;
  fPartNormal:= 0;
  fPartDisabled:= 0;
  fPartHightLight:= 0;
  fPartFocused:= 0;
end;

function TAeroButtonImage.PartSize: TSize;
begin
  Result.cx:= PartWidth;
  Result.cy:= PartHeight;
end;

procedure TAeroButtonImage.SetImagePart(const Index, Value: Integer);
begin
  case Index of
    0: if UpDateValue(fPartNormal,Value) then Change;
    1: if UpDateValue(fPartHightLight,Value) then Change;
    2: if UpDateValue(fPartDown,Value) then Change;
    3: if UpDateValue(fPartDisabled,Value) then Change;
    4: if UpDateValue(fPartFocused,Value) then Change;
  end;
end;

end.
