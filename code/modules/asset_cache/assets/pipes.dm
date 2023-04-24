/datum/asset/spritesheet/pipes
	name = "pipes"

/datum/asset/spritesheet/pipes/create_spritesheets()
	for (var/each in list('icons/obj/atmospherics/pipes/pipe_item.dmi', 'icons/obj/atmospherics/pipes/disposal.dmi', 'icons/obj/atmospherics/pipes/transit_tube.dmi', 'icons/obj/plumbing/fluid_ducts.dmi'))
		InsertAll("", each, GLOB.alldirs)
	Insert(sprite_name = "gsensor1", I = 'icons/obj/stationobjs.dmi', icon_state = "gsensor1")
