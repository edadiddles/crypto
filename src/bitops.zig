const std = @import("std");
const testing = std.testing;


//TODO: refactor code to use canonical crypto identity (~r & W-1)
pub fn rotl32(x: u32, n: u32) u32 {
    const r: u5 = @intCast(n & 31);
    const s: u5 = @intCast((@as(u32, 32)-r) & 31);
    return (x << r) | (x >> s);
}

pub fn rotr32(x: u32, n: u32) u32 {
    const r: u5 = @intCast(n & 31);
    const s: u5 = @intCast((@as(u32, 32)-r) & 31);
    return (x >> r) | (x << s);
}

pub fn rotl64(x: u64, n: u64) u64 {
    const r: u6 = @intCast(n & 63);
    const s: u6 = @intCast((@as(u64, 64)-@as(u64, r)) & 63);
    return (x << r) | (x >> s);
}

pub fn rotr64(x: u64, n: u64) u64 {
    const r: u6 = @intCast(n & 63);
    const s: u6 = @intCast((@as(u64, 64)-@as(u64, r)) & 63);
    return (x >> r) | (x << s);
}


test "rotl32 basic" {
    try std.testing.expectEqual(
        @as(u32, 0x23456781),
        rotl32(0x12345678, 4),
    );
}

test "rotl32/rotr32 inverse" {
    const x: u32 = 0xdeadbeef;
    for (0..32) |i| {
        try std.testing.expectEqual(
            x,
            rotr32(rotl32(x, @as(u32, @intCast(i))), @as(u32, @intCast(i))),
        );
    }
}

test "rotl32 edge cases" {
    try testing.expectEqual(0x12345678, rotl32(0x12345678, 0));
    try testing.expectEqual(0x2468acf0, rotl32(0x12345678, 1));
    try testing.expectEqual(0x091a2b3c, rotl32(0x12345678, 31));
    try testing.expectEqual(0x12345678, rotl32(0x12345678, 32));
    try testing.expectEqual(0, rotl32(0, 5));
    try testing.expectEqual(0xffffffff, rotl32(~@as(u32, 0), 5));
}

test "rotl64 basic" {
    try std.testing.expectEqual(
        @as(u64, 0x123456789abcdef0),
        rotl64(0x0123456789abcdef, 4),
    );
    try std.testing.expectEqual(
        0xdeadbeefdeadbeef,
        rotl64(0xdeadbeefdeadbeef, 0),
    );
}

test "rotr64 basic" {
    try std.testing.expectEqual(
        @as(u64, 0x0123456789abcdef),
        rotr64(0x123456789abcdef0, 4),
    );
    try std.testing.expectEqual(
        0xdeadbeefdeadbeef,
        rotr64(0xdeadbeefdeadbeef, 0),
    );
}

test "rotl64/rotr64 inverse" {
    const x: u64 = 0xdeadbeefdeadbeef;
    for (0..64) |i| {
        try std.testing.expectEqual(
            x,
            rotr64(rotl64(x, @as(u64, @intCast(i))), @as(u64, @intCast(i))),
        );
    }
}

test "rotl64 edge cases" {
    try testing.expectEqual(0x0123456789abcdef, rotl64(0x0123456789abcdef, 0));
    try testing.expectEqual(0x02468acf13579bde, rotl64(0x0123456789abcdef, 1));
    try testing.expectEqual(0x8091a2b3c4d5e6f7, rotl64(0x0123456789abcdef, 63));
    try testing.expectEqual(0x0123456789abcdef, rotl64(0x0123456789abcdef, 64));
    try testing.expectEqual(0, rotl64(0, 5));
    try testing.expectEqual(0xffffffffffffffff, rotl64(~@as(u64, 0), 5));
}

