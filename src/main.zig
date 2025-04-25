// Std imports
const std = @import("std");
const print = std.debug.print;

// Machine imports
const machine = @import("machine.zig");
const Machine = machine.Machine;
const Word = machine.Word;

// Instruction imports
const inst = @import("inst.zig");

const Programs = struct {
    const programs = .{
        [_]Word{ 0x1, 0xFF }, // Nop
        [_]Word{ 0x2, 0x1, 0x3, 0x0, 0xFF }, // PushPop
        [_]Word{
            // Add
            0x2,  0x5, 0x2, 0x4, 0x4, 0x3, 0x0,
            // Sub
            0x2,  0x4, 0x2, 0x1, 0x5, 0x3, 0x1,
            // Mul
            0x2,  0x3, 0x2, 0x8, 0x6, 0x3, 0x2,
            // Div
            0x2,  0x3, 0x2, 0x8, 0x7, 0x3, 0x3,
            // Mod
            0x2,  0x8, 0x2, 0x3, 0x8, 0x3, 0x4,
            // ret
            0xFF,
        },
    };
    const program_names = .{
        "Nop",
        "PushPop",
        "Math",
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
