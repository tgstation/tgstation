/obj/effect/spawner/room
	name = "room spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"
	var/datum/map_template/random_room/template

/obj/effect/spawner/room/proc/LateSpawn()
	template.load(get_turf(src), centered = FALSE, orientation = dir)
	qdel(src)

/obj/effect/spawner/room/pod_spawn
	name = "supply pod spawner"
	icon_state = "supply_pod"
	var/static/spawned = FALSE

/obj/effect/spawner/room/pod_spawn/Initialize()
	. = ..()
	if(!spawned && prob(10))
		spawned = TRUE
		if(prob(50))
			template = SSmapping.random_room_templates["pod_grey"]
		else
			template = SSmapping.random_room_templates["pod_supplies"]
		if(!template)
			throw EXCEPTION("Random pod template not found!")
			qdel(src)
			return
		addtimer(CALLBACK(src, /obj/effect/spawner/room.proc/LateSpawn), 600)
	else
		qdel(src)


/obj/effect/spawner/room/fivebyfour
	name = "random 5x4 maint room spawner"
	dir = 1

/obj/effect/spawner/room/fivebyfour/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/spawner/room/fivebyfour/LateInitialize()
	shuffle_inplace(SSmapping.random_room_templates)
	for(var/ID in SSmapping.random_room_templates)
		template = SSmapping.random_room_templates[ID]
		if(istype(template, /datum/map_template/random_room/fivebyfour))
			if(!template.spawned)
				template.spawned = TRUE
				if(prob(50) && template.flippable)//50% chance of room loading flipped
					if(dir == 1)
						dir = 2
					else if(dir == 4)
						dir = 8
				addtimer(CALLBACK(src, /obj/effect/spawner/room.proc/LateSpawn), 600)
				break
		template = null
	if(!template)
		qdel(src)