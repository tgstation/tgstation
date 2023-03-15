/obj/effect/spawner/random_bars
	name = "random room spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"
	dir = NORTH
	var/room_width = 0
	var/room_height = 0

/obj/effect/spawner/random_bars/New(loc, ...)
	. = ..()
	if(!isnull(SSmapping.random_bar_spawners))
		SSmapping.random_bar_spawners += src

/obj/effect/spawner/random_bars/Initialize(mapload)
	..()
	if(!length(SSmapping.random_bar_templates))
		message_admins("Room spawner created with no templates available. This shouldn't happen.")
		return INITIALIZE_HINT_QDEL
	var/list/possible_bar_templates = list()
	var/datum/map_template/random_bars/bar_candidate
	shuffle_inplace(SSmapping.random_bar_templates)
	for(var/ID in SSmapping.random_bar_templates)
		bar_candidate = SSmapping.random_bar_templates[ID]
		if(bar_candidate.weight == 0 || room_height != bar_candidate.template_height || room_width != bar_candidate.template_width)
			bar_candidate = null
			continue
		possible_bar_templates[bar_candidate] = bar_candidate.weight
	if(possible_bar_templates.len)
		var/datum/map_template/random_bars/template = pickweight(possible_bar_templates)
		template.load(get_turf(src), centered = template.centerspawner)
	return INITIALIZE_HINT_QDEL

/// Box Station Bar Area Spawner
/obj/effect/spawner/random_bars/box
	name = "box bar spawner"
	room_width = 15
	room_height = 9

/// MetaStation Bar Area Spawner
/obj/effect/spawner/random_bars/meta
	name = "meta bar spawner"
	room_width = 9
	room_height = 9

/// PubbyStation Bar Area Spawner
/obj/effect/spawner/random_bars/pubby
	name = "pubby bar spawner"
	room_width = 18
	room_height = 12




