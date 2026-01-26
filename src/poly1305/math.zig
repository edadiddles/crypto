const std = @import("std");
const State = @import("state.zig").Poly1305State;

const LIMBS = 5;
const LIMB_BITS = 26;
const LIMB_MASK = 0x3fffffff;

pub fn addMessage(h: *[LIMBS]u32, m: [LIMBS]u32) void {
    inline for (0..LIMBS) |i| {
        h[i] += m[i];
    }
}

pub fn mulAcc(h: *[LIMBS]u32, r: *[LIMBS]u32) void {
    const r0 = @as(u64, r[0]);
    const r1 = @as(u64, r[1]);
    const r2 = @as(u64, r[2]);
    const r3 = @as(u64, r[3]);
    const r4 = @as(u64, r[4]);

    const s1 = r1 * 5;
    const s2 = r2 * 5;
    const s3 = r3 * 5;
    const s4 = r4 * 5;
    
    const h0 = @as(u64, h[0]);
    const h1 = @as(u64, h[1]);
    const h2 = @as(u64, h[2]);
    const h3 = @as(u64, h[3]);
    const h4 = @as(u64, h[4]);

    const d0 = h0*r0 + h1*s4 + h2*s3 + h3*s2 + h4*s1;
    const d1 = h0*r1 + h1*r0 + h2*s4 + h3*s3 + h4*s2;
    const d2 = h0*r2 + h1*r1 + h2*r0 + h3*s4 + h4*s3;
    const d3 = h0*r3 + h1*r2 + h2*r1 + h3*r0 + h4*s4;
    const d4 = h0*r4 + h1*r3 + h2*r2 + h3*r1 + h4*r0;

    h[0] = @intCast(d0 & LIMB_MASK);
    h[1] = @intCast(d1 & LIMB_MASK);
    h[2] = @intCast(d2 & LIMB_MASK);
    h[3] = @intCast(d3 & LIMB_MASK);
    h[4] = @intCast(d4 & LIMB_MASK);
}

pub fn reduce(h: *[LIMBS]u32) void {
    var c: u32 = undefined;

    c = h[0] >> LIMB_BITS; h[0] &= LIMB_MASK; h[1] += c;
    c = h[1] >> LIMB_BITS; h[1] &= LIMB_MASK; h[2] += c;
    c = h[2] >> LIMB_BITS; h[2] &= LIMB_MASK; h[3] += c;
    c = h[3] >> LIMB_BITS; h[3] &= LIMB_MASK; h[4] += c;

    c = h[4] >> LIMB_BITS;
    h[4] &= LIMB_MASK;
    h[0] += c*5;

    c = h[0] >> LIMB_BITS;
    h[0] &= LIMB_MASK;
    h[1] += c;
}

pub fn finalizeReduce(h: *[LIMBS]u32) void {
    reduce(h);

    var g: [LIMBS]u32 = h.*;

    g[0] +%= 5;
    var c: u32 = g[0] >> LIMB_BITS; g[0] &= LIMB_MASK;

    inline for (1..LIMBS) |i| {
        g[i] +%= c;
        c = g[i] >> LIMB_BITS;
        g[i] &= LIMB_MASK;
    }

    const mask = @as(u32, @intCast((c^1)-1));
    inline for (0..LIMBS) |i| {
        h[i] = (h[i] & ~mask) | (g[i] & mask);
    }
}
