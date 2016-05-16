program SynSrv;

uses
  FastMM4,
  Forms,
  UFrmMain in 'UFrmMain.pas' {FrmMain},
  UDmSys in 'UDmSys.pas' {DmSys: TDataModule},
  URecords in 'URecords.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDmSys, DmSys);
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.

