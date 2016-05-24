{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.Composition;

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
  Vcl.StdCtrls,
  {$ELSE}
  SysUtils, Windows, Messages, Classes, Controls, Types,
  UxTheme, Graphics, Winapi.GDIPOBJ, StdCtrls,
  {$ENDIF}
  NTS.Code.Common.Types,
  UI.Aero.Core.CustomControl,
  UI.Aero.Image,
  UI.Aero.Window,
  UI.Aero.Core.BaseControl,
  UI.Aero.Core.CustomControl.Animation,
  UI.Aero.Globals,
  UI.Aero.Core;

type
  TThemeCollectionItem   = Class;
  TFontCollectionItem    = Class;
  TImageCollectionItem   = Class;

  TElementItem = Class;
   TElementImage = Class;
   TElementText = Class;
   TElementTheme = Class;

  TCustomCompositionItem = Class;
   TCompositionElement    = Class;

  TCustomAeroCollection  = Class;
   TAeroThemeCollection   = Class;
   TAeroFontCollection    = Class;
   TAeroImageCollection   = Class;
   TCompositionCollection = Class;

  TAeroComposition       = Class;
  TAeroAnimationComposition = class;

  TAeroDrawThemeElementEvent = procedure(const Sender: TCompositionElement; PartID, StateID: Integer; Surface: hDC) of object;

  TThemeCollectionItem = Class(TCollectionItem)
  private
    fThemeData: hTheme;
    fDataName: String;
    fElementPaint: TAeroDrawThemeElementEvent;
    procedure SetDataName(const Value: String);
  Public
    Constructor Create(Collection: TCollection); override;
    Destructor Destroy; override;
  Published
    property DataName: String Read fDataName Write SetDataName;
    property ThemeData: hTheme Read fThemeData Default 0;
    property OnThemePaint: TAeroDrawThemeElementEvent Read fElementPaint Write fElementPaint;
  End;

  TFontCollectionItem = Class(TCollectionItem)
  private
    fFont: TFont;
    procedure SetFont(const Value: TFont);
  published
  Public
    Constructor Create(Collection: TCollection); override;
    Destructor Destroy; override;
  Published
    property Font: TFont Read fFont Write SetFont;
  End;

  TImageCollectionItem = Class(TCollectionItem)
  private
    fFileName: TImageFileName;
    procedure SetFileName(const Value: TImageFileName);
  published
  Public
    Image: TBitmap;
    Constructor Create(Collection: TCollection); override;
    Destructor Destroy; override;
  Published
    property FileName: TImageFileName Read fFileName Write SetFileName;
  End;

  TCustomCompositionItem = Class(TCollectionItem)
  private
    fWidth: Integer;
    fVisible: BooLean;
    fTop: Integer;
    fHeight: Integer;
    fLeft: Integer;
    fDesigningRect: BooLean;
    procedure SetBoundsValue(const Index, Value: Integer);
    procedure SetVisible(const Value: BooLean);
    procedure SetDesigningRect(const Value: BooLean);
  Protected
    Function GetParent: TAeroBaseControl;
    Function GetParentImageCollection: TAeroImageCollection;
    Function GetParentThemeCollection: TAeroThemeCollection;
    Function GetParentFontCollection: TAeroFontCollection;
    Function GetParentThemeData: hTheme;
  Public
    Constructor Create(Collection: TCollection); override;
    procedure ParentRePaint;
    procedure SetBounds(ALeft,ATop,AWidth,AHeight: Integer); Virtual;
    procedure RenderItem(const DC: hDC;ClassicDraw: Boolean = False); Virtual;
    function GetBounds: TRect; Virtual;
  Published
    property Visible: BooLean Read fVisible Write SetVisible default True;
    Property DesigningRect: BooLean Read fDesigningRect Write SetDesigningRect Default True;
  //
    property Left: Integer Index 0 Read fLeft Write SetBoundsValue;
    property Top: Integer Index 1 Read fTop Write SetBoundsValue;
    property Width: Integer Index 2 Read fWidth Write SetBoundsValue;
    property Height: Integer Index 3 Read fHeight Write SetBoundsValue;      
  End;

  TElementItem = Class(TPersistent)
  private
    FOnChange: TNotifyEvent;
  Protected
    Procedure Change; virtual;
  Public
    Constructor Create; virtual;
    Property OnChange: TNotifyEvent read FOnChange write FOnChange;
  End;

  TElementImage = class(TElementItem)
  private
    fImageIndex: Integer;
    fPosition: TImagePosition;
    procedure SetImageIndex(const Value: Integer);
    procedure SetPosition(const Value: TImagePosition);
  Public
    Constructor Create; override;
  Published
    property ImageIndex: Integer Read fImageIndex Write SetImageIndex default -1;
    property Position: TImagePosition Read fPosition Write SetPosition default ipCenter;
  end;

  TElementText = class(TElementItem)
  private
    fText: String;
    fAlignment: TAlignment;
    FLayout: TTextLayout;
    fWordWrap: Boolean;
    fDrawGlow: BooLean;
    fFontIndex: Integer;
    procedure SetText(const Value: String);
    procedure SetAlignment(const Value: TAlignment);
    procedure SetLayout(const Value: TTextLayout);
    procedure SetWordWrap(const Value: Boolean);
    procedure SetDrawGlow(const Value: BooLean);
    procedure SetFontIndex(const Value: Integer);
  Public
    Constructor Create; override;
    function GetTextFormat: DWORD;
  Published
    Property Text: String Read fText Write SetText;
    Property Alignment: TAlignment Read fAlignment Write SetAlignment Default taCenter;
    property Layout: TTextLayout Read FLayout Write SetLayout Default tlCenter;
    property WordWrap: Boolean Read fWordWrap Write SetWordWrap Default False;
    property DrawGlow: BooLean Read fDrawGlow Write SetDrawGlow Default False;
    property FontIndex: Integer Read fFontIndex Write SetFontIndex default -1;
    
{
     |-[ThemeText]
}


{
  TCompositionTextItem = Class(TCustomCompositionItem)
  private
    fFont: Integer;
    fGlow: BooLean;
    fText: String;
    procedure SetFont(const Value: Integer);
    procedure SetGlow(const Value: BooLean);
    procedure SetText(const Value: String);
  Public
    Constructor Create(Collection: TCollection); override;
    procedure RenderItem(const DC: hDC); override;
  Published
    Property Font: Integer Read fFont Write SetFont Default -1;
    Property Text: String Read fText Write SetText;
    Property Glow: BooLean Read fGlow Write SetGlow Default False;
  End;
}
  end;

  TElementTheme = class(TElementItem)
  private
    fPartID: Integer;
    fThemeIndex: Integer;
    fStateID: Integer;
    procedure SetThemeID(const Index, Value: Integer);
    procedure SetThemeIndex(const Value: Integer);
  published
  Public
    Constructor Create; override;
  Published
    property ThemeIndex: Integer Read fThemeIndex Write SetThemeIndex default -1;
    property PartID: Integer Index 0 Read fPartID Write SetThemeID default 1;
    property StateID: Integer Index 1 Read fStateID Write SetThemeID default 1;
  end;

  TCompositionElement = Class(TCustomCompositionItem)
  private
    fSecond: TCompositionDraw;
    fThird: TCompositionDraw;
    fFirst: TCompositionDraw;
    fTheme: TElementTheme;
    fImage: TElementImage;
    fText: TElementText;
    fDragWindow: Boolean;
    procedure SetCompositionDraw(const Index: Integer; const Value: TCompositionDraw);
    procedure SetElementImage(const Value: TElementImage);
    procedure SetElementText(const Value: TElementText);
    procedure SetElementTheme(const Value: TElementTheme);
  Protected
    procedure ImageChange(Sender: TObject);
    procedure ThemeChange(Sender: TObject);
    procedure TextChange(Sender: TObject);

    function GetImageData: TBitmap;
    function GetImageRect(Data: TBitmap): TRect;
    procedure RenderImage(const DC: hDC); Virtual;
    procedure RenderText(const DC: hDC); Virtual;
    procedure RenderTheme(const DC: hDC;ClassicDraw: Boolean); Virtual;
  Public
    Constructor Create(Collection: TCollection); override;
    Destructor Destroy; override;
    procedure RenderItem(const DC: hDC;ClassicDraw: Boolean = False); override;
  Published
    property FirstDraw: TCompositionDraw  Index 0 Read fFirst  Write SetCompositionDraw;
    property SecondDraw: TCompositionDraw Index 1 Read fSecond Write SetCompositionDraw;
    property ThirdDraw: TCompositionDraw  Index 2 Read fThird  Write SetCompositionDraw;

    property Image: TElementImage Read fImage Write SetElementImage;
    property Text : TElementText  Read fText  Write SetElementText;
    property Theme: TElementTheme Read fTheme Write SetElementTheme;
    property DragWindow: Boolean Read fDragWindow Write fDragWindow default True;
  End;

  TCustomAeroCollection = Class(TCollection)
  Private
    fOwner: TAeroBaseControl;
  Public
    Constructor Create(AOwner: TAeroBaseControl;ItemClass: TCollectionItemClass);
    Function Owner: TAeroBaseControl;
  End;

  TAeroThemeCollection = Class(TCustomAeroCollection)
  Private
    function GetItem(Index: Integer): TThemeCollectionItem;
    procedure SetItem(Index: Integer; const Value: TThemeCollectionItem);
  Public
    Constructor Create(AOwner: TAeroBaseControl);
    function Add: TThemeCollectionItem;
    procedure ReloadTheme(Index: Integer);
    procedure FreeThemes;
    property Items[Index: Integer]: TThemeCollectionItem read GetItem write SetItem; default;
  End;

  TAeroFontCollection = Class(TCustomAeroCollection)
  private
    function GetItem(Index: Integer): TFontCollectionItem;
    procedure SetItem(Index: Integer; const Value: TFontCollectionItem);
  Public
    Constructor Create(AOwner: TAeroBaseControl);
    function Add: TFontCollectionItem;
    property Items[Index: Integer]: TFontCollectionItem read GetItem write SetItem; default;
  End;

  TAeroImageCollection = Class(TCustomAeroCollection)
  private
    function GetItem(Index: Integer): TImageCollectionItem;
    procedure SetItem(Index: Integer; const Value: TImageCollectionItem);
  Public
    Constructor Create(AOwner: TAeroBaseControl);
    function Add: TImageCollectionItem;
    property Items[Index: Integer]: TImageCollectionItem read GetItem write SetItem; default;
  End;

  TCompositionCollection = Class(TCustomAeroCollection)
  private
    function GetItem(Index: Integer): TCompositionElement;
    procedure SetItem(Index: Integer; const Value: TCompositionElement);
  Public
    Constructor Create(AOwner: TAeroBaseControl);
    Function Add: TCompositionElement;
    Property Items[Index: Integer]: TCompositionElement read GetItem write SetItem; default;
  End;

  TCompositionAnimationElement = Class(TCollectionItem)
  private
    fComposition: TCompositionCollection;
    procedure SetComposition(const Value: TCompositionCollection);
  published
  Public
    Constructor Create(Collection: TCollection); override;
    Destructor Destroy; override;
  Published
    property Composition: TCompositionCollection Read fComposition Write SetComposition;
  End;

  TAnimationCompositionCollection = Class(TCustomAeroCollection)
  private
    function GetItem(Index: Integer): TCompositionAnimationElement;
    procedure SetItem(Index: Integer; const Value: TCompositionAnimationElement);
  Public
    Constructor Create(AOwner: TAeroAnimationComposition);
    Function Add: TCompositionAnimationElement;
    Property Items[Index: Integer]: TCompositionAnimationElement read GetItem write SetItem; default;
  End;

  TAeroComposition = Class(TCustomAeroControl)
  private
    fFontCollection: TAeroFontCollection;
    fThemeCollection: TAeroThemeCollection;
    fItems: TCompositionCollection;
    fImageCollection: TAeroImageCollection;
    procedure SetFontCollection(const Value: TAeroFontCollection);
    procedure SetThemeCollection(const Value: TAeroThemeCollection);
    procedure SetItems(const Value: TCompositionCollection);
    procedure SetImageCollection(const Value: TAeroImageCollection);
  Protected
    function GetRenderState: TRenderConfig; OverRide;
    procedure ClassicRender(const ACanvas: TCanvas); OverRide;
    procedure ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig); OverRide;
    function GetThemeClassName: PWideChar; override;
    procedure CurrentThemeChanged; override;
    function CanDrag(X,Y: Integer): BooLean; override;
    procedure PostRender(const Surface: TCanvas; const RConfig: TRenderConfig); override;
  Public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
    function AddFont: TFontCollectionItem; InLine;
    function AddImage: TImageCollectionItem; InLine;
    function AddTheme: TThemeCollectionItem; InLine;
  Published
    property Font;
    property ThemeCollection: TAeroThemeCollection Read fThemeCollection Write SetThemeCollection;
    property FontCollection: TAeroFontCollection Read fFontCollection Write SetFontCollection;
    property ImageCollection: TAeroImageCollection Read fImageCollection Write SetImageCollection;
    property Items: TCompositionCollection Read fItems Write SetItems;
  End;
  
  TAeroAnimationComposition = class(TCustomAeroControlWithAnimation)
  private
    fFontCollection: TAeroFontCollection;
    fThemeCollection: TAeroThemeCollection;
    fImageCollection: TAeroImageCollection;
    fItems: TAnimationCompositionCollection;
    procedure SetFontCollection(const Value: TAeroFontCollection);
    procedure SetImageCollection(const Value: TAeroImageCollection);
    procedure SetThemeCollection(const Value: TAeroThemeCollection);
    procedure SetItems(const Value: TAnimationCompositionCollection);
    function GetCurrentItem: Integer;
    procedure SetCurrentItem(const Value: Integer);
  Protected
    function GetThemeClassName: PWideChar; override;
    function GetRenderState: TARenderConfig; OverRide;
    procedure RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer); OverRide;
    procedure ClassicRender(const ACanvas: TCanvas; const DrawState: Integer); OverRide;
    procedure PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer); override;
  Public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
    function AddFont: TFontCollectionItem; InLine;
    function AddImage: TImageCollectionItem; InLine;
    function AddTheme: TThemeCollectionItem; InLine;
  Published
    property Font;
    property ThemeCollection: TAeroThemeCollection Read fThemeCollection Write SetThemeCollection;
    property FontCollection: TAeroFontCollection Read fFontCollection Write SetFontCollection;
    property ImageCollection: TAeroImageCollection Read fImageCollection Write SetImageCollection;
    property Items: TAnimationCompositionCollection Read fItems Write SetItems;
    property CurrentItem: Integer Read GetCurrentItem Write SetCurrentItem Default 0;
  end;

implementation

uses
  UI.Aero.Core.Images, Math;

{ TCustomAeroCollection }

Constructor TCustomAeroCollection.Create(AOwner: TAeroBaseControl; ItemClass: TCollectionItemClass);
begin
 Inherited Create(ItemClass);
 fOwner:= AOwner;
end;

Function TCustomAeroCollection.Owner: TAeroBaseControl;
begin
 Result:= fOwner;
end;

{ TThemeCollectionItem }

Constructor TThemeCollectionItem.Create(Collection: TCollection);
begin
 Inherited Create(Collection);
 fThemeData:= 0;
 fDataName:= '';
end;

Destructor TThemeCollectionItem.Destroy;
begin
 if fThemeData <> 0 then
  CloseThemeData(fThemeData);
 Inherited Destroy;
end;

procedure TThemeCollectionItem.SetDataName(const Value: String);
begin
 if fDataName <> Value then
  begin
   fDataName:= Value;
   TAeroThemeCollection(Collection).ReloadTheme(Index);
  end;
end;

{ TAeroThemeCollection }

Constructor TAeroThemeCollection.Create(AOwner: TAeroBaseControl);
begin
 Inherited Create(AOwner,TThemeCollectionItem);
end;

procedure TAeroThemeCollection.FreeThemes;
var
 I: integer;
begin
 for I:=0 to Self.Count-1 do
  if Items[I].ThemeData <> 0 then
   begin
    CloseThemeData(Items[I].ThemeData);
    Items[I].fThemeData:= 0;
   end;
end;

Function TAeroThemeCollection.Add: TThemeCollectionItem;
begin
 Result:= TThemeCollectionItem(Inherited Add);
end;

Function TAeroThemeCollection.GetItem(Index: Integer): TThemeCollectionItem;
begin
 Result:= TThemeCollectionItem(Inherited GetItem(Index));
end;

procedure TAeroThemeCollection.ReloadTheme(Index: Integer);

  procedure ReloadItemTheme(AIndex: Integer);
  begin
   if Items[AIndex].ThemeData <> 0 then
    begin
     CloseThemeData(Items[AIndex].ThemeData);
     Items[AIndex].fThemeData:= 0;
    end;
   if Items[AIndex].fDataName <> '' then
    Items[AIndex].fThemeData:= OpenThemeData(0,pChar(Items[AIndex].fDataName));
  end;

var
 I: Integer;
begin
 if Index = -1 then
  for I:=0 to Self.Count-1 do
   ReloadItemTheme(I)
 else
  ReloadItemTheme(Index);
end;

Procedure TAeroThemeCollection.SetItem(Index: Integer; const Value: TThemeCollectionItem);
begin
 Inherited SetItem(Index, Value);
end;

{ TFontCollectionItem }

Constructor TFontCollectionItem.Create(Collection: TCollection);
begin
 Inherited Create(Collection);
 fFont:= TFont.Create;
end;

Destructor TFontCollectionItem.Destroy;
begin
 fFont.Free;
 Inherited Destroy;
end;

procedure TFontCollectionItem.SetFont(const Value: TFont);
begin
 fFont.Assign(Value);
end;

{ TAeroFontCollection }

Constructor TAeroFontCollection.Create(AOwner: TAeroBaseControl);
begin
 Inherited Create(AOwner,TFontCollectionItem);
end;

Function TAeroFontCollection.Add: TFontCollectionItem;
begin
 Result:= TFontCollectionItem(Inherited Add);
end;

Function TAeroFontCollection.GetItem(Index: Integer): TFontCollectionItem;
begin
 Result:= TFontCollectionItem(Inherited GetItem(Index));
end;

Procedure TAeroFontCollection.SetItem(Index: Integer; const Value: TFontCollectionItem);
begin
 Inherited SetItem(Index, Value);
end;

{ TAeroImageCollection }

Constructor TAeroImageCollection.Create(AOwner: TAeroBaseControl);
begin
 Inherited Create(AOwner,TImageCollectionItem); 
end;

function TAeroImageCollection.Add: TImageCollectionItem;
begin
 Result:= TImageCollectionItem(Inherited Add);
end;

function TAeroImageCollection.GetItem(Index: Integer): TImageCollectionItem;
begin
 Result:= TImageCollectionItem(Inherited GetItem(Index));
end;

procedure TAeroImageCollection.SetItem(Index: Integer; const Value: TImageCollectionItem);
begin
 Inherited SetItem(Index, Value);
end;

{ TCustomCompositionItem }

Constructor TCustomCompositionItem.Create(Collection: TCollection);
begin
 Inherited Create(Collection);
 SetBounds(0,0,50,50);
 fVisible:= True;
 fDesigningRect:= True;
end;

function TCustomCompositionItem.GetBounds: TRect;
begin
 Result:= Bounds(fLeft,fTop,fWidth,fHeight);
end;

function TCustomCompositionItem.GetParent: TAeroBaseControl;
begin
 Result:= TCompositionCollection(Collection).Owner;
end;

function TCustomCompositionItem.GetParentFontCollection: TAeroFontCollection;
begin
 if GetParent is TAeroComposition then
  Result:= TAeroComposition(GetParent).FontCollection
 else
  Result:= TAeroAnimationComposition(GetParent).FontCollection;
end;

function TCustomCompositionItem.GetParentImageCollection: TAeroImageCollection;
begin
 if GetParent is TAeroComposition then
  Result:= TAeroComposition(GetParent).ImageCollection
 else
  Result:= TAeroAnimationComposition(GetParent).ImageCollection; 
end;

function TCustomCompositionItem.GetParentThemeCollection: TAeroThemeCollection;
begin
 if GetParent is TAeroComposition then
  Result:= TAeroComposition(GetParent).ThemeCollection
 else
  Result:= TAeroAnimationComposition(GetParent).ThemeCollection; 
end;

function TCustomCompositionItem.GetParentThemeData: hTheme;
begin
 if GetParent is TAeroComposition then
  Result:= TAeroComposition(GetParent).ThemeData
 else
  Result:= TAeroAnimationComposition(GetParent).ThemeData; 
end;

procedure TCustomCompositionItem.ParentRePaint;
begin
 GetParent.Invalidate;
end;

procedure TCustomCompositionItem.RenderItem(const DC: hDC;ClassicDraw: Boolean);
var
 ItRect: TRect;
begin
 if fDesigningRect and GetParent.IsDesigningTime then
  begin
   ItRect:= Bounds(Left,Top,Width,Height);
   DrawFocusRect(DC,ItRect);
  end;
end;

procedure TCustomCompositionItem.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
 fLeft:= ALeft;
 fTop:= ATop;
 fWidth:= AWidth;
 fHeight:= AHeight;
 ParentRePaint; 
end;

Procedure TCustomCompositionItem.SetBoundsValue(const Index, Value: Integer);
begin
 case Index of
   0: SetBounds(Value,fTop,fWidth,fHeight);// fLeft:= Value;
   1: SetBounds(fLeft,Value,fWidth,fHeight);// fTop:= Value;
   2: SetBounds(fLeft,fTop,Value,fHeight);// fWidth:= Value;
   3: SetBounds(fLeft,fTop,fWidth,Value);// fHeight:= Value;
 end;
end;

procedure TCustomCompositionItem.SetDesigningRect(const Value: BooLean);
begin
 if fDesigningRect <> Value then
  begin
   fDesigningRect:= Value;
   ParentRePaint;
  end;
end;

Procedure TCustomCompositionItem.SetVisible(const Value: BooLean);
begin
 if fVisible <> Value then
  begin
   fVisible:= Value;
   ParentRePaint;
  end;
end;

{ TImageCollectionItem }

Constructor TImageCollectionItem.Create(Collection: TCollection);
begin
 Inherited Create(Collection);
 fFileName:= '';
 Image:= nil;
end;

Destructor TImageCollectionItem.Destroy;
begin
 if Assigned(Image) then
  Image.Free;
 Inherited Destroy;
end;

procedure TImageCollectionItem.SetFileName(const Value: TImageFileName);
begin
 if fFileName <> Value then
  begin
   fFileName:= Value;
   if Assigned(Image) then
    Image.Free;
   Image:= AeroPicture.LoadImage(fFileName); 
  end;
end;

{ TCompositionCollection }

Constructor TCompositionCollection.Create(AOwner: TAeroBaseControl);
begin
 Inherited Create(AOwner,TCompositionElement);
end;

function TCompositionCollection.Add: TCompositionElement;
begin
 Result:= TCompositionElement(Inherited Add);
end;

function TCompositionCollection.GetItem(Index: Integer): TCompositionElement;
begin
 Result:= TCompositionElement(Inherited GetItem(Index));
end;

procedure TCompositionCollection.SetItem(Index: Integer; const Value: TCompositionElement);
begin
 Inherited SetItem(Index, Value);
end;

{ TAeroComposition }

Constructor TAeroComposition.Create(AOwner: TComponent);
begin
 Inherited Create(AOwner);
 ControlStyle:= ControlStyle+[csAcceptsControls];
 fFontCollection:= TAeroFontCollection.Create(Self);
 fThemeCollection:= TAeroThemeCollection.Create(Self);
 fImageCollection:= TAeroImageCollection.Create(Self);
 fItems:= TCompositionCollection.Create(Self);
end;

Destructor TAeroComposition.Destroy;
begin
 fItems.Free;
 fThemeCollection.Free;
 fFontCollection.Free;
 ImageCollection.Free;
 Inherited Destroy;
end;

procedure TAeroComposition.CurrentThemeChanged;
begin
 Inherited CurrentThemeChanged;
 ThemeCollection.ReloadTheme(-1);
end;

function TAeroComposition.GetRenderState: TRenderConfig;
begin
 Result:= [rsBuffer];
end;

function TAeroComposition.GetThemeClassName: PWideChar;
begin
 Result:= VSCLASS_WINDOW;
end;

procedure TAeroComposition.PostRender(const Surface: TCanvas; const RConfig: TRenderConfig);
begin

end;

procedure TAeroComposition.SetFontCollection(const Value: TAeroFontCollection);
begin
 fFontCollection.Assign(Value);
end;

procedure TAeroComposition.SetThemeCollection( const Value: TAeroThemeCollection);
begin
 fThemeCollection.Assign(Value);
end;

procedure TAeroComposition.SetImageCollection(const Value: TAeroImageCollection);
begin
 fImageCollection.Assign(Value);
end;

procedure TAeroComposition.SetItems(const Value: TCompositionCollection);
begin
 fItems.Assign(Value);
end;

function TAeroComposition.AddFont: TFontCollectionItem;
begin
 Result:= FontCollection.Add;
end;

function TAeroComposition.AddImage: TImageCollectionItem;
begin
 Result:= ImageCollection.Add;
end;

function TAeroComposition.AddTheme: TThemeCollectionItem;
begin
 Result:= ThemeCollection.Add;
end;

function TAeroComposition.CanDrag(X, Y: Integer): BooLean;
var
 I: Integer;
begin
 Result:= True;
 for I:=0 to Items.Count-1 do
  if PtInRect(Items[i].GetBounds,Point(X,Y)) then
   begin
    Result:= Items[i].DragWindow;
    Break;
   end;
end;

procedure TAeroComposition.ClassicRender(const ACanvas: TCanvas);
var
 I: Integer;
begin
 for I:=0 to Items.Count-1 do
  Items[I].RenderItem(ACanvas.Handle,True);
end;

procedure TAeroComposition.ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig);
var
 I: Integer;
begin
 for I:=0 to Items.Count-1 do
  Items[I].RenderItem(PaintDC);
end;

{ TCompositionElement }

Constructor TCompositionElement.Create(Collection: TCollection);
begin
 Inherited Create(Collection);
 fDragWindow:= True;

 fFirst:= cdNone;
 fSecond:= cdNone;
 fThird:= cdNone;

 fImage:= TElementImage.Create;
 fImage.OnChange:= ImageChange;

 fText:= TElementText.Create;
 fText.OnChange:= TextChange;

 fTheme:= TElementTheme.Create;
 fTheme.OnChange:= ThemeChange;
end;

Destructor TCompositionElement.Destroy;
begin
 fTheme.Free;
 fText.Free;
 fImage.Free;
 Inherited Destroy;
end;

procedure TCompositionElement.SetCompositionDraw(const Index: Integer; const Value: TCompositionDraw);
begin
 case Index of
   0: fFirst:= Value;
   1: fSecond:= Value;
   2: fThird:= Value;
 end;
 ParentRePaint;
end;

procedure TCompositionElement.SetElementImage(const Value: TElementImage);
begin
 fImage.Assign(Value);
end;

procedure TCompositionElement.SetElementText(const Value: TElementText);
begin
 fText.Assign(Value);
end;

procedure TCompositionElement.SetElementTheme(const Value: TElementTheme);
begin
 fTheme.Assign(Value);
end;

procedure TCompositionElement.RenderItem(const DC: hDC;ClassicDraw: Boolean);

 procedure CallRender(CurrentDraw: TCompositionDraw);
 begin
  case CurrentDraw of
    cdImage: RenderImage(DC);
    cdText : RenderText(DC);
    cdTheme: RenderTheme(DC,ClassicDraw);
  end;
 end;

begin
 Inherited RenderItem(DC);
 CallRender(fFirst);
 CallRender(fSecond);
 CallRender(fThird);
end;

function TCompositionElement.GetImageData: TBitmap;
begin
 if Image.ImageIndex <> -1 then
  Result:= GetParentImageCollection[Image.ImageIndex].Image
 else
  Result:= nil;
end;

function TCompositionElement.GetImageRect(Data: TBitmap): TRect;

 function GetCenterLeft: Integer;
 begin
  Result:= fLeft+((fWidth div 2)-(Data.Width div 2));
 end;

 function GetCenterTop: Integer;
 begin
  Result:= fTop+((fHeight div 2)-(Data.Height div 2));
 end;

 function GetRightLeft: Integer;
 begin
  Result:= fLeft+(fWidth-Data.Width);
 end;

 function GetBottomTop: Integer;
 begin
  Result:= fTop+(fHeight-Data.Height);
 end;

begin//fLeft,fTop,fWidth,fHeight
 case Image.Position of
   ipTopLeft       : Result:= Rect(fLeft        ,fTop,Data.Width,Data.Height);
   ipTopCenter     : Result:= Rect(GetCenterLeft,fTop,Data.Width,Data.Height);
   ipTopRight      : Result:= Rect(GetRightLeft ,fTop,Data.Width,Data.Height);

   ipCenterLeft    : Result:= Rect(fLeft        ,GetCenterTop,Data.Width,Data.Height);
   ipCenter        : Result:= Rect(GetCenterLeft,GetCenterTop,Data.Width,Data.Height);
   ipCenterRight   : Result:= Rect(GetRightLeft ,GetCenterTop,Data.Width,Data.Height);

   ipBottomLeft    : Result:= Rect(fLeft        ,GetBottomTop,Data.Width,Data.Height);
   ipBottomCenter  : Result:= Rect(GetCenterLeft,GetBottomTop,Data.Width,Data.Height);
   ipBottomRight   : Result:= Rect(GetRightLeft ,GetBottomTop,Data.Width,Data.Height);

   ipStretch       : Result:= Rect(fLeft,fTop,fWidth,fHeight);
 end;
end;

procedure TCompositionElement.ImageChange(Sender: TObject);
begin
 if not InRange(Image.ImageIndex,-1,GetParentImageCollection.Count-1) then
  Image.fImageIndex:= -1;
 ParentRePaint;
end;

procedure TCompositionElement.TextChange(Sender: TObject);
begin
 if not InRange(Text.FontIndex,-1,GetParentFontCollection.Count-1) then
  Text.fFontIndex:= -1;
 ParentRePaint;
end;

procedure TCompositionElement.ThemeChange(Sender: TObject);
begin
 if not InRange(Theme.ThemeIndex,-1,GetParentThemeCollection.Count-1) then
  Theme.ThemeIndex:= -1;
 ParentRePaint;
end;

procedure TCompositionElement.RenderImage(const DC: hDC);
var
 ImageData: TBitmap;
begin
 ImageData:= GetImageData;
 if Assigned(ImageData) then
  AeroPicture.StretchDraw(DC,ImageData,GetImageRect(ImageData));
end;

procedure TCompositionElement.RenderText(const DC: hDC);
var
 TextRect: TRect;
 TextFont: TFont;
begin
 if Text.Text <> '' then
  begin
   TextRect:= Bounds(Left,Top,Width,Height);
   if Text.FontIndex = -1 then
    TextFont:= GetParent.Font
   else
    TextFont:= GetParentFontCollection[Text.FontIndex].Font;
   AeroCore.RenderText(DC,GetParentThemeData,1,1,TextFont,Text.GetTextFormat,TextRect, Text.Text,Text.DrawGlow);
  end;
end;

procedure TCompositionElement.RenderTheme(const DC: hDC;ClassicDraw: Boolean);
var
 ThemeData: hTheme;
 DrawRect: TRect;
begin
 if ClassicDraw then
  begin
   if (Theme.ThemeIndex <> -1) and Assigned(GetParentThemeCollection[Theme.ThemeIndex].OnThemePaint) then
    GetParentThemeCollection[Theme.ThemeIndex].OnThemePaint(Self,Theme.PartID,Theme.StateID,DC);
  end
 else
  begin
   if Theme.ThemeIndex <> -1 then
    ThemeData:= GetParentThemeCollection[Theme.ThemeIndex].ThemeData
   else
    ThemeData:= 0;
   if ThemeData <> 0 then
    begin
     DrawRect:= Bounds(Left,Top,Width,Height);
     DrawThemeBackground(ThemeData,DC,Theme.PartID,Theme.StateID,DrawRect,@DrawRect);
    end;
  end;
end;

{ TElementItem }

Constructor TElementItem.Create;
begin
 FOnChange:= nil;
end;

procedure TElementItem.Change;
begin
 if Assigned(FOnChange) then
  FOnChange(Self);
end;

{ TElementImage }

Constructor TElementImage.Create;
begin
 Inherited Create;
 fImageIndex:= -1;
 fPosition:= ipCenter;
end;

procedure TElementImage.SetImageIndex(const Value: Integer);
begin
 if Value <> fImageIndex then
  begin
   fImageIndex:= Value;
   Change;
  end;
end;

procedure TElementImage.SetPosition(const Value: TImagePosition);
begin
 if fPosition <> Value then
  begin
   fPosition:= Value;
   Change;
  end;
end;

{ TElementTheme }

Constructor TElementTheme.Create;
begin
 Inherited Create;
 fThemeIndex:= -1;
 fPartID:= 1;
 fStateID:= 1;
end;

procedure TElementTheme.SetThemeID(const Index, Value: Integer);
begin
 case Index of
   0: fPartID:= Value;
   1: fStateID:= Value;
 end;
 Change;
end;

procedure TElementTheme.SetThemeIndex(const Value: Integer);
begin
 if fThemeIndex <> Value then
  begin
   fThemeIndex := Value;
   Change;
  end;
end;

{ TElementText }

Constructor TElementText.Create;
begin
 Inherited Create;
 fText:= '';
 fAlignment:= taCenter;
 FLayout:= tlCenter;
 fWordWrap:= False;
 fDrawGlow:= False;
end;

function TElementText.GetTextFormat: DWORD;
begin
 Result:= 0;
 if FWordWrap then
  Result:= Result or DT_WORDBREAK
 else
  Result:= Result or DT_SINGLELINE;
 case FLayout of
   tlTop   : Result:= Result or DT_TOP;
   tlCenter: Result:= Result or DT_VCenter;
   tlBottom: Result:= Result or DT_Bottom;
 end;
 case FAlignment of
   taLeftJustify : Result:= Result or DT_LEFT;
   taRightJustify: Result:= Result or DT_RIGHT;
   taCenter      : Result:= Result or DT_Center;
 end;
end;

procedure TElementText.SetAlignment(const Value: TAlignment);
begin
 if fAlignment <> Value then
  begin
   fAlignment:= Value;
   Change;
  end;
end;

procedure TElementText.SetDrawGlow(const Value: BooLean);
begin
 if fDrawGlow <> Value then
  begin
   fDrawGlow:= Value;
   Change;
  end;
end;

procedure TElementText.SetFontIndex(const Value: Integer);
begin
 if fFontIndex <> Value then
  begin
   fFontIndex:= Value;
   Change;
  end;
end;

procedure TElementText.SetLayout(const Value: TTextLayout);
begin
 if FLayout <> Value then
  begin
   FLayout:= Value;
   Change;
  end;
end;

procedure TElementText.SetText(const Value: String);
begin
 if fText <> Value then
  begin
   fText:= Value;
   Change;
  end;
end;

procedure TElementText.SetWordWrap(const Value: Boolean);
begin
 if fWordWrap <> Value then
  begin
   fWordWrap:= Value;
   Change;
  end;
end;

{ TAeroAnimationComposition }

Constructor TAeroAnimationComposition.Create(AOwner: TComponent);
begin
 Inherited Create(AOwner);
 fFontCollection:= TAeroFontCollection.Create(Self);
 fThemeCollection:= TAeroThemeCollection.Create(Self);
 fImageCollection:= TAeroImageCollection.Create(Self);
 fItems:= TAnimationCompositionCollection.Create(Self);
end;

Destructor TAeroAnimationComposition.Destroy;
begin
 fItems.Free;
 fThemeCollection.Free;
 fFontCollection.Free;
 ImageCollection.Free;
 Inherited Destroy;
end;

procedure TAeroAnimationComposition.SetCurrentItem(const Value: Integer);
begin
 NewAniState:= Value;
 Invalidate;
end;

procedure TAeroAnimationComposition.SetFontCollection(const Value: TAeroFontCollection);
begin
 fFontCollection.Assign(Value);
end;

procedure TAeroAnimationComposition.SetImageCollection(const Value: TAeroImageCollection);
begin
 fImageCollection.Assign(Value);
end;

procedure TAeroAnimationComposition.SetItems(const Value: TAnimationCompositionCollection);
begin
 fItems.Assign(Value);
end;

procedure TAeroAnimationComposition.SetThemeCollection(const Value: TAeroThemeCollection);
begin
 fThemeCollection.Assign(Value);
end;

function TAeroAnimationComposition.GetCurrentItem: Integer;
begin
 Result:= NewAniState;
end;

function TAeroAnimationComposition.GetRenderState: TARenderConfig;
begin
 Result:= [];
end;

function TAeroAnimationComposition.GetThemeClassName: PWideChar;
begin
 Result:= VSCLASS_WINDOW;
end;

procedure TAeroAnimationComposition.PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer);
begin
 // nothing here
end;

function TAeroAnimationComposition.AddFont: TFontCollectionItem;
begin
 Result:= FontCollection.Add;
end;

function TAeroAnimationComposition.AddImage: TImageCollectionItem;
begin
 Result:= ImageCollection.Add;
end;

function TAeroAnimationComposition.AddTheme: TThemeCollectionItem;
begin
 Result:= ThemeCollection.Add;
end;

procedure TAeroAnimationComposition.ClassicRender(const ACanvas: TCanvas; const DrawState: Integer);
var
 I: Integer;
 Item: TCompositionAnimationElement;
begin
 if (fItems.Count > 0) and InRange(DrawState,0,fItems.Count-1) then
  begin
   Item:= fItems[DrawState];
   for I:=0 to Item.Composition.Count-1 do
    Item.Composition[I].RenderItem(ACanvas.Handle,True);
  end;
end;

procedure TAeroAnimationComposition.RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer);
var
 I: Integer;
 Item: TCompositionAnimationElement;
begin
 if (fItems.Count > 0) and InRange(DrawState,0,fItems.Count-1) then
  begin
   Item:= fItems[DrawState];
   for I:=0 to Item.Composition.Count-1 do
    Item.Composition[I].RenderItem(PaintDC);
  end;
end;

{ TCompositionAnimationElement }

Constructor TCompositionAnimationElement.Create(Collection: TCollection);
begin
 Inherited Create(Collection);
 fComposition:= TCompositionCollection.Create(TAnimationCompositionCollection(Collection).Owner);
end;

Destructor TCompositionAnimationElement.Destroy;
begin
 fComposition.Free;
 Inherited Destroy;
end;

procedure TCompositionAnimationElement.SetComposition(const Value: TCompositionCollection);
begin
 fComposition.Assign(Value);
end;

{ TAnimationCompositionCollection }

Constructor TAnimationCompositionCollection.Create(AOwner: TAeroAnimationComposition);
begin
 Inherited Create(AOwner,TCompositionAnimationElement);
end;

function TAnimationCompositionCollection.Add: TCompositionAnimationElement;
begin
 Result:= TCompositionAnimationElement(Inherited Add);
end;

function TAnimationCompositionCollection.GetItem(Index: Integer): TCompositionAnimationElement;
begin
 Result:= TCompositionAnimationElement(Inherited GetItem(Index));
end;

procedure TAnimationCompositionCollection.SetItem(Index: Integer;const Value: TCompositionAnimationElement);
begin
 Inherited SetItem(Index, Value);
end;

end.
