const std = @import ("std");

// TODO input checking and maybe return error
pub fn load_u32_be(b: []const u8) u32 {
    return (@as(u32, b[0]) << 24) |
            (@as(u32, b[1]) << 16) |
            (@as(u32, b[2]) << 8) |
            (@as(u32, b[3]) << 0);
}
pub fn load_u32_le(b: []const u8) u32 {
    return (@as(u32, b[3]) << 24) |
            (@as(u32, b[2]) << 16) |
            (@as(u32, b[1]) << 8) |
            (@as(u32, b[0]) << 0);
}
pub fn load_u64_be(b: []const u8) u64 {
    return (@as(u64, b[0]) << 56) |
            (@as(u64, b[1]) << 48) |
            (@as(u64, b[2]) << 40) |
            (@as(u64, b[3]) << 32) |
            (@as(u64, b[4]) << 24) |
            (@as(u64, b[5]) << 16) |
            (@as(u64, b[6]) << 8) |
            (@as(u64, b[7]) << 0);
}
pub fn load_u64_le(b: []const u8) u64 {
    return (@as(u64, b[7]) << 56) |
            (@as(u64, b[6]) << 48) |
            (@as(u64, b[5]) << 40) |
            (@as(u64, b[4]) << 32) |
            (@as(u64, b[3]) << 24) |
            (@as(u64, b[2]) << 16) |
            (@as(u64, b[1]) << 8) |
            (@as(u64, b[0]) << 0);
}

pub fn store_u32_be() []u8 {
    return []u8{};
}
pub fn store_u32_le() []u8 {
    return []u8{};
}
pub fn store_u64_be() []u8 {
    return []u8{};
}
pub fn store_u64_le() []u8 {
    return []u8{};
}


test "load_u32_be basic" {
    const b = [_]u8{ 0x12, 0x34, 0x56, 0x78 };
    try std.testing.expectEqual(
        @as(u32, 0x12345678),
        load_u32_be(&b),
    );
}

test "load_u32_le basic" {
    const b = [_]u8{ 0x78, 0x56, 0x34, 0x12 };
    try std.testing.expectEqual(
        @as(u32, 0x12345678),
        load_u32_le(&b),
    );
}

test "load_u64_be basic" {
    const b = [_]u8{ 0x12, 0x34, 0x56, 0x78, 0x90, 0xab, 0xcd, 0xef };
    try std.testing.expectEqual(
        @as(u64, 0x1234567890abcdef),
        load_u64_be(&b),
    );
}

test "load_u64_le basic" {
    const b = [_]u8{ 0xef, 0xcd, 0xab, 0x90, 0x78, 0x56, 0x34, 0x12 };
    try std.testing.expectEqual(
        @as(u64, 0x1234567890abcdef),
        load_u64_le(&b),
    );
}

