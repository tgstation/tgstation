/datum/asset/spritesheet/pipes
	name = "pipes"

/datum/asset/spritesheet/pipes/create_spritesheets()
	for (var/each in list('icons/obj/pipes_n_cables/pipes/pipe_item.dmi', 'icons/obj/pipes_n_cables/pipes/disposal.dmi', 'icons/obj/pipes_n_cables/pipes/transit_tube.dmi', 'icons/obj/pipes_n_cables/hydrochem/fluid_ducts.dmi'))
		InsertAll("", each, GLOB.alldirs)
