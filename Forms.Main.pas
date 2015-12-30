unit Forms.Main;

interface

uses
  Winapi.ActiveX, Winapi.CommCtrl, System.SysUtils, System.Variants,
  System.Classes, System.Types, System.UITypes, System.IOUtils, System.Math,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics,
  Vcl.Imaging.pngimage, Vcl.Dialogs, Vcl.ComCtrls,
  Analysis, Analysis.Spectrum, Analysis.Spectrum.Palette,
  DragDrop, DropTarget, DropSource, DragDropFile,
  System.Actions, Vcl.ActnList, Vcl.Menus,
  Frames.Progress, Frames.About, Frames.Export, Forms.Dialog;

type
  TfrmMain = class(TForm)
    imgSpectrum: TImage;
    actlstMain: TActionList;
    actOpen: TAction;
    dlgOpenFile: TFileOpenDialog;
    pmMain: TPopupMenu;
    miOpenFile: TMenuItem;
    actSave: TAction;
    dlgSaveGraphic: TFileSaveDialog;
    miSavePicture: TMenuItem;
    miSeparator1: TMenuItem;
    actAbout: TAction;
    miAbout: TMenuItem;
    actExport: TAction;
    miExportSpectrum: TMenuItem;
    imgPopupMenu: TImage;
    procedure FormResize(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actlstMainUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actAboutExecute(Sender: TObject);
    procedure imgPopupMenuClick(Sender: TObject);
    procedure actExportExecute(Sender: TObject);
  private
    const
      AppName = 'Sound Analyzer';
      AppVers = 'v.1.3 by M.A.D.M.A.N.';
  private
    FAnalyzer: TAnalyzer;
    {FDropExporter: TDropFileSource;}

    function GraphicAvailable: Boolean; inline;

    procedure ConvertToPNG(AGraphic: TGraphic; const APath: string); inline;

    procedure OpenFile(const AFileName: string);
    procedure ShowDropIcon;
    procedure ShowSpectrum;

    procedure OnDropFile(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    {procedure OnGetDragImage(Sender: TObject;
      const DragSourceHelper: IDragSourceHelper; var Handled: Boolean);}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.actAboutExecute(Sender: TObject);
begin
  with TfrmDialog.Create(Self, TfrAbout) do
  try
    with TfrAbout(Frame) do
    begin
      lblAppName.Caption := AppName;
      lblAppVers.Caption := AppVers;
    end;

    ShowModal;
  finally
    Free;
  end;
end;

procedure TfrmMain.actExportExecute(Sender: TObject);
var
  bmp: TBitmap;
begin
  with TfrmDialog.Create(Self, TfrSettings) do
  try
    if (ShowModal = mrOk) and dlgSaveGraphic.Execute then
    begin
      bmp := TBitmap.Create;
      try
        with TfrSettings(Frame) do
          FAnalyzer.Draw(bmp, Integer.Parse(medtHeight.Text),
            Integer.Parse(medtWidth.Text));

        ConvertToPNG(bmp, ChangeFileExt(dlgSaveGraphic.FileName, '.png'))
      finally
        bmp.Free;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TfrmMain.actlstMainUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  actSave.Enabled := GraphicAvailable;
  actExport.Enabled := actSave.Enabled;
end;

procedure TfrmMain.actOpenExecute(Sender: TObject);
begin
  if dlgOpenFile.Execute then
    OpenFile(dlgOpenFile.FileName);
end;

procedure TfrmMain.actSaveExecute(Sender: TObject);
begin
  if dlgSaveGraphic.Execute then
    ConvertToPNG(imgSpectrum.Picture.Graphic, ChangeFileExt(dlgSaveGraphic.FileName, '.png'))
end;

procedure TfrmMain.ConvertToPNG(AGraphic: TGraphic; const APath: string);
var
  img: TPngImage;
begin
  img := TPngImage.Create;
  try
    img.Assign(AGraphic);
    img.SaveToFile(APath);
  finally
    img.Free;
  end;
end;

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Caption := AppName;

  FAnalyzer := TAnalyzer.Create;
  with FAnalyzer do
  begin
    PaletteType := ptSOX;
    PaletteSize := 251;
    FFTLength   := 1024;
    FFTWindow   := 1;
    WindowType  := wtHann;
  end;

  ShowDropIcon;

  with TDropFileTarget.Create(Self) do
  begin
    DragTypes := [dtCopy{, dtMove, dtLink}];
    OnDrop    := OnDropFile;
    Target    := Self;
  end;

  (*FDropExporter := TDropFileSource.Create(Self);
  with FDropExporter do
  begin
    DragTypes       := [dtCopy{dtMove, dtLink}];
    OnGetDragImage  := Self.OnGetDragImage;
    ShowImage       := True;
  end;*)
end;

(*procedure TfrmMain.imgSpectrumMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  s: string;
  img: TPngImage;
begin
  if (Button = mbLeft) and GraphicAvailable then
  with FDropExporter do
  begin
    Files.Clear;

    s := TPath.GetTempPath + 'spectrum.png';

    img := TPngImage.Create;
    try
      img.Assign(imgSpectrum.Picture.Graphic);
      img.SaveToFile(s);

      Files.Add(s);

      if Execute <> drDropMove then
        TFile.Delete(s);
    finally
      img.Free;
    end;
  end; *)

destructor TfrmMain.Destroy;
begin
  FAnalyzer.Free;
  inherited;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  if GraphicAvailable then
    ShowSpectrum;
end;

function TfrmMain.GraphicAvailable: Boolean;
begin
  Result := imgSpectrum.Picture.Graphic.InheritsFrom(Vcl.Graphics.TBitmap);
end;

procedure TfrmMain.imgPopupMenuClick(Sender: TObject);
begin
  with ClientToScreen(Point(imgPopupMenu.Left, imgPopupMenu.Top + imgPopupMenu.Height + 4)) do
    pmMain.Popup(X, Y);
end;

procedure TfrmMain.OnDropFile(Sender: TObject; ShiftState: TShiftState;
  Point: TPoint; var Effect: Integer);
var
  dt: TDropFileTarget absolute Sender;
begin
  if (dt.Files.Count > 0) then
    OpenFile(dt.Files[0]);

  Effect := DROPEFFECT_NONE;
end;

{procedure TfrmMain.OnGetDragImage(Sender: TObject;
  const DragSourceHelper: IDragSourceHelper; var Handled: Boolean);
var
  shDragImage: TSHDRAGIMAGE;
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  try
    bmp.Height := 256;
    bmp.Width := 256;
    bmp.Canvas.StretchDraw(Rect(0, 0, bmp.Width, bmp.Height), imgSpectrum.Picture.Graphic);

    with shDragImage do
    begin
      crColorKey := CLR_NONE;

      hbmpDragImage     := bmp.Handle;
      sizeDragImage.cx  := bmp.Width;
      sizeDragImage.cy  := bmp.Height;
      ptOffset.x := bmp.Width div 2;
      ptOffset.y := bmp.Height div 2;
    end;

    Handled := Succeeded(DragSourceHelper.InitializeFromBitmap(shDragImage,
      TCustomDropSource(Sender) as IDataObject));

    if Handled then
      bmp.ReleaseHandle;
  finally
    bmp.Free;
  end;
end;}

procedure TfrmMain.OpenFile(const AFileName: string);
const
  ProgressTypeStr: array[TProgressType] of string = (
    'Декодирование…',
    'Анализ…',
    'Построение графика…'
  );
var
  pb: TfrmDialog;
begin
  if TFile.Exists(AFileName) then
  begin
    pb := TfrmDialog.Create(Self, TfrProgress);
    try
      Enabled := False;
      pb.Show;

      FAnalyzer.OnAnalyseStep := procedure (AProgressType: TProgressType;
        ADetermined: Boolean)
      begin
        with TfrProgress(pb.Frame) do
        begin
          Title         := ProgressTypeStr[AProgressType];
          IsDetermined  := ADetermined;
          Progress      := 0;
        end;

        Application.ProcessMessages;
      end;

      FAnalyzer.OnProgress := procedure (AValue: Int64)
      begin
        TfrProgress(pb.Frame).Progress := AValue;
        Application.ProcessMessages;
      end;

      if FAnalyzer.Analyse(AFileName) then
        ShowSpectrum
      else
      begin
        ShowDropIcon;
        MessageDlg('Файл не содержит аудио потоков', mtWarning, [mbOK], -1);
      end;
    finally
      Enabled := True;
      pb.Free;
    end;
  end;
end;

procedure TfrmMain.ShowDropIcon;
var
  rs: TResourceStream;
  img: TPngImage;
begin
  img := TPngImage.Create;
  try
    rs := TResourceStream.Create(hInstance, 'DropIcon', RT_RCDATA);
    try
      img.LoadFromStream(rs);
      imgSpectrum.Center := True;
      imgSpectrum.Picture.Graphic := img;
    finally
      rs.Free;
    end;
  finally
    img.Free;
  end;
end;

procedure TfrmMain.ShowSpectrum;
begin
  imgSpectrum.Center := False;
  imgSpectrum.Picture.Bitmap.Height := imgSpectrum.Height;
  imgSpectrum.Picture.Bitmap.Width  := imgSpectrum.Width;

  FAnalyzer.Draw(imgSpectrum.Picture.Bitmap);
end;

end.
