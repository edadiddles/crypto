const IV = @import("params.zig").IV;
const Blake2sState = @import("state.zig").Blake2sState;

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

fn loadMessage(block: *const [64]u8, m: [16]u32) void {
    for (0..16) |k| {
        const b1: u32 = block[k];
        const b2: u32 = block[k+1] << 8;
        const b3: u32 = block[k+2] << 16;
        const b4: u32 = block[k+3] << 24;
        m[k] = b1 ^ b2 ^ b3 ^ b4;
    }
}

fn initWorkVector(state: *Blake2sState, v: [16]u32) void {
    for (0..7) |k| {
        v[k] = state.h[k];
        v[k+8] = IV[k];
    }
 
    v[12] ^= state.t0;
    v[13] ^= state.t1;
    v[14] ^= state.f0;
    v[15] ^= state.f1;
}

fn round(v: [16]u32, m: [16]u32, r: usize) void {
    _ = v;
    _ = m;
    _ = r;
}

fn feedForward(state: *Blake2sState, v: [16]u32) void {
    for (0..8) |k| {
        state.h[k] = state.h[k] ^ v[k] ^ v[k+8];
    }
}
