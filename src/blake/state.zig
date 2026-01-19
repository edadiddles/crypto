const params = @import("params.zig");

const BLOCK_SIZE = 64;

pub const Blake2sState = struct {
    h: [8]u32,
    t0: u32,
    t1: u32,
    f0: u32,
    f1: u32,
    buf: [BLOCK_SIZE]u8,
    buf_len: u32,
    out_len: u8,

    pub fn create() Blake2sState {
        return .{
            .h = .{0}**8,
            .t0 = 0,
            .t1 = 0,
            .f0 = 0,
            .f1 = 0,
            .buf = .{0}**BLOCK_SIZE,
            .buf_len = 0,
            .out_len = 0,
        };
    }

    pub fn init(self: *Blake2sState, blake2sParams: *const params.Blake2sParams) void {
        const param_words = blake2sParams.as_words();
        for(0..8) |i| {
            self.h[i] = params.IV[i] ^ param_words[i];
        }

        self.t0 = 0;
        self.t1 = 0;
        self.f0 = 0;
        self.f1 = 0;
        self.buf = .{0}**BLOCK_SIZE;
        self.buf_len = 0;
        self.out_len = blake2sParams.digest_length;
    }

    pub fn increment_bytes(self: *Blake2sState, num_bytes: u32) void {
        const res = @addWithOverflow(self.t0, num_bytes);
        self.t0 += res[0];
        self.t1 += res[1];
    }

};
