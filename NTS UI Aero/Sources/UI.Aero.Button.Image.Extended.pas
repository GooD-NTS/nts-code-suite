{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Button.Image.Extended;

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
  Vcl.Themes,
  {$ELSE}
  Windows, Classes, Graphics, Winapi.GDIPOBJ, Buttons, UxTheme, Themes,
  {$ENDIF}
  UI.Aero.Core.CustomControl.Animation,
  UI.Aero.Button.Custom,
  UI.Aero.Button.Image,
  UI.Aero.Core.Images,
  UI.Aero.Globals,
  UI.Aero.Core;

type
  TAeroImageButtonEx = Class(TAeroImageButton)
  const
    TextFormat = (DT_CENTER or DT_VCENTER or DT_SINGLELINE);
  private
    fDrawCaption: BooLean;
    fTextGlow: BooLean;
    FLayout: TButtonLayout;
    fCustomImage: TAeroButtonImage;
    procedure SetDrawCaption(const Value: BooLean);
    procedure SetTextGlow(const Value: BooLean);
    procedure SetLayout(const Value: TButtonLayout);
    procedure SetNewImage(const Value: TAeroButtonImage);
  Protected
    procedure RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer); override;
    procedure ClassicRender(const ACanvas: TCanvas; const DrawState: Integer); override;
    procedure ImageCustomChange(Sender: TObject);
    function GetCaptionRect: TRect;
    procedure DrawButtonImage(const PaintDC: hDC; const DrawState: TAeroButtonState);
  Public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;  
  Published
    Property Caption;
    Property DrawCaption: BooLean Read fDrawCaption Write SetDrawCaption default False;
    Property TextGlow: BooLean Read fTextGlow Write SetTextGlow default False;
    property Layout: TButtonLayout read FLayout write SetLayout default blGlyphLeft;
    Property CustomImage: TAeroButtonImage Read fCustomImage Write SetNewImage;
  End;

implementation

{ TAeroImageButtonEx }

Constructor TAeroImageButtonEx.Create(AOwner: TComponent);
begin
 Inherited Create(AOwner);
 fDrawCaption:= False;
 fTextGlow:= False;
 FLayout:= blGlyphLeft;
 fCustomImage:= TAeroButtonImage.Create;
 fCustomImage.OnChange:= ImageCustomChange;
end;

Destructor TAeroImageButtonEx.Destroy;
begin
 fCustomImage.Free;
 Inherited Destroy;
end;         

procedure TAeroImageButtonEx.DrawButtonImage(const PaintDC: hDC; const DrawState: TAeroButtonState);
var
 ImgPos: TPoint;
begin
 ImgPos:= Point(0,0);
 if fDrawCaption then
  case FLayout of
    blGlyphLeft:
     begin
      ImgPos.X:= 4;
      ImgPos.Y:= (Self.Height div 2)-(fCustomImage.PartHeight div 2);
     end;
    blGlyphRight:
     begin
      ImgPos.X:= Self.Width-(fCustomImage.PartWidth+4);
      ImgPos.Y:= (Self.Height div 2)-(fCustomImage.PartHeight div 2);
     end;
    blGlyphTop:
     begin
      ImgPos.X:= (Self.Width div 2)-(fCustomImage.PartWidth div 2);
      ImgPos.Y:= 4;
     end;
    blGlyphBottom:
     begin
      ImgPos.X:= (Self.Width div 2)-(fCustomImage.PartWidth div 2);
      ImgPos.Y:= Self.Height-(fCustomImage.PartHeight+4);
     end;
  end
 else
  begin
   ImgPos.X:= (Self.Width div 2)-(fCustomImage.PartWidth div 2);
   ImgPos.Y:= (Self.Height div 2)-(fCustomImage.PartHeight div 2);
  end;
 case DrawState of
   bsNormal    : AeroPicture.DrawPart(PaintDC,fCustomImage.Data.Canvas.Handle,ImgPos,fCustomImage.PartSize,fCustomImage.PartNormal,fCustomImage.Orientation);
   bsHightLight: AeroPicture.DrawPart(PaintDC,fCustomImage.Data.Canvas.Handle,ImgPos,fCustomImage.PartSize,fCustomImage.PartHightLight,fCustomImage.Orientation);
   bsFocused   : AeroPicture.DrawPart(PaintDC,fCustomImage.Data.Canvas.Handle,ImgPos,fCustomImage.PartSize,fCustomImage.PartNormal,fCustomImage.Orientation);
   bsDown      : AeroPicture.DrawPart(PaintDC,fCustomImage.Data.Canvas.Handle,ImgPos,fCustomImage.PartSize,fCustomImage.PartDown,fCustomImage.Orientation);
   bsDisabled  : AeroPicture.DrawPart(PaintDC,fCustomImage.Data.Canvas.Handle,ImgPos,fCustomImage.PartSize,fCustomImage.PartDisabled,fCustomImage.Orientation);
 end;
end;

function TAeroImageButtonEx.GetCaptionRect: TRect;
begin
 if Assigned(fCustomImage.Data) then
  case FLayout of
    blGlyphLeft:
     begin
      Result.Left:= 6+fCustomImage.PartWidth;
      Result.Top:= 0;
      Result.Right:= Self.Width-4;
      Result.Bottom:= Self.Height;
     end;
    blGlyphRight:
     begin
      Result.Left:= 4;
      Result.Top:= 0;
      Result.Right:= Self.Width-(fCustomImage.PartWidth+6);
      Result.Bottom:= Self.Height;
     end;
    blGlyphTop:
     begin
      Result.Left:= 4;
      Result.Right:= Self.Width-4;
      Result.Top:= fCustomImage.PartHeight+6;
      Result.Bottom:= Self.Height;
     end;
    blGlyphBottom:
     begin
      Result.Left:= 4;
      Result.Right:= Self.Width-4;
      Result.Top:= 0;
      Result.Bottom:= Self.Height-(fCustomImage.PartHeight+6)
     end;
  end
 else
  Result:= GetClientRect;
end;

procedure TAeroImageButtonEx.ImageCustomChange(Sender: TObject);
begin
 Invalidate;
end;

procedure TAeroImageButtonEx.SetDrawCaption(const Value: BooLean);
begin
 if fDrawCaption <> Value then
  begin
   fDrawCaption:= Value;
   Invalidate;
  end;
end;

procedure TAeroImageButtonEx.SetLayout(const Value: TButtonLayout);
begin
 if FLayout <> Value then
  begin
   FLayout:= Value;
   Invalidate;
  end;
end;

procedure TAeroImageButtonEx.SetNewImage(const Value: TAeroButtonImage);
begin
 fCustomImage.Assign(Value);
end;

procedure TAeroImageButtonEx.SetTextGlow(const Value: BooLean);
begin
 if fTextGlow <> Value then
  begin
   fTextGlow:= Value;
   Invalidate;
  end;
end;

procedure TAeroImageButtonEx.ClassicRender(const ACanvas: TCanvas; const DrawState: Integer);
var
 clRect: TRect;
begin
 Inherited ClassicRender(ACanvas,DrawState);
 if Assigned(fCustomImage.Data) then DrawButtonImage(ACanvas.Handle,ButtonState);
 if fDrawCaption then
  begin
   clRect:= GetCaptionRect;
   AeroCore.RenderText(ACanvas.Handle,Self.Font,TextFormat,clRect,Caption);
   if Focused then ACanvas.DrawFocusRect(clRect);
  end; 
end;

procedure TAeroImageButtonEx.RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer);
var
 PartID, StateID: Integer;
begin
 Inherited RenderState(PaintDC,Surface,RConfig,DrawState);
 if Assigned(fCustomImage.Data) then DrawButtonImage(PaintDC,ButtonState);
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

end.
