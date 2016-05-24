unit UIDemoWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, NTS.Code.Components.WindowConfig,
  NTS.Code.Components.VirtualStringList, ExtCtrls;

type
  TDemoWindow = class(TForm)
    WindowConfig: TWindowConfig;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    Button1: TButton;
    PaintBox1: TPaintBox;
    Label1: TLabel;
    RadioGroup1: TRadioGroup;
    procedure CheckBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DemoWindow: TDemoWindow;

implementation

uses
  NTS.Code.Graphics.Gradient;

{$R *.dfm}

procedure TDemoWindow.Button1Click(Sender: TObject);
begin
  with TOpenDialog.Create(Application) do
  begin
    Filter:= 'Icon|*.ico';
    if Execute() then
      WindowConfig.Icon:= FileName;
    Free;
  end;
end;

procedure TDemoWindow.CheckBox1Click(Sender: TObject);
begin
  WindowConfig.ShowCaptionBar:= CheckBox1.Checked;
end;

procedure TDemoWindow.PaintBox1Paint(Sender: TObject);
begin
  TGradientClass.Get( TGradientType(RadioGroup1.ItemIndex), PaintBox1.Canvas,
    PaintBox1.ClientRect, clSkyBlue, clWhite);
end;

procedure TDemoWindow.RadioGroup1Click(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

end.
