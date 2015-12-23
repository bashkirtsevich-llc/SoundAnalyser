unit Frames.Progress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Frames.Persistent, Vcl.ComCtrls,
  Vcl.StdCtrls;

type
  TfrProgress = class(TfrmPersistent)
    lblComment: TLabel;
    pbProgress: TProgressBar;
  private
    FTitle: string;
    FProgress: Integer;
    FIsDetermined: Boolean;

    function GetTitle: string; inline;
    procedure SetTitle(const Value: string); inline;
    function GetIsDetermined: Boolean; inline;
    function GetProgress: Integer; inline;
    procedure SetIsDetermined(const Value: Boolean); inline;
    procedure SetProgress(const Value: Integer); inline;
  public
    property Title: string read GetTitle write SetTitle;
    property Progress: Integer read GetProgress write SetProgress;
    property IsDetermined: Boolean read GetIsDetermined write SetIsDetermined;
    procedure Reset; inline;

    constructor Create(AOwner: TWinControl); override;
  end;

var
  frProgress: TfrProgress;

implementation

{$R *.dfm}

{ TfrProgress }

constructor TfrProgress.Create(AOwner: TWinControl);
begin
  inherited Create(AOwner);
  Parent := AOwner;

  FTitle := string.Empty;
  FProgress := 0;
  FIsDetermined := False;
end;

function TfrProgress.GetIsDetermined: Boolean;
begin
  Result := FIsDetermined;
end;

function TfrProgress.GetProgress: Integer;
begin
  Result := FProgress;
end;

function TfrProgress.GetTitle: string;
begin
  Result := FTitle;
end;

procedure TfrProgress.Reset;
begin
  FProgress := 0;
end;

procedure TfrProgress.SetIsDetermined(const Value: Boolean);
begin
  FIsDetermined := Value;
end;

procedure TfrProgress.SetProgress(const Value: Integer);
begin
  if FProgress <> Value then
  begin
    FProgress := Value;

    if FIsDetermined then
      pbProgress.Position := FProgress
    else
      pbProgress.Position := Trunc(Log10(FProgress) * 10);
  end;
end;

procedure TfrProgress.SetTitle(const Value: string);
begin
  if FTitle <> Value then
  begin
    FTitle := Value;
    lblComment.Caption := FTitle;
  end;
end;

end.
