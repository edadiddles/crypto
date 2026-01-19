const IV = @import("params.zig").IV;
const Blake2sState = @import("state.zig").Blake2sState;
const G = @import("g.zig").G;
const SIGMA = @import("params.zig").SIGMA;

const ROUNDS = 10;

pub fn compress(state: *Blake2sState, block: *const [64]u8) void {
    var m: [16]u32 = undefined;
    var v: [16]u32 = undefined;

    loadMessage(block, &m);
    initWorkVector(state, &v);

    inline for (0..ROUNDS) |r| {
        round(&v, &m, r);
    }

    feedForward(state, &v);
}

fn loadMessage(block: *const [64]u8, m: *[16]u32) void {
    for (0..16) |k| {
        const b1: u32 = @as(u32, block[k]) & 0xffffffff;
        const b2: u32 = @as(u32, block[k+1]) << 8 & 0xffffffff;
        const b3: u32 = @as(u32, block[k+2]) << 16 & 0xffffffff;
        const b4: u32 = @as(u32, block[k+3]) << 24 & 0xffffffff;
        m[k] = b1 ^ b2 ^ b3 ^ b4;
    }
}

fn initWorkVector(state: *Blake2sState, v: *[16]u32) void {
    for (0..7) |k| {
        v[k] = state.h[k];
        v[k+8] = IV[k];
    }
 
    v[12] ^= state.t0;
    v[13] ^= state.t1;
    v[14] ^= state.f0;
    v[15] ^= state.f1;
}

fn round(v: *[16]u32, m: *[16]u32, r: usize) void {
    G(&v[0], &v[4], &v[6], &v[12], &m[SIGMA[r][0]], &m[SIGMA[r][1]]);
    G(&v[1], &v[5], &v[9], &v[13], &m[SIGMA[r][2]], &m[SIGMA[r][3]]);
    G(&v[2], &v[6], &v[10], &v[14], &m[SIGMA[r][4]], &m[SIGMA[r][5]]);
    G(&v[3], &v[7], &v[11], &v[15], &m[SIGMA[r][6]], &m[SIGMA[r][7]]);

    G(&v[0], &v[5], &v[10], &v[15], &m[SIGMA[r][8]], &m[SIGMA[r][9]]);
    G(&v[1], &v[6], &v[11], &v[12], &m[SIGMA[r][10]], &m[SIGMA[r][11]]);
    G(&v[2], &v[7], &v[8], &v[13], &m[SIGMA[r][12]], &m[SIGMA[r][13]]);
    G(&v[3], &v[4], &v[9], &v[14], &m[SIGMA[r][14]], &m[SIGMA[r][15]]);
}

fn feedForward(state: *Blake2sState, v: *[16]u32) void {
    for (0..8) |k| {
        state.h[k] = state.h[k] ^ v[k] ^ v[k+8];
    }
}
