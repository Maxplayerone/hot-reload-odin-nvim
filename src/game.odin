package game

import rl "vendor:raylib"

Game_Memory :: struct {}

g_mem: ^Game_Memory

Width :: 1280
Height :: 720

@(export)
game_init_window :: proc() {
	rl.InitWindow(Width, Height, "Odin + Raylib + Hot Reload template!")
	rl.SetWindowPosition(200, 200)
	rl.SetTargetFPS(500)
}

@(export)
game_init :: proc() {
	g_mem = new(Game_Memory)

	g_mem^ = Game_Memory{}

	game_hot_reloaded(g_mem)
}

@(export)
game_update :: proc() -> bool {
	rl.BeginDrawing()
	rl.ClearBackground(rl.WHITE)
	rl.DrawRectangleRec(rl.Rectangle{Width / 2 - 50, Height / 2 - 50, 100, 100}, rl.BLACK)
	rl.EndDrawing()
	return !rl.WindowShouldClose()
}

@(export)
game_shutdown :: proc() {
	free(g_mem)
}

@(export)
game_shutdown_window :: proc() {
	rl.CloseWindow()
}

@(export)
game_memory :: proc() -> rawptr {
	return g_mem
}

@(export)
game_memory_size :: proc() -> int {
	return size_of(Game_Memory)
}

@(export)
game_hot_reloaded :: proc(mem: rawptr) {
	g_mem = (^Game_Memory)(mem)
}

@(export)
game_force_reload :: proc() -> bool {
	return rl.IsKeyPressed(.Z)
}

@(export)
game_force_restart :: proc() -> bool {
	return rl.IsKeyPressed(.Q)
}
