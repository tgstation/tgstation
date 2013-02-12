
/datum/artifact_effect/teleport
	effecttype = "teleport"

/datum/artifact_effect/teleport/DoEffectTouch(var/mob/user)
	var/list/randomturfs = new/list()
	for(var/turf/simulated/floor/T in orange(user, 50))
		randomturfs.Add(T)
	if(randomturfs.len > 0)
		user << "\red You are suddenly zapped away elsewhere!"
		if (user.buckled)
			user.buckled.unbuckle()

		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 0, get_turf(user))
		sparks.start()
		user.loc = pick(randomturfs)
		sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 0, get_turf(user))
		sparks.start()

	return 1

/datum/artifact_effect/teleport/DoEffectAura()
	if(holder)
		for (var/mob/living/M in range(src.effectrange,holder))
			if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
				continue
			var/list/randomturfs = new/list()
			for(var/turf/simulated/floor/T in orange(M, 30))
				randomturfs.Add(T)
			if(randomturfs.len > 0)
				M << "\red You are displaced by a strange force!"
				if(M.buckled)
					M.buckled.unbuckle()

				var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
				sparks.set_up(3, 0, get_turf(M))
				sparks.start()
				M.loc = pick(randomturfs)
				sparks = new /datum/effect/effect/system/spark_spread()
				sparks.set_up(3, 0, get_turf(M))
				sparks.start()
	return 1

/datum/artifact_effect/teleport/DoEffectPulse()
	if(holder)
		for (var/mob/living/M in range(src.effectrange, holder))
			if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
				continue
			var/list/randomturfs = new/list()
			for(var/turf/simulated/floor/T in orange(M, 15))
				randomturfs.Add(T)
			if(randomturfs.len > 0)
				M << "\red You are displaced by a strange force!"

				var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
				sparks.set_up(3, 0, get_turf(M))
				sparks.start()
				if(M.buckled)
					M.buckled.unbuckle()
				M.loc = pick(randomturfs)
				sparks = new /datum/effect/effect/system/spark_spread()
				sparks.set_up(3, 0, get_turf(M))
				sparks.start()
	return 1
