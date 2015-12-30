unit Analysis;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  System.Generics.Defaults, System.IOUtils, System.Math,
  Winapi.Windows,
  Vcl.Graphics, Vcl.Forms,
  Analysis.Spectrum, Analysis.Spectrum.Palette, Analysis.Spectrum.Quantization,
  Analysis.Ruler, Analysis.Decoder,
  Common.ComplexNum, libavutil_samplefmt;

type
  TProgressType = (ptDecoding, ptAnalysis, ptRendering);

  TAnalyzer = class
  private
    FFFTData: TList<TArray<TComplexNum>>;
    FSpectrumScetch: TBitmap;
    FPalette: TArray<TColor>;
    FPaletteScetch: TBitmap;

    FFFTWindow: Integer;
    FWindowType: TWindowType;
    FFFTLength: Integer;

    FTrackInfo: TDecodeInfo;

    FPaletteType: TPaletteType;
    FPaletteSize: Integer;
    FOnProgress: TProc<Int64>;
    FOnAnalyseStep: TProc<TProgressType, Boolean>;

    procedure BuildSpectrumScetch;
    procedure BuildPaletteScetch;

    procedure SetFFTLength(const Value: Integer);
    procedure SetFFTWindow(const Value: Integer);
    procedure SetWindowType(const Value: TWindowType);
    procedure SetPaletteSize(const Value: Integer);
    procedure SetPaletteType(const Value: TPaletteType);
  public
    property FFTLength: Integer read FFFTLength write SetFFTLength;
    property FFTWindow: Integer read FFFTWindow write SetFFTWindow;
    property WindowType: TWindowType read FWindowType write SetWindowType;

    property PaletteType: TPaletteType read FPaletteType write SetPaletteType;
    property PaletteSize: Integer read FPaletteSize write SetPaletteSize;

    property OnAnalyseStep: TProc<TProgressType, Boolean> read FOnAnalyseStep write FOnAnalyseStep;
    property OnProgress: TProc<Int64> read FOnProgress write FOnProgress;
  public
    procedure Clear;
    function Analyse(const AFileName: string): Boolean;
    procedure Draw(ABitmap: TBitmap; AHeight: Integer = -1; AWidth: Integer = -1);
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TAnalyzer }

function TAnalyzer.Analyse(const AFileName: string): Boolean;
var
  tmp: string;
begin
  Clear;

  tmp := TPath.GetTempFileName;
  try
    if Assigned(FOnAnalyseStep) then
      FOnAnalyseStep(ptDecoding, False);

    Result := Analysis.Decoder.Decode(AFileName, tmp, FOnProgress,
      procedure (AInfo: TDecodeInfo; AStream: TStream)
      begin
        if Assigned(FOnAnalyseStep) then
          FOnAnalyseStep(ptAnalysis, True);

        FTrackInfo := AInfo;

        Analysis.Spectrum.Analyse(AStream, AInfo.Channels, FFFTLength,
          FFFTWindow, FWindowType, FOnProgress,
          procedure (AFFTData: TArray<TComplexNum>)
          begin
            FFFTData.Add(Copy(AFFTData , 0, Length(AFFTData)));
          end);

        BuildSpectrumScetch;
      end);
  finally
    TFile.Delete(tmp);
  end;
end;

procedure TAnalyzer.BuildPaletteScetch;
var
  i: Integer;
begin
  MakePalette(FPaletteSize, FPaletteType, FPalette);

  FPaletteScetch.Width := 1;
  FPaletteScetch.Height := FPaletteSize;

  { превьюха палитры }
  for i := 0 to FPaletteSize - 1 do
  begin
    FPaletteScetch.Canvas.Pen.Color := FPalette[FPaletteSize - i - 1];
    FPaletteScetch.Canvas.MoveTo(0, i);
    FPaletteScetch.Canvas.LineTo(1, i);
  end;
end;

procedure TAnalyzer.BuildSpectrumScetch;
var
  i: Integer;
begin
  if FFFTData.Count > 0 then
  begin
    if Assigned(FOnAnalyseStep) then
      FOnAnalyseStep(ptRendering, True);

    FSpectrumScetch.Width  := FFFTData.Count;
    FSpectrumScetch.Height := Length(FFFTData[0]);

    for i := 0 to FFFTData.Count - 1 do
    begin
      Analysis.Spectrum.Quantization.Quantization(FFFTData[i], FFFTLength,
        FPaletteSize,
        procedure(APalData: TArray<Integer>)
        var
          j: Integer;
        begin
          for j := 0 to Length(APalData) - 1 do
            FSpectrumScetch.Canvas.Pixels[i, j] := FPalette[APalData[j]];
        end);

      if Assigned(FOnProgress) then
        FOnProgress(Trunc(i / FFFTData.Count * 100));
    end;
  end;
end;

procedure TAnalyzer.Clear;
begin
  FSpectrumScetch.FreeImage;
  FFFTData.Clear;
end;

constructor TAnalyzer.Create;
begin
  inherited;

  FPaletteSize := 251;
  FPaletteType := ptSOX;

  FSpectrumScetch := TBitmap.Create;
  FPaletteScetch  := TBitmap.Create;

  BuildPaletteScetch;

  FFFTData := TList<TArray<TComplexNum>>.Create;
end;

destructor TAnalyzer.Destroy;
begin
  Clear;
  FSpectrumScetch.Free;
  FPaletteScetch.Free;
  FFFTData.Free;
  inherited;
end;

procedure TAnalyzer.Draw(ABitmap: TBitmap;
  AHeight, AWidth: Integer);
var
  i: Integer;
  r: TRect;
begin
  with ABitmap, ABitmap.Canvas do
  begin
    Height  := IfThen(AHeight > 0, AHeight, Height);
    Width   := IfThen(AWidth  > 0, AWidth , Width);
    { черный фон }
    Brush.Style := bsSolid;
    Pen.Color := clBlack;
    Brush.Color := clBlack;
    FillRect(Rect(0, 0, Width, Height));
    Brush.Style := bsClear;

    Pen.Color := clSilver;

    Font.Color := clWhite;

    { информация о треке }
    Font.Style := [fsBold];
    TextOut(60, 15, FTrackInfo.FileName);
    Font.Style := [];

    with FTrackInfo do
      TextOut(60, 35, Format('%s, %d бит, %d Гц, каналов: %d', [
        CodecName,
        BitsPerSample,
        SampleRate,
        Channels]
        )
      );

    { граница палитры }
    r := Rect(Width - 82, 60, Width - 73, Height - 40);
    { палитра }
    StretchDraw(r, FPaletteScetch);
    { рамка палитры }
    Rectangle(r);
    { линейка децибелов }
    MoveTo(Width - 65, 60);
    LineTo(Width - 65, Height - 40);

    Ruler(Width - 65, 60, pRight, '-000 dB',
      [1, 2, 5, 10, 20, 50, 0], 0, 120, 3.0,
      (Height - 101) / (-120), Height - 101)(Canvas,
      function (ATick: Integer): string
      begin
        Result := Format('%d dB', [-ATick]);
      end
    );

    { спектр и рамка }
    r := Rect(60, 60, Width - 90, Height - 40);
    StretchDraw(r, FSpectrumScetch);
    Rectangle(r);

    for i := 2 to FTrackInfo.Channels do
    begin
      MoveTo(r.Left,            1 + r.Top + Trunc(r.Height / FTrackInfo.Channels));
      LineTo(r.Left + r.Width,  1 + r.Top + Trunc(r.Height / FTrackInfo.Channels));
    end;

    { линейка частот }
    with Brush do
    begin
      Style := bsSolid;
      Color := clBlack;
    end;

    for i := 1 to FTrackInfo.Channels do
      Ruler(60, 60 + ((i - 1) * ((Height - 101) div FTrackInfo.Channels)), pLeft, '00 kHz',
        [1000, 2000, 5000, 10000, 20000, 0], 0, FTrackInfo.SampleRate div 2, 3.0,
        ((Height - 100) / FTrackInfo.Channels) / (FTrackInfo.SampleRate div 2), 0)(
        Canvas,
        function (ATick: Integer): string
        begin
          Result := Format('%d kHz', [ATick div 1000]);
        end
      );

    { линейка времени }
    Ruler(60, Height - 40, pBottom, '00:00',
      [1, 2, 5, 10, 20, 30, 1*60, 2*60, 5*60, 10*60, 20*60, 30*60, 0],
      0, FTrackInfo.Duration, 1.5, (Width - (90+61)) / FTrackInfo.Duration, 0)(
      Canvas,
      function (ATick: Integer): string
      begin
        Result := Format('%d:%.2d', [ATick div 60, ATick mod 60]);
      end
    );
  end;
end;

procedure TAnalyzer.SetFFTLength(const Value: Integer);
begin
  if FFFTLength <> Value then
  begin
    FFFTLength := Value;
  end;
end;

procedure TAnalyzer.SetFFTWindow(const Value: Integer);
begin
  if FFFTWindow <> Value then
  begin
    FFFTWindow := Value;
  end;
end;

procedure TAnalyzer.SetPaletteSize(const Value: Integer);
begin
  if FPaletteSize <> Value then
  begin
    FPaletteSize := Value;
    BuildPaletteScetch;
  end;
end;

procedure TAnalyzer.SetPaletteType(const Value: TPaletteType);
begin
  if FPaletteType <> Value then
  begin
    FPaletteType := Value;
    BuildPaletteScetch;
  end;
end;

procedure TAnalyzer.SetWindowType(const Value: TWindowType);
begin
  if FWindowType <> Value then
  begin
    FWindowType := Value;
  end;
end;

end.
