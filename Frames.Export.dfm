inherited frSettings: TfrSettings
  Width = 178
  Height = 161
  ExplicitWidth = 178
  ExplicitHeight = 161
  inherited gpButtons: TGridPanel
    Left = 1
    Top = 120
    ExplicitLeft = 1
    ExplicitTop = 120
  end
  object grpSize: TGroupBox
    Left = 3
    Top = 3
    Width = 172
    Height = 110
    Anchors = [akLeft, akTop, akRight]
    Caption = #1056#1072#1079#1084#1077#1088' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1103
    TabOrder = 1
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
      Width = 137
      Height = 21
      Alignment = taRightJustify
      EditMask = '9999;1;_'
      MaxLength = 4
      TabOrder = 0
      Text = '    '
    end
    object medtHeight: TMaskEdit
      Left = 16
      Top = 75
      Width = 137
      Height = 21
      Alignment = taRightJustify
      EditMask = '9999;1;_'
      MaxLength = 4
      TabOrder = 1
      Text = '    '
    end
  end
end
