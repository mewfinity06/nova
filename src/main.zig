// Std imports
const std = @import("std");
const print = std.debug.print;

// Machine imports
const machine = @import("machine.zig");
const Machine = machine.Machine;
const Word = machine.Word;

// Instruction imports
const Inst = @import("inst.zig").Inst;

fn word(inst: Inst) Word {
    return inst.as_word();
}

const Programs = struct {
    const programs = .{
        // Nop
        [_]Word{word(.Nop)},
        // PopPush
        [_]Word{
            word(.Push), 0x1, //
            word(.Pop), 0x0, //
        },
        // Math'ng
        [_]Word{
            //  inst     arg
            // Add
            word(.Push), 0x5, //
            word(.Push), 0x4, //
            word(.Add), //
            word(.Pop), 0x0, //
            // Sub
            word(.Push), 0x4, //
            word(.Push), 0x1, //
            word(.Sub), //
            word(.Pop), 0x1, //
            // Mul
            word(.Push), 0x4, //
            word(.Push), 0x1, //
            word(.Mul), //
            word(.Pop), 0x2, //
            // Div
            word(.Push), 0x4, //
            word(.Push), 0x1, //
            word(.Div), //
            word(.Pop), 0x3, //
            // Mod
            word(.Push), 0x4, //
            word(.Push), 0x1, //
            word(.Mod), //
            word(.Pop), 0x4, //
        },
    };
};

fn prologue() void {
    print("_start: PROGRAM .main\n", .{});
    print("    goto .main\n", .{});
    print("\n", .{});
}

fn epilogue(num_pids: usize) void {
    print(".main:\n", .{});
    for (0..num_pids) |pid| {
        print("    goto :{}\n", .{pid});
    }
}

const BuildType = enum {
    Dump,
    Debug,
};

pub fn main() !void {
    var m = Machine.default;
    const bt = BuildType.Debug;

    if (bt == .Debug) prologue();

    var pids: usize = 0;
    inline for (Programs.programs, 0..) |p, pid| {
        try m.dump(p.len, p);
        pids += 1;
        switch (bt) {
            .Debug => {
                try m.debug_bin(pid);
                print("\n", .{});
            },
            .Dump => {
                m.print_dumped(p.len);
                print("{}:\n", .{pid});
                while (try m.step()) {}
            },
        }
    }

    if (bt == .Debug) epilogue(pids);
}
