unit Analysis.Spectrum;

interface

uses
  System.Classes, System.SysUtils, System.Math, Common.ComplexNum;

type
  TWindowType = (wtHann, wtHamm, wtBlackman);

procedure Analyse(
  AStream         : TStream;        // данные
  AChannels       : Integer;        // кол-во каналов
  AFFTLength      : Integer;        // размер выборки для FFT
  AFFTWindow      : Integer;        // размер окна выборки для FFT
  AWindowType     : TWindowType;    // тип оконной функции
  AOnProgress     : TProc<Int64>;   // прогресс
  AOnBlockFinish  : TProc<TArray<TComplexNum>>);

implementation

procedure Analyse(
  AStream         : TStream;
  AChannels       : Integer;
  AFFTLength      : Integer;
  AFFTWindow      : Integer;
  AWindowType     : TWindowType;
  AOnProgress     : TProc<Int64>;
  AOnBlockFinish  : TProc<TArray<TComplexNum>>);

  procedure MakeFourier(AWindowType: TWindowType;
    AFFTLength: Integer; var AFFTData: TArray<TComplexNum>);

    procedure FourierTransform(ANumSamples: Word;
      ADataIn: TArray<TComplexNum>; var ADataOut: TArray<TComplexNum>);

      {$REGION 'Support functions'}
      function ReverseBits(AIndex: Word; ANumBits: Integer): Word;
      var
        i: Integer;
      begin
        Result := 0;
        for i := 0 to ANumBits - 1 do
        begin
          Result := (Result shl 1) or (AIndex and 1);
          AIndex := AIndex shr 1;
        end;
      end;

      {$REGION 'IsPowerOfTwo'}
      {function IsPowerOfTwo(x: Word): Boolean;
      var
        i, y: Word;
      begin
        y := 2;
        for i := 1 to 15 do
        begin
          if x = y then
          begin
            Result := True;
            Exit;
          end;
          y := y shl 1;
        end;
        Result := False;
      end;}
      {$ENDREGION}

      function NumberOfBitsNeeded(APowerOfTwo: Word): Word;
      begin
        for Result := 0 to 16 do
          if (APowerOfTwo and (1 shl Result)) <> 0 then
            Exit;

        Result := 0;
      end;
      {$ENDREGION}

    var
      numBits, i, j, k, n, blockSize, blockEnd: Word;
      deltaAngle, deltaAr: Single;
      alpha, beta: Single;
      tr, ti, ar, ai: Single;
    begin
      {if not IsPowerOfTwo(ANumSamples) or (ANumSamples < 2) then
        raise Exception.Create(Format('Error in procedure Fourier:  NumSamples=%d  is not a positive integer power of 2.', [ANumSamples]));}

      numBits := NumberOfBitsNeeded(ANumSamples);

      for i := 0 to ANumSamples - 1 do
      begin
        j := ReverseBits(i, numBits);

        ADataOut[j].Real  := ADataIn[i].Real;
        ADataOut[j].Imm   := ADataIn[i].Imm;
      end;

      blockEnd := 1;
      blockSize := 2;
      while blockSize <= ANumSamples do
      begin
        deltaAngle := (2*pi) / blockSize;

        alpha := sin(0.5 * deltaAngle);
        alpha := 2.0 * alpha * alpha;

        beta := sin(deltaAngle);

        i := 0;
        while i < ANumSamples do
        begin
          ar := 1.0; (* cos(0) *)
          ai := 0.0; (* sin(0) *)

          j := i;
          for n := 0 to blockEnd - 1 do
          begin
            k := j + blockEnd;

            tr := ar * ADataOut[k].Real - ai * ADataOut[k].Imm;
            ti := ar * ADataOut[k].Imm  + ai * ADataOut[k].Real;

            ADataOut[k].Real := ADataOut[j].Real - tr;
            ADataOut[k].Imm  := ADataOut[j].Imm  - ti;
            ADataOut[j].Real := ADataOut[j].Real + tr;
            ADataOut[j].Imm  := ADataOut[j].Imm  + ti;

            deltaAr := alpha * ar + beta * ai;
            ai := ai - (alpha * ai - beta * ar);
            ar := ar - deltaAr;

            inc(j);
          end;

          Inc(i, blockSize);
        end;

        blockEnd := blockSize;
        blockSize := blockSize shl 1;
      end;
    end;

  var
    i: Integer;
    fftOut: TArray<TComplexNum>;
  begin
    SetLength(fftOut, AFFTLength);

    case AWindowType of
      wtHann:
        for i := 0 to AFFTLength - 1 do
          AFFTData[i].Real := AFFTData[i].Real *
            ( 0.50 - ( 0.50 * Cos(2 * pi * (i + 1) / AFFTLength)) );

      wtHamm:
        for i := 0 to AFFTLength - 1 do
          AFFTData[i].Real := AFFTData[i].Real *
            ( 0.54 - ( 0.46 * Cos(2 * pi * (i + 1) / AFFTLength)) );

      wtBlackman:
        for i := 0 to AFFTLength - 1 do
          AFFTData[i].Real := AFFTData[i].Real *
            ( 0.42 - ( 0.50 * Cos(2 * pi * (i + 1) / AFFTLength)) +
                     ( 0.08 * Cos(4 * pi * (i + 1) / AFFTLength)) );
    end;

    FourierTransform(AFFTLength, AFFTData, fftOut);

    for i := 0 to AFFTLength - 1 do
      AFFTData[i] := fftOut[i];
  end;

var
  fftData: TArray<TComplexNum>;
  data: TArray<Single>;
  c, i: Integer;
  block: TArray<TComplexNum>;
  skip: Int64;
begin
  Assert(AStream.Size > 0);
  Assert(AChannels > 0);
  Assert(Assigned(AOnBlockFinish));

  SetLength(fftData, AFFTLength);
  SetLength(block, AFFTLength div 2 * AChannels);

  SetLength(data, AFFTLength * AChannels);

  AStream.Position := 0;

  skip := AStream.Size div Single.Size div AChannels div 1920;

  while AStream.Position < AStream.Size do
  begin
    AStream.Read(data[0], AFFTLength * AChannels * Single.Size);

    for c := 0 to AChannels - 1 do
    begin
      for i := 0 to AFFTLength - 1 do
        fftData[i] := TComplexNum.Create(data[i * AChannels + c], 0);

      MakeFourier(AWindowType, AFFTLength, fftData);

      for i := 0 to AFFTLength div 2 - 1 do
        block[(AFFTLength div 2 * (c + 1)) - i] := fftData[i];
    end;

    AOnBlockFinish(block);

    { skip bytes }

    AStream.Seek(skip * Single.Size * AChannels, soCurrent);

    if Assigned(AOnProgress) then
      AOnProgress(Trunc(AStream.Position / AStream.Size * 100));
  end;
end;

end.
