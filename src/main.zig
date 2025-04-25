const std = @import("std");

const print = std.debug.print;

const Word: type = u8;
const DataSize: usize = 2048;
const StackSize: usize = 128;

const MachineError = error{
    IndexOutOfBounds,
};

const Machine = struct {
    stack: [StackSize]Word,
    data: [DataSize]Word,

    const default: Machine = .{
        .stack = [_]Word{0} ** StackSize,
        .data = [_]Word{0} ** DataSize,
    };

    /// IN  : self, sp
    /// OUT : Word @ sp
    pub fn get_stack(self: Machine, sp: usize) MachineError!Word {
        if (sp >= StackSize) return MachineError.IndexOutOfBounds;
        return self.stack[sp];
    }

    pub fn set_stack(self: *Machine, sp: usize, value: Word) MachineError!void {
        if (sp >= StackSize) return MachineError.IndexOutOfBounds;
        self.stack[sp] = value;
    }
};

pub fn main() !void {
    var m: Machine = Machine.default;

    try m.set_stack(4, 16);
    const x = try m.get_stack(4);

    print("m.stack[{d}] = {d}\n", .{ 4, x });
}
