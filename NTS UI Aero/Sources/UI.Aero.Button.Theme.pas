{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Button.Theme;

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
  Vcl.Graphics,
  Vcl.Buttons,
  {$ELSE}
  SysUtils, Classes, Windows, Graphics, Winapi.GDIPOBJ, UxTheme, Buttons,
  {$ENDIF}
  UI.Aero.Globals,
  UI.Aero.Core,
  UI.Aero.Button.Custom,
  UI.Aero.Core.Images;

type
  TThemButtonState = class(TPersistent)
  private
    fStateDisabled: Integer;
    fPartDown: Integer;
    fStateHightLight: Integer;
    fPartNormal: Integer;
    fPartDisabled: Integer;
    fStateFocused: Integer;
    fPartHightLight: Integer;
    FOnChange: TNotifyEvent;
    fStateDown: Integer;
    fStateNormal: Integer;
    fPartFocused: Integer;
    procedure SetThemePart(const Index, Value: Integer);
    procedure SetThemeState(const Index, Value: Integer);
  Protected
    Procedure Change; virtual;
  Public
    Constructor Create; virtual;
    Destructor Destroy; override;
    Property OnChange: TNotifyEvent read FOnChange write FOnChange;
  Published
    Property PartNormal    : Integer Index 0 Read fPartNormal     Write SetThemePart Default 0;
    Property PartHightLight: Integer Index 1 Read fPartHightLight Write SetThemePart Default 0;
    Property PartFocused   : Integer Index 2 Read fPartFocused    Write SetThemePart Default 0;
    Property PartDown      : Integer Index 3 Read fPartDown       Write SetThemePart Default 0;
    Property PartDisabled  : Integer Index 4 Read fPartDisabled   Write SetThemePart Default 0;

    Property StateNormal    : Integer Index 0 Read fStateNormal     Write SetThemeState Default 0;
    Property StateHightLight: Integer Index 1 Read fStateHightLight Write SetThemeState Default 0;
    Property StateFocused   : Integer Index 2 Read fStateFocused    Write SetThemeState Default 0;
    Property StateDown      : Integer Index 3 Read fStateDown       Write SetThemeState Default 0;
    Property StateDisabled  : Integer Index 4 Read fStateDisabled   Write SetThemeState Default 0;
  end;

  TAeroThemeButtonEvent = procedure(const Sender: TAeroCustomButton; PartID, StateID: Integer; Surface: TCanvas) of object;
  TAeroThemeButtonGetSizeEvent = procedure(Sender: TAeroCustomButton; PartID, StateID: Integer;var ASize: TSize) of object;


  TAeroBaseThemeButton = class(TAeroCustomButton)
  private
    fThemeClassName: String;
    fState: TThemButtonState;
    fThemePaint: TAeroThemeButtonEvent;
    fThemeSize: Boolean;
    fOnThemeSize: TAeroThemeButtonGetSizeEvent;
    procedure SetThemeClassName(const Value: String);
    procedure SetState(const Value: TThemButtonState);
    procedure SetThemeSize(const Value: Boolean);
  Protected
    function GetThemeClassName: PWideChar; OverRide;
    procedure ImageChange(Sender: TObject);
    function GetRenderState: TARenderConfig; override;
    procedure RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer); override;
    procedure ClassicRender(const ACanvas: TCanvas; const DrawState: Integer); override;
    procedure PostRender(const Surface: TCanvas;const RConfig: TARenderConfig; const DrawState: Integer); override;
    function GetElementSize(DrawState: Integer): TSize;
    procedure DoClassicThemePaint(const Sender: TAeroCustomButton; PartID, StateID: Integer; Surface: TCanvas); virtual;
  Public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
  Published
    property ThemeClassName: String Read fThemeClassName Write SetThemeClassName;
    property State: TThemButtonState Read fState Write SetState;
    property OnThemePaint: TAeroThemeButtonEvent Read fThemePaint Write fThemePaint;
    property ThemeSize: Boolean Read fThemeSize Write SetThemeSize Default false;
    property OnThemeSize: TAeroThemeButtonGetSizeEvent Read fOnThemeSize Write fOnThemeSize;
  end;

  TAeroThemeButton = class(TAeroBaseThemeButton)
  private
    FLayout: TButtonLayout;
    fTextGlow: BooLean;
    fImage: TAeroButtonImage;
    fDrawCaption: BooLean;
    procedure SetDrawCaption(const Value: BooLean);
    procedure SetLayout(const Value: TButtonLayout);
    procedure SetNewImage(const Value: TAeroButtonImage);
    procedure SetTextGlow(const Value: BooLean);
  Protected
    procedure RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer); override;
    procedure ClassicRender(const ACanvas: TCanvas; const DrawState: Integer); override;
    function GetCaptionRect: TRect; virtual;
    function GetTextFormat: Cardinal; virtual;
    procedure DrawButtonImage(const PaintDC: hDC; const DrawState: TAeroButtonState);
  Public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
  Published
    Property Caption;
    property Layout: TButtonLayout read FLayout write SetLayout default blGlyphLeft;
    Property Image: TAeroButtonImage Read fImage Write SetNewImage;
    Property DrawCaption: BooLean Read fDrawCaption Write SetDrawCaption default True;
    Property TextGlow: BooLean Read fTextGlow Write SetTextGlow default False;  
  end;
  
  
implementation

{ TThemButtonState }

Constructor TThemButtonState.Create;
begin
 fPartNormal    := 0;
 fPartHightLight:= 0;
 fPartFocused   := 0;
 fPartDown      := 0;
 fPartDisabled  := 0;

 fStateNormal    := 0;
 fStateHightLight:= 0;
 fStateFocused   := 0;
 fStateDown      := 0;
 fStateDisabled  := 0;
end;

Destructor TThemButtonState.Destroy;
begin

 Inherited Destroy;
end;

procedure TThemButtonState.Change;
begin
 if Assigned(FOnChange) then
  FOnChange(Self);
end;

procedure TThemButtonState.SetThemePart(const Index, Value: Integer);
begin
 case Index of
   0: fPartNormal    := Value;
   1: fPartHightLight:= Value;
   2: fPartFocused   := Value;
   3: fPartDown      := Value;
   4: fPartDisabled  := Value;
 end;
 Change;
end;

procedure TThemButtonState.SetThemeState(const Index, Value: Integer);
begin
 case Index of
   0: fStateNormal    := Value;
   1: fStateHightLight:= Value;
   2: fStateFocused   := Value;
   3: fStateDown      := Value;
   4: fStateDisabled  := Value;
 end;
 Change;
end;

{ TAeroThemeButton }

Constructor TAeroBaseThemeButton.Create(AOwner: TComponent);
begin
 fThemeClassName:= '';
 Inherited Create(AOwner);
 fState:= TThemButtonState.Create;
 fState.OnChange:= ImageChange;
 fThemePaint:= nil;
 fOnThemeSize:= nil;
 fThemeSize:= False;
end;

Destructor TAeroBaseThemeButton.Destroy;
begin
 fState.Free;
 Inherited Destroy;
end;

function TAeroBaseThemeButton.GetElementSize(DrawState: Integer): TSize;
var
 PartID, StateID: Integer;
begin
 PartID:= 0;
 StateID:= 0;
 Result.cx:= 0;
 Result.cy:= 0;
 case TAEROButtonState(DrawState) of
   UI.Aero.Globals.bsNormal:
    begin
     PartID:= State.PartNormal;
     StateID:= State.StateNormal;
    end;
   UI.Aero.Globals.bsHightLight:
    begin
     PartID:= State.PartHightLight;
     StateID:= State.StateHightLight;
    end;
   UI.Aero.Globals.bsFocused:
    begin
     PartID:= State.PartFocused;
     StateID:= State.StateFocused;
    end;
   UI.Aero.Globals.bsDown:
    begin
     PartID:= State.PartDown;
     StateID:= State.StateDown;
    end;
   UI.Aero.Globals.bsDisabled:
    begin
     PartID:= State.PartDisabled;
     StateID:= State.StateDisabled;
    end;
 end;
 if ThemeData <> 0 then
  begin
   GetThemePartSize(ThemeData,Canvas.Handle,PartID,StateID,nil,TS_TRUE,Result)
  end
 else
  begin
   if Assigned(fOnThemeSize) then
    fOnThemeSize(Self,PartID,StateID,Result);
  end;
end;

function TAeroBaseThemeButton.GetRenderState: TARenderConfig;
begin
 Result:= [];
end;

function TAeroBaseThemeButton.GetThemeClassName: PWideChar;
begin
 Result:= pWChar(fThemeClassName);
end;

procedure TAeroBaseThemeButton.ImageChange(Sender: TObject);
begin
 Invalidate;
end;

procedure TAeroBaseThemeButton.PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer);
begin

end;

procedure TAeroBaseThemeButton.RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer);
var
 clRect: TRect;
 PartID,
 StateID: Integer;
begin
 if ThemeData <> 0 then
  begin
   PartID:= 0;
   StateID:= 0;
   case TAEROButtonState(DrawState) of
     UI.Aero.Globals.bsNormal:
      begin
       PartID:= State.PartNormal;
       StateID:= State.StateNormal;
      end;
     UI.Aero.Globals.bsHightLight:
      begin
       PartID:= State.PartHightLight;
       StateID:= State.StateHightLight;
      end;
     UI.Aero.Globals.bsFocused:
      begin
       PartID:= State.PartFocused;
       StateID:= State.StateFocused;
      end;
     UI.Aero.Globals.bsDown:
      begin
       PartID:= State.PartDown;
       StateID:= State.StateDown;
      end;
     UI.Aero.Globals.bsDisabled:
      begin
       PartID:= State.PartDisabled;
       StateID:= State.StateDisabled;
      end;                     
   end;
//
   if fThemeSize then
    with GetElementSize(DrawState) do
     begin
      clRect.Left:= 0;
      clRect.Top:= 0;
      clRect.Right:= cx;
      clRect.Bottom:= cy;
     end
   else
    clRect:= GetClientRect;
//
   DrawThemeBackground(ThemeData,PaintDC,PartID,StateID,clRect,@clRect);
  end
 else
  if Assigned(fThemePaint) then
   begin
    PartID:= 0;
    StateID:= 0;
    case TAEROButtonState(DrawState) of
      UI.Aero.Globals.bsNormal:
       begin
        PartID:= State.PartNormal;
        StateID:= State.StateNormal;
       end;
      UI.Aero.Globals.bsHightLight:
       begin
        PartID:= State.PartHightLight;
        StateID:= State.StateHightLight;
       end;
      UI.Aero.Globals.bsFocused:
       begin
        PartID:= State.PartFocused;
        StateID:= State.StateFocused;
       end;
      UI.Aero.Globals.bsDown:
       begin
        PartID:= State.PartDown;
        StateID:= State.StateDown;
       end;
      UI.Aero.Globals.bsDisabled:
       begin
        PartID:= State.PartDisabled;
        StateID:= State.StateDisabled;
       end;
    end;
    fThemePaint(Self,PartID,StateID,Canvas);
   end;
end;  

procedure TAeroBaseThemeButton.ClassicRender(const ACanvas: TCanvas; const DrawState: Integer);
var
 PartID,
 StateID: Integer;
begin
 PartID:= 0;
 StateID:= 0;
 case TAEROButtonState(DrawState) of
   UI.Aero.Globals.bsNormal:
    begin
     PartID:= State.PartNormal;
     StateID:= State.StateNormal;
    end;
   UI.Aero.Globals.bsHightLight:
    begin
     PartID:= State.PartHightLight;
     StateID:= State.StateHightLight;
    end;
   UI.Aero.Globals.bsFocused:
    begin
     PartID:= State.PartFocused;
     StateID:= State.StateFocused;
    end;
   UI.Aero.Globals.bsDown:
    begin
     PartID:= State.PartDown;
     StateID:= State.StateDown;
    end;
   UI.Aero.Globals.bsDisabled:
    begin
     PartID:= State.PartDisabled;
     StateID:= State.StateDisabled;
    end;
 end;
 DoClassicThemePaint(Self,PartID,StateID,ACanvas);
end;

procedure TAeroBaseThemeButton.DoClassicThemePaint(const Sender: TAeroCustomButton; PartID, StateID: Integer; Surface: TCanvas);
begin
 if Assigned(fThemePaint) then
  fThemePaint(Sender,PartID,StateID,Surface);
end;

procedure TAeroBaseThemeButton.SetState(const Value: TThemButtonState);
begin
 fState.Assign(Value);
end;

procedure TAeroBaseThemeButton.SetThemeClassName(const Value: String);
begin
 if fThemeClassName <> Value then
  begin
   fThemeClassName:= Value;
   CurrentThemeChanged;
   Invalidate;   
  end;
end;

procedure TAeroBaseThemeButton.SetThemeSize(const Value: Boolean);
begin
 if fThemeSize <> Value then
  begin
   fThemeSize:= Value;
   Invalidate;
  end;
end;

{ TAeroThemeButton }

Constructor TAeroThemeButton.Create(AOwner: TComponent);
begin
 Inherited Create(AOwner);
 FLayout:= blGlyphLeft;
 fDrawCaption:= True;
 fTextGlow:= False;
 fImage:= TAeroButtonImage.Create;
 fImage.OnChange:= ImageChange;
end;

Destructor TAeroThemeButton.Destroy;
begin
 fImage.Free;
 Inherited Destroy;
end;

procedure TAeroThemeButton.DrawButtonImage(const PaintDC: hDC; const DrawState: TAeroButtonState);
var
 ImgPos: TPoint;
begin
 ImgPos:= Point(0,0);
 if fDrawCaption then
  case FLayout of
    blGlyphLeft:
     begin
      ImgPos.X:= 4;
      ImgPos.Y:= (Self.Height div 2)-(Image.PartHeight div 2);
     end;
    blGlyphRight:
     begin
      ImgPos.X:= Self.Width-(Image.PartWidth+4);
      ImgPos.Y:= (Self.Height div 2)-(Image.PartHeight div 2);
     end;
    blGlyphTop:
     begin
      ImgPos.X:= (Self.Width div 2)-(Image.PartWidth div 2);
      ImgPos.Y:= 4;
     end;
    blGlyphBottom:
     begin
      ImgPos.X:= (Self.Width div 2)-(Image.PartWidth div 2);
      ImgPos.Y:= Self.Height-(Image.PartHeight+4);
     end;
  end
 else
  begin
   ImgPos.X:= (Self.Width div 2)-(Image.PartWidth div 2);
   ImgPos.Y:= (Self.Height div 2)-(Image.PartHeight div 2);
  end;
 case DrawState of
   UI.Aero.Globals.bsNormal    : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,Image.PartSize,Image.PartNormal,Image.Orientation);
   UI.Aero.Globals.bsHightLight: AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,Image.PartSize,Image.PartHightLight,Image.Orientation);
   UI.Aero.Globals.bsFocused   : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,Image.PartSize,Image.PartNormal,Image.Orientation);
   UI.Aero.Globals.bsDown      : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,Image.PartSize,Image.PartDown,Image.Orientation);
   UI.Aero.Globals.bsDisabled  : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,Image.PartSize,Image.PartDisabled,Image.Orientation);
 end;
end;

function TAeroThemeButton.GetCaptionRect: TRect;
begin
 if Assigned(Image.Data) then
  case FLayout of
    blGlyphLeft:
     begin
      Result.Left:= 6+Image.PartWidth;
      Result.Top:= 0;
      Result.Right:= Self.Width-4;
      Result.Bottom:= Self.Height;
     end;
    blGlyphRight:
     begin
      Result.Left:= 4;
      Result.Top:= 0;
      Result.Right:= Self.Width-(Image.PartWidth+6);
      Result.Bottom:= Self.Height;
     end;
    blGlyphTop:
     begin
      Result.Left:= 4;
      Result.Right:= Self.Width-4;
      Result.Top:= Image.PartHeight+6;
      Result.Bottom:= Self.Height;
     end;
    blGlyphBottom:
     begin
      Result.Left:= 4;
      Result.Right:= Self.Width-4;
      Result.Top:= 0;
      Result.Bottom:= Self.Height-(Image.PartHeight+6)
     end;
  end
 else
  Result:= GetClientRect;
end;

function TAeroThemeButton.GetTextFormat: Cardinal;
begin
 Result:= (DT_CENTER or DT_VCENTER or DT_SINGLELINE);
end;

procedure TAeroThemeButton.SetDrawCaption(const Value: BooLean);
begin
 if fDrawCaption <> Value then
  begin
   fDrawCaption:= Value;
   Invalidate;
  end;
end;

procedure TAeroThemeButton.SetLayout(const Value: TButtonLayout);
begin
 if FLayout <> Value then
  begin
   FLayout:= Value;
   Invalidate;
  end;
end;

procedure TAeroThemeButton.SetNewImage(const Value: TAeroButtonImage);
begin
 fImage.Assign(Value);
end;

procedure TAeroThemeButton.SetTextGlow(const Value: BooLean);
begin
 if fTextGlow <> Value then
  begin
   fTextGlow:= Value;
   Invalidate;
  end;
end;

procedure TAeroThemeButton.ClassicRender(const ACanvas: TCanvas; const DrawState: Integer);
var
 clRect: TRect;
begin
 Inherited ClassicRender(ACanvas,DrawState);
 if Assigned(Image.Data) then
  DrawButtonImage(ACanvas.Handle,ButtonState);
 if fDrawCaption then
  begin
   clRect:= GetCaptionRect;
   AeroCore.RenderText(ACanvas.Handle,Self.Font,GetTextFormat,clRect,Caption);
   if Focused then ACanvas.DrawFocusRect(clRect);
  end;
end;

procedure TAeroThemeButton.RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer);
var
 PartID, StateID: Integer;
begin
 Inherited RenderState(PaintDC,Surface,RConfig,DrawState);
 if Assigned(Image.Data) then
  DrawButtonImage(PaintDC,ButtonState);
 if fDrawCaption then
  begin
   PartID:= 0;
   StateID:= 0;
   case TAEROButtonState(DrawState) of
     UI.Aero.Globals.bsNormal:
      begin
       PartID:= State.PartNormal;
       StateID:= State.StateNormal;
      end;
     UI.Aero.Globals.bsHightLight:
      begin
       PartID:= State.PartHightLight;
       StateID:= State.StateHightLight;
      end;
     UI.Aero.Globals.bsFocused:
      begin
       PartID:= State.PartFocused;
       StateID:= State.StateFocused;
      end;
     UI.Aero.Globals.bsDown:
      begin
       PartID:= State.PartDown;
       StateID:= State.StateDown;
      end;
     UI.Aero.Globals.bsDisabled:
      begin
       PartID:= State.PartDisabled;
       StateID:= State.StateDisabled;
      end;                     
   end;
    AeroCore.RenderText(PaintDC,ThemeData,PartID,StateID,Self.Font,GetTextFormat,GetCaptionRect,Caption,fTextGlow);
  end;
end;

end.
