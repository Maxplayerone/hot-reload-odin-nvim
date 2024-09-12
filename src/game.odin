package main

import "core:fmt"
import rl "vendor:raylib"

_ :: fmt

Player :: struct {
	pos:    rl.Vector2,
	radius: f32,
	color:  rl.Color,
}

get_triangle_from_pos_and_radius :: proc(
	pos: rl.Vector2,
	radius: f32,
) -> (
	rl.Vector2,
	rl.Vector2,
	rl.Vector2,
) {

	top_vertex := rl.Vector2{pos.x, pos.y + radius}
	left_vertex := rl.Vector2{pos.x - 0.87 * radius, pos.y - 0.5 * radius}
	right_vertex := rl.Vector2{pos.x + 0.87 * radius, pos.y - 0.5 * radius}

	return top_vertex, left_vertex, right_vertex
}

GameMemory :: struct {
	player: Player,
	Width:  i32,
	Height: i32,
}

g_mem: ^GameMemory

@(export)
game_init_window :: proc() {
	Width: i32 = 1280
	Height: i32 = 720
	rl.InitWindow(Width, Height, "raylib hot reloading")
	rl.SetTargetFPS(60)

	//g_mem.Width = Width
	//g_mem.Height = Height

	/*
	g_mem.player = Player {
		pos    = {f32(Width / 2), f32(Height / 2)},
		radius = 20,
	}
	*/
}

@(export)
game_init :: proc() {
	g_mem = new(GameMemory)
}

@(export)
game_update :: proc() -> bool {
	//updating

	//drawing
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.DrawTriangle(
		get_triangle_from_pos_and_radius(g_mem.player.pos, g_mem.player.radius),
		g_mem.player.color,
	)

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
game_hot_reloaded :: proc(mem: ^GameMemory) {
	g_mem = mem
}

@(export)
game_force_restart :: proc() -> bool {
	return false
}
