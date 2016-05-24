{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Panel;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils,
  System.Classes,

  Winapi.Windows,
  Winapi.Messages,
  Winapi.UxTheme,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,

  Vcl.Graphics,
  Vcl.Controls,
  {$ELSE}
  Windows, Messages, SysUtils, Classes, Controls, Graphics, Themes, UxTheme,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  {$ENDIF}
  NTS.Code.Common.Types,
  UI.Aero.Core.CustomControl,
  UI.Aero.Globals;

type
  TAeroPanel = Class(TCustomAeroControl)
  private
    fBorder: TBevelEdges;
    fGradientColor,
    fBorderColor: TColor;
    fAlphaGradientColor: TGPColorValue;
    fAlphaBorderColor: TGPColorValue;
    fAlphaColor: TGPColorValue;
    fBackGround: TAeroBackGround;
    fGradientType: LinearGradientMode;
    fWrapMode: TWrapMode;
    fTexture: TImageFileName;
    procedure SetBorder(const Value: TBevelEdges);
    procedure SetAlphaBorderColor(const Value: TGPColorValue);
    procedure SetAlphaColor(const Value: TGPColorValue);
    procedure SetAlphaGradientColor(const Value: TGPColorValue);
    procedure SetBackGround(const Value: TAeroBackGround);
    procedure SetGradientType(const Value: LinearGradientMode);
    function CreateGPBrush(const AGPRect: TGPRect;var Image: TGPImage): TGPBrush;
    function CreateGPRect: TGPRect;
    procedure SetWrapMode(const Value: TWrapMode);
    function CreateGPImage: TGPImage;
    procedure SetTexture(const Value: TImageFileName);
  Protected
    function GetRenderState: TRenderConfig; OverRide;
    procedure ClassicRender(const ACanvas: TCanvas); OverRide;
    procedure ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig); OverRide;
    procedure DarwBorder(Surface: TGPGraphics);
    procedure PostRender(const Surface: TCanvas; const RConfig: TRenderConfig); override;
  Public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
  Published
    property Border: TBevelEdges Read fBorder Write SetBorder Default [];

    Property AlphaColor: TGPColorValue Read fAlphaColor Write SetAlphaColor default aclNavy;
    Property AlphaGradientColor: TGPColorValue Read fAlphaGradientColor Write SetAlphaGradientColor default aclWhite;
    Property AlphaBorderColor: TGPColorValue Read fAlphaBorderColor Write SetAlphaBorderColor default aclBlack;

    Property BackGround: TAeroBackGround Read fBackGround Write SetBackGround default bgSolid;
    Property GradientType: LinearGradientMode Read fGradientType Write SetGradientType default LinearGradientModeHorizontal;

    Property TextureWrapMode: TWrapMode Read fWrapMode Write SetWrapMode default WrapModeTile;
    Property Texture: TImageFileName Read fTexture Write SetTexture;
    

  End;

implementation

{ TAeroPanel }

constructor TAeroPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle:= ControlStyle+[csAcceptsControls];
  fBorder:= [];
//
  fAlphaColor:= aclNavy;
  fAlphaGradientColor:= aclWhite;
  fAlphaBorderColor:= aclBlack;
//
  Color:= RGB(GetRed(fAlphaColor),GetGreen(fAlphaColor),GetBlue(fAlphaColor));
  fGradientColor:= RGB(GetRed(fAlphaGradientColor),GetGreen(fAlphaGradientColor),GetBlue(fAlphaGradientColor));
  fBorderColor:= RGB(GetRed(fAlphaBorderColor),GetGreen(fAlphaBorderColor),GetBlue(fAlphaBorderColor));
//
  fBackGround:= bgSolid;
  fGradientType:= LinearGradientModeHorizontal;
//
  fWrapMode:= WrapModeTile;
  fTexture:= '';
end;

destructor TAeroPanel.Destroy;
begin

  inherited Destroy;
end;

function TAeroPanel.GetRenderState: TRenderConfig;
begin
  Result:= [rsBuffer, rsGDIP];
end;

procedure TAeroPanel.PostRender(const Surface: TCanvas; const RConfig: TRenderConfig);
begin

end;

procedure TAeroPanel.SetAlphaBorderColor(const Value: TGPColorValue);
begin
  if fAlphaBorderColor <> Value then
  begin
    fAlphaBorderColor:= Value;
    fBorderColor:= RGB(GetRed(Value),GetGreen(Value),GetBlue(Value));
    Invalidate;
  end;
end;

procedure TAeroPanel.SetAlphaColor(const Value: TGPColorValue);
begin
  if fAlphaColor <> Value then
  begin
    fAlphaColor:= Value;
    Color:= RGB(GetRed(Value),GetGreen(Value),GetBlue(Value));
  end;
end;

procedure TAeroPanel.SetAlphaGradientColor(const Value: TGPColorValue);
begin
  if fAlphaGradientColor <> Value then
  begin
    fAlphaGradientColor:= Value;
    fGradientColor:= RGB(GetRed(Value),GetGreen(Value),GetBlue(Value));
    Invalidate;
  end;
end;

procedure TAeroPanel.SetBackGround(const Value: TAeroBackGround);
begin
  if fBackGround <> Value then
  begin
    fBackGround:= Value;
    Invalidate;
  end;
end;

procedure TAeroPanel.SetBorder(const Value: TBevelEdges);
begin
  if fBorder <> Value then
  begin
    fBorder:= Value;
    Invalidate;
  end;
end;

procedure TAeroPanel.SetGradientType(const Value: LinearGradientMode);
begin
  if fGradientType <> Value then
  begin
    fGradientType:= Value;
    Invalidate;
  end;
end;

procedure TAeroPanel.SetTexture(const Value: TImageFileName);
begin
  if fTexture <> Value then
  begin
    fTexture:= Value;
    Invalidate;
  end;
end;

procedure TAeroPanel.SetWrapMode(const Value: TWrapMode);
begin
  if fWrapMode <> Value then
  begin
    fWrapMode:= Value;
    Invalidate;
  end;
end;

procedure TAeroPanel.ClassicRender(const ACanvas: TCanvas);
begin
  // {$Message HINT 'Доделать и исправить наконец эту долбаную панель!'}
end;

function TAeroPanel.CreateGPBrush(const AGPRect: TGPRect;var Image: TGPImage): TGPBrush;
begin
  Result:= nil;
  case fBackGround of
    bgSolid   : Result:= TGPSolidBrush.Create(fAlphaColor);
    bgGradient: Result:= TGPLinearGradientBrush.Create(AGPRect,fAlphaColor,fAlphaGradientColor,fGradientType);
    bgTexture : Result:= TGPTextureBrush.Create(Image,fWrapMode,0,0,Image.GetWidth,Image.GetHeight);
  end;
end;

function TAeroPanel.CreateGPImage: TGPImage;
begin
  if FileExists(fTexture) then
  begin
    Result:= TGPImage.Create(fTexture);
  end
  else
    Result:= nil;
end;

function TAeroPanel.CreateGPRect: TGPRect;
begin
  Result:= MakeRect(0, 0, ClientWidth, ClientHeight);
  if beLeft in fBorder then Result.X:= 0;
  if beTop in fBorder then Result.Y:= 0;

  if beRight in fBorder then
  begin
    if beLeft in fBorder then
      Result.Width:= Result.Width-1
    else
      Result.Width:= Result.Width-1;
  end;
  if beBottom in fBorder then
  begin
    if beTop in fBorder then
      Result.Height:= Result.Height-1
    else
      Result.Height:= Result.Height-1;
  end;
end;

procedure TAeroPanel.DarwBorder(Surface: TGPGraphics);
var
  ARect: TGPRect;
  GPen: TGPPen;
begin
  GPen:= TGPPen.Create(fAlphaBorderColor);
  ARect:= MakeRect(-1,-1,ClientWidth+1,ClientHeight+1);
  if beLeft in fBorder then
    ARect.X:= 0;
  if beTop in fBorder then
    ARect.Y:= 0;
  if beRight in fBorder then
  begin
    if beLeft in fBorder then
      ARect.Width:= ClientWidth-1
    else
      ARect.Width:= ClientWidth;
  end;
  if beBottom in fBorder then
  begin
    if beTop in fBorder then
      ARect.Height:= ClientHeight-1
    else
      ARect.Height:= ClientHeight;
  end;
  Surface.DrawRectangle(GPen,ARect);
  GPen.Free;
end;

procedure TAeroPanel.ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig);
var                                                     
  ARect: TGPRect;
  Brush: TGPBrush;
  Image: TGPImage;
begin
  if (fBorder <> []) then DarwBorder(Surface);
//
  ARect:= CreateGPRect;
  Image:= CreateGPImage;
  Brush:= CreateGPBrush(ARect,Image);
//
  Surface.SetClip(ARect);
  Surface.FillRectangle(Brush,ARect);
  Surface.ResetClip;
//
  if Assigned(Image) then Image.Free;
  Brush.Free;
end;

end.
