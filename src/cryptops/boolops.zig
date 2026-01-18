const std = @import("std");

pub fn ch32(x: u32, y: u32, z: u32) u32 {
    return (x & y) ^ (~x & z);
}

pub fn maj32(x: u32, y: u32, z: u32) u32 {
    return (x & y) ^ (x & z) ^ (y & z);
}

pub fn par32(x: u32, y: u32, z: u32) u32 {
    return x ^ y ^ z;
}

pub fn ch64(x: u64, y: u64, z: u64) u64 {
    return (x & y) ^ (~x & z);
}

pub fn maj64(x: u64, y: u64, z: u64) u64 {
    return (x & y) ^ (x & z) ^ (y & z);
}

pub fn par64(x: u64, y: u64, z: u64) u64 {
    return x ^ y ^ z;
}

test "ch32 basic" {
    try std.testing.expectEqual(
        @as(u32, 0x12345678),
        ch32(0x00000000, 0xffffffff, 0x12345678),
    );

    try std.testing.expectEqual(
        @as(u32, 0xdeadbeef),
        ch32(0xffffffff, 0xdeadbeef, 0x12345678),
    );
}

test "ch32 masking" {
    try std.testing.expectEqual(
        @as(u32, 0xaaaaaaaa),
        ch32(0xaaaaaaaa, 0xffffffff, 0x000000000),
    );

    try std.testing.expectEqual(
        @as(u32, 0x55555555),
        ch32(0xaaaaaaaa, 0x000000000, 0xffffffff),
    );
}

test "ch32 structural" {
    try std.testing.expectEqual(
        @as(u32, 0xffffffff),
        ch32(0xaaaaaaaa, 0xaaaaaaaa, 0x55555555),
    );
}

test "maj32 basic" {
    try std.testing.expectEqual(
        @as(u32, 0x00000000),
        maj32(0x00000000, 0x00000000, 0x00000000),
    );

    try std.testing.expectEqual(
        @as(u32, 0xffffffff),
        maj32(0xffffffff, 0xffffffff, 0xffffffff),
    );

    try std.testing.expectEqual(
        @as(u32, 0x12345678),
        maj32(0x12345678, 0x12345678, 0xdeadbeef),
    );

    try std.testing.expectEqual(
        @as(u32, 0xdeadbeef),
        maj32(0x12345678, 0xdeadbeef, 0xdeadbeef),
    );
}

test "maj32 alternating" {
    try std.testing.expectEqual(
        @as(u32, 0xaaaaaaaa),
        maj32(0xaaaaaaaa, 0x55555555, 0xaaaaaaaa),
    );

    try std.testing.expectEqual(
        @as(u32, 0x55555555),
        maj32(0x55555555, 0x55555555, 0xaaaaaaaa),
    );

    try std.testing.expectEqual(
        @as(u32, 0xaaaaaaaa),
        maj32(0xaaaaaaaa, 0xcccccccc, 0xaaaaaaaa),
    );
}

test "maj32 mixed" {
    try std.testing.expectEqual(
        @as(u32, 0xe8e8e8e8),
        maj32(0xaaaaaaaa, 0xcccccccc, 0xf0f0f0f0),
    );

    try std.testing.expectEqual(
        @as(u32, 0xffffffff),
        maj32(0xaaaaaaaa, 0x55555555, 0xffffffff),
    );
}

test "par32 basic" {
    try std.testing.expectEqual(
        @as(u32, 0x00000000),
        par32(0x00000000, 0x00000000, 0x00000000),
    );
    
    try std.testing.expectEqual(
        @as(u32, 0x12345678),
        par32(0x12345678, 0x00000000, 0x00000000),
    );

    try std.testing.expectEqual(
        @as(u32, 0x00000000),
        par32(0x12345678, 0x12345678, 0x00000000),
    );
}

test "par32 alternating" {
    try std.testing.expectEqual(
        @as(u32, 0xffffffff),
        par32(0xaaaaaaaa, 0x55555555, 0x00000000),
    );
}

test "par32 linearity" {
    try std.testing.expectEqual(
        true,
        par32(0x12345678^0xdeadbeef, 0xa5a5a5a5, 0x5a5a5a5a) == par32(0x12345678, 0xa5a5a5a5, 0x5a5a5a5a) ^ 0xdeadbeef,
    );
}

test "ch64 basic" {
    try std.testing.expectEqual(
        @as(u64, 0x1234567890abcdef),
        ch64(0x0000000000000000, 0xffffffffffffffff, 0x1234567890abcdef),
    );

    try std.testing.expectEqual(
        @as(u64, 0xdeadbeefdeadbeef),
        ch64(0xffffffffffffffff, 0xdeadbeefdeadbeef, 0x1234567890abcdef),
    );
}

test "ch64 masking" {
    try std.testing.expectEqual(
        @as(u64, 0xaaaaaaaaaaaaaaaa),
        ch64(0xaaaaaaaaaaaaaaaa, 0xffffffffffffffff, 0x000000000000000000),
    );

    try std.testing.expectEqual(
        @as(u64, 0x5555555555555555),
        ch64(0xaaaaaaaaaaaaaaaa, 0x000000000000000000, 0xffffffffffffffff),
    );
}

test "ch64 structural" {
    try std.testing.expectEqual(
        @as(u64, 0xffffffffffffffff),
        ch64(0xaaaaaaaaaaaaaaaa, 0xaaaaaaaaaaaaaaaa, 0x5555555555555555),
    );
}

test "maj64 basic" {
    try std.testing.expectEqual(
        @as(u64, 0x0000000000000000),
        maj64(0x0000000000000000, 0x0000000000000000, 0x0000000000000000),
    );

    try std.testing.expectEqual(
        @as(u64, 0xffffffffffffffff),
        maj64(0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff),
    );

    try std.testing.expectEqual(
        @as(u64, 0x1234567890abcdef),
        maj64(0x1234567890abcdef, 0x1234567890abcdef, 0xdeadbeefdeadbeef),
    );

    try std.testing.expectEqual(
        @as(u64, 0xdeadbeefdeadbeef),
        maj64(0x1234567890abcdef, 0xdeadbeefdeadbeef, 0xdeadbeefdeadbeef),
    );
}

test "maj64 alternating" {
    try std.testing.expectEqual(
        @as(u64, 0xaaaaaaaaaaaaaaaa),
        maj64(0xaaaaaaaaaaaaaaaa, 0x5555555555555555, 0xaaaaaaaaaaaaaaaa),
    );

    try std.testing.expectEqual(
        @as(u64, 0x5555555555555555),
        maj64(0x5555555555555555, 0x5555555555555555, 0xaaaaaaaaaaaaaaaa),
    );

    try std.testing.expectEqual(
        @as(u64, 0xaaaaaaaaaaaaaaaa),
        maj64(0xaaaaaaaaaaaaaaaa, 0xcccccccccccccccc, 0xaaaaaaaaaaaaaaaa),
    );
}

test "maj64 mixed" {
    try std.testing.expectEqual(
        @as(u64, 0xe8e8e8e8e8e8e8e8),
        maj64(0xaaaaaaaaaaaaaaaa, 0xcccccccccccccccc, 0xf0f0f0f0f0f0f0f0),
    );

    try std.testing.expectEqual(
        @as(u64, 0xffffffffffffffff),
        maj64(0xaaaaaaaaaaaaaaaa, 0x5555555555555555, 0xffffffffffffffff),
    );
}

test "par64 basic" {
    try std.testing.expectEqual(
        @as(u64, 0x0000000000000000),
        par64(0x0000000000000000, 0x0000000000000000, 0x0000000000000000),
    );
    
    try std.testing.expectEqual(
        @as(u64, 0x1234567890abcdef),
        par64(0x1234567890abcdef, 0x0000000000000000, 0x0000000000000000),
    );

    try std.testing.expectEqual(
        @as(u64, 0x0000000000000000),
        par64(0x1234567890abcdef, 0x1234567890abcdef, 0x0000000000000000),
    );
}

test "par64 alternating" {
    try std.testing.expectEqual(
        @as(u64, 0xffffffffffffffff),
        par64(0xaaaaaaaaaaaaaaaa, 0x5555555555555555, 0x0000000000000000),
    );
}

test "par64 linearity" {
    try std.testing.expectEqual(
        true,
        par64(0x1234567890abcdef^0xdeadbeefdeadbeef, 0xa5a5a5a5a5a5a5a5, 0x5a5a5a5a5a5a5a5a) == par64(0x1234567890abcdef, 0xa5a5a5a5a5a5a5a5, 0x5a5a5a5a5a5a5a5a) ^ 0xdeadbeefdeadbeef,
    );
}
