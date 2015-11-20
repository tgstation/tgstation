//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_random_events()
	//Puke if toxloss is too high
	if(!stat)
		if(getToxLoss() >= 45 && nutrition > 20)
			vomit()

		//No hair for radroaches
		if(src.radiation >= 50)
			src.h_style = "Bald"
			src.f_style = "Shaved"
			src.update_hair()

	//0.1% chance of playing a scary sound to someone who's in complete darkness
	if(isturf(loc) && rand(1,1000) == 1)
		var/turf/T = get_turf(src)
		if(!T.get_lumcount())
			playsound_local(src,pick(scarySounds), 50, 1, -1)

//Separate proc so we can jump out of it when we've succeeded in spreading disease.
/mob/living/carbon/human/proc/findAirborneVirii()
	if(blood_virus_spreading_disabled)
		return 0
	for(var/obj/effect/decal/cleanable/blood/B in get_turf(src))
		if(istype(B.virus2,/list) && B.virus2.len)
			for(var/ID in B.virus2)
				var/datum/disease2/disease/V = B.virus2[ID]
				if(infect_virus2(src,V, notes="(Airborne from blood)"))
					return 1

	for(var/obj/effect/decal/cleanable/mucus/M in get_turf(src))
		if(istype(M.virus2,/list) && M.virus2.len)
			for (var/ID in M.virus2)
				var/datum/disease2/disease/V = M.virus2[ID]
				if (infect_virus2(src,V, notes="(Airborne from mucus)"))
					return 1
	return 0
