unit SnappyLib;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Description:	SNAPPY compressor and decompressor                            //
// Version:	0.1                                                           //
// Date:	13-FEB-2025                                                   //
// License:     MIT                                                           //
// Target:	Win64, Free Pascal, Delphi                                    //
// Copyright:	(c) 2025 Xelitan.com.                                         //
//		All rights reserved.                                          //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Classes, SysUtils;

  const LIBSNAP = 'libsnappy.dll';

  type TSnappyStatus = (SNAPPY_OK, SNAPPY_INVALID_INPUT, SNAPPY_BUFFER_TOO_SMALL);

  function snappy_compress(input: PByte; input_length: SizeUInt; compressed: PByte; var compressed_length: SizeUInt): TSnappyStatus; cdecl; external LIBSNAP;
  function snappy_uncompress(compressed: PByte; compressed_length: SizeUInt; uncompressed: PByte; var uncompressed_length: SizeUInt): TSnappyStatus; cdecl; external LIBSNAP;
  function snappy_max_compressed_length(source_length: SizeUInt): SizeUInt; cdecl; external LIBSNAP;
  function snappy_uncompressed_length(compressed: PByte; compressed_length: SizeUInt; var result: SizeUInt): TSnappyStatus; cdecl; external LIBSNAP;

  //Functions
  function Snappy(Data: PByte; DataLen: Integer; var OutData: TBytes): Boolean; overload;
  function UnSnappy(Data: PByte; DataLen: Integer; var OutData: TBytes): Boolean; overload;

  function Snappy(InStr, OutStr: TStream): Boolean; overload;
  function UnSnappy(InStr, OutStr: TStream): Boolean; overload;

  function Snappy(Str: String): String; overload;
  function UnSnappy(Str: String): String; overload;

implementation

function Snappy(Data: PByte; DataLen: Integer; var OutData: TBytes): Boolean;
var Res: TSnappyStatus;
    OutLen: QWord;
begin
  OutLen := snappy_max_compressed_length(DataLen);
  SetLength(OutData, OutLen);

  Res := snappy_compress(Data, DataLen, @OutData[0], OutLen);
  if Res <> SNAPPY_OK then Exit(False);
  SetLength(OutData, OutLen);

  Result := False;
  if Res = SNAPPY_OK then Exit(True);
end;

function UnSnappy(Data: PByte; DataLen: Integer; var OutData: TBytes): Boolean;
var Res: TSnappyStatus;
    MaxLen: SizeUint;
begin
  Res := snappy_uncompressed_length(Data, DataLen, MaxLen);
  if Res <> SNAPPY_OK then Exit(False);
  SetLength(OutData, MaxLen);

  Res := snappy_uncompress(Data, DataLen, @OutData[0], MaxLen);
  Result := False;
  if Res = SNAPPY_OK then Exit(True);
end;

function UnSnappy(Str: String): String;
var Res: Boolean;
    OutLen: Integer;
    OutData: TBytes;
begin
  Res := UnSnappy(@Str[1], Length(Str), OutData);
  if not Res then Exit('');

  OutLen := Length(OutData);
  SetLength(Result, OutLen);
  Move(OutData[0], Result[1], OutLen);
end;

function Snappy(InStr, OutStr: TStream): Boolean;
var Buf: array of Byte;
    Size: Integer;
    OutData: TBytes;
begin
  Result := False;
  try
    Size := InStr.Size - InStr.Position;
    SetLength(Buf, Size);
    InStr.Read(Buf[0], Size);

    if not Snappy(@Buf[0], Size, OutData) then Exit;

    OutStr.Write(OutData[0], Length(OutData));
    Result := True;
  finally
  end;
end;

function UnSnappy(InStr, OutStr: TStream): Boolean;
var Buf: array of Byte;
    Size: Integer;
    OutData: TBytes;
begin
  Result := False;
  try
    Size := InStr.Size - InStr.Position;
    SetLength(Buf, Size);
    InStr.Read(Buf[0], Size);

    if not UnSnappy(@Buf[0], Size, OutData) then Exit;

    OutStr.Write(OutData[0], Length(OutData));
    Result := True;
  finally
  end;
end;

function Snappy(Str: String): String;
var Res: Boolean;
    OutLen: Integer;
    OutData: TBytes;
begin
  Res := Snappy(@Str[1], Length(Str), OutData);
  if not Res then Exit('');

  OutLen := Length(OutData);
  SetLength(Result, OutLen);
  Move(OutData[0], Result[1], OutLen);
end;

end.
