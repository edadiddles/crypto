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
                block.processBlock(&self.state, &self.state.buf);
                self.state.buf_len = 0;
            }
        }

        while (input.len >= 16) {
            self.state.incrementCounter(16);
            block.processBlock(&self.state, &input[0..16].*);
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
            for (self.state.buf_len+1..16) |i| {
                self.state.buf[i] = 0;
            }

            self.state.incrementCounter(self.state.buf_len);
            block.processBlock(&self.state, &self.state.buf);
        }
        math.finalizeReduce(&self.state.h);

        var f0 = self.state.h[0] | (self.state.h[1] << 26);
        var f1 = (self.state.h[1] >> 6) | (self.state.h[2] << 20);
        var f2 = (self.state.h[2] >> 12) | (self.state.h[3] << 14);
        var f3 = (self.state.h[3] >> 18) | (self.state.h[4] << 8);

        var carry: u1 = 0;
        var r = @addWithOverflow(f0, self.state.s[0]);
        f0 = r[0];
        carry = r[1];
       
        r = @addWithOverflow(f1, self.state.s[1]+carry);
        f1 = r[0];
        carry = r[1];
        
        r = @addWithOverflow(f2, self.state.s[2]+carry);
        f2 = r[0];
        carry = r[1];
        
        r = @addWithOverflow(f3, self.state.s[3]+carry);
        f3 = r[0];

        std.mem.writeInt(u32, out[0..4], f0, .little);
        std.mem.writeInt(u32, out[4..8], f1, .little);
        std.mem.writeInt(u32, out[8..12], f2, .little);
        std.mem.writeInt(u32, out[12..16], f3, .little);
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
    try std.testing.expectEqualSlices(u8, &expected, &out);
}

