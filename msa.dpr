program msa;

{$R *.dres}

uses
  Vcl.Forms,
  Forms.Main in 'Forms.Main.pas' {frmMain},
  Analysis.Spectrum in 'Analysis.Spectrum.pas',
  Analysis.Spectrum.Palette in 'Analysis.Spectrum.Palette.pas',
  Analysis.Spectrum.Quantization in 'Analysis.Spectrum.Quantization.pas',
  Common.ComplexNum in 'Common.ComplexNum.pas',
  Analysis in 'Analysis.pas',
  Analysis.Ruler in 'Analysis.Ruler.pas',
  Graphics.FastBitmap in 'Graphics.FastBitmap.pas',
  Analysis.Decoder in 'Analysis.Decoder.pas',
  Frames.About in 'Frames.About.pas' {frAbout: TFrame},
  Forms.Dialog in 'Forms.Dialog.pas' {frmDialog},
  Frames.Persistent in 'Frames.Persistent.pas' {frmPersistent: TFrame},
  Frames.Dialog in 'Frames.Dialog.pas' {frDialog: TFrame},
  Frames.Progress in 'Frames.Progress.pas' {frProgress: TFrame},
  Frames.Export in 'Frames.Export.pas' {frSettings: TFrame};

{$R *.res}

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Sound Analyzer';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
