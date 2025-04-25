// Imports
const std = @import("std");
const debug = std.debug;

const Inst = @import("inst.zig").Inst;

// Word size, 64bit arch
pub const Word: type = u64;
pub const Pointer: type = i64;
pub const StackSize: usize = 10;
pub const DataSize: usize = 2048;
pub const RegisterCount: usize = 5;

fn ptr_usz(p: Pointer) usize {
    return @as(usize, @intCast(p));
}

pub const Machine = struct {
    /// Stack
    stack: [StackSize]Word,
    /// Registers
    regs: [RegisterCount]Word,
    /// Data (Program)
    data: [DataSize]Word,
    /// Data pointer
    dp: Pointer,
    /// Stack pointer
    sp: Pointer,
    /// Ret pointer
    rp: Pointer,

    pub const default: Machine = .{
        .stack = [_]Word{0} ** StackSize,
        .regs = [_]Word{0} ** RegisterCount,
        .data = [_]Word{0} ** DataSize,
        .dp = -1,
        .sp = -1,
        .rp = -1,
    };

    fn is_regs_zeroed(self: Machine) bool {
        for (self.regs) |reg| {
            if (reg != 0) return false;
        }
        return true;
    }

    fn stack_empty(self: Machine) bool {
        return self.sp <= 0;
    }

    pub fn step(self: *Machine) !bool {
        if (self.dp >= DataSize) return false;
        self.print();
        const inst: Inst = try self.fetch_enum(Inst);
        switch (inst) {
            .Nop => {},
            // TODO: Finish ret
            .Halt => {
                if (!self.stack_empty()) return error.StackMustBeEmpty;
                return false;
            },
            .Ret => {
                if (!self.stack_empty()) return error.StackMustBeEmpty;
                self.dp = self.rp;
            },
            .Push => {
                const v = try self.fetch();
                if (ptr_usz(self.sp) >= StackSize) return error.StackOverflow;
                self.stack[ptr_usz(self.sp)] = v;
                self.sp += 1;
            },
            .Pop => {
                if (self.sp < 0) return error.StackUnderflow;
                const reg = try self.fetch();
                if (self.sp != 0) self.sp -= 1;
                self.regs[reg] = self.stack[ptr_usz(self.sp)];
                self.stack[ptr_usz(self.sp)] = 0;
            },
            .Add => {
                if (self.sp < 2) return error.StackUnderflow;
                const a = self.stack[ptr_usz(self.sp) - 1];
                const b = self.stack[ptr_usz(self.sp) - 2];
                self.stack[ptr_usz(self.sp) - 1] = 0;
                self.stack[ptr_usz(self.sp) - 2] = b + a;
                self.sp -= 1;
            },
            .Sub => {
                if (self.sp < 2) return error.StackUnderflow;
                const a = self.stack[ptr_usz(self.sp) - 1];
                const b = self.stack[ptr_usz(self.sp) - 2];
                self.stack[ptr_usz(self.sp) - 1] = 0;
                self.stack[ptr_usz(self.sp) - 2] = b - a;
                self.sp -= 1;
            },
            .Mul => {
                if (self.sp < 2) return error.StackUnderflow;
                const a = self.stack[ptr_usz(self.sp) - 1];
                const b = self.stack[ptr_usz(self.sp) - 2];
                self.stack[ptr_usz(self.sp) - 1] = 0;
                self.stack[ptr_usz(self.sp) - 2] = b * a;
                self.sp -= 1;
            },
            .Div => {
                if (self.sp < 2) return error.StackUnderflow;
                const a = self.stack[ptr_usz(self.sp) - 1];
                const b = self.stack[ptr_usz(self.sp) - 2];
                self.stack[ptr_usz(self.sp) - 1] = 0;
                self.stack[ptr_usz(self.sp) - 2] = b / a;
                self.sp -= 1;
            },
            .Mod => {
                if (self.sp < 2) return error.StackUnderflow;
                const a = self.stack[ptr_usz(self.sp) - 1];
                const b = self.stack[ptr_usz(self.sp) - 2];
                self.stack[ptr_usz(self.sp) - 1] = 0;
                self.stack[ptr_usz(self.sp) - 2] = b % a;
                self.sp -= 1;
            },
            .Drop => {
                const reg = try self.fetch();
                if (reg >= RegisterCount) return error.RegisterOutOfBounds;
                self.regs[@as(usize, reg)] = 0;
            },
            // else => {
            //     debug.print("Unimplemented {}\n", .{inst});
            //     return error.Unimplemented;
            // },
        }
        return true;
    }

    fn function_prologue(pid: usize) void {
        debug.print("{}:\n", .{pid});
    }

    fn function_epilogue(_: usize) void {}

    fn print_stack(self: Machine) void {
        debug.print("      N, ", .{});
        for (self.stack) |stack| {
            debug.print("{}, ", .{stack});
        }
        debug.print("\n", .{});
        debug.print("      ", .{});
        for (0..ptr_usz(self.sp)) |_| {
            debug.print("   ", .{});
        }
        debug.print("^\n", .{});
    }

    pub fn debug_bin(self: *Machine, progid: usize) !void {
        Machine.function_prologue(progid);
        var i: usize = 0;
        while (i < self.data.len) : (i += 1) {
            var word = self.data[i];
            const inst: Inst = @enumFromInt(word);

            switch (inst) {
                .Nop => {
                    debug.print("    nop\n", .{});
                },
                .Drop => {
                    i += 1;
                    word = self.data[i];
                    debug.print("    drop {}\n", .{word});
                },
                .Halt => {
                    debug.print("    halt\n", .{});
                    break;
                },
                .Ret => {
                    debug.print("    ret\n", .{});
                    break;
                },
                .Push => {
                    i += 1;
                    word = self.data[i];
                    debug.print("    push {}\n", .{word});
                },
                .Pop => {
                    i += 1;
                    word = self.data[i];
                    debug.print("    pop {}\n", .{word});
                },
                .Add => {
                    debug.print("    add\n", .{});
                },
                .Sub => {
                    debug.print("    sub\n", .{});
                },
                .Mul => {
                    debug.print("    mul\n", .{});
                },
                .Div => {
                    debug.print("    div\n", .{});
                },
                .Mod => {
                    debug.print("    mod\n", .{});
                },
                // else => {
                //    debug.print("Unimplemented {}\n", .{inst});
                //    return error.Unimplemented;
                // },
            }
        }
        Machine.function_epilogue(progid);
    }

    fn fetch_enum(self: *Machine, comptime T: type) !T {
        if (self.dp < 0) return error.Segfault;
        const v = self.data[ptr_usz(self.dp)];
        defer self.dp += 1;
        if (self.dp > DataSize) return error.Segfault;
        return @enumFromInt(v);
    }

    fn fetch_value(self: *Machine, comptime T: type) !T {
        if (self.dp < 0) return error.Segfault;
        const v = self.data[ptr_usz(self.dp)];
        defer self.dp += 1;
        if (self.dp > DataSize) return error.Segfault;
        return @as(T, v);
    }

    fn fetch(self: *Machine) !Word {
        return self.fetch_value(Word);
    }

    pub fn print(self: Machine) void {
        if (self.dp >= DataSize) return;
        if (self.sp >= StackSize) return;
        const inst: Inst = @as(Inst, @enumFromInt(self.data[ptr_usz(self.dp)]));
        debug.print("-- dp: {}, sp: {}, rp: {}\n", .{ self.dp, self.sp, self.rp });
        if (inst == Inst.Nop) return;
        debug.print("   ", .{});
        for (self.regs, 1..) |reg, i| {
            debug.print("r{}:{}, ", .{ i, reg });
        }
        debug.print("\n", .{});
        debug.print("   Inst: {any} ({})\n", .{ inst, self.data[ptr_usz(self.dp) + 1] });
        self.print_stack();
        debug.print("\n", .{});
    }

    pub fn dump(self: *Machine, size: comptime_int, data: [size]Word) !void {
        if (data.len > DataSize) return error.Segfault;

        // Reset everything between programs. Granted these "programs"
        // are just basically functions
        self.stack = [_]Word{0} ** StackSize;
        self.regs = [_]Word{0} ** RegisterCount;
        self.dp = 0;
        self.sp = 0;

        for (data, 0..data.len) |d, i| {
            self.data[i] = d;
        }
    }

    pub fn print_dumped(self: Machine, size: comptime_int) void {
        debug.print("PROGRAM (size: {})\n", .{size});
        for (self.data, 0..) |d, i| {
            if (i % 10 == 0 and i != 0) debug.print("\n", .{});
            if (i == size) break;
            debug.print("0x{X} ", .{d});
        }
        debug.print("\n", .{});
    }
};
