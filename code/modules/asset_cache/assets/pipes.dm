/datum/asset/spritesheet/pipes
	name = "pipes"

/datum/asset/spritesheet/pipes/create_spritesheets()
	 ///SKYRAPTOR EDIT: pipe_item redir to aestheticsmodule
	for (var/each in list('modular_skyraptor/modules/aesthetics/moremospherics/icons/pipes/pipe_item.dmi', 'icons/obj/pipes_n_cables/disposal.dmi', 'icons/obj/pipes_n_cables/transit_tube.dmi', 'icons/obj/pipes_n_cables/hydrochem/fluid_ducts.dmi'))
		InsertAll("", each, GLOB.alldirs)
