unit Frames.Export;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Frames.Dialog, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Mask;

type
  TfrSettings = class(TfrDialog)
    grpSize: TGroupBox;
    medtWidth: TMaskEdit;
    medtHeight: TMaskEdit;
    lblWidth: TLabel;
    lblHeight: TLabel;
  end;

implementation

{$R *.dfm}

end.
