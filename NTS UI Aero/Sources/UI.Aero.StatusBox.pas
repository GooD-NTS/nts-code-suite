{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.StatusBox;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.UxTheme,
  Winapi.GDIPOBJ,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Themes,
  {$ELSE}
  Windows, Messages, SysUtils, Classes, Controls, Graphics, Winapi.GDIPOBJ,
  Themes, UxTheme,
  {$ENDIF}
  UI.Aero.Core.CustomControl,
  UI.Aero.Globals,
  UI.Aero.Core;

type
  TAeroBaseStatusBox = class(TCustomAeroControl)
    public class var BandImageLeft: String;
    public class var BandImageCenter: String;
    public class var BandImageRight: String;
    public class var BandImageBreak: String;
    public class var BandImageLight: String;
  public
    class var Usage: Integer;
    class var fImageLeft: TBitmap;
    class var fImageRight: TBitmap;
    class var fImageCenter: TBitmap;
    class var fImageBreak: TBitmap;
    class var fImageLight: TBitmap;
    class constructor Create;
  private
    function GetTextFormat: DWORD;
  protected
    fBreakLeft: boolean;
    fBreakRight: boolean;
    fLight: boolean;
    FChromeLess: Boolean;
    function GetTextSize: TSize; virtual;
    function GetRenderState: TRenderConfig; OverRide;
    procedure ClassicRender(const ACanvas: TCanvas); OverRide;
    procedure ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig); OverRide;
    procedure RenderCompositeImage(const PaintDC: hDC); virtual;
    procedure RenderImage(const PaintDC: hDC); virtual;
    function GetThemeClassName: PWideChar; override;
    procedure SetBreak(const Index: Integer; const Value: boolean);
    procedure SetChromeLess(const Value: boolean);
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure PostRender(const Surface: TCanvas; const RConfig: TRenderConfig); override;
  public
    constructor Create(AOwner: TComponent); OverRide;
    destructor Destroy; OverRide;
  end;

  TAeroStatusBox = class(TAeroBaseStatusBox)
  published
    property BreakLeft: boolean index 0 Read fBreakLeft Write SetBreak default False;
    property BreakRight: boolean index 1 Read fBreakRight Write SetBreak default False;
    property Light: boolean index 2 Read fLight Write SetBreak default False;
    property Height default 20;
    property AutoSize Default True;
    property DragWindow Default True;
    property Caption;
    property ChromeLess: boolean read FChromeLess Write SetChromeLess default False;
  end;

  TAeroStatusButton = class(TAeroStatusBox)
  private
    fButtonState: TAeroButtonState;
    procedure UpDateButtonState;
    function GetButtonRect: TRect;
  protected
    procedure WndProc(var Message: TMessage); override;
    function GetTextSize: TSize; override;
    function GetThemeClassName: PWideChar; override;
    procedure ClassicRender(const ACanvas: TCanvas); OverRide;
    procedure ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig); OverRide;
  public
    Constructor Create(AOwner: TComponent); OverRide;
  published
    property DragWindow Default False;
  end;

implementation

uses
  System.Types,
  UI.Aero.Core.Images;

{ TAeroBaseStatusBoxBand }

class constructor TAeroBaseStatusBox.Create;
begin
  Usage:= 0;
  if Assigned(RegisterComponentsProc) then
  begin
    TAeroBaseStatusBox.BandImageLeft:= GetEnvironmentVariable('NTS_LIB_ROOT')+'\NTS UI Aero\Resources\Images\band-left.png';
    TAeroBaseStatusBox.BandImageCenter:= GetEnvironmentVariable('NTS_LIB_ROOT')+'\NTS UI Aero\Resources\Images\band-center.png';
    TAeroBaseStatusBox.BandImageRight:= GetEnvironmentVariable('NTS_LIB_ROOT')+'\NTS UI Aero\Resources\Images\band-right.png';
    TAeroBaseStatusBox.BandImageBreak:= GetEnvironmentVariable('NTS_LIB_ROOT')+'\NTS UI Aero\Resources\Images\band-break.png';
    TAeroBaseStatusBox.BandImageLight:= GetEnvironmentVariable('NTS_LIB_ROOT')+'\NTS UI Aero\Resources\Images\band-light.png';
  end
  else
  begin
    TAeroBaseStatusBox.BandImageLeft:= '???ERROR_PATH***';
    TAeroBaseStatusBox.BandImageCenter:= '???ERROR_PATH***';
    TAeroBaseStatusBox.BandImageRight:= '???ERROR_PATH***';
    TAeroBaseStatusBox.BandImageBreak:= '???ERROR_PATH***';
    TAeroBaseStatusBox.BandImageLight:= '???ERROR_PATH***';
  end;
end;

constructor TAeroBaseStatusBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  inc(Usage);
  FChromeLess := False;
  ControlStyle:= ControlStyle+[csAcceptsControls];
  if TAeroBaseStatusBox.Usage = 1 then
  begin
    TAeroBaseStatusBox.fImageLeft:= AeroPicture.LoadImage(TAeroBaseStatusBox.BandImageLeft);
    TAeroBaseStatusBox.fImageRight:= AeroPicture.LoadImage(TAeroBaseStatusBox.BandImageRight);
    TAeroBaseStatusBox.fImageCenter:= AeroPicture.LoadImage(TAeroBaseStatusBox.BandImageCenter);
    TAeroBaseStatusBox.fImageBreak:= AeroPicture.LoadImage(TAeroBaseStatusBox.BandImageBreak);
    TAeroBaseStatusBox.fImageLight:= AeroPicture.LoadImage(TAeroBaseStatusBox.BandImageLight);
  end;
  fBreakLeft:= False;
  fBreakRight:= False;
  fLight:= False;
  Height:= 20;
  AutoSize:= True;
  DragWindow:= True;
end;

destructor TAeroBaseStatusBox.Destroy;
begin
  dec(Usage);
  if TAeroBaseStatusBox.Usage = 0 then
  begin
    TAeroBaseStatusBox.fImageLeft.Free;
    TAeroBaseStatusBox.fImageRight.Free;
    TAeroBaseStatusBox.fImageCenter.Free;
    TAeroBaseStatusBox.fImageBreak.Free;
    TAeroBaseStatusBox.fImageLight.Free;
  end;
  inherited Destroy();
end;

function TAeroBaseStatusBox.GetRenderState: TRenderConfig;
begin
  Result:= [rsBuffer];
end;

function TAeroBaseStatusBox.GetTextFormat: DWORD;
begin
  Result:= DT_SINGLELINE OR DT_VCenter OR DT_Center;
end;

function TAeroBaseStatusBox.GetTextSize: TSize;
begin
  if Assigned(Parent) then
  begin
    Canvas.Font:= Self.Font;
    Result:= Canvas.TextExtent(Caption);
    Result.cx:= Result.cx+10;
  end
  else
  begin
    Result.cx:= ClientWidth;
    Result.cy:= ClientHeight;
  end;
  Result.cy:= 20;
end;

function TAeroBaseStatusBox.GetThemeClassName: PWideChar;
begin
  Result:= VSCLASS_WINDOW;
end;

procedure TAeroBaseStatusBox.PostRender(const Surface: TCanvas; const RConfig: TRenderConfig);
begin

end;

function TAeroBaseStatusBox.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result:= True;
  with GetTextSize do
  if IsRunTime or (cx > 0) and (cy > 0) then
  begin
    if Align in [alNone, alLeft, alRight] then
      NewWidth:= cx;
    if Align in [alNone, alTop, alBottom] then
      NewHeight := cy;
  end;
end;

procedure TAeroBaseStatusBox.ClassicRender(const ACanvas: TCanvas);
begin
  RenderImage(ACanvas.Handle);
  AeroCore.RenderText(ACanvas.Handle,Self.Font,GetTextFormat,GetClientRect,Caption);
end;

procedure TAeroBaseStatusBox.ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig);
begin
  if AeroCore.CompositionActive then
    RenderCompositeImage(PaintDC)
  else
    RenderImage(PaintDC);
  AeroCore.RenderText(PaintDC,ThemeData,1,1,Self.Font,GetTextFormat,GetClientRect,Caption,False);
end;

procedure TAeroBaseStatusBox.RenderImage(const PaintDC: hDC);
var
  cRect: TRect;
begin
  cRect:= Rect(5,0,Self.Width-10,20);
  if fBreakLeft then
  begin
    cRect.Left:= 0;
    cRect.Right:= cRect.Right+5;
  end;
  //else
  //  AeroPicture.Draw(PaintDC,TAeroBaseStatusBox.fImageLeft,Point(0,0), TSize(Point(5,20)) );
  if fBreakRight then
  begin
    cRect.Right:= cRect.Right+5;
    AeroPicture.Draw(PaintDC,TAeroBaseStatusBox.fImageBreak,Point(Self.Width-2,0), TSize(Point(2,20)) );
  end;
  //else
  //  AeroPicture.Draw(PaintDC,TAeroBaseStatusBox.fImageRight,Point(Self.Width-5,0), TSize(Point(5,20)) );

  if not FChromeLess and fLight then
    AeroPicture.StretchDraw(PaintDC,TAeroBaseStatusBox.fImageLight, cRect);

  //AeroPicture.StretchDraw(PaintDC,TAeroBaseStatusBox.fImageCenter, cRect );
end;

procedure TAeroBaseStatusBox.RenderCompositeImage(const PaintDC: hDC);
var
  cRect: TRect;
begin
  cRect:= Rect(5,0,Self.Width-10,20);
  if fBreakLeft then
  begin
    cRect.Left:= 0;
    cRect.Right:= cRect.Right+5;
  end
  else
  begin
    if not FChromeLess then
      AeroPicture.Draw(PaintDC,TAeroBaseStatusBox.fImageLeft, Point(0,0), TSize(Point(5,20)));
  end;

  if fBreakRight then
  begin
    cRect.Right:= cRect.Right+5;
    AeroPicture.Draw(PaintDC,TAeroBaseStatusBox.fImageBreak,Point(Self.Width-2,0), TSize(Point(2,20)) );
  end
  else
  begin
    if not FChromeLess then
      AeroPicture.Draw(PaintDC,TAeroBaseStatusBox.fImageRight,Point(Self.Width-5,0), TSize(Point(5,20)) );
  end;

  if not FChromeLess and fLight then
    AeroPicture.StretchDraw(PaintDC,TAeroBaseStatusBox.fImageLight, cRect );

  if not FChromeLess then
    AeroPicture.StretchDraw(PaintDC,TAeroBaseStatusBox.fImageCenter, cRect );
end;

procedure TAeroBaseStatusBox.SetBreak(const Index: Integer; const Value: boolean);
begin
  case Index of
    0: fBreakLeft:= Value;
    1: fBreakRight:= Value;
    2: fLight:= Value;
  end;
  Self.Invalidate;
end;

procedure TAeroBaseStatusBox.SetChromeLess(const Value: boolean);
begin
  if FChromeLess <> Value then
  begin
    FChromeLess := Value;
    Invalidate;
  end;
end;

{ TAeroStatusButton }

Constructor TAeroStatusButton.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  DragWindow:= False;
end;

function TAeroStatusButton.GetButtonRect: TRect;
begin
  Result.Top:= 1;
  Result.Bottom:= Height-1;
  Result.Left:= 7;
  Result.Right:= Width-7;
end;

function TAeroStatusButton.GetTextSize: TSize;
begin
  if Assigned(Parent) then
  begin
    Canvas.Font:= Self.Font;
    Result:= Canvas.TextExtent(Caption);
    Result.cx:= Result.cx+20;
  end
  else
  begin
    Result.cx:= ClientWidth;
    Result.cy:= ClientHeight;
  end;
  Result.cy:= 20;
end;

function TAeroStatusButton.GetThemeClassName: PWideChar;
begin
  Result:= VSCLASS_TOOLBAR;
end;

procedure TAeroStatusButton.UpDateButtonState;
var
  TempValue: TAeroButtonState;
begin
  TempValue:= fButtonState;
  if Enabled then
  begin
    if MouseOnControl then
    begin
      if MouseLeftDown then
        fButtonState:= bsDown
      else
        fButtonState:= bsHightLight;
    end
    else
    if Focused then
      fButtonState:= bsFocused
    else
      fButtonState:= bsNormal;
  end
  else
    fButtonState:= bsDisabled;
  if TempValue <> fButtonState then
    Invalidate;
end;

procedure TAeroStatusButton.WndProc(var Message: TMessage);
begin
  Inherited WndProc(Message);
  case Message.Msg of
    CM_MOUSEENTER, CM_MOUSELEAVE, CM_ENABLEDCHANGED,
    WM_LBUTTONDOWN, WM_LBUTTONUP: UpDateButtonState;
  end;
end;


procedure TAeroStatusButton.ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig);
var
  iState: Integer;
begin
  if AeroCore.CompositionActive then
    RenderCompositeImage(PaintDC)
  else
    RenderImage(PaintDC);
  case fButtonState of
    bsNormal: iState:= 1;
    bsHightLight: iState:= 2;
    bsFocused: iState:= 2;
    bsDown: iState:= 3;
    bsDisabled: iState:= 4;
  else
    iState:= 1;
  end;
  DrawThemeBackground(ThemeData, PaintDC, 1, iState, GetButtonRect, nil);
  AeroCore.RenderText(PaintDC,ThemeData,1,1,Self.Font,GetTextFormat,GetClientRect,Caption,False);
end;

procedure TAeroStatusButton.ClassicRender(const ACanvas: TCanvas);
begin
  RenderImage(ACanvas.Handle);
  AeroCore.RenderText(ACanvas.Handle,Self.Font,GetTextFormat,GetClientRect,Caption);
end;


end.
