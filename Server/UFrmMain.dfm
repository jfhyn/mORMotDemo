object FrmMain: TFrmMain
  Left = 528
  Top = 244
  Width = 265
  Height = 196
  Caption = 'mORMot Server'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object grp_1: TGroupBox
    Left = 8
    Top = 8
    Width = 169
    Height = 145
    Caption = 'Setting'
    TabOrder = 0
    object chk_1: TCheckBox
      Left = 16
      Top = 16
      Width = 97
      Height = 17
      Caption = 'RemoteDb'
      TabOrder = 0
    end
    object chk_2: TCheckBox
      Left = 16
      Top = 40
      Width = 97
      Height = 17
      Caption = 'WebSocket'
      TabOrder = 1
    end
    object chk_3: TCheckBox
      Left = 16
      Top = 64
      Width = 97
      Height = 17
      Caption = 'AutoStart'
      TabOrder = 2
    end
    object chk_4: TCheckBox
      Left = 16
      Top = 88
      Width = 97
      Height = 17
      Caption = 'WeChat'
      TabOrder = 3
    end
  end
  object btn_1: TButton
    Left = 184
    Top = 16
    Width = 57
    Height = 25
    Caption = 'Start'
    TabOrder = 1
    OnClick = btn_1Click
  end
  object btn_2: TButton
    Left = 184
    Top = 48
    Width = 57
    Height = 25
    Caption = 'Stop'
    TabOrder = 2
    OnClick = btn_2Click
  end
end
