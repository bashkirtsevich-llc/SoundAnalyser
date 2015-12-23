unit Frames.About;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Frames.Dialog, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TfrAbout = class(TfrDialog)
    imgLogo: TImage;
    lblAppName: TLabel;
    lblAppVers: TLabel;
  end;

implementation

{$R *.dfm}

end.
