(*
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
 * libavcodec/libavfilter gluing utilities
 *
 * This should be included in an application ONLY if the installed
 * libavfilter has been compiled with libavcodec support, otherwise
 * symbols defined below will not be available.
 *)

(*
 * FFVCL - Delphi FFmpeg VCL Components
 * http://www.DelphiFFmpeg.com
 *
 * Original file: libavfilter/avcodec.h
 * Ported by CodeCoolie@CNSW 2014/07/22 -> $Date:: 2014-12-19 #$
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

unit libavfilter_avcodec;

interface

{$I CompilerDefines.inc}

uses
  libavfilter,
  libavutil,
  libavutil_frame;

{$I libversion.inc}

{$IFDEF FF_API_AVFILTERBUFFER}
(**
 * Create and return a picref reference from the data and properties
 * contained in frame.
 *
 * @param perms permissions to assign to the new buffer reference
 * @deprecated avfilter APIs work natively with AVFrame instead.
 *)
function avfilter_get_video_buffer_ref_from_frame(const frame: PAVFrame; perms: Integer): PAVFilterBufferRef; cdecl; external AVFILTER_LIBNAME name _PU + 'avfilter_get_video_buffer_ref_from_frame';

(**
 * Create and return a picref reference from the data and properties
 * contained in frame.
 *
 * @param perms permissions to assign to the new buffer reference
 * @deprecated avfilter APIs work natively with AVFrame instead.
 *)
function avfilter_get_audio_buffer_ref_from_frame(const frame: PAVFrame;
                                                           perms: Integer): PAVFilterBufferRef; cdecl; external AVFILTER_LIBNAME name _PU + 'avfilter_get_audio_buffer_ref_from_frame';

(**
 * Create and return a buffer reference from the data and properties
 * contained in frame.
 *
 * @param perms permissions to assign to the new buffer reference
 * @deprecated avfilter APIs work natively with AVFrame instead.
 *)
function avfilter_get_buffer_ref_from_frame(ttype: TAVMediaType;
                                                     const frame: PAVFrame;
                                                     perms: Integer): PAVFilterBufferRef; cdecl; external AVFILTER_LIBNAME name _PU + 'avfilter_get_buffer_ref_from_frame';
{$ENDIF}

implementation

end.
