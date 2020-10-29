unit CtwOopf;

interface

uses
  CtwManager, SysUtils, Classes, ToolsApi, TypInfo, Forms, Dialogs;

type
  TCanWizOopForm = class (TCanWiz)
  public
    function MenuText: string; override;
    procedure Execute (Sender: TObject); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  if Assigned (CantoolsManager) then
    CantoolsManager.Add(TCanWizOopForm.Create);
end;

procedure TCanWizOopForm.Execute  (Sender: TObject);
var
  iModule: IOTAModule;
  iSourceEditor: IOTASourceEditor;
  iIntFormEditor: INTAFormEditor;
  iView: IOTAEditView;
  aForm: TComponent;
  iWriter: IOTAEditWriter;
  I: Integer;
  strCode: UTF8String; // changed for 2009
  strName, strType: string;
  ListTypes: TStringList;
  StartPos: Integer;
  CurPos: TOTAEditPos;
  CurCharPos: TOTACharPos;
  CreateMethod: TMethod;
begin
  ListTypes := TStringList.Create;
  try
    iModule := (BorlandIDEServices as IOTAModuleServices).CurrentModule;
    if iModule = nil then
    begin
      ShowMessage ('Cantools error: File is closed');
      Exit;
    end;

    // get the interface to the form editor.
    if not Supports (iModule.CurrentEditor, INTAFormEditor, iIntFormEditor) then
    begin
      ShowMessage ('Cantools error: You must select a form');
      Exit;
    end;

    if iIntFormEditor.FormDesigner = nil then
    begin
      ShowMessage ('Cantools error: No designer for module');
      Exit;
    end;


    // get the list of components, preparing the source code
    strCode := UTF8String ('  // FormCreate event'#10#13);
    aForm := iIntFormEditor.FormDesigner.Root;
    for I := 0 to aForm.ComponentCount - 1 do
    begin
      strName := aForm.Components[i].Name;
      strType := aForm.Components[i].ClassName;
      strCode := strCode + UTF8String('  ' + strName + ' := ' +
        'FindComponent (''' + strName + ''') as ' + strType + ';'#10#13);
      // add unique class names to list
      if ListTypes.IndexOf (strType) < 0 then
        ListTypes.Add (strType);
    end;

    // TODO: move!
    strCode := strCode + UTF8String( '{'#10#13 + 'initialization'#10#13);
    strCode := strCode + UTF8String('  RegisterClasses (['#10#13);
    // add all but the last
    for I := 0 to ListTypes.Count - 2 do
      strCode := strCode + UTF8String('    ' + ListTypes [I] + ','#10#13);
    // add the last and close
    if ListTypes.Count > 0 then
      strCode := strCode +  UTF8String('    ' + ListTypes [ListTypes.Count - 1] +
        ']);'#10#13'}');

    // select or add the FormCreate method
    iIntFormEditor.FormDesigner.Activate;
    if not iIntFormEditor.FormDesigner.MethodExists ('FormCreate') then
    begin
      CreateMethod := iIntFormEditor.FormDesigner.CreateMethod('FormCreate',
        GetTypeData (TypeInfo(TNotifyEvent)));
      if aForm is TForm then
        TForm(aForm).OnCreate := TNotifyEvent(Createmethod);
    end;
    iIntFormEditor.FormDesigner.ShowMethod('FormCreate');

    if not Supports (iModule.CurrentEditor, IOTASourceEditor, iSourceEditor) then
    begin
      ShowMessage ('Cantools error: No editor found');
      Exit;
    end;

    // add the source ocde in the current position
    // TODO: find a simplified way for positioning!
    iView := iSourceEditor.GetEditView (0);
    CurPos := iView.CursorPos;
    iView.ConvertPos(True, CurPos, CurCharPos);
    StartPos := iView.CharPosToPos(CurCharPos);

    iWriter := iSourceEditor.CreateUndoableWriter;
    iWriter.CopyTo (StartPos);
    iWriter.Insert(PAnsiChar(strCode));
  finally
    ListTypes.Free;
  end;
end;

function TCanWizOopForm.MenuText: string;
begin
  Result := 'OOP Form Wizard';   // useless
end;

end.
