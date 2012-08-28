/proc/gibs(atom/location, var/list/viruses, var/datum/dna/MobDNA)		//CARN MARKER
	new /obj/effect/gibspawner/generic(get_turf(location),viruses,MobDNA)

/proc/hgibs(atom/location, var/list/viruses, var/datum/dna/MobDNA)
	new /obj/effect/gibspawner/human(get_turf(location),viruses,MobDNA)

/proc/xgibs(atom/location, var/list/viruses)
	new /obj/effect/gibspawner/xeno(get_turf(location),viruses)

/proc/robogibs(atom/location, var/list/viruses)
	new /obj/effect/gibspawner/robot(get_turf(location),viruses)

/obj/effect/gibspawner
	var/sparks = 0 //whether sparks spread on Gib()
	var/virusProb = 20 //the chance for viruses to spread on the gibs
	var/list/gibtypes = list()
	var/list/gibamounts = list()
	var/list/gibdirections = list() //of lists

	New(location, var/list/viruses, var/datum/dna/MobDNA)
		..()

		if(istype(loc,/turf)) //basically if a badmin spawns it
			Gib(loc,viruses,MobDNA)

	proc/Gib(atom/location, var/list/viruses = list(), var/datum/dna/MobDNA = null)
		if(gibtypes.len != gibamounts.len || gibamounts.len != gibdirections.len)
			world << "\red Gib list length mismatch!"
			return

		var/obj/effect/decal/cleanable/blood/gibs/gib = null
		for(var/datum/disease/D in viruses)
			if(D.spread_type == SPECIAL)
				del(D)

		if(sparks)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 1, location)
			s.start()

		for(var/i = 1, i<= gibtypes.len, i++)
			if(gibamounts[i])
				for(var/j = 1, j<= gibamounts[i], j++)
					var/gibType = gibtypes[i]
					gib = new gibType(location)

					if(viruses.len > 0)
						for(var/datum/disease/D in viruses)
							if(prob(virusProb))
								var/datum/disease/viruus = new D.type
								gib.viruses += viruus
								viruus.holder = gib
								viruus.spread_type = CONTACT_FEET
					gib.blood_DNA = list()
					if(MobDNA)
						gib.blood_DNA[MobDNA.unique_enzymes] = MobDNA.b_type
					else if(istype(src, /obj/effect/gibspawner/xeno))
						gib.blood_DNA["UNKNOWN DNA"] = "X*"
					else if(istype(src, /obj/effect/gibspawner/human)) // Probably a monkey
						gib.blood_DNA["Non-human DNA"] = "A+"
					var/list/directions = gibdirections[i]
					if(directions.len)
						gib.streak(directions)

		del(src)