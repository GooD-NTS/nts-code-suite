{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.PageManager;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils,
  System.Classes,

  Winapi.Windows,
  Winapi.Messages,
  Winapi.GDIPOBJ,
  Winapi.UxTheme,

  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Menus,
  {$ELSE}
  SysUtils, Windows, Messages, Classes, Controls, Graphics, UxTheme,
  Winapi.GDIPOBJ, Menus,
  {$ENDIF}
  NTS.Code.Helpers,
  UI.Aero.Core.CustomControl,
  UI.Aero.Core.Images,
  UI.Aero.Core.BaseControl,
  UI.Aero.Globals,
  UI.Aero.Core;

type
  TAeroPageManager = Class;

  TButtonClickEvent = procedure(Sender: TAeroPageManager;ButtonIndex: Integer) of object;
  TPageChangeEvent = procedure(Sender: TAeroPageManager;NewPage,OldPage: Integer) of object;

  TAeroBasePageManager = Class(TCustomAeroControl)
  public class var ImageFile_Left: String;
  public class var ImageFile_Right: String;
  private class constructor Create;
  Private
    FPages: TStrings;
    fPage: Integer;
    fPageChange: TPageChangeEvent;
    procedure SetPage(const Value: Integer);
    procedure SetPages(const Value: TStrings);
  Protected
    ImageLeft,
    ImageRight: TBitmap;
    function GetRenderState: TRenderConfig; OverRide;
    function GetThemeClassName: PWideChar; OverRide;
  Public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
    procedure NextPage;
    procedure PreviousPage;
  Published
    property Pages: TStrings Read FPages write SetPages;
    property CurrentPage: Integer Read fPage Write SetPage Default -1;
    property OnPageChange: TPageChangeEvent Read fPageChange Write fPageChange;
  End;

  TAeroPageManager = Class(TAeroBasePageManager)
  const
    ugButtonNormal = 0;
    ugButtonHightLight = 1;
    ugButtonDown = 2;
    ugButtonDisabled = 3;
    ugTextFormat = (DT_SINGLELINE or DT_CENTER or DT_VCENTER);
  Private
    HightLightButton,
    DownButton: Integer;
    fButtonClick: TButtonClickEvent;
    fAutoPopupMenu: BooLean;
    PopMenu: TPopupMenu;
    function GetButtonState(Index: Integer): Integer;
    procedure DoButtonClick(Index: Integer);
    procedure CreatePopMenu;
    procedure MenuClick(Sender: TObject);
  Protected
    procedure RenderBody(const PaintDC: hDC);
    procedure ClassicRender(const ACanvas: TCanvas); OverRide;
    procedure ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig); OverRide;
    procedure Click; OverRide;
    procedure DblClick; override;
    procedure WndProc(var Message: TMessage); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); OverRide;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure PostRender(const Surface: TCanvas; const RConfig: TRenderConfig); override;
  Public
    Constructor Create(AOwner: TComponent); override;
  Published
    property TabStop Default True;
    property AutoPopupMenu: BooLean Read fAutoPopupMenu Write fAutoPopupMenu Default True;
    property OnButtonClick: TButtonClickEvent Read fButtonClick Write fButtonClick;
  End;

implementation

uses
  UI.Aero.Window, Math;

{ TAeroBasePageManager }

class constructor TAeroBasePageManager.Create;
begin
  if Assigned(RegisterComponentsProc) then
  begin
    TAeroBasePageManager.ImageFile_Left:= GetEnvironmentVariable('NTS_LIB_ROOT')+'\NTS UI Aero\Resources\Images\PagesLeft.png';
    TAeroBasePageManager.ImageFile_Right:= GetEnvironmentVariable('NTS_LIB_ROOT')+'\NTS UI Aero\Resources\Images\PagesRight.png';
  end
  else
  begin
    TAeroBasePageManager.ImageFile_Left:= '???ERROR_PATH***';
    TAeroBasePageManager.ImageFile_Right:= '???ERROR_PATH***';
  end;
end;

Constructor TAeroBasePageManager.Create(AOwner: TComponent);
begin
 Inherited Create(AOwner);
 Height:= 23;
 Width:= 100;
 with Constraints do
  begin
   MinHeight:= 23;
   MaxHeight:= 23;
   MinWidth:= 50;
  end;
//
 ImageLeft := AeroPicture.LoadImage(TAeroBasePageManager.ImageFile_Left);
 ImageRight:= AeroPicture.LoadImage(TAeroBasePageManager.ImageFile_Right);
//
 FPages:= TStringList.Create;
 fPage:= -1;
 fPageChange:= nil;
end;

Destructor TAeroBasePageManager.Destroy;
begin
 FPages.Free;
 if Assigned(ImageLeft) then
  ImageLeft.Free;
 if Assigned(ImageRight) then
  ImageRight.Free;
 Inherited Destroy;
end;

function TAeroBasePageManager.GetRenderState: TRenderConfig;
begin
 Result:= [rsBuffer];
end;

function TAeroBasePageManager.GetThemeClassName: PWideChar;
begin
 Result:= VSCLASS_BUTTON;
end;

procedure TAeroBasePageManager.SetPages(const Value: TStrings);
begin
 FPages.Assign(Value);
 Invalidate;
end;

procedure TAeroBasePageManager.NextPage;
begin
 SetPage(fPage+1);
end;

procedure TAeroBasePageManager.PreviousPage;
begin
 SetPage(fPage-1);
end;

procedure TAeroBasePageManager.SetPage(const Value: Integer);
begin
 if (fPage <> Value) and (InRange(Value,0,Pages.Count-1)) then
  begin
   if Assigned(fPageChange) then
    fPageChange(TAeroPageManager(Self),Value,fPage);
   fPage:= Value;
   Invalidate;
  end;
end;

{ TAeroPageManager }

Constructor TAeroPageManager.Create(AOwner: TComponent);
begin
 Inherited Create(AOwner);
 HightLightButton:= -1;
 DownButton:= -1;
 TabStop:= True;
 fButtonClick:= nil;
 fAutoPopupMenu:= True;
 PopMenu:= nil;
end;

procedure TAeroPageManager.CreatePopMenu;
var
 I: Integer;
begin
 PopMenu:= TPopupMenu.Create(Self);
 for I:=0 to Pages.Count-1 do
  PopMenu.Items.Add(NewItem(Pages[I],0,False,True,MenuClick,I,''));
{}
 PopMenu.Items[fPage].Checked:= True;
{}
 PopupMenu:= PopMenu;
end;

procedure TAeroPageManager.DoButtonClick(Index: Integer);
begin
 case Index of
   0: PreviousPage;
   1: NextPage;
 end;
 if Assigned(fButtonClick) then
  fButtonClick(Self,Index);
end;

procedure TAeroPageManager.Click;
begin
 Inherited Click;
 if (DownButton = HightLightButton) and (HightLightButton <> -1) then
  DoButtonClick(DownButton);
end;

procedure TAeroPageManager.DblClick;
begin
 Inherited DblClick;
 if HightLightButton <> 0 then
  DoButtonClick(HightLightButton);
end;

function TAeroPageManager.GetButtonState(Index: Integer): Integer;

  Procedure ButtonState(Param: Integer);
  begin
   if fPage = Param then
    Result:= ugButtonDisabled
   else
    if HightLightButton = Index then
     begin
      if DownButton = Index then
       Result:= ugButtonDown
      else
       Result:= ugButtonHightLight;
     end
    else
     Result:= ugButtonNormal;
  end;

begin
 Result:= ugButtonDisabled;
 if (Pages.Count <= 1) or (fPage = -1) or (not Self.Enabled) then
  Result:= ugButtonDisabled
 else
  case Index of
    0: ButtonState(0);
    1: ButtonState(FPages.Count-1);
  end;
end;

procedure TAeroPageManager.MenuClick(Sender: TObject);
begin
 SetPage(TMenuItem(Sender).MenuIndex);
{}
 PopMenu.Free;
end;

procedure TAeroPageManager.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if (Button = mbRight) and fAutoPopupMenu then
  CreatePopMenu;
 Inherited MouseDown(Button,Shift,X,Y);
 if Button = mbLeft then
  begin
   if Point(X,Y).InRect(Rect(2,2,19,19)) then
    begin
     DownButton:= 0;
     Invalidate;
    end
   else
    if Point(X,Y).InRect(Rect(Width-21,2,Width-2,19)) then
     begin
      DownButton:= 1;
      Invalidate;
     end
    else
     DownButton:= -1;
  end;
end;

procedure TAeroPageManager.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
 Inherited MouseMove(Shift,X,Y);
 if Pages.Count > 1 then
  begin
   if Point(X,Y).InRect(Rect(2,2,19,19)) then
    begin
     if HightLightButton <> 0 then
      begin
       HightLightButton:= 0;
       Invalidate;
      end;
    end
   else
    begin
     if Point(X,Y).InRect(Rect(Width-21,2,Width-2,19)) then
      begin
       if HightLightButton <> 1 then
        begin
         HightLightButton:= 1;
         Invalidate;
        end;
      end
     else
      if HightLightButton <> -1 then
       begin
        HightLightButton:= -1;
        Invalidate;
       end;
    end;
  end; 
end;

procedure TAeroPageManager.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 Inherited MouseUp(Button,Shift,X,Y);
 if (Button = mbLeft) and (DownButton <> -1) then
  begin
   DownButton:= -1;
   Invalidate;
  end;
end;

procedure TAeroPageManager.PostRender(const Surface: TCanvas; const RConfig: TRenderConfig);
begin

end;

procedure TAeroPageManager.RenderBody(const PaintDC: hDC);

  procedure DrawButton(Image: TBitmap;State,PosX,PosY: Integer);
  var
   PartSize: TSize;
  begin
   PartSize.cx:= 22;
   PartSize.cy:= 23;
   AeroPicture.DrawPart(PaintDC,Image.Canvas.Handle,Point(PosX,PosY),PartSize,State,ioVertical);
  end;

  procedure DrawTextBg;
  begin
   AlphaBlend(PaintDC,22,0,Width-44,23,ImageLeft.Canvas.Handle,21,0,1,23,AeroPicture.Blend);
  end;

begin
 DrawButton(ImageLeft,GetButtonState(0),0,0);
 DrawButton(ImageRight,GetButtonState(1),Width-22,0);
 DrawTextBg;
end;

procedure TAeroPageManager.ClassicRender(const ACanvas: TCanvas);
begin
 if Assigned(ImageLeft) and Assigned(ImageRight) then
  RenderBody(ACanvas.Handle);
 if (Pages.Count > 0) and (fPage <> -1) then
  AeroCore.RenderText(ACanvas.Handle,Self.Font,ugTextFormat,GetClientRect,Pages[fPage]);
end;

procedure TAeroPageManager.ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig);
begin
 if Assigned(ImageLeft) and Assigned(ImageRight) then RenderBody(PaintDC);
 if (Pages.Count > 0) and (fPage <> -1) then
  AeroCore.RenderText(PaintDC,ThemeData,1,1,Self.Font,ugTextFormat,GetClientRect,Pages[fPage],false);
end;

procedure TAeroPageManager.WndProc(var Message: TMessage);
begin
 Inherited WndProc(Message);
 case Message.Msg of
   CM_MOUSEENTER: Invalidate;
   CM_MOUSELEAVE:
    begin
     HightLightButton:= -1;
     Invalidate;
    end;
 end;
end;

end.
