program rdbclient;

uses
  FastMM4,
  Forms,
  UFrmMain in 'UFrmMain.pas' {FrmMain},
  UDmClient in 'UDmClient.pas' {DmClient: TDataModule};

{$R *.res}
begin
  Application.Initialize;
  Application.CreateForm(TDmClient, DmClient);
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.

