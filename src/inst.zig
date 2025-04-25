const Word = @import("machine.zig").Word;

pub const Inst = enum(Word) {
    Halt = 0x0,
    Nop = 0x1,
    Ret = 0x2,
    Push = 0x3,
    Pop = 0x4,
    Add = 0x5,
    Sub = 0x6,
    Mul = 0x7,
    Div = 0x8,
    Mod = 0x9,
    Drop = 0x10,

    pub fn as_word(self: Inst) Word {
        return @intFromEnum(self);
    }
};
