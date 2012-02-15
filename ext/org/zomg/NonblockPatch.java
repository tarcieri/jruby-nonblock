package org.zomg;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.runtime.load.Library;

public class NonblockPatch implements Library {
    private Ruby ruby;

    public void load(final Ruby ruby, boolean bln) {
        this.ruby = ruby;

        RubyClass tcpSocket = ruby.getClass("TCPSocket");
    }
}