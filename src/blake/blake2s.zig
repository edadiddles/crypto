const std = @import("std");
const Blake2sState = @import("state.zig").Blake2sState;
const Blake2sParams = @import("params.zig").Blake2sParams;
const compress = @import("compress.zig").compress;

pub const Blake2s = struct {
    pub fn hash(input: []const u8) []const u8 {
        const state = Blake2sState;
        init(&state, 32);

        update(&state, input);

        const out: [state.out_len]u8 = undefined;
        finalize(&state, &out);

        return std.fmt.bufPrint(&out[0..state.out_len], "{x}", .{out[0..state.out_len]});
    }

    fn init(state: *Blake2sState, digest_len: u8, key: ?[]const u8) void {
        const params = Blake2sParams.init(digest_len, key.?.len);
        state.init(&params);
    }

    fn update(state: *Blake2sState, input: []const u8) void {
        for (input) |c| {
            state.buf[state.buf_len] = c;
            state.buf_len += 1;

            if (state.buf_len == 64) {
                state.increment_bytes(64);
                compress(&state, &state.buf);
                state.buf_len = 0;
            }
        }
    }

    fn finalize(state: *Blake2sState, out: *[32]u8) void {
        std.debug.assert(out.len == state.out_len);

        state.increment_bytes(state.buf_len);
        // zero pad buffer
        for (state.buf[state.buf_len..]) |b| {
            b = 0;
        }
        state.f0 = 0xffffffff;
        compress(&state, &state.buf);
        
        for (state.h, 0..) |h, k| {
            out[k] = h & 255;
            out[k+1] = h >> 8 & 255;
            out[k+2] = h >> 16 & 255;
            out[k+3] = h >> 24 & 255;
        }
        
    }
};

test "hash empty string" {
    const input = "";
    const expected = "69217a3079908094e11121d042354a7c1f55b6482ca1a51e1b250dfd1ed0eef9";
    std.testing.expectEqual(Blake2s.hash(input), expected);
}

test "hash abc" {
    const input = "abc";
    const expected = "508c5e8c327c14e2e1a72ba34eeb452f37458b209ed63a294d999b4c86675982";
    std.testing.expectEqual(Blake2s.hash(input), expected);
}

test "hash short ascii string" {
    const input = "The quick brown fox jumps over the lazy dog";
    const expected = "606beeec743ccbeff6cbcdf5d5302aa855c256c29b88c8ed331ea1a6bf3c8812";
    std.testing.expectEqual(Blake2s.hash(input), expected);
}
