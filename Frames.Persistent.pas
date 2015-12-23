unit Frames.Persistent;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TfrmPersistentClass = class of TfrmPersistent;

  TfrmPersistent = class(TFrame)
  public
    constructor Create(AOwner: TWinControl); reintroduce; virtual;
  end;

implementation

{$R *.dfm}

{ TfrmPersistent }

constructor TfrmPersistent.Create(AOwner: TWinControl);
begin
  inherited Create(AOwner);
  Parent := AOwner;
end;

end.
