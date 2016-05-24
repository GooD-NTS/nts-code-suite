{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Labels;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils,
  System.Classes,

  Winapi.Windows,
  Winapi.Messages,
  Winapi.UxTheme,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Themes,
  {$ELSE}
  SysUtils, Windows, Messages, Classes, Controls, Graphics, CommCtrl,
  Themes, UxTheme, DwmApi, PNGImage, StdCtrls,
  {$ENDIF}
  Winapi.GDIPOBJ,
  NTS.Code.Common.Types,
  UI.Aero.Core.BaseControl,
  UI.Aero.Core.CustomControl,
  UI.Aero.Globals,
  UI.Aero.Core;

type
  TAeroLabel = Class(TCustomAeroControl)
  private
    FLayout: TTextLayout;
    FAlignment: TAlignment;
    FWordWrap: Boolean;
    fTextGlow: BooLean;
    function GetTextFormat: DWORD;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetLayout(const Value: TTextLayout);
    procedure SetWordWrap(const Value: Boolean);
    function GetTextSize: TSize;
    procedure SetTextGlow(const Value: BooLean);
  protected
    function GetRenderState: TRenderConfig; OverRide;
    procedure ClassicRender(const ACanvas: TCanvas); OverRide;
    procedure ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig); OverRide;
    function GetThemeClassName: PWideChar; override;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure PostRender(const Surface: TCanvas; const RConfig: TRenderConfig); override;
    function GetCaptionRect: TRect;
  public
    Constructor Create(AOwner: TComponent); OverRide;
  published
    property Caption;
    property AutoSize Default True;
    property TextGlow: BooLean Read fTextGlow Write SetTextGlow Default False;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Layout: TTextLayout read FLayout write SetLayout default tlTop;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
  End;

implementation

Uses
  UI.Aero.Window;

{ TAeroLabel }

constructor TAeroLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoSize:= True;
  FAlignment:= taLeftJustify;
  FLayout:= tlTop;
  FWordWrap:= False;
  fTextGlow:= False;
end;

function TAeroLabel.GetRenderState: TRenderConfig;
begin
  Result:= [rsBuffer];
end;

function TAeroLabel.GetTextFormat: DWORD;
begin
  Result:= 0;
  if not FWordWrap then
    Result:= Result or DT_SINGLELINE;
  case FLayout of
    tlTop   : Result:= Result or DT_TOP;
    tlCenter: Result:= Result or DT_VCenter;
    tlBottom: Result:= Result or DT_Bottom;
  end;

  case FAlignment of
    taLeftJustify : Result:= Result or DT_LEFT;
    taRightJustify: Result:= Result or DT_RIGHT;
    taCenter      : Result:= Result or DT_Center;
  end;
end;

function TAeroLabel.GetTextSize: TSize;
begin
  if Assigned(Parent) then
  begin
    Canvas.Font:= Self.Font;
    Result:= Canvas.TextExtent(Caption);
    if fTextGlow then
    begin
      Result.cx:= Result.cx + 24;
      Result.cy:= Result.cy + 24;
    end;
  end
  else
  begin
    Result.cx:= ClientWidth;
    Result.cy:= ClientHeight;
  end;
end;

function TAeroLabel.GetThemeClassName: PWideChar;
begin
  Result:= VSCLASS_WINDOW;
end;

procedure TAeroLabel.PostRender(const Surface: TCanvas;const RConfig: TRenderConfig);
begin

end;

procedure TAeroLabel.SetAlignment(const Value: TAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment:= Value;
    Invalidate;
  end;
end;

procedure TAeroLabel.SetLayout(const Value: TTextLayout);
begin
  if FLayout <> Value then
  begin
    FLayout:= Value;
    Invalidate;
  end;
end;

procedure TAeroLabel.SetTextGlow(const Value: BooLean);
begin
  if fTextGlow <> Value then
  begin
    fTextGlow:= Value;
    Invalidate;
    if AutoSize then
      SetBounds(Left,Top,Width+1,Height+1);
  end;
end;

procedure TAeroLabel.SetWordWrap(const Value: Boolean);
begin
  if FWordWrap <> Value then
  begin
    FWordWrap:= Value;
    Invalidate;
  end;
end;

function TAeroLabel.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result:= True;
  with GetTextSize do
  if IsRunTime or (cx > 0) and (cy > 0) then
  begin
    if Align in [alNone, alLeft, alRight] then
      NewWidth:= cx;
    if Align in [alNone, alTop, alBottom] then
      NewHeight := cy;
  end;
end;

procedure TAeroLabel.ClassicRender(const ACanvas: TCanvas);
begin
  AeroCore.RenderText(ACanvas.Handle, Self.Font, GetTextFormat, GetCaptionRect,
    Caption);
end;

procedure TAeroLabel.ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig);
begin
  AeroCore.RenderText(PaintDC, ThemeData, 1, 1, Self.Font, GetTextFormat,
    GetCaptionRect, Caption, fTextGlow);
end;

function TAeroLabel.GetCaptionRect: TRect;
begin
  Result:= GetClientRect;
  if fTextGlow then
    Result.Left:= Result.Left+8;
end;

end.
