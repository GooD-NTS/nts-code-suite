{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Button;

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
  Themes, UxTheme, DwmApi, pngimage, StdCtrls, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  Winapi.GDIPUTIL,
{$ENDIF}
  NTS.Code.Common.Types,
  UI.Aero.Core.BaseControl,
  UI.Aero.Core.CustomControl.Animation,
  UI.Aero.Button.Custom,
  UI.Aero.Globals,
  UI.Aero.Core;

type
  TCustomAeroButton = Class(TAeroCustomButton)
  private
    fFlatStyle: boolean;
    procedure setFlatStyle(const Value: boolean);
  protected
    function GetRenderState: TARenderConfig; override;
    function GetThemeClassName: PWideChar; override;
    procedure RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer); override;
    procedure ClassicRender(const ACanvas: TCanvas; const DrawState: Integer); override;
  published

  public
    constructor Create(AOwner: TComponent); override;
  published
    property DesigningRect default False;
    property AnimationDuration default 250;
    property FlatStyle: boolean read fFlatStyle write setFlatStyle default False;
  end;

  TAeroButton = class(TCustomAeroButton)
  const
    TextFormat = (DT_CENTER or DT_VCENTER or DT_SINGLELINE);
  protected
    procedure PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer); override;
    procedure RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer); override;
    procedure ClassicRender(const ACanvas: TCanvas; const DrawState: Integer); override;
  published
    property Caption;
  end;

const
  aclSystemBaseLowColor = $33FFFFFF;
  aclSystemBaseMediumLowColor = $66FFFFFF;

type
  TAeroColorButton = class(TCustomAeroButton)
  const
    CL_TEXT_FORMAT = (DT_CENTER or DT_VCENTER or DT_SINGLELINE);
  private
    FColorNormal: TGPColorValue;
    FColorHover: TGPColorValue;
    FColorDown: TGPColorValue;
    FColorDisabled: TGPColorValue;
    FColorFocused: TGPColorValue;
    FAutoSizeTextDeltaX: Integer;
    FAutoSizeTextDeltaY: Integer;
    FColorBorderHover: TGPColorValue;
    FColorBorderFocused: TGPColorValue;
    FColorBorderDown: TGPColorValue;
    FColorBorderNormal: TGPColorValue;
    FColorBorderDisabled: TGPColorValue;
    procedure SetButtonColor(const Index: Integer; const Value: TGPColorValue);
    procedure SetButtonBorderColor(const Index: Integer; const Value: TGPColorValue);
  protected
    procedure PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer); override;
    procedure RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer); override;
    procedure ClassicRender(const ACanvas: TCanvas; const DrawState: Integer); override;
    function GetRenderState: TARenderConfig; override;
    function CanAutoSize(var NewWidth: Integer; var NewHeight: Integer): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption;

    property AutoSize default False;
    property AutoSizeTextDeltaX: Integer read FAutoSizeTextDeltaX write FAutoSizeTextDeltaX;
    property AutoSizeTextDeltaY: Integer read FAutoSizeTextDeltaY write FAutoSizeTextDeltaY;

    property ColorNormal: TGPColorValue index 0 read FColorNormal write SetButtonColor default aclSystemBaseLowColor;
    property ColorHover: TGPColorValue index 1 read FColorHover write SetButtonColor default aclSystemBaseLowColor;
    property ColorDown: TGPColorValue index 2 read FColorDown write SetButtonColor default aclSystemBaseMediumLowColor;
    property ColorDisabled: TGPColorValue index 3 read FColorDisabled write SetButtonColor default aclSystemBaseLowColor;
    property ColorFocused: TGPColorValue index 4 read FColorFocused write SetButtonColor default aclSystemBaseLowColor;

    property ColorBorderNormal: TGPColorValue index 0 read FColorBorderNormal write SetButtonBorderColor default aclTransparent;
    property ColorBorderHover: TGPColorValue index 1 read FColorBorderHover write SetButtonBorderColor default aclSystemBaseMediumLowColor;
    property ColorBorderDown: TGPColorValue index 2 read FColorBorderDown write SetButtonBorderColor default aclTransparent;
    property ColorBorderDisabled: TGPColorValue index 3 read FColorBorderDisabled write SetButtonBorderColor default aclTransparent;
    property ColorBorderFocused: TGPColorValue index 4 read FColorBorderFocused write SetButtonBorderColor default aclTransparent;
  end;

implementation

Uses
  UI.Aero.Window;

{ TCustomAeroButton }

constructor TCustomAeroButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DesigningRect := False;
  AnimationDuration := 250;
  fFlatStyle := False;
  Width := 75;
  Height := 25;
end;

function TCustomAeroButton.GetRenderState: TARenderConfig;
begin
  Result := [];
end;

function TCustomAeroButton.GetThemeClassName: PWideChar;
begin
  Result := VSCLASS_BUTTON;
end;

procedure TCustomAeroButton.ClassicRender(const ACanvas: TCanvas; const DrawState: Integer);
var
  StateID: Integer;
  clRect: TRect;
begin
  StateID := DFCS_HOT;
  case TAeroButtonState(DrawState) of
    bsNormal:
      StateID := DFCS_BUTTONPUSH or DFCS_HOT;
    bsHightLight:
      StateID := DFCS_BUTTONPUSH or DFCS_HOT;
    bsFocused:
      StateID := DFCS_BUTTONPUSH or DFCS_HOT;
    bsDown:
      StateID := DFCS_BUTTONPUSH or DFCS_PUSHED;
    bsDisabled:
      begin
        StateID := DFCS_BUTTONPUSH or DFCS_FLAT;
        ACanvas.Font.Color := clGrayText;
      end;
  end;
  clRect := GetClientRect;
  DrawFrameControl(ACanvas.Handle, clRect, DFC_BUTTON, StateID);
end;

procedure TCustomAeroButton.RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer);
var
  PartID, StateID: Integer;
  clRect: TRect;
begin
  clRect := GetClientRect;
  if fFlatStyle then
  begin
    if AeroCore.RunWindowsVista then
      PartID := BP_COMMANDLINK
    else
      PartID := BP_PUSHBUTTON;
  end
  else
    PartID := BP_PUSHBUTTON;
  StateID := PBS_NORMAL;
  case TAeroButtonState(DrawState) of
    bsNormal:
      StateID := PBS_NORMAL;
    bsHightLight:
      StateID := PBS_HOT;
    bsFocused:
      StateID := PBS_DEFAULTED;
    bsDown:
      StateID := PBS_PRESSED;
    bsDisabled:
      StateID := PBS_DISABLED;
  end;
  DrawThemeBackground(ThemeData, PaintDC, PartID, StateID, clRect, @clRect);
end;

procedure TCustomAeroButton.setFlatStyle(const Value: boolean);
begin
  if fFlatStyle <> Value then
  begin
    fFlatStyle := Value;
    Invalidate;
  end;
end;

{ TAeroButton }

procedure TAeroButton.PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer);
begin

end;

procedure TAeroButton.RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer);
var
  PartID, StateID: Integer;
begin
  Inherited RenderState(PaintDC, Surface, RConfig, DrawState);
  PartID := BP_PUSHBUTTON;
  StateID := PBS_NORMAL;
  case TAeroButtonState(DrawState) of
    bsNormal:
      StateID := PBS_NORMAL;
    bsHightLight:
      StateID := PBS_HOT;
    bsFocused:
      StateID := PBS_DEFAULTED;
    bsDown:
      StateID := PBS_PRESSED;
    bsDisabled:
      StateID := PBS_DISABLED;
  end;
  AeroCore.RenderText(PaintDC, ThemeData, PartID, StateID, Self.Font,
    TextFormat, GetClientRect, Caption, False);
end;

procedure TAeroButton.ClassicRender(const ACanvas: TCanvas; const DrawState: Integer);
var
  clRect: TRect;
begin
  inherited ClassicRender(ACanvas, DrawState);

  clRect := GetClientRect;
  clRect := Rect(clRect.Left + 3, clRect.Top + 3, clRect.Right - 3, clRect.Bottom - 3);
  AeroCore.RenderText(ACanvas.Handle, Self.Font, TextFormat, clRect, Caption);

  if Focused then
    ACanvas.DrawFocusRect(clRect);
end;

{ TColorButton }

constructor TAeroColorButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoSize := False;
  Font.Color := clWhite;

  FColorNormal := aclSystemBaseLowColor;
  FColorHover := aclSystemBaseLowColor;
  FColorDown := aclSystemBaseMediumLowColor;
  FColorDisabled := aclSystemBaseLowColor;
  FColorFocused := aclSystemBaseLowColor;

  FColorBorderNormal := aclTransparent;
  FColorBorderHover := aclSystemBaseMediumLowColor;
  FColorBorderDown := aclTransparent;
  FColorBorderDisabled := aclTransparent;
  FColorBorderFocused := aclTransparent;

  FAutoSizeTextDeltaX := 10;
  FAutoSizeTextDeltaY := 12;
end;

function TAeroColorButton.GetRenderState: TARenderConfig;
begin
  Result := [arsGDIP];
end;

function TAeroColorButton.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;

  function GetTextSize(): TSize;
  begin
    if Assigned(Parent) then
    begin
      Canvas.Font := Self.Font;
      Result := Canvas.TextExtent(Caption);
    end
    else
    begin
      Result.cx := ClientWidth;
      Result.cy := ClientHeight;
    end;
  end;

var
  textSize: TSize;
begin
  Result := True;
  textSize := GetTextSize();

  if IsRunTime or (textSize.cx > 0) and (textSize.cy > 0) then
  begin
    if Align in [alNone, alLeft, alRight] then
      NewWidth := textSize.cx + FAutoSizeTextDeltaX;

    if Align in [alNone, alTop, alBottom] then
      NewHeight := textSize.cy + FAutoSizeTextDeltaY;
  end;
end;

procedure TAeroColorButton.SetButtonBorderColor(const Index: Integer; const Value: TGPColorValue);
begin
  case Index of
    0: FColorBorderNormal := Value;
    1: FColorBorderHover := Value;
    2: FColorBorderDown := Value;
    3: FColorBorderDisabled := Value;
    4: FColorBorderFocused := Value;
  end;
  Invalidate;
end;

procedure TAeroColorButton.SetButtonColor(const Index: Integer; const Value: TGPColorValue);
begin
  case Index of
    0: FColorNormal := Value;
    1: FColorHover := Value;
    2: FColorDown := Value;
    3: FColorDisabled := Value;
    4: FColorFocused := Value;
  end;
  Invalidate;
end;

procedure TAeroColorButton.RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer);
var
  backgroundBrush: TGPBrush;
  backgroundRect: TGPRect;
  borderPen: TGPPen;
begin
  case TAeroButtonState(DrawState) of
    bsNormal:
    begin
      backgroundBrush := TGPSolidBrush.Create(FColorNormal);
      borderPen := TGPPen.Create(FColorBorderNormal);
    end;
    bsHightLight:
    begin
      backgroundBrush := TGPSolidBrush.Create(FColorHover);
      borderPen := TGPPen.Create(FColorBorderHover);
    end;
    bsFocused:
    begin
      backgroundBrush := TGPSolidBrush.Create(FColorFocused);
      borderPen := TGPPen.Create(FColorBorderFocused);
    end;
    bsDown:
    begin
      backgroundBrush := TGPSolidBrush.Create(FColorDown);
      borderPen := TGPPen.Create(FColorBorderDown);
    end;
    bsDisabled:
    begin
      backgroundBrush := TGPSolidBrush.Create(FColorDisabled);
      borderPen := TGPPen.Create(FColorBorderDisabled);
    end;
  else
    begin
      backgroundBrush := TGPSolidBrush.Create(aclWhite);
      borderPen := TGPPen.Create(aclBlack);
    end;
  end;
  borderPen.SetWidth(4);

  backgroundRect := MakeRect(0, 0, ClientWidth, ClientHeight);
  Surface.SetClip(backgroundRect);
  Surface.FillRectangle(backgroundBrush, backgroundRect);
  Surface.ResetClip();
  backgroundBrush.Free();

  Surface.DrawRectangle(borderPen, backgroundRect);
  borderPen.Free();

  AeroCore.RenderText(PaintDC, Self.Font, TAeroButton.TextFormat, ClientRect, Caption);
end;

procedure TAeroColorButton.ClassicRender(const ACanvas: TCanvas; const DrawState: Integer);
var
  clRect: TRect;
begin
  inherited ClassicRender(ACanvas, DrawState);
  Self.Font.Color := clBtnText;

  clRect := GetClientRect;
  clRect := Rect(clRect.Left + 3, clRect.Top + 3, clRect.Right - 3, clRect.Bottom - 3);
  AeroCore.RenderText(ACanvas.Handle, Self.Font, CL_TEXT_FORMAT, clRect, Caption);

  if Focused then
    ACanvas.DrawFocusRect(clRect);
end;

procedure TAeroColorButton.PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer);
begin
  // Nothig here
end;

end.

