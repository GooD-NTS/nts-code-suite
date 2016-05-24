{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Core.CustomControl;

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
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Themes,
  {$ELSE}
  SysUtils, Classes, Windows, Messages, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  Winapi.GDIPUTIL, UxTheme, DwmApi, Controls, Graphics, Themes,
  {$ENDIF}
  UI.Aero.Core.BaseControl,
  UI.Aero.Globals;

type
  TCustomAeroControl = class(TAeroBaseControl)
  Private
    Function CreateRenderBuffer(const DrawDC: hDC;var PaintDC: hDC): hPaintBuffer;
  Protected
    function GetRenderState: TRenderConfig; Virtual; Abstract;
    procedure RenderProcedure_Vista(const ACanvas: TCanvas); override;
    procedure RenderProcedure_XP(const ACanvas: TCanvas); override;
    procedure RenderProcedure_Classic(const ACanvas: TCanvas);
    procedure ClassicRender(const ACanvas: TCanvas); Virtual; Abstract;
    procedure ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig); Virtual; Abstract;
    procedure PostRender(const Surface: TCanvas;const RConfig: TRenderConfig); Virtual; Abstract;
  Public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
  end;

implementation

{ TCustomAeroControl }

constructor TCustomAeroControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

end;

destructor TCustomAeroControl.Destroy;
begin

  inherited Destroy;
end;

function TCustomAeroControl.CreateRenderBuffer(const DrawDC: hDC; var PaintDC: hDC): hPaintBuffer;
var
  rcClient: TRect;
  Params: TBPPaintParams;
begin
  rcClient:= GetClientRect;
  ZeroMemory(@Params,SizeOf(TBPPaintParams));
  Params.cbSize:= SizeOf(TBPPaintParams);
  Params.dwFlags:= BPPF_ERASE;
  Result:= BeginBufferedPaint(DrawDC, rcClient, BPBF_COMPOSITED, @params, PaintDC);
  if Result = 0 then
    PaintDC:= DrawDC
  else
    DrawAeroParentBackground(PaintDC,rcClient);
end;

procedure TCustomAeroControl.RenderProcedure_Classic(const ACanvas: TCanvas);
begin
  CreateClassicBuffer;
  DrawClassicBG;
  ClassicRender(ClassicBuffer.Canvas);
  ACanvas.Draw(0, 0, ClassicBuffer);
end;

procedure TCustomAeroControl.RenderProcedure_Vista(const ACanvas: TCanvas);
var
  RConfig: TRenderConfig;
  PaintDC: hDC;
  RenderBuffer: hPaintBuffer;
  GPSurface: TGPGraphics;
begin
  PaintDC:= ACanvas.Handle;
  RenderBuffer:= 0;
  GPSurface:= nil;
  RConfig:= [];
//
  if {$IFDEF HAS_VCLSTYLES}StyleServices.Enabled{$ELSE}ThemeServices.ThemesEnabled{$ENDIF} then
  begin
    if IsCompositionActive then
      RConfig:= GetRenderState+[rsComposited]
    else
      RConfig:= GetRenderState;
    if (rsBuffer in RConfig) then
      RenderBuffer:= CreateRenderBuffer(ACanvas.Handle,PaintDC);
    if (rsGDIP in RConfig) then
      GPSurface:= TGPGraphics.Create(PaintDC);
    ThemedRender(PaintDC, GPSurface, RConfig);
    if Assigned(GPSurface) then
      GPSurface.Free;
    if (rsBuffer in RConfig) and (RenderBuffer <> 0) then
      EndBufferedPaint(RenderBuffer, True);
  end
  else
    RenderProcedure_Classic(ACanvas);
  if rsPostDraw in RConfig then
    PostRender(ACanvas,RConfig);
end;

procedure TCustomAeroControl.RenderProcedure_XP(const ACanvas: TCanvas);
var
  RConfig: TRenderConfig;
  PaintDC: hDC;
  GPSurface: TGPGraphics;
begin
  PaintDC:= ACanvas.Handle;
  GPSurface:= nil;
  RConfig:= [];
//
  if {$IFDEF HAS_VCLSTYLES}StyleServices.Enabled{$ELSE}ThemeServices.ThemesEnabled{$ENDIF} then
  begin
    RConfig:= GetRenderState;
    if (rsGDIP in RConfig) then
      GPSurface:= TGPGraphics.Create(PaintDC);
    ThemedRender(PaintDC,GPSurface,RConfig);
    if Assigned(GPSurface) then
      GPSurface.Free;
  end
  else
    RenderProcedure_Classic(ACanvas);
  if rsPostDraw in RConfig then
    PostRender(ACanvas,RConfig);
end;

end.
