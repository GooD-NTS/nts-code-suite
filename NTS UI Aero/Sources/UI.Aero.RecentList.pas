{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit UI.Aero.RecentList;

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
  Vcl.Imaging.pngimage,
  {$ELSE}
  Windows, Messages, SysUtils, Classes, Controls, Graphics, Winapi.GDIPOBJ,
  Themes, UxTheme, PNGImage,
  {$ENDIF}
  NTS.Code.Common.Types,
  UI.Aero.Core.CustomControl,
  UI.Aero.Globals,
  UI.Aero.Core.BaseControl;

type
  TItemHoverState = (hsNone, hsFull, hsButton);
  TAeroRecentList = class;
  TRecentListCollection = class;

  TRecentListItem = class(TCollectionItem)
  private
    fFileName: String;
    fName: TCaption;
    fHover: TItemHoverState;
    fIsPin: BooLean;
    fEnabled: BooLean;
    procedure SetHover(const Value: TItemHoverState);
    procedure SetIsPin(const Value: BooLean);
    procedure SetName(const Value: TCaption);
    procedure SetEnabled(const Value: BooLean);
  Public
    Constructor Create(Collection: TCollection); OverRide;
    procedure Pin;
    procedure UnPin;
  Published
    Property Name: TCaption Read fName Write SetName;
    Property Hover: TItemHoverState Read fHover Write SetHover Default hsNone;
    Property FileName: String Read fFileName Write fFileName;
    Property IsPin: BooLean Read fIsPin Write SetIsPin;
    Property Enabled: BooLean Read fEnabled Write SetEnabled;
  end;

  TRecentListCollection = class(TCollection)
  Private
    fOwner: TAeroRecentList;
    function GetItem(Index: Integer): TRecentListItem;
    procedure SetItem(Index: Integer; const Value: TRecentListItem);
  Public
    Constructor Create(AOwner: TAeroRecentList); Virtual;
    Function Owner: TAeroRecentList;
    function Add: TRecentListItem; OverLoad;
    function Add(AFileName: String;AIsPin: Boolean = False): TRecentListItem; OverLoad;
    Property Items[Index: Integer]: TRecentListItem read GetItem write SetItem; default;
  end;

  TItemClickArea = ( caBody, caFolder, caPin );
  TItemClickEvent = procedure (Sender: TAeroRecentList; Index: Integer; ClickArea: TItemClickArea) of Object;

  TAeroRecentList = Class(TAeroBaseControl)
  public class var ImageFile_Pin: String;
  public class var ImageFile_UnPin: String;
  public class var ImageFile_Backgound: String;
  public class var ImageFile_Folder: String;
  private class constructor Create;
  Private
    fItems: TRecentListCollection;
    fHoverItem: Integer;
    IsPinHover: BooLean;
    IsFolderHover: Boolean;
    imgPin: TPNGImage;
    imgUnPin: TPNGImage;
    imgFolder: TPNGImage;
    bgIMg: TPNGImage;
    fItemClick: TItemClickEvent;
    fStateId: Integer;
    fCurrentIndex: Integer;
    procedure SetItems(const Value: TRecentListCollection);
  Protected
    function GetThemeClassName: PWideChar; OverRide;
    procedure RenderProcedure_Vista(const ACanvas: TCanvas); OverRide;
    procedure RenderProcedure_XP(const ACanvas: TCanvas); OverRide;
    procedure DrawItem(const ACanvas: TCanvas;Item: TRecentListItem;ItemTop: Integer);
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); OverRide;
    procedure Click; override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
    function GetClientRect: TRect; override;
  Public
    Constructor Create(AOwner: TComponent); OverRide;
    Destructor Destroy; OverRide;
    function CurrentIndex: Integer;
  Published
    property Caption;
    property Hint;
    property Color Default clWhite;
    property Items: TRecentListCollection Read fItems Write SetItems;
    property OnItemClick: TItemClickEvent Read fItemClick Write fItemClick;
  End;

implementation

uses
  UI.Aero.Core, Math;

{ TRecentListItem }

Constructor TRecentListItem.Create(Collection: TCollection);
begin
 Inherited Create(Collection);
 fEnabled:= True;
 fName:= 'RecentListItem'+IntToStr(Index);
end;

procedure TRecentListItem.Pin;
begin

end;

procedure TRecentListItem.UnPin;
begin

end;

procedure TRecentListItem.SetEnabled(const Value: BooLean);
begin
 fEnabled:= Value;
end;

procedure TRecentListItem.SetHover(const Value: TItemHoverState);
begin
  fHover:= Value;
end;

procedure TRecentListItem.SetIsPin(const Value: BooLean);
begin
  fIsPin:= Value;
end;

procedure TRecentListItem.SetName(const Value: TCaption);
begin
  fName:= Value;
end;

{ TRecentListCollection }

Constructor TRecentListCollection.Create(AOwner: TAeroRecentList);
begin
 Inherited Create(TRecentListItem);
 fOwner:= AOwner;
end;

function TRecentListCollection.Owner: TAeroRecentList;
begin
 Result:= fOwner;
end;

function TRecentListCollection.Add: TRecentListItem;
begin
 Result:= TRecentListItem(Inherited Add);
end;

function TRecentListCollection.Add(AFileName: String; AIsPin: Boolean): TRecentListItem;
begin
 Result:= Add;
 Result.fFileName:= AFileName;
 Result.fName:= ExtractFileName(AFileName);
 Result.fIsPin:= AIsPin;
end;

function TRecentListCollection.GetItem(Index: Integer): TRecentListItem;
begin
 Result:= TRecentListItem(Inherited GetItem(Index));
end;

procedure TRecentListCollection.SetItem(Index: Integer; const Value: TRecentListItem);
begin
 Inherited SetItem(Index, Value);
end;

{ TAeroRecentList }

class constructor TAeroRecentList.Create;
begin
  if Assigned(RegisterComponentsProc) then
  begin
    TAeroRecentList.ImageFile_Pin:= GetEnvironmentVariable('NTS_LIB_ROOT')+'\NTS UI Aero\Resources\Images\pin.png';
    TAeroRecentList.ImageFile_UnPin:=  GetEnvironmentVariable('NTS_LIB_ROOT')+'\NTS UI Aero\Resources\Images\unpin.png';
    TAeroRecentList.ImageFile_Backgound:= GetEnvironmentVariable('NTS_LIB_ROOT')+'\NTS UI Aero\Resources\Images\menu_bg.png';
    TAeroRecentList.ImageFile_Folder:= GetEnvironmentVariable('NTS_LIB_ROOT')+'\NTS UI Aero\Resources\Images\folder.png';
  end
  else
  begin
    TAeroRecentList.ImageFile_Pin:= '???ERROR_PATH***';
    TAeroRecentList.ImageFile_UnPin:= '???ERROR_PATH***';
    TAeroRecentList.ImageFile_Backgound:= '???ERROR_PATH***';
    TAeroRecentList.ImageFile_Folder:= '???ERROR_PATH***';
  end;
end;

constructor TAeroRecentList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fItemClick:= nil;

  imgPin := TPNGImage.Create;
  imgPin.LoadFromFile(TAeroRecentList.ImageFile_Pin);

  imgUnPin := TPNGImage.Create;
  imgUnPin.LoadFromFile(TAeroRecentList.ImageFile_UnPin);

  imgFolder := TPNGImage.Create;
  imgFolder.LoadFromFile(TAeroRecentList.ImageFile_Folder);

  bgIMg := TPNGImage.Create;
  if (TAeroRecentList.ImageFile_Backgound <> '') and FileExists(TAeroRecentList.ImageFile_Backgound) then
    bgIMg.LoadFromFile(TAeroRecentList.ImageFile_Backgound);

  Color := clWhite;
  fItems := TRecentListCollection.Create(Self);
  fHoverItem := -1;
  IsPinHover := False;
  IsFolderHover := False;
  fStateId := LIS_SELECTED;
  fCurrentIndex:= -1;
end;

function TAeroRecentList.CurrentIndex: Integer;
begin
 Result:= fCurrentIndex;
end;

Destructor TAeroRecentList.Destroy;
begin
 bgIMg.Free;
 imgPin.Free;
 imgUnPin.Free;
 imgFolder.Free;
 fItems.Free;
 Inherited Destroy;
end;

function TAeroRecentList.GetClientRect(): TRect;
begin
  Result:= Inherited GetClientRect();
  Result.Left:= Result.Left+8;
  Result.Right:= Result.Right-8;
end;

function TAeroRecentList.GetThemeClassName: PWideChar;
begin
 if AeroCore.RunWindowsVista then
  Result:= 'Explorer::ListView'
 else
  Result:= VSCLASS_LISTVIEW;
end;

procedure TAeroRecentList.Click;
begin
  Inherited Click;
  if (fHoverItem <> -1) then
  begin
    if IsPinHover then
    begin
      Items[fHoverItem].fIsPin:= not Items[fHoverItem].fIsPin;
      Invalidate;
      if Assigned(fItemClick) then
        fItemClick(Self,fHoverItem,caPin);
    end
    else
      if IsFolderHover then
      begin
        if Assigned(fItemClick) and Items[fHoverItem].Enabled then
          fItemClick(Self,fHoverItem,caFolder);
      end
      else
        if Assigned(fItemClick) and Items[fHoverItem].Enabled then
          fItemClick(Self,fHoverItem,caBody);
  end;
end;

procedure TAeroRecentList.CMMouseLeave(var Message: TMessage);
begin
 Inherited;
 if fStateId = LIS_SELECTED then
  begin
   fHoverItem:= -1;
   IsPinHover:= False;
   IsFolderHover:= False;
   Invalidate;
  end;
end;

procedure TAeroRecentList.MouseMove(Shift: TShiftState; X, Y: Integer);
var
 OldIsPinHover: Boolean;
 OldHoverItem, Temp: Integer;
//
 OldIsFolderHover: Boolean;
begin
 Inherited MouseMove(Shift,X,Y);
 OldHoverItem:= fHoverItem;
 OldIsPinHover:= IsPinHover;
 OldIsFolderHover:= IsFolderHover;
 IsPinHover:= InRange(X,ClientWidth-32,ClientWidth);
 IsFolderHover:= InRange(X,ClientWidth-64,ClientWidth-32);
 if Y <= 24 then
  fHoverItem:= -1
 else
  begin
   Temp:= (Y-24) div 21;
   if Temp < Items.Count then
    fHoverItem:= Temp
   else
    fHoverItem:= -1;
  end;
 if (OldHoverItem <> fHoverItem) or (OldIsPinHover <> IsPinHover) or (IsFolderHover <> OldIsFolderHover) then
  Invalidate;
end;

procedure TAeroRecentList.RenderProcedure_XP(const ACanvas: TCanvas);
begin
  RenderProcedure_Vista(ACanvas);
end;

procedure TAeroRecentList.RenderProcedure_Vista(const ACanvas: TCanvas);
const
  capFormat = (DT_LEFT OR DT_VCENTER OR DT_SINGLELINE);
  verFormat = (DT_RIGHT OR DT_VCENTER OR DT_SINGLELINE);

  procedure BevelLine(C: TColor; X1, Y1, X2, Y2: Integer);
  begin
    with ACanvas do
    begin
      Pen.Color:= C;
      MoveTo(X1, Y1);
      LineTo(X2, Y2);
    end;
  end;

var
  I, ItemTop: Integer;
  OldBkMode: integer;
  capRect: TRect;
begin
  ACanvas.Brush.Color:= Self.Color;
  ACanvas.FillRect( Rect(0,0,Width,Height) );
  ACanvas.Draw(-(bgIMg.Width-Self.Width),Self.Height-bgIMg.Height,bgIMg);

  ACanvas.Font.Color:= clNavy;
  ACanvas.Font.Style:= [fsBold];
  capRect:= ClientRect;
  capRect:= Bounds(capRect.Left+8,capRect.Top+0,ClientWidth,20);
  OldBkMode:= SetBkMode(ACanvas.Handle,1);
  DrawText(ACanvas.Handle,PChar(Caption),-1,capRect,capFormat);
  SetBkMode(ACanvas.Handle,OldBkMode);
//
  ACanvas.Font.Color:= clBlack;
  ACanvas.Font.Style:= [];
  capRect:= ClientRect;
  capRect:= Bounds(0,0,ClientWidth,20);
  OldBkMode:= SetBkMode(ACanvas.Handle,1);
  DrawText(ACanvas.Handle,PChar(Hint),-1,capRect,verFormat);
  SetBkMode(ACanvas.Handle,OldBkMode);
//
  capRect:= ClientRect;
  BevelLine(clBtnShadow, capRect.Left, capRect.Top+20, ClientWidth, 20);
  BevelLine(cl3DLight, capRect.Left, capRect.Top+21, ClientWidth, 21);
  ItemTop:= 24;
  for I:=0 to fItems.Count-1 do
  begin
    DrawItem(ACanvas, fItems[I], ItemTop);
    ItemTop:= ItemTop+21;
  end;
end;

procedure TAeroRecentList.DrawItem(const ACanvas: TCanvas; Item: TRecentListItem;ItemTop: Integer);
const
  capFormat = (DT_LEFT OR DT_VCENTER OR DT_SINGLELINE);
  pathFormat = (DT_LEFT OR DT_VCENTER OR DT_SINGLELINE OR DT_PATH_ELLIPSIS);
var
  OldBkMode: integer;
  itRect: TRect;
begin
  if fHoverItem = Item.Index then
  begin
    if IsPinHover then
      itRect:= Bounds(ClientWidth-32,ItemTop,32,21)
    else
    if IsFolderHover then
      itRect:= Bounds(ClientWidth-64,ItemTop,32,21)
    else
    if Item.Enabled then
      itRect:= Bounds(ClientRect.Left,ItemTop,ClientWidth-8,21)
    else
      itRect:= Bounds(0,0,0,0);
    DrawThemeBackground(ThemeData,ACanvas.Handle,LVP_LISTITEM,fStateId,itRect,nil);
  end;

  if Item.Enabled then
    ACanvas.Font.Color:= clBlack
  else
    ACanvas.Font.Color:= clSilver;
  ACanvas.Font.Style:= [];

  if Item.Index <= 8 then
  begin
    ACanvas.Font.Style:= [fsUnderline];
    itRect:= Bounds(ClientRect.Left+8,ItemTop,22,21);
    OldBkMode:= SetBkMode(ACanvas.Handle,1);
    DrawText(ACanvas.Handle,PChar(IntToStr(Item.Index+1)),-1,itRect,capFormat);
    SetBkMode(ACanvas.Handle,OldBkMode);
    ACanvas.Font.Style:= [];
    itRect:= Bounds(ClientRect.Left+22,ItemTop,ClientWidth-94,21);
  end
  else
    itRect:= Bounds(ClientRect.Left+22,ItemTop,ClientWidth-94,21);

  OldBkMode:= SetBkMode(ACanvas.Handle,1);
  DrawText(ACanvas.Handle,PChar(Item.Name),-1,itRect,capFormat);
  SetBkMode(ACanvas.Handle,OldBkMode);

  itRect.Left:= itRect.Left+ACanvas.TextExtent(Item.Name).cx+4;

  if Item.fIsPin then
    ACanvas.Draw(ClientWidth-24,ItemTop+2,imgUnPin)
  else
    ACanvas.Draw(ClientWidth-24,ItemTop+2,imgPin);
// Folders path UI 2010
  if (fHoverItem = Item.Index) then
  begin
    ACanvas.Draw(ClientWidth-56,ItemTop+2,imgFolder);
  end;

  ACanvas.Font.Style:= [];
  if (fHoverItem = Item.Index) and not IsPinHover then
  begin
    if IsFolderHover then
      ACanvas.Font.Color:= clMaroon
    else
      ACanvas.Font.Color:= clNavy
  end
  else
    ACanvas.Font.Color:= clSilver;

  OldBkMode:= SetBkMode(ACanvas.Handle,1);
  DrawText(ACanvas.Handle,PChar('('+ExtractFilePath(Item.fFileName)+')'),-1,itRect,pathFormat);
  SetBkMode(ACanvas.Handle,OldBkMode);
end;

procedure TAeroRecentList.SetItems(const Value: TRecentListCollection);
begin
 fItems:= Value;
end;

procedure TAeroRecentList.WMContextMenu(var Message: TWMContextMenu);
begin
 if (fHoverItem <> -1) and not IsPinHover and not IsFolderHover then
  begin
   fStateId:= LIS_SELECTEDNOTFOCUS;
   Invalidate;
   fCurrentIndex:= fHoverItem;
   Inherited;
   fStateId:= LIS_SELECTED;
   Invalidate;
   MouseMove([],Message.XPos,Message.YPos);
  end;
end;

end.
