/obj/effect/rockhill/dungeon_helper/east
	dir = EAST
	top = FALSE

/obj/effect/rockhill/dungeon_helper/east/top
	dir = EAST
	top = TRUE

/obj/effect/rockhill/dungeon_helper/north
	dir = NORTH
	top = FALSE

/obj/effect/rockhill/dungeon_helper/south
	dir = SOUTH
	top = FALSE

/obj/effect/rockhill/dungeon_helper/west
	dir = WEST
	top = FALSE

/obj/structure/rockhill/dungeon_entry/center
	name = "The Tomb of Alotheos"
	desc = "Greedy fool, will you emerge rich and victorious, or be entombed forever?"
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/portal.dmi'
	icon_state = "portal"
	pixel_x = -48
	dungeon_id = "center"
	target_exit_id = "hamlet"
	claim_free_exit = FALSE
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')

/obj/structure/rockhill/dungeon_exit
	name = "dungeon exit"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "ladder10"
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
