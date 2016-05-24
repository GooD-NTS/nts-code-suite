unit UIDemo2Window;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UI.Aero.Core, UI.Aero.Window, UI.Aero.Core.BaseControl,
  UI.Aero.Core.CustomControl, UI.Aero.PageManager, UI.Aero.StatusBox,
  UI.Aero.ThemeElement, UI.Aero.Core.CustomControl.Animation,
  UI.Aero.Composition, ExtCtrls, StdCtrls;

type
  TDemo2Window = class(TForm)
    AeroPageManager1: TAeroPageManager;
    AeroWindow1: TAeroWindow;
    AeroStatusBar: TAeroThemeElement;
    statusFiles: TAeroStatusBox;
    statusSelectedFiles: TAeroStatusBox;
    statusVersionCheck: TAeroStatusButton;
    statusArchiveButton: TAeroStatusButton;
    statusGameName: TAeroStatusBox;
    statusPlatform: TAeroStatusBox;
    AeroStatusBox1: TAeroStatusBox;
    AeroAnimationComposition1: TAeroAnimationComposition;
    AnimTimer: TTimer;
    DemoAnim1: TAeroAnimationComposition;
    procedure AnimTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Demo2Window: TDemo2Window;

implementation

uses
  UI.Aero.Globals;

{$R *.dfm}

procedure TDemo2Window.AnimTimerTimer(Sender: TObject);
begin
  if DemoAnim1.CurrentItem = 3 then
  begin
    DemoAnim1.CurrentItem:= 0;
    case Random(3) of
      0: DemoAnim1.FontCollection[0].Font.Color:= clBlack;
      1: DemoAnim1.FontCollection[0].Font.Color:= clMaroon;
      2: DemoAnim1.FontCollection[0].Font.Color:= clNavy;
      3: DemoAnim1.FontCollection[0].Font.Color:= clGreen;
    end;
  end
  else
    DemoAnim1.CurrentItem:= DemoAnim1.CurrentItem+1;
end;

procedure TDemo2Window.FormCreate(Sender: TObject);
begin
 Randomize;
 DemoAnim1.Items.Add;
 DemoAnim1.Items.Add;
 DemoAnim1.Items.Add;
 DemoAnim1.Items.Add;
//
 with DemoAnim1.Items[0].Composition.Add do
  begin
   Top:= 0;
   Left:= 0;
   Width:= DemoAnim1.Width;
   Height:= DemoAnim1.Height;
   FirstDraw:= cdText;
   Text.FontIndex:= 0;
   Text.Text:= 'Demo Anim';
   Text.Alignment:= taCenter;
   Text.Layout:= tlCenter;
  end;
 with DemoAnim1.Items[1].Composition.Add do
  begin
   Top:= 0;
   Left:= 0;
   Width:= DemoAnim1.Width;
   Height:= DemoAnim1.Height;
   FirstDraw:= cdText;
   Text.FontIndex:= 0;
   Text.Text:= '(Demo Anim)';
   Text.Alignment:= taCenter;
   Text.Layout:= tlCenter;
  end;
 with DemoAnim1.Items[2].Composition.Add do
  begin
   Top:= 0;
   Left:= 0;
   Width:= DemoAnim1.Width;
   Height:= DemoAnim1.Height;
   FirstDraw:= cdText;
   Text.FontIndex:= 0;
   Text.Text:= '( Demo Anim )';
   Text.Alignment:= taCenter;
   Text.Layout:= tlCenter;
  end;
 with DemoAnim1.Items[3].Composition.Add do
  begin
   Top:= 0;
   Left:= 0;
   Width:= DemoAnim1.Width;
   Height:= DemoAnim1.Height;
   FirstDraw:= cdText;
   Text.FontIndex:= 0;
   Text.Text:= '(  Demo Anim  )';
   Text.Alignment:= taCenter;
   Text.Layout:= tlCenter;
  end;
///////

end;

initialization
begin
  TAeroBasePageManager.ImageFile_Left:= '..\..\..\Resources\Images\PagesLeft.png';
  TAeroBasePageManager.ImageFile_Right:= '..\..\..\Resources\Images\PagesRight.png';

  TAeroBaseStatusBox.BandImageLeft:= '..\..\..\Resources\Images\band-left.png';
  TAeroBaseStatusBox.BandImageCenter:= '..\..\..\Resources\Images\band-center.png';
  TAeroBaseStatusBox.BandImageRight:= '..\..\..\Resources\Images\band-right.png';
  TAeroBaseStatusBox.BandImageBreak:= '..\..\..\Resources\Images\band-break.png';
  TAeroBaseStatusBox.BandImageLight:= '..\..\..\Resources\Images\band-light.png';
end

end.
