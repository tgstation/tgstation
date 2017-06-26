//The necropolis gate is used to call forth Legion from the Necropolis.
/obj/structure/necropolis_gate
	name = "necropolis gate"
	desc = "A tremendous and impossibly large gateway, bored into dense bedrock."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "door"
	anchored = 1
	density = 1
	opacity = 1
	bound_width = 96
	bound_height = 96
	pixel_x = -32
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 1
	var/boss = FALSE
	var/is_anyone_home = FALSE

/obj/structure/necropolis_gate/attack_hand(mob/user)
	for(var/mob/living/simple_animal/hostile/megafauna/legion/L in GLOB.mob_list)
		return
	if(is_anyone_home)
		return
	var/safety = alert(user, "You think this might be a bad idea...", "Knock on the door?", "Proceed", "Abort")
	if(safety == "Abort" || !in_range(src, user) || !src || is_anyone_home || user.incapacitated())
		return
	user.visible_message("<span class='warning'>[user] knocks on [src]...</span>", "<span class='boldannounce'>You tentatively knock on [src]...</span>")
	playsound(user.loc, 'sound/effects/shieldbash.ogg', 100, 1)
	is_anyone_home = TRUE
	sleep(50)
	if(boss)
		to_chat(user, "<span class='notice'>There's no response.</span>")
		is_anyone_home = FALSE
		return 0
	boss = TRUE
	visible_message("<span class='warning'>Locks along the door begin clicking open from within...</span>")
	var/volume = 60
	for(var/i in 1 to 3)
		playsound(src, 'sound/items/deconstruct.ogg', volume, 0)
		volume += 20
		sleep(10)
	sleep(10)
	visible_message("<span class='userdanger'>Something horrible emerges from the Necropolis!</span>")
	message_admins("[key_name_admin(user)] has summoned Legion!")
	log_game("[key_name(user)] summoned Legion.")
	for(var/mob/M in GLOB.player_list)
		if(M.z == z)
			to_chat(M, "<span class='userdanger'>Discordant whispers flood your mind in a thousand voices. Each one speaks your name, over and over. Something horrible has come.</span>")
			M << 'sound/creatures/legion_spawn.ogg'
			flash_color(M, flash_color = "#FF0000", flash_time = 50)
	var/mutable_appearance/door_overlay = mutable_appearance('icons/effects/effects.dmi', "legiondoor")
	notify_ghosts("Legion has been summoned in the [get_area(src)]!", source = src, alert_overlay = door_overlay, action = NOTIFY_JUMP)
	is_anyone_home = FALSE
	new/mob/living/simple_animal/hostile/megafauna/legion(get_step(src.loc, SOUTH))

/obj/structure/necropolis_gate/singularity_pull()
	return 0

/obj/structure/necropolis_gate/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

//stone tiles for boss arenas
/obj/structure/stone_tile
	name = "stone tile"
	icon = 'icons/turf/boss_floors.dmi'
	icon_state = "pristine_tile1"
	layer = OVER_LATTICE_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/tile_key = "pristine_tile"
	var/tile_random_sprite_max = 24

/obj/structure/stone_tile/Initialize(mapload)
	. = ..()
	icon_state = "[tile_key][rand(1, tile_random_sprite_max)]"

/obj/structure/stone_tile/block
	name = "stone block"
	icon_state = "pristine_block1"
	tile_key = "pristine_block"
	tile_random_sprite_max = 4

/obj/structure/stone_tile/slab
	name = "stone slab"
	icon_state = "pristine_slab1"
	tile_key = "pristine_slab"
	tile_random_sprite_max = 4

/obj/structure/stone_tile/center
	name = "stone center tile"
	icon_state = "pristine_center1"
	tile_key = "pristine_center"
	tile_random_sprite_max = 4

/obj/structure/stone_tile/surrounding
	name = "stone surrounding slab"
	icon_state = "pristine_surrounding1"
	tile_key = "pristine_surrounding"
	tile_random_sprite_max = 2

/obj/structure/stone_tile/surrounding_tile
	name = "stone surrounding tile"
	icon_state = "pristine_surrounding_tile1"
	tile_key = "pristine_surrounding_tile"
	tile_random_sprite_max = 2

//cracked stone tiles
/obj/structure/stone_tile/cracked
	name = "cracked stone tile"
	icon_state = "cracked_tile1"
	tile_key = "cracked_tile"

/obj/structure/stone_tile/block/cracked
	name = "cracked stone block"
	icon_state = "cracked_block1"
	tile_key = "cracked_block"

/obj/structure/stone_tile/slab/cracked
	name = "cracked stone slab"
	icon_state = "cracked_slab1"
	tile_key = "cracked_slab"
	tile_random_sprite_max = 1

/obj/structure/stone_tile/center/cracked
	name = "cracked stone center tile"
	icon_state = "cracked_center1"
	tile_key = "cracked_center"

/obj/structure/stone_tile/surrounding/cracked
	name = "cracked stone surrounding slab"
	icon_state = "cracked_surrounding1"
	tile_key = "cracked_surrounding"
	tile_random_sprite_max = 1

/obj/structure/stone_tile/surrounding_tile/cracked
	name = "cracked stone surrounding tile"
	icon_state = "cracked_surrounding_tile1"
	tile_key = "cracked_surrounding_tile"

//burnt stone tiles
/obj/structure/stone_tile/burnt
	name = "burnt stone tile"
	icon_state = "burnt_tile1"
	tile_key = "burnt_tile"

/obj/structure/stone_tile/block/burnt
	name = "burnt stone block"
	icon_state = "burnt_block1"
	tile_key = "burnt_block"

/obj/structure/stone_tile/slab/burnt
	name = "burnt stone slab"
	icon_state = "burnt_slab1"
	tile_key = "burnt_slab"

/obj/structure/stone_tile/center/burnt
	name = "burnt stone center tile"
	icon_state = "burnt_center1"
	tile_key = "burnt_center"

/obj/structure/stone_tile/surrounding/burnt
	name = "burnt stone surrounding slab"
	icon_state = "burnt_surrounding1"
	tile_key = "burnt_surrounding"

/obj/structure/stone_tile/surrounding_tile/burnt
	name = "burnt stone surrounding tile"
	icon_state = "burnt_surrounding_tile1"
	tile_key = "burnt_surrounding_tile"

//hot stone tiles, cosmetic only
/obj/structure/stone_tile/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/block/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/slab/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/center/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/surrounding/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/surrounding_tile/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

//hot cracked stone tiles, cosmetic only
/obj/structure/stone_tile/cracked/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/block/cracked/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/slab/cracked/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/center/cracked/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/surrounding/cracked/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/surrounding_tile/cracked/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

//hot burnt stone tiles, cosmetic only
/obj/structure/stone_tile/burnt/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/block/burnt/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/slab/burnt/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/center/burnt/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/surrounding/burnt/hot
	icon = 'icons/turf/boss_floors_hot.dmi'

/obj/structure/stone_tile/surrounding_tile/burnt/hot
	icon = 'icons/turf/boss_floors_hot.dmi'
