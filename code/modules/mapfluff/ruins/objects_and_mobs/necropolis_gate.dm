//The necropolis gate is used to call forth Legion from the Necropolis.
/obj/structure/necropolis_gate
	name = "necropolis gate"
	desc = "A massive stone gateway."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "gate_full"
	flags_1 = ON_BORDER_1
	appearance_flags = 0
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	anchored = TRUE
	density = TRUE
	pixel_x = -32
	pixel_y = -32
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 8
	light_color = LIGHT_COLOR_LAVA
	can_atmos_pass = ATMOS_PASS_DENSITY
	move_resist = INFINITY
	var/open = FALSE
	var/changing_openness = FALSE
	var/locked = FALSE
	var/static/mutable_appearance/top_overlay
	var/static/mutable_appearance/door_overlay
	var/obj/structure/opacity_blocker/sight_blocker
	var/sight_blocker_distance = 1

/obj/structure/necropolis_gate/Initialize(mapload)
	. = ..()
	setDir(SOUTH)
	var/turf/sight_blocker_turf = get_turf(src)
	if(sight_blocker_distance)
		for(var/i in 1 to sight_blocker_distance)
			if(!sight_blocker_turf)
				break
			sight_blocker_turf = get_step(sight_blocker_turf, NORTH)
	if(sight_blocker_turf)
		sight_blocker = new (sight_blocker_turf) //we need to block sight in a different spot than most things do
		sight_blocker.pixel_y = initial(sight_blocker.pixel_y) - (32 * sight_blocker_distance)
	icon_state = "gate_bottom"
	top_overlay = mutable_appearance('icons/effects/96x96.dmi', "gate_top")
	top_overlay.layer = EDGED_TURF_LAYER
	add_overlay(top_overlay)
	door_overlay = mutable_appearance('icons/effects/96x96.dmi', "door")
	door_overlay.layer = EDGED_TURF_LAYER
	add_overlay(door_overlay)

	new /obj/effect/decal/necropolis_gate_decal(loc)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)
	AddComponent(/datum/component/seethrough, SEE_THROUGH_MAP_DEFAULT_TWO_TALL, clickthrough = FALSE)

/obj/structure/necropolis_gate/Destroy(force)
	qdel(sight_blocker)
	return ..()

/obj/structure/necropolis_gate/singularity_pull(atom/singularity, current_size)
	return 0

/obj/structure/necropolis_gate/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(border_dir != dir)
		return TRUE

/obj/structure/necropolis_gate/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving.movement_type & PHASING)
		return

	if(leaving == src)
		return // Let's not block ourselves.

	if (direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/opacity_blocker
	icon = 'icons/effects/96x96.dmi'
	icon_state = "gate_blocker"
	layer = EDGED_TURF_LAYER
	pixel_x = -32
	pixel_y = -32
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	opacity = TRUE
	anchored = TRUE

/obj/structure/opacity_blocker/singularity_pull(atom/singularity, current_size)
	return FALSE

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/necropolis_gate/attack_hand(mob/user, list/modifiers)
	if(locked)
		to_chat(user, span_bolddanger("It's [open ? "stuck open":"locked"]."))
		return
	toggle_the_gate(user)
	return ..()

/obj/structure/necropolis_gate/proc/toggle_the_gate(mob/user, legion_damaged)
	if(changing_openness)
		return
	changing_openness = TRUE
	var/turf/T = get_turf(src)
	if(open)
		new /obj/effect/temp_visual/necropolis(T)
		visible_message(span_boldwarning("The door slams closed!"))
		sleep(0.1 SECONDS)
		playsound(T, 'sound/effects/stonedoor_openclose.ogg', 300, TRUE, frequency = 80000)
		sleep(0.1 SECONDS)
		set_density(TRUE)
		sleep(0.1 SECONDS)
		var/turf/sight_blocker_turf = get_turf(src)
		if(sight_blocker_distance)
			for(var/i in 1 to sight_blocker_distance)
				if(!sight_blocker_turf)
					break
				sight_blocker_turf = get_step(sight_blocker_turf, NORTH)
		if(sight_blocker_turf)
			sight_blocker.pixel_y = initial(sight_blocker.pixel_y) - (32 * sight_blocker_distance)
			sight_blocker.forceMove(sight_blocker_turf)
		sleep(0.25 SECONDS)
		playsound(T, 'sound/effects/magic/clockwork/invoke_general.ogg', 30, TRUE, frequency = 15000)
		add_overlay(door_overlay)
		open = FALSE
	else
		cut_overlay(door_overlay)
		new /obj/effect/temp_visual/necropolis/open(T)
		sleep(0.2 SECONDS)
		visible_message(span_warning("The door starts to grind open..."))
		playsound(T, 'sound/effects/stonedoor_openclose.ogg', 300, TRUE, frequency = 20000)
		sleep(2.2 SECONDS)
		sight_blocker.forceMove(src)
		sleep(0.5 SECONDS)
		set_density(FALSE)
		sleep(0.5 SECONDS)
		open = TRUE
	changing_openness = FALSE
	return TRUE

/obj/structure/necropolis_gate/locked
	locked = TRUE

GLOBAL_DATUM(necropolis_gate, /obj/structure/necropolis_gate/legion_gate)
/obj/structure/necropolis_gate/legion_gate
	desc = "A tremendous, impossibly large gateway, set into a massive tower of stone."
	sight_blocker_distance = 2

/obj/structure/necropolis_gate/legion_gate/Initialize(mapload)
	. = ..()
	GLOB.necropolis_gate = src

/obj/structure/necropolis_gate/legion_gate/Destroy(force)
	if(GLOB.necropolis_gate == src)
		GLOB.necropolis_gate = null
	return ..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/necropolis_gate/legion_gate/attack_hand(mob/user, list/modifiers)
	if(!open && !changing_openness)
		var/safety = tgui_alert(user, "You think this might be a bad idea...", "Knock on the door?", list("Proceed", "Abort"))
		if(safety == "Abort" || !in_range(src, user) || !src || open || changing_openness || user.incapacitated)
			return
		user.visible_message(span_warning("[user] knocks on [src]..."), span_bolddanger("You tentatively knock on [src]..."))
		playsound(user.loc, 'sound/effects/shieldbash.ogg', 100, TRUE)
		sleep(5 SECONDS)
	return ..()

/obj/structure/necropolis_gate/legion_gate/toggle_the_gate(mob/user, legion_damaged)
	if(open)
		return
	. = ..()
	if(.)
		locked = TRUE
		var/turf/T = get_turf(src)
		visible_message(span_userdanger("Something horrible emerges from the Necropolis!"))
		if(legion_damaged)
			message_admins("Legion took damage while the necropolis gate was closed, and has released itself!")
			log_game("Legion took damage while the necropolis gate was closed and released itself.")
		else
			message_admins("[user ? ADMIN_LOOKUPFLW(user):"Unknown"] has released Legion!")
			user.log_message("released Legion.", LOG_GAME)

		var/sound/legion_sound = sound('sound/mobs/non-humanoids/legion/legion_spawn.ogg')
		for(var/mob/M in GLOB.player_list)
			if(is_valid_z_level(get_turf(M), T))
				to_chat(M, span_userdanger("Discordant whispers flood your mind in a thousand voices. Each one speaks your name, over and over. Something horrible has been released."))
				M.playsound_local(T, null, 100, FALSE, 0, FALSE, pressure_affected = FALSE, sound_to_use = legion_sound)
				flash_color(M, flash_color = "#FF0000", flash_time = 50)
		var/mutable_appearance/release_overlay = mutable_appearance('icons/effects/effects.dmi', "legiondoor")
		notify_ghosts(
			"Legion has been released in the [get_area(src)]!",
			source = src,
			alert_overlay = release_overlay,
			notify_flags = NOTIFY_CATEGORY_NOFLASH,
		)

/obj/effect/decal/necropolis_gate_decal
	icon = 'icons/effects/96x96.dmi'
	icon_state = "gate_dais"
	flags_1 = ON_BORDER_1
	appearance_flags = 0
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/necropolis
	icon = 'icons/effects/96x96.dmi'
	icon_state = "door_closing"
	appearance_flags = 0
	duration = 6
	layer = EDGED_TURF_LAYER
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/necropolis/open
	icon_state = "door_opening"
	duration = 38

/obj/structure/necropolis_arch
	name = "necropolis arch"
	desc = "A massive arch over the necropolis gate, set into a massive tower of stone."
	icon = 'icons/effects/160x160.dmi'
	icon_state = "arch_full"
	appearance_flags = 0
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	anchored = TRUE
	pixel_x = -64
	pixel_y = -40
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/open = FALSE
	var/static/mutable_appearance/top_overlay

/obj/structure/necropolis_arch/Initialize(mapload)
	. = ..()
	icon_state = "arch_bottom"
	top_overlay = mutable_appearance('icons/effects/160x160.dmi', "arch_top")
	top_overlay.layer = EDGED_TURF_LAYER
	add_overlay(top_overlay)

	AddComponent(/datum/component/seethrough, SEE_THROUGH_MAP_DEFAULT_TWO_TALL)

/obj/structure/necropolis_arch/singularity_pull(atom/singularity, current_size)
	return 0

//stone tiles for boss arenas
/obj/structure/stone_tile
	name = "stone tile"
	icon = 'icons/turf/boss_floors.dmi'
	icon_state = "pristine_tile1"
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/tile_key = "pristine_tile"
	var/tile_random_sprite_max = 24

/obj/structure/stone_tile/Initialize(mapload)
	. = ..()
	icon_state = "[tile_key][rand(1, tile_random_sprite_max)]"

	var/static/list/give_turf_traits
	if(!give_turf_traits)
		give_turf_traits = string_list(list(TRAIT_LAVA_STOPPED, TRAIT_CHASM_STOPPED, TRAIT_IMMERSE_STOPPED))
	AddElement(/datum/element/give_turf_traits, give_turf_traits)

/obj/structure/stone_tile/singularity_pull(atom/singularity, current_size)
	return

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
