// Std imports
const std = @import("std");
const print = std.debug.print;

// Machine imports
const machine = @import("machine.zig");
const Machine = machine.Machine;

pub fn main() !void {
    var m: Machine = Machine.default;

    try m.set_stack(4, 16);
    const x = try m.get_stack(4);

    print("m.stack[{d}] = {d}\n", .{ 4, x });
}
