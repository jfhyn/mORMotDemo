unit UDmSys;

interface

uses
  SysUtils,
  StrUtils,
  Classes,
  NativeXml,
  SHA,
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
  private
    function CheckMsgSignature(token, timestamp, nonce, signature: string): Boolean;
  public
    function Request(Ctxt: THttpServerRequest): cardinal; override;
  published
    procedure weixin(Ctxt: TSQLRestServerURIContext);
  end;

  TDmSys = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    fModel: TSQLModel;
    fServer: TSQLRestServerDB;
    fHttpServer: TMORMotHttpServer;
    fRemoteDb: TSQLDBServerSockets;
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
  doc: TJSONVariantData;
  str1: string;
  ts: TStrings;
  i: Integer;
  aXml: TNativeXml;
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
  else if leftstr(UpperCaseU(Ctxt.URL), 7) = '/WEIXIN' then
  begin
    if Pos('echostr', Ctxt.URL) > 0 then
    begin
      str1 := Ctxt.URL + '&' + Ctxt.InContent;
      Delete(str1, 1, 8);
      with TStringList.Create do
      try
        Delimiter := '&';
        DelimitedText := str1;
        if CheckMsgSignature(gSysConfig.Value['token'], Values['timestamp'],
          Values['nonce'], Values['signature']) then
          Ctxt.OutContent := Values['echostr']
        else
          Ctxt.OutContent := 'error';
      finally
        Free;
      end;
    end
    else
    begin
      aXml := TNativeXml.Create(nil);
      doc.Init;
      with aXml do
      try
        XmlFormat := xfReadable;
        Charset := 'utf-8';
        ReadFromString('<?xml version="1.0" charset="utf-8"?>' + UTF8ToString(Ctxt.InContent));
        for i := 0 to Root.NodeCount - 1 do
          doc.value[Root.Nodes[i].Name] := Root.Nodes[i].Value;
        if doc.Value['Content'] <> '' then
          FileName := FormatUTF8('weixin\%.xml', [doc.Value['Content']])
        else
          FileName := FormatUTF8('weixin\%%.xml', [doc.Value['Event'], doc.Value
            ['EventKey']]);
        if not FileExists(FileName) then
        begin
          if gSysConfig.Value['NoError'] then
            doc.value['Content'] := '这是默认信息'
          else
            doc.value['Content'] := '[' + FileName + ']不存在';
          FileName := 'weixin\nofile.xml';
        end;
        SynMustacheTemplate := TSynMustache.Parse(AnyTextFileToString(FileName));
        Ctxt.OutContent := StringToUTF8(SynMustacheTemplate.Render(_JsonFast(doc.ToJSON)));
        Ctxt.OutContentType := 'text/xml';
      finally
        FreeAndNil(aXml);
      end;
    end;
    Result := 200;
  end
  else
    Result := inherited Request(Ctxt);
end;

function StringListCompareStrings(List: TStringList; Index1, Index2: Integer): Integer;
begin
  if List.Strings[Index1] > List.Strings[Index2] then
    Result := 1
  else if List.Strings[Index1] < List.Strings[Index2] then
    Result := -1
  else
    Result := 0;
end;

function TMORMotHttpServer.CheckMsgSignature(token, timestamp, nonce, signature:
  string): Boolean;
var
  s1: string;
  slite: TStringList;
begin
  slite := TStringList.Create;
  slite.Append(token);
  slite.Append(timestamp);
  slite.Append(nonce);
  slite.CustomSort(StringListCompareStrings);
  s1 := StringReplace(slite.Text, #13#10, EmptyStr, [rfReplaceAll]);
  slite.Free;
  Result := signature = SHA1(s1);
end;

procedure TMORMotHttpServer.weixin(Ctxt: TSQLRestServerURIContext);
var
  aXml: TNativeXml;
begin
  with Ctxt do
  begin
    if CheckMsgSignature(gSysConfig.Value['token'], InputString['timestamp'],
      InputString['nonce'], InputString['signature']) then
      Returns(InputString['echostr']);
  end;
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
      fRemoteDb := TSQLDBServerSockets.Create(gProps, 'remote', '8092', 'mORMot',
        'mORMot');
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

