const State = @import("state.zig").Poly1305State;
const math = @import("math.zig");

pub fn processBlock(state: *State, block: []const u8) void {
    const msg = loadMessage(block);
    math.addMessage(&state.h, msg);
    math.mulAcc(&state.h, &state.r);
    math.reduce(&state.h);
}

fn loadMessage(block: []const u8) [5]u32 {
    var t: [5]u32 = .{0}**5;

    var i: usize = 0;
    while (i < block.len) : (i += 1) {
        const limb = (i*8)/26;
        const shift: u5 = @intCast((i*8)%26 & 0x3ffffff);
        t[limb] |= (@as(u32, block[i])) << shift;
    }

    const bit = block.len*8;
    const limb = bit/26;
    const shift: u5 = @intCast(bit%26 & 0x3ffffff);
    t[limb] |= (@as(u32, 1) << shift);

    return t;
}
