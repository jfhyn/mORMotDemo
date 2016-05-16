unit UDmSys;

interface

uses
  SysUtils,
  Classes,
  SynCommons,
  SynDB,
  SynCrossPlatformJSON,
  mORMot,
  mORMotDB,
  SynCrtSock,
  SynBidirSock,
  SynDBMidasVCL,
  SynDBRemote,
  mORMotHttpServer,
  mORMotSQLite3,
  SynSQLite3,
  SynOleDB,
  SynDBZeos,
  SynDBSQLite3,
  SynMustache,
  SynSQLite3Static;

type
  TWebSocketProtocolEcho = class(TWebSocketProtocolChat)
  protected
    procedure EchoFrame(Sender: THttpServerResp; const Frame: TWebSocketFrame);
  end;

  TMORMotHttpServer = class(TSQLHttpServer)
  public
    function Request(Ctxt: THttpServerRequest): cardinal; override;
  end;

  TDmSys = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    fModel: TSQLModel;
    fServer: TSQLRestServerDB;
    fHttpServer: TMORMotHttpServer;
    fRemoteDb: TSQLDBServerHttpApi;
    fprotocol: TWebSocketProtocolEcho;
  public
    { Public declarations }
    procedure StartSrv();
    procedure StopSrv();
  end;

var
  DmSys: TDmSys;
  gProps: TSQLDBConnectionProperties;
  gSysConfig: TJSONVariantData;
  gServerStart: Boolean;

implementation

{$R *.dfm}

{ TMORMotHttpServer }
uses
  URecords;

function TMORMotHttpServer.Request(Ctxt: THttpServerRequest): cardinal;
var
  FileName: TFileName;
  SynMustacheTemplate: TSynMustache;
begin
  if (Ctxt.Method = 'GET') and (Ctxt.URL = '/') then
  begin
    FileName := ExeVersion.ProgramFilePath + 'www\index.html';
    SynMustacheTemplate := TSynMustache.Parse(AnyTextFileToString(FileName));
    Ctxt.OutContent := SynMustacheTemplate.Render(_JsonFast(gSysConfig.ToJSON));
    Ctxt.OutContentType := 'text/html;charset=utf-8';
    Result := 200;
  end
  else if (Ctxt.Method = 'GET') and IdemPChar(pointer(Ctxt.URL), '/STATIC/') and
    (PosEx('..', Ctxt.URL) = 0) then
  begin
    FileName := ExeVersion.ProgramFilePath + 'www\' + UTF8ToString(Copy(Ctxt.URL,
      8, MaxInt));
    Ctxt.OutContent := StringToUTF8(FileName);
    Ctxt.OutContentType := HTTP_RESP_STATICFILE;
    Result := 200;
  end
  else
    Result := inherited Request(Ctxt);
end;

{ TDmSys }

procedure TDmSys.StartSrv;
begin
  if not gServerStart then
  begin
    gProps := TSQLDBConnectionProperties.CreateFromFile(ExeVersion.ProgramFilePath
      + 'db.config');

    fModel := TSQLModel.Create([TSQLRecordPeople]);
    VirtualTableExternalRegisterAll(fModel, gProps);
    fServer := TSQLRestServerDB.Create(fModel, ':memory:', False);
    fServer.CreateMissingTables();
    if gSysConfig.Value['WebSocket'] then
    begin
      fprotocol := TWebSocketProtocolEcho.Create('ws', 'ws');
      fprotocol.OnIncomingFrame := fprotocol.EchoFrame;
      fHttpServer := TMORMotHttpServer.Create('80', [fServer], '+', useBidirSocket);
      fHttpServer.WebSocketsEnable('ws', '', True).WebSocketProtocols.Add(fprotocol);
    end
    else
      fHttpServer := TMORMotHttpServer.Create('80', [fServer], '+', useHttpApi);
    if gSysConfig.Value['RemoteDb'] then
      fRemoteDb := TSQLDBServerHttpApi.Create(gProps, 'remote','mORMot','mORMot');
    gServerStart := True;
  end;
end;

procedure TDmSys.StopSrv;
begin
  if gServerStart then
  begin
    FreeAndNil(fHttpServer);
    FreeAndNil(fServer);
    FreeAndNil(fModel);
    FreeAndNil(fRemoteDb);
    FreeAndNil(gProps);
  end;
end;

{ TWebSocketProtocolEcho }

procedure TWebSocketProtocolEcho.EchoFrame(Sender: THttpServerResp; const Frame:
  TWebSocketFrame);
var
  aFrame: TWebSocketFrame;
  doc: TJSONVariantData;
begin
  aFrame := Frame;
  case Frame.opcode of
    focText:
      try
        doc.init(Frame.payload);
        if doc.value['type'] = 'qry' then
          aFrame.payload := gProps.ExecuteInlined(doc.value['sql'], True).FetchAllAsJSON
            (True)
        else if doc.value['type'] = 'sql' then
          aFrame.payload := FormatUTF8('%d', [gProps.ExecuteNoResult(doc.value['sql'],
            [])])
        else
          aFrame.payload := 'unsorport type';
      except
        on e: Exception do
          aFrame.payload := FormatUTF8('{"error":"%"}', [e.Message]);
      end;
  end;
  SendFrame(Sender, aFrame);
end;

procedure TDmSys.DataModuleCreate(Sender: TObject);
begin
  gSysConfig.Init(AnyTextFileToRawUTF8('sys.config'));
end;

end.

