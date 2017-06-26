//The necropolis gate is used to call forth Legion from the Necropolis.
/obj/structure/necropolis_gate
	name = "necropolis gate"
	desc = "A massive stone gateway."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "gate_full"
	layer = TABLE_LAYER
	anchored = TRUE
	density = TRUE
	pixel_x = -32
	pixel_y = -32
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 8
	light_color = LIGHT_COLOR_LAVA
	var/open = FALSE
	var/static/mutable_appearance/top_overlay
	var/static/mutable_appearance/door_overlay
	var/obj/structure/opacity_blocker/sight_blocker
	var/sight_blocker_distance = 1

/obj/structure/necropolis_gate/Initialize()
	. = ..()
	var/turf/sight_blocker_turf = get_turf(src)
	if(sight_blocker_distance)
		for(var/i in 1 to sight_blocker_distance)
			if(!sight_blocker_turf)
				break
			sight_blocker_turf = get_step(sight_blocker_turf, NORTH)
	if(sight_blocker_turf)
		sight_blocker = new (sight_blocker_turf) //we need to block sight in a different spot than most things do
	icon_state = "gate_bottom"
	top_overlay = mutable_appearance('icons/effects/96x96.dmi', "gate_top")
	top_overlay.layer = EDGED_TURF_LAYER
	add_overlay(top_overlay)
	door_overlay = mutable_appearance('icons/effects/96x96.dmi', "door")
	add_overlay(door_overlay)

/obj/structure/necropolis_gate/Destroy(force)
	if(force)
		qdel(sight_blocker, TRUE)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/obj/structure/necropolis_gate/singularity_pull()
	return 0

/obj/structure/opacity_blocker
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	mouse_opacity = 0
	opacity = TRUE

/obj/structure/opacity_blocker/singularity_pull()
	return 0

/obj/structure/opacity_blocker/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/obj/structure/necropolis_gate/attack_hand(mob/user)
	open_the_gate(user)

/obj/structure/necropolis_gate/proc/open_the_gate(mob/user, legion_damaged)
	if(open)
		return
	open = TRUE
	cut_overlay(door_overlay)
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/necropolis_open(T)
	sleep(2)
	visible_message("<span class='warning'>The door starts to grind open...</span>")
	playsound(T, 'sound/effects/stonedoor_openclose.ogg', 300, TRUE, frequency = 20000)
	sleep(27)
	qdel(sight_blocker, TRUE)
	sleep(5)
	density = FALSE
	return TRUE

/obj/structure/necropolis_gate/locked/attack_hand(mob/user)
	to_chat(user, "<span class='boldannounce'>It's locked.</span>")

GLOBAL_DATUM(necropolis_gate, /obj/structure/necropolis_gate/legion_gate)
/obj/structure/necropolis_gate/legion_gate
	desc = "A tremendous, impossibly large gateway, set into a massive tower of stone."
	sight_blocker_distance = 2

/obj/structure/necropolis_gate/legion_gate/Initialize()
	. = ..()
	GLOB.necropolis_gate = src

/obj/structure/necropolis_gate/legion_gate/Destroy(force)
	if(force)
		if(GLOB.necropolis_gate == src)
			GLOB.necropolis_gate = null
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/obj/structure/necropolis_gate/legion_gate/attack_hand(mob/user)
	if(open)
		return
	var/safety = alert(user, "You think this might be a bad idea...", "Knock on the door?", "Proceed", "Abort")
	if(safety == "Abort" || !in_range(src, user) || !src || open || user.incapacitated())
		return
	user.visible_message("<span class='warning'>[user] knocks on [src]...</span>", "<span class='boldannounce'>You tentatively knock on [src]...</span>")
	playsound(user.loc, 'sound/effects/shieldbash.ogg', 100, 1)
	sleep(50)
	..()

/obj/structure/necropolis_gate/legion_gate/open_the_gate(mob/user, legion_damaged)
	. = ..()
	if(.)
		visible_message("<span class='userdanger'>Something horrible emerges from the Necropolis!</span>")
		if(legion_damaged)
			message_admins("Legion took damage while the necropolis gate was closed, and has released itself!")
			log_game("Legion took damage while the necropolis gate was closed and released itself.")
		else
			message_admins("[user ? "key_name_admin(user)":"Unknown"] has released Legion!")
			log_game("[user ? "key_name(user)":"Unknown"] released Legion.")
		for(var/mob/M in GLOB.player_list)
			if(M.z == z)
				to_chat(M, "<span class='userdanger'>Discordant whispers flood your mind in a thousand voices. Each one speaks your name, over and over. Something horrible has been released.</span>")
				M.playsound_local(T, 'sound/creatures/legion_spawn.ogg', 100, FALSE, 0, FALSE, pressure_affected = FALSE)
				flash_color(M, flash_color = "#FF0000", flash_time = 50)
		var/mutable_appearance/release_overlay = mutable_appearance('icons/effects/effects.dmi', "legiondoor")
		notify_ghosts("Legion has been released in the [get_area(src)]!", source = src, alert_overlay = release_overlay, action = NOTIFY_JUMP)

/obj/effect/temp_visual/necropolis_open
	icon = 'icons/effects/96x96.dmi'
	icon_state = "door_opening"
	duration = 38
	layer = TABLE_LAYER
	pixel_x = -32
	pixel_y = -32

/obj/structure/necropolis_arch
	name = "necropolis arch"
	desc = "A massive arch over the necropolis gate, set into a massive tower of stone."
	icon = 'icons/effects/160x160.dmi'
	icon_state = "arch_full"
	layer = TABLE_LAYER
	anchored = TRUE
	pixel_x = -64
	pixel_y = -40
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/open = FALSE
	var/static/mutable_appearance/top_overlay

/obj/structure/necropolis_arch/Initialize()
	. = ..()
	icon_state = "arch_bottom"
	top_overlay = mutable_appearance('icons/effects/160x160.dmi', "arch_top")
	top_overlay.layer = EDGED_TURF_LAYER
	add_overlay(top_overlay)

/obj/structure/necropolis_arch/singularity_pull()
	return 0

/obj/structure/necropolis_arch/Destroy(force)
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
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/tile_key = "pristine_tile"
	var/tile_random_sprite_max = 24

/obj/structure/stone_tile/Initialize(mapload)
	. = ..()
	icon_state = "[tile_key][rand(1, tile_random_sprite_max)]"

/obj/structure/stone_tile/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

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
