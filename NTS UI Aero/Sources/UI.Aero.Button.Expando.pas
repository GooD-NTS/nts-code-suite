{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Button.Expando;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.GDIPOBJ,
  Winapi.UxTheme,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Buttons,
  {$ELSE}
  Classes, Controls, SysUtils, Windows, Graphics, Winapi.GDIPOBJ, UxTheme,
  Buttons,
  {$ENDIF}
  UI.Aero.Globals,
  UI.Aero.Core,
  UI.Aero.Button.Custom,
  UI.Aero.Core.Images;

type
  TCunstomExpandoButton = class(TAeroCustomButton)
  const
    TDLG_EXPANDOBUTTON = 13;

    TDLGEBS_NORMAL = 1;
    TDLGEBS_HOVER = 2;
    TDLGEBS_PRESSED = 3;

    TDLGEBS_EXPANDEDNORMAL = 4;
    TDLGEBS_EXPANDEDHOVER = 5;
    TDLGEBS_EXPANDEDPRESSED = 6;
  private
    fExpand: Boolean;
    fOnExpand: TNotifyEvent;
    fVisibleControl: TControl;
    fExpandCaption: TCaption;
    procedure SetExpand(const Value: Boolean);
    procedure SetVisibleControl(const Value: TControl);
    procedure SetExpandCaption(const Value: TCaption);
  Protected
    function GetRenderState: TARenderConfig; override;
    function GetThemeClassName: PWideChar; override;
    procedure ExpandChange; Virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Click; override;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    function GetCurrentTextWidth: Integer;
  Public
    Constructor Create(AOwner: TComponent); OverRide;
  Published
    property AutoSize Default True;
    property Caption;
    property ExpandCaption: TCaption Read fExpandCaption Write SetExpandCaption;
    property Expand: Boolean Read fExpand Write SetExpand Default True;
    property OnExpand: TNotifyEvent Read fOnExpand Write fOnExpand;
    property VisibleControl: TControl Read fVisibleControl Write SetVisibleControl;
  end;

  TAeroExpandoButton = class(TCunstomExpandoButton)
  const
    TextFormat = (DT_CENTER or DT_VCENTER or DT_SINGLELINE);
  Protected
    procedure RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer); override;
    procedure ClassicRender(const ACanvas: TCanvas; const DrawState: Integer); override;
    procedure PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer); override;
  end;

implementation

{ TAeroExpandoButton }

Constructor TCunstomExpandoButton.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  AutoSize:= True;
  fExpand:= True;
  fOnExpand:= nil;
  fVisibleControl:= nil;
  fExpandCaption:= 'AeroExpandoButton';
end;

function TCunstomExpandoButton.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result:= True;
  if Align in [alNone, alTop, alBottom] then
    NewHeight:= 21;
  if Align in [alNone, alLeft, alRight] then
    NewWidth:= 21+GetCurrentTextWidth;
end;

procedure TCunstomExpandoButton.Click;
begin
  Inherited Click;
  SetExpand(not fExpand);
end;

procedure TCunstomExpandoButton.ExpandChange;
begin
  if Assigned(fVisibleControl) then
    fVisibleControl.Visible:= fExpand;
  if Assigned(fOnExpand) then
    fOnExpand(Self);
  if AutoSize then
    SetBounds(Left,Top,0,0);
end;

function TCunstomExpandoButton.GetCurrentTextWidth: Integer;
begin
  if Assigned(Parent) then
  begin
    Canvas.Font:= Self.Font;
    if Expand then
      Result:= Canvas.TextExtent(ExpandCaption).cx
    else
      Result:= Canvas.TextExtent(Caption).cx;
  end
  else
    Result:= 0;
end;

function TCunstomExpandoButton.GetRenderState: TARenderConfig;
begin
  Result:= [];
end;

function TCunstomExpandoButton.GetThemeClassName: PWideChar;
begin
  if AeroCore.RunWindowsVista then
    Result:= 'TaskDialog'
  else
    Result:= 'ExplorerBar';//VSCLASS_BUTTON;
  {TODO -oGooD -cGeneral : Доделать комопнент для XP и клсасики}
end;

procedure TCunstomExpandoButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  Inherited Notification(AComponent,Operation);
  if (Operation = opRemove) and (AComponent = fVisibleControl) then
    fVisibleControl:= nil;
end;

procedure TCunstomExpandoButton.SetExpand(const Value: Boolean);
begin
  if fExpand <> value then
  begin
    fExpand:= Value;
    Invalidate;
    ExpandChange;
  end;
end;

procedure TCunstomExpandoButton.SetExpandCaption(const Value: TCaption);
begin
  if fExpandCaption <> Value then
  begin
    fExpandCaption:= Value;
    Invalidate;
  end;
end;

procedure TCunstomExpandoButton.SetVisibleControl(const Value: TControl);
begin
  if fVisibleControl <> Value then
  begin
    fVisibleControl:= Value;
    fVisibleControl.Visible:= fExpand;
  end;
end;

{ TAeroExpandoButton }

procedure TAeroExpandoButton.ClassicRender(const ACanvas: TCanvas; const DrawState: Integer);
begin
{ Wingdigs 217() 218()
------------------------------------------------
|      |                                       -|
|      |   Текст Текст Текст Текст Текст Текст -|
|      |                                       -|
------------------------------------------------
}
end;

procedure TAeroExpandoButton.PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer);
begin

end;

procedure TAeroExpandoButton.RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer);
var
  clRect: TRect;
  StateID: Integer;
begin
  if AeroCore.RunWindowsVista then
  begin
    StateID:= TDLGEBS_NORMAL;
    if fExpand then
    case TAeroButtonState(DrawState) of
      UI.Aero.Globals.bsNormal    : StateID:= TDLGEBS_EXPANDEDNORMAL;
      UI.Aero.Globals.bsHightLight: StateID:= TDLGEBS_EXPANDEDHOVER;
      UI.Aero.Globals.bsFocused   : StateID:= TDLGEBS_EXPANDEDNORMAL;
      UI.Aero.Globals.bsDown      : StateID:= TDLGEBS_EXPANDEDPRESSED;
      UI.Aero.Globals.bsDisabled  : StateID:= TDLGEBS_EXPANDEDNORMAL;
    end
    else
    case TAeroButtonState(DrawState) of
      UI.Aero.Globals.bsNormal    : StateID:= TDLGEBS_NORMAL;
      UI.Aero.Globals.bsHightLight: StateID:= TDLGEBS_HOVER;
      UI.Aero.Globals.bsFocused   : StateID:= TDLGEBS_NORMAL;
      UI.Aero.Globals.bsDown      : StateID:= TDLGEBS_PRESSED;
      UI.Aero.Globals.bsDisabled  : StateID:= TDLGEBS_NORMAL;
    end;
    clRect:= Rect(0,0,19,21);
    DrawThemeBackground(ThemeData,PaintDC,TDLG_EXPANDOBUTTON,StateID,clRect,nil);
    clRect:= Rect(21,0,Width,Height);
    if Expand then
      AeroCore.RenderText(PaintDC, ThemeData, TDLG_EXPANDOBUTTON, StateID,
        Self.Font, TextFormat, clRect, ExpandCaption, false)
    else
      AeroCore.RenderText(PaintDC, ThemeData, TDLG_EXPANDOBUTTON, StateID,
        Self.Font, TextFormat, clRect, Caption, false);
  end
  else
  begin
    StateID:= TDLGEBS_NORMAL;
    if fExpand then
    case TAeroButtonState(DrawState) of
      UI.Aero.Globals.bsNormal    : StateID:= PBS_NORMAL;
      UI.Aero.Globals.bsHightLight: StateID:= PBS_HOT;
      UI.Aero.Globals.bsFocused   : StateID:= PBS_DEFAULTED;
      UI.Aero.Globals.bsDown      : StateID:= PBS_PRESSED;
      UI.Aero.Globals.bsDisabled  : StateID:= PBS_DISABLED;
    end
    else
    case TAeroButtonState(DrawState) of
      UI.Aero.Globals.bsNormal    : StateID:= PBS_NORMAL;
      UI.Aero.Globals.bsHightLight: StateID:= PBS_HOT;
      UI.Aero.Globals.bsFocused   : StateID:= PBS_DEFAULTED;
      UI.Aero.Globals.bsDown      : StateID:= PBS_PRESSED;
      UI.Aero.Globals.bsDisabled  : StateID:= PBS_DISABLED;
    end;
    clRect:= GetClientRect;
    DrawThemeBackground(ThemeData,PaintDC,BP_PUSHBUTTON,StateID,clRect,nil);
    if Expand then
      AeroCore.RenderText(PaintDC, ThemeData, BP_PUSHBUTTON, StateID, Self.Font,
        TextFormat, clRect, ExpandCaption, false)
    else
      AeroCore.RenderText(PaintDC, ThemeData, BP_PUSHBUTTON, StateID, Self.Font,
        TextFormat, clRect, Caption, false);
  end;
end;      

end.
