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
    print("_start: PROGRAM Main\n", .{});
    print("    call Main\n", .{});
    print("\n", .{});
}

fn epilogue() void {
    print("PROGRAM Main()\n", .{});
    inline for (Programs.program_names) |name| {
        print("    call {s}\n", .{name});
    }
    print("END ; Main\n", .{});
}

const BuildType = enum {
    Dump,
    Debug,
};

pub fn main() !void {
    var m = Machine.default;
    const bt = BuildType.Dump;

    if (bt == .Debug) prologue();

    inline for (Programs.programs, Programs.program_names) |p, p_name| {
        try m.dump(p.len, p);
        switch (bt) {
            .Debug => {
                try m.debug_bin(p_name);
                print("\n", .{});
            },
            .Dump => {
                // m.print_dumped(p.len);
                print("PROGRAM {s}\n", .{p_name});
                while (try m.step()) {}
            },
        }
    }

    if (bt == .Debug) epilogue();
}
