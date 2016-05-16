unit UDmClient;

interface

uses
  SysUtils,
  Classes,
  SynDBRemote,
  SynDBMidasVCL,
  MidasLib;

type
  TDmClient = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    fConn: TSQLDBWinHTTPConnectionProperties;
  public
    { Public declarations }
    function getDataSet(): TSynDBDataSet;
    function getSql(const aSql: string): integer;
  end;

var
  DmClient: TDmClient;

implementation

{$R *.dfm}

procedure TDmClient.DataModuleCreate(Sender: TObject);
begin
  fConn := TSQLDBWinHTTPConnectionProperties.Create('127.0.0.1:8092', 'remote',
    'mORMot', 'mORMot');
end;

procedure TDmClient.DataModuleDestroy(Sender: TObject);
begin
  fConn.ClearConnectionPool;
  fConn.Destroy;
end;

function TDmClient.getDataSet(): TSynDBDataSet;
begin
  Result := TSynDBDataSet.Create(nil);
  Result.Connection := fConn.MainConnection.Properties;
end;

function TDmClient.getSql(const aSql: string): integer;
begin
  with fConn do
    Result := ExecuteNoResult(aSql, []);
end;

end.

