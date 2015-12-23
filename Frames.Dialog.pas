unit Frames.Dialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Frames.Persistent, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TfrDialog = class(TfrmPersistent)
    gpButtons: TGridPanel;
    btnOK: TButton;
    btnCancel: TButton;
  end;

implementation

{$R *.dfm}

end.
