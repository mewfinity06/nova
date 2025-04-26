// Std imports
const std = @import("std");
const print = std.debug.print;

// Machine imports
const machine = @import("machine.zig");
const Machine = machine.Machine;
const Word = machine.Word;

// Instruction imports
const Inst = @import("inst.zig").Inst;

const word = Inst.as_word;

const Programs = struct {
    const programs = .{
        [_]Word{
            word(.Push), 0xA, // Push 10
            word(.Push), 0x5, // Push 5
            word(.Add), // Add (10 + 5 = 15)
            word(.Exit), // Exit with 15
        },
        [_]Word{
            word(.Push), 0x14, // Push 20
            word(.Push), 0x2, // Push 2
            word(.Sub), // Subtract (20 - 2 = 18)
            word(.Halt), // Halt (exit code will be whatever is left on stack)
        },
        [_]Word{
            word(.Push), 0x3, // Push 3
            word(.Push), 0x4, // Push 4
            word(.Mul), // Multiply (3 * 4 = 12)
            word(.Push), 0x2, // Push 2
            word(.Div), // Divide (12 / 2 = 6)
            word(.Exit), // Exit with 6
        },
        [_]Word{
            word(.Push), 0xB, // Push 11
            word(.Push), 0x3, // Push 3
            word(.Mod), // Modulo (11 % 3 = 2)
            word(.Pop), 0x0, // Pop result to register 0
            word(.Halt), // Halt
        },
        [_]Word{
            word(.Push), 0x1, // Push 1
            word(.Push), 0x2, // Push 2
            word(.Drop), 0x0, // Drop (sets register 0 to 2)
            word(.Push), 0x7, // Push 7
            word(.Exit), // Exit with 7
        },
        [_]Word{
            word(.Nop), //
            word(.Push), 0x1, //
            word(.Goto), 0x6, // Jump to Push 0x2
            word(.Exit), // Unreachable
            word(.Push), 0x2, //
            word(.Exit), // Exit with 2
        },
        [_]Word{
            word(.Push), 0x10, // Push 16
            word(.Ret), // Return (behavior undefined without call stack)
            word(.Drop), //
            word(.Halt), //
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
    Run,
    Debug,
};

pub fn main() !u8 {
    var m = Machine.default;
    const bt = BuildType.Debug;

    // if (bt == .Debug) prologue();

    var pids: usize = 0;
    inline for (Programs.programs, 1..) |p, pid| {
        try m.dump(p.len, p);
        pids += 1;
        switch (bt) {
            .Debug => {
                try m.debug_bin(pid);
                print("\n", .{});
            },
            .Run => {
                m.print_dumped(p.len, pid);
                while (try m.step(true)) {}
                m.print();
                if (m.exit_code != 0) print("Exit: {}\n", .{m.exit_code});
                print("----------------------------\n", .{});
            },
        }
    }

    // if (bt == .Debug) epilogue(pids);
    return 0;
}
