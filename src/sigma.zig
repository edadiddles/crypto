const std = @import("std");
const bitops = @import("bitops.zig");

pub fn small_sigma0_32(x: u32) u32 {
    return bitops.rotr32(x, 7) ^ bitops.rotr32(x, 18) ^ x >> 3;
}

pub fn small_sigma1_32(x: u32) u32 { 
    return bitops.rotr32(x, 17) ^ bitops.rotr32(x, 19) ^ x >> 10;
}

pub fn big_sigma0_32(x: u32) u32 {
    return bitops.rotr32(x, 2) ^ bitops.rotr32(x, 13) ^ bitops.rotr32(x, 22);
}

pub fn big_sigma1_32(x: u32) u32 {
    return bitops.rotr32(x, 6) ^ bitops.rotr32(x, 11) ^ bitops.rotr32(x, 25);
}

pub fn small_sigma0_64(x: u64) u64 { return x; }
pub fn small_sigma1_64(x: u64) u64 { return x; }
pub fn big_sigma0_64(x: u64) u64 { return x; }
pub fn big_sigma1_64(x: u64) u64 { return x; }


test "small_sigma0_32 basic" {
    try std.testing.expectEqual(
        @as(u32, 0x00000000),
        small_sigma0_32(0x00000000),
    );
 
    try std.testing.expect(
        @as(u32, 0xffffffff) != small_sigma0_32(0xffffffff),
    );

    try std.testing.expectEqual(
        @as(u32, 0x02004000),
        small_sigma0_32(0x00000001),
    );
    
    try std.testing.expectEqual(
        @as(u32, 0x11002000),
        small_sigma0_32(0x80000000),
    );
}

test "small_sigma0_32 alternating patterns" {
    try std.testing.expect(
        @as(u32, 0x00000000) != small_sigma0_32(0xaaaaaaaa),
    );
    
    try std.testing.expect(
        @as(u32, 0x00000000) != small_sigma0_32(0x55555555),
    );
}

test "small_sigma1_32 basic" {
    try std.testing.expectEqual(
        @as(u32, 0x00000000),
        small_sigma1_32(0x00000000),
    );

    try std.testing.expect(
        @as(u32, 0xffffffff) != small_sigma1_32(0xffffffff)
    );

    try std.testing.expectEqual(
        @as(u32, 0x0000A000),
        small_sigma1_32(0x00000001),
    );

    try std.testing.expectEqual(
        @as(u32, 0x00205000),
        small_sigma1_32(0x80000000),
    );
}

test "small_sigma1_32 alternating patterns" {
    try std.testing.expect(
        @as(u32, 0x00000000) != small_sigma1_32(0xaaaaaaaa),
    );
    
    try std.testing.expect(
        @as(u32, 0x00000000) != small_sigma1_32(0x55555555),
    );
}
