unit Analysis.Ruler;

interface

uses
  Vcl.Graphics, System.SysUtils;

type
  TPosition = (pTop, pBottom, pLeft, pRight);

function Ruler(AX, AY: Integer; APosition: TPosition;
    ASampleLabel: string; AFactors: TArray<Integer>;
    AMinUnits, AMaxUnits: Integer; ASpacing, AScale, AOffset: Single
  ): TProc<TCanvas, TFunc<Integer, string>>;

implementation

uses
  Winapi.Windows, System.Classes, System.Math;

function Ruler(AX, AY: Integer; APosition: TPosition;
    ASampleLabel: string; AFactors: TArray<Integer>;
    AMinUnits, AMaxUnits: Integer; ASpacing, AScale, AOffset: Single
  ): TProc<TCanvas, TFunc<Integer, string>>;
begin
  Result := procedure (ACanvas: TCanvas; AFormatter: TFunc<Integer, string>)
  var
    len, factor, i: Integer;
    drawTick: TProc<TCanvas, Integer, TFunc<Integer, string>>;
  begin
    drawTick := procedure (ACanvas: TCanvas; ATick: Integer;
      AFormatter: TFunc<Integer, string>)
    {$REGION 'drawTick'}
    const
      GAP = 10;
      TICK_LEN = 6;
    var
      value, h, w: Integer;
      p: Single;
      lbl: string;
    begin
      lbl := AFormatter(ATick);
      value := IfThen((APosition = pTop) or (APosition = pBottom),
                      ATick,
                      AMaxUnits + AMinUnits - ATick);
      p := AOffset + AScale * (value - AMinUnits);

      w := ACanvas.TextWidth(lbl);
      h := ACanvas.TextHeight(lbl);

      case APosition of
        pTop:
          begin
            ACanvas.MoveTo(Round(AX + p), Round(AY));
            ACanvas.LineTo(Round(AX + p), Round(AY + TICK_LEN));
            ACanvas.TextOut(Trunc(AX + p - w / 2), Trunc(AY - GAP - h), lbl);
          end;

        pRight:
          begin
            ACanvas.MoveTo(Round(AX), Round(AY + p));
            ACanvas.LineTo(Round(AX + TICK_LEN), Round(AY + p));
            ACanvas.TextOut(Trunc(AX + GAP), Trunc(AY + p - h / 2), lbl);
          end;

        pBottom:
          begin
            ACanvas.MoveTo(Round(AX + p), Round(AY));
            ACanvas.LineTo(Round(AX + p), Round(AY + TICK_LEN));
            ACanvas.TextOut(Trunc(AX + p - w / 2), Trunc(AY + GAP), lbl);
          end;

        pLeft:
          begin
            ACanvas.MoveTo(Round(AX), Round(AY + p));
            ACanvas.LineTo(Round(AX - TICK_LEN), Round(AY + p));
            ACanvas.TextOut(Trunc(AX - w - GAP), Trunc(AY + p - h / 2), lbl);
          end;
      end;
    end;
    {$ENDREGION}

    // Mesure the sample label.
    len := IfThen(APosition in [pTop, pBottom],
                  ACanvas.TextWidth(ASampleLabel),
                  ACanvas.TextHeight(ASampleLabel));

    // Select the factor to use, we want some space between the labels.
    factor := 0; i := 0;

    while AFactors[i] > 0 do
    begin
      if Abs(AScale * AFactors[i]) >= ASpacing * len then
      begin
        factor := AFactors[i];
        Break;
      end;

      Inc(i);
    end;

    // Draw the ticks.
    drawTick(ACanvas, AMinUnits, AFormatter);
    drawTick(ACanvas, AMaxUnits, AFormatter);

    if factor > 0 then
    begin
      i := AMinUnits + factor;
      while i < AMaxUnits do
      begin
        if Abs(AScale * (AMaxUnits - i)) < len * 1.2 then
          Break;

        drawTick(ACanvas, i, AFormatter);
        Inc(i, factor);
      end;
    end;
  end;
end;

end.
