unit Forms.Dialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Frames.Persistent;

type
  TfrmDialog = class(TForm)
    pnlFrames: TPanel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FFrame: TfrmPersistent;
  public
    property Frame: TfrmPersistent read FFrame;
    constructor Create(AOwner: TComponent; AFrameClass: TfrmPersistentClass); reintroduce;
  end;

implementation

{$R *.dfm}

{ TfrmDialog }

constructor TfrmDialog.Create(AOwner: TComponent; AFrameClass: TfrmPersistentClass);
begin
  inherited Create(AOwner);

  FFrame := AFrameClass.Create(pnlFrames);

  Height := FFrame.Height;
  Width  := FFrame.Width;
end;

procedure TfrmDialog.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ModalResult <> mrNone;
end;

end.
