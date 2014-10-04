obj/effect/decal/cleanable/liquid_fuel
	//Liquid fuel is used for things that used to rely on volatile fuels or plasma being contained to a couple tiles.
	icon = 'icons/effects/effects.dmi'
	icon_state = "fuel"
	layer = TURF_LAYER+0.2
	anchored = 1
	var/amount = 1 //Basically moles.

	New(newLoc,amt=1)
		src.amount = amt

		//Be absorbed by any other liquid fuel in the tile.
		for(var/obj/effect/decal/cleanable/liquid_fuel/other in newLoc)
			if(other != src)
				other.amount += src.amount
				spawn other.Spread()
				del src

		Spread()
		. = ..()

	proc/Spread()
		//Allows liquid fuels to sometimes flow into other tiles.
		if(amount < 0.5) return
		var/turf/simulated/S = loc
		if(!istype(S)) return
		for(var/d in cardinal)
			if(rand(25))
				var/turf/simulated/target = get_step(src,d)
				var/turf/simulated/origin = get_turf(src)
				if(origin.CanPass(null, target, 0, 0) && target.CanPass(null, origin, 0, 0))
					if(!locate(/obj/effect/decal/cleanable/liquid_fuel) in target)
						new/obj/effect/decal/cleanable/liquid_fuel(target, amount*0.25)
						amount *= 0.75

	flamethrower_fuel
		icon_state = "mustard"
		anchored = 0
		New(newLoc, amt = 1, d = 0)
			dir = d //Setting this direction means you won't get torched by your own flamethrower.
			. = ..()

		Spread()
			//The spread for flamethrower fuel is much more precise, to create a wide fire pattern.
			if(amount < 0.1) return
			var/turf/simulated/S = loc
			if(!istype(S)) return

			for(var/d in list(turn(dir,90),turn(dir,-90), dir))
				var/turf/simulated/O = get_step(S,d)
				if(locate(/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel) in O)
					continue
				if(O.CanPass(null, S, 0, 0) && S.CanPass(null, O, 0, 0))
					new/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel(O,amount*0.25,d)
					O.hotspot_expose((T20C*2) + 380,500) //Light flamethrower fuel on fire immediately.

			amount *= 0.25
