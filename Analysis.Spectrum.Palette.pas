unit Analysis.Spectrum.Palette;

interface

uses
  System.SysUtils, Vcl.Graphics;

type
  TPaletteType = (ptSOX, ptSpek);

procedure MakePalette(ASize: Integer; APalType: TPaletteType; out APalette: TArray<TColor>);

implementation

uses
  Winapi.Windows;

procedure MakePalette(ASize: Integer; APalType: TPaletteType; out APalette: TArray<TColor>);
var
  i: Integer;
  c: array[0..3] of Single;
  x: Single;
begin
  SetLength(APalette, ASize);

  for i := 0 to ASize - 1 do
  case APalType of
    ptSOX:
      begin
        x := i / (ASize - 1);

        if (x < 0.13) then c[0] := 0 else
        if (x < 0.73) then c[0] := 1   * sin((x - 0.13) / 0.60 * Pi / 2) else
                           c[0] := 1;

        if (x < 0.60) then c[1] := 0 else
        if (x < 0.91) then c[1] := 1   * sin((x - 0.60) / 0.31 * Pi / 2) else
                           c[1] := 1;

        if (x < 0.60) then c[2] := 0.5 * sin((x - 0.00) / 0.60 * Pi    ) else
        if (x < 0.78) then c[2] := 0 else
                           c[2] :=           (x - 0.78) / 0.22;

        APalette[i] := RGB(Trunc(0.5 + 255 * c[0]),
                           Trunc(0.5 + 255 * c[1]),
                           Trunc(0.5 + 255 * c[2]));
      end;

    ptSpek:
      begin
        x := (i / (ASize - 1)) * 0.6625;

        if (x >= 0) and (x < 0.15) then
        begin
          c[0] := (0.15 - x) / (0.15 + 0.075); c[1] := 0.0; c[2] := 1.0;
        end else
        if (x >= 0.15) and (x < 0.275) then
        begin
          c[0] := 0.0; c[1] := (x - 0.15) / (0.275 - 0.15); c[2] := 1.0;
        end else
        if (x >= 0.275) and (x < 0.325) then
        begin
          c[0] := 0.0; c[1] := 1.0; c[2] := (0.325 - x) / (0.325 - 0.275);
        end else
        if (x >= 0.325) and (x < 0.5) then
        begin
          c[0] := (x - 0.325) / (0.5 - 0.325); c[1] := 1.0; c[2] := 0.0;
        end else
        if (x >= 0.5) and (x < 0.6625) then
        begin
          c[0] := 1.0; c[1] := (0.6625 - x) / (0.6625 - 0.5); c[2] := 0.0;
        end;

        // Intensity correction.
        c[3] := 1.0;
        if (x >= 0.0) and (x < 0.1) then
            c[3] := x / 0.1;

        c[3] := c[3]*255.0;

        APalette[i] := RGB(Trunc(0.5 + c[3] * c[0]),
                           Trunc(0.5 + c[3] * c[1]),
                           Trunc(0.5 + c[3] * c[2]));
      end;
  end;

end;

end.
