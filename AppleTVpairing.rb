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


AppleTVpair()
