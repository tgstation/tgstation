/*
#define FIND_PLANT 1
#define FIND_BIO 2
#define FIND_METEORIC 3
#define FIND_ICE 4
#define FIND_CRYSTALLINE 5
#define FIND_METALLIC 6
#define FIND_IGNEOUS 7
#define FIND_METAMORPHIC 8
#define FIND_SEDIMENTARY 9
#define FIND_NOTHING 10
*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Rock sliver

/obj/item/weapon/rocksliver
	name = "rock sliver"
	desc = "It looks extremely delicate."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "sliver1"	//0-4
	w_class = 1
	//item_state = "electronic"
	var/source_rock = "/turf/unsimulated/mineral/"
	var/datum/geosample/geological_data

/obj/item/weapon/rocksliver/New()
	. = ..()
	icon_state = "sliver[rand(1,3)]"
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 0)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Geosample datum

/datum/geosample
	var/age = 0								//age can correspond to different archaeological finds
	var/age_thousand = 0
	var/age_million = 0
	var/age_billion = 0
	var/artifact_id = ""					//id of a nearby artifact, if there is one
	var/artifact_distance = -1				//proportional to distance
	var/source_mineral = "chlorine"			//machines will pop up a warning telling players that the sample may be confused
	var/total_spread = 0
	//
	//var/source_mineral
	//all potential finds are initialised to null, so nullcheck before you access them
	var/list/find_presence = list()

/datum/geosample/New(var/turf/unsimulated/mineral/container)
	UpdateTurf(container)

//this should only need to be called once
/datum/geosample/proc/UpdateTurf(var/turf/unsimulated/mineral/container)
	if(!container || !istype(container))
		return

	age = rand(1,999)

	if(container.mineral)
		switch(container.mineral.name)
			if("Uranium")
				age_million = rand(1, 704)
				age_thousand = rand(1,999)
				find_presence["potassium"] = rand(1,1000) / 100
				source_mineral = "potassium"
			if("Iron")
				age_thousand = rand(1, 999)
				age_million = rand(1, 999)
				find_presence["iron"] = rand(1,1000) / 100
				source_mineral = "iron"
			if("Diamond")
				age_thousand = rand(1,999)
				age_million = rand(1,999)
				find_presence["nitrogen"] = rand(1,1000) / 100
				source_mineral = "nitrogen"
			if("Gold")
				age_thousand = rand(1,999)
				age_million = rand(1,999)
				age_billion = rand(3,4)
				find_presence["iron"] = rand(1,1000) / 100
				source_mineral = "iron"
			if("Silver")
				age_thousand = rand(1,999)
				age_million = rand(1,999)
				find_presence["iron"] = rand(1,1000) / 100
				source_mineral = "iron"
			if("Plasma")
				age_thousand = rand(1,999)
				age_million = rand(1,999)
				age_billion = rand(10, 13)
				find_presence["plasma"] = rand(1,1000) / 100
				source_mineral = "plasma"
			if("Clown")
				age = rand(-1,-999)				//thats the joke
				age_thousand = rand(-1,-999)
				find_presence["plasma"] = rand(1,1000) / 100
				source_mineral = "plasma"

	if(prob(75))
		find_presence["phosphorus"] = rand(1,500) / 100
	if(prob(25))
		find_presence["mercury"] = rand(1,500) / 100
	find_presence["chlorine"] = rand(500,2500) / 100

	//loop over finds, grab any relevant stuff
	for(var/datum/find/F in container.finds)
		var/responsive_reagent = get_responsive_reagent(F.find_type)
		find_presence[responsive_reagent] = F.dissonance_spread

	//loop over again to reset values to percentages
	var/total_presence = 0
	for(var/carrier in find_presence)
		total_presence += find_presence[carrier]
	for(var/carrier in find_presence)
		find_presence[carrier] = find_presence[carrier] / total_presence

	for(var/entry in find_presence)
		total_spread += find_presence[entry]

//have this separate from UpdateTurf() so that we dont have a billion turfs being updated (redundantly) every time an artifact spawns
/datum/geosample/proc/UpdateNearbyArtifactInfo(var/turf/unsimulated/mineral/container)
	if(!container || !istype(container))
		return

	if(container.artifact_find)
		artifact_distance = rand()
		artifact_id = container.artifact_find.artifact_id
	else
		if(master_controller) //Sanity check due to runtimes ~Z
			for(var/turf/unsimulated/mineral/T in master_controller.artifact_spawning_turfs)
				if(T.artifact_find)
					var/cur_dist = get_dist(container, T) * 2
					if( (artifact_distance < 0 || cur_dist < artifact_distance) && cur_dist <= T.artifact_find.artifact_detect_range )
						artifact_distance = cur_dist + rand() * 2 - 1
						artifact_id = T.artifact_find.artifact_id
				else
					master_controller.artifact_spawning_turfs.Remove(T)

/*
#undef FIND_PLANT
#undef FIND_BIO
#undef FIND_METEORIC
#undef FIND_ICE
#undef FIND_CRYSTALLINE
#undef FIND_METALLIC
#undef FIND_IGNEOUS
#undef FIND_METAMORPHIC
#undef FIND_SEDIMENTARY
#undef FIND_NOTHING
*/
