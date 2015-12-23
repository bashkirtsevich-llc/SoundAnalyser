inherited frDialog: TfrDialog
  Width = 394
  Height = 258
  ExplicitWidth = 394
  ExplicitHeight = 258
  DesignSize = (
    394
    258)
  object gpButtons: TGridPanel
    Left = 217
    Top = 217
    Width = 177
    Height = 41
    Anchors = [akRight, akBottom]
    BevelOuter = bvNone
    BorderWidth = 4
    ColumnCollection = <
      item
        Value = 50.000000000000000000
      end
      item
        Value = 50.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = btnOK
        Row = 0
      end
      item
        Column = 1
        Control = btnCancel
        Row = 0
      end>
    RowCollection = <
      item
        Value = 100.000000000000000000
      end>
    TabOrder = 0
    object btnOK: TButton
      Left = 4
      Top = 4
      Width = 84
      Height = 33
      Align = alClient
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 88
      Top = 4
      Width = 85
      Height = 33
      Align = alClient
      Cancel = True
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 1
    end
  end
end
