{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Button.Extended;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.Classes,
  Winapi.Windows,
  Winapi.GDIPOBJ,
  Winapi.UxTheme,
  Vcl.Graphics,
  Vcl.Buttons,
  {$ELSE}
  Windows, Classes, Graphics, Buttons, Winapi.GDIPOBJ, UxTheme,
  {$ENDIF}
  UI.Aero.Button.Custom,
  UI.Aero.Button,
  UI.Aero.Core.Images,
  UI.Aero.Core.CustomControl.Animation,
  UI.Aero.Globals,
  UI.Aero.Core;

type
  TAeroButtonEx = Class(TCustomAeroButton)
  const
    TextFormat = (DT_CENTER or DT_VCENTER or DT_SINGLELINE);
  private
    FLayout: TButtonLayout;
    fImage: TAeroButtonImage;
    fDrawCaption: BooLean;
    fTextGlow: BooLean;
    procedure SetLayout(const Value: TButtonLayout);
    procedure SetNewImage(const Value: TAeroButtonImage);
    procedure SetDrawCaption(const Value: BooLean);
    procedure SetTextGlow(const Value: BooLean);
  Protected
    procedure RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer); override;
    procedure ClassicRender(const ACanvas: TCanvas; const DrawState: Integer); override;
    procedure DrawButtonImage(const PaintDC: hDC; const DrawState: TAeroButtonState);
    function GetCaptionRect: TRect;
    procedure ImageChange(Sender: TObject);
    procedure PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer); override;
  Public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
  Published
    Property Caption;
    property Layout: TButtonLayout read FLayout write SetLayout default blGlyphLeft;
    Property Image: TAeroButtonImage Read fImage Write SetNewImage;
    Property DrawCaption: BooLean Read fDrawCaption Write SetDrawCaption default True;
    Property TextGlow: BooLean Read fTextGlow Write SetTextGlow default False;
  End;

implementation

{ TAeroButtonEx }

Constructor TAeroButtonEx.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  FLayout:= blGlyphLeft;
  fDrawCaption:= True;
  fTextGlow:= False;
  fImage:= TAeroButtonImage.Create;
  fImage.OnChange:= ImageChange;
end;

Destructor TAeroButtonEx.Destroy;
begin
  fImage.Free;
  Inherited Destroy;
end;

function TAeroButtonEx.GetCaptionRect: TRect;
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

procedure TAeroButtonEx.ImageChange(Sender: TObject);
begin
  Invalidate;
end;

procedure TAeroButtonEx.PostRender(const Surface: TCanvas;const RConfig: TARenderConfig; const DrawState: Integer);
begin

end;

procedure TAeroButtonEx.SetDrawCaption(const Value: BooLean);
begin
  if fDrawCaption <> Value then
  begin
    fDrawCaption := Value;
    Invalidate;
  end;
end;

procedure TAeroButtonEx.SetLayout(const Value: TButtonLayout);
begin
  if FLayout <> Value then
  begin
    FLayout:= Value;
    Invalidate;
  end;
end;

procedure TAeroButtonEx.SetNewImage(const Value: TAeroButtonImage);
begin
  fImage.Assign(Value);
end;

procedure TAeroButtonEx.SetTextGlow(const Value: BooLean);
begin
  if fTextGlow <> Value then
  begin
    fTextGlow:= Value;
    Invalidate;
  end;
end;

procedure TAeroButtonEx.DrawButtonImage(const PaintDC: hDC; const DrawState: TAeroButtonState);
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
    bsNormal    : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,
                    Image.PartSize,Image.PartNormal,Image.Orientation);
    bsHightLight: AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,
                    Image.PartSize,Image.PartHightLight,Image.Orientation);
    bsFocused   : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,
                    Image.PartSize,Image.PartNormal,Image.Orientation);
    bsDown      : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,
                    Image.PartSize,Image.PartDown,Image.Orientation);
    bsDisabled  : AeroPicture.DrawPart(PaintDC,Image.Data.Canvas.Handle,ImgPos,
                    Image.PartSize,Image.PartDisabled,Image.Orientation);
  end;
end;

procedure TAeroButtonEx.RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer);
var
  PartID, StateID: Integer;
begin
  Inherited RenderState(PaintDC,Surface,RConfig,DrawState);
  if Assigned(Image.Data) then
    DrawButtonImage(PaintDC,ButtonState);
  if fDrawCaption then
  begin
    PartID:= BP_PUSHBUTTON;
    StateID:= PBS_NORMAL;
    case TAeroButtonState(DrawState) of
      bsNormal    : StateID:= PBS_NORMAL;
      bsHightLight: StateID:= PBS_HOT;
      bsFocused   : StateID:= PBS_DEFAULTED;
      bsDown      : StateID:= PBS_PRESSED;
      bsDisabled  : StateID:= PBS_DISABLED;
    end;
    AeroCore.RenderText(PaintDC,ThemeData,PartID,StateID,Self.Font,TextFormat,GetCaptionRect,Caption,fTextGlow);
  end; 
end;

procedure TAeroButtonEx.ClassicRender(const ACanvas: TCanvas; const DrawState: Integer);
var
  clRect: TRect;
begin
  Inherited ClassicRender(ACanvas,DrawState);
  if Assigned(Image.Data) then
    DrawButtonImage(ACanvas.Handle,ButtonState);
  if fDrawCaption then
  begin
    clRect:= GetCaptionRect;
    AeroCore.RenderText(ACanvas.Handle,Self.Font,TextFormat,clRect,Caption);
    if Focused then
      ACanvas.DrawFocusRect(clRect);
  end;
end;

end.
