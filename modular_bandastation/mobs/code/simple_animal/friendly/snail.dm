/mob/living/basic/snail
	death_sound = 'modular_bandastation/mobs/sound/crack_death1.ogg'

/mob/living/basic/snail/space
	name = "космоулитка"
	desc = "Маленькая космо-улиточка со своим космо-домиком. Прочная, тихая и медленная."
	icon = 'modular_bandastation/mobs/icons/animal.dmi'
	icon_state = "snail"
	icon_living = "snail"
	icon_dead = "snail_dead"

	habitable_atmos = null
	minimum_survivable_temperature = TCMB
	maximum_survivable_temperature = T0C + 1500

	var/datum/reagent/wet_reagent = /datum/reagent/water
	var/wet_volume = 10

/mob/living/basic/snail/space/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_SPACEWALK, TRAIT_SWIMMER, TRAIT_FENCE_CLIMBER, TRAIT_SNOWSTORM_IMMUNE), INNATE_TRAIT)

/mob/living/basic/snail/space/Move(atom/newloc, direct, movetime)
	var/oldLoc = src.loc
	. = ..()
	if(.)
		if(stat != DEAD)
			make_wet_floor(oldLoc)

/mob/living/basic/snail/space/proc/make_wet_floor(atom/oldLoc)
	if(oldLoc != src.loc)
		//create_reagents(10)	// !!!! TODO: Need Testing
		reagents.add_reagent(wet_reagent, wet_volume)
		reagents.expose(oldLoc, TOUCH, wet_volume) //Needed for proper floor wetting.

/mob/living/basic/snail/space/lube
	name = "космоулитка"
	desc = "Маленькая космо-улиточка со своим космо-домиком. Прочная, тихая и медленная. И очень склизкая."
	gold_core_spawnable = HOSTILE_SPAWN
	faction = list("slime", "hostile")
	wet_reagent = /datum/reagent/lube

/mob/living/basic/turtle
	death_sound = 'modular_bandastation/mobs/sound/crack_death1.ogg'
