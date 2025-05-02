package main

import "core:fmt"

MachineError :: enum {
	Ok,
	Done,
	// Unknowns
	UnknownInst,
	UnknownWord,
	// Data
	DataOverflow,
	DataUnderflow,
	// Stack
	StackOverflow,
	StackUnderflow,
}

Word :: distinct u64
Pointer :: distinct i64
Instruction :: enum Word {
	Halt = 0x0,
	Nop  = 0x1,
	Push = 0x2,
	Pop  = 0x3,
}

inst :: proc(self: Instruction) -> Word {
	return auto_cast self
}

MaxProgramSize :: 2048
MaxStackSize :: 10

Machine :: struct {
	program: [MaxProgramSize]Word "Machine program in Words (u64)",
	stack:   [MaxStackSize]Word "Machine stack in Words (u64)",
	reg:     Word "The Register",
	pp:      Pointer "Program Pointer",
	sp:      Pointer "Stack pointer",
}

DefaultMachine :: Machine {
	program = [MaxProgramSize]Word{},
	stack   = [MaxStackSize]Word{},
	reg     = 0x0,
	pp      = 0x0,
	sp      = 0x0,
}

MachineDump :: proc(self: ^Machine, prog: []Word) -> MachineError {

	for i := 0; i < len(prog); i += 1 {
		if i >= MaxProgramSize {
			return .DataOverflow
		}
		self.program[i] = prog[i]
	}

	return .Ok
}

MachineStep :: proc(self: ^Machine) -> MachineError {
	if self.pp >= MaxProgramSize {
		return .DataUnderflow
	}

	inst, ok := MachineFetchInst(self)
	if ok != .Ok {
		return ok
	}

	MachinePrint(self)
	fmt.println("    Inst:", inst)

	#partial switch inst {
	case .Halt:
		return .Done
	case .Nop:
	case .Push:
		if self.sp >= MaxStackSize {return .StackOverflow}
		a, ok := MachineFetchWord(self)
		if ok != .Ok {return .UnknownWord}
		self.stack[self.sp] = a
		self.sp += 1
	case .Pop:
		if self.sp < 0 {return .StackUnderflow}
		self.sp -= 1
		self.reg = self.stack[self.sp]
		self.stack[self.sp] = 0
	case:
		fmt.eprintln("Error: Unknown instruction")
		fmt.eprintfln("     | Found '%s'", inst)
		return .UnknownInst
	}


	return .Ok
}

MachineFetchInst :: proc(self: ^Machine) -> (inst: Instruction, err: MachineError) {
	// Initial values
	inst = .Nop
	err = .Ok

	// Bounds check
	if self.pp >= MaxProgramSize {
		err = .DataUnderflow
		return
	}

	inst = auto_cast self.program[self.pp]
	self.pp += 1
	return
}

MachineFetchWord :: proc(self: ^Machine) -> (word: Word, err: MachineError) {
	// Initial values
	word = 0x0
	err = .Ok

	// Bounds check
	if self.pp >= MaxProgramSize {
		err = .DataUnderflow
		return
	}

	word = self.program[self.pp]
	self.pp += 1
	return
}

MachinePrint :: proc(self: ^Machine) {
	prelude := "    "
	fmt.printfln(
		"Machine (pp: 0x%X/0x%X, sp: 0x%X/0x%X):",
		self.pp,
		MaxProgramSize,
		self.sp,
		MaxStackSize,
	)
	fmt.printfln("%s(Reg1: 0x%X)", prelude, self.reg)
	fmt.print(prelude)
	for i := 0; i < len(self.stack); i += 1 {
		fmt.printf("0x%X ", self.stack[i])
	}
	fmt.println()
}
