{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Button.Custom;

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
  Winapi.CommCtrl,
  Winapi.UxTheme,
  Winapi.DwmApi,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Themes,
  Vcl.Imaging.pngimage,
  Vcl.StdCtrls,
  {$ELSE}
  SysUtils, Windows, Messages, Classes, Controls, Graphics, CommCtrl,
  Themes, UxTheme, DwmApi, PNGImage, StdCtrls, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  Winapi.GDIPUTIL,
  {$ENDIF}
  NTS.Code.Common.Types,
  UI.Aero.Core.BaseControl,
  UI.Aero.Core.CustomControl.Animation,
  UI.Aero.Core.Images,
  UI.Aero.Globals;

type
  TAeroCustomButton = class(TCustomAeroControlWithAnimation)
  private
    function GetButtonState: TAEROButtonState;
    procedure SetButtonState(const Value: TAEROButtonState);
  Protected
    SpaceDown: BooLean;
    procedure WndProc(var Message: TMessage); override;
    procedure UpDateButtonState;
    procedure Click; override;
    property ButtonState: TAEROButtonState Read GetButtonState Write SetButtonState;
    procedure ButtonStateChange; Virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
  Public
    Constructor Create(AOwner: TComponent); override;
  Published
    property AnimationDuration Default 250;
    property TabStop default True;
  end;

  TAeroCustomImageButton = class(TAeroCustomButton)
  private
    fImage: TAeroButtonImage;
    procedure SetNewImage(const Value: TAeroButtonImage);
  Protected
    procedure ImageChange(Sender: TObject); Virtual;
  Public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
  Published
    Property Image: TAeroButtonImage Read fImage Write SetNewImage;
  end;

implementation

{ TAeroCustomButton }

Constructor TAeroCustomButton.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  SpaceDown:= False;
  ButtonState:= bsNormal;
  TabStop:= True;
  AnimationDuration:= 250;
end;

procedure TAeroCustomButton.ButtonStateChange;
begin

end;

procedure TAeroCustomButton.Click;
begin
  SetFocus;
  Inherited Click;
end;

function TAeroCustomButton.GetButtonState: TAEROButtonState;
begin
  Result:= TAEROButtonState(NewAniState);
end;

procedure TAeroCustomButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  Inherited KeyDown(Key,Shift);
  case Key of
    VK_RETURN: Click;
    VK_SPACE:
      begin
        SpaceDown:= True;
        UpDateButtonState;
      end;
  end;
end;

procedure TAeroCustomButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  Inherited KeyUp(Key,Shift);
  if Key = VK_SPACE then
  begin
    SpaceDown:= False;
    UpDateButtonState;
    Click;
  end;
end;

procedure TAeroCustomButton.SetButtonState(const Value: TAEROButtonState);
begin
  NewAniState:= Integer(Value);
end;

procedure TAeroCustomButton.UpDateButtonState;
var
  TempValue: TAeroButtonState;
begin
  TempValue:= ButtonState;
  if Enabled then
  begin
    if SpaceDown then
      ButtonState:= bsDown
    else
    if MouseOnControl then
    begin
      if MouseLeftDown then
        ButtonState:= bsDown
      else
        ButtonState:= bsHightLight;
    end
    else
    if Focused then
      ButtonState:= bsFocused
    else
      ButtonState:= bsNormal;
  end
  else
    ButtonState:= bsDisabled;
  if TempValue <> ButtonState then
  begin
    Invalidate;
    ButtonStateChange;
  end; 
end;

procedure TAeroCustomButton.WndProc(var Message: TMessage);
var
  KeyVar: Word;
begin
  Inherited WndProc(Message);
  case Message.Msg of
    CM_EXIT:
    begin
      if SpaceDown then
      begin
        KeyVar:= VK_SPACE;
        KeyUp(KeyVar,[]);
      end;
      UpDateButtonState;
    end;
    CM_ENTER,
    CM_MOUSEENTER,
    CM_MOUSELEAVE,
    CM_ENABLEDCHANGED,
    WM_LBUTTONDOWN,
    WM_LBUTTONUP: UpDateButtonState;
  end;
end;

{ TAeroCustomImageButton }

Constructor TAeroCustomImageButton.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  fImage:= TAEROButtonImage.Create;
  fImage.OnChange:= ImageChange;
end;

Destructor TAeroCustomImageButton.Destroy;
begin
  fImage.Free;
  Inherited Destroy;
end;

procedure TAeroCustomImageButton.ImageChange(Sender: TObject);
begin
  Invalidate;
end;

procedure TAeroCustomImageButton.SetNewImage(const Value: TAeroButtonImage);
begin
  fImage.Assign(Value);
end;

end.
