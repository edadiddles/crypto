const params = @import("params.zig");

const BLOCK_SIZE = 64;

pub const Blake2sState = struct {
    h: [8]u32,
    t: u64,
    f: u64,
    buf: [BLOCK_SIZE]u8,
    buf_len: usize,
    out_len: u8,

    fn init(self: *Blake2sState, blake2sParams: *const params.Blake2sParams) void {
        const param_words = blake2sParams.as_words();
        for(0..8) |i| {
            self.h[i] = params.IV[i] ^ param_words[i];
        }

        self.t = 0;
        self.f = 0;
        self.buf = .{0}**BLOCK_SIZE;
        self.buf_len = 0;
        self.out_len = blake2sParams.digest_length;
    }
};
