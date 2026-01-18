const rotr = @import("../bitops.zig").rotr32;
const R = [_]u32{16, 12, 8, 7};

pub fn G(a: *u32, b: *u32, c: *u32, d: *u32, x: *u32, y: *u32) void {
    a = a + b + x;
    d = rotr(d ^ a,  R[0]);
    c = c + d;
    b = rotr(b ^ c, R[1]);
    a = a + b + y;
    d = rotr(d ^ a, R[2]);
    c = c + d;
    b = rotr(b ^ c, R[3]);
}
