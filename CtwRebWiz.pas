unit CtwRebWiz;

interface

uses
  Windows, CtwRebWForm, Forms, CtwManager;

type
  TCanRebWiz = class (TCanWiz)
  public
    function MenuText: string; override;
    procedure Execute (Sender: TObject); override;
  end;

procedure Register;

implementation

uses
  Dialogs, SysUtils;

function TCanRebWiz.MenuText: String;
begin
  Result := '&Rebuild Wizard (Cantools)...'
end;

procedure TCanRebWiz.Execute (Sender: TObject);
begin
  // the actual code
  RebWizForm := TRebWizForm.Create (Application);
  RebWizForm.Show;
end;

procedure Register;
begin
  CantoolsManager.Add(TCanRebWiz.Create);
end;

end.
