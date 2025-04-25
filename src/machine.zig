// Imports
const std = @import("std");
const debug = std.debug;

const Inst = @import("inst.zig").Inst;

// Word size, 64bit arch
pub const Word: type = u64;
pub const StackSize: usize = 10;
pub const DataSize: usize = 2048;
pub const RegisterCount: usize = 5;

const StackStatus = enum {
    Alive,
    Dead,
};

pub const MachineError = error{
    IndexOutOfBounds,
    Segfault,
    StackOverflow,
    StackUnderflow,
};

pub const Machine = struct {
    stack: [StackSize]Word,
    stack_status: [StackSize]StackStatus,
    reg: [RegisterCount]Word,
    data: [DataSize]Word,
    dp: Word,
    sp: Word,

    pub const default: Machine = .{
        .stack = [_]Word{0} ** StackSize,
        .stack_status = [_]StackStatus{.Dead} ** StackSize,
        .reg = [_]Word{0} ** RegisterCount,
        .data = [_]Word{0} ** DataSize,
        .dp = 0,
        .sp = 0,
    };

    pub fn step(self: *Machine) !bool {
        if (self.dp >= DataSize) return false;

        try self.fetch_value(void);

        debug.print("HOLY FUCK I MAKE IT HERE NOW\n", .{});

        return true;
    }

    fn fetch_enum(self: *Machine, comptime T: type) !T {
        self.dp += 1;
        if (self.dp > DataSize) return error.Segfault;
    }

    fn fetch_value(self: *Machine, comptime T: type) !T {
        self.dp += 1;
        if (self.dp > DataSize) return error.Segfault;
    }

    pub fn print(self: Machine) void {
        if (self.dp >= DataSize) return;
        debug.print("-- Machine ({}) --\n", .{self.dp});
        debug.print("- Inst: {any}\n", .{@as(Inst, @enumFromInt(self.data[self.dp]))});
    }

    pub fn dump(self: *Machine, size: comptime_int, data: [size]Word) !void {
        if (data.len > DataSize) return MachineError.Segfault;
        for (data, 0..data.len) |d, i| {
            self.data[i] = d;
        }
    }
};
