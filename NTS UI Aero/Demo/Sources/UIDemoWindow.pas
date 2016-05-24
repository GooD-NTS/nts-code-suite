unit UIDemoWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UI.Aero.Core, UI.Aero.Window, UI.Aero.Core.BaseControl,
  UI.Aero.Core.CustomControl, UI.Aero.Labels,
  UI.Aero.Core.CustomControl.Animation, UI.Aero.Button.Custom,
  UI.Aero.Button.Task, UI.Aero.Button, UI.Aero.Button.Theme,
  UI.Aero.black.GameButton;

type
  TMainWindow = class(TForm)
    AeroWindow1: TAeroWindow;
    lbTitle: TAeroLabel;
    lnkGCode: TAeroTaskButton;
    lnkTwitter: TAeroTaskButton;
    btnExit: TAeroButton;
    btnDemo1: TAeroThemeButton;
    btnDemo2: TAeroThemeButton;
    procedure FormCreate(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure lnkGCodeClick(Sender: TObject);
    procedure lnkTwitterClick(Sender: TObject);
    procedure btnDemo1Click(Sender: TObject);
    procedure btnDemo2Click(Sender: TObject);
  private
    { Private declarations }
    procedure RunLink(AURL: String);
  public
    { Public declarations }
  end;

var
  MainWindow: TMainWindow;

implementation

uses
  ShellAPI,
  UIDemo1Window,
  UIDemo2Window;

{$R *.dfm}

procedure TMainWindow.btnDemo1Click(Sender: TObject);
begin
  Demo1Window.Show;
end;

procedure TMainWindow.btnDemo2Click(Sender: TObject);
begin
  Demo2Window.Show;
end;

procedure TMainWindow.btnExitClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TMainWindow.FormCreate(Sender: TObject);
begin
  lnkTwitter.Image.FileName:= 'twitter.png';
end;

procedure TMainWindow.lnkGCodeClick(Sender: TObject);
begin
  Self.RunLink('http://code.google.com/p/nts-code-suite/');
end;

procedure TMainWindow.lnkTwitterClick(Sender: TObject);
begin
  Self.RunLink('https://twitter.com/GooDNTS');
end;

procedure TMainWindow.RunLink(AURL: String);
begin
  with TThread.CreateAnonymousThread(
    procedure
    begin
      ShellExecute(0,'Open',pChar(AURL),nil,nil,SW_SHOWNORMAL);
    end
  ) do Start;
end;

initialization
begin

end

end.
