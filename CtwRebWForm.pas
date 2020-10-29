unit CtwRebWForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, DockForm;

type
  TRebWizForm = class(TDockableForm)
    ListBoxFiles: TListBox;
    Panel1: TPanel;
    Label1: TLabel;
    EditDir: TEdit;
    BtnGetFiles: TButton;
    BtnCompileAll: TButton;
    BtnOpen: TButton;
    BtnCompOne: TButton;
    procedure BtnGetFilesClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOpenClick(Sender: TObject);
    procedure BtnCompOneClick(Sender: TObject);
    procedure BtnCompileAllClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditDirDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ExamineDir (CurrDir: string);
    procedure DoCompile;
  end;

var
  RebWizForm: TRebWizForm;

implementation

{$R *.DFM}

uses
  ToolsAPI, CtwManager, FileCtrl;

procedure TRebWizForm.BtnGetFilesClick(Sender: TObject);
begin
  ListBoxFiles.Items.Clear;
  ExamineDir (EditDir.Text);
  // enable all buttons
  BtnOpen.Enabled := True;
  BtnCompOne.Enabled := True;
  BtnCompileAll.Enabled := True;
  // save last folder to registry
  CantoolsManager.WriteSetting('rebuildwizardfolder', EditDir.Text);
end;

procedure TRebWizForm.EditDirDblClick(Sender: TObject);
var
  sDir: string;
begin
  sDir := EditDir.Text;
  SelectDirectory (sDir, []);
  EditDir.Text := sDir;
end;

procedure TRebWizForm.ExamineDir (CurrDir: string);
var
  sr: TSearchRec;
begin
  if FindFirst (CurrDir + pathDelim + '*.*',
    faAnyFile, sr) = 0 then
  repeat
    // look for Delphi project files
    if SameText (ExtractFileExt (sr.Name), '.dproj') then
//    if SameText (ExtractFileExt (sr.Name), '.dpr') or
//      SameText (ExtractFileExt (sr.Name), '.dpk') then
    begin
      ListBoxFiles.Items.Add (CurrDir + pathDelim + sr.Name);
    end;
    // look for subfolders and recurse
    if ((sr.Attr and faDirectory) <> 0) and
      (sr.Name <> '.') and (sr.Name <> '..') then
    begin
      // should rather use a thread...
      Application.ProcessMessages;
      ExamineDir (CurrDir + pathDelim + sr.Name);
    end;
  until FindNext (sr) <> 0;
  FindClose (sr);
end;

procedure TRebWizForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  RebWizForm := nil;
end;

procedure TRebWizForm.BtnOpenClick(Sender: TObject);
var
  CurrPrj: string;
begin
  with ListBoxFiles do
    CurrPrj := Items [ItemIndex];
  (BorlandIDEServices as IOTAActionServices).
    OpenFile (CurrPrj);
end;

procedure TRebWizForm.BtnCompOneClick(Sender: TObject);
var
  CurrPrj: string;
begin
  with ListBoxFiles do
    CurrPrj := Items [ItemIndex];
  (BorlandIDEServices as IOTAActionServices).OpenFile (CurrPrj);
  DoCompile;
end;

procedure TRebWizForm.DoCompile;
var
  HDelphi: THandle;
  ObjDelphi: TWinControl;
  Meth1: TMethod;
  Evt: TNotifyEvent;
  P: Pointer;
begin
  HDelphi := FindWindow ('TAppBuilder', nil);
  if HDelphi = 0 then
    raise Exception.Create ('Delphi not found');
  ObjDelphi := FindControl (hDelphi);
  if ObjDelphi <> nil then
  begin
    P := ObjDelphi.MethodAddress ('ProjectBuild');
    Meth1.Code := P;
    Meth1.Data := ObjDelphi;
    Evt := TNotifyEvent (Meth1);
    Evt (ObjDelphi);
  end
  else
    ShowMessage ('AppBuilder object not accessible');
end;

procedure TRebWizForm.BtnCompileAllClick(Sender: TObject);
var
  CurrPrj: string;
  I: Integer;
begin
  with ListBoxFiles do
    for I := 0 to Items.Count - 1 do
    begin
      CurrPrj := Items [I];
      (BorlandIDEServices as IOTAActionServices).OpenFile (CurrPrj);
      DoCompile;
    end;
end;

procedure TRebWizForm.FormCreate(Sender: TObject);
begin
  EditDir.Text := CantoolsManager.ReadSetting('rebuildwizardfolder');
end;

initialization

finalization
  if Assigned (RebWizForm) then
    FreeAndNil (RebWizForm);

end.
