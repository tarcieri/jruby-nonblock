require 'spec_helper'

describe TCPSocket do
  let(:addr)     { "127.0.0.1" }
  let(:tcp_port) { 12321 }
  let(:payload)  { "JUNK IN THE TUBES" }
  let(:server)   { TCPServer.new addr, tcp_port }
  let(:peer)     { server.accept }
  
  subject do
    server
    client = TCPSocket.new addr, tcp_port
    peer
    client
  end
  
  after do
    subject.close
    server.close
    peer.close
  end
  
  it "supports non-blocking writes" do
    subject.write_nonblock(payload).should == payload.length

    loop do
      begin
        subject.write_nonblock(payload)
      rescue Errno::EWOULDBLOCK
        break
      end
    end
  end
end