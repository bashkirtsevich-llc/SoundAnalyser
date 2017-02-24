unit Analysis.Decoder;

interface

uses
  System.Classes, System.IOUtils, System.SysUtils, System.Math,
  Winapi.Windows,
  libavcodec, libavformat, libavutil, libavutil_dict, libavutil_frame,
  libavutil_samplefmt, FFTypes;

type
  TDecodeInfo = record
    FileName: string;
    CodecName: string;              //audioDecCtx^.codec^.long_name or avdec^.long_name
    BitsPerSample: Integer;         //audioDecCtx^.bits_per_raw_sample
    SampleRate: Integer;            //audioDecCtx^.sample_rate (Hz)
    Channels: Integer;              //audioDecCtx^.channels
    Duration: Integer;              //size div sizeof(single) div Channels div SampleRate
  end;

function Decode(
  const AInFile, ADestFile: TFileName;
  AOnProgress: TProc<Int64>;
  AOnComplete: TProc<TDecodeInfo, TStream>): Boolean;

implementation

function Decode(
  const AInFile, ADestFile: TFileName;
  AOnProgress: TProc<Int64>;
  AOnComplete: TProc<TDecodeInfo, TStream>): Boolean;

  function PPtrIdx(P: PPAVStream; I: Integer): PAVStream; inline; overload;
  begin
    Inc(P, I);
    Result := P^;
  end;

  function PPtrIdx(P: PPByte; I: Integer): PPByte; inline; overload;
  begin
    Inc(P, I);
    Result := P;
  end;

  { перевод в формат -1..1 }
  function ConvertData(ASampleFmt: TAVSampleFormat; AData: PPByte;
    AIndex: Integer): Single; inline;
  begin
    case ASampleFmt of
      AV_SAMPLE_FMT_U8, AV_SAMPLE_FMT_U8P   :
        Result := PShortInt(NativeUInt(AData^) + NativeUInt(AIndex * ShortInt.Size))^ / ShortInt.MaxValue;
      AV_SAMPLE_FMT_S16, AV_SAMPLE_FMT_S16P :
        Result := PSmallInt(NativeUInt(AData^) + NativeUInt(AIndex * SmallInt.Size))^ / SmallInt.MaxValue;
      AV_SAMPLE_FMT_S32, AV_SAMPLE_FMT_S32P :
        Result := PInteger(NativeUInt(AData^) + NativeUInt(AIndex * Integer.Size))^ / Integer.MaxValue;
      AV_SAMPLE_FMT_FLT, AV_SAMPLE_FMT_FLTP :
        Result := PSingle(NativeUInt(AData^) + NativeUInt(AIndex * Single.Size))^;
      AV_SAMPLE_FMT_DBL, AV_SAMPLE_FMT_DBLP :
        Result := PDouble(NativeUInt(AData^) + NativeUInt(AIndex * Double.Size))^;
    else
        Result := 0;
    end;
  end;

var
  fname: AnsiString;
  fs: TFileStream;
  info: TDecodeInfo;
  fmtCtx: PAVFormatContext;
  audioStream: PAVStream;
  audioStreamIdx: Integer;
  st: PAVStream;
  decCtx, audioDecCtx: PAVCodecContext;
  avdec: PAVCodec;
  opts: PAVDictionary;
  frame: PAVFrame;
  pkt: TAVPacket;
  size, gotFrame, samples, i, j: Integer;
  data: TArray<Single>;
begin
  Result := False;

  av_register_all;

  fmtCtx := nil;

  fname := TPath.GetTempFileName;

  TFile.Copy(AInFile, fname, True);
  try
    if avformat_open_input(@fmtCtx, PAnsiChar(fname), nil, nil) = 0 then
    try
      if avformat_find_stream_info(fmtCtx, nil) >= 0 then
      begin
        audioStreamIdx := av_find_best_stream(fmtCtx, AVMEDIA_TYPE_AUDIO, -1, -1, nil, 0);

        if audioStreamIdx >= 0 then
        begin
          st := PPtrIdx(fmtCtx.streams, audioStreamIdx);

          decCtx := st.codec;

          avdec := avcodec_find_decoder(decCtx.codec_id);
          if Assigned(avdec) then
          begin
            opts := nil;
            av_dict_set(@opts, 'refcounted_frames', '1', 0);

            if avcodec_open2(decCtx, avdec, @opts) >= 0 then
            begin
              audioStream := PPtrIdx(fmtCtx.streams, audioStreamIdx);

              if Assigned(audioStream) then
              begin
                audioDecCtx := audioStream.codec;
                try
                  frame := av_frame_alloc;
                  Assert(Assigned(frame));

                  try
                    fs := TFileStream.Create(ADestFile, fmCreate or fmShareDenyWrite);
                    try
                      av_init_packet(@pkt);

                      pkt.data := nil;
                      pkt.size := 0;

                      while av_read_frame(fmtCtx, @pkt) = 0 do
                      try
                        if pkt.stream_index = audioStreamIdx then
                        repeat
                          size := avcodec_decode_audio4(audioDecCtx, frame, @gotFrame, @pkt);
                          if size > 0 then
                          begin
                            size := Min(size, pkt.size);

                            if gotFrame <> 0 then
                            begin
                              samples := frame.nb_samples * frame.channels;
                              SetLength(data, samples);

                              if av_sample_fmt_is_planar(TAVSampleFormat(frame.format)) <> 0 then
                                for i := 0 to frame.nb_samples - 1 do
                                  for j := 0 to frame.channels - 1 do
                                    data[i * frame.channels + j] := ConvertData(TAVSampleFormat(frame.format), PPtrIdx(frame.extended_data, j), i)
                              else
                                for i := 0 to samples - 1 do
                                  data[i] := ConvertData(TAVSampleFormat(frame.format), frame.extended_data, i);

                              fs.Write(data[0], Length(data) * Single.Size);

                              if Assigned(AOnProgress) then
                                AOnProgress(fs.Size);

                              av_frame_unref(frame);
                            end;

                            Inc(pkt.data, size);
                            Dec(pkt.size, size);
                          end else
                            Break;
                        until pkt.size <= 0;
                      finally
                        av_free_packet(@pkt);
                      end;

                      with info do
                      begin
                        FileName      := AInFile;
                        CodecName     := string(audioDecCtx^.codec^.long_name);
                        BitsPerSample := av_get_bytes_per_sample(audioDecCtx^.sample_fmt) * 8;
                        SampleRate    := audioDecCtx^.sample_rate;
                        Channels      := audioDecCtx^.channels;
                        Duration      := (fs.Size div Single.Size div Channels div SampleRate) or 1;
                      end;

                      if Assigned(AOnComplete) then
                        AOnComplete(info, fs);

                      Result := True;
                    finally
                      fs.Free;
                    end;
                  finally
                    av_frame_free(@frame);
                  end;
                finally
                  avcodec_close(audioDecCtx);
                end;
              end;
            end;
          end;
        end;
      end;
    finally
      avformat_close_input(@fmtCtx);
    end;
  finally
    TFile.Delete(fname);
  end;
end;

end.
