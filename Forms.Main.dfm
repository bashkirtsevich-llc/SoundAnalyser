object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Sound Analyzer'
  ClientHeight = 562
  ClientWidth = 784
  Color = clWhite
  Constraints.MinHeight = 600
  Constraints.MinWidth = 800
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = pmMain
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object imgSpectrum: TImage
    Left = 0
    Top = 0
    Width = 784
    Height = 562
    Align = alClient
    ExplicitLeft = 8
    ExplicitTop = 39
    ExplicitWidth = 968
    ExplicitHeight = 578
  end
  object imgPopupMenu: TImage
    Left = 20
    Top = 16
    Width = 32
    Height = 32
    Cursor = crHandPoint
    AutoSize = True
    Center = True
    Picture.Data = {
      0954506E67496D61676589504E470D0A1A0A0000000D49484452000000200000
      00200806000000737A7AF400000009704859730000103800001038016E2B1021
      000000A74944415478DA636460600806E274868101331981C42E20761D2007EC
      863B60DEBC791FB4B4B4FED0C3D66BD7AEB124252509A038E0C489136FCCCDCD
      7FD3C301274F9E64B5B0B0101975C0E077004821352CC4662E4107E8E9E9895C
      BE7C992A0ED0D5D5FD7DE9D2A53743CB01031E05B404A30E181A6960C073C180
      3B60C0A3809660D40143230D0C782E1870070C7814D0128C3A60703A60C0BB66
      F4B0180B003B6040BBE700028D5EA2F5E0DED10000000049454E44AE426082}
    OnClick = imgPopupMenuClick
  end
  object actlstMain: TActionList
    OnUpdate = actlstMainUpdate
    Left = 8
    Top = 8
    object actOpen: TAction
      Caption = #1054#1090#1082#1088#1099#1090#1100' '#1092#1072#1081#1083
      ShortCut = 16463
      OnExecute = actOpenExecute
    end
    object actSave: TAction
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077
      ShortCut = 16467
      OnExecute = actSaveExecute
    end
    object actExport: TAction
      Caption = #1069#1082#1089#1087#1086#1088#1090' '#1075#1088#1072#1092#1080#1082#1072
      ShortCut = 24659
      OnExecute = actExportExecute
    end
    object actAbout: TAction
      Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
      ShortCut = 112
      OnExecute = actAboutExecute
    end
  end
  object dlgOpenFile: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPathMustExist, fdoFileMustExist]
    Left = 40
    Top = 8
  end
  object pmMain: TPopupMenu
    Left = 104
    Top = 8
    object miOpenFile: TMenuItem
      Action = actOpen
    end
    object miSavePicture: TMenuItem
      Action = actSave
    end
    object miExportSpectrum: TMenuItem
      Action = actExport
    end
    object miSeparator1: TMenuItem
      Caption = '-'
    end
    object miAbout: TMenuItem
      Action = actAbout
    end
  end
  object dlgSaveGraphic: TFileSaveDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Portable Network Graphics'
        FileMask = '*.png'
      end>
    Options = [fdoCreatePrompt]
    Left = 72
    Top = 8
  end
end
