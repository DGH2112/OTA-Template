object frmOptions: TfrmOptions
  Left = 443
  Top = 427
  BorderStyle = bsDialog
  Caption = 'Auto Save Options'
  ClientHeight = 139
  ClientWidth = 343
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    343
    139)
  PixelsPerInch = 96
  TextHeight = 16
  object btnOK: TBitBtn
    Left = 242
    Top = 60
    Width = 92
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 2
    ExplicitLeft = 324
    ExplicitTop = 131
  end
  object btnCancel: TBitBtn
    Left = 242
    Top = 99
    Width = 92
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 3
    ExplicitLeft = 324
    ExplicitTop = 170
  end
  object chkEnabled: TCheckBox
    Left = 8
    Top = 8
    Width = 327
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = '&Enabled AutoSave'
    TabOrder = 0
    OnClick = chkEnabledClick
    ExplicitWidth = 409
  end
  object gbxAutosaveOptions: TGroupBox
    Left = 8
    Top = 31
    Width = 227
    Height = 100
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'AutoSave Options'
    TabOrder = 1
    ExplicitWidth = 309
    ExplicitHeight = 171
    DesignSize = (
      227
      100)
    object lblAutoSaveInterval: TLabel
      Left = 10
      Top = 31
      Width = 108
      Height = 16
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Auto Save &Interval'
      FocusControl = edtAutosaveInterval
    end
    object cbxPrompt: TCheckBox
      Left = 10
      Top = 68
      Width = 201
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akLeft, akTop, akRight]
      Caption = '&Prompt'
      TabOrder = 2
      ExplicitWidth = 283
    end
    object edtAutosaveInterval: TEdit
      Left = 142
      Top = 28
      Width = 50
      Height = 24
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      TabOrder = 0
      Text = '60'
      ExplicitLeft = 224
    end
    object udAutoSaveInterval: TUpDown
      Left = 192
      Top = 28
      Width = 19
      Height = 24
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Associate = edtAutosaveInterval
      Min = 60
      Max = 3600
      Position = 60
      TabOrder = 1
      ExplicitLeft = 274
    end
  end
end
