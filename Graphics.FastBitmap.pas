unit Graphics.FastBitmap;

interface

uses
  Winapi.Windows;

type
  TFastBitmap = class
  public
    type
      TFColor = record
        B, G, R: Byte;

        constructor Create(AR, AG, AB: Byte); overload;
        constructor Create(AColor: Cardinal); overload;
      end;

      TLine   = array [0..0] of TFColor;
      PLine   = ^TLine;

      TPLines = array [0..0] of PLine;
      PPLines = ^TPLines;
  private
    const
      hSection = 0;
  private
    FInitialized: Boolean;
    FGap,    // space between scanlines
    FRowInc, // distance to next scanline
    FSize,   // size of Bits
    FWidth, FHeight: Integer;
    FPixels: PPLines;
    FBits: Pointer;

    FHandle: THandle;
    FDC: HDC;

    FBMInfo: TBitmapInfo;
    FBMHeader: TBitmapInfoHeader;

    procedure Initialize;
  public
    property Pixels: PPLines read FPixels;
    property Initialized: Boolean read FInitialized;
  public
    constructor Create(AWidth, AHeight: Integer); overload;
    constructor Create(AHBmp: Integer); overload;
    destructor Destroy; override;

    procedure ReleaseImg;

    procedure Draw(ADest: HDC; AX, AY: Integer);
    procedure StretchDraw(ADest: HDC; AX, AY, AW, AH: Integer); overload;
    procedure StretchDraw(ADest: HDC; ARect: TRect); overload;

    procedure LineTo(AX1, AY1, AX2, AY2: Integer; AColor: TFColor);
    procedure Square(AX1, AY1, AX2, AY2: Integer; AColor: TFColor);
  end;

implementation

{ TFastBMP }

procedure TFastBitmap.Initialize;
var
  i: Integer;
  x: Longint;
begin
  FPixels := VirtualAlloc(nil, FHeight * SizeOf(PLine), MEM_COMMIT, PAGE_READWRITE);

  FGap := FWidth mod 4;
  FRowInc := (FWidth * 3) + FGap;
  FSize := FRowInc * FHeight;

  x := Integer(FBits);
  for i := 0 to FHeight - 1 do
  begin
    FPixels[i] := Pointer(x);
    Inc(x, FRowInc);
  end;

  FDC := CreateCompatibleDC(0);
  SelectObject(FDC, FHandle);

  FInitialized := True;
end;

procedure TFastBitmap.LineTo(AX1, AY1, AX2, AY2: Integer;
  AColor: TFColor);
var
  v7, v8, v9, v10, v11,
  xEnda, xEndb, yEnda: Integer;
begin
  v7 := AX2 - AX1;

  v11 := 1;
  if v7 <= 0 then
  begin
    v11 := -1;
    v7  := -v7;
  end;

  v8 := AY2 - AY1;

  yEnda := 1;

  if v8 <= 0 then
  begin
    yEnda := -1;
    v8 := -v8;
  end;

  if v8 < v7 then
  begin
    v10 := v7 div 2;
    xEndb := v7;
    while xEndb <> 0 do
    begin
      Dec(xEndb);

      Pixels[AY1, AX1] := AColor;

      Inc(AX1, v11);
      Dec(v10, v8);
      if ( v10 < 0 ) then
      begin
        Inc(v10, v7);
        Inc(AY1, yEnda);
      end;
    end;
  end else
  begin
    v9 := v8 div 2;
    xEnda := v8;

    while xEnda <> 0 do
    begin
      Dec(xEnda);

      Pixels[AY1, AX1] := AColor;

      Inc(AY1, yEnda);
      Dec(v9, v7);

      if v9 < 0  then
      begin
        Inc(v9, v8);
        Inc(AX1, v11);
      end;
    end;
  end;
end;

procedure TFastBitmap.ReleaseImg;
begin
  DeleteDC(FDC);
  DeleteObject(FHandle);
  VirtualFree(FPixels, 0, MEM_RELEASE);

  FInitialized := False;
end;

procedure TFastBitmap.StretchDraw(ADest: HDC; AX, AY, AW, AH: Integer);
begin
  SetStretchBltMode(ADest, STRETCH_DELETESCANS);
  StretchBlt(ADest, AX, AY, AW, AH, FDC, 0, 0, FWidth, FHeight, SRCCOPY);
end;

procedure TFastBitmap.Square(AX1, AY1, AX2, AY2: Integer; AColor: TFColor);
begin
  LineTo(AX1, AY1, AX1, AY2, AColor);
  LineTo(AX1, AY1, AX2, AY1, AColor);
  LineTo(AX2-1, AY1, AX2-1, AY2, AColor);
  LineTo(AX1, AY2-1, AX2, AY2-1, AColor);
end;

procedure TFastBitmap.StretchDraw(ADest: HDC; ARect: TRect);
begin
  StretchDraw(ADest, ARect.Left, ARect.Top, ARect.Width, ARect.Height);
end;

constructor TFastBitmap.Create(AWidth, AHeight: Integer);
begin
  FWidth := AWidth;
  FHeight := AHeight;

  with FBMHeader do
  begin
    biSize := SizeOf(FBMHeader);
    biWidth := FWidth;
    biHeight := -FHeight;
    biPlanes := 1;
    biBitCount := 24;
    biCompression := BI_RGB;
  end;

  FBMInfo.bmiHeader := FBMHeader;
  FHandle := CreateDIBSection(0, FBMInfo, DIB_RGB_COLORS, FBits, hSection, 0);

  Initialize;
end;

constructor TFastBitmap.Create(AHBmp: Integer);
var
  bmpRec: TBITMAP;
  memDC: Integer;
begin
  GetObject(AHBmp, SizeOf(bmpRec), @bmpRec);

  FWidth := bmpRec.bmWidth;
  FHeight := bmpRec.bmHeight;

  FSize := ((FWidth * 3) + (FWidth mod 4)) * FHeight;

  with FBMHeader do
  begin
    biSize := SizeOf(FBMHeader);
    biWidth := FWidth;
    biHeight := -FHeight;
    biPlanes := 1;
    biBitCount := 24;
    biCompression := BI_RGB;
  end;

  FBMInfo.bmiHeader := FBMHeader;
  FHandle := CreateDIBSection(0, FBMInfo, DIB_RGB_COLORS, FBits, hSection, 0);
  memDC := GetDC(0);
  GetDIBits(memDC, AHBmp, 0, FHeight, FBits, FBMInfo, DIB_RGB_COLORS);
  ReleaseDC(0, memDC);

  Initialize;
end;

procedure TFastBitmap.Draw(ADest: HDC; AX, AY: Integer);
begin
  BitBlt(ADest, AX, AY, FWidth, FHeight, FDC, 0, 0, SRCCOPY);
end;

destructor TFastBitmap.Destroy;
begin
  ReleaseImg;
end;

{ TFastBMP.TFColor }

constructor TFastBitmap.TFColor.Create(AR, AG, AB: Byte);
begin
  r := AR;
  g := AG;
  b := AB;
end;

constructor TFastBitmap.TFColor.Create(AColor: Cardinal);
begin
  r := Byte(AColor);
  AColor := AColor shr 8;

  g := Byte(AColor);
  AColor := AColor shr 8;

  b := Byte(AColor);
end;

end.
