{*******************************************************}
{                                                       }
{                    NTS Code Library                   }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit NTS.Code.Graphics.Gradient;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Graphics;
  {$ELSE}
  Windows, SysUtils, Graphics, Classes;
  {$ENDIF}

type
  TGradientType = ( gtHorizontal, gtVertical, gtRainbow, gtCircle, gtltTopBottom, gtWindow );
  TRGB = record
    B,G,R: byte;
  end;
  ARGB = array [0..1] of TRGB;
  PARGB = ^ARGB;

  TGradientClass = class
  Private
    class procedure HGradientRect(Bitmap: TBitmap; Canvas: TCanvas; X1, Y1, X2, Y2: integer; Color1, Color2: TColor);
    class procedure VGradientRect(Bitmap: TBitmap; Canvas: TCanvas; X1, Y1, X2, Y2: integer; Color1, Color2: TColor);
    class procedure RGradientRect(Bitmap: TBitmap; Canvas: TCanvas; X1, Y1, X2, Y2: integer; Color1, Color2: TColor);
    class procedure CGradientRect(Bitmap: TBitmap; Canvas: TCanvas; X1, Y1, X2, Y2: integer; Color1, Color2: TColor);
    class procedure BGradientRect(Bitmap: TBitmap; Canvas: TCanvas; X1, Y1, X2, Y2: integer; Color1, Color2: TColor);
    class procedure WGradientRect(Bitmap: TBitmap; Canvas: TCanvas; X1, Y1, X2, Y2: integer; Color1, Color2: TColor);
  Public
    class procedure Get(gType:TGradientType;Canvas: TCanvas; X1,Y1,X2,Y2: integer; Color1,Color2: TColor); OverLoad;
    class procedure Get(gType:TGradientType;Canvas: TCanvas; gRect: TRect; Color1,Color2: TColor); OverLoad;
  end;

implementation

{ TGradientClass }

class procedure TGradientClass.Get(gType: TGradientType; Canvas: TCanvas; X1, Y1, X2, Y2: integer; Color1, Color2: TColor);
var
  Bitmap: TBitmap;
begin
  Bitmap:= TBitmap.Create;
  Bitmap.PixelFormat:=pf24bit;

  case gType of
    gtHorizontal : HGradientRect(Bitmap, Canvas,X1,Y1,X2,Y2,Color1,Color2);
    gtVertical   : VGradientRect(Bitmap, Canvas,X1,Y1,X2,Y2,Color1,Color2);
    gtRainbow    : RGradientRect(Bitmap, Canvas,X1,Y1,X2,Y2,Color1,Color2);
    gtCircle     : CGradientRect(Bitmap, Canvas,X1,Y1,X2,Y2,Color1,Color2);
    gtltTopBottom: BGradientRect(Bitmap, Canvas,X1,Y1,X2,Y2,Color1,Color2);
    gtWindow     : WGradientRect(Bitmap, Canvas,X1,Y1,X2,Y2,Color1,Color2);
  end;

  Bitmap.Free;
end;

class procedure TGradientClass.Get(gType: TGradientType; Canvas: TCanvas; gRect: TRect; Color1, Color2: TColor);
begin
  Get(gType,Canvas,gRect.Left,gRect.Top,gRect.Right,gRect.Bottom,Color1,Color2);
end;

class procedure TGradientClass.HGradientRect(Bitmap: TBitmap; Canvas: TCanvas; X1, Y1, X2, Y2: integer; Color1, Color2: TColor);
var
  x, y, c1, c2, r1, g1, b1: integer;
  dr, dg, db: real;
  p: PARGB;
begin
  Bitmap.Width:=abs(X1-X2);
  Bitmap.Height:=abs(Y1-Y2);
  c1:=ColorToRGB(Color1);
  r1:=getRValue(c1);
  g1:=getGValue(c1);
  b1:=getBValue(c1);
  c2:=ColorToRGB(Color2);
  dr:=(getRValue(c2)-r1)/Bitmap.Width;
  dg:=(getGValue(c2)-g1)/Bitmap.Width;
  db:=(getBValue(c2)-b1)/Bitmap.Width;
  for y:=0 to Bitmap.Height-1 do
  begin
    p:= Bitmap.ScanLine[y];
    for x:=0 to Bitmap.Width-1 do
    begin
      p[x].R:=round(r1+x*dr);
      p[x].G:=round(g1+x*dg);
      p[x].B:=round(b1+x*db)
    end
  end;
  Canvas.Draw(X1, Y1, Bitmap)
end;

class procedure TGradientClass.VGradientRect(Bitmap: TBitmap; Canvas: TCanvas; X1, Y1, X2, Y2: integer; Color1, Color2: TColor);
var
  x, y, c1, c2, r1, g1, b1: integer;
  dr, dg, db: real;
  p: PARGB;
begin
  Bitmap.Width:= abs(X1-X2);
  Bitmap.Height:= abs(Y1-Y2);
  c1:= ColorToRGB(Color1);
  r1:= getRValue(c1);
  g1:= getGValue(c1);
  b1:= getBValue(c1);
  c2:= ColorToRGB(Color2);
  dr:= (getRValue(c2)-r1)/Bitmap.Height;
  dg:= (getGValue(c2)-g1)/Bitmap.Height;
  db:= (getBValue(c2)-b1)/Bitmap.Height;
  for y:=0 to Bitmap.Height-1 do
  begin
    p:= Bitmap.ScanLine[y];
    for x:=0 to Bitmap.Width-1 do
    begin
      p[x].R:= round(r1+y*dr);
      p[x].G:= round(g1+y*dg);
      p[x].B:= round(b1+y*db)
    end
  end;
  Canvas.Draw(X1, Y1, Bitmap)
end;

class procedure TGradientClass.WGradientRect(Bitmap: TBitmap; Canvas: TCanvas; X1, Y1, X2, Y2: integer;Color1, Color2: TColor);
begin
  Canvas.Brush.Color:= clWhite;
  Canvas.FillRect(Rect(X1,Y1,X2,Y2));
  Get(gtVertical,Canvas,0,0,X2,40,Color1,clWhite);
  Get(gtVertical,Canvas,0,40,X2,Y2,clWhite,Color2);
end;

class procedure TGradientClass.RGradientRect(Bitmap: TBitmap; Canvas: TCanvas; X1, Y1, X2, Y2: integer; Color1, Color2: TColor);
var
  x, y, c1, c2, r1, g1, b1: integer;
  dr, dg, db, d: real;
  p: PARGB;
begin
  Bitmap.Width:=abs(X1-X2);
  Bitmap.Height:=abs(Y1-Y2);
  c1:=ColorToRGB(Color1);
  r1:=getRValue(c1);
  g1:=getGValue(c1);
  b1:=getBValue(c1);
  c2:=ColorToRGB(Color2);
  d:= sqrt(Bitmap.Width*Bitmap.Width+Bitmap.Height*Bitmap.Height)/2;
  dr:=(getRValue(c2)-r1)/d;
  dg:=(getGValue(c2)-g1)/d;
  db:=(getBValue(c2)-b1)/d;
  for y:=0 to Bitmap.Height-1 do
  begin
    p:=Bitmap.ScanLine[y];
    for x:=0 to Bitmap.Width-1 do
    begin
      // d:=sqrt(((Bitmap.Width-2*x)*(Bitmap.Width-2*x)+(Bitmap.Height-2*y)*(Bitmap.Height-2*y))/4);
      d:=sqrt(((Bitmap.Width-2*x)*(Bitmap.Width-2*x))/4);
      p[x].R:=round(r1+d*dr);
      p[x].G:=round(g1+d*dg);
      p[x].B:=round(b1+d*db)
    end
  end;
  Canvas.Draw(X1, Y1, Bitmap)
end;

class procedure TGradientClass.CGradientRect(Bitmap: TBitmap; Canvas: TCanvas; X1, Y1, X2, Y2: integer; Color1, Color2: TColor);
var
  x, y, c1, c2, r1, g1, b1: integer;
  dr, dg, db, d: real;
  p: PARGB;
begin
  Bitmap.Width:=abs(X1-X2);
  Bitmap.Height:=abs(Y1-Y2);
  c1:=ColorToRGB(Color1);
  r1:=getRValue(c1);
  g1:=getGValue(c1);
  b1:=getBValue(c1);
  c2:=ColorToRGB(Color2);
  d:= sqrt(Bitmap.Width*Bitmap.Width+Bitmap.Height*Bitmap.Height)/2;
  dr:=(getRValue(c2)-r1)/d;
  dg:=(getGValue(c2)-g1)/d;
  db:=(getBValue(c2)-b1)/d;
  for y:=0 to Bitmap.Height-1 do
  begin
    p:=Bitmap.ScanLine[y];
    for x:=0 to Bitmap.Width-1 do
    begin
      d:=sqrt(((Bitmap.Width-2*x)*(Bitmap.Width-2*x)+(Bitmap.Height-2*y)*(Bitmap.Height-2*y))/4);
      p[x].R:=round(r1+d*dr);
      p[x].G:=round(g1+d*dg);
      p[x].B:=round(b1+d*db)
    end
  end;
  Canvas.Draw(X1, Y1, Bitmap)
end;

class procedure TGradientClass.BGradientRect(Bitmap: TBitmap; Canvas: TCanvas; X1, Y1, X2, Y2: integer; Color1, Color2: TColor);
var
  x, y, c1, c2, r1, g1, b1: integer;
  dr, dg, db, d: real;
  p: PARGB;
begin
  Bitmap.Width:=abs(X1-X2);
  Bitmap.Height:=abs(Y1-Y2);
  c1:=ColorToRGB(Color1);
  r1:=getRValue(c1);
  g1:=getGValue(c1);
  b1:=getBValue(c1);
  c2:=ColorToRGB(Color2);
  d:= sqrt(Bitmap.Width*Bitmap.Width+Bitmap.Height*Bitmap.Height)/2;
  dr:=(getRValue(c2)-r1)/d;
  dg:=(getGValue(c2)-g1)/d;
  db:=(getBValue(c2)-b1)/d;
  for y:=0 to Bitmap.Height-1 do
  begin
    p:=Bitmap.ScanLine[y];
    for x:=0 to Bitmap.Width-1 do
    begin
      d:=sqrt(((Bitmap.Height-2*y)*(Bitmap.Height-2*y))/4);
      // d:=sqrt(((Bitmap.Width-2*x)*(Bitmap.Width-2*x))/4);
      p[x].R:=round(r1+d*dr);
      p[x].G:=round(g1+d*dg);
      p[x].B:=round(b1+d*db)
    end
  end;
  Canvas.Draw(X1, Y1, Bitmap)
end;

end.
