unit CtwHelper;

interface

uses
  ToolsAPI;

type
  // base module creator class, with default implementations
  TCtwBaseModuleCreator = class (TInterfacedObject, IOTAModuleCreator)
  private
    FTextSource: string;
    FFormSource: string;
    FFormName: string;
    FSourceFileName: string;
  public
    property TextSource: string read FTextSource write FTextSource;
    property FormSource: string read FFormSource write FFormSource;
    property FormName: string read FFormName write FFormName;
    property SourceFileName: string read FSourceFileName write FSourceFileName;
  public
    procedure FormCreated(const FormEditor: IOTAFormEditor);
    function GetAncestorName: String;
    function GetCreatorType: String;
    function GetExisting: Boolean;
    function GetFileSystem: String;
    function GetFormName: String;
    function GetImplFileName: String;
    function GetIntfFileName: String;
    function GetMainForm: Boolean;
    function GetOwner: IOTAModule;
    function GetShowForm: Boolean;
    function GetShowSource: Boolean;
    function GetUnnamed: Boolean;
    function NewFormFile(const FormIdent: String;
      const AncestorIdent: String): IOTAFile;
    function NewImplSource(const ModuleIdent: String;
      const FormIdent: String; const AncestorIdent: String): IOTAFile;
    function NewIntfSource(const ModuleIdent: String;
      const FormIdent: String; const AncestorIdent: String): IOTAFile;
  end;



implementation

uses
  IStreams, CtwManager;

{ TCtwBaseModuleCreator }

procedure TCtwBaseModuleCreator.FormCreated(
  const FormEditor: IOTAFormEditor);
begin
  CantoolsManager.ShowMessage('FormCreated')
  // add more components to the form
  // nothing to do by default
end;

function TCtwBaseModuleCreator.GetAncestorName: String;
begin
  CantoolsManager.ShowMessage('GetAncestorName');
  Result := 'TForm';
end;

function TCtwBaseModuleCreator.GetCreatorType: String;
begin
  CantoolsManager.ShowMessage('GetCreatorType');
  Result := ''; // not a predefined one
end;

function TCtwBaseModuleCreator.GetExisting: Boolean;
begin
  CantoolsManager.ShowMessage('GetExisting');
  Result := FSourceFileName <> '';
end;

function TCtwBaseModuleCreator.GetFileSystem: String;
begin
  CantoolsManager.ShowMessage('GetFileSystem');
  Result := ''; // default
end;

function TCtwBaseModuleCreator.GetFormName: String;
begin
  CantoolsManager.ShowMessage('GetFormName');
  Result := FFormName;
end;

function TCtwBaseModuleCreator.GetImplFileName: String;
begin
  CantoolsManager.ShowMessage('GetImplFileName');
  Result := FSourceFileName;
end;

function TCtwBaseModuleCreator.GetIntfFileName: String;
begin
  CantoolsManager.ShowMessage('GetIntfFileName');
  Result := ''; // C++ header, if any!
end;

function TCtwBaseModuleCreator.GetMainForm: Boolean;
begin
  CantoolsManager.ShowMessage('GetMainForm');
  Result := False; // not the main form
end;

function TCtwBaseModuleCreator.GetOwner: IOTAModule;
begin
  CantoolsManager.ShowMessage('GetOwner');
  Result := ToolsAPI.GetActiveProject;
end;

function TCtwBaseModuleCreator.GetShowForm: Boolean;
begin
  CantoolsManager.ShowMessage('GetShowForm');
  Result := FFormSource <> ''; // form visible, if form code is there
end;

function TCtwBaseModuleCreator.GetShowSource: Boolean;
begin
  CantoolsManager.ShowMessage('GetShowSource');
  Result := True; // source visible in editor
end;

function TCtwBaseModuleCreator.GetUnnamed: Boolean;
begin
  CantoolsManager.ShowMessage('GetUnnamed');
  // unnamed if there is no file
  Result := True; // FSourceFileName = ''; // new name when first saved
end;

function TCtwBaseModuleCreator.NewFormFile(const FormIdent,
  AncestorIdent: String): IOTAFile;
begin
  CantoolsManager.ShowMessage('NewFormFile');
  // this is where you return the form source code

  if FFormSource <> '' then
    Result := TOTAFile.Create (FormSource)
  else
    Result := nil;
end;

function TCtwBaseModuleCreator.NewImplSource(const ModuleIdent, FormIdent,
  AncestorIdent: String): IOTAFile;
begin
  CantoolsManager.ShowMessage('NewImplSource');
  // here you return the unit code
  if FFormSource <> '' then
    Result := TOTAFile.Create (TextSource)
  else
    Result := nil;
end;

function TCtwBaseModuleCreator.NewIntfSource(const ModuleIdent, FormIdent,
  AncestorIdent: String): IOTAFile;
begin
  CantoolsManager.ShowMessage('NewIntfSource');
  Result := nil; // no interface in Delphi
end;

end.
