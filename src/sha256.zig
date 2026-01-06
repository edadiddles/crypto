const std = @import("std");
const endian = @import("endian.zig");
const sigma = @import("sigma.zig");
const boolops = @import("boolops.zig");

const K = [_]u32{
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
};

fn schedule(block: []const u8, W: *[64]u32) void {
    for (0..16) |i| {
        W[i] = endian.load_u32_be(block[i*4..][0..4]);
    }

    for(16..64) |i| {
        W[i] = sigma.small_sigma1_32(W[i-2]) +% W[i-7] +% sigma.small_sigma0_32(W[i-15]) +% W[i-16];
    }
}

pub fn compress(state: *[8]u32, block: []const u8) void {
    var W: [64]u32 = undefined;
    schedule(block, &W);

    var a = state[0];
    var b = state[1];
    var c = state[2];
    var d = state[3];
    var e = state[4];
    var f = state[5];
    var g = state[6];
    var h = state[7];

    for (0..64) |i| {
        const t1 = h +% sigma.big_sigma1_32(e) +% boolops.ch32(e,f,g) +% K[i] +% W[i];
        const t2 = sigma.big_sigma0_32(a) +% boolops.maj32(a,b,c);

        h = g;
        g = f;
        f = e;
        e = d +% t1;
        d = c;
        c = b;
        b = a;
        a = t1 +% t2;
    }

    state[0] +%= a;
    state[1] +%= b;
    state[2] +%= c;
    state[3] +%= d;
    state[4] +%= e;
    state[5] +%= f;
    state[6] +%= g;
    state[7] +%= h;
}

test "compress zero block sanity" {
    const block: [64]u8 = [_]u8{0}**64;
    var state: [8]u32 = [_]u32{1,2,3,4,5,6,7,8};
    compress(&state, &block);
    try std.testing.expect(!std.mem.eql(u32, &[_]u32{1,2,3,4,5,6,7,8}, &state));
}

test "compress determinism" {
    const block: [64]u8 = .{'H','e','l','l','o',' ','w','o','r','l','d'} ++ .{0}**53;
    var state1: [8]u32 = [_]u32{1,2,3,4,5,6,7,8};
    var state2: [8]u32 = [_]u32{1,2,3,4,5,6,7,8};
    compress(&state1, &block);
    compress(&state2, &block);
    try std.testing.expectEqualSlices(u32, &state1, &state2);
}

test "schedule determinism" {
    const block: []const u8 = &(.{ 0x61, 0x62, 0x63, 0x80 } ++ .{ 0 }**56 ++ .{ 0x00, 0x00, 0x00, 0x18 });

    var W1: [64]u32 = undefined;
    var W2: [64]u32 = undefined;

    schedule(block, &W1);
    schedule(block, &W2);

    try std.testing.expectEqualSlices(u32, &W1, &W2);
}

test "schedule partial correctness" {
    const block: []const u8 = &(.{ 0x61, 0x62, 0x63, 0x80 } ++ .{ 0 }**56 ++ .{ 0x00, 0x00, 0x00, 0x18 });
    var W: [64]u32 = .{0}**64;
    schedule(block, &W);

    try std.testing.expectEqual(0x61626380, W[0]);
    try std.testing.expectEqual(0x00000018, W[15]);
    try std.testing.expectEqual(0x61626380, W[16]);
}
