inherited frSettings: TfrSettings
  Width = 211
  Height = 174
  Padding.Left = 8
  Padding.Top = 8
  Padding.Right = 8
  Padding.Bottom = 8
  ExplicitWidth = 211
  ExplicitHeight = 174
  inherited gpButtons: TGridPanel
    Left = 8
    Top = 125
    Width = 195
    Align = alBottom
    TabOrder = 1
    ExplicitLeft = 1
    ExplicitTop = 120
  end
  object grpSize: TGroupBox
    Left = 8
    Top = 8
    Width = 195
    Height = 117
    Align = alClient
    Caption = #1056#1072#1079#1084#1077#1088' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1103
    TabOrder = 0
    ExplicitLeft = 3
    ExplicitTop = 3
    ExplicitWidth = 172
    ExplicitHeight = 110
    object lblWidth: TLabel
      Left = 16
      Top = 19
      Width = 40
      Height = 13
      Caption = #1064#1080#1088#1080#1085#1072
    end
    object lblHeight: TLabel
      Left = 16
      Top = 60
      Width = 37
      Height = 13
      Caption = #1042#1099#1089#1086#1090#1072
    end
    object medtWidth: TMaskEdit
      Left = 16
      Top = 34
      Width = 161
      Height = 21
      Alignment = taRightJustify
      EditMask = '9999;1;_'
      MaxLength = 4
      TabOrder = 0
      Text = '    '
    end
    object medtHeight: TMaskEdit
      Left = 16
      Top = 79
      Width = 161
      Height = 21
      Alignment = taRightJustify
      EditMask = '9999;1;_'
      MaxLength = 4
      TabOrder = 1
      Text = '    '
    end
  end
end
