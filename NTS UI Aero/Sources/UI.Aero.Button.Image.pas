{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Button.Image;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils,
  System.Classes,
  System.Types,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.CommCtrl,
  Winapi.UxTheme,
  Winapi.DwmApi,
  Winapi.GDIPAPI,
  Winapi.GDIPOBJ,
  Winapi.GDIPUTIL,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Themes,
  Vcl.Imaging.pngimage,
  Vcl.StdCtrls,
  {$ELSE}
  SysUtils, Windows, Messages, Classes, Controls, Graphics, CommCtrl, Types,
  Themes, UxTheme, DwmApi, PNGImage, StdCtrls, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  Winapi.GDIPUTIL,
  {$ENDIF}
  NTS.Code.Common.Types,
  UI.Aero.Core.BaseControl,
  UI.Aero.Core.CustomControl.Animation,
  UI.Aero.Button.Custom,
  UI.Aero.Core.Images,
  UI.Aero.Globals;

type
  TAeroImageButton = Class(TAeroCustomImageButton)
  Protected
    function GetRenderState: TARenderConfig; override;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer); override;
    procedure ClassicRender(const ACanvas: TCanvas; const DrawState: Integer); override;
    procedure PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer); override;
  Published
    Property AutoSize;
  End;

implementation

{ TAeroImageButton }

function TAeroImageButton.GetRenderState: TARenderConfig;
begin
  Result:= [];
end;

procedure TAeroImageButton.PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer);
begin

end;

function TAeroImageButton.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result:= True;
  if Image.DataLoaded then
  begin
    NewWidth:= Image.PartWidth;
    NewHeight:= Image.PartHeight;
  end;
end;

procedure TAeroImageButton.ClassicRender(const ACanvas: TCanvas; const DrawState: Integer);
begin
  if Image.DataLoaded then
  case TAeroButtonState(DrawState) of
    bsNormal    : AeroPicture.DrawPart(ACanvas.Handle,Image.Data.Canvas.Handle,Point(0,0),Image.PartSize,Image.PartNormal,Image.Orientation);
    bsHightLight: AeroPicture.DrawPart(ACanvas.Handle,Image.Data.Canvas.Handle,Point(0,0),Image.PartSize,Image.PartHightLight,Image.Orientation);
    bsFocused   : AeroPicture.DrawPart(ACanvas.Handle,Image.Data.Canvas.Handle,Point(0,0),Image.PartSize,Image.PartFocused,Image.Orientation);
    bsDown      : AeroPicture.DrawPart(ACanvas.Handle,Image.Data.Canvas.Handle,Point(0,0),Image.PartSize,Image.PartDown,Image.Orientation);
    bsDisabled  : AeroPicture.DrawPart(ACanvas.Handle,Image.Data.Canvas.Handle,Point(0,0),Image.PartSize,Image.PartDisabled,Image.Orientation);
  end;
end;

procedure TAeroImageButton.RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer);
begin
  if Image.DataLoaded then
  case TAeroButtonState(DrawState) of
    bsNormal    : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,Point(0,0),Image.PartSize,Image.PartNormal,Image.Orientation);
    bsHightLight: AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,Point(0,0),Image.PartSize,Image.PartHightLight,Image.Orientation);
    bsFocused   : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,Point(0,0),Image.PartSize,Image.PartFocused,Image.Orientation);
    bsDown      : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,Point(0,0),Image.PartSize,Image.PartDown,Image.Orientation);
    bsDisabled  : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,Point(0,0),Image.PartSize,Image.PartDisabled,Image.Orientation);
  end;
end;

end.
