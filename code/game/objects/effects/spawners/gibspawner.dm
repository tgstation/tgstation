/obj/effect/gibspawner
	icon_state = "gibspawner"// For the map editor
	var/virusProb = 20 //the chance for viruses to spread on the gibs
	var/gib_mob_type  //generate a fake mob to transfer DNA from if we weren't passed a mob.
	var/sound_to_play = 'sound/effects/blob/blobattack.ogg'
	var/sound_vol = 60
	var/list/gibtypes = list() // Assoc list of typepaths of the gib decals to spawn to amount to spawn
	var/list/gibdirections = list() // Lists of possible directions to spread each gib decal type towards.
	var/blood_dna_info // Cached blood_dna_info in case we do not have a source mob

/obj/effect/gibspawner/Initialize(mapload, mob/living/source_mob, list/datum/disease/diseases, blood_dna_info)
	. = ..()

	if(sound_to_play && isnum(sound_vol))
		playsound(src, sound_to_play, sound_vol, TRUE)

	var/list/dna_to_add //find the dna to pass to the spawned gibs. do note this can be null if the mob doesn't have blood. add_blood_DNA() has built in null handling.
	if(blood_dna_info)
		dna_to_add = blood_dna_info
	else if(source_mob)
		dna_to_add = source_mob.get_blood_dna_list() //ez pz
	else if(gib_mob_type)
		var/mob/living/temp_mob = new gib_mob_type(src) //generate a fake mob so that we pull the right type of DNA for the gibs.
		dna_to_add = temp_mob.get_blood_dna_list()
		qdel(temp_mob)
	else
		dna_to_add = list("Non-human DNA" = random_human_blood_type()) //else, generate a random bloodtype for it.


	for(var/i in 1 to gibtypes.len)
		var/gibType = gibtypes[i]
		var/amount = gibtypes[gibType]
		for(var/j in 1 to amount)
// These might streak off into space and cause annoying flaky failures with mapping nearstation tests
#ifndef UNIT_TESTS
			var/obj/effect/decal/cleanable/blood/gibs/gib = new gibType(loc, diseases, dna_to_add)
			var/list/directions = gibdirections[i]
			if(isturf(loc))
				if(directions.len)
					gib.streak(directions, mapload)
#else
			new gibType(loc, diseases, dna_to_add)
#endif

	return INITIALIZE_HINT_QDEL

/obj/effect/gibspawner/generic
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs = 2, /obj/effect/decal/cleanable/blood/gibs = 2, /obj/effect/decal/cleanable/blood/gibs/core = 1)
	sound_vol = 40

/obj/effect/gibspawner/generic/Initialize(mapload, mob/living/source_mob, list/datum/disease/diseases, blood_dna_info)
	if(!gibdirections.len)
		gibdirections = list(list(WEST, NORTHWEST, SOUTHWEST, NORTH), list(EAST, NORTHEAST, SOUTHEAST, SOUTH), list())
	return ..()

/obj/effect/gibspawner/generic/animal
	gib_mob_type = /mob/living/basic/pet

/obj/effect/gibspawner/human
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/up = 1, /obj/effect/decal/cleanable/blood/gibs/down = 1, /obj/effect/decal/cleanable/blood/gibs = 1, /obj/effect/decal/cleanable/blood/gibs = 1, /obj/effect/decal/cleanable/blood/gibs/body = 1, /obj/effect/decal/cleanable/blood/gibs/limb = 1, /obj/effect/decal/cleanable/blood/gibs/core = 1)
	gib_mob_type = /mob/living/carbon/human
	sound_vol = 50

/obj/effect/gibspawner/human/Initialize(mapload, mob/living/source_mob, list/datum/disease/diseases, blood_dna_info)
	if(!gibdirections.len)
		gibdirections = list(
			list(NORTH, NORTHEAST, NORTHWEST),
			list(SOUTH, SOUTHEAST, SOUTHWEST),
			list(WEST, NORTHWEST, SOUTHWEST),
			list(EAST, NORTHEAST, SOUTHEAST),
			GLOB.alldirs,
			GLOB.alldirs,
			list(),
		)

	if(!iscarbon(source_mob) && isnull(blood_dna_info))
		return ..(blood_dna_info = list("Human DNA" = random_human_blood_type()))

	return ..()

/obj/effect/gibspawner/human/bodypartless //only the gibs that don't look like actual full bodyparts (except torso).
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs = 1, /obj/effect/decal/cleanable/blood/gibs/core = 1, /obj/effect/decal/cleanable/blood/gibs = 1, /obj/effect/decal/cleanable/blood/gibs/core = 1, /obj/effect/decal/cleanable/blood/gibs = 1, /obj/effect/decal/cleanable/blood/gibs/torso = 1)

/obj/effect/gibspawner/human/bodypartless/Initialize(mapload, mob/living/source_mob, list/datum/disease/diseases, blood_dna_info)
	if(!gibdirections.len)
		gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST), list(SOUTH, SOUTHEAST, SOUTHWEST), list(WEST, NORTHWEST, SOUTHWEST), list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, list())
	return ..()

/obj/effect/gibspawner/xeno
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/xeno/up = 1, /obj/effect/decal/cleanable/blood/gibs/xeno/down = 1, /obj/effect/decal/cleanable/blood/gibs/xeno = 1, /obj/effect/decal/cleanable/blood/gibs/xeno = 1, /obj/effect/decal/cleanable/blood/gibs/xeno/body = 1, /obj/effect/decal/cleanable/blood/gibs/xeno/limb = 1, /obj/effect/decal/cleanable/blood/gibs/xeno/core = 1)
	gib_mob_type = /mob/living/carbon/alien

/obj/effect/gibspawner/xeno/Initialize(mapload, mob/living/source_mob, list/datum/disease/diseases, blood_dna_info)
	if(!gibdirections.len)
		gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST), list(SOUTH, SOUTHEAST, SOUTHWEST), list(WEST, NORTHWEST, SOUTHWEST), list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, GLOB.alldirs, list())
	return ..()

/obj/effect/gibspawner/xeno/bodypartless //only the gibs that don't look like actual full bodyparts (except torso).
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/xeno = 1, /obj/effect/decal/cleanable/blood/gibs/xeno/core = 1, /obj/effect/decal/cleanable/blood/gibs/xeno = 1, /obj/effect/decal/cleanable/blood/gibs/xeno/core = 1, /obj/effect/decal/cleanable/blood/gibs/xeno = 1, /obj/effect/decal/cleanable/blood/gibs/xeno/torso = 1)

/obj/effect/gibspawner/xeno/bodypartless/Initialize(mapload, mob/living/source_mob, list/datum/disease/diseases, blood_dna_info)
	if(!gibdirections.len)
		gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST), list(SOUTH, SOUTHEAST, SOUTHWEST), list(WEST, NORTHWEST, SOUTHWEST), list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, list())
	return ..()

/obj/effect/gibspawner/larva
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/xeno/larva = 1, /obj/effect/decal/cleanable/blood/gibs/xeno/larva = 1, /obj/effect/decal/cleanable/blood/gibs/xeno/larva/body = 1, /obj/effect/decal/cleanable/blood/gibs/xeno/larva/body = 1)
	gib_mob_type = /mob/living/carbon/alien/larva

/obj/effect/gibspawner/larva/Initialize(mapload, mob/living/source_mob, list/datum/disease/diseases, blood_dna_info)
	if(!gibdirections.len)
		gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST), list(SOUTH, SOUTHEAST, SOUTHWEST), list(), GLOB.alldirs)
	return ..()

/obj/effect/gibspawner/larva/bodypartless
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/xeno/larva = 1, /obj/effect/decal/cleanable/blood/gibs/xeno/larva = 1, /obj/effect/decal/cleanable/blood/gibs/xeno/larva = 1)

/obj/effect/gibspawner/larva/bodypartless/Initialize(mapload, mob/living/source_mob, list/datum/disease/diseases, blood_dna_info)
	if(!gibdirections.len)
		gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST), list(SOUTH, SOUTHEAST, SOUTHWEST), list())
	return ..()

/obj/effect/gibspawner/robot
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/robot_debris/up = 1, /obj/effect/decal/cleanable/blood/gibs/robot_debris/down = 1, /obj/effect/decal/cleanable/blood/gibs/robot_debris = 1, /obj/effect/decal/cleanable/blood/gibs/robot_debris = 1, /obj/effect/decal/cleanable/blood/gibs/robot_debris = 1, /obj/effect/decal/cleanable/blood/gibs/robot_debris/limb = 1)
	gib_mob_type = /mob/living/silicon

/obj/effect/gibspawner/robot/Initialize(mapload, mob/living/source_mob, list/datum/disease/diseases, blood_dna_info)
	if(!gibdirections.len)
		gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST), list(SOUTH, SOUTHEAST, SOUTHWEST), list(WEST, NORTHWEST, SOUTHWEST), list(EAST, NORTHEAST, SOUTHEAST), GLOB.alldirs, GLOB.alldirs)
	gibtypes[/obj/effect/decal/cleanable/blood/gibs/robot_debris/limb] = pick(0, 1, 2)
	. = ..()
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(2, 1, drop_location())
	sparks.start()
