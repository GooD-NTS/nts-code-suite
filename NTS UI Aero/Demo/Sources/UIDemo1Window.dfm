object Demo1Window: TDemo1Window
  Left = 0
  Top = 0
  Caption = 'Demo1Window'
  ClientHeight = 300
  ClientWidth = 635
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.Top = 41
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    635
    300)
  PixelsPerInch = 96
  TextHeight = 13
  object AeroFooter1: TAeroFooter
    Left = 0
    Top = 259
    Width = 635
    ThemeClassName = 'AeroWizard'
    ExplicitLeft = 552
    ExplicitTop = 256
    ExplicitWidth = 160
    DesignSize = (
      635
      41)
    object Button1: TButton
      Left = 554
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object AeroIEBackForward1: TAeroIEBackForward
    Left = 4
    Top = 5
    Width = 76
    Height = 36
    EnabledBack = True
    EnabledForward = True
  end
  object AeroBackForward1: TAeroBackForward
    Left = 86
    Top = 8
    Width = 81
    Height = 31
    EnabledBack = True
    EnabledForward = True
    EnabledMenu = True
  end
  object AeroSearchBox1: TAeroSearchBox
    Left = 387
    Top = 8
    Width = 240
    Height = 24
    Anchors = [akTop, akRight]
    Constraints.MaxHeight = 24
    Constraints.MinHeight = 24
    BannerText = 'Search for'
  end
  object AeroExpandoButton1: TAeroExpandoButton
    Left = 8
    Top = 56
    Width = 118
    Height = 21
    Caption = 'AeroExpandoButton1'
    ExpandCaption = 'AeroExpandoButton'
    VisibleControl = AeroToolTip1
  end
  object AeroToolTip1: TAeroToolTip
    Left = 8
    Top = 83
    Width = 337
    Height = 62
    Caption = 'AeroToolTip1'
  end
  object AeroWindow1: TAeroWindow
    ShowCaptionBar = False
    DragWindow = True
    LinesCount = 0
    Left = 288
    Top = 8
  end
end
