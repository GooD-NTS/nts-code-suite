{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Window;

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
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Themes,
  Vcl.Imaging.GIFImg,
  Vcl.Forms,
  {$ELSE}
  SysUtils, Classes, Windows, Messages, UxTheme, DwmApi,
  Themes, Controls, Graphics, GIFImg, Forms,
  {$ENDIF}
  NTS.Code.Common.Types,
  UI.Aero.Globals,
  UI.Aero.Core;

type
  TBaseAeroWindow = Class(AeroCore)
  Private
    DefaultWindowProc: TWndMethod;
    ThemeData: hTheme;
    StateID: Integer;
    OldWidth,
    OldHeight: Integer;
    fSnapMode: TSnapMode;
    fAutoSnap: BooLean;
    fSnapSize: Integer;
    fOnSnap: TNotifyEvent;
    fOnUnSnap: TNotifyEvent;
    function GetComposition: BooLean;
    function GetWindowsVista: BooLean;    
    procedure FindWindow;
    Procedure TestSnap(var Message: TMessage);
    procedure LoadAeroTheme;
  Protected
    Window: TForm;
    Procedure AEROWindowProc(var Message: TMessage); Virtual;
    Procedure AEROWindowPaint(Sender: TObject);
    Procedure CurrentThemeChanged; Virtual;
  Public
    BackGroundImage: TBitmap;
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
    function IsRunTime: Boolean;
  Published
    Property WindowsVista: BooLean Read GetWindowsVista;
    Property Composition: BooLean Read GetComposition;
    Property AutoSnap: BooLean Read fAutoSnap Write fAutoSnap default False;
    Property SnapSize: Integer Read fSnapSize Write fSnapSize default 0;
    Property SnapMode: TSnapMode Read fSnapMode Write fSnapMode default smTop;
  //
    Property OnSnap: TNotifyEvent Read fOnSnap Write fOnSnap;
    Property OnUnSnap: TNotifyEvent Read fOnUnSnap Write fOnUnSnap;    
  End;

  TAeroWindow = class(TBaseAeroWindow)
  private
    fShowInTaskBar: BooLean;
    fIcon: TImageFileName;
    fShowCaptionBar: BooLean;
    fDragWindow: BooLean;
    fLines: TStrings;
    fLinesCount: Integer;
    procedure SetIcon(const Value: TImageFileName);
    procedure SetShowCaptionBar(const Value: BooLean);
    procedure SetShowInTaskBar(const Value: BooLean);
    procedure DragMove(X,Y: Integer);
    procedure SetLines(const Value: TStrings);
    function GetStringListText: String;
    procedure SetLinesCount(const Value: Integer);
  protected
    Procedure AEROWindowProc(var Message: TMessage); OverRide;
    Procedure ChangeTaskBar;
    Procedure ChangeCaptionBar;
  public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
    function GetString(Index: Integer): string; inline;
  published
    property Icon: TImageFileName Read fIcon Write SetIcon;
    property ShowInTaskBar: BooLean Read fShowInTaskBar Write SetShowInTaskBar Default True;
    property ShowCaptionBar: BooLean Read fShowCaptionBar Write SetShowCaptionBar Default True;
    Property DragWindow: BooLean Read fDragWindow Write fDragWindow Default False;
    property StringList: TStrings Read fLines Write SetLines;
    property LinesCount: Integer Read fLinesCount Write SetLinesCount;
    property Text: String Read GetStringListText;
  end;

implementation

uses
  System.Types,
  System.IOUtils,
  NTS.Code.Helpers;

{ TBaseAeroWindow }

Constructor TBaseAeroWindow.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  if AeroCore.FirstInstance = nil then
  begin
    AeroCore.FirstInstance:= Self;
    if AeroCore.RunWindowsVista then
      AeroCore.CompositionActive:= IsCompositionActive
    else
      AeroCore.CompositionActive:= False;
  end;
  BackGroundImage:= TBitmap.Create;
  FindWindow;
  if not Assigned(Window) then
    raise Exception.Create('Aero Engine: [Fatal error] Parent owner Window is nil.');
  if IsRunTime then
  begin
    Self.DefaultWindowProc:= Window.WindowProc;
    Window.WindowProc:= Self.AEROWindowProc;
    Window.OnPaint:= Self.AEROWindowPaint;
  end;
  LoadAeroTheme;
  StateID:= 1;
  fAutoSnap:= False;
  fSnapSize:= 0;
  fSnapMode:= smTop;
  fOnSnap:= nil;
  fOnUnSnap:= nil;
end;

Destructor TBaseAeroWindow.Destroy;
begin
  if IsRunTime then
  begin
    Window.WindowProc:= Self.DefaultWindowProc;
    Window.OnPaint:= nil;
  end;
  if ThemeData <> 0 then
    CloseThemeData(ThemeData);
  if Assigned(BackGroundImage) then
    BackGroundImage.Free;
  if AeroCore.FirstInstance = Self then
    AeroCore.FirstInstance:= nil;
  Inherited Destroy;
end;

procedure TBaseAeroWindow.LoadAeroTheme;
begin
  if RunWindowsVista and {$IFDEF HAS_VCLSTYLES}StyleServices.Enabled{$ELSE}ThemeServices.ThemesEnabled{$ENDIF} then
    ThemeData:= OpenThemeData(0,'AeroWizard')
  else
    ThemeData:= 0;
end;

procedure TBaseAeroWindow.CurrentThemeChanged;
begin
  if AeroCore.RunWindowsVista then
  begin
    if AeroCore.FirstInstance = Self then
      AeroCore.CompositionActive:= IsCompositionActive
    else
    if AeroCore.FirstInstance = nil then
    begin
      AeroCore.FirstInstance:= Self;
      AeroCore.CompositionActive:= IsCompositionActive;
    end;
  end
  else
    AeroCore.CompositionActive:= False;
  if ThemeData <> 0 then
    CloseThemeData(ThemeData);
  LoadAeroTheme;
end;

procedure TBaseAeroWindow.FindWindow;
begin
  if Owner is TForm then
    Window:= TForm(Owner)
  else
    Window:= nil;
end;

function TBaseAeroWindow.GetComposition: BooLean;
begin
  Result:= AeroCore.CompositionActive;
end;

function TBaseAeroWindow.GetWindowsVista: BooLean;
begin
  Result:= RunWindowsVista;
end;

function TBaseAeroWindow.IsRunTime: Boolean;
begin
  Result:= not (csDesigning in ComponentState);
end;

procedure TBaseAeroWindow.TestSnap(var Message: TMessage);

  function CheckNewSize(var NewWidth, NewHeight: Integer): Boolean;
  var
    Magic: Integer;
    OldValue: BooLean;
  begin
    Result:= True;
    OldValue:= Window.GlassFrame.SheetOfGlass;
    case fSnapMode of
      smTop:
        begin
          Magic:= Window.Height-Window.ClientHeight;
          if NewHeight <= Window.GlassFrame.Top+Magic+fSnapSize then
          begin
            NewHeight:= Window.GlassFrame.Top+Magic;
            Window.GlassFrame.SheetOfGlass:= True;
            if (OldValue <> Window.GlassFrame.SheetOfGlass) and Assigned(fOnSnap) then
              fOnSnap(Self);
          end
          else
          begin
            Window.GlassFrame.SheetOfGlass:= False;
            if (OldValue <> Window.GlassFrame.SheetOfGlass) and Assigned(fOnUnSnap) then
              fOnUnSnap(Self);
          end;
        end;
      smBottom:
        begin
          Magic:= (Window.Height-Window.ClientHeight);
          if NewHeight <= Window.GlassFrame.Bottom+Magic+fSnapSize then
          begin
            NewHeight:= Window.GlassFrame.Bottom+Magic;
            Window.GlassFrame.SheetOfGlass:= True;
            if (OldValue <> Window.GlassFrame.SheetOfGlass) and Assigned(fOnSnap) then
              fOnSnap(Self);
          end
          else
          begin
            Window.GlassFrame.SheetOfGlass:= False;
            if (OldValue <> Window.GlassFrame.SheetOfGlass) and Assigned(fOnUnSnap) then
              fOnUnSnap(Self);
          end;
        end;
      smLeft:
        begin
          Magic:= (Window.Width-Window.ClientWidth);
          if NewWidth <= Window.GlassFrame.Left+Magic+fSnapSize then
          begin
            NewWidth:= Window.GlassFrame.Left+Magic;
            Window.GlassFrame.SheetOfGlass:= True;
            if (OldValue <> Window.GlassFrame.SheetOfGlass) and Assigned(fOnSnap) then
              fOnSnap(Self);
          end
          else
          begin
            Window.GlassFrame.SheetOfGlass:= False;
            if (OldValue <> Window.GlassFrame.SheetOfGlass) and Assigned(fOnUnSnap) then
              fOnUnSnap(Self);
          end;
        end;
      smRight:
        begin
          Magic:= (Window.Width-Window.ClientWidth);
          if NewWidth <= Window.GlassFrame.Right+Magic+fSnapSize then
          begin
            NewWidth:= Window.GlassFrame.Right+Magic;
            Window.GlassFrame.SheetOfGlass:= True;
            if (OldValue <> Window.GlassFrame.SheetOfGlass) and Assigned(fOnSnap) then
              fOnSnap(Self);
          end
          else
          begin
            Window.GlassFrame.SheetOfGlass:= False;
            if (OldValue <> Window.GlassFrame.SheetOfGlass) and Assigned(fOnUnSnap) then
              fOnUnSnap(Self);
          end;
        end;
    end;
  end;

var
  WinPos: PWindowPos;
begin
  WinPos:= Pointer(Message.LParam);
  with WinPos^ do
  if (flags and SWP_NOSIZE = 0) and not CheckNewSize(cx, cy) then
    flags := flags or SWP_NOSIZE;
  Self.DefaultWindowProc(Message);
end;

procedure TBaseAeroWindow.AEROWindowPaint(Sender: TObject);
var
  LClientRect: TRect;
begin
  if RunWindowsVista and not Composition and {$IFDEF HAS_VCLSTYLES}StyleServices.Enabled{$ELSE}ThemeServices.ThemesEnabled{$ENDIF} then
  begin
    LClientRect:= Window.ClientRect;
    LClientRect.Bottom:= LClientRect.Bottom+1;
    if not Window.GlassFrame.SheetOfGlass then
      ExcludeClipRect( Window.Canvas.Handle, Window.GlassFrame.Left,
        Window.GlassFrame.Top, LClientRect.Right - Window.GlassFrame.Right,
        LClientRect.Bottom - Window.GlassFrame.Bottom );
    DrawThemeBackground(ThemeData, Window.Canvas.Handle, 1, StateID,
      LClientRect, @LClientRect);
    BackGroundImage.SetSize(Window.Width,Window.Height);
    BackGroundImage.Canvas.Brush.Color:= Window.Color;
    BackGroundImage.Canvas.FillRect(Rect(0, 0, Window.Width, Window.Height));
    DrawThemeBackground(ThemeData, BackGroundImage.Canvas.Handle, 1, 1,
      LClientRect, @LClientRect);
  end;
end;

procedure TBaseAeroWindow.AEROWindowProc(var Message: TMessage);
begin
  if (Message.Msg = WM_WINDOWPOSCHANGING) and fAutoSnap then
    TestSnap(Message)
  else
    DefaultWindowProc(Message);
  case Message.Msg of
    WM_THEMECHANGED,
    WM_DWMCOMPOSITIONCHANGED: CurrentThemeChanged;
    WM_ACTIVATE:
      if RunWindowsVista and not Composition and {$IFDEF HAS_VCLSTYLES}StyleServices.Enabled{$ELSE}ThemeServices.ThemesEnabled{$ENDIF}then
      begin
        case Message.wParam of
          WA_ACTIVE, WA_CLICKACTIVE: StateID:= 1;
          WA_INACTIVE: StateID:= 2;
        end;
        Window.Invalidate;
      end;
    WM_WINDOWPOSCHANGED:
      if RunWindowsVista and not Composition and {$IFDEF HAS_VCLSTYLES}StyleServices.Enabled{$ELSE}ThemeServices.ThemesEnabled{$ENDIF} then
      begin
        if (OldWidth <> Window.ClientWidth) or (OldHeight <> Window.ClientHeight) then
        begin
          Window.Invalidate;
          OldWidth:= Window.ClientWidth;
          OldHeight:= Window.ClientHeight;
        end;
      end;
  end;
end;

{ TAeroWindow }

Constructor TAeroWindow.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  fIcon:= '';
  fShowInTaskBar:= True;
  fShowCaptionBar:= True;
  fDragWindow:= False;
  fLines:= TStringList.Create;
  fLinesCount:= 0;
end;

Destructor TAeroWindow.Destroy;
begin
  fLines.Free;
  Inherited Destroy;
end;

procedure TAeroWindow.DragMove(X, Y: Integer);
const
  SC_DragMove = $F012;
var
  NonGlassRect: TRect;
begin
  if Window.GlassFrame.SheetOfGlass then
  begin
    ReleaseCapture;
    Window.Perform(WM_SysCommand, SC_DragMove, 0);
  end
  else
  begin
    NonGlassRect:= Window.ClientRect;
    NonGlassRect := Rect(Window.GlassFrame.Left, Window.GlassFrame.Top,
      NonGlassRect.Right - Window.GlassFrame.Right,
      NonGlassRect.Bottom - Window.GlassFrame.Bottom );
    if not Point(X,Y).InRect(NonGlassRect) then
    begin
      ReleaseCapture;
      Window.Perform(WM_SysCommand, SC_DragMove, 0);
    end;
  end;
end;

function TAeroWindow.GetString(Index: Integer): string;
begin
  if (StringList.Count > 0) and (Index > -1) and (Index < StringList.Count-1) then
    Result:= StringList[Index]
  else
    Result:= 'LangString:'+IntToStr(Index);
end;

function TAeroWindow.GetStringListText: String;
begin
  Result:= fLines.Text;
end;

procedure TAeroWindow.AEROWindowProc(var Message: TMessage);
begin
  if (Message.Msg = CM_SHOWINGCHANGED) and (Window.Showing) then
  begin
    ChangeCaptionBar;
    ChangeTaskBar;
  end;
  Inherited AEROWindowProc(Message);
  if (Message.Msg = WM_LBUTTONDOWN) and (fDragWindow) then
    DragMove(Message.LParamLo, Message.LParamHi);
end;

procedure TAeroWindow.SetIcon(const Value: TImageFileName);

  Procedure SetZeroIcon(FreeOld: BooLean);
  begin
    if FreeOld then
    begin
      DestroyIcon(SendMessage(Window.Handle, WM_GETICON, ICON_SMALL, 0));
      DestroyIcon(SendMessage(Window.Handle, WM_SETICON, ICON_SMALL, 0));
    end;
    PostMessage(Window.Handle, WM_SETICON, ICON_SMALL, 0);
    PostMessage(Window.Handle, WM_SETICON, ICON_BIG, 0);
  end;

  Procedure SetNewIcon;
  var
    Icon: hIcon;
  begin
    Icon:= LoadImage(HInstance,pChar(fIcon),IMAGE_ICON,
      GetSystemMetrics(SM_CXSMICON),GetSystemMetrics(SM_CYSMICON),
      LR_LOADFROMFILE);
    PostMessage(Window.Handle, WM_SETICON, ICON_SMALL, Icon);
    Icon:= LoadImage(HInstance,pChar(fIcon),IMAGE_ICON,
      GetSystemMetrics(SM_CXICON),GetSystemMetrics(SM_CYICON),LR_LOADFROMFILE);
    PostMessage(Window.Handle, WM_SETICON, ICON_BIG, Icon);
  end;

begin
  if fIcon <> Value then
  begin
    SetZeroIcon(fIcon <> '');
    fIcon:= Value;
    if TFile.Exists(fIcon) then
      SetNewIcon;;
  end;
end;

procedure TAeroWindow.SetLines(const Value: TStrings);
begin
  fLines.Assign(Value);
end;

procedure TAeroWindow.SetLinesCount(const Value: Integer);
var
  I: Integer;
begin
  fLinesCount := Value;
  if IsRunTime then
  begin
    FLines.Clear;
    for I:=0 to Value do
      FLines.Add(Window.Name+'.StringList.Item_'+IntToStr(I));
  end;
end;

procedure TAeroWindow.SetShowCaptionBar(const Value: BooLean);
begin
 if fShowCaptionBar <> Value then
  begin
   fShowCaptionBar:= Value;
   if IsRunTime then
    ChangeCaptionBar;
  end;
end;

procedure TAeroWindow.SetShowInTaskBar(const Value: BooLean);
begin
  if fShowInTaskBar <> Value then
  begin
    fShowInTaskBar:= Value;
    if IsRunTime then
      ChangeTaskBar;
  end;
end;

procedure TAeroWindow.ChangeCaptionBar;
begin
  if AeroCore.RunWindowsVista then
  begin
    if fShowCaptionBar then
      SetWindowThemeNonClientAttributes(Window.Handle, WTNCA_VALIDBITS, 0)
    else
      SetWindowThemeNonClientAttributes(Window.Handle, WTNCA_VALIDBITS, WTNCA_VALIDBITS);
  end;
end;

procedure TAeroWindow.ChangeTaskBar;
begin         
  if fShowInTaskBar then
    SetWindowLong(Window.Handle,GWL_EXSTYLE,GetWindowLong(Window.Handle,GWL_EXSTYLE) or WS_EX_APPWINDOW)
  else
    SetWindowLong(Window.Handle,GWL_EXSTYLE,GetWindowLong(Window.Handle,GWL_EXSTYLE) and not WS_EX_APPWINDOW);
end;

{ Initialization & Finalization }

Initialization
begin
  Screen.Cursors[crHandPoint]:= LoadCursor(0,IDC_HAND);
  GIFImageDefaultAnimate:= True;

end;

Finalization
begin
 // To Do: Type code here...
end;

end.
