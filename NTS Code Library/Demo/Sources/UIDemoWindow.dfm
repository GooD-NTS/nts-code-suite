object DemoWindow: TDemoWindow
  Left = 0
  Top = 0
  Caption = 'DemoWindow'
  ClientHeight = 391
  ClientWidth = 378
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    378
    391)
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox1: TPaintBox
    Left = 8
    Top = 147
    Width = 198
    Height = 236
    Anchors = [akLeft, akTop, akRight, akBottom]
    OnPaint = PaintBox1Paint
    ExplicitWidth = 265
    ExplicitHeight = 201
  end
  object Label1: TLabel
    Left = 8
    Top = 128
    Width = 49
    Height = 13
    Caption = 'Gradient'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 362
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Window Config'
    TabOrder = 0
    ExplicitWidth = 415
    DesignSize = (
      362
      105)
    object CheckBox1: TCheckBox
      Left = 24
      Top = 24
      Width = 335
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Show caption bar'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = CheckBox1Click
      ExplicitWidth = 402
    end
    object Button1: TButton
      Left = 24
      Top = 47
      Width = 326
      Height = 41
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Browse for icon'
      TabOrder = 1
      OnClick = Button1Click
      ExplicitWidth = 393
    end
  end
  object RadioGroup1: TRadioGroup
    Left = 212
    Top = 147
    Width = 158
    Height = 201
    Anchors = [akTop, akRight]
    Caption = 'Gradient type'
    ItemIndex = 0
    Items.Strings = (
      'gtHorizontal'
      'gtVertical'
      'gtRainbow'
      'gtCircle'
      'gtltTopBottom'
      'gtWindow')
    TabOrder = 1
    OnClick = RadioGroup1Click
    ExplicitLeft = 279
  end
  object WindowConfig: TWindowConfig
    ShowInTaskBar = False
    Left = 144
    Top = 24
  end
end
