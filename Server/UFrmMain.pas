unit UFrmMain;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls;

type
  TFrmMain = class(TForm)
    grp_1: TGroupBox;
    btn_1: TButton;
    btn_2: TButton;
    chk_1: TCheckBox;
    chk_2: TCheckBox;
    chk_3: TCheckBox;
    procedure btn_1Click(Sender: TObject);
    procedure btn_2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}
uses
  UDmSys;

procedure TFrmMain.btn_1Click(Sender: TObject);
begin
  gSysConfig.Value['AutoStart'] := chk_3.Checked;
  gSysConfig.Value['RemoteDb'] := chk_1.Checked;
  gSysConfig.Value['WebSocket'] := chk_2.Checked;
  DmSys.StartSrv;
end;

procedure TFrmMain.btn_2Click(Sender: TObject);
begin
  DmSys.StopSrv;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  DmSys.StopSrv;
  with TStringList.Create do
  try
    Text := gSysConfig.ToJSON;
    SaveToFile('sys.config');
  finally
    Free;
  end;

end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  chk_1.Checked := gSysConfig.Value['RemoteDb'];
  chk_2.Checked := gSysConfig.Value['WebSocket'];
  chk_3.Checked := gSysConfig.Value['AutoStart'];
  if chk_3.Checked then
    DmSys.StartSrv;
end;

end.

