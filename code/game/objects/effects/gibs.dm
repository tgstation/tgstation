/proc/gibs(atom/location, list/viruses, datum/dna/MobDNA)
	new /obj/effect/gibspawner/generic(location,viruses,MobDNA)

/proc/hgibs(atom/location, list/viruses, datum/dna/MobDNA)
	new /obj/effect/gibspawner/human(location,viruses,MobDNA)

/proc/xgibs(atom/location, list/viruses)
	new /obj/effect/gibspawner/xeno(location,viruses)

/proc/robogibs(atom/location, list/viruses)
	new /obj/effect/gibspawner/robot(location,viruses)

/obj/effect/gibspawner
	var/sparks = 0 //whether sparks spread on Gib()
	var/virusProb = 20 //the chance for viruses to spread on the gibs
	var/list/gibtypes = list()
	var/list/gibamounts = list()
	var/list/gibdirections = list() //of lists

/obj/effect/gibspawner/New(location, var/list/viruses, var/datum/dna/MobDNA)
	..()

	Gib(loc,viruses,MobDNA)

/obj/effect/gibspawner/proc/Gib(atom/location, list/viruses = list(), datum/dna/MobDNA = null)
	if(gibtypes.len != gibamounts.len || gibamounts.len != gibdirections.len)
		world << "<span class='danger'>Gib list length mismatch!</span>"
		return

	var/obj/effect/decal/cleanable/blood/gibs/gib = null

	if(sparks)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(2, 1, location)
		s.start()

	for(var/i = 1, i<= gibtypes.len, i++)
		if(gibamounts[i])
			for(var/j = 1, j<= gibamounts[i], j++)
				var/gibType = gibtypes[i]
				gib = new gibType(location)
				if(istype(location,/mob/living/carbon))
					var/mob/living/carbon/digester = location
					digester.stomach_contents += gib

				if(viruses.len > 0)
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
				if(istype(loc,/turf))
					if(directions.len)
						gib.streak(directions)

	qdel(src)
