{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Core.BaseControl;

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
  Vcl.Forms,
  {$ELSE}
  SysUtils, Classes, Windows, Messages, UxTheme, DwmApi, Winapi.GDIPAPI,
  Winapi.GDIPOBJ, Winapi.GDIPUTIL, Controls, Graphics, Themes, Forms,
  {$ENDIF}
  UI.Aero.Globals,
  UI.Aero.Core;

type
  TRenderProcedure = procedure(const ACanvas: TCanvas) of Object;

  TCustomBaseAeroControl = Class(TCustomControl)
  private
    fDragWindow: BooLean;
    FsTag: String;
    fDesigningRect: BooLean;
    fTransparent: Boolean;
    fTransparentColor: TColor;
    procedure SetDesigningRect(const Value: BooLean);
    procedure SetTransparent(const Value: Boolean);
    procedure SetTransparentColor(const Value: TColor);
  Public
    Constructor Create(AOwner: TComponent); OverRide;
    function IsRunTime: Boolean;
    function IsDesigningTime: Boolean;
    procedure SetCenterTop;
  Published
    Property DesigningRect: BooLean Read fDesigningRect Write SetDesigningRect Default True;
    Property DragWindow: BooLean Read fDragWindow Write fDragWindow Default False;
    Property sTag: String Read FsTag Write FsTag;

    property Transparent: Boolean Read fTransparent Write SetTransparent default True;
    property TransparentColor: TColor Read fTransparentColor Write SetTransparentColor default clBtnFace;
  //
    property Align;
    property Anchors;
    property Font;
    property Constraints;
    property ParentColor;
    property Visible;
    property Enabled;
    property ShowHint;
    property PopupMenu;
  //
    property OnResize;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;

  End;

  TAeroBaseControl = class(TCustomBaseAeroControl)
  Private
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure DragMove;
  Protected
    Render: TRenderProcedure;
    MouseOnControl: Boolean;
    MouseLeftDown: Boolean;
    ClassicBuffer: TBitmap;
    ThemeData: hTheme;
    procedure RenderProcedure_Vista(const ACanvas: TCanvas); Virtual; Abstract;
    procedure RenderProcedure_XP(const ACanvas: TCanvas); Virtual; Abstract;
    procedure CurrentThemeChanged; Virtual;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
    procedure CreateClassicBuffer;
    procedure DrawClassicBG;
    procedure WndProc(var Message: TMessage); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure LoadThemeData; Virtual;
    function GetThemeClassName: PChar; Virtual;
    procedure DrawAeroParentBackground(DrawDC: HDC; DrawRect: TRect);
    function CanDrag(X,Y: Integer): BooLean; Virtual;
  Public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
  end;


implementation

Uses
  UI.Aero.Window;

{ TCustomBaseAeroControl }

Constructor TCustomBaseAeroControl.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  fDragWindow:= False;
  FsTag:= '';
  fDesigningRect:= True;
  Width:= 160;
  Height:= 90;
  fTransparent:= True;
  fTransparentColor:= clBtnFace;
end;

function TCustomBaseAeroControl.IsRunTime: Boolean;
begin
  Result:= not (csDesigning in ComponentState);
end;

function TCustomBaseAeroControl.IsDesigningTime: Boolean;
begin
  Result:= (csDesigning in ComponentState);
end;

procedure TCustomBaseAeroControl.SetCenterTop;
begin
 if Assigned(Parent) then
  begin
   Self.Top:= (Parent.ClientHeight div 2)-(Self.Height div 2);
  end;
end;

Procedure TCustomBaseAeroControl.SetDesigningRect(const Value: BooLean);
begin
 if fDesigningRect <> Value then
  begin
   fDesigningRect:= Value;
   Invalidate;
  end;
end;

procedure TCustomBaseAeroControl.SetTransparent(const Value: Boolean);
begin
 if fTransparent <> Value then
  begin
   fTransparent:= Value;
   Invalidate;
  end;
end;

procedure TCustomBaseAeroControl.SetTransparentColor(const Value: TColor);
begin
 if fTransparentColor <> Value then
  begin
   fTransparentColor:= Value;
   if not fTransparent then
    Invalidate;
  end;
end;

{ TAeroBaseControl }

function TAeroBaseControl.CanDrag(X, Y: Integer): BooLean;
begin
 Result:= True;
end;

constructor TAeroBaseControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ClassicBuffer:= nil;
  MouseOnControl:= False;
  // Render Procedure
  if TAeroWindow.RunWindowsVista then
    Render:= RenderProcedure_Vista
  else
    Render:= RenderProcedure_XP;
  // Def Style
  ControlStyle := [csCaptureMouse, csClickEvents, csSetCaption, csOpaque, csDoubleClicks, csReplicatable, csPannable];
  if {$IFDEF HAS_VCLSTYLES}StyleServices.Enabled{$ELSE}ThemeServices.ThemesEnabled{$ENDIF} then
    ControlStyle := ControlStyle+[csParentBackground]-[csOpaque]
  else
    ControlStyle := ControlStyle-[csParentBackground]+[csOpaque];
  ParentBackground:= True;
  // Themes
  ThemeData:= 0;
  LoadThemeData;
end;

Destructor TAeroBaseControl.Destroy;
begin
 if ThemeData <> 0 then
  CloseThemeData(ThemeData);
 if Assigned(ClassicBuffer) then
  ClassicBuffer.Free;
 Inherited Destroy;
end;

procedure TAeroBaseControl.CreateClassicBuffer;
begin
 if Assigned(ClassicBuffer) then ClassicBuffer.Free;
 ClassicBuffer:= TBitmap.Create;
 ClassicBuffer.SetSize(Self.Width,Self.Height);
 ClassicBuffer.Canvas.Brush.Color:= Self.Color;
 ClassicBuffer.Canvas.FillRect(Rect(0,0,Self.Width,Self.Height));
end;

procedure TAeroBaseControl.DragMove;
const
 SC_DragMove = $F012;
begin
 ReleaseCapture;
 GetParentForm(self).Perform(WM_SysCommand, SC_DragMove, 0);
end;

procedure TAeroBaseControl.DrawAeroParentBackground(DrawDC: HDC; DrawRect: TRect);
begin
  if Transparent then
    DrawThemeParentBackground(Self.Handle, DrawDC, @DrawRect)
  else
  begin
    Canvas.Brush.Color := TransparentColor;
    Canvas.Brush.Style := bsSolid;
    FillRect(DrawDC, DrawRect, Canvas.Brush.Handle);
  end;
end;

procedure TAeroBaseControl.DrawClassicBG;
begin
  if Parent is TAeroBaseControl then
  begin
    if TAeroBaseControl(Parent).ClassicBuffer <> nil then
    begin
      BitBlt(ClassicBuffer.Canvas.Handle,0,0,Self.Width,
      Self.Height,TAeroBaseControl(Parent).ClassicBuffer.Canvas.Handle,
      Self.Left,Self.Top,SRCCOPY);
    end;
  end;
end;

function TAeroBaseControl.GetThemeClassName: PChar;
begin
 Result:= '';
end;

procedure TAeroBaseControl.LoadThemeData;
var
  ThemeClassName: PChar;
begin
  if ThemeData <> 0 then
    CloseThemeData(ThemeData);

  ThemeClassName:= GetThemeClassName;

  if ThemeClassName <> '' then
    ThemeData:= OpenThemeData(0, ThemeClassName);
end;

procedure TAeroBaseControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button,Shift,X,Y);

  if Button = mbLeft then
    MouseLeftDown:= True;

  if fDragWindow and CanDrag(X,Y) then
    DragMove;
end;

procedure TAeroBaseControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button,Shift,X,Y);
  if Button = mbLeft then
    MouseLeftDown:= False;
end;

procedure TAeroBaseControl.Paint;
begin
  Render(Canvas);
  if IsDesigningTime and fDesigningRect then
    Canvas.DrawFocusRect(ClientRect);
end;

procedure TAeroBaseControl.CurrentThemeChanged;
begin
  if {$IFDEF HAS_VCLSTYLES}StyleServices.Enabled{$ELSE}ThemeServices.ThemesEnabled{$ENDIF} then
    ControlStyle := ControlStyle+[csParentBackground]-[csOpaque]
  else
    ControlStyle := ControlStyle-[csParentBackground]+[csOpaque];
  LoadThemeData;
end;

procedure TAeroBaseControl.CreateParams(var Params: TCreateParams);
begin
 Inherited CreateParams(Params);
 with Params do
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
 //{$MESSAGE HINT 'Узнать зачем здесь нужно  and not (CS_HREDRAW or CS_VREDRAW)'}
end;

procedure TAeroBaseControl.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
 if TAeroWindow.RunWindowsVista then
  begin //Vista
   if Self.ControlCount = 0 then
    begin
     if {$IFDEF HAS_VCLSTYLES}StyleServices.Enabled{$ELSE}ThemeServices.ThemesEnabled{$ENDIF} then
      Message.Result:= 1
     else
      DefaultHandler(Message);
    end
   else
    Inherited;
  end
 else
  begin //XP
   Inherited;
  end;
end;

procedure TAeroBaseControl.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
 Invalidate;
 inherited;
end;

procedure TAeroBaseControl.WndProc(var Message: TMessage);
begin
  Inherited WndProc(Message);
  case Message.Msg of
    WM_DWMCOMPOSITIONCHANGED,
    WM_THEMECHANGED:
    begin
      CurrentThemeChanged;
      Invalidate;
    end;
    CM_MOUSEENTER: MouseOnControl:= True;
    CM_MOUSELEAVE: MouseOnControl:= False;
    CM_TEXTCHANGED:
    begin
      if AutoSize then
      begin
        AutoSize:= False;
        AutoSize:= True;
      end;
      Invalidate;
    end;
  end;
end;

{ Initialization & Finalization }

Initialization
begin
  if TAeroWindow.RunWindowsVista then
    BufferedPaintInit;
end;

Finalization
begin
  if TAeroWindow.RunWindowsVista then
    BufferedPaintUnInit;
end;

end.
