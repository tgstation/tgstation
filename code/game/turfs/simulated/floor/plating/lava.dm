///LAVA

/turf/open/floor/plating/lava
	name = "lava"
	icon_state = "lava"
	gender = PLURAL //"That's some lava."
	baseturf = /turf/open/floor/plating/lava //lava all the way down
	slowdown = 2

	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA

/turf/open/floor/plating/lava/ex_act()
	return

/turf/open/floor/plating/lava/airless
	initial_gas_mix = "TEMP=2.7"

/turf/open/floor/plating/lava/Entered(atom/movable/AM)
	if(burn_stuff(AM))
		START_PROCESSING(SSobj, src)

/turf/open/floor/plating/lava/hitby(atom/movable/AM)
	if(burn_stuff(AM))
		START_PROCESSING(SSobj, src)

/turf/open/floor/plating/lava/process()
	if(!burn_stuff())
		STOP_PROCESSING(SSobj, src)

/turf/open/floor/plating/lava/singularity_act()
	return

/turf/open/floor/plating/lava/singularity_pull(S, current_size)
	return

/turf/open/floor/plating/lava/make_plating()
	return

/turf/open/floor/plating/lava/GetHeatCapacity()
	. = 700000

/turf/open/floor/plating/lava/GetTemperature()
	. = 5000

/turf/open/floor/plating/lava/TakeTemperature(temp)


/turf/open/floor/plating/lava/proc/is_safe()
	//if anything matching this typecache is found in the lava, we don't burn things
	var/static/list/lava_safeties_typecache = typecacheof(list(/obj/structure/lattice/catwalk))
	var/list/found_safeties = typecache_filter_list(contents, lava_safeties_typecache)
	return LAZYLEN(found_safeties)


/turf/open/floor/plating/lava/proc/burn_stuff(AM)
	. = 0

	if(is_safe())
		return FALSE

	var/thing_to_check = src
	if (AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(isobj(thing))
			var/obj/O = thing
			if((O.resistance_flags & (LAVA_PROOF|INDESTRUCTIBLE)) || O.throwing)
				continue
			. = 1
			if((O.resistance_flags & (ON_FIRE)))
				continue
			if(!(O.resistance_flags & FLAMMABLE))
				O.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
			if(O.resistance_flags & FIRE_PROOF)
				O.resistance_flags &= ~FIRE_PROOF
			if(O.armor["fire"] > 50) //obj with 100% fire armor still get slowly burned away.
				O.armor["fire"] = 50
			O.fire_act(10000, 1000)

		else if (isliving(thing))
			. = 1
			var/mob/living/L = thing
			if(L.movement_type & FLYING)
				continue	//YOU'RE FLYING OVER IT
			if("lava" in L.weather_immunities)
				continue
			if(L.buckled)
				if(isobj(L.buckled))
					var/obj/O = L.buckled
					if(O.resistance_flags & LAVA_PROOF)
						continue
				if(isliving(L.buckled)) //Goliath riding
					var/mob/living/live = L.buckled
					if("lava" in live.weather_immunities)
						continue

			L.adjustFireLoss(20)
			if(L) //mobs turning into object corpses could get deleted here.
				L.adjust_fire_stacks(20)
				L.IgniteMob()


/turf/open/floor/plating/lava/attackby(obj/item/C, mob/user, params) //Lava isn't a good foundation to build on
	return

/turf/open/floor/plating/lava/break_tile()
	return

/turf/open/floor/plating/lava/pry_tile()
	return

/turf/open/floor/plating/lava/try_replace_tile()
	return

/turf/open/floor/plating/lava/burn_tile()
	return

/turf/open/floor/plating/lava/smooth
	name = "lava"
	baseturf = /turf/open/floor/plating/lava/smooth
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "unsmooth"
	smooth = SMOOTH_MORE | SMOOTH_BORDER
	canSmoothWith = list(/turf/open/floor/plating/lava/smooth)


/turf/open/floor/plating/lava/smooth/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	planetary_atmos = TRUE
	baseturf = /turf/open/chasm/straight_down/lava_land_surface

/turf/open/floor/plating/lava/smooth/airless
	initial_gas_mix = "TEMP=2.7"
