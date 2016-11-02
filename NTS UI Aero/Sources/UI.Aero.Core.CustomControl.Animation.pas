{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Core.CustomControl.Animation;

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
  TCustomAeroControlWithAnimation = class(TAeroBaseControl)
  private
    fAnimationStyle: TAnimationStyle;
    fAnimationDuration: DWORD;
  Protected
    CurrentAniState: Integer;
    NewAniState: Integer;
    procedure RenderProcedure_Vista(const ACanvas: TCanvas); override;
    procedure RenderProcedure_XP(const ACanvas: TCanvas); override;
    procedure RenderProcedure_Classic(const ACanvas: TCanvas);
    procedure RenderProcedure_Animation(const DC: hDC; const DrawState: Integer; var RConfig: TARenderConfig); Virtual;
    function GetRenderState: TARenderConfig; Virtual; Abstract;
    procedure RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer); Virtual; Abstract;
    procedure PostRender(const Surface: TCanvas;const RConfig: TARenderConfig; const DrawState: Integer); Virtual;  Abstract;
    procedure ClassicRender(const ACanvas: TCanvas; const DrawState: Integer); Virtual; Abstract;
  Public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
  Published
    property AnimationStyle: TAnimationStyle Read fAnimationStyle Write fAnimationStyle Default asLinear;
    property AnimationDuration: DWORD Read fAnimationDuration Write fAnimationDuration Default 500;
  end;

implementation

uses
  UI.Aero.Core,
  UI.Aero.Core.CustomControl;

{ TCustomAeroControlWithAnimation }

Constructor TCustomAeroControlWithAnimation.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  fAnimationStyle:= asLinear;
  CurrentAniState:= 0;
  NewAniState:= 0;
  fAnimationDuration:= 500;
  if AeroCore.RunWindowsVista then
    BufferedPaintInit;
end;

Destructor TCustomAeroControlWithAnimation.Destroy;
begin

  Inherited Destroy;
end;

procedure TCustomAeroControlWithAnimation.RenderProcedure_Animation(const DC: hDC; const DrawState: Integer; var RConfig: TARenderConfig);
var
 GPSurface: TGPGraphics;
 clRect: TRect;
begin
  GPSurface:= nil;
//
  clRect:= GetClientRect;
  DrawAeroParentBackground(DC, clRect);
//
  if (arsGDIP in RConfig) then GPSurface:= TGPGraphics.Create(DC);
  RenderState(DC,GPSurface,RConfig,DrawState);
  if Assigned(GPSurface) then GPSurface.Free;
end;

procedure TCustomAeroControlWithAnimation.RenderProcedure_Classic(const ACanvas: TCanvas);
begin
 CreateClassicBuffer;
 DrawClassicBG;
 CurrentAniState:= NewAniState;
 ClassicRender(ClassicBuffer.Canvas,CurrentAniState);
 ACanvas.Draw(0,0,ClassicBuffer);
end;

procedure TCustomAeroControlWithAnimation.RenderProcedure_Vista(const ACanvas: TCanvas);
var
  hdcFrom,
  hdcTo,
  PaintDC: hDC;

  AnimationParams: TBPAnimationParams;
  rtClient: TRect;
  AnimationBuffer: hAnimationBuffer;
  PaintParams: TBPPaintParams;
  RConfig: TARenderConfig;

begin
  hdcFrom:= 0;
  hdcTo:= 0;
  PaintDC:= ACanvas.Handle;
  RConfig:= [];

  if {$IFDEF HAS_VCLSTYLES}StyleServices.Enabled{$ELSE}ThemeServices.ThemesEnabled{$ENDIF} then
  begin
    if not BufferedPaintRenderAnimation(Handle,PaintDC) then
    begin
      if IsCompositionActive then
        RConfig:= GetRenderState+[arsComposited]
      else
        RConfig:= GetRenderState;
      ZeroMemory(@AnimationParams, sizeof(TBPAnimationParams));
      AnimationParams.cbSize:= sizeof(BP_ANIMATIONPARAMS);
      AnimationParams.Style:= Integer(fAnimationStyle);
      if CurrentAniState <> NewAniState then
        AnimationParams.dwDuration:= fAnimationDuration
      else
        AnimationParams.dwDuration:= 0;
      rtClient:= Self.GetClientRect;
      ZeroMemory(@PaintParams,SizeOf(TBPPaintParams));
      PaintParams.cbSize:= SizeOf(TBPPaintParams);
      PaintParams.dwFlags:= BPPF_ERASE;

      AnimationBuffer:= BeginBufferedAnimation(Handle, PaintDC, rtClient,
                BPBF_COMPOSITED, @PaintParams, AnimationParams, hdcFrom, hdcTo);
      if AnimationBuffer = 0 then
        RenderProcedure_Animation(PaintDC,NewAniState,RConfig)
      else
      begin
        if hdcFrom <> 0 then
          RenderProcedure_Animation(hdcFrom,CurrentAniState,RConfig);
        if hdcTo <> 0 then
          RenderProcedure_Animation(hdcTo,NewAniState,RConfig);
        CurrentAniState:= NewAniState;
        EndBufferedAnimation(AnimationBuffer, True);
      end;
    end;
  end
  else
    RenderProcedure_Classic(ACanvas);

  if arsPostDraw in RConfig then
    PostRender(ACanvas,RConfig,CurrentAniState);
end;

procedure TCustomAeroControlWithAnimation.RenderProcedure_XP(const ACanvas: TCanvas);
var
  RConfig: TARenderConfig;
  GPSurface: TGPGraphics;
begin
  GPSurface:= nil;
  if {$IFDEF HAS_VCLSTYLES}StyleServices.Enabled{$ELSE}ThemeServices.ThemesEnabled{$ENDIF} then
  begin
    CurrentAniState:= NewAniState;
    RConfig:= GetRenderState;
    if (arsGDIP in RConfig) then
      GPSurface:= TGPGraphics.Create(ACanvas.Handle);
    RenderState(ACanvas.Handle,GPSurface,RConfig,CurrentAniState);
    if Assigned(GPSurface) then
      GPSurface.Free;
  end
  else
    RenderProcedure_Classic(ACanvas);
  if arsPostDraw in RConfig then
    PostRender(ACanvas,RConfig,CurrentAniState);
end;

end.
