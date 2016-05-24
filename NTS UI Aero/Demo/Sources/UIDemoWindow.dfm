object MainWindow: TMainWindow
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'MainWindow'
  ClientHeight = 349
  ClientWidth = 330
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.SheetOfGlass = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    330
    349)
  PixelsPerInch = 96
  TextHeight = 13
  object lbTitle: TAeroLabel
    Left = 0
    Top = 0
    Width = 330
    Height = 69
    DragWindow = True
    Align = alTop
    Font.Charset = ANSI_CHARSET
    Font.Color = 13789440
    Font.Height = -32
    Font.Name = 'Segoe UI'
    Font.Style = []
    Caption = 'NTS Aero UI Demo'
    TextGlow = True
    Alignment = taCenter
    ExplicitLeft = -8
    ExplicitTop = 8
    ExplicitWidth = 416
  end
  object lnkGCode: TAeroTaskButton
    Left = 125
    Top = 46
    Width = 205
    Height = 13
    Anchors = [akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 13395456
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    OnClick = lnkGCodeClick
    Caption = 'http://code.google.com/p/nts-code-suite/'
    ExplicitLeft = 211
  end
  object lnkTwitter: TAeroTaskButton
    Left = 8
    Top = 331
    Width = 65
    Height = 13
    Anchors = [akLeft, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 13395456
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    OnClick = lnkTwitterClick
    Image.PartHeight = 16
    Image.PartWidth = 16
    Caption = '@GoooDNTS'
    ExplicitTop = 422
  end
  object btnExit: TAeroButton
    Left = 247
    Top = 320
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    OnClick = btnExitClick
    Caption = 'Exit'
    ExplicitLeft = 333
    ExplicitTop = 414
  end
  object btnDemo1: TAeroThemeButton
    Left = 16
    Top = 88
    Width = 297
    Height = 49
    OnClick = btnDemo1Click
    ThemeClassName = 'BUTTON'
    State.PartNormal = 6
    State.PartHightLight = 6
    State.PartFocused = 6
    State.PartDown = 6
    State.PartDisabled = 6
    State.StateNormal = 1
    State.StateHightLight = 2
    State.StateFocused = 5
    State.StateDown = 3
    State.StateDisabled = 6
    Caption = 'Run Demo 1'
  end
  object btnDemo2: TAeroThemeButton
    Left = 16
    Top = 143
    Width = 297
    Height = 49
    OnClick = btnDemo2Click
    ThemeClassName = 'BUTTON'
    State.PartNormal = 6
    State.PartHightLight = 6
    State.PartFocused = 6
    State.PartDown = 6
    State.PartDisabled = 6
    State.StateNormal = 1
    State.StateHightLight = 2
    State.StateFocused = 5
    State.StateDown = 3
    State.StateDisabled = 6
    Caption = 'Run Demo 2'
  end
  object AeroWindow1: TAeroWindow
    ShowCaptionBar = False
    DragWindow = True
    LinesCount = 0
    Left = 8
    Top = 32
  end
end
