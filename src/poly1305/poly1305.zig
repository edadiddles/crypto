const std = @import("std");
const State = @import("state.zig").Poly1305State;
const block = @import("block.zig");
const math = @import("math.zig");

const Poly1305 = struct {
    state: State,

    pub fn init(key: [32]u8) Poly1305 {
        return .{
            .state = State.init(key),
        };
    }

    pub fn update(self: *Poly1305, msg: []const u8) void {
        var input = msg;

        if(self.state.buf_len > 0) {
            const want = 16 - self.state.buf_len;
            const take = @min(want, input.len);

            @memcpy(
                self.state.buf[self.state.buf_len..][0..take],
                input[0..take],
            );

            self.state.buf_len += take;
            input = input[take..];

            if (self.state.buf_len == 16) {
                self.state.incrementCounter(16);
                block.processBlock(&self.state, &self.state.buf, false);
                self.state.buf_len = 0;
            }
        }

        while (input.len >= 16) {
            self.state.incrementCounter(16);
            block.processBlock(&self.state, &input[0..16].*, false);
            input = input[16..];
        }

        if (input.len > 0) {
            @memcpy( 
                self.state.buf[0..input.len],
                input[0..]
            );
            self.state.buf_len = input.len;
        }
    }

    pub fn finalize(self: *Poly1305, out: *[16]u8) void {
        if (self.state.buf_len > 0) {
            self.state.buf[self.state.buf_len] = 1;
            for (self.state.buf_len + 1 .. 16) |i| {
                self.state.buf[i] = 0;
            }

            self.state.incrementCounter(self.state.buf_len);
            block.processBlock(&self.state, &self.state.buf, true);
        } else {
            self.state.incrementCounter(0);
            block.processBlock(&self.state, &[_]u8{0}**16, true);
        }

        math.finalizeReduce(&self.state.h);

        var f: u64 = 0;
        f = (@as(u64, self.state.h[0])) |
            (@as(u64, self.state.h[1]) << 26) |
            (@as(u64, self.state.h[2]) << 52) |
            (@as(u64, self.state.h[3]) << 78) |
            (@as(u64, self.state.h[4]) << 104);

        f +%= self.state.s;

        std.mem.writeInt(u128, out, @intCast(f), .little);
    }
};



test "Empty message" {
    const key: [32]u8 = .{
        0x85,0xd6,0xbe,0x78,0x57,0x55,0x6d,0x33,
        0x7f,0x44,0x52,0xfe,0x42,0xd5,0x06,0xa8,
        0x01,0x03,0x80,0x8a,0xfb,0x0d,0xb2,0xfd,
        0x4a,0xbf,0xf6,0xaf,0x41,0x49,0xf5,0x1b,
    };
    const msg = "";
    const expected: [16]u8 = .{
        0xcd,0x92,0x0b,0xff,0x7a,0x7c,0x08,0xdc,
        0x5f,0x2f,0x00,0x78,0xfa,0x63,0x4b,0xff,
    };
    var out: [16]u8 = undefined;

    var poly1305 = Poly1305.init(key);
    poly1305.update(msg);
    poly1305.finalize(&out);
    std.testing.expectEqualSlices(expected, out);
}
