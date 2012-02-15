package org.zomg;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.Channel;
import java.nio.channels.WritableByteChannel;
import java.nio.channels.SelectableChannel;
import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyIO;
import org.jruby.RubyString;
import org.jruby.RubyNumeric;
import org.jruby.runtime.Arity;
import org.jruby.runtime.load.Library;
import org.jruby.runtime.callback.Callback;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.Block;
import org.jruby.util.ByteList;
import org.jruby.exceptions.RaiseException;

public class NonblockPatch implements Library {
    private Ruby ruby;

    public void load(final Ruby ruby, boolean bln) {
        this.ruby = ruby;

        RubyClass io = ruby.getClass("IO");

        io.defineMethod("write_nonblock", new Callback() {
            public IRubyObject execute(IRubyObject recv, IRubyObject[] args, Block block) {
                Ruby runtime = recv.getRuntime();
                ThreadContext context = runtime.getCurrentContext();
                Channel channel = RubyIO.convertToIO(context, recv).getChannel();

                if(!(channel instanceof SelectableChannel)) {
                    throw ruby.newArgumentError("non-blocking operations not supported for this object");
                }

                ByteBuffer buffer = ByteBuffer.wrap(args[0].convertToString().getByteList().bytes());

                int nbytes;

                try {
                    ((SelectableChannel)channel).configureBlocking(false);
                    nbytes = ((WritableByteChannel)channel).write(buffer);
                } catch(IOException ie) {
                    throw runtime.newIOError(ie.getLocalizedMessage());
                }

                if(nbytes == 0) {
                    throw new RaiseException(runtime, runtime.getErrno().getClass("EWOULDBLOCK"), "not writable", true);
                }

                return RubyNumeric.int2fix(runtime, nbytes);
            }

            public Arity getArity() {
                return Arity.fixed(1);
            }
        });
    }
}
