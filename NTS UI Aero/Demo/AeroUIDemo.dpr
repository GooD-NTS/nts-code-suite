program AeroUIDemo;

uses
  Forms,
  UIDemoWindow in 'Sources\UIDemoWindow.pas' {MainWindow},
  UIDemo1Window in 'Sources\UIDemo1Window.pas' {Demo1Window},
  UIDemo2Window in 'Sources\UIDemo2Window.pas' {Demo2Window};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainWindow, MainWindow);
  Application.CreateForm(TDemo1Window, Demo1Window);
  Application.CreateForm(TDemo2Window, Demo2Window);
  Application.Run;
end.
