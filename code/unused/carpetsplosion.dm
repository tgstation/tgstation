/proc/carpetsplosion(turf/location as turf,range = 10)
	var/obj/effects/spreader/spreadEpicentre = new /obj/effects/spreader(location,range)
	var/list/turf/spreadTurfs = list()

	sleep(5)

	for(var/obj/effects/spreader/spread in spreadEpicentre.spreadList)
		spreadTurfs += get_turf(spread)

	del(spreadEpicentre)
	return

//DEBUG START
/obj/carpetnade
	New()
		..()
		carpetsplosion(loc)

//DEBUG END

/obj/effects/spreader
	var/list/obj/effects/spreader/spreadList = list()

/obj/effects/spreader/Del()
	for(var/obj/effects/spreader/spread in spreadList)
		if(spread != src)
			del(spread)
	..()

/obj/effects/spreader/New(location,var/amount = 1,obj/effects/spreader/source = src) //just a copypaste job from foam
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

			var/obj/effects/spreader/S = locate() in T
			if(S)
				continue

			new /obj/effects/spreader(T,amount-1,source)

		source.spreadList += src

/*
/obj/effects/foam/proc/process()
	if(--amount < 0)
		return


	while(expand)	// keep trying to expand while true

		for(var/direction in cardinal)


			var/turf/T = get_step(src,direction)
			if(!T)
				continue

			if(!T.Enter(src))
				continue

			var/obj/effects/foam/F = locate() in T
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