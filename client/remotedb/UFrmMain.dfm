object FrmMain: TFrmMain
  Left = 365
  Top = 145
  Width = 681
  Height = 507
  Caption = 'FrmMain'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object dbgrd_1: TDBGrid
    Left = 0
    Top = 97
    Width = 665
    Height = 353
    Align = alClient
    DataSource = ds_1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object pnl: TPanel
    Left = 0
    Top = 0
    Width = 665
    Height = 97
    Align = alTop
    TabOrder = 1
    DesignSize = (
      665
      97)
    object lbl_1: TLabel
      Left = 11
      Top = 10
      Width = 19
      Height = 13
      Caption = 'SQL'
    end
    object mmo_1: TMemo
      Left = 40
      Top = 8
      Width = 497
      Height = 82
      Anchors = [akLeft, akTop, akRight]
      Lines.Strings = (
        'select * from People')
      TabOrder = 0
    end
    object btn_1: TButton
      Left = 552
      Top = 8
      Width = 49
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'query'
      TabOrder = 1
      OnClick = btn_1Click
    end
    object btn_2: TButton
      Left = 608
      Top = 8
      Width = 49
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'sql'
      TabOrder = 2
      OnClick = btn_2Click
    end
    object btn_3: TButton
      Left = 552
      Top = 40
      Width = 49
      Height = 25
      Caption = '5000'
      TabOrder = 3
      OnClick = btn_3Click
    end
    object btn_4: TButton
      Left = 608
      Top = 40
      Width = 49
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'clear'
      TabOrder = 4
      OnClick = btn_2Click
    end
  end
  object stat_1: TStatusBar
    Left = 0
    Top = 450
    Width = 665
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ds_1: TDataSource
    Left = 16
    Top = 152
  end
end
