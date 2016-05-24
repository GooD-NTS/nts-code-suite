{*******************************************************}
{                                                       }
{                    NTS Code Library                   }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit NTS.Code.Components.WindowConfig;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.Classes,
  System.SysUtils,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.UxTheme,
  Winapi.DwmApi,
  Vcl.Forms,
  {$ELSE}
  Classes, SysUtils, Windows, Messages, Forms, UxTheme, DwmApi,
  {$ENDIF}
  NTS.Code.Common.Types;

type             
  TWindowConfig = class(TComponent)
  Private
    fShowInTaskBar: BooLean;
    fIcon: TImageFileName;
    fShowCaptionBar: BooLean;
    procedure SetShowInTaskBar(const Value: BooLean);
    procedure SetIcon(const Value: TImageFileName);
    procedure SetShowCaptionBar(const Value: BooLean);
  Protected
    Window: TForm;
  Public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
  Published
    property ShowInTaskBar: BooLean Read fShowInTaskBar Write SetShowInTaskBar Default True;
    property Icon: TImageFileName Read fIcon Write SetIcon;
    property ShowCaptionBar: BooLean Read fShowCaptionBar Write SetShowCaptionBar Default True;
  end;

implementation

{ TWindowConfig }

Constructor TWindowConfig.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  fShowInTaskBar:= True;
  fIcon:= '';
  fShowCaptionBar:= True;
  if not (AOwner is TForm) then
    Raise Exception.Create('Owner is not TForm');
  Window:= TForm(AOwner);
end;

Destructor TWindowConfig.Destroy;
begin
  {
  if fIcon <> '' then
  begin
    DestroyIcon(SendMessage(Window.Handle, WM_GETICON, ICON_SMALL, 0));
    DestroyIcon(SendMessage(Window.Handle, WM_SETICON, ICON_SMALL, 0));
    PostMessage(Window.Handle, WM_SETICON, ICON_SMALL, 0);
    PostMessage(Window.Handle, WM_SETICON, ICON_BIG, 0);
  end;
  }
  Inherited Destroy;
end;

procedure TWindowConfig.SetIcon(const Value: TImageFileName);

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
    Icon:= LoadImage(HInstance,pChar(fIcon),IMAGE_ICON,GetSystemMetrics(SM_CXSMICON),GetSystemMetrics(SM_CYSMICON),LR_LOADFROMFILE);
    PostMessage(Window.Handle, WM_SETICON, ICON_SMALL, Icon);
    Icon:= LoadImage(HInstance,pChar(fIcon),IMAGE_ICON,GetSystemMetrics(SM_CXICON),GetSystemMetrics(SM_CYICON),LR_LOADFROMFILE);
    PostMessage(Window.Handle, WM_SETICON, ICON_BIG, Icon);
  end;

begin
  if fIcon <> Value then
  begin
    SetZeroIcon(fIcon <> '');
    fIcon:= Value;
    if FileExists(fIcon) then
      SetNewIcon;
  end;
end;

procedure TWindowConfig.SetShowCaptionBar(const Value: BooLean);
begin
  if (fShowCaptionBar <> Value) then
  begin
    fShowCaptionBar:= Value;
    if CheckWin32Version(6,0) and not (csDesigning in ComponentState) then
    begin
      if fShowCaptionBar then
        SetWindowThemeNonClientAttributes(Window.Handle, WTNCA_VALIDBITS, 0)
      else
        SetWindowThemeNonClientAttributes(Window.Handle, WTNCA_VALIDBITS, WTNCA_VALIDBITS);
    end;
  end;
end;

procedure TWindowConfig.SetShowInTaskBar(const Value: BooLean);
begin
  if fShowInTaskBar <> Value then
  begin
    fShowInTaskBar:= Value;
    if not (csDesigning in ComponentState) then
    begin
      if fShowInTaskBar then
        SetWindowLong(Window.Handle,GWL_EXSTYLE,GetWindowLong(Window.Handle,GWL_EXSTYLE) or WS_EX_APPWINDOW)
      else
        SetWindowLong(Window.Handle,GWL_EXSTYLE,GetWindowLong(Window.Handle,GWL_EXSTYLE) and not WS_EX_APPWINDOW);
    end;
  end;
end;

end.
