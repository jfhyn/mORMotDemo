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
  StdCtrls,
  ExtCtrls,
  Grids,
  DBGrids,
  SynDBMidasVCL,
  DB,
  DBClient;

type
  TFrmMain = class(TForm)
    ds_1: TDataSource;
    dbgrd_1: TDBGrid;
    pnl: TPanel;
    lbl_1: TLabel;
    mmo_1: TMemo;
    btn_1: TButton;
    btn_2: TButton;
    Cds_1: TClientDataSet;
    procedure btn_1Click(Sender: TObject);
    procedure btn_2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  UDmClient;

{$R *.dfm}

procedure TFrmMain.btn_1Click(Sender: TObject);
begin
  Cds_1 := DmClient.getDataSet() as TClientDataSet;
  with Cds_1 do
  begin
    CommandText := mmo_1.Text;
    try
      Open;
    except
      Execute;
    end;
  end;
end;

procedure TFrmMain.btn_2Click(Sender: TObject);
begin
  ShowMessage(inttostr(DmClient.getSql(mmo_1.Text)));
end;

end.

