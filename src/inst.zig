const Word = @import("machine.zig").Word;

pub const Inst = enum(Word) {
    Halt = 0x0,
    Nop = 0x1,
};
