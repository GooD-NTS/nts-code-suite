{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.ThemeElement;

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
  UI.Aero.Globals;

type
  TAeroThemeElement = Class;
  TAeroPaintThemeElementEvent = procedure(const Sender: TAeroThemeElement; PartID, StateID: Integer; Surface: TCanvas) of object;
  TAeroGetElementSizeEvent = procedure(Sender: TAeroThemeElement; PartID, StateID: Integer;var ASize: TSize) of object;

  TAeroThemeElement = Class(TCustomAeroControl)
  private
    fThemeClassName: String;
    fPartID: Integer;
    fStateID: Integer;
    fElementPaint: TAeroPaintThemeElementEvent;
    fGetElementSize: TAeroGetElementSizeEvent;
    procedure SetThemeClassName(const Value: String);
    procedure SetThemeID(const Index, Value: Integer);
  protected
    function GetRenderState: TRenderConfig; OverRide;
    function GetThemeClassName: PWideChar; OverRide;
    procedure ClassicRender(const ACanvas: TCanvas); OverRide;
    procedure ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig); OverRide;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure PostRender(const Surface: TCanvas;const RConfig: TRenderConfig); override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); OverRide;
    destructor Destroy; OverRide;
  published
    property AutoSize;
    property ThemeClassName: String Read fThemeClassName Write SetThemeClassName;
    property PartID: Integer Index 0 Read fPartID Write SetThemeID Default 1;
    property StateID: Integer Index 1 Read fStateID Write SetThemeID Default 1;
    property OnElementPaint: TAeroPaintThemeElementEvent Read fElementPaint Write fElementPaint;
    property OnGetElementSize: TAeroGetElementSizeEvent Read fGetElementSize Write fGetElementSize;
  End;

implementation

{ TAeroThemeElement }

constructor TAeroThemeElement.Create(AOwner: TComponent);
begin
  fThemeClassName := '';
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls];
  fPartID := 1;
  fStateID := 1;
  fElementPaint := nil;
  fGetElementSize := nil;
end;

destructor TAeroThemeElement.Destroy();
begin

  inherited Destroy();
end;

procedure TAeroThemeElement.CreateWnd();
begin
  inherited CreateWnd();
  CurrentThemeChanged();
end;

function TAeroThemeElement.GetRenderState: TRenderConfig;
begin
  Result := [rsBuffer];
end;

function TAeroThemeElement.GetThemeClassName: PWideChar;
begin
  Result := pWChar(fThemeClassName);
end;

procedure TAeroThemeElement.PostRender(const Surface: TCanvas; const RConfig: TRenderConfig);
begin
  // Nothing here
end;

function TAeroThemeElement.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
var
  varSize: TSize;
begin
  Result := True;
  varSize.cx := -1;
  varSize.cy := -1;

  if ThemeData <> 0 then
    GetThemePartSize(ThemeData, Canvas.Handle, fPartID, fStateID, nil, TS_TRUE, varSize)
  else
  if Assigned(fGetElementSize) then
    fGetElementSize(Self, fPartID, fStateID, varSize);

  if (varSize.cx <> -1) and (varSize.cy <> -1) then
  begin
    NewWidth := varSize.cx;
    NewHeight := varSize.cy;
  end
  else
  begin
    NewWidth := Width;
    NewHeight := Height;
  end;
end;

procedure TAeroThemeElement.SetThemeClassName(const Value: String);
begin
  if fThemeClassName <> Value then
  begin
    fThemeClassName := Value;
    CurrentThemeChanged();
    Invalidate();

    if AutoSize then
      SetBounds(Left, Top, 0, 0);
  end;
end;

procedure TAeroThemeElement.SetThemeID(const Index, Value: Integer);
begin
  case Index of
    0: fPartID:= Value;
    1: fStateID:= Value;
  end;

  Invalidate();

  if AutoSize then
    SetBounds(Left, Top, Width + 1, Height + 1);
end;       

procedure TAeroThemeElement.ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig);
var
  clRect: TRect;
  PaintSurface: TCanvas;
begin
  clRect := GetClientRect;

  if ThemeData <> 0 then
    DrawThemeBackground(ThemeData, PaintDC, fPartID, fStateID, clRect, @clRect)
  else
  if Assigned(fElementPaint) then
  begin
    PaintSurface := TCanvas.Create();
    PaintSurface.Handle := PaintDC;
    fElementPaint(Self, fPartID, fStateID, PaintSurface);
    PaintSurface.Handle := 0;
    PaintSurface.Free();
  end;
end;

procedure TAeroThemeElement.ClassicRender(const ACanvas: TCanvas);
begin
  if Assigned(fElementPaint) then
    fElementPaint(Self, fPartID, fStateID, ACanvas);
end;

end.

