// Word size, 64bit arch
pub const Word: type = u64;
pub const StackSize: usize = 128;
pub const DataSize: usize = 2048;

pub const MachineError = error{
    IndexOutOfBounds,
};

pub const Machine = struct {
    stack: [StackSize]Word,
    data: [DataSize]Word,

    pub const default: Machine = .{
        .stack = [_]Word{0} ** StackSize,
        .data = [_]Word{0} ** DataSize,
    };

    pub fn set_stack(self: *Machine, sp: usize, value: Word) MachineError!void {
        if (sp >= StackSize) return MachineError.IndexOutOfBounds;
        self.stack[sp] = value;
    }

    pub fn get_stack(self: Machine, sp: usize) MachineError!Word {
        if (sp >= StackSize) return MachineError.IndexOutOfBounds;
        return self.stack[sp];
    }
};
