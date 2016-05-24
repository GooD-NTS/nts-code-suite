{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.BackForward;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.GDIPUTIL,
  Winapi.GDIPOBJ,
  Winapi.GDIPAPI,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Imaging.pngimage,
  Vcl.Menus,
  Vcl.ExtCtrls,
  {$ELSE}
  Windows, SysUtils, Messages, Classes, Controls, Graphics, Menus,
  Winapi.GDIPUTIL, Winapi.GDIPOBJ, Winapi.GDIPAPI, ExtCtrls, PNGImage,
  {$ENDIF}
  UI.Aero.Globals,
  UI.Aero.Core,
  UI.Aero.Button.Theme,
  UI.Aero.Button.Custom,
  UI.Aero.Button.Image,
  UI.Aero.Core.CustomControl,
  UI.Aero.Core.Images;

type
  TButtonClickEvent = procedure(Sender: TObject; Index: Integer) of object;

  TAeroBackForward = class(TWinControl)
  public class var Resources_Images_xp_w3k: String;
  private class constructor Create;
  Private
    buttons: Array [0..2] of TAeroThemeButton;
    AeroXP: Array [1..3] of TPNGImage;
    FGoToMenu: TPopupMenu;
    FOnBtnClick: TButtonClickEvent;
    function GetBtnEnabled(const Index: Integer): BooLean;
    procedure SetBtnEnabled(const Index: Integer; const Value: BooLean);
    procedure SetGoToMenu(const Value: TPopupMenu);
  Protected
    procedure CreateButtons; Virtual;
    procedure DestroyButtons; Virtual;
    procedure SetButtonsProperty; Virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure btnBackMenuClick(Sender: TObject);
    procedure buttonClick(Sender: TObject);
    procedure xp_w3k_theme(const Sender: TAeroCustomButton; PartID, StateID: Integer; Surface: TCanvas);
    procedure LoadMsStyle;
    procedure FreeMsStyle;
  Public
    CurrentIndex: Integer;
    NeedUpDate: Boolean;
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
  Published
    Property EnabledBack: BooLean Index 0 Read GetBtnEnabled Write SetBtnEnabled;
    Property EnabledForward: BooLean Index 1 Read GetBtnEnabled Write SetBtnEnabled;
    Property EnabledMenu: BooLean Index 2 Read GetBtnEnabled Write SetBtnEnabled;
    property GoToMenu: TPopupMenu read FGoToMenu write SetGoToMenu;
    property OnButtonClick: TButtonClickEvent Read FOnBtnClick Write FOnBtnClick;
  end;

  TAeroIEBackForward = class(TCustomAeroControl)
  public class var ResourcesImagesPath: String;
  private class constructor Create;
  Private
    bmBackground: TBitmap;
    bmMask: TBitmap;
    bmButton: Array [bsNormal..bsDisabled] of TBitmap;

    FStateBack: TAeroButtonState;
    FStateForward: TAeroButtonState;
    FBackDown: boolean;
    FForwardDown: boolean;
    FTravelMenu: TPopupMenu;
    FMenuTimer: TTimer;
    FOnBtnClick: TButtonClickEvent;
    FOnlyBackButton: Boolean;
    function GetButtonEnabled(const Index: Integer): boolean;
    procedure SetButtonEnabled(const Index: Integer; const Value: boolean);
    procedure SetTravelMenu(const Value: TPopupMenu);
    procedure ShowTravelMenu(Sender: TObject);
    procedure SetOnlyBackButton(const Value: Boolean);
  Protected
    function GetRenderState: TRenderConfig; override;
    procedure RenderControl(const PaintDC: hDC);
    procedure ClassicRender(const ACanvas: TCanvas); override;
    procedure ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig); override;
    procedure PostRender(const Surface: TCanvas;const RConfig: TRenderConfig); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); OverRide;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure WndProc(var Message: TMessage); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Click; override;
  Public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
  Published
    property OnlyBackButton: Boolean read FOnlyBackButton write SetOnlyBackButton default false;
    property EnabledBack: boolean index 0 read GetButtonEnabled write SetButtonEnabled default false;
    property EnabledForward: boolean index 1 read GetButtonEnabled write SetButtonEnabled default false;
    property TravelMenu: TPopupMenu read FTravelMenu write SetTravelMenu;
    property OnButtonClick: TButtonClickEvent Read FOnBtnClick Write FOnBtnClick;
  end;

implementation

uses
  NTS.Code.Helpers;

class constructor TAeroBackForward.Create;
begin
  if Assigned(RegisterComponentsProc) then
  begin
    TAeroBackForward.Resources_Images_xp_w3k:= GetEnvironmentVariable('NTS_LIB_ROOT')+'\NTS UI Aero\Resources\Images\';
  end
  else
  begin
    TAeroBackForward.Resources_Images_xp_w3k:= '???ERROR_PATH***';
  end;
end;

class constructor TAeroIEBackForward.Create;
begin
  if Assigned(RegisterComponentsProc) then
  begin
    TAeroIEBackForward.ResourcesImagesPath:= GetEnvironmentVariable('NTS_LIB_ROOT')+'\NTS UI Aero\Resources\Images\'
  end
  else
  begin
    TAeroIEBackForward.ResourcesImagesPath:= '???ERROR_PATH***';
  end;
end;


{ TAeroBackForward }

Constructor TAeroBackForward.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  NeedUpDate:= True;
  CurrentIndex:= 0;
  ControlStyle:= ControlStyle+[csParentBackground]-[csOpaque];
  Height:= 31;
  Width:= 81;
  CreateButtons;
  SetButtonsProperty;
end;

Destructor TAeroBackForward.Destroy;
begin
  DestroyButtons;
  Inherited Destroy;
end;

procedure TAeroBackForward.Notification(AComponent: TComponent; Operation: TOperation);
begin
  Inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FGoToMenu) then
    FGoToMenu:= nil;
end;

procedure TAeroBackForward.CreateButtons;
const
  bntName: Array [0..2] of String = ('btnBack','btnForward','btnBackMenu');
var                                                                           
  I: Integer;
begin
  if not AeroCore.RunWindowsVista then
    LoadMsStyle;
  for I:=0 to 2 do
  begin
    buttons[I]:= TAeroThemeButton.Create(Self);
    buttons[I].Name:= bntName[I];
    buttons[I].Parent:= Self;
    buttons[I].Tag:= I;
    if not AeroCore.RunWindowsVista then
      buttons[I].OnThemePaint:= xp_w3k_theme;
  end;
end;

procedure TAeroBackForward.DestroyButtons;
var
  I: Integer;
begin
  for I:=0 to 2 do
    buttons[I].Free;
  if not AeroCore.RunWindowsVista then
    FreeMsStyle;
end;

procedure TAeroBackForward.SetButtonsProperty;
var
  I: Integer;
begin
  for I:=1 to 3 do
  with buttons[I-1] do
  begin
    Top:= -2;
    if AeroCore.RunWindowsVista then
      Height:= 33
    else
      Height:= 29;
    ThemeClassName:= 'Navigation';
    DrawCaption:= False;
    State.StateNormal:= 1;
    State.StateHightLight:= 2;
    State.StateFocused:= 2;
    State.StateDown:= 3;
    State.StateDisabled:= 4;

    State.PartNormal:= I;
    State.PartHightLight:= I;
    State.PartFocused:= I;
    State.PartDown:= I;
    State.PartDisabled:= I;
  end;

  with buttons[0] do
  begin
    Left:= 0;
    Width:= 33;
    OnClick:= buttonClick;
  end;

  with buttons[1] do
  begin
    Left:= 32;
    Width:= 33;
    OnClick:= buttonClick;
  end;

  with buttons[2] do
  begin
    Left:= 64;
    Width:= 17;
    OnClick:= btnBackMenuClick;
  end;
end;

procedure TAeroBackForward.SetGoToMenu(const Value: TPopupMenu);
begin
  FGoToMenu:= Value;
end;

function TAeroBackForward.GetBtnEnabled(const Index: Integer): BooLean;
begin
  Result:= buttons[Index].Enabled;
end;

procedure TAeroBackForward.SetBtnEnabled(const Index: Integer; const Value: BooLean);
begin
  buttons[Index].Enabled:= Value;
end;

procedure TAeroBackForward.btnBackMenuClick(Sender: TObject);
var
  Point: TPoint;
begin
  if Assigned(FGoToMenu) then
  begin
    Point:= buttons[2].ClientOrigin;
    Point.Y:= Point.Y+buttons[2].Height;
    with Point do
      FGoToMenu.Popup(X, Y);
  end;
end;

procedure TAeroBackForward.buttonClick(Sender: TObject);
begin
  if Assigned(FOnBtnClick) then
    FOnBtnClick(Self,TAeroThemeButton(Sender).Tag);
end;

procedure TAeroBackForward.LoadMsStyle;
const
  bntName: Array [1..3] of String = ('933.png','935.png','937.png');
var
  I: Integer;
  Dir: String;
begin
  Dir:= TAeroBackForward.Resources_Images_xp_w3k;
  for I:=1 to 3 do
  begin
    AeroXP[I]:= TPNGImage.Create;
    if FileExists(Dir+bntName[I]) then
      AeroXP[I].LoadFromFile(Dir+bntName[I])
    else
      MessageBox(0, pChar('Cant load image: '+sLineBreak+Dir+bntName[I]),
        'Aero UI - Error', MB_ICONHAND OR MB_OK);
  end;
end;

procedure TAeroBackForward.FreeMsStyle;
var
  I: Integer;
begin
  for I:=1 to 3 do
    AeroXP[I].Free;
end;

procedure TAeroBackForward.xp_w3k_theme(const Sender: TAeroCustomButton; PartID, StateID: Integer; Surface: TCanvas);
begin
  Surface.Draw(0,-(27*(StateID-1))+2,AeroXP[PartID]);
end;

{ TAeroIEBackForward }

Constructor TAeroIEBackForward.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  FMenuTimer:= TTimer.Create(Self);
  FMenuTimer.Enabled:= False;
  FMenuTimer.Interval:= 300;
  FMenuTimer.OnTimer:= ShowTravelMenu;

  FOnlyBackButton:= False;

  FStateBack:= bsDisabled;
  FStateForward:= bsDisabled;

  FBackDown:= false;
  FForwardDown:= false;

  bmBackground:= AeroPicture.LoadImage( ResourcesImagesPath+'TRAVEL_BACKGROUND_MINIE.png' );
  bmMask:= AeroPicture.LoadImage( ResourcesImagesPath+'TRAVEL_MINIE_MASK.png' );

  bmButton[bsNormal]:= AeroPicture.LoadImage( ResourcesImagesPath+'TRAVEL_ENABLED_MINIE.png' );
  bmButton[bsHightLight]:= AeroPicture.LoadImage( ResourcesImagesPath+'TRAVEL_HOT_MINIE.png' );
  bmButton[bsDown]:= AeroPicture.LoadImage( ResourcesImagesPath+'TRAVEL_PRESSED_MINIE.png' );
  bmButton[bsDisabled]:= AeroPicture.LoadImage( ResourcesImagesPath+'TRAVEL_DISABLED_MINIE.png' );

  Height:= 36;
  Width:= 76;
end;

Destructor TAeroIEBackForward.Destroy;
begin
  bmButton[bsNormal].Free();
  bmButton[bsHightLight].Free();
  bmButton[bsDown].Free();
  bmButton[bsDisabled].Free();
  bmMask.Free();
  bmBackground.Free();
  FMenuTimer.Free;
  Inherited Destroy;
end;

function TAeroIEBackForward.GetRenderState: TRenderConfig;
begin
  Result:= [rsBuffer];
end;

procedure TAeroIEBackForward.Click;
begin
  inherited Click;
  if Assigned(FOnBtnClick) then
  begin
    if FStateBack in [bsHightLight, bsDown] then
      FOnBtnClick(Self, 0);
    if FStateForward in [bsHightLight, bsDown] then
      FOnBtnClick(Self, 1);
  end;
end;

procedure TAeroIEBackForward.ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig);
begin
  RenderControl(PaintDC);
end;

procedure TAeroIEBackForward.ClassicRender(const ACanvas: TCanvas);
begin
  RenderControl(ACanvas.Handle);
end;

procedure TAeroIEBackForward.PostRender(const Surface: TCanvas; const RConfig: TRenderConfig);
begin

end;

procedure TAeroIEBackForward.RenderControl(const PaintDC: hDC);

  function Size(cx, cy: Integer): TSize;
  begin
    Result.cx:= cx;
    Result.cy:= cy;
  end;

begin
  if not FOnlyBackButton then
    AeroPicture.Draw(PaintDC, bmBackground, Point(0, 1) );
  if Self.Enabled then
  begin
    if csDesigning in ComponentState then
    begin
      AeroPicture.DrawPart( PaintDC, bmMask.Canvas.Handle, Point(0,0),
        Size(38, 35), 0, ioHorizontal );
      AeroPicture.DrawPart( PaintDC, bmButton[bsNormal].Canvas.Handle,
        Point(0,0), Size(38, 35), 0, ioHorizontal );
      if not FOnlyBackButton then
        AeroPicture.DrawPart( PaintDC, bmButton[bsDisabled].Canvas.Handle,
          Point(38,0), Size(38, 35), 1, ioHorizontal );
    end
    else
    begin
      if FStateBack <> bsDisabled then
        AeroPicture.DrawPart( PaintDC, bmMask.Canvas.Handle, Point(0,0),
          Size(38, 35), 0, ioHorizontal );

      if not FOnlyBackButton and (FStateForward <> bsDisabled) then
        AeroPicture.DrawPart( PaintDC, bmMask.Canvas.Handle, Point(38,0),
          Size(38, 35), 1, ioHorizontal );

      AeroPicture.DrawPart( PaintDC, bmButton[FStateBack].Canvas.Handle,
        Point(0,0), Size(38, 35), 0, ioHorizontal );

      if not FOnlyBackButton then
        AeroPicture.DrawPart( PaintDC, bmButton[FStateForward].Canvas.Handle,
          Point(38,0), Size(38, 35), 1, ioHorizontal );
    end;
  end
  else
    AeroPicture.Draw(PaintDC, bmButton[bsDisabled], Point(0, 0) );
end;

procedure TAeroIEBackForward.SetButtonEnabled(const Index: Integer; const Value: boolean);
begin
  case Index of
    0: if Value then FStateBack:= bsNormal else FStateBack:= bsDisabled;
    1: if Value then FStateForward:= bsNormal else FStateForward:= bsDisabled;
  end;
  Invalidate;
end;

procedure TAeroIEBackForward.SetOnlyBackButton(const Value: Boolean);
begin
  if FOnlyBackButton <> Value then
  begin
    FOnlyBackButton := Value;
    Invalidate;
  end;
end;

procedure TAeroIEBackForward.SetTravelMenu(const Value: TPopupMenu);
begin
  FTravelMenu := Value;
  if Value <> nil then
  begin
    Value.ParentBiDiModeChanged(Self);
    Value.FreeNotification(Self);
  end;
end;

procedure TAeroIEBackForward.ShowTravelMenu(Sender: TObject);
begin
  FMenuTimer.Enabled:= False;
  if FBackDown and Assigned(FTravelMenu) then
  begin
    FBackDown:= False;
    FStateBack:= bsNormal;
    with Self.ClientToScreen( Point(0, Height-3) ) do
      FTravelMenu.Popup(x, y);
  end;
  if FForwardDown and Assigned(FTravelMenu) then
  begin
    FForwardDown:= False;
    FStateForward:= bsNormal;
    with Self.ClientToScreen( Point(38, Height-3) ) do
      FTravelMenu.Popup(x, y);
  end;

end;

function TAeroIEBackForward.GetButtonEnabled(const Index: Integer): boolean;
begin
  case Index of
    0: Result:= FStateBack <> bsDisabled;
    1: Result:= FStateForward <> bsDisabled;
  else
    Result:= False;
  end;
end;

procedure TAeroIEBackForward.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  OStateBack: TAeroButtonState;
  OStateForward: TAeroButtonState;
begin
  Inherited MouseDown(Button, Shift, X, Y);
  OStateBack:= FStateBack;
  OStateForward:= FStateForward;

  if (FStateBack <> bsDisabled) then
  begin
    if Point(X,Y).InRect( Rect(0, 0, 38, 35) ) then
    begin
      FStateBack:= bsDown;
      FBackDown:= True;
      FMenuTimer.Enabled:= True;
    end
    else
      FBackDown:= False;
  end;

  if (FStateForward <> bsDisabled) then
  begin
    if Point(X,Y).InRect( Rect(38, 0, 76, 35) ) then
    begin
      FStateForward:= bsDown;
      FForwardDown:= True;
      FMenuTimer.Enabled:= True;
    end
    else
      FForwardDown:= False;
  end;

  if (OStateBack <> FStateBack) or (OStateForward <> FStateForward) then
    Invalidate;
end;

procedure TAeroIEBackForward.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Inherited MouseUp(Button, Shift, X, Y);
  FMenuTimer.Enabled:= True;
  FBackDown:= False;
  FForwardDown:= False;
  MouseMove(Shift, X, Y);
end;

procedure TAeroIEBackForward.Notification(AComponent: TComponent; Operation: TOperation);
begin
  Inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FTravelMenu) then
    FTravelMenu:= nil;
end;

procedure TAeroIEBackForward.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  OStateBack: TAeroButtonState;
  OStateForward: TAeroButtonState;
begin
  Inherited MouseMove(Shift, X, Y);
  OStateBack:= FStateBack;
  OStateForward:= FStateForward;

  if (FStateBack <> bsDisabled) then
  begin
    if Point(X,Y).InRect( Rect(0, 0, 38, 35) ) then
    begin
      if FBackDown then
        FStateBack:= bsDown
      else
        FStateBack:= bsHightLight
    end
    else
      FStateBack:= bsNormal;
  end;

  if (FStateForward <> bsDisabled) then
  begin
    if Point(X,Y).InRect( Rect(38, 0, 76, 35) ) then
    begin
      if FForwardDown then
        FStateForward:= bsDown
      else
        FStateForward:= bsHightLight
    end
    else
      FStateForward:= bsNormal;
  end;

  if (OStateBack <> FStateBack) or (OStateForward <> FStateForward) then
  begin
    Invalidate;
  end;
end;

procedure TAeroIEBackForward.WndProc(var Message: TMessage);
begin
  Inherited WndProc(Message);
  case Message.Msg of
    CM_MOUSEENTER: Invalidate;
    CM_MOUSELEAVE:
      begin
        if (FStateBack <> bsDisabled) then FStateBack:= bsNormal;
        if (FStateForward <> bsDisabled) then FStateForward:= bsNormal;
        Invalidate;
      end;
  end;
end;



end.

