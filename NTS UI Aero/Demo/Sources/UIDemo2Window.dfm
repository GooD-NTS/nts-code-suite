object Demo2Window: TDemo2Window
  Left = 0
  Top = 0
  Caption = 'Demo2Window'
  ClientHeight = 278
  ClientWidth = 646
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.Top = 41
  GlassFrame.Bottom = 21
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    646
    278)
  PixelsPerInch = 96
  TextHeight = 13
  object AeroPageManager1: TAeroPageManager
    Left = 378
    Top = 8
    Width = 260
    Height = 23
    Anchors = [akTop, akRight]
    Constraints.MaxHeight = 23
    Constraints.MinHeight = 23
    Constraints.MinWidth = 50
  end
  object AeroStatusBar: TAeroThemeElement
    AlignWithMargins = True
    Left = 0
    Top = 258
    Width = 646
    Height = 20
    Margins.Left = 0
    Margins.Top = 1
    Margins.Right = 0
    Margins.Bottom = 0
    DragWindow = True
    Align = alBottom
    DesignSize = (
      646
      20)
    object statusFiles: TAeroStatusBox
      Left = 0
      Top = 0
      Width = 61
      Align = alLeft
      BreakRight = True
      Caption = 'statusFiles'
    end
    object statusSelectedFiles: TAeroStatusBox
      Left = 61
      Top = 0
      Width = 102
      Align = alLeft
      BreakLeft = True
      Caption = 'statusSelectedFiles'
    end
    object statusVersionCheck: TAeroStatusButton
      Left = 532
      Top = 0
      Width = 114
      Align = alRight
      BreakLeft = True
      Caption = 'statusVersionCheck'
    end
    object statusArchiveButton: TAeroStatusButton
      Left = 240
      Top = 0
      Width = 118
      Align = alRight
      BreakRight = True
      Caption = 'statusArchiveButton'
    end
    object statusGameName: TAeroStatusBox
      Left = 358
      Top = 0
      Width = 94
      Align = alRight
      BreakLeft = True
      BreakRight = True
      Caption = 'statusGameName'
    end
    object statusPlatform: TAeroStatusBox
      Left = 452
      Top = 0
      Width = 80
      Align = alRight
      BreakLeft = True
      BreakRight = True
      Caption = 'statusPlatform'
    end
    object AeroStatusBox1: TAeroStatusBox
      Left = 170
      Top = 0
      Width = 64
      Anchors = [akTop, akRight]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Caption = 'dev. build'
    end
  end
  object AeroAnimationComposition1: TAeroAnimationComposition
    Left = 8
    Top = 48
    Width = 630
    Height = 129
    ThemeCollection = <>
    FontCollection = <>
    ImageCollection = <>
    Items = <>
  end
  object DemoAnim1: TAeroAnimationComposition
    Left = 61
    Top = 0
    Width = 226
    Height = 42
    DragWindow = True
    ThemeCollection = <>
    FontCollection = <
      item
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
      end>
    ImageCollection = <>
    Items = <>
  end
  object AeroWindow1: TAeroWindow
    ShowCaptionBar = False
    DragWindow = True
    LinesCount = 0
    Left = 304
    Top = 8
  end
  object AnimTimer: TTimer
    Interval = 500
    OnTimer = AnimTimerTimer
    Left = 16
    Top = 8
  end
end
