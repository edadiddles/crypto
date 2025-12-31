const std = @import ("std");

pub fn load_u32_be(b: []const u8) u32 {
    std.debug.assert(b.len >= 4);
    return (@as(u32, b[0]) << 24) |
            (@as(u32, b[1]) << 16) |
            (@as(u32, b[2]) << 8) |
            (@as(u32, b[3]) << 0);
}
pub fn load_u32_le(b: []const u8) u32 {
    std.debug.assert(b.len >= 4);
    return (@as(u32, b[3]) << 24) |
            (@as(u32, b[2]) << 16) |
            (@as(u32, b[1]) << 8) |
            (@as(u32, b[0]) << 0);
}
pub fn load_u64_be(b: []const u8) u64 {
    std.debug.assert(b.len >= 8);
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
    std.debug.assert(b.len >= 8);
    return (@as(u64, b[7]) << 56) |
            (@as(u64, b[6]) << 48) |
            (@as(u64, b[5]) << 40) |
            (@as(u64, b[4]) << 32) |
            (@as(u64, b[3]) << 24) |
            (@as(u64, b[2]) << 16) |
            (@as(u64, b[1]) << 8) |
            (@as(u64, b[0]) << 0);
}

pub fn store_u32_be(buf: []u8, x: u32) void {
    std.debug.assert(buf.len >= 4);
    buf[0] = @intCast((x >> 24) & 0xff);
    buf[1] = @intCast((x >> 16) & 0xff);
    buf[2] = @intCast((x >> 8) & 0xff);
    buf[3] = @intCast((x >> 0) & 0xff);
}

pub fn store_u32_le(buf: []u8, x: u32) void {
    std.debug.assert(buf.len >= 4);
    buf[0] = @intCast((x >> 0) & 0xff);
    buf[1] = @intCast((x >> 8) & 0xff);
    buf[2] = @intCast((x >> 16) & 0xff);
    buf[3] = @intCast((x >> 24) & 0xff);
}
pub fn store_u64_be(buf: []u8, x: u32) void {
    std.debug.assert(buf.len >= 8);
    _ = x;
}
pub fn store_u64_le(buf: []u8, x: u32) void {
    std.debug.assert(buf.len >= 8);
    _ = x;
}


test "load_u32_be basic" {
    const b = [_]u8{ 0x12, 0x34, 0x56, 0x78 };
    try std.testing.expectEqual(
        @as(u32, 0x12345678),
        load_u32_be(&b),
    );
}

test "load_u32_be edge cases" {
    const b0 = [_]u8{ 0x00, 0x00, 0x00, 0x00 };
    try std.testing.expectEqual(
        @as(u32, 0x00000000),
        load_u32_be(&b0),
    );

    const b1 = [_]u8{ 0xff, 0xff, 0xff, 0xff };
    try std.testing.expectEqual(
        @as(u32, 0xffffffff),
        load_u32_be(&b1),
    );

    const b2 = [_]u8{ 0xaa, 0x55, 0xaa, 0x55 };
    try std.testing.expectEqual(
        @as(u32, 0xaa55aa55),
        load_u32_be(&b2),
    );

    const b3 = [_]u8{ 0x55, 0xaa, 0x55, 0xaa };
    try std.testing.expectEqual(
        @as(u32, 0x55aa55aa),
        load_u32_be(&b3),
    );

    const b4 = [_]u8{ 0x12, 0x34, 0x56, 0x78, 0x90 };
    try std.testing.expectEqual(
        @as(u32, 0x12345678),
        load_u32_be(&b4),
    );
}

test "load_u32_le basic" {
    const b = [_]u8{ 0x78, 0x56, 0x34, 0x12 };
    try std.testing.expectEqual(
        @as(u32, 0x12345678),
        load_u32_le(&b),
    );
}

test "load_u32_le edge cases" {
    const b0 = [_]u8{ 0x00, 0x00, 0x00, 0x00 };
    try std.testing.expectEqual(
        @as(u32, 0x00000000),
        load_u32_le(&b0),
    );

    const b1 = [_]u8{ 0xff, 0xff, 0xff, 0xff };
    try std.testing.expectEqual(
        @as(u32, 0xffffffff),
        load_u32_le(&b1),
    );

    const b2 = [_]u8{ 0xaa, 0x55, 0xaa, 0x55 };
    try std.testing.expectEqual(
        @as(u32, 0x55aa55aa),
        load_u32_le(&b2),
    );

    const b3 = [_]u8{ 0x55, 0xaa, 0x55, 0xaa };
    try std.testing.expectEqual(
        @as(u32, 0xaa55aa55),
        load_u32_le(&b3),
    );

    const b4 = [_]u8{ 0x12, 0x34, 0x56, 0x78, 0x90 };
    try std.testing.expectEqual(
        @as(u32, 0x78563412),
        load_u32_le(&b4),
    );
}

test "load_u64_be basic" {
    const b = [_]u8{ 0x12, 0x34, 0x56, 0x78, 0x90, 0xab, 0xcd, 0xef };
    try std.testing.expectEqual(
        @as(u64, 0x1234567890abcdef),
        load_u64_be(&b),
    );
}

test "load_u64_be edge cases" {
    const b0 = [_]u8{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
    try std.testing.expectEqual(
        @as(u64, 0x0000000000000000),
        load_u64_be(&b0),
    );

    const b1 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
    try std.testing.expectEqual(
        @as(u64, 0xffffffffffffffff),
        load_u64_be(&b1),
    );

    const b2 = [_]u8{ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 };
    try std.testing.expectEqual(
        @as(u64, 0xaa55aa55aa55aa55),
        load_u64_be(&b2),
    );

    const b3 = [_]u8{ 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa };
    try std.testing.expectEqual(
        @as(u64, 0x55aa55aa55aa55aa),
        load_u64_be(&b3),
    );

    const b4 = [_]u8{ 0x12, 0x34, 0x56, 0x78, 0x90, 0xab, 0xcd, 0xef, 0xff };
    try std.testing.expectEqual(
        @as(u64, 0x1234567890abcdef),
        load_u64_be(&b4),
    );
}


test "load_u64_le basic" {
    const b = [_]u8{ 0xef, 0xcd, 0xab, 0x90, 0x78, 0x56, 0x34, 0x12 };
    try std.testing.expectEqual(
        @as(u64, 0x1234567890abcdef),
        load_u64_le(&b),
    );
}

test "load_u64_le edge cases" {
    const b0 = [_]u8{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
    try std.testing.expectEqual(
        @as(u64, 0x0000000000000000),
        load_u64_le(&b0),
    );

    const b1 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
    try std.testing.expectEqual(
        @as(u64, 0xffffffffffffffff),
        load_u64_le(&b1),
    );

    const b2 = [_]u8{ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 };
    try std.testing.expectEqual(
        @as(u64, 0x55aa55aa55aa55aa),
        load_u64_le(&b2),
    );

    const b3 = [_]u8{ 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa };
    try std.testing.expectEqual(
        @as(u64, 0xaa55aa55aa55aa55),
        load_u64_le(&b3),
    );

    const b4 = [_]u8{ 0x12, 0x34, 0x56, 0x78, 0x90, 0xab, 0xcd, 0xef, 0xff };
    try std.testing.expectEqual(
        @as(u64, 0xefcdab9078563412),
        load_u64_le(&b4),
    );
}

test "store_u32_be basic" {
    var b = [_]u8 { 0x00, 0x00, 0x00, 0x00 };
    store_u32_be(&b, 0x12345678);
    try std.testing.expectEqual(
        [_]u8 { 0x12, 0x34, 0x56, 0x78 },
        b,
    );
}

test "store_u32_le basic" {
    var b = [_]u8 { 0x00, 0x00, 0x00, 0x00 };
    store_u32_le(&b, 0x12345678);
    try std.testing.expectEqual(
        [_]u8 { 0x78, 0x56, 0x34, 0x12 },
        b,
    );
}
