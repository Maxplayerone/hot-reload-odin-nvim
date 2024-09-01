package main

import "core:fmt"

GameMemory :: struct {
	some_state: int,
}

g_mem: ^GameMemory

@(export)
game_init :: proc() {
	g_mem = new(GameMemory)
}

@(export)
game_update :: proc() -> bool {
	g_mem.some_state += 1
	fmt.println(g_mem.some_state)
	return true
}

@(export)
game_shutdown :: proc() {
	free(g_mem)
}

@(export)
game_memory :: proc() -> rawptr {
	return g_mem
}

@(export)
game_hot_reloaded :: proc(mem: ^GameMemory) {
	g_mem = mem
}

@(export)
game_force_restart :: proc() -> bool {
	if g_mem.some_state > 1000 {
		return true
	}
	return false
}
