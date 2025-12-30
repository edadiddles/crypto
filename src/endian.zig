const std = @import ("std");

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
pub fn load_u64_be(bytes: []const u8) void {
    _ = bytes;
}
pub fn load_u64_le(bytes: []const u8) void {
    _ = bytes;
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

