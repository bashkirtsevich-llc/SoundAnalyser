unit Common.ComplexNum;

interface

type
  TComplexNum = record
    Real: Single;
    Imm: Single;
    constructor Create(AReal, AImm: Single);
  end;

implementation

{ TComplexNum }

constructor TComplexNum.Create(AReal, AImm: Single);
begin
  Real := AReal;
  Imm := AImm;
end;

end.
