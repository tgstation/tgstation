
/obj/effect/gibspawner
	var/sparks = 0 //whether sparks spread
	var/virusProb = 20 //the chance for viruses to spread on the gibs
	var/list/gibtypes = list() //typepaths of the gib decals to spawn
	var/list/gibamounts = list() //amount to spawn for each gib decal type we'll spawn.
	var/list/gibdirections = list() //of lists of possible directions to spread each gib decal type towards.

/obj/effect/gibspawner/Initialize(mapload, list/viruses, datum/dna/MobDNA)
	..()

	if(gibtypes.len != gibamounts.len || gibamounts.len != gibdirections.len)
		to_chat(world, "<span class='danger'>Gib list length mismatch!</span>")
		return

	var/obj/effect/decal/cleanable/blood/gibs/gib = null

	if(sparks)
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(2, 1, loc)
		s.start()

	for(var/i = 1, i<= gibtypes.len, i++)
		if(gibamounts[i])
			for(var/j = 1, j<= gibamounts[i], j++)
				var/gibType = gibtypes[i]
				gib = new gibType(loc)
				if(istype(loc,/mob/living/carbon))
					var/mob/living/carbon/digester = loc
					digester.stomach_contents += gib

				if(viruses && viruses.len > 0)
					for(var/datum/disease/D in viruses)
						if(prob(virusProb))
							var/datum/disease/viruus = D.Copy(1)
							gib.viruses += viruus
							viruus.holder = gib

				if(MobDNA)
					gib.blood_DNA[MobDNA.unique_enzymes] = MobDNA.blood_type
				else if(istype(src, /obj/effect/gibspawner/generic)) // Probably a monkey
					gib.blood_DNA["Non-human DNA"] = "A+"
				var/list/directions = gibdirections[i]
				if(isturf(loc))
					if(directions.len)
						gib.streak(directions)

	qdel(src)



/obj/effect/gibspawner/generic
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/core)
	gibamounts = list(2,2,1)

/obj/effect/gibspawner/generic/Initialize()
	playsound(src, 'sound/effects/blobattack.ogg', 40, 1)
	gibdirections = list(list(WEST, NORTHWEST, SOUTHWEST, NORTH),list(EAST, NORTHEAST, SOUTHEAST, SOUTH), list())
	..()

/obj/effect/gibspawner/human
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/up,/obj/effect/decal/cleanable/blood/gibs/down,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/body,/obj/effect/decal/cleanable/blood/gibs/limb,/obj/effect/decal/cleanable/blood/gibs/core)
	gibamounts = list(1,1,1,1,1,1,1)

/obj/effect/gibspawner/human/Initialize()
	playsound(src, 'sound/effects/blobattack.ogg', 50, 1)
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), alldirs, alldirs, list())
	..()


/obj/effect/gibspawner/humanbodypartless //only the gibs that don't look like actual full bodyparts (except torso).
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs, /obj/effect/decal/cleanable/blood/gibs/core,/obj/effect/decal/cleanable/blood/gibs, /obj/effect/decal/cleanable/blood/gibs/core, /obj/effect/decal/cleanable/blood/gibs, /obj/effect/decal/cleanable/blood/gibs/torso)
	gibamounts = list(1, 1, 1, 1, 1, 1)

/obj/effect/gibspawner/humanbodypartless/Initialize()
	playsound(src, 'sound/effects/blobattack.ogg', 50, 1)
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), alldirs, list())
	..()


/obj/effect/gibspawner/xeno
	gibtypes = list(/obj/effect/decal/cleanable/xenoblood/xgibs/up,/obj/effect/decal/cleanable/xenoblood/xgibs/down,/obj/effect/decal/cleanable/xenoblood/xgibs, /obj/effect/decal/cleanable/xenoblood/xgibs, /obj/effect/decal/cleanable/xenoblood/xgibs/body, /obj/effect/decal/cleanable/xenoblood/xgibs/limb, /obj/effect/decal/cleanable/xenoblood/xgibs/core)
	gibamounts = list(1,1,1,1,1,1,1)

/obj/effect/gibspawner/xeno/Initialize()
	playsound(src, 'sound/effects/blobattack.ogg', 60, 1)
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), alldirs, alldirs, list())
	..()


/obj/effect/gibspawner/xenobodypartless //only the gibs that don't look like actual full bodyparts (except torso).
	gibtypes = list(/obj/effect/decal/cleanable/xenoblood/xgibs, /obj/effect/decal/cleanable/xenoblood/xgibs/core,/obj/effect/decal/cleanable/xenoblood/xgibs, /obj/effect/decal/cleanable/xenoblood/xgibs/core, /obj/effect/decal/cleanable/xenoblood/xgibs, /obj/effect/decal/cleanable/xenoblood/xgibs/torso)
	gibamounts = list(1, 1, 1, 1, 1, 1)


/obj/effect/gibspawner/xenobodypartless/Initialize()
	playsound(src, 'sound/effects/blobattack.ogg', 60, 1)
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), alldirs, list())
	..()

/obj/effect/gibspawner/larva
	gibtypes = list(/obj/effect/decal/cleanable/xenoblood/xgibs/larva, /obj/effect/decal/cleanable/xenoblood/xgibs/larva, /obj/effect/decal/cleanable/xenoblood/xgibs/larva/body, /obj/effect/decal/cleanable/xenoblood/xgibs/larva/body)
	gibamounts = list(1, 1, 1, 1)

/obj/effect/gibspawner/larva/Initialize()
	playsound(src, 'sound/effects/blobattack.ogg', 60, 1)
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST), list(), alldirs)
	..()

/obj/effect/gibspawner/larvabodypartless
	gibtypes = list(/obj/effect/decal/cleanable/xenoblood/xgibs/larva, /obj/effect/decal/cleanable/xenoblood/xgibs/larva, /obj/effect/decal/cleanable/xenoblood/xgibs/larva)
	gibamounts = list(1, 1, 1)

/obj/effect/gibspawner/larvabodypartless/Initialize()
	playsound(src, 'sound/effects/blobattack.ogg', 60, 1)
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST), list())
	..()

/obj/effect/gibspawner/robot
	sparks = 1
	gibtypes = list(/obj/effect/decal/cleanable/robot_debris/up,/obj/effect/decal/cleanable/robot_debris/down,/obj/effect/decal/cleanable/robot_debris,/obj/effect/decal/cleanable/robot_debris,/obj/effect/decal/cleanable/robot_debris,/obj/effect/decal/cleanable/robot_debris/limb)
	gibamounts = list(1,1,1,1,1,1)

/obj/effect/gibspawner/robot/Initialize()
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), alldirs, alldirs)
	gibamounts[6] = pick(0,1,2)
	..()
