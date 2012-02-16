object frmOptions: TfrmOptions
  Left = 443
  Top = 427
  BorderStyle = bsDialog
  Caption = 'Auto Save Options'
  ClientHeight = 64
  ClientWidth = 241
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblAutoSaveInterval: TLabel
    Left = 8
    Top = 12
    Width = 88
    Height = 13
    Caption = 'Auto Save &Interval'
    FocusControl = edtAutosaveInterval
  end
  object edtAutosaveInterval: TEdit
    Left = 104
    Top = 8
    Width = 41
    Height = 21
    TabOrder = 0
    Text = '60'
  end
  object udAutoSaveInterval: TUpDown
    Left = 145
    Top = 8
    Width = 15
    Height = 21
    Associate = edtAutosaveInterval
    Min = 60
    Max = 3600
    Position = 60
    TabOrder = 1
  end
  object cbxPrompt: TCheckBox
    Left = 8
    Top = 36
    Width = 97
    Height = 17
    Caption = '&Prompt'
    TabOrder = 2
  end
  object btnOK: TBitBtn
    Left = 164
    Top = 8
    Width = 75
    Height = 25
    TabOrder = 3
    Kind = bkOK
  end
  object btnCancel: TBitBtn
    Left = 164
    Top = 36
    Width = 75
    Height = 25
    TabOrder = 4
    Kind = bkCancel
  end
end
