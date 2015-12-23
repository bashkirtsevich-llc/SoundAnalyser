(*
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *)

(**
 * @file
 * @ingroup lavfi_buffersrc
 * Memory buffer source API.
 *)

(*
 * FFVCL - Delphi FFmpeg VCL Components
 * http://www.DelphiFFmpeg.com
 *
 * Original file: libavfilter/buffersrc.h
 * Ported by CodeCoolie@CNSW 2014/07/22 -> $Date:: 2014-08-22 #$
 *)

(*
FFmpeg Delphi/Pascal Headers and Examples License Agreement

A modified part of FFVCL - Delphi FFmpeg VCL Components.
Copyright (c) 2008-2014 DelphiFFmpeg.com
All rights reserved.
http://www.DelphiFFmpeg.com

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

This source code is provided "as is" by DelphiFFmpeg.com without
warranty of any kind, either expressed or implied, including but not
limited to the implied warranties of merchantability and/or fitness
for a particular purpose.

Please also notice the License agreement of FFmpeg libraries.
*)

unit libavfilter_buffersrc;

interface

{$I CompilerDefines.inc}

uses
  libavfilter,
  libavutil_frame;

{$I libversion.inc}

(**
 * @defgroup lavfi_buffersrc Buffer source API
 * @ingroup lavfi
 * @{
 *)

const

(**
 * Do not check for format changes.
 *)
  AV_BUFFERSRC_FLAG_NO_CHECK_FORMAT = 1;

{$IFDEF FF_API_AVFILTERBUFFER}
(**
 * Ignored
 *)
  AV_BUFFERSRC_FLAG_NO_COPY = 2;
{$ENDIF}

(**
 * Immediately push the frame to the output.
 *)
  AV_BUFFERSRC_FLAG_PUSH = 4;

(**
 * Keep a reference to the frame.
 * If the frame if reference-counted, create a new reference; otherwise
 * copy the frame data.
 *)
  AV_BUFFERSRC_FLAG_KEEP_REF = 8;

(**
 * Add buffer data in picref to buffer_src.
 *
 * @param buffer_src  pointer to a buffer source context
 * @param picref      a buffer reference, or NULL to mark EOF
 * @param flags       a combination of AV_BUFFERSRC_FLAG_*
 * @return            >= 0 in case of success, a negative AVERROR code
 *                    in case of failure
 *)
function av_buffersrc_add_ref(buffer_src: PAVFilterContext;
                         picref: PAVFilterBufferRef; flags: Integer): Integer; cdecl; external AVFILTER_LIBNAME name _PU + 'av_buffersrc_add_ref';

(**
 * Get the number of failed requests.
 *
 * A failed request is when the request_frame method is called while no
 * frame is present in the buffer.
 * The number is reset when a frame is added.
 *)
function av_buffersrc_get_nb_failed_requests(buffer_src: PAVFilterContext): Cardinal; cdecl; external AVFILTER_LIBNAME name _PU + 'av_buffersrc_get_nb_failed_requests';

{$IFDEF FF_API_AVFILTERBUFFER}
(**
 * Add a buffer to a filtergraph.
 *
 * @param ctx an instance of the buffersrc filter
 * @param buf buffer containing frame data to be passed down the filtergraph.
 * This function will take ownership of buf, the user must not free it.
 * A NULL buf signals EOF -- i.e. no more frames will be sent to this filter.
 *
 * @deprecated use av_buffersrc_write_frame() or av_buffersrc_add_frame()
 *)
function av_buffersrc_buffer(ctx: PAVFilterContext; buf: PAVFilterBufferRef): Integer; cdecl; external AVFILTER_LIBNAME name _PU + 'av_buffersrc_buffer';
{$ENDIF}

(**
 * Add a frame to the buffer source.
 *
 * @param ctx   an instance of the buffersrc filter
 * @param frame frame to be added. If the frame is reference counted, this
 * function will make a new reference to it. Otherwise the frame data will be
 * copied.
 *
 * @return 0 on success, a negative AVERROR on error
 *
 * This function is equivalent to av_buffersrc_add_frame_flags() with the
 * AV_BUFFERSRC_FLAG_KEEP_REF flag.
 *)
function av_buffersrc_write_frame(ctx: PAVFilterContext; const frame: PAVFrame): Integer; cdecl; external AVFILTER_LIBNAME name _PU + 'av_buffersrc_write_frame';

(**
 * Add a frame to the buffer source.
 *
 * @param ctx   an instance of the buffersrc filter
 * @param frame frame to be added. If the frame is reference counted, this
 * function will take ownership of the reference(s) and reset the frame.
 * Otherwise the frame data will be copied. If this function returns an error,
 * the input frame is not touched.
 *
 * @return 0 on success, a negative AVERROR on error.
 *
 * @note the difference between this function and av_buffersrc_write_frame() is
 * that av_buffersrc_write_frame() creates a new reference to the input frame,
 * while this function takes ownership of the reference passed to it.
 *
 * This function is equivalent to av_buffersrc_add_frame_flags() without the
 * AV_BUFFERSRC_FLAG_KEEP_REF flag.
 *)
function av_buffersrc_add_frame(ctx: PAVFilterContext; frame: PAVFrame): Integer; cdecl; external AVFILTER_LIBNAME name _PU + 'av_buffersrc_add_frame';

(**
 * Add a frame to the buffer source.
 *
 * By default, if the frame is reference-counted, this function will take
 * ownership of the reference(s) and reset the frame. This can be controlled
 * using the flags.
 *
 * If this function returns an error, the input frame is not touched.
 *
 * @param buffer_src  pointer to a buffer source context
 * @param frame       a frame, or NULL to mark EOF
 * @param flags       a combination of AV_BUFFERSRC_FLAG_*
 * @return            >= 0 in case of success, a negative AVERROR code
 *                    in case of failure
 *)
function av_buffersrc_add_frame_flags(buffer_src: PAVFilterContext;
                                  frame: PAVFrame; flags: Integer): Integer; cdecl; external AVFILTER_LIBNAME name _PU + 'av_buffersrc_add_frame_flags';


(**
 * @}
 *)

implementation

end.
