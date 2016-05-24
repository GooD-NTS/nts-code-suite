{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Core;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.UxTheme,
  Vcl.Graphics;
  {$ELSE}
  SysUtils, Classes, Windows, UxTheme, Graphics;
  {$ENDIF}

type
  TDrawProcedure = procedure(ADC: hDC; ATheme: hTheme; APartID, AStateID: Integer; AFont: TFont; AFormat: DWORD; ARect: TRect; AText: String; AGlow: BooLean) of object;

  AeroCore = Class(TComponent)
  Private
    class var RenderFunction: TDrawProcedure;
    class procedure DrawVista(ADC: hDC; ATheme: hTheme; APartID, AStateID: Integer; AFont: TFont; AFormat: DWORD; ARect: TRect; AText: String; AGlow: BooLean);
    class procedure DrawXP(ADC: hDC; ATheme: hTheme; APartID, AStateID: Integer; AFont: TFont; AFormat: DWORD; ARect: TRect; AText: String; AGlow: BooLean);
  Public
    class var FirstInstance: AeroCore;
    class var RunWindowsVista: BooLean;
    class var CompositionActive: BooLean;
    class procedure RenderText(ADC: hDC; ATheme: hTheme; APartID, AStateID: Integer; AFont: TFont; AFormat: DWORD; ARect: TRect; AText: String; AGlow: BooLean); OverLoad;
    class procedure RenderText(ADC: hDC; AFont: TFont; AFormat: DWORD; ARect: TRect; AText: String); OverLoad;
  End;

implementation

{ AeroCore }

class procedure AeroCore.DrawVista(ADC: hDC; ATheme: hTheme; APartID, AStateID: Integer; AFont: TFont; AFormat: DWORD; ARect: TRect; AText: String; AGlow: BooLean);
var
  Options: TDTTOpts;
begin
  if CompositionActive and (ATheme <> 0) then
  begin
    SelectObject(ADC,AFont.Handle);
    ZeroMemory(@Options,SizeOf(TDTTOpts));
    Options.dwSize:= SizeOf(TDTTOpts);
    Options.dwFlags:= DTT_COMPOSITED or DTT_TEXTCOLOR;
    Options.crText:= ColorToRGB(AFont.Color);
    if AGlow then
    begin
      Options.dwFlags:= Options.dwFlags or DTT_GLOWSIZE;
      Options.iGlowSize:= 12;
    end;
    DrawThemeTextEx(ATheme, ADC, APartID, AStateID, PWideChar(AText), -1,
      AFormat, @ARect, Options);
  end
  else
    DrawXP(ADC,ATheme,APartID,AStateID,AFont,AFormat,ARect,AText,AGlow);
end;

class procedure AeroCore.DrawXP(ADC: hDC; ATheme: hTheme; APartID, AStateID: Integer; AFont: TFont; AFormat: DWORD; ARect: TRect; AText: String; AGlow: BooLean);
var
  OldBkMode: Integer;
begin
  SelectObject(ADC, AFont.Handle);
  SetTextColor(ADC, ColorToRGB(AFont.Color));
  OldBkMode := SetBkMode(ADC, Transparent);
  DrawText(ADC, pChar(AText), -1, ARect, AFormat);
  SetBkMode(ADC, OldBkMode);
end;

class procedure AeroCore.RenderText(ADC: hDC; AFont: TFont; AFormat: DWORD; ARect: TRect; AText: String);
begin
  DrawXP(ADC, 0, 0, 0, AFont, AFormat, ARect, AText, False);
end;

class procedure AeroCore.RenderText(ADC: hDC; ATheme: hTheme; APartID, AStateID: Integer; AFont: TFont; AFormat: DWORD; ARect: TRect; AText: String; AGlow: BooLean);
begin
  RenderFunction(ADC, ATheme, APartID, AStateID, AFont, AFormat, ARect, AText,
    AGlow);
end;

Initialization
begin
  InitThemeLibrary;
  AeroCore.FirstInstance:= nil;
  if CheckWin32Version(6, 0) then
  begin
    AeroCore.RunWindowsVista:= True;
    AeroCore.CompositionActive:= IsCompositionActive;
    AeroCore.RenderFunction:= AeroCore.DrawVista;
  end
  else
  begin
    AeroCore.RunWindowsVista:= False;
    AeroCore.CompositionActive:= False;
    AeroCore.RenderFunction:= AeroCore.DrawXP;
  end;
end;

Finalization
begin
  // To Do: Type code here;
end;


end.
