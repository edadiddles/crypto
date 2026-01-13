pub const IV: [8]u32 = undefined;
pub const SIGMA: [10][16]u8 = undefined;

pub const Params = struct {
    digest_length: u8,
    key_length: u8,
    fanout: u8,
    depth: u8,
    leaf_length: u32,
    node_offset: u64,
    node_depth: u8,
    inner_length: u8,
};
