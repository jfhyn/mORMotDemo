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
    procedure btn_1Click(Sender: TObject);
    procedure btn_2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
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
end;

end.

