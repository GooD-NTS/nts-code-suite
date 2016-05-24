{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.ColorHost;

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
  Winapi.GDIPAPI,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.ExtCtrls,
  {$ELSE}
  Windows, SysUtils, Messages, Classes, Controls, Graphics,
  Winapi.GDIPOBJ, Winapi.GDIPAPI, UxTheme, ExtCtrls,
  {$ENDIF}
  UI.Aero.Globals,
  UI.Aero.Core,
  UI.Aero.Core.CustomControl,
  UI.Aero.Core.Images;
  
type
  TAeroColorItem = Class;
  TAeroColorCollection = Class;
  TCutomColorHost = Class;
  TAeroColorHost = Class;

  TAeroColorItem = Class(TCollectionItem)
  private
    fName: TCaption;
    fData: TGPColor;
    procedure SetData(const Value: TGPColor);
    procedure SetName(const Value: TCaption);
    function GetSelected: BooLean;
    function GetHover: BooLean;
    function GetMarked: BooLean;
  Public
    Constructor Create(Collection: TCollection); OverRide;
    function GetState: Integer;
  Published
    Property Data: TGPColor Read fData Write SetData Default 0;
    Property Name: TCaption Read fName Write SetName;
    Property Selected: BooLean Read GetSelected;
    Property Hover: BooLean Read GetHover;
    Property Marked: BooLean Read GetMarked;
  End;

  TAeroColorCollection = Class(TCollection)
  const
    ItemWidth = 72;
  private
    fOwner: TCutomColorHost;
    fItemIndex: Integer;
    fHoverIndex: Integer;
    fLeft: Integer;
    fWidth: Integer;
    fMarkedIndex: Integer;
    function GetItem(Index: Integer): TAeroColorItem;
    procedure SetItem(Index: Integer; const Value: TAeroColorItem);
    procedure SetItemIndex(const Value: Integer);
    procedure SetHoverIndex(const Value: Integer);
    procedure SetLeft(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    procedure SetMarkedIndex(const Value: Integer);
  Public
    Constructor Create(AOwner: TCutomColorHost);
    Destructor Destroy; override;
    Function Owner: TCutomColorHost;
    Function Add: TAeroColorItem;
    procedure CalculateWidth;
    procedure CalculateLeft;
  Public
    Property Left: Integer Read fLeft Write SetLeft;
    Property Width: Integer Read fWidth Write SetWidth;
    Property ItemIndex: Integer Read fItemIndex Write SetItemIndex default -1;
    Property HoverIndex: Integer Read fHoverIndex Write SetHoverIndex default -1;
    Property MarkedIndex: Integer Read fMarkedIndex Write SetMarkedIndex default -1; 
    Property Items[Index: Integer]: TAeroColorItem read GetItem write SetItem; default;
  End;

  TCutomColorHost = Class(TCustomAeroControl)
  public class var AeroColorItemImage: String;
  private class constructor Create;
  private
    fItems: TAeroColorCollection;
    FrameImage: TBitmap;
    procedure SetItems(const Value: TAeroColorCollection);
    function GetHoverIndex: Integer;
    function GetItemIndex: Integer;
    function GetMarkedIndex: Integer;
    procedure SetItemIndex(const Value: Integer);
  Protected
    function GetRenderState: TRenderConfig; OverRide;
    function GetThemeClassName: PWideChar; override;
    procedure ValueChange(ValueType,Value: Integer); Virtual; Abstract;
  Public                                            
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
    function Selected: TAeroColorItem;
    function Hover: TAeroColorItem;
    function Marked: TAeroColorItem;                
  Published
    Property Items: TAeroColorCollection Read fItems Write SetItems;
    Property ItemIndex: Integer Read GetItemIndex Write SetItemIndex Default -1;
    Property HoverIndex: Integer Read GetHoverIndex;
    Property MarkedIndex: Integer Read GetMarkedIndex;
  End;

  TAeroColorEvent = procedure(Sender: TAeroColorHost;NewValue: TAeroColorItem) of Object;
  
  TAeroColorHost = class(TCutomColorHost)
  const
    TextFormat = (DT_CENTER or DT_VCENTER or DT_SINGLELINE);
  Private
    ScrollAction: Integer;
    ScrollWork: TTimer;
    fOnItemChange: TAeroColorEvent;
    fOnMarkedChange: TAeroColorEvent;
    fOnHoverChange: TAeroColorEvent;
  Protected
    procedure ClassicRender(const ACanvas: TCanvas); OverRide;
    procedure ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig); OverRide;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure CMMousEleave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure Click; override;
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
    procedure Resize; override;
    procedure ScrollTimer(Sender: TObject);
    procedure TestItems(X: Integer);
    procedure ValueChange(ValueType,Value: Integer); override;
    procedure PostRender(const Surface: TCanvas; const RConfig: TRenderConfig); override;
  Public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
    function IndexOf(ColorData: TGPColor): Integer;
    function AddColor: TAeroColorItem; OverLoad;
    function AddColor(AData: TGPColor): TAeroColorItem; OverLoad;
    function AddColor(AName: TCaption): TAeroColorItem; OverLoad;
    function AddColor(AName: TCaption;AData: TGPColor): TAeroColorItem; OverLoad;
    procedure DeleteColor(AIndex: Integer);
  Published
    property Caption;
    property OnItemChange: TAeroColorEvent Read fOnItemChange Write fOnItemChange;
    property OnHoverChange: TAeroColorEvent Read fOnHoverChange Write fOnHoverChange;
    property OnMarkedChange: TAeroColorEvent Read fOnMarkedChange Write fOnMarkedChange; 
  end;

implementation

uses
  Math;

{ TAeroColorItem }

Constructor TAeroColorItem.Create(Collection: TCollection);
begin
 Inherited Create(Collection);
 fData:= MakeColor(Random(255),Random(255),Random(255),Random(255));//0;
 fName:= 'AeroColor'+IntToStr(Index);
end;

function TAeroColorItem.GetHover: BooLean;
begin
 Result:= (TAeroColorCollection(Collection).HoverIndex = Index);
end;

function TAeroColorItem.GetMarked: BooLean;
begin
 Result:= (TAeroColorCollection(Collection).MarkedIndex = Index);
end;

function TAeroColorItem.GetSelected: BooLean;
begin
 Result:= (TAeroColorCollection(Collection).ItemIndex = Index);
end;

function TAeroColorItem.GetState: Integer;
begin
 if Marked then
  Result:= LIS_SELECTEDNOTFOCUS
 else
  if Selected then
   begin
    if Hover then
     Result:= LISS_HOTSELECTED
    else
     Result:= LIS_SELECTED;
   end
  else
   begin
    if Hover then
     Result:= LIS_HOT
    else
     Result:= LIS_NORMAL;
   end;
end;

procedure TAeroColorItem.SetData(const Value: TGPColor);
begin
 if fData <> Value then
  begin
   fData:= Value;

  end;
end;

procedure TAeroColorItem.SetName(const Value: TCaption);
begin
 if fName <> Value then
  begin
   fName:= Value;

  end;
end;

{ TAeroColorCollection }

Constructor TAeroColorCollection.Create(AOwner: TCutomColorHost);
begin
 Inherited Create(TAeroColorItem);
 fOwner:= AOwner;
 fLeft:= 0;
 fWidth:= 0;
 fItemIndex:= -1;
 fHoverIndex:= -1;
 fMarkedIndex:= -1;
end;

Destructor TAeroColorCollection.Destroy;
begin

 Inherited Destroy;
end;

function TAeroColorCollection.Owner: TCutomColorHost;
begin
 Result:= fOwner;
end;

function TAeroColorCollection.Add: TAeroColorItem;
begin
 Result:= TAeroColorItem(inherited Add);
 CalculateWidth;
 CalculateLeft;
end;

function TAeroColorCollection.GetItem(Index: Integer): TAeroColorItem;
begin
 Result:= TAeroColorItem(inherited GetItem(Index));
end;

procedure TAeroColorCollection.SetHoverIndex(const Value: Integer);
begin
 if fHoverIndex <> Value then
  begin
   if InRange(Value,-1,Count-1) then
    fHoverIndex:= Value
   else
    fHoverIndex:= -1;
   Owner.Invalidate;
   Owner.ValueChange(1,fHoverIndex);
  end;
end;

procedure TAeroColorCollection.SetItemIndex(const Value: Integer);
begin
 if fItemIndex <> Value then
  begin
   if InRange(Value,-1,Count-1) then
    fItemIndex:= Value
   else
    fItemIndex:= -1;
   Owner.Invalidate;
   Owner.ValueChange(0,fItemIndex);
  end;
end;

procedure TAeroColorCollection.SetItem(Index: Integer; const Value: TAeroColorItem);
begin
 Inherited SetItem(Index, Value);
 CalculateWidth;
 CalculateLeft;
end;

procedure TAeroColorCollection.SetLeft(const Value: Integer);
begin
 if fLeft <> Value then
  begin
   fLeft:= Value;
   Owner.Invalidate;
  end;
end;

procedure TAeroColorCollection.SetMarkedIndex(const Value: Integer);
begin
 if fMarkedIndex <> Value then
  begin
   if InRange(Value,-1,Count-1) then
    fMarkedIndex:= Value
   else
    fMarkedIndex:= -1;
   Owner.Invalidate;
   Owner.ValueChange(2,fMarkedIndex);
  end;
end;

procedure TAeroColorCollection.SetWidth(const Value: Integer);
begin
 if fWidth <> Value then
  begin
   fWidth:= Value;
   Owner.Invalidate;
  end;
end;

procedure TAeroColorCollection.CalculateWidth;
begin
 if Self.Count = 0 then
  Width:= 0
 else
  Width:= ItemWidth*Self.Count;
end;

procedure TAeroColorCollection.CalculateLeft;
begin
 if Self.Count = 0 then
  Left:= 0
 else
  Left:= (Owner.Width div 2) - (Self.Width div 2);
end;

{ TCutomColorHost }

class constructor TCutomColorHost.Create;
begin
  if Assigned(RegisterComponentsProc) then
    TCutomColorHost.AeroColorItemImage:=  GetEnvironmentVariable('NTS_LIB_ROOT')+'\NTS UI Aero\Resources\Images\ColorFrame.png'
  else
    TCutomColorHost.AeroColorItemImage:= '???ERROR_PATH***';
end;

Constructor TCutomColorHost.Create(AOwner: TComponent);
begin
 Inherited Create(AOwner);
 fItems:= TAeroColorCollection.Create(Self);
 FrameImage:= AeroPicture.LoadImage(AeroColorItemImage);
end;

Destructor TCutomColorHost.Destroy;
begin
 FrameImage.Free;
 fItems.Free;
 Inherited Destroy;
end;

function TCutomColorHost.GetHoverIndex: Integer;
begin
 Result:= Items.HoverIndex;
end;

function TCutomColorHost.GetItemIndex: Integer;
begin
 Result:= Items.ItemIndex;
end;

function TCutomColorHost.GetMarkedIndex: Integer;
begin
 Result:= Items.MarkedIndex;
end;

function TCutomColorHost.GetRenderState: TRenderConfig;
begin
 Result:= [rsBuffer,rsGDIP];
end;

function TCutomColorHost.GetThemeClassName: PWideChar;
begin                        
 if AeroCore.RunWindowsVista then
  Result:= 'Explorer::ListView'
 else
  Result:= VSCLASS_LISTVIEW;
end;

function TCutomColorHost.Hover: TAeroColorItem;
begin
 if HoverIndex = -1 then
  Result:= nil
 else
  Result:= Items[HoverIndex];
end;

function TCutomColorHost.Marked: TAeroColorItem;
begin
 if MarkedIndex = -1 then
  Result:= nil
 else
  Result:= Items[MarkedIndex];
end;

function TCutomColorHost.Selected: TAeroColorItem;
begin
 if ItemIndex = -1 then
  Result:= nil
 else
  Result:= Items[ItemIndex];
end;

procedure TCutomColorHost.SetItemIndex(const Value: Integer);
begin
 Items.ItemIndex:= Value;
end;

procedure TCutomColorHost.SetItems(const Value: TAeroColorCollection);
begin
 fItems.Assign(Value);
end;

{ TAeroColorHost }

Constructor TAeroColorHost.Create(AOwner: TComponent);
begin
 Inherited Create(AOwner);
 fOnItemChange:= nil;
 fOnMarkedChange:= nil;
 fOnHoverChange:= nil;
 Randomize;
 ScrollAction:= 0;          
 ScrollWork:= TTimer.Create(Self);
 ScrollWork.Enabled:= False;
 ScrollWork.Interval:= 1;
 ScrollWork.OnTimer:= ScrollTimer;
end;

procedure TAeroColorHost.DeleteColor(AIndex: Integer);
begin
 if InRange(AIndex,0,Items.Count-1) then
  begin
   if ItemIndex = AIndex then
    ItemIndex:= -1;
   Items.Delete(AIndex);
   Items.CalculateWidth;
   Items.CalculateLeft;
  end;
end;

Destructor TAeroColorHost.Destroy;
begin
 ScrollWork.Enabled:= False;
 ScrollWork.Free;
 Inherited Destroy;
end;

function TAeroColorHost.IndexOf(ColorData: TGPColor): Integer;
var
 I: Integer;
begin
 Result:= -1;
 for I:=0 to Items.Count-1 do
  if Items[I].Data = ColorData then
   begin
    Result:= I;
    Break;
   end;
end;

procedure TAeroColorHost.Click;
begin
 Inherited Click;
 if Items.HoverIndex <> -1 then
  Items.ItemIndex:= Items.HoverIndex;
end;

procedure TAeroColorHost.CMMousEleave(var Message: TMessage);
begin
 Inherited;
 Items.HoverIndex:= -1;
 ScrollWork.Enabled:= False;
end;

procedure TAeroColorHost.MouseMove(Shift: TShiftState; X, Y: Integer);
var
 Test: Integer;
begin
 Inherited MouseMove(Shift,X,Y);
 TestItems(X);
 if Items.Width > Self.Width then
  begin
   ScrollWork.Enabled:= True;
   Test:= Self.Width div 3;
{
   if (X > (Self.Width div 2)) then
    ScrollAction:= -1
   else
    ScrollAction:= +1;
}
   if InRange(X,0,Test) then
    ScrollAction:= +3
   else
    if InRange(X,Test+Test,Width) then
     ScrollAction:= -3
    else
     ScrollAction:= 0;
  end
 else
  ScrollWork.Enabled:= False;
end;

procedure TAeroColorHost.PostRender(const Surface: TCanvas; const RConfig: TRenderConfig);
begin

end;

procedure TAeroColorHost.Resize;
begin
 Inherited Resize;
 Items.CalculateWidth;
 Items.CalculateLeft;
end;

procedure TAeroColorHost.ScrollTimer(Sender: TObject);
begin
 if (ScrollAction > 0) and (Items.Left <> 0) then
  begin
   Items.Left:= Items.Left+ScrollAction;
   if Items.Left > 0 then Items.Left:= 0;
   TestItems(ScreenToClient(Mouse.CursorPos).X);
  end;
 if (ScrollAction < 0) and (Items.Left <> -(Items.Width-Self.Width)) then
  begin
   Items.Left:= Items.Left+ScrollAction;
   if Items.Left < -(Items.Width-Self.Width) then
    Items.Left:= -(Items.Width-Self.Width);
   TestItems(ScreenToClient(Mouse.CursorPos).X);
  end;
end;

procedure TAeroColorHost.WMContextMenu(var Message: TWMContextMenu);
begin
 if Items.HoverIndex = -1 then
  Inherited
 else
  begin
   Items.MarkedIndex:= Items.HoverIndex;
   Inherited;
   Items.MarkedIndex:= -1;
  end;
end;

procedure TAeroColorHost.TestItems(X: Integer);
begin
 if InRange(X,Items.Left,Items.Left+Items.Width) then
  Items.HoverIndex:= ( (X-Items.Left) div Items.ItemWidth)
 else
  Items.HoverIndex:= -1;
end;

procedure TAeroColorHost.ClassicRender(const ACanvas: TCanvas);
begin

end;

procedure TAeroColorHost.ThemedRender(const PaintDC: hDC; const Surface: TGPGraphics; var RConfig: TRenderConfig);
var
 ItLeft,I,StateID: Integer;
 ItRect: TRect;
 Brush: TGPSolidBrush;
begin
 if Items.Count = 0 then
  begin
   ItRect:= GetClientRect;
   AeroCore.RenderText(PaintDC,ThemeData,LVP_LISTITEM,LIS_NORMAL,Self.Font,TextFormat,ItRect,Caption,false);
  end
 else
  begin
   ItLeft:= Items.Left;
   for I:=0 to Items.Count-1 do
    begin
     ItRect:= Rect(ItLeft,0,ItLeft+Items.ItemWidth,80);
     StateID:= Items[I].GetState;
     if StateID <> LIS_NORMAL then
      DrawThemeBackground(ThemeData,PaintDC,LVP_LISTITEM,StateID,ItRect,nil);
     //
      Brush:= TGPSolidBrush.Create(Items[I].Data);
      Surface.FillRectangle(Brush,MakeRect(ItLeft+13,9,46,46));
      Brush.Free;
     //
     AeroPicture.Draw(PaintDC,FrameImage,Point(ItLeft+4,0));
     ItRect.Top:= 64;
     AeroCore.RenderText(PaintDC,ThemeData,LVP_LISTITEM,StateID,Self.Font,TextFormat,ItRect,Items[I].Name,false);
     ItLeft:= ItLeft+Items.ItemWidth;
    end;
  end;
end;

procedure TAeroColorHost.ValueChange(ValueType,Value: Integer);
var
 nValue: TAeroColorItem;
begin
 if Value = -1 then
  nValue:= nil
 else
  nValue:= Items[Value];
 case ValueType of
   0: if Assigned(fOnItemChange) then fOnItemChange(Self,nValue);
   1: if Assigned(fOnHoverChange) then fOnHoverChange(Self,nValue);
   2: if Assigned(fOnMarkedChange) then fOnMarkedChange(Self,nValue);
 end;
end;

function TAeroColorHost.AddColor: TAeroColorItem;
begin
 Result:= Items.Add;
end;

function TAeroColorHost.AddColor(AData: TGPColor): TAeroColorItem;
begin
 Result:= Items.Add;
 Result.Data:= AData;
end;

function TAeroColorHost.AddColor(AName: TCaption): TAeroColorItem;
begin
 Result:= Items.Add;
 Result.Name:= AName;
end;

function TAeroColorHost.AddColor(AName: TCaption; AData: TGPColor): TAeroColorItem;
begin
 Result:= Items.Add;
 Result.Name:= AName;
 Result.Data:= AData;
end;


end.
