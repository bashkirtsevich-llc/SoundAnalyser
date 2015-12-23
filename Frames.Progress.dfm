inherited frProgress: TfrProgress
  Width = 450
  Height = 73
  ExplicitWidth = 450
  ExplicitHeight = 73
  object lblComment: TLabel
    Left = 6
    Top = 3
    Width = 439
    Height = 23
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'lblComment'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Layout = tlCenter
  end
  object pbProgress: TProgressBar
    Left = 6
    Top = 32
    Width = 439
    Height = 36
    Anchors = [akLeft, akTop, akRight, akBottom]
    Step = 1
    TabOrder = 0
    ExplicitHeight = 41
  end
end
