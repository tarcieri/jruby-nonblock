require 'spec_helper'

describe TCPSocket do
  let(:addr)     { "127.0.0.1" }
  let(:tcp_port) { rand(10000) + 10000 }
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
  
  context :write_nonblock do
    it "writes if the operation won't block" do
      subject.write_nonblock(payload).should == payload.length
      peer.read(payload.length).should == payload
    end
    
    it "raises Errno::EWOULDBLOCK if the operation would block" do
      expect do
        loop { subject.write_nonblock(payload) }
      end.to raise_exception(Errno::EWOULDBLOCK)
    end
  end
end