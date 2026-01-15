pub const IV: [8]u32 = .{
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
};

pub const SIGMA: [10][16]u8 = undefined;

pub const Blake2sParams = packed struct {
    digest_length: u8,
    key_length: u8,
    fanout: u8,
    depth: u8,
    leaf_length: u32,
    node_offset: u64,
    node_depth: u8,
    inner_length: u8,
    reserved: [14]u8,

    pub fn init(digest_len: u8, key_len: u8) Blake2sParams {
        return .{
            .digest_length = digest_len,
            .key_length = key_len,
            .fanout = 1,
            .depth = 1,
            .leaf_length = 0,
            .node_offset = 0,
            .node_depth = 0,
            .inner_length = 0,
            .reserved = [_]u8{0}**14,
        };
    }

    pub fn as_words(p: *const Blake2sParams) *const [8]u32 {
        return @ptrCast(p);
    }
};

