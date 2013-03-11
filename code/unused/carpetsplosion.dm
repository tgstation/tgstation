/proc/carpetsplosion(turf/location as turf,range = 10)
	var/obj/effect/spreader/spreadEpicentre = new /obj/effect/spreader(location,range)
	var/list/turf/spreadTurfs = list()

	sleep(5)

	for(var/obj/effect/spreader/spread in spreadEpicentre.spreadList)
		spreadTurfs += get_turf(spread)

	del(spreadEpicentre)
	return

//DEBUG START
/obj/carpetnade
	New()
		..()
		carpetsplosion(loc)

//DEBUG END

/obj/effect/spreader
	var/list/obj/effect/spreader/spreadList = list()

/obj/effect/spreader/Del()
	for(var/obj/effect/spreader/spread in spreadList)
		if(spread != src)
			del(spread)
	..()

/obj/effect/spreader/New(location,var/amount = 1,obj/effects/spreader/source = src) //just a copypaste job from foam
	if(amount <= 0)
		del(src)
		return
	else
		..()

		for(var/direction in cardinal)
			var/turf/T = get_step(src,direction)
			if(!T)
				continue

			if(!T.Enter(src))
				continue

			var/obj/effect/spreader/S = locate() in T
			if(S)
				continue

			new /obj/effect/spreader(T,amount-1,source)

		source.spreadList += src

/*
/obj/effect/foam/proc/process()
	if(--amount < 0)
		return


	while(expand)	// keep trying to expand while true

		for(var/direction in cardinal)


			var/turf/T = get_step(src,direction)
			if(!T)
				continue

			if(!T.Enter(src))
				continue

			var/obj/effect/foam/F = locate() in T
			if(F)
				continue

			F = new(T, metal)
			F.amount = amount
			if(!metal)
				F.create_reagents(10)
				if (reagents)
					for(var/datum/reagent/R in reagents.reagent_list)
						F.reagents.add_reagent(R.id,1)
		sleep(15)
*/