const std = @import("std");

const Limb = u32;

pub const Poly1305State = struct {
    h: [5]Limb,
    r: [5]Limb,
    s: [4]u32,
    buf: [16]u8,
    buf_len: usize,

    pub fn init(key: [32]u8) Poly1305State {
        var st = Poly1305State{
            .h = .{0}**5,
            .r = undefined,
            .s = undefined,
            .buf = .{0}**16,
            .buf_len = 0,
        };

        const t0 = std.mem.readIntLittle(u32, key[0..4]);
        const t1 = std.mem.readIntLittle(u32, key[4..8]);
        const t2 = std.mem.readIntLittle(u32, key[8..12]);
        const t3 = std.mem.readIntLittle(u32, key[12..16]);

        // Clamp r
        st.r[0] = t0 & 0x3fffffff;
        st.r[1] = ((t0 >> 26) | (t1 << 6)) & 0x3fffff03;
        st.r[2] = ((t1 >> 20) | (t2 << 12)) & 0x3fffc0ff;
        st.r[3] = ((t2 >> 14) | (t3 << 18)) & 0x3f03ffff;
        st.r[4] = (t3 >> 8) & 0x00ffffff;

        // Load s
        st.s[0] = std.mem.readIntLittle(u32, key[16..20]);
        st.s[1] = std.mem.readIntLittle(u32, key[20..24]);
        st.s[2] = std.mem.readIntLittle(u32, key[24..28]);
        st.s[3] = std.mem.readIntLittle(u32, key[28..32]);
        return st;
    }

    pub fn incrementCounter(self: Poly1305State, bytes: usize) void {
        self.buf_len += bytes;
    }
};

