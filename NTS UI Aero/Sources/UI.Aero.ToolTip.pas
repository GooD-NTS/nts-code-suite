{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.ToolTip;

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

  Vcl.Graphics,
  Vcl.Controls,
  {$ELSE}
  Windows, Messages, SysUtils, Classes, Controls, Graphics, Winapi.GDIPOBJ,
  Themes, UxTheme,
  {$ENDIF}
  UI.Aero.Core.CustomControl,
  UI.Aero.Globals,
  UI.Aero.Core;

type
  TAeroToolTip = Class(TCustomAeroControl)
  private
    fIcon: TToolTipIcon;
    IconHandle: hIcon;
    fIconPos: TToolTipIconPos;
    procedure SetIcon(const Value: TToolTipIcon);
    procedure SetIconPos(const Value: TToolTipIconPos);
  Protected
    function GetTextRect: TRect;
    procedure LoadNewIcon; Virtual;
    procedure DrawContent(const PaintDC: hDC);
    function GetIntIconSize: TSize;
  protected
    function GetRenderState: TRenderConfig; OverRide;
    function GetThemeClassName: PWideChar; override;
    procedure ClassicRender(const ACanvas: TCanvas); OverRide;
    procedure ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig); OverRide;
    procedure PostRender(const Surface: TCanvas; const RConfig: TRenderConfig); override;
  Public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
  Published
    Property Caption;
    Property Icon: TToolTipIcon Read fIcon Write SetIcon Default tiAsterisk;
    Property IconPos: TToolTipIconPos Read fIconPos Write SetIconPos Default tipLeft;
    Property DesigningRect Default False;
  End;

implementation

Uses
  UI.Aero.Window;

{ TAeroToolTip }

Constructor TAeroToolTip.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  DesigningRect:= False;
  fIcon:= tiAsterisk;
  fIconPos:= tipLeft;
  IconHandle:= 0;
  LoadNewIcon;
end;

Destructor TAeroToolTip.Destroy;
begin
  if IconHandle <> 0 then
    DestroyIcon(IconHandle);
  Inherited Destroy;
end;

function TAeroToolTip.GetIntIconSize: TSize;
begin
  Result.cx:= GetSystemMetrics(SM_CXICON);
  Result.cy:= GetSystemMetrics(SM_CYICON);
end;

function TAeroToolTip.GetRenderState: TRenderConfig;
begin
  Result:= [rsBuffer];
end;

function TAeroToolTip.GetTextRect: TRect;
begin
  Result:= Bounds(2,2,Width-4,Height-4);
  if IconHandle <> 0 then
  with GetIntIconSize do
  case fIconPos of
    tipLeft : Result.Left:= Result.Left+(cx+2);
    tipRight: Result.Right:= Result.Right-(cy+2);
  end;
end;

function TAeroToolTip.GetThemeClassName: PWideChar;
begin
  Result:= VSCLASS_TOOLTIP;
end;

procedure TAeroToolTip.LoadNewIcon;
const
  IDI_SHIELD = MakeIntResource(32518);
begin
  if IconHandle <> 0 then
    DestroyIcon(IconHandle);
  case fIcon of
    tiNone       : IconHandle:= 0;
    tiApplication: IconHandle:= LoadIcon(0,IDI_APPLICATION);
    tiHand       : IconHandle:= LoadIcon(0,IDI_HAND);
    tiQuestion   : IconHandle:= LoadIcon(0,IDI_QUESTION);
    tiExclamation: IconHandle:= LoadIcon(0,IDI_EXCLAMATION);
    tiAsterisk   : IconHandle:= LoadIcon(0,IDI_ASTERISK);
    tiWinLogo    : IconHandle:= LoadIcon(0,IDI_WINLOGO);
    tiShield     : IconHandle:= LoadIcon(0,IDI_SHIELD);
  end;
end;

procedure TAeroToolTip.PostRender(const Surface: TCanvas; const RConfig: TRenderConfig);
begin

end;

procedure TAeroToolTip.SetIcon(const Value: TToolTipIcon);
begin
  if fIcon <> Value then
  begin
    fIcon:= Value;
    LoadNewIcon;
    Invalidate;
  end;
end;

procedure TAeroToolTip.SetIconPos(const Value: TToolTipIconPos);
begin
  if fIconPos <> Value then
  begin
    fIconPos:= Value;
    Invalidate;
  end;
end;

procedure TAeroToolTip.ClassicRender(const ACanvas: TCanvas);
begin
  ACanvas.Pen.Color:= clWindowFrame;
  ACanvas.Brush.Color:= clInfoBk;
  ACanvas.FillRect(GetClientRect);
  DrawContent(ACanvas.Handle);
end;

procedure TAeroToolTip.ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig);
var
  clRect: TRect;
begin
  clRect:= GetClientRect;
  DrawThemeBackground(ThemeData,PaintDC,TTP_STANDARD,TTCS_NORMAL,clRect,@clRect);
  DrawContent(PaintDC);
end;

procedure TAeroToolTip.DrawContent(const PaintDC: hDC);
const
  TextFormat = (DT_LEFT or DT_TOP or DT_WORDBREAK);
begin
  if IconHandle <> 0 then
  case fIconPos of
    tipLeft : DrawIcon(PaintDC,2,2,IconHandle);
    tipRight: DrawIcon(PaintDC,Width-(GetIntIconSize.cx+2),2,IconHandle);
  end;
  if Caption <> '' then
    AeroCore.RenderText(PaintDC,ThemeData,TTP_STANDARD,TTCS_NORMAL,Self.Font,
      TextFormat,GetTextRect,Caption,false);
end;

end.
