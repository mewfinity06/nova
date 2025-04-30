package main

import "core:fmt"
import "core:os"

main :: proc() {
	args := os.args[1:]

	config := get_config(args)
	machine := DefaultMachine

	prog := []Word{inst(.Nop), inst(.Nop), inst(.Push), 0x1, inst(.Pop)}

	ok := MachineDump(&machine, prog)

	#partial switch ok {
	case .Ok: // Do nothing
	case .DataOverflow:
		fmt.eprintln("Error: Data overflow")
		fmt.eprintfln("     | Program too long, expected %d found %d", MaxProgramSize, len(prog))
	case:
		fmt.eprintfln("Error: Unknown Error found: %s", ok)
	}

	for {
		ok := MachineStep(&machine)

		#partial switch ok {
		case .Ok:
		case:
		}
	}
}
