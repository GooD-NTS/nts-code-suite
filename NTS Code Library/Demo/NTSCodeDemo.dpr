program NTSCodeDemo;

uses
  Forms,
  UIDemoWindow in 'Sources\UIDemoWindow.pas' {DemoWindow};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown:= True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDemoWindow, DemoWindow);
  Application.Run;
end.
