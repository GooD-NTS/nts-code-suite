{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Button.Task;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.UxTheme,
  Winapi.DwmApi,
  Winapi.GDIPAPI,
  Winapi.GDIPOBJ,
  Winapi.GDIPUTIL,
  Winapi.CommCtrl,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Themes,
  Vcl.Imaging.pngimage,
  Vcl.StdCtrls,
  {$ELSE}
  SysUtils, Windows, Messages, Classes, Controls, Graphics, CommCtrl,
  Themes, UxTheme, DwmApi, PNGImage, StdCtrls, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  Winapi.GDIPUTIL,
  {$ENDIF}
  NTS.Code.Common.Types,
  UI.Aero.Core.BaseControl,
  UI.Aero.Core.CustomControl.Animation,
  UI.Aero.Button.Custom,
  UI.Aero.Globals,
  UI.Aero.Core,
  UI.Aero.Core.Images;

type
  TAeroTaskButton = class(TAeroCustomImageButton)
  const
    lTextFormat = (DT_SINGLELINE or DT_VCENTER or DT_CENTER);
  private
    fImagePos: TTaskButtonImagePos;
    fDrawGlow: Boolean;
    procedure SetImagePos(const Value: TTaskButtonImagePos);
    procedure SetDrawGlow(const Value: Boolean);
    procedure SetTextStyle(const DrawState: Integer);
  Protected
    function GetThemeClassName: PWideChar; override;
    function GetRenderState: TARenderConfig; override;
    procedure RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer); override;
    procedure ClassicRender(const ACanvas: TCanvas; const DrawState: Integer); override;
    procedure DrawButtonImage(const PaintDC: hDC; const DrawState: TAeroButtonState);
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    function GetContentSize: TSize;
    function GetTextRect: TRect;
    procedure PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer); override;
  Public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
  Published
    property AutoSize Default True;
    property Caption;
    property Cursor Default crHandPoint;
    property ImagePos: TTaskButtonImagePos Read fImagePos Write SetImagePos Default tbLeft;
    property DrawGlow: Boolean Read fDrawGlow Write SetDrawGlow Default False;
  end;

implementation

Uses
  UI.Aero.Window, Math;
  
{ TAeroTaskButton }

constructor TAeroTaskButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoSize:= True;
  fDrawGlow:= False;
  Cursor:= crHandPoint;
  fImagePos:= tbLeft;
end;

destructor TAeroTaskButton.Destroy;
begin

  inherited Destroy;
end;

procedure TAeroTaskButton.SetTextStyle(const DrawState: Integer);
begin
  case TAeroButtonState(DrawState) of
    bsNormal:
      begin
        Self.Font.Color := $CC6600;
        Self.Font.Style := [];
      end;
    bsHightLight:
      begin
        Self.Font.Color := $FF9933;
        Self.Font.Style := [fsUnderline];
      end;
    bsFocused:
      begin
        Self.Font.Color := $CC6600;
        Self.Font.Style := [fsUnderline];
      end;
    bsDown:
      begin
        Self.Font.Color := $804000;
        Self.Font.Style := [fsUnderline];
      end;
    bsDisabled:
      begin
        Self.Font.Color := $9C857E;
        Self.Font.Style := [fsUnderline];
      end;
  end;
end;

function TAeroTaskButton.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result:= True;
  with GetContentSize do
  if IsRunTime or (cx > 0) and (cy > 0) then
  begin
    if Align in [alNone, alLeft, alRight] then
      NewWidth:= cx;
    if Align in [alNone, alTop, alBottom] then
      NewHeight := cy;
  end;
end;

function TAeroTaskButton.GetContentSize: TSize;
var
  TextSize: TSize;
  ImageSize: TSize;
begin
  TextSize.cx:= 0;
  TextSize.cy:= 0;
  ImageSize.cx:= 0;
  ImageSize.cy:= 0;
  if Assigned(Parent) then
  begin
    if ButtonState = bsNormal then
      Self.Font.Style:= []
    else
      Self.Font.Style:= [fsUnderline];
    Canvas.Font:= Self.Font;
    TextSize:= Canvas.TextExtent(Caption);
    if fDrawGlow then
    begin
      TextSize.cx:= TextSize.cx+24;
      TextSize.cy:= TextSize.cy+24;
    end;
    if Assigned(Image.Data) then
      ImageSize:= Image.PartSize;
    Result.cY:= Max(ImageSize.cy,TextSize.cy);
    Result.cX:= ImageSize.cx + TextSize.cx + 4;
  end
  else
  begin
    Result.cx:= ClientWidth;
    Result.cy:= ClientHeight;
  end;
end;

procedure TAeroTaskButton.SetDrawGlow(const Value: Boolean);
begin
  if fDrawGlow <> Value then
  begin
    fDrawGlow:= Value;
    if AutoSize then
      SetBounds(Left,Top,Width+1,Height-1);
    Invalidate;
  end;
end;

procedure TAeroTaskButton.SetImagePos(const Value: TTaskButtonImagePos);
begin
  if fImagePos <> Value then
  begin
    fImagePos:= Value;
    Invalidate;
  end;
end;

function TAeroTaskButton.GetRenderState: TARenderConfig;
begin
  Result:= [];
end;

function TAeroTaskButton.GetTextRect: TRect;
begin
  if Assigned(Image.Data) then
  begin
    Result:= ClientRect;
    if fDrawGlow then
    begin

    end
    else
    case fImagePos of
      tbLeft : Result.Left:= Result.Left+(Image.PartWidth+4);
      tbRight: Result.Right:= Result.Right-(Image.PartWidth+4);
    end;
  end
  else
    Result:= ClientRect;
end;

function TAeroTaskButton.GetThemeClassName: PWideChar;
begin
  Result:= VSCLASS_BUTTON;
end;

procedure TAeroTaskButton.PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer);
begin
  // nothing here
end;

procedure TAeroTaskButton.ClassicRender(const ACanvas: TCanvas; const DrawState: Integer);
begin
  if Assigned(Image.Data) then
    DrawButtonImage(ACanvas.Handle,ButtonState);
  SetTextStyle(DrawState);
  AeroCore.RenderText(ACanvas.Handle,Self.Font,lTextFormat,GetTextRect,Caption);
end;

procedure TAeroTaskButton.DrawButtonImage(const PaintDC: hDC; const DrawState: TAeroButtonState);
var
  ImgPos: TPoint;
begin
  ImgPos.Y:= (Self.Height div 2)-(Image.PartHeight div 2);
  case fImagePos of
    tbLeft : ImgPos.X:= 0;
    tbRight: ImgPos.X:= Self.Width-Image.PartWidth;
  end;

  case DrawState of
    bsNormal    : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,Image.PartSize,Image.PartNormal,Image.Orientation);
    bsHightLight: AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,Image.PartSize,Image.PartHightLight,Image.Orientation);
    bsFocused   : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,Image.PartSize,Image.PartNormal,Image.Orientation);
    bsDown      : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,Image.PartSize,Image.PartDown,Image.Orientation);
    bsDisabled  : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,Image.PartSize,Image.PartDisabled,Image.Orientation);
  end;
end;

procedure TAeroTaskButton.RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer);
begin
  if Assigned(Image.Data) then
    DrawButtonImage(PaintDC,ButtonState);
  SetTextStyle(DrawState);
  AeroCore.RenderText(PaintDC, ThemeData, BP_PUSHBUTTON, PBS_NORMAL, Self.Font,
    lTextFormat, GetTextRect, Caption, fDrawGlow);
end;

end.
