{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.SearchBox;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils,
  System.Classes,

  Winapi.Windows,
  Winapi.Messages,
  Winapi.GDIPOBJ,
  Winapi.CommCtrl,
  Winapi.UxTheme,
  Winapi.DwmApi,

  Vcl.Controls,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.Themes,
  Vcl.Imaging.pngimage,
  Vcl.Forms,
  {$ELSE}
  SysUtils, Windows, Messages, Classes, Controls, Graphics, CommCtrl,
  Themes, UxTheme, DwmApi, PNGImage, StdCtrls, Winapi.GDIPOBJ, Forms,
  {$ENDIF}
  NTS.Code.Common.Types,
  UI.Aero.Core.BaseControl,
  UI.Aero.Core.CustomControl,
  UI.Aero.Globals,
  UI.Aero.Button.Theme;

type
  TAeroSearchBox = class(TCustomAeroControl)
  private
    StateID: Integer;
    EditControl: TEdit;
    EditControlWindowProc: TWndMethod;
    fBannerText: String;
    FIsModernWindows: boolean;

    function GetEditTest: String;
    procedure SetEditText(const Value: String);
    function GetEditChangeEvent: TNotifyEvent;
    procedure SetEditChangeEvent(const Value: TNotifyEvent);
    procedure SetBannerText(const Value: String);
    procedure FixGlassPaint;
    function GetEditKeyDownEvent: TKeyEvent;
    function GetEditKeyPressEvent: TKeyPressEvent;
    function GetEditKeyUpEvent: TKeyEvent;
    procedure SetEditKeyPressEvent(const Value: TKeyPressEvent);
    procedure SetEditKeyUpEvent(const Value: TKeyEvent);
    procedure SetEditKeyDownEvent(const Value: TKeyEvent);//;cs
  protected
    function GetRenderState: TRenderConfig; override;
    procedure ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig); OverRide;
    procedure ClassicRender(const ACanvas: TCanvas); override;
    procedure EditWindowProc(var Message: TMessage);
    procedure SetParent(AParent: TWinControl); override;
    procedure SetEditTheme;
    procedure WndProc(var Message: TMessage); override;
    procedure SetEnabled(Value: Boolean); override;
    function GetThemeClassName: PWideChar; override;
    procedure PostRender(const Surface: TCanvas; const RConfig: TRenderConfig); override;
    procedure SearchButtonClick(Sender: TObject);
    procedure UpdateButtonStatus();
    procedure CreateWnd; override;
  public
    FSearchButton: TAeroThemeButton;
    function EditHandle: THandle;
    function GetEditControl: TEdit;
    constructor Create(AOwner: TComponent); OverRide;
    destructor Destroy; OverRide;
  public
    class var CompatibilitySearchButtonImage: string;
  published
    property Text: String Read GetEditTest Write SetEditText;
    property DesigningRect Default False;
    property BannerText: String read fBannerText Write SetBannerText;

    property OnTextChange: TNotifyEvent Read GetEditChangeEvent Write SetEditChangeEvent;
    property OnKeyDown: TKeyEvent read GetEditKeyDownEvent write SetEditKeyDownEvent;
    property OnKeyPress: TKeyPressEvent read GetEditKeyPressEvent write SetEditKeyPressEvent;
    property OnKeyUp: TKeyEvent read GetEditKeyUpEvent write SetEditKeyUpEvent;
  end;

implementation

uses
  UI.Aero.Window;

{ From CommCtrl.h }

function Edit_SetCueBannerTextFocused(hwnd: HWND; lpcwText: PChar;fDrawFocused: Bool): Bool;
begin
  Result := Bool(SendMessage(hwnd, EM_SETCUEBANNER, WPARAM(fDrawFocused), LPARAM(lpcwText)));
end;

{ TAeroSearchBox }

constructor TAeroSearchBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Height := 24;
  Width := 240;
  Constraints.MaxHeight := 24;
  Constraints.MinHeight := 24;
  StateID := 1;
  FIsModernWindows := CheckWin32Version(6, 2);

  FSearchButton := TAeroThemeButton.Create(Self);
  EditControl := TEdit.Create(Self);
  with EditControl do
  begin
    Name := 'Edit';
    Parent := Self;
    AlignWithMargins := True;
    Margins.SetBounds(2, 5, 3, 3);
    Align := alClient;
    BorderStyle := bsNone;
    Text := '';
  end;

  EditControl.DoubleBuffered := False;
  EditControlWindowProc := EditControl.WindowProc;
  EditControl.WindowProc := EditWindowProc;

  FSearchButton.Name := 'SearchButton';
  FSearchButton.Parent := Self;
  FSearchButton.AlignWithMargins := True;
  FSearchButton.Margins.SetBounds(0, 0, 2, 0);
  FSearchButton.Align := alRight;
  FSearchButton.Caption := '';
  FSearchButton.DoubleBuffered := False;
  FSearchButton.Width := 24;
  FSearchButton.OnClick := SearchButtonClick;

  if FIsModernWindows then
  begin
    FSearchButton.ThemeClassName := GetThemeClassName;

    FSearchButton.State.PartNormal := 3;
    FSearchButton.State.PartHightLight := 3;
    FSearchButton.State.PartFocused := 3;
    FSearchButton.State.PartDown := 3;
    FSearchButton.State.PartDisabled := 3;

    FSearchButton.State.StateNormal := 1;
    FSearchButton.State.StateHightLight := 1;
    FSearchButton.State.StateFocused := 1;
    FSearchButton.State.StateDown := 1;
    FSearchButton.State.StateDisabled := 1;
  end
  else
  begin
    FSearchButton.Image.FileName := CompatibilitySearchButtonImage;
    FSearchButton.Image.Orientation := ioVertical;
    FSearchButton.Image.PartHeight := 18;
    FSearchButton.Image.PartWidth := 18;
    FSearchButton.Image.PartNormal := 0;
    FSearchButton.Image.PartHightLight := 0;
    FSearchButton.Image.PartDown := 0;
  end;

  DesigningRect := False;
  fBannerText := '';
end;

destructor TAeroSearchBox.Destroy;
begin
  EditControl.WindowProc := EditControlWindowProc;
  EditControl.Free();

  FSearchButton.Free();

  inherited Destroy;
end;

procedure TAeroSearchBox.CreateWnd();
begin
  inherited CreateWnd();
  SetEditTheme();
end;

function TAeroSearchBox.EditHandle: THandle;
begin
  Result := EditControl.Handle;
end;

procedure TAeroSearchBox.EditWindowProc(var Message: TMessage);
var
  WinHandle: HWND;
begin
  EditControl.ControlState := EditControl.ControlState-[csGlassPaint];
  EditControlWindowProc(Message);
  case Message.Msg of
    CM_ENTER:
    begin
      StateID := 4;
      Invalidate;
    end;
    CM_EXIT:
    begin
      WinHandle := WindowFromPoint(Mouse.CursorPos);
      if (WinHandle = EditControl.Handle) or (WinHandle = Self.Handle) then
        StateID := 2
      else
        StateID := 1;
      Invalidate;
    end;
  end;
end;

procedure TAeroSearchBox.FixGlassPaint;
begin
  EditControl.ControlState := EditControl.ControlState - [csGlassPaint];
end;

function TAeroSearchBox.GetThemeClassName: PWideChar;
begin
  if TAeroWindow.RunWindowsVista then
  begin
    if IsCompositionActive then
      Result := 'SearchBoxComposited::SearchBox'
    else
      Result := 'SearchBox';
  end
  else
    Result := 'Edit';
end;

procedure TAeroSearchBox.PostRender(const Surface: TCanvas; const RConfig: TRenderConfig);
begin
  // Nothing here
end;

function TAeroSearchBox.GetEditChangeEvent: TNotifyEvent;
begin
  if Assigned(EditControl) then
    Result := EditControl.OnChange
  else
    Result := nil;
end;

function TAeroSearchBox.GetEditControl: TEdit;
begin
  Result := EditControl;
end;

function TAeroSearchBox.GetEditKeyDownEvent: TKeyEvent;
begin
  if Assigned(EditControl) then
    Result := EditControl.OnKeyDown
  else
    Result := nil;
end;

function TAeroSearchBox.GetEditKeyPressEvent: TKeyPressEvent;
begin
  if Assigned(EditControl) then
    Result := EditControl.OnKeyPress
  else
    Result := nil;
end;

function TAeroSearchBox.GetEditKeyUpEvent: TKeyEvent;
begin
  if Assigned(EditControl) then
    Result := EditControl.OnKeyUp
  else
    Result := nil;
end;

function TAeroSearchBox.GetEditTest: String;
begin
  if Assigned(EditControl) then
    Result := EditControl.Text
  else
    Result := '';
end;

function TAeroSearchBox.GetRenderState: TRenderConfig;
begin
  Result := [];
end;

procedure TAeroSearchBox.SearchButtonClick(Sender: TObject);
begin
  if EditControl.Text <> '' then
    EditControl.Text := '';

  EditControl.SetFocus();
end;

procedure TAeroSearchBox.SetBannerText(const Value: String);
begin
  fBannerText := Value;
  Edit_SetCueBannerTextFocused(EditControl.Handle, PChar(fBannerText), True);
end;

procedure TAeroSearchBox.SetEditChangeEvent(const Value: TNotifyEvent);
begin
  if Assigned(EditControl) then
    EditControl.OnChange := Value;
end;

procedure TAeroSearchBox.SetEditKeyDownEvent(const Value: TKeyEvent);
begin
  if Assigned(EditControl) then
    EditControl.OnKeyDown := Value;
end;

procedure TAeroSearchBox.SetEditKeyPressEvent(const Value: TKeyPressEvent);
begin
  if Assigned(EditControl) then
    EditControl.OnKeyPress := Value;
end;

procedure TAeroSearchBox.SetEditKeyUpEvent(const Value: TKeyEvent);
begin
  if Assigned(EditControl) then
    EditControl.OnKeyUp := Value;
end;

procedure TAeroSearchBox.SetEditText(const Value: String);
begin
  if Assigned(EditControl) then
    EditControl.Text := Value;
end;

procedure TAeroSearchBox.SetEditTheme;
begin
  if TAeroWindow.RunWindowsVista and (Parent <> nil) then
  begin
    if IsCompositionActive then
      SetWindowTheme(EditControl.Handle, 'SearchBoxEditComposited', nil)
    else
      SetWindowTheme(EditControl.Handle, 'SearchBoxEdit', nil)
  end;
end;

procedure TAeroSearchBox.SetEnabled(Value: Boolean);
var
  WinHandle: HWND;
begin
  Inherited SetEnabled(Value);
  EditControl.Enabled := Value;
  if Value then
  begin
    if EditControl.Focused then
      StateID := 3
    else
    begin
      WinHandle := WindowFromPoint(Mouse.CursorPos);
      if (WinHandle = EditControl.Handle) or (WinHandle = Self.Handle) then
        StateID := 2
      else
        StateID := 1;
    end;
  end
  else
    StateID := 3;
  Invalidate;
end;

procedure TAeroSearchBox.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  SetEditTheme();
end;

procedure TAeroSearchBox.WndProc(var Message: TMessage);
begin
  Inherited WndProc(Message);
  case Message.Msg of
    CM_MOUSEENTER:
    begin
      if EditControl.Focused then
        StateID := 4
      else
        StateID := 2;
      Invalidate;
    end;
    CM_MOUSELEAVE:
    begin
      if EditControl.Focused then
        StateID := 4
      else
        StateID := 1;
      Invalidate;
    end;
    CM_CHANGED:
    begin
      UpdateButtonStatus();
    end;
  end;
end;

procedure TAeroSearchBox.ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig);
var
  clRect: TRect;
  StateXP: Integer;
begin
  FixGlassPaint;
  clRect:= GetClientRect;
  if TAeroWindow.RunWindowsVista then
    DrawThemeBackground(ThemeData, PaintDC, 1, StateID, clRect, @clRect)
  else
  begin
    if StateID = 3 then
      StateXP := 4
    else
      StateXP := 1;
    DrawThemeBackground(ThemeData, PaintDC, 1, StateXP, clRect, @clRect);
  end;
end;

procedure TAeroSearchBox.UpdateButtonStatus;
begin
  if Assigned(EditControl) and Assigned(FSearchButton) then
  begin
    if EditControl.Text <> '' then
    begin
      if FIsModernWindows then
      begin
        FSearchButton.State.PartNormal := 2;
        FSearchButton.State.PartHightLight := 2;
        FSearchButton.State.PartFocused := 2;
        FSearchButton.State.PartDown := 2;
        FSearchButton.State.PartDisabled := 2;
      end
      else
      begin
        FSearchButton.Image.PartNormal := 1;
        FSearchButton.Image.PartHightLight := 2;
        FSearchButton.Image.PartDown := 3;
      end;
    end
    else
    begin
      if FIsModernWindows then
      begin
        FSearchButton.State.PartNormal := 3;
        FSearchButton.State.PartHightLight := 3;
        FSearchButton.State.PartFocused := 3;
        FSearchButton.State.PartDown := 3;
        FSearchButton.State.PartDisabled := 3;
      end
      else
      begin
        FSearchButton.Image.PartNormal := 0;
        FSearchButton.Image.PartHightLight := 0;
        FSearchButton.Image.PartDown := 0;
      end;
    end;
  end;
end;

procedure TAeroSearchBox.ClassicRender(const ACanvas: TCanvas);
begin
  ACanvas.Brush.Color := clWindow;
  case StateID of
    1: ACanvas.Pen.Color := clWindowFrame;
    2: ACanvas.Pen.Color := clHighlight;
    3: ACanvas.Pen.Color := clInActiveBorder;
    4: ACanvas.Pen.Color := clActiveBorder;
  end;
  ACanvas.Rectangle(1, 1, Width, Height);
end;

end.

