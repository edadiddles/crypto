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

        const t0 = std.mem.readInt(u32, key[0..4], .little);
        const t1 = std.mem.readInt(u32, key[4..8], .little);
        const t2 = std.mem.readInt(u32, key[8..12], .little);
        const t3 = std.mem.readInt(u32, key[12..16], .little);

        // Clamp r
        st.r[0] = t0 & 0x3ffffff;
        st.r[1] = ((t0 >> 26) | (t1 << 6)) & 0x3ffff03;
        st.r[2] = ((t1 >> 20) | (t2 << 12)) & 0x3ffc0ff;
        st.r[3] = ((t2 >> 14) | (t3 << 18)) & 0x3f03fff;
        st.r[4] = (t3 >> 8) & 0x00fffff;

        // Load s
        st.s[0] = std.mem.readInt(u32, key[16..20], .little);
        st.s[1] = std.mem.readInt(u32, key[20..24], .little);
        st.s[2] = std.mem.readInt(u32, key[24..28], .little);
        st.s[3] = std.mem.readInt(u32, key[28..32], .little);
        return st;
    }

    pub fn incrementCounter(self: *Poly1305State, bytes: usize) void {
        self.buf_len = bytes;
    }
};

