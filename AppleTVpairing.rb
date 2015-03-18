require 'net/http'


def ReadFromRemote(sock)
  data = sock.gets("\n")
  if data.include? "HTTP"
    sock.gets("\r\n\r\n")
    /GET \/([^ ]+) HTTP/.match(data)
    data = $1
  end
  return data
end

def ServerGET(ip,url)
  uri = URI.parse("http://#{ip}:3689#{url}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 500
  req = Net::HTTP::Get.new(uri.request_uri)
  req['Host']= "192.168.1.20:3689"
  req['User-Agent'] = "iPod"
  req['Accept'] = "text/html,application/xhtml+xml,application/xml"
  req['Accept-Language'] = "en-us"
  req['Connection'] = "keep-alive"
  req['Viewer-Only-Client'] = 1
  req['Client-Daap-Version'] = 3.10
  r = http.request(req)
  return r
end

def ServerPOST(ip,url,data)
  uri = URI.parse("http://#{ip}:3689#{url}")
  req = Net::HTTP::Post.new(uri)
  req['Host']= "192.168.1.20:3689"
  req['User-Agent'] = "iPod"
  req['Accept'] = "text/html,application/xhtml+xml,application/xml"
  req['Accept-Language'] = "en-us"
  req['Connection'] = "keep-alive"
  req['Viewer-Only-Client'] = 1
  req['Client-Daap-Version'] = 3.10
  req.body = data
  r = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end
  return r  
end

def AppleTVReply(sock)
  r = "cmpg\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00\x01"+
    "cmnm\x00\x00\x00\x06Savant"+
    "cmty\x00\x00\x00\x04iPod"
  r = "cmpa\x00\x00\x00#{r.length.chr}" + r
  sock.write "HTTP/1.1 200 OK\r\n" +
     "Content-Length: #{r.length}\r\n\r\n" + r
  sock.close
end

def AppleTVpair()
  require File.expand_path(File.dirname(__FILE__)) + '/net/dns/mdns-sd'
  handle = Net::DNS::MDNSSD.register('0000000000000000000000000000000000000001',
                          '_touch-remote._tcp', 
                          'local', 12003,
                          {"Pair"=>"0000000000000001",
                            "txtvers"=>"1",
                            "RemN"=>"Remote",
                            "DvTy"=>"iPod",
                            "RemV"=>"10000",
                            "DvNm"=>"Savant"
                           })
  server = TCPServer.open(12003)
  sock = server.accept
  port, ip = Socket.unpack_sockaddr_in(sock.getpeername)
  data = ReadFromRemote(sock)
  AppleTVReply(sock)
  sock.close
  return true
end

def AppleTVlogin(ip)
  begin
    r = ServerGET(ip,"/login?pairing-guid=0x0000000000000001").body
    /mlid....(....)/.match(r)
    sid = $1.unpack('H*')[0].to_i(16)
    return sid
  rescue
    AppleTVpair()
    retry
  end
end

AppleTVpair()
