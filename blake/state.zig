pub const Blake2sState = struct {
    h: [8]u32,
    t: u64,
    buf: [64]u8,
    buf_len: usize,
    is_finalized: bool,
};
