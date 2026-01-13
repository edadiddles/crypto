const Blake2sState = @import("state.zig").Blake2sState;


pub fn init(state: *Blake2sState, digest_len: u8, key: ?[]const u8) void {
    _ = state;
    _ = digest_len;
    _ = key;
}

pub fn update(state: *Blake2sState, input: []const u8) void {
    _ = state;
    _ = input;
}

pub fn finalize(state: *Blake2sState, out: []u8) void {
    _ = state;
    _ = out;
}
