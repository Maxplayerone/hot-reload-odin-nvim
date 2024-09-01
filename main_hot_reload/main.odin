package main

import "core:c/libc"
import "core:dynlib"
import "core:fmt"
import "core:os"

GameAPI :: struct {
	init:            proc(),
	init_window:     proc(),
	update:          proc() -> bool,
	shutdown:        proc(),
	shutdown_window: proc(),
	memory:          proc() -> rawptr,
	hot_reloaded:    proc(_: rawptr),
	full_reset:      proc() -> bool,
	lib:             dynlib.Library,
	dll_time:        os.File_Time,
	api_version:     int,
}

load_game_api :: proc(api_version: int) -> (GameAPI, bool) {
	dll_time, dll_time_err := os.last_write_time_by_name("game.dll")

	if dll_time_err != os.ERROR_NONE {
		fmt.println("Could not fetch last write date of game.dll")
		return {}, false
	}

	dll_name := fmt.tprintf("game_{0}.dll", api_version)

	copy_cmd := fmt.ctprintf("copy game.dll {0}", dll_name)
	if libc.system(copy_cmd) != 0 {
		fmt.println("Failed to copy game.dll to {0}", dll_name)
		return {}, false
	}

	lib, lib_ok := dynlib.load_library(dll_name)

	if !lib_ok {
		fmt.println("Failed loading game DLL")
		return {}, false
	}

	api := GameAPI {
		init            = cast(proc())(dynlib.symbol_address(lib, "game_init") or_else nil),
		init_window     = cast(proc())(dynlib.symbol_address(lib, "game_init_window") or_else nil),
		shutdown_window = cast(proc(
		))(dynlib.symbol_address(lib, "game_shutdown_window") or_else nil),
		update          = cast(proc(
		) -> bool)(dynlib.symbol_address(lib, "game_update") or_else nil),
		shutdown        = cast(proc())(dynlib.symbol_address(lib, "game_shutdown") or_else nil),
		memory          = cast(proc(
		) -> rawptr)(dynlib.symbol_address(lib, "game_memory") or_else nil),
		full_reset      = cast(proc(
		) -> bool)(dynlib.symbol_address(lib, "game_force_restart") or_else nil),
		hot_reloaded    = cast(proc(
			_: rawptr,
		))(dynlib.symbol_address(lib, "game_hot_reloaded") or_else nil),
		lib             = lib,
		dll_time        = dll_time,
		api_version     = api_version,
	}

	if api.init == nil ||
	   api.update == nil ||
	   api.shutdown == nil ||
	   api.memory == nil ||
	   api.hot_reloaded == nil {
		dynlib.unload_library(api.lib)
		fmt.println("Game DLL missing required procedure")
		return {}, false
	}

	return api, true
}

unload_game_api :: proc(api: GameAPI) {
	if api.lib != nil {
		dynlib.unload_library(api.lib)
	}

	del_cmd := fmt.ctprintf("del game_{0}.dll", api.api_version)
	if libc.system(del_cmd) != 0 {
		fmt.println("Failed to remove game_{0}.dll copy", api.api_version)
	}
}

main :: proc() {
	game_api_version := 0
	game_api, game_api_ok := load_game_api(game_api_version)

	if !game_api_ok {
		fmt.println("Failed to load GameAPI")
		return
	}

	game_api_version += 1

	game_api.init_window()
	game_api.init()

	for {
		if game_api.update() == false {
			break
		}

		dll_time, dll_time_err := os.last_write_time_by_name("game.dll")

		reload := dll_time_err == os.ERROR_NONE && game_api.dll_time != dll_time

		full_reset := game_api.full_reset()

		if reload {
			new_api, new_api_ok := load_game_api(game_api_version)

			if new_api_ok {
				if full_reset {
					game_api.shutdown()
					unload_game_api(game_api)
					game_api = new_api
					game_api.init()
				} else {
					game_memory := game_api.memory()
					unload_game_api(game_api)
					game_api = new_api
					game_api.hot_reloaded(game_memory)
				}
				game_api_version += 1
			}
		}
	}

	fmt.println("Shuting down the program")
	game_api.shutdown()
	game_api.shutdown_window()
	unload_game_api(game_api)
}
