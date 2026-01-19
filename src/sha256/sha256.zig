const std = @import("std");
const endian = @import("endian");
const sigma = @import("sigma.zig");
const boolops = @import("boolops");

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

const IV = [_]u32 {
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
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

pub fn sha256(input: []const u8) []u32 {
    const padding: [1]u8 = .{0x80};
    var bit_size: [8]u8 = .{0}**8;
    const num_bytes = input.len + padding.len + bit_size.len;
    const num_blks = (num_bytes/64) + 1;

    var blks: [256][64]u8 = undefined;
    var bit_cnt: u64 = 0;
    var blk_cnt: usize = 0;
    {
        var blk: [64]u8 = .{0}**64;
        var blk_idx: usize = 0;
        for (input, 1..) |m, k| {
            if (k % 64 == 0) {
                blks[blk_cnt] = blk;
                blk_cnt += 1;
                blk_idx = 0;
                blk = .{0}**64;
            }
            blk[blk_idx] = m;
            bit_cnt+=8; // count bits
            blk_idx+=1;
            //bit_size += 1;
        }

        blk[blk_idx] = padding[0];

        blks[blk_cnt] = blk;
        blk_cnt += 1;

        if (blk_cnt < num_blks) {
            blks[blk_cnt] = .{0}**64;
        }

        bit_size = .{
            @intCast(bit_cnt >> 56 & 255),
            @intCast(bit_cnt >> 48 & 255),
            @intCast(bit_cnt >> 40 & 255),
            @intCast(bit_cnt >> 32 & 255),
            @intCast(bit_cnt >> 24 & 255),
            @intCast(bit_cnt >> 16 & 255),
            @intCast(bit_cnt >> 8 & 255),
            @intCast(bit_cnt >> 0 & 255),
        };
        for (bit_size,0..) |b,k| {
            blks[num_blks-1][56+k] = b;
        }
    }

    var state: [8]u32 = IV;
    for (blks, 0..) |blk, k| {
        if (k >= num_blks) {
            break;
        }
        compress(&state, &blk);
    }

    return &state;
}

test "compress zero block sanity check with Known Value test" {
    const block: [64]u8 = .{0x80} ++ .{0x00}**63;
    var state: [8]u32 = IV;
    compress(&state, &block);
    try std.testing.expect(!std.mem.eql(u32, &IV, &state));
    try std.testing.expectEqualSlices(
        u32,
        &[_]u32 {
            0xe3b0c442, 0x98fc1c14, 0x9afbf4c8, 0x996fb924,
            0x27ae41e4, 0x649b934c, 0xa495991b, 0x7852b855,
        },
        &state,
    );
}

test "compress determinism" {
    const block: [64]u8 = .{'H','e','l','l','o',' ','w','o','r','l','d', 0x80 } ++ .{0}**44 ++ .{0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x58 };
    var state1: [8]u32 = IV;
    var state2: [8]u32 = IV;
    compress(&state1, &block);
    compress(&state2, &block);
    try std.testing.expectEqualSlices(u32, &state1, &state2);
    try std.testing.expectEqualSlices(u32,
        &[_]u32 {
            0x64ec88ca, 0x00b268e5, 0xba1a3567, 0x8a1b5316,
            0xd212f4f3, 0x66b24772, 0x32534a8a, 0xeca37f3c,
        },
        &state1,
    );
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

test "schedule does not mutate block" {
    var block = [_]u8{0} ** 64;
    block[0] = 0x80;

    const original = block;

    var W: [64]u32 = undefined;
    schedule(&block, &W);

    try std.testing.expectEqualSlices(u8, &original, &block);
}

test "sha256 Known Value Tests" {
    try std.testing.expectEqualSlices(
        u32,
        &[8]u32{
            0xe3b0c442, 0x98fc1c14, 0x9afbf4c8, 0x996fb924,
            0x27ae41e4, 0x649b934c, 0xa495991b, 0x7852b855,
        },
        sha256(""),
    );
    try std.testing.expectEqualSlices(
        u32,
        &[8]u32{
            0xba7816bf, 0x8f01cfea, 0x414140de, 0x5dae2223,
            0xb00361a3, 0x96177a9c, 0xb410ff61, 0xf20015ad,
        },
        sha256("abc"),
    );
    try std.testing.expectEqualSlices(
        u32,
        &[8]u32{
            0xa591a6d4, 0x0bf42040, 0x4a011733, 0xcfb7b190,
            0xd62c65bf, 0x0bcda32b, 0x57b277d9, 0xad9f146e,
        },
        sha256("Hello World"),
    );
    try std.testing.expectEqualSlices(
        u32,
        &[8]u32{
            0x248d6a61, 0xd20638b8, 0xe5c02693, 0x0c3e6039,
            0xa33ce459, 0x64ff2167, 0xf6ecedd4, 0x19db06c1,
        },
        sha256("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),
    );
}
