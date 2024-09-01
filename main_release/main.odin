package main_release

import game "../src"

main :: proc() {
	game.game_init()

	for {
		if game.game_update() == false {
			break
		}
	}

	game.game_shutdown()
}
