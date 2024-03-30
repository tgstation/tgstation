
//random room spawner. takes random rooms from their appropriate map file and places them. the room will spawn with the spawner in the bottom left corner

/obj/effect/spawner/room
	name = "random room spawner"
	icon = 'monkestation/icons/effects/landmarks_static.dmi'
	icon_state = "random_room"
	dir = NORTH
	var/room_width = 0
	var/room_height = 0

/obj/effect/spawner/room/New(loc, ...)
	. = ..()
	if(!isnull(SSmapping.random_room_spawners))
		SSmapping.random_room_spawners += src

/obj/effect/spawner/room/Initialize(mapload)
	if(!length(SSmapping.random_room_templates))
		message_admins("Room spawner created with no templates available. This shouldn't happen.")
		return INITIALIZE_HINT_QDEL
	var/list/possibletemplates = list()
	var/datum/map_template/random_room/candidate
	shuffle_inplace(SSmapping.random_room_templates)
	for(var/ID in SSmapping.random_room_templates)
		candidate = SSmapping.random_room_templates[ID]
		if(candidate.spawned || room_height != candidate.template_height || room_width != candidate.template_width)
			candidate = null
			continue
		possibletemplates[candidate] = candidate.weight
	if(possibletemplates.len)
		var/datum/map_template/random_room/template = pick_weight(possibletemplates)
		template.stock --
		template.weight = (template.weight / 2)
		if(template.stock <= 0)
			template.spawned = TRUE
		template.load(get_turf(src), centered = template.centerspawner)
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/room/fivexfour
	name = "5x4 room spawner"
	room_width = 5
	room_height = 4

/obj/effect/spawner/room/fivexthree
	name = "5x3 room spawner"
	room_width = 5
	room_height = 3

/obj/effect/spawner/room/threexfive
	name = "3x5 room spawner"
	room_width = 3
	room_height = 5

/obj/effect/spawner/room/tenxten
	name = "10x10 room spawner"
	room_width = 10
	room_height = 10

/obj/effect/spawner/room/tenxfive
	name = "10x5 room spawner"
	room_width = 10
	room_height = 5

/obj/effect/spawner/room/threexthree
	name = "3x3 room spawner"
	room_width = 3
	room_height = 3

/obj/effect/spawner/room/fland
	name = "Special Room (5x11)"
	icon_state = "random_room_alternative"
	room_width = 5
	room_height = 11




/obj/effect/spawner/random_engines
	name = "random room spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"
	dir = NORTH
	var/room_width = 0
	var/room_height = 0

/obj/effect/spawner/random_engines/New(loc, ...)
	. = ..()
	if(!isnull(SSmapping.random_engine_spawners))
		SSmapping.random_engine_spawners += src

/obj/effect/spawner/random_engines/Initialize(mapload)
	..()
	if(!mapload)
		return INITIALIZE_HINT_QDEL
	if(!length(SSmapping.random_engine_templates))
		message_admins("Room spawner created with no templates available. This shouldn't happen.")
		return INITIALIZE_HINT_QDEL
	var/list/possible_engine_templates = list()
	var/datum/map_template/random_room/random_engines/engine_candidate
	shuffle_inplace(SSmapping.random_engine_templates)
	for(var/ID in SSmapping.random_engine_templates)
		engine_candidate = SSmapping.random_engine_templates[ID]
		if(engine_candidate.weight == 0 || room_height != engine_candidate.template_height || room_width != engine_candidate.template_width)
			engine_candidate = null
			continue
		possible_engine_templates[engine_candidate] = engine_candidate.weight
	if(possible_engine_templates.len)
		var/datum/map_template/random_room/random_engines/template = pick_weight(possible_engine_templates)
		template.load(get_turf(src), centered = template.centerspawner)
	return INITIALIZE_HINT_QDEL



///BoxStation Engine Area Spawner
/obj/effect/spawner/random_engines/box
	name = "box engine spawner"
	room_width = 29
	room_height = 26

/// MetaStation Engine Area Spawner
/obj/effect/spawner/random_engines/meta
	name = "meta engine spawner"
	room_width = 33
	room_height = 25

/// TramStation Engine Area Spawner
/obj/effect/spawner/random_engines/tram
	name = "tram engine spawner"
	room_width = 24
	room_height = 20

/obj/effect/spawner/random_engines/kilo
	name = "kilo engine spawner"
	room_width = 20
	room_height = 21



/obj/effect/spawner/random_bar
	name = "random bar spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"
	dir = NORTH
	var/room_width = 0
	var/room_height = 0

/obj/effect/spawner/random_bar/New(loc, ...)
	. = ..()
	if(!isnull(SSmapping.random_bar_spawners))
		SSmapping.random_bar_spawners += src

/obj/effect/spawner/random_bar/Initialize(mapload)
	..()
	if(!mapload)
		return INITIALIZE_HINT_QDEL

	if(!length(SSmapping.random_bar_templates))
		message_admins("Room spawner created with no templates available. This shouldn't happen.")
		return INITIALIZE_HINT_QDEL
	var/list/possible_bar_templates = list()
	var/datum/map_template/random_room/random_bar/bar_candidate
	shuffle_inplace(SSmapping.random_bar_templates)
	for(var/ID in SSmapping.random_bar_templates)
		bar_candidate = SSmapping.random_bar_templates[ID]
		if(bar_candidate.weight == 0 || room_height != bar_candidate.template_height || room_width != bar_candidate.template_width)
			bar_candidate = null
			continue
		possible_bar_templates[bar_candidate] = bar_candidate.weight
	if(possible_bar_templates.len)
		var/datum/map_template/random_room/random_bar/template = pick_weight(possible_bar_templates)
		template.load(get_turf(src), centered = template.centerspawner)
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/random_bar/box
	name = "Box Bar Spawner"
	room_width = 11
	room_height = 17

/obj/effect/spawner/random_bar/icebox
	name = "Icebox bar spawner"
	room_width = 18
	room_height = 12

/obj/effect/spawner/random_bar/tramstation
	name = "Tramstation bar spawner"
	room_width = 30
	room_height = 25
