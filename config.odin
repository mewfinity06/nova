package main

import "core:fmt"

Config :: struct {
	build_type: enum {
		Unknown,
		Run,
		Debug,
	},
	src_path:   string,
	build_out:  string,
}

get_config :: proc(args: []string) -> Config {
	config: Config

	for i := 0; i < len(args); i += 1 {
		switch args[i] {
		case "-r", "--run":
			config.build_type = .Run
		case "-b", "--build":
			config.build_type = .Debug
		case "-o", "--output":
			i += 1
			assert(len(args) - 1 != 0)
			config.build_out = args[i]
		case:
			fmt.println("Unknown flag:", args[i])
		}
	}

	return config
}
