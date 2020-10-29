unit CtwManager;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ToolsApi, Menus, TypInfo, Contnrs, Registry, ExtCtrls, ComCtrls,
  ActnList;

type
  TCanWiz = class
  public
    function MenuText: string; virtual; abstract;
    procedure Execute (Sender: TObject); virtual; abstract;
  end;

  TCantoolsManager = class (TInterfacedObject,
    IOTANotifier, IOTAWizard)
  private
    BaseRegKey: string;
    CantoolsMenu: TMenuItem;

    FPlugInInfoCode: Integer;
    fProductBitmap: HBITMAP;
    MessageGroup: IOTAMessageGroup;

    procedure AddMenu(CanWiz: TCanWiz);
  public
    WizardsList: TObjectList;

    // specific methods
    constructor Create;
    destructor Destroy; override;

    procedure Add (CanWiz: TCanWiz);
    procedure CreateMenu;
    procedure AddToAboutBox;
    procedure RemoveFromAboutBox;
    procedure RefreshMenu;
    class procedure ShowSplash;

    function ReadSetting (const KeyName: string): string;
    procedure WriteSetting (const KeyName, KeyValue: string);

    procedure ShowMessage (const strMessage: string);

    // event handler
    procedure AboutExecute (Sender: TObject);

    // IOTANotifier interface
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;

    // IOTAWizard interface
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;
  end;

var
  // gobal variable for the wizards manager
  CantoolsManager: TCantoolsManager;

procedure Register;

implementation

uses
  ImgList;

{$R Objects.res}

procedure Register;
begin
  RegisterPackageWizard(CantoolsManager);
end;

procedure TCantoolsManager.AboutExecute(Sender: TObject);
begin
  // ShowMessage ('About...');
end;

procedure TCantoolsManager.Add(CanWiz: TCanWiz);
begin
  // add to the internal list (accounts for destruction)
  WizardsList.Add(CanWiz);
  if Assigned (CantoolsMenu) then
    AddMenu (CanWiz);
end;

procedure TCantoolsManager.AddMenu(CanWiz: TCanWiz);
begin
  // add a menu for the wizard
  CantoolsMenu.Add (NewItem (
    CanWiz.MenuText, 0, False, True,
    CanWiz.Execute, 0, CanWiz.ClassName));
end;

procedure TCantoolsManager.AddToAboutBox;
begin
  fProductBitmap := LoadBitmap(HInstance, 'OBJECTS');
  FPlugInInfoCode :=
    (BorlandIDEServices as IOTAAboutBoxServices).
    AddPluginInfo(
    'Cantools', 'Marco Cantù''s Wizards Collection', fProductBitmap, False,
    'Copyright 2020 www.marcocantu.com', 'Version 10.4');
end;

procedure TCantoolsManager.AfterSave;
begin
end;

procedure TCantoolsManager.BeforeSave;
begin
end;

constructor TCantoolsManager.Create;
begin
  inherited Create;
  // create the list
  WizardsList := TObjectList.Create; // owns objects
  // registry
  BaseRegKey := (BorlandIDEServices as IOTAServices).
    GetBaseRegistryKey + '\CanTools';

  CreateMenu;
  AddToAboutBox;
end;

procedure TCantoolsManager.CreateMenu;
var
  DMenu: TMainMenu;
  I: Integer;
begin
  // create a secondary menu for the set of wizards
  DMenu := (BorlandIDEServices as INTAServices).MainMenu;

  if not Assigned (CantoolsMenu) then
  begin
    CantoolsMenu := NewItem ('Cantools', 0, False,
      True, nil, 0, 'Cantoolsmenu');

    // add items for the current wizards
    for I := 0 to WizardsList.Count - 1 do
      AddMenu (WizardsList[i] as TCanWiz);
  end;

  if ReadSetting ('MainMenuItem') <> '' then
    DMenu.Items.Insert(DMenu.Items.Count-2, CanToolsMenu)
  else
    for I := 0 to DMenu.Items.Count - 1 do
    begin
      if DMenu.Items[I].Name = 'ToolsMenu' then
        DMenu.Items[I].Insert (0, CantoolsMenu);
    end;
end;

destructor TCantoolsManager.Destroy;
begin
  FreeAndNil (CantoolsMenu);
  FreeAndNil (WizardsList); // owns objects

  RemoveFromAboutBox;
  CantoolsManager := nil;

  inherited;
end;

procedure TCantoolsManager.Destroyed;
begin
end;

procedure TCantoolsManager.Execute;
begin
end;

function TCantoolsManager.GetIDString: string;
begin
  Result := 'marcocantu-com-CantoolsManager-idstring';
end;

function TCantoolsManager.GetName: string;
begin
  Result := 'marcocantu-com-CantoolsManager-name';
end;

function TCantoolsManager.GetState: TWizardState;
begin
  Result := [wsEnabled]; // useless
end;

procedure TCantoolsManager.Modified;
begin
end;

function TCantoolsManager.ReadSetting(const KeyName: string): string;
var
  Reg: TRegistry;
begin
  Result := '';
  Reg := TRegistry.Create;
  try
    Reg.OpenKey(BaseRegKey, True);
    Result := Reg.ReadString(KeyName);
  finally
    Reg.Free;
  end;
end;

procedure TCantoolsManager.RefreshMenu;
begin
  // delete and re-create the menu
  CantoolsMenu.Parent.Remove (CantoolsMenu);
  CreateMenu;
end;

procedure TCantoolsManager.RemoveFromAboutBox;
begin
  if FPlugInInfoCode <> 0 then
    (BorlandIDEServices as IOTAAboutBoxServices).RemovePluginInfo(FPlugInInfoCode);
end;

procedure TCantoolsManager.ShowMessage(const strMessage: string);
begin
  if MessageGroup = nil then
    MessageGroup := (BorlandIDEServices as IOTAMessageServices).AddMessageGroup('Cantools');
  (BorlandIDEServices as IOTAMessageServices).ShowMessageView(MessageGroup);
  (BorlandIDEServices as IOTAMessageServices).AddTitleMessage(strMEssage, MessageGroup);
end;

class procedure TCantoolsManager.ShowSplash;
var
  Bitmap: HBITMAP;
begin
  Bitmap := LoadBitmap(HInstance, 'OBJECTS');
  SplashScreenServices.StatusMessage('Cantools installed');
  SplashScreenServices.AddPluginBitmap('Cantools', Bitmap);
end;

procedure TCantoolsManager.WriteSetting(const KeyName, KeyValue: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.OpenKey(BaseRegKey, True);
    Reg.WriteString(KeyName, KeyValue);
  finally
    Reg.Free;
  end;
end;

initialization
  TCanToolsManager.ShowSplash;
  CantoolsManager := TCantoolsManager.Create;

end.

