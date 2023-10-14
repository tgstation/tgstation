/proc/reset_arena_area()
	var/list/turfs = get_area_turfs(/area/centcom/tdome/arena/actual)
	for(var/turf/listed_turf in turfs)
		for(var/atom/listed_atom in listed_turf.contents)
			if(istype(listed_atom, /mob/dead/observer))
				continue
			if(istype(listed_atom, /mob/living/carbon/human/ghost))
				var/mob/living/carbon/human/ghost/mob = listed_atom
				mob.move_to_ghostspawn()
				mob.fully_heal()
				continue
			qdel(listed_atom)
		listed_turf.baseturfs = list(/turf/open/indestructible/event/plating)
	var/turf/located = locate(148, 29, SSmapping.levels_by_trait(ZTRAIT_CENTCOM)[1]) // this grabs the bottom corner turf
	new /obj/effect/spawner/random_arena_spawner(located)

/obj/effect/spawner/random_arena_spawner
	name = "random arena spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"
	dir = NORTH
	var/room_width = 17
	var/room_height = 10

/obj/effect/spawner/random_arena_spawner/New()
	if(!isnull(SSmapping.random_arena_spawners) && (SSticker.current_state != GAME_STATE_PLAYING && SSticker.current_state != GAME_STATE_FINISHED))
		SSmapping.random_arena_spawners += src
	else
		. = ..()

/obj/effect/spawner/random_arena_spawner/Initialize(mapload)
	if(mapload)
		return INITIALIZE_HINT_QDEL
	else
		if(!length(SSmapping.random_arena_templates))
			message_admins("Room spawner created with no templates available. This shouldn't happen.")
			return INITIALIZE_HINT_QDEL

		var/list/possible_arenas = list()
		var/datum/map_template/random_room/random_arena/arena_candidate
		shuffle_inplace(SSmapping.random_arena_templates)
		for(var/ID in SSmapping.random_arena_templates)
			arena_candidate = SSmapping.random_arena_templates[ID]
			if(arena_candidate.weight == 0)
				arena_candidate = null
				continue
			possible_arenas[arena_candidate] = arena_candidate.weight

		if(possible_arenas.len)
			var/datum/map_template/random_room/random_arena/template = pick_weight(possible_arenas)
			template.load(get_turf(src), centered = template.centerspawner)
		return INITIALIZE_HINT_QDEL
