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
  DBClient,
  ComCtrls;

type
  TFrmMain = class(TForm)
    ds_1: TDataSource;
    dbgrd_1: TDBGrid;
    pnl: TPanel;
    lbl_1: TLabel;
    mmo_1: TMemo;
    btn_1: TButton;
    btn_2: TButton;
    btn_3: TButton;
    btn_4: TButton;
    stat_1: TStatusBar;
    procedure btn_1Click(Sender: TObject);
    procedure btn_2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn_3Click(Sender: TObject);
  private
    { Private declarations }
    ds: TSynDBDataSet;
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
  FreeAndNil(ds);
  ds := DmClient.getDataSet();
  gTick := gConn.MainConnection.ServerTimeStamp;
  with ds do
  begin
    CommandText := mmo_1.Text;
    try
      DisableControls;
      Open;
      ds_1.DataSet := ds;
      EnableControls;
    except
      ds_1.DataSet := nil;
      Execute;
    end;
    stat_1.SimpleText := IntToStr(gConn.MainConnection.ServerTimeStamp - gTick);
  end;
end;

procedure TFrmMain.btn_2Click(Sender: TObject);
begin
  ShowMessage(inttostr(DmClient.getSql(mmo_1.Text)));
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(ds);
end;

procedure TFrmMain.btn_3Click(Sender: TObject);
var
  i: integer;
begin
  with DmClient, getConn do
  begin
    gTick := gConn.MainConnection.ServerTimeStamp;
    StartTransaction;
    for i := 0 to 5000 - 1 do
      Properties.ExecuteNoResult('INSERT INTO People (FirstName,LastName,YearOfBirth,YearOfDeath) '
        + 'VALUES (?,?,?,?)', ['FirstName New ' + IntToStr(i), 'New Last', i +
        1400, 1519]);
    Commit;
    stat_1.SimpleText := IntToStr(gConn.MainConnection.ServerTimeStamp - gTick);
  end;
end;

end.

