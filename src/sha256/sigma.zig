const std = @import("std");
const bitops = @import("../cryptops/bitops.zig");

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

pub fn small_sigma0_64(x: u64) u64 {
    return bitops.rotr64(x, 1) ^ bitops.rotr64(x, 8) ^ x >> 7;
}

pub fn small_sigma1_64(x: u64) u64 {
    return bitops.rotr64(x, 19) ^ bitops.rotr64(x, 61) ^ x >> 6;
}

pub fn big_sigma0_64(x: u64) u64 {
    return bitops.rotr64(x, 28) ^ bitops.rotr64(x, 34) ^ bitops.rotr64(x, 39);
}

pub fn big_sigma1_64(x: u64) u64 {
    return bitops.rotr64(x, 14) ^ bitops.rotr64(x, 18) ^ bitops.rotr64(x, 41);
}


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

test "big_sigma0_32 basic" {
    try std.testing.expectEqual(
        @as(u32, 0x00000000),
        big_sigma0_32(0x00000000),
    );
 
    try std.testing.expectEqual(
        @as(u32, 0xffffffff),
        big_sigma0_32(0xffffffff),
    );

    try std.testing.expectEqual(
        @as(u32, 0x40080400),
        big_sigma0_32(0x00000001),
    );
    
    try std.testing.expectEqual(
        @as(u32, 0x20040200),
        big_sigma0_32(0x80000000),
    );
}

test "big_sigma0_32 alternating patterns" {
    try std.testing.expect(
        @as(u32, 0x00000000) != big_sigma0_32(0xaaaaaaaa),
    );
    
    try std.testing.expect(
        @as(u32, 0x00000000) != big_sigma0_32(0x55555555),
    );
}
test "big_sigma1_32 basic" {
    try std.testing.expectEqual(
        @as(u32, 0x00000000),
        big_sigma1_32(0x00000000),
    );
 
    try std.testing.expectEqual(
        @as(u32, 0xffffffff),
        big_sigma1_32(0xffffffff),
    );

    try std.testing.expectEqual(
        @as(u32, 0x04200080),
        big_sigma1_32(0x00000001),
    );
    
    try std.testing.expectEqual(
        @as(u32, 0x02100040),
        big_sigma1_32(0x80000000),
    );
}

test "big_sigma1_32 alternating patterns" {
    try std.testing.expect(
        @as(u32, 0x00000000) != big_sigma1_32(0xaaaaaaaa),
    );
    
    try std.testing.expect(
        @as(u32, 0x00000000) != big_sigma1_32(0x55555555),
    );
}

test "small_sigma0_64 basic" {
    try std.testing.expectEqual(
        @as(u64, 0x0000000000000000),
        small_sigma0_64(0x0000000000000000),
    );
 
    try std.testing.expect(
        @as(u64, 0xffffffffffffffff) != small_sigma0_64(0xffffffffffffffff),
    );

    try std.testing.expectEqual(
        @as(u64, 0x8100000000000000),
        small_sigma0_64(0x000000000000001),
    );
    
    try std.testing.expectEqual(
        @as(u64, 0x4180000000000000),
        small_sigma0_64(0x8000000000000000),
    );
}

test "small_sigma0_64 alternating patterns" {
    try std.testing.expect(
        @as(u64, 0x0000000000000000) != small_sigma0_64(0xaaaaaaaaaaaaaaaa),
    );
    
    try std.testing.expect(
        @as(u64, 0x0000000000000000) != small_sigma0_64(0x5555555555555555),
    );
}

test "small_sigma1_64 basic" {
    try std.testing.expectEqual(
        @as(u64, 0x0000000000000000),
        small_sigma1_64(0x0000000000000000),
    );

    try std.testing.expect(
        @as(u64, 0xffffffffffffffff) != small_sigma1_64(0xffffffffffffffff)
    );

    try std.testing.expectEqual(
        @as(u64, 0x0000200000000008),
        small_sigma1_64(0x00000000000000001),
    );

    try std.testing.expectEqual(
        @as(u64, 0x0200100000000004),
        small_sigma1_64(0x8000000000000000),
    );
}

test "small_sigma1_64 alternating patterns" {
    try std.testing.expect(
        @as(u64, 0x0000000000000000) != small_sigma1_64(0xaaaaaaaaaaaaaaaa),
    );
    
    try std.testing.expect(
        @as(u64, 0x0000000000000000) != small_sigma1_64(0x5555555555555555),
    );
}

test "big_sigma0_64 basic" {
    try std.testing.expectEqual(
        @as(u64, 0x0000000000000000),
        big_sigma0_64(0x0000000000000000),
    );
 
    try std.testing.expectEqual(
        @as(u64, 0xffffffffffffffff),
        big_sigma0_64(0xffffffffffffffff),
    );

    try std.testing.expectEqual(
        @as(u64, 0x0000001042000000),
        big_sigma0_64(0x0000000000000001),
    );
    
    try std.testing.expectEqual(
        @as(u64, 0x0000000821000000),
        big_sigma0_64(0x8000000000000000),
    );
}

test "big_sigma0_64 alternating patterns" {
    try std.testing.expect(
        @as(u64, 0x0000000000000000) != big_sigma0_64(0xaaaaaaaaaaaaaaaa),
    );
    
    try std.testing.expect(
        @as(u64, 0x0000000000000000) != big_sigma0_64(0x5555555555555555),
    );
}

test "big_sigma1_64 basic" {
    try std.testing.expectEqual(
        @as(u64, 0x0000000000000000),
        big_sigma1_64(0x0000000000000000),
    );
 
    try std.testing.expectEqual(
        @as(u64, 0xffffffffffffffff),
        big_sigma1_64(0xffffffffffffffff),
    );

    try std.testing.expectEqual(
        @as(u64, 0x0004400000800000),
        big_sigma1_64(0x0000000000000001),
    );
    
    try std.testing.expectEqual(
        @as(u64, 0x0002200000400000),
        big_sigma1_64(0x8000000000000000),
    );
}

test "big_sigma1_64 alternating patterns" {
    try std.testing.expect(
        @as(u64, 0x0000000000000000) != big_sigma1_64(0xaaaaaaaaaaaaaaaa),
    );
    
    try std.testing.expect(
        @as(u64, 0x0000000000000000) != big_sigma1_64(0x5555555555555555),
    );
}
