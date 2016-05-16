unit UDmClient;

interface

uses
  SysUtils,
  Classes,
  SynDB,
  SynDBRemote,
  SynDBMidasVCL,
  MidasLib;

type
  TDmClient = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function getDataSet(): TSynDBDataSet;
    function getSql(const aSql: string): integer;
    function getConn: TSQLDBConnection;
    function getStatement: TSQLDBStatement;
  end;

var
  DmClient: TDmClient;
  gConn: TSQLDBSocketConnectionProperties;
  gTick: Int64;

implementation

{$R *.dfm}

procedure TDmClient.DataModuleCreate(Sender: TObject);
begin
  gConn := TSQLDBSocketConnectionProperties.Create('127.0.0.1:8092', 'remote',
    'mORMot', 'mORMot');
end;

procedure TDmClient.DataModuleDestroy(Sender: TObject);
begin
  gConn.ClearConnectionPool;
  gConn.Free;
end;

function TDmClient.getConn: TSQLDBConnection;
begin
  Result := gConn.MainConnection;
end;

function TDmClient.getDataSet(): TSynDBDataSet;
begin
  Result := TSynDBDataSet.Create(nil);
  Result.Connection := gConn.MainConnection.Properties;
end;

function TDmClient.getSql(const aSql: string): integer;
begin
  with gConn do
    Result := ExecuteNoResult(aSql, []);
end;

function TDmClient.getStatement: TSQLDBStatement;
begin
  Result := gConn.NewThreadSafeStatement;
end;

end.

