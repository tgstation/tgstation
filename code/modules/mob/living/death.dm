/mob/living/death(gibbed)
	if(!gibbed && can_butcher)
		verbs += /mob/living/proc/butcher

	//Check the global list of butchering drops for our species.
	//See code/datums/helper_datums/butchering.dm
	init_butchering_list()

	clear_fullscreens()
	..()

/mob/living/proc/init_butchering_list()
	butchering_drops = list()

	if(species_type && (!src.butchering_drops || !src.butchering_drops.len))
		if(animal_butchering_products[species_type])
			var/list/L = animal_butchering_products[species_type]

			for(var/butchering_type in L)
				src.butchering_drops += new butchering_type
