const Word = @import("machine.zig").Word;

pub const Inst = enum(Word) {
    /// IN : n/a
    /// OUT: n/a
    /// ABT: Stops the program. Like exit(0)
    Halt = 0x0,
    /// IN : n/a
    /// OUT: n/a
    /// ABT: No operation
    Nop = 0x1,
    /// IN : $reg
    /// OUT: n/a
    /// ABT: puts the value in `reg` onto the stack
    Push = 0x2,
    /// IN : $reg
    /// OUT: n/a
    /// ABT: puts the value on top of the stack into `reg`
    Pop = 0x3,
    /// IN : n/a
    /// OUT: n/a
    /// ABT: adds the top to values on the stack
    ///    | s_0 + s_1
    Add = 0x4,
    /// IN : n/a
    /// OUT: n/a
    /// ABT: subs the top to values on the stack
    ///    | s_0 - s_1
    Sub = 0x5,
    /// IN : n/a
    /// OUT: n/a
    /// ABT: muls the top to values on the stack
    ///    | s_0 * s_1
    Mul = 0x6,
    /// IN : n/a
    /// OUT: n/a
    /// ABT: adds the top to values on the stack
    ///    | s_0 / s_1
    Div = 0x7,
    /// IN : n/a
    /// OUT: n/a
    /// ABT: adds the top to values on the stack
    ///    | s_0 % s_1
    Mod = 0x8,
    /// IN : n/a
    /// OUT: n/a
    /// ABT: goes to previous function call
    Ret = 0xFF,
};
