unit UIDemo1Window;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UI.Aero.Core, UI.Aero.Window, UI.Aero.Core.BaseControl,
  UI.Aero.Core.CustomControl, UI.Aero.ThemeElement, UI.Aero.Footer,
  UI.Aero.BackForward, UI.Aero.SearchBox, StdCtrls,
  UI.Aero.Core.CustomControl.Animation, UI.Aero.Button.Custom,
  UI.Aero.Button.Expando, UI.Aero.ToolTip;

type
  TDemo1Window = class(TForm)
    AeroWindow1: TAeroWindow;
    AeroFooter1: TAeroFooter;
    AeroIEBackForward1: TAeroIEBackForward;
    AeroBackForward1: TAeroBackForward;
    AeroSearchBox1: TAeroSearchBox;
    Button1: TButton;
    AeroExpandoButton1: TAeroExpandoButton;
    AeroToolTip1: TAeroToolTip;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Demo1Window: TDemo1Window;

implementation

{$R *.dfm}

procedure TDemo1Window.Button1Click(Sender: TObject);
begin
  Self.Close;
end;

initialization
begin
  TAeroBackForward.Resources_Images_xp_w3k:= '..\..\..\Resources\Images\';
  TAeroIEBackForward.ResourcesImagesPath:= '..\..\..\Resources\Images\';
end

end.
