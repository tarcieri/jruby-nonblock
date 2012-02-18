require 'spec_helper'

describe TCPSocket do
  describe "#read_nonblock" do
    it "reads if the operation won't block" do
      setup_tcp do |client, peer|
        peer << "OHAI"
        client.read_nonblock(4).should == "OHAI"
      end
    end

    it "raises Errno::EWOULDBLOCK if the operation would block" do
      setup_tcp do |client, peer|
        expect { client.read_nonblock(4) }.to raise_exception(Errno::EWOULDBLOCK)
      end
    end
  end

  describe '#write_nonblock' do
    let(:payload) { 'JUNK IN THE TUBES' }

    it "writes if the operation won't block" do
      setup_tcp do |client, peer|
        client.write_nonblock(payload).should eq payload.length
        peer.read(payload.length).should eq payload
      end
    end

    it "raises Errno::EWOULDBLOCK if the operation would block" do
      setup_tcp do |client, peer|
        expect do
          loop { client.write_nonblock(payload) }
        end.to raise_exception(Errno::EWOULDBLOCK)
      end
    end
  end

  def setup_tcp(&block)
    addr, tcp_port = '127.0.0.1', rand(10000) + 10000

    server = TCPServer.new(addr, tcp_port)
    client = TCPSocket.new(addr, tcp_port)
    peer   = server.accept

    block.call(client, peer)

    client.close
    server.close
    peer.close
  end
end
