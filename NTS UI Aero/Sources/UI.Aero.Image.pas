{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Image;

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
  Vcl.Controls,
  {$ELSE}
  SysUtils, Windows, Messages, Classes, Controls, Graphics, UxTheme,
  Winapi.GDIPOBJ,
  {$ENDIF}
  NTS.Code.Common.Types,
  NTS.Code.Helpers,
  UI.Aero.Core.CustomControl,
  UI.Aero.Core.Images,
  UI.Aero.Core.BaseControl,
  UI.Aero.Globals;

type
  TAeroImage = Class(TCustomAeroControl)
  Private
    fImage: TImageFileName;
    fImgPos: TImagePosition;
    procedure SetImage(const Value: TImageFileName);
    procedure SetImgPos(const Value: TImagePosition);
    function GetImageRect: TRect;
  Protected
    Data: TBitmap;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    function GetRenderState: TRenderConfig; OverRide;
    procedure ClassicRender(const ACanvas: TCanvas); OverRide;
    procedure ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig); OverRide;
    procedure RenderImage(const PaintDC: hDC);
    procedure PostRender(const Surface: TCanvas; const RConfig: TRenderConfig); override;
  Public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;  
  Published
    property AutoSize;
    Property ImageName: TImageFileName Read fImage Write SetImage;
    Property ImagePosition: TImagePosition Read fImgPos Write SetImgPos Default ipTopLeft;
  End;


implementation

{ TAeroImage }

Constructor TAeroImage.Create(AOwner: TComponent);
begin
 Inherited Create(AOwner);
 fImage:= '';
 Data:= nil;
 fImgPos:= ipTopLeft;
end;

Destructor TAeroImage.Destroy;
begin
 if Assigned(Data) then
  Data.Free;
 Inherited Destroy;
end;

function TAeroImage.GetImageRect: TRect;

 function GetCenterLeft: Integer;
 begin
  Result:= (Self.ClientWidth div 2)-(Data.Width div 2);
 end;

 function GetCenterTop: Integer;
 begin
  Result:= (Self.ClientHeight div 2)-(Data.Height div 2);
 end;

 function GetRightLeft: Integer;
 begin
  Result:= Self.ClientWidth-Data.Width;
 end;

 function GetBottomTop: Integer;
 begin
  Result:= Self.ClientHeight-Data.Height;
 end;

begin
 case fImgPos of
   ipTopLeft       : Result:= Rect(0,0,Data.Width,Data.Height);
   ipTopCenter     : Result:= Rect(GetCenterLeft,0,Data.Width,Data.Height);
   ipTopRight      : Result:= Rect(GetRightLeft,0,Data.Width,Data.Height);

   ipCenterLeft    : Result:= Rect(0,GetCenterTop,Data.Width,Data.Height);
   ipCenter        : Result:= Rect(GetCenterLeft,GetCenterTop,Data.Width,Data.Height);
   ipCenterRight   : Result:= Rect(GetRightLeft,GetCenterTop,Data.Width,Data.Height);

   ipBottomLeft    : Result:= Rect(0,GetBottomTop,Data.Width,Data.Height);
   ipBottomCenter  : Result:= Rect(GetCenterLeft,GetBottomTop,Data.Width,Data.Height);
   ipBottomRight   : Result:= Rect(GetRightLeft,GetBottomTop,Data.Width,Data.Height);

   ipStretch       : Result:= GetClientRect;
 end;
end;

function TAeroImage.GetRenderState: TRenderConfig;
begin
 Result:= [rsBuffer];
end;

procedure TAeroImage.PostRender(const Surface: TCanvas; const RConfig: TRenderConfig);
begin

end;

procedure TAeroImage.RenderImage(const PaintDC: hDC);
begin
 AeroPicture.StretchDraw(PaintDC,Data,GetImageRect);
end;

function TAeroImage.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
 Result:= True;
 if Assigned(Data) then
  if IsRunTime or (Data.Width > 0) and (Data.Height > 0) then
   begin
    if Align in [alNone, alLeft, alRight] then
     NewWidth := Data.Width;
    if Align in [alNone, alTop, alBottom] then
     NewHeight := Data.Height;
   end;
end;

procedure TAeroImage.SetImage(const Value: TImageFileName);
begin
 if fImage <> Value then
  begin
   fImage:= Value;
   if Assigned(Data) then
    Data.Free;
   Data:= AeroPicture.LoadImage(fImage);
   Invalidate;
   if Assigned(Data) and AutoSize then
    SetBounds(Left,Top,Data.Width,Data.Height);
  end;
end;

procedure TAeroImage.SetImgPos(const Value: TImagePosition);
begin
 if fImgPos <> Value then
  begin
   fImgPos:= Value;
   Invalidate;
  end;
end;

procedure TAeroImage.ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig);
begin
 if Assigned(Data) then
  RenderImage(PaintDC);
end;

procedure TAeroImage.ClassicRender(const ACanvas: TCanvas);
begin
 if Assigned(Data) then
  RenderImage(ACanvas.Handle)
end;

end.
