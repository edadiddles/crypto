const std = @import("std");
const testing = std.testing;

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

pub fn rotl64(x: u64, n: u6) u64 {
    _ = x;
    _ = n;
    return 0;
}

pub fn rotr64(x: u64, n: u6) u64 {
    _ = x;
    _ = n;
    return 0;
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
            rotr32(rotl32(x, @as(u32, @intCast(i))), @as(u5, @intCast(i))),
        );
    }
}
