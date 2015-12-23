unit Analysis.Spectrum.Quantization;

interface

uses
  System.SysUtils, Common.ComplexNum;

procedure Quantization(
  AFFTData    : TArray<TComplexNum>; // данные БПФ
  AFFTLength  : Word;                // размер выборки для FFT
  APalSize    : Integer;             // размер палитры
  AOnComplete : TProc<TArray<Integer>>);

implementation

uses
  System.Math;

procedure Quantization(
  AFFTData    : TArray<TComplexNum>; // данные БПФ
  AFFTLength  : Word;                // размер выборки для FFT
  APalSize    : Integer;             // размер палитры
  AOnComplete : TProc<TArray<Integer>>);
const
  dB_range = 120;
var
  idx, i: Integer;
  c: TComplexNum;
  dBfs, magnitude: Single;
  qData: TArray<Integer>;
begin
  SetLength(qData, Length(AFFTData));

  i := 0;
  for c in AFFTData do
  begin
    magnitude := Sqrt(Sqr(c.Real) + Sqr(c.Imm));

    if magnitude <> 0 then
      dBfs := 20 * Log10(magnitude / AFFTLength + 0.000001)
    else
      dBfs := -dB_range; // тишина

    idx := Trunc(Abs(APalSize + dBfs * APalSize / dB_range));

    qData[i] := Min(Max(0, idx), APalSize - 1);

    Inc(i);
  end;

  AOnComplete(qData);
end;

end.
