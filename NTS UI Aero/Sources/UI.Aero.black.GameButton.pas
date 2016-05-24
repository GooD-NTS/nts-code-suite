{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.black.GameButton;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.Classes,
  Winapi.Windows,
  Winapi.UxTheme,
  Vcl.Graphics,
  {$ELSE}
  Windows, Classes, Graphics, UxTheme,
  {$ENDIF}
  UI.Aero.Button.Custom,
  UI.Aero.Button.Theme,
  UI.Aero.Button;

type
  TBlackGameButton = class(TAeroThemeButton)
  private
    subLeft: Integer;
  Protected
    function GetCaptionRect: TRect; override;
    function GetTextFormat: Cardinal; override;
    procedure DoClassicThemePaint(const Sender: TAeroCustomButton; PartID, StateID: Integer; Surface: TCanvas); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddSub(sText, sGameTag: String; iTag: integer; whenClick: TNotifyEvent; isEnabled: Boolean);
  end;

implementation

uses
  UI.Aero.Core;

{ TBlackGameButton }

Constructor TBlackGameButton.Create(AOwner: TComponent);
var
  osPartID: Integer;
begin
  Inherited Create(AOwner);
  subLeft:= 0;
  ThemeClassName:= 'BUTTON';
  Height:= 73;
  Width:= 305;
  if AeroCore.RunWindowsVista then
    osPartID:= BP_COMMANDLINK
  else
    osPartID:= BP_PUSHBUTTON;

  with State do
  begin
    PartNormal:= osPartID;
    PartHightLight:= osPartID;
    PartFocused:= osPartID;
    PartDown:= osPartID;
    PartDisabled:= osPartID;

    StateNormal:= 1;
    StateHightLight:= 2;
    StateFocused:= 5;
    StateDown:= 3;
    StateDisabled:= 4;
  end;

  with Image do
  begin
    PartHeight:= 64;
    PartWidth:= 64;
  end;
end;

destructor TBlackGameButton.Destroy;
begin
  inherited Destroy;
end;

procedure TBlackGameButton.DoClassicThemePaint(const Sender: TAeroCustomButton; PartID, StateID: Integer; Surface: TCanvas);
begin
  case StateID of
    2:
    begin
      Surface.Brush.Color:= clHighlight;
      Surface.FillRect( Self.GetClientRect );
    end;
    3:
    begin
      Surface.Brush.Color:= clHotLight;
      Surface.FillRect( Self.GetClientRect );
    end;
  end;
  Inherited DoClassicThemePaint(Sender,PartID,StateID,Surface);
end;

procedure TBlackGameButton.AddSub(sText, sGameTag: String; iTag: integer; whenClick: TNotifyEvent; isEnabled: Boolean);
var
  AButton: TAeroButton;
begin
  AButton := TAeroButton.Create(Self);
  AButton.Parent := Self;
  AButton.Caption := sText;
  AButton.sTag := sGameTag;
  AButton.Tag := iTag;
  AButton.FlatStyle := True;
  AButton.OnClick := whenClick;
  AButton.Top := 24;
  AButton.Left := 76 + subLeft;
  AButton.Enabled := isEnabled;
  subLeft := subLeft + AButton.Width + 4;
end;

function TBlackGameButton.GetCaptionRect: TRect;
begin
  Result.Left := 76;
  Result.Top := 4;
  Result.Right := Width - 4;
  Result.Bottom := Height - 8;
end;

function TBlackGameButton.GetTextFormat: Cardinal;
begin
  Result:= (DT_TOP OR DT_LEFT OR DT_SINGLELINE);
end;

end.
