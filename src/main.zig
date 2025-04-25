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
        [_]Word{ 1, 2, 3 },
        [_]Word{},
    };
};

pub fn main() !void {
    var m = Machine.default;

    inline for (Programs.programs, 0..) |p, i| {
        print("PROGRAM ({})", .{i});
        try m.dump(p.len, p);
        m.print();
        while (try m.step()) m.print();
    }
}
