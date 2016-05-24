{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.ListBox;

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
  SysUtils, Windows, Messages, Classes, Controls, Graphics, CommCtrl,
  Themes, UxTheme, DwmApi, PNGImage, StdCtrls, Winapi.GDIPOBJ,
  {$ENDIF}
  NTS.Code.Common.Types,
  UI.Aero.Core.BaseControl,
  UI.Aero.Core.Images,
  UI.Aero.Core.CustomControl.Animation,
  UI.Aero.Globals,
  UI.Aero.Core;


type
  TAeroListItem = Class;
  TAeroItems = Class;
  TBaseAeroListBox = Class;

  TAeroListItem = class(TCollectionItem)
  Private
    ItemRect: TRect;
    AParent: TBaseAeroListBox;
    fText: String;
    fImage: TImageFileName;
    fData: Integer;
    fsTag: String;
    fTag: Integer;
    procedure SetImage(const Value: TImageFileName);
    Function GetDrawState: Integer;
  Protected
    ImageData: TBitmap;
    procedure DrawItem(const PaintDC: hDC; X,Y: Integer);
    procedure PaintItem(const ACanvas: TCanvas; X,Y: Integer);
  public
    Constructor Create(Collection: TCollection); override;
    Destructor Destroy; override;
  Published
    property Text: String Read fText Write fText;
    property Image: TImageFileName Read fImage Write SetImage;
    property Data: Integer Read fData Write fData;
    property Tag: Integer  Read fTag Write fTag;
    property sTag: String  Read fsTag Write fsTag;
  end;

  TAeroItems = Class(TCollection)
  private
    FOwner: TBaseAeroListBox;
    function GetItem(Index: Integer): TAeroListItem;
    procedure SetItem(Index: Integer; const Value: TAeroListItem);
  Public
    function Add: TAeroListItem;
    Function Owner: TBaseAeroListBox;
    Constructor Create(AOwner: TBaseAeroListBox); Virtual;
    Property Items[Index: Integer]: TAeroListItem read GetItem write SetItem; default;
  End;

  TItemChangeEvent = procedure(Sender: TBaseAeroListBox; AItemIndex: Integer) of object;

  TBaseAeroListBox = Class(TCustomAeroControlWithAnimation)
  private
    fBackGround: BooLean;
    fTextGlow: BooLean;
    fItemWidth,
    fItemHeight,
    fItemsInWidth,
    fItemsInHeight,
    fItemsOnPage,
    WidthSpaseSize,
    HeightSpaseSize,
    fCurrentPage,
    fHightLightItem,
    fItemIndex,
    fDownItem,
    fPageCount: Integer;
    fOnItemDblClick: TItemChangeEvent;
    fOnItemChange: TItemChangeEvent;
    fOnCalculatePages: TNotifyEvent;
    fItems: TAeroItems;
    fHightLightCursor,
    fNoramlCursor: TCursor;
    procedure SetItems(const Value: TAeroItems);
    procedure SetItemSize(const Index, Value: Integer);
    procedure SetCurrentPage(const Value: Integer);
    procedure SetItemIndex(const Value: Integer);
    procedure SetBackGround(const Value: BooLean);
    procedure SetTextGlow(const Value: BooLean);
  protected
    procedure CalculatePages;
    function GetThemeClassName: PWideChar; override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure Click; override;
    procedure DblClick; override;
    procedure Resize; override;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
  public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
  published
    property TabStop Default True;
    property Items: TAeroItems Read fItems Write SetItems;
    property ItemWidth: Integer Index 0 Read fItemWidth Write SetItemSize Default 154;
    property ItemHeight: Integer Index 1 Read fItemHeight Write SetItemSize Default 108;
    property ItemsOnPage: Integer Read fItemsOnPage;
    property CurrentPage: Integer Read fCurrentPage Write SetCurrentPage Default 0;
    property HightLightItem: Integer Read fHightLightItem;
    property ItemIndex: Integer Read fItemIndex Write SetItemIndex Default -1;
    property Pages: Integer Read fPageCount;
    property BackGround: BooLean Read fBackGround Write SetBackGround Default False;
    property TextGlow: BooLean Read fTextGlow Write SetTextGlow Default False;
    property HightLightCursor: TCursor Read fHightLightCursor Write fHightLightCursor Default crDefault;
    Property OnItemChange: TItemChangeEvent Read fOnItemChange Write fOnItemChange;
    Property OnItemDblClick: TItemChangeEvent Read fOnItemDblClick Write fOnItemDblClick;
    Property OnCalculatePages: TNotifyEvent Read fOnCalculatePages Write fOnCalculatePages;  
  end;

  TAeroListBox = Class(TBaseAeroListBox)
  protected
    function GetRenderState: TARenderConfig; OverRide;
    procedure RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer); OverRide;
    procedure ClassicRender(const ACanvas: TCanvas; const DrawState: Integer); OverRide;
    procedure DrawPage(const PaintDC: hDC;const APageIndex: Integer);
    procedure PaintPage(const ACanvas: TCanvas;const APageIndex: Integer);
    procedure PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer); override;
  end;

implementation

Uses
  UI.Aero.Window;

{ TAeroListItem }

Constructor TAeroListItem.Create(Collection: TCollection);
begin
 Inherited Create(Collection);
 AParent:= TAeroItems(Collection).Owner;
 ItemRect:= Rect(0,0,0,0);
 fText:= 'Item '+IntToStr(Index);
 ImageData:= nil;
 fData:= 0;
 fTag:= 0;
 fsTag:= '';
end;

Destructor TAeroListItem.Destroy;
begin
 if Assigned(ImageData) then
  ImageData.Free;
 Inherited Destroy;
end;

function TAeroListItem.GetDrawState: Integer;

  function Get_LISS_HOTSELECTED: Integer;
  begin
   if TAeroWindow.RunWindowsVista then
    Result:= LISS_HOTSELECTED
   else
    Result:= LIS_HOT;
  end;

begin
 if AParent.ItemIndex = Index then
  begin
   if AParent.HightLightItem = Index then
    Result:= Get_LISS_HOTSELECTED
   else
    if AParent.Focused then
     Result:= LIS_SELECTED
    else
     Result:= LIS_SELECTEDNOTFOCUS;
  end
 else
  if AParent.HightLightItem = Index then
   Result:= LIS_HOT
  else
   Result:= LIS_NORMAL;
end;

procedure TAeroListItem.DrawItem(const PaintDC: hDC; X, Y: Integer);
var
 fState: Integer;

  procedure DrawItemText;
  Const
    TextFormat = (DT_SINGLELINE or DT_VCENTER or DT_CENTER);
  var
   TextRect: TRect;
  begin
   TextRect:= ItemRect;
   if Assigned(ImageData) then TextRect.Top:= TextRect.Top+ImageData.Height+4;
   AeroCore.RenderText(PaintDC,AParent.ThemeData,LVP_LISTITEM,fState,AParent.Font,TextFormat,TextRect,fText,AParent.TextGlow);
  end;

  procedure DrawImage;
  var
   ImgPos: TPoint;
  begin
   ImgPos.Y:= Y+2;
   ImgPos.X:= X+( (AParent.ItemWidth div 2)-(ImageData.Width div 2) );
   AeroPicture.Draw(PaintDC,ImageData,ImgPos);
  end;

begin
 ItemRect:= Bounds(X,Y,AParent.ItemWidth,AParent.ItemHeight);
 fState:= GetDrawState;
 if fState <> LIS_NORMAL then
  DrawThemeBackground(AParent.ThemeData,PaintDC,LVP_LISTITEM,fState,ItemRect,@ItemRect);
 if Assigned(ImageData) then DrawImage;
 if fText <> '' then DrawItemText;
end;

procedure TAeroListItem.PaintItem(const ACanvas: TCanvas; X, Y: Integer);
var
 fState: Integer;

  procedure SetPaintColor(APen,ABrush: TColor);
  begin
   ACanvas.Pen.Color:= APen;
   ACanvas.Brush.Color:= ABrush;
   ACanvas.Rectangle(ItemRect);
  end;

  procedure DrawImage;
  var
   ImgPos: TPoint;
  begin
   ImgPos.Y:= Y+2;
   ImgPos.X:= X+( (AParent.ItemWidth div 2)-(ImageData.Width div 2) );
   AeroPicture.Draw(ACanvas.Handle,ImageData,ImgPos);
  end;

  procedure DrawItemText;
  Const
    TextFormat = (DT_SINGLELINE or DT_VCENTER or DT_CENTER);
  var
   TextRect: TRect;
  begin
   TextRect:= ItemRect;
   if Assigned(ImageData) then TextRect.Top:= TextRect.Top+ImageData.Height+4;
   AeroCore.RenderText(ACanvas.Handle,AParent.Font,TextFormat,TextRect,fText);
  end;

begin
 ItemRect:= Bounds(X,Y,AParent.ItemWidth,AParent.ItemHeight);
 fState:= GetDrawState;
 case fState of
//   LIS_NORMAL: SetPaintColor(clWindow,clWindow);
   LIS_HOT,
   LISS_HOTSELECTED: SetPaintColor(clHighlight,clWindow);
   LIS_SELECTED,
   LIS_SELECTEDNOTFOCUS: SetPaintColor(clActiveBorder,clWindow);
 end;
 if Assigned(ImageData) then DrawImage;
 if fText <> '' then DrawItemText;
end;

procedure TAeroListItem.SetImage(const Value: TImageFileName);
begin
 if fImage <> Value then
  begin
   fImage:= Value;
   if Assigned(ImageData) then
    ImageData.Free;
   ImageData:= AeroPicture.LoadImage(fImage);
  end;
end;


{ TAeroItems }

function TAeroItems.Add: TAeroListItem;
begin
 Result:= TAeroListItem(Inherited Add);
end;

Constructor TAeroItems.Create(AOwner: TBaseAeroListBox);
begin
 Inherited Create(TAeroListItem);
 FOwner:= AOwner;
end;

function TAeroItems.GetItem(Index: Integer): TAeroListItem;
begin
 Result:= TAeroListItem(Inherited GetItem(Index));
end;

function TAeroItems.Owner: TBaseAeroListBox;
begin
 Result:= FOwner;
end;

procedure TAeroItems.SetItem(Index: Integer; const Value: TAeroListItem);
begin
 Inherited SetItem(Index, Value);
end;

{ TBaseAeroListBox }

Constructor TBaseAeroListBox.Create(AOwner: TComponent);
begin
 Inherited Create(AOwner);
 fItems:= TAeroItems.Create(Self);
 fItemWidth:= 154;
 fItemHeight:= 108;
 fCurrentPage:= 0;
 fHightLightItem:= -1;
 fItemIndex:= -1;
 fDownItem:= -1;
 fPageCount:= 0;
 fOnItemChange:= nil;
 fOnItemDblClick:= nil;
 fOnCalculatePages:= nil;
 fBackGround:= False;
 fTextGlow:= False;
 fHightLightCursor:= crDefault;
 fNoramlCursor:= Cursor;
end;

Destructor TBaseAeroListBox.Destroy;
begin
 fItems.Free;
 Inherited Destroy;
end;

function TBaseAeroListBox.GetThemeClassName: PWideChar;
begin
 if TAeroWindow.RunWindowsVista then
  Result:= 'Explorer::ListView'
 else
  Result:= 'ListView';
end;

procedure TBaseAeroListBox.Click;
begin
 Inherited Click;
 SetFocus;
end;

procedure TBaseAeroListBox.CMEnabledChanged(var Message: TMessage);
begin
 Inherited;
 Invalidate;
end;

procedure TBaseAeroListBox.DblClick;
begin
 Inherited DblClick;
 if fHightLightItem <> -1 then
  begin
   if Assigned(fOnItemDblClick) then
    fOnItemDblClick(Self,fHightLightItem);
  end;
end;

procedure TBaseAeroListBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 Inherited MouseDown(Button,Shift,X,Y);
 if (Button = mbLeft) and (fHightLightItem <> -1) then
  fDownItem:= fHightLightItem;
end;

procedure TBaseAeroListBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
 IndexValue, ItIndex, ItemsOnLine, OldHightLightItem,
 ItemX, ItemY: Integer;
begin
 Inherited MouseMove(Shift,0,0);
 if Items.Count > 0 then
  begin
   IndexValue:= (fCurrentPage*fItemsOnPage);
   ItemX:= WidthSpaseSize;
   ItemY:= HeightSpaseSize;
   ItemsOnLine:= 0;
   OldHightLightItem:= fHightLightItem;
   fHightLightItem:= -1;
   for ItIndex:=IndexValue to IndexValue+fItemsOnPage do
    if ItIndex = Items.Count then
     Break
    else
     begin
      if PtInRect(Items.Items[ItIndex].ItemRect,Point(X,Y)) then
       begin
        fHightLightItem:= ItIndex;
        Break;
       end;
     //
      ItemX:= ItemX+ItemWidth+WidthSpaseSize;
      Inc(ItemsOnLine);
      if ItemsOnLine = fItemsInWidth then
       begin
        ItemsOnLine:= 0;
        ItemX:= WidthSpaseSize;
        ItemY:= ItemY+ItemHeight+HeightSpaseSize;
       end;
     end;
   if OldHightLightItem <> fHightLightItem then
    Invalidate;
  end;
// For Temp... Leter
 if fHightLightItem = -1 then
  Cursor:= fNoramlCursor
 else
  if Cursor <> HightLightCursor then
   begin
    fNoramlCursor:= Cursor;
    Cursor:= HightLightCursor;
   end;
end;

procedure TBaseAeroListBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 Inherited MouseUp(Button,Shift,X,Y);
 if (Button = mbLeft) and (fHightLightItem = fDownItem) then
  begin
   fDownItem:= -1;
   if fHightLightItem <> -1 then
    ItemIndex:= fHightLightItem;
  end;
end;

procedure TBaseAeroListBox.Resize;
begin
 Inherited Resize;
 CalculatePages;
 Invalidate;
end;

procedure TBaseAeroListBox.SetBackGround(const Value: BooLean);
begin
 if fBackGround <> Value then
  begin
   fBackGround:= Value;
   Invalidate;
  end;
end;

procedure TBaseAeroListBox.SetCurrentPage(const Value: Integer);
begin
 if fCurrentPage <> Value then
  begin
   if Value >= fPageCount+1 then
    fCurrentPage:= fPageCount
   else
    fCurrentPage:= Value;
   NewAniState:= fCurrentPage;
   Invalidate;
  end;
end;

procedure TBaseAeroListBox.SetItemIndex(const Value: Integer);
begin
 if fItemIndex <> Value then
  begin
   fItemIndex:= Value;
   Invalidate;
   if Assigned(fOnItemChange) then
    fOnItemChange(Self,Value);
  end;
end;

procedure TBaseAeroListBox.SetItems(const Value: TAeroItems);
begin
 fItems.Assign(Value);
 Invalidate;
end;

procedure TBaseAeroListBox.SetItemSize(const Index, Value: Integer);
begin
 case Index of
   0: fItemWidth:= Value;
   1: fItemHeight:= Value;
 end;
 CalculatePages;
 Invalidate;
end;

procedure TBaseAeroListBox.SetTextGlow(const Value: BooLean);
begin
 if fTextGlow <> Value then
  begin
   fTextGlow:= Value;
   Invalidate;
  end;
end;

procedure TBaseAeroListBox.CalculatePages;
var
 FreeInWidth,
 FreeInHeight: Integer;
begin
 fItemsInWidth:= Width div fItemWidth;
 fItemsInHeight:= Height div fItemHeight;
 FreeInWidth:= Width-(fItemsInWidth*fItemWidth);
 FreeInHeight:= Height-(fItemsInHeight*fItemHeight);
 WidthSpaseSize:= FreeInWidth div (fItemsInWidth+1);
 HeightSpaseSize:= FreeInHeight div (fItemsInHeight+1);
 if WidthSpaseSize < 4 then
  begin
   Dec(fItemsInWidth);
   FreeInWidth:= Width-(fItemsInWidth*fItemWidth);
   WidthSpaseSize:= FreeInWidth div (fItemsInWidth+1);
  end;
 if HeightSpaseSize < 4 then
  begin
   Dec(fItemsInHeight);
   FreeInHeight:= Height-(fItemsInHeight*fItemHeight);
   HeightSpaseSize:= FreeInHeight div (fItemsInHeight+1);
  end;
 fItemsOnPage:= fItemsInWidth*fItemsInHeight;
 if (Items.Count = 0) or (fItemsOnPage = 0) then
  fPageCount:= 0
 else
  fPageCount:= Items.Count div fItemsOnPage;
 if Assigned(fOnCalculatePages) then
  fOnCalculatePages(Self);
end;

{ TAeroListBox }

function TAeroListBox.GetRenderState: TARenderConfig;
begin
 Result:= [];
end;

procedure TAeroListBox.RenderState(const PaintDC: hDC; var Surface: TGPGraphics; var RConfig: TARenderConfig; const DrawState: Integer);
var
 bgRect: TRect;
begin
 if fBackGround then
  begin
   bgRect:= GetClientRect;
   DrawThemeBackground(ThemeData,PaintDC,LVP_LISTITEM,LIS_NORMAL,bgRect,@bgRect);
  end;
 if Items.Count > 0 then
  DrawPage(PaintDC,DrawState);
end;

procedure TAeroListBox.ClassicRender(const ACanvas: TCanvas; const DrawState: Integer);
begin
 ACanvas.Font.Assign(Self.Font);
 ACanvas.Brush.Color:= clWindow;
 ACanvas.Pen.Color:= clWindowFrame;
 ACanvas.Rectangle(GetClientRect);
 if Items.Count > 0 then
  PaintPage(ACanvas,DrawState);
end;

procedure TAeroListBox.PaintPage(const ACanvas: TCanvas; const APageIndex: Integer);
var
 ItIndex,IndexValue, ItemsOnLine,
 DrawX, DrawY: Integer;
begin
 IndexValue:= (APageIndex*fItemsOnPage);
 DrawX:= WidthSpaseSize;
 DrawY:= HeightSpaseSize;
 ItemsOnLine:= 0;
 for ItIndex:= 0 to Items.Count-1 do
  Items.Items[ItIndex].ItemRect:= Bounds(-5,-5,1,1);
 for ItIndex:=IndexValue to IndexValue+(fItemsOnPage-1) do
  if ItIndex >= Items.Count then
   Break
  else
   begin
    Items.Items[ItIndex].PaintItem(ACanvas,DrawX,DrawY);
    DrawX:= DrawX+ItemWidth+WidthSpaseSize;
    Inc(ItemsOnLine);
    if ItemsOnLine = fItemsInWidth then
     begin
      ItemsOnLine:= 0;
      DrawX:= WidthSpaseSize;
      DrawY:= DrawY+ItemHeight+HeightSpaseSize;
     end;
   end;
end;

procedure TAeroListBox.PostRender(const Surface: TCanvas; const RConfig: TARenderConfig; const DrawState: Integer);
begin

end;

procedure TAeroListBox.DrawPage(const PaintDC: hDC; const APageIndex: Integer);
var
 ItIndex,IndexValue, ItemsOnLine,
 DrawX, DrawY: Integer;
begin
 SelectObject(PaintDC,Self.Font.Handle);
 IndexValue:= (APageIndex*fItemsOnPage);
 DrawX:= WidthSpaseSize;
 DrawY:= HeightSpaseSize;
 ItemsOnLine:= 0;
 for ItIndex:= 0 to Items.Count-1 do
  Items.Items[ItIndex].ItemRect:= Bounds(-5,-5,1,1);
 for ItIndex:=IndexValue to IndexValue+(fItemsOnPage-1) do
  if ItIndex >= Items.Count then
   Break
  else
   begin
    Items.Items[ItIndex].DrawItem(PaintDC,DrawX,DrawY);
    DrawX:= DrawX+ItemWidth+WidthSpaseSize;
    Inc(ItemsOnLine);
    if ItemsOnLine = fItemsInWidth then
     begin
      ItemsOnLine:= 0;
      DrawX:= WidthSpaseSize;
      DrawY:= DrawY+ItemHeight+HeightSpaseSize;
     end;
   end;
end;

end.
