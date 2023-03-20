
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




///RandomEngines - BoxStation Area Spawner
/obj/effect/spawner/room/engine/box
	name = "box engine spawner"
	room_width = 32
	room_height = 27

///RandomEngines - MetaStation Area Spawner
/obj/effect/spawner/room/engine/meta
	name = "meta engine spawner"
	room_width = 32
	room_height = 26
