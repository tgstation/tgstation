/obj/item/grenade/gas_crystal
	desc = "Some kind of crystal, this shouldn't spawn"
	name = "Gas Crystal"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "bluefrag"
	inhand_icon_state = "flashbang"
	resistance_flags = FIRE_PROOF


/obj/item/grenade/gas_crystal/healium_crystal
	name = "Healium crystal"
	desc = "A crystal made from the Healium gas, it's cold to the touch."
	icon_state = "healium_crystal"
	///Amount of stamina damage mobs will take if in range
	var/stamina_damage = 30
	///Range of the grenade that will cool down and affect mobs
	var/freeze_range = 4

/obj/item/grenade/gas_crystal/proto_nitrate_crystal
	name = "Proto Nitrate crystal"
	desc = "A crystal made from the Proto Nitrate gas, you can see the liquid gases inside."
	icon_state = "proto_nitrate_crystal"
	///Range of the grenade air refilling
	var/refill_range = 5

/obj/item/grenade/gas_crystal/cyrion_b_crystal
	name = "Cyrion B crystal"
	desc = "A crystal made from the Cyrion B Gas, you can see the liquid plasma inside."
	icon_state = "cyrion_b_crystal"
	ex_dev = 1
	ex_heavy = 2
	ex_light = 4
	ex_flame = 2

/obj/item/grenade/gas_crystal/preprime(mob/user, delayoverride, msg = TRUE, volume = 60)
	var/turf/turf_loc = get_turf(src)
	log_grenade(user, turf_loc) //Inbuilt admin procs already handle null users
	if(user)
		add_fingerprint(user)
		if(msg)
			to_chat(user, "<span class='warning'>You crush the [src]! [capitalize(DisplayTimeText(det_time))]!</span>")
	if(shrapnel_type && shrapnel_radius)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type=shrapnel_type, magnitude=shrapnel_radius)
	active = TRUE
	icon_state = initial(icon_state) + "_active"
	playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', volume, TRUE)
	SEND_SIGNAL(src, COMSIG_GRENADE_ARMED, det_time, delayoverride)
	addtimer(CALLBACK(src, .proc/prime), isnull(delayoverride)? det_time : delayoverride)

/obj/item/grenade/gas_crystal/healium_crystal/prime(mob/living/lanced_by)
	. = ..()
	update_mob()
	playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
	for(var/turf/turf_loc in view(freeze_range, loc))
		if(!isopenturf(turf_loc))
			continue
		var/distance_from_center = get_dist(turf_loc, loc)
		var/turf/open/floor_loc = turf_loc
		switch(distance_from_center)
			if(0)
				if(floor_loc.air.temperature > 260 && floor_loc.air.temperature < 370)
					floor_loc.atmos_spawn_air("n2=100;TEMP=273")
				if(floor_loc.air.temperature > 370)
					floor_loc.atmos_spawn_air("n2=250;TEMP=30")
					floor_loc.MakeSlippery(TURF_WET_PERMAFROST, 5 MINUTES)
				if(floor_loc.air.gases[/datum/gas/plasma])
					floor_loc.air.gases[/datum/gas/plasma][MOLES] -= floor_loc.air.gases[/datum/gas/plasma][MOLES] * 0.5
			if(1)
				if(floor_loc.air.temperature > 260 && floor_loc.air.temperature < 370)
					floor_loc.atmos_spawn_air("n2=50;TEMP=273")
				if(floor_loc.air.temperature > 370)
					floor_loc.atmos_spawn_air("n2=150;TEMP=30")
					floor_loc.MakeSlippery(TURF_WET_PERMAFROST, 3 MINUTES)
				if(floor_loc.air.gases[/datum/gas/plasma])
					floor_loc.air.gases[/datum/gas/plasma][MOLES] -= floor_loc.air.gases[/datum/gas/plasma][MOLES] * 0.25
			if(2)
				if(floor_loc.air.temperature > 260 && floor_loc.air.temperature < 370)
					floor_loc.atmos_spawn_air("n2=25;TEMP=273")
				if(floor_loc.air.temperature > 370)
					floor_loc.atmos_spawn_air("n2=75;TEMP=30")
					floor_loc.MakeSlippery(TURF_WET_PERMAFROST, 1 MINUTES)
				if(floor_loc.air.gases[/datum/gas/plasma])
					floor_loc.air.gases[/datum/gas/plasma][MOLES] -= floor_loc.air.gases[/datum/gas/plasma][MOLES] * 0.15
			else
				if(floor_loc.air.temperature > 260 && floor_loc.air.temperature < 370)
					floor_loc.atmos_spawn_air("n2=15;TEMP=273")
				if(floor_loc.air.temperature > 370)
					floor_loc.atmos_spawn_air("n2=35;TEMP=30")
					floor_loc.MakeSlippery(TURF_WET_WATER, 1 MINUTES)
				if(floor_loc.air.gases[/datum/gas/plasma])
					floor_loc.air.gases[/datum/gas/plasma][MOLES] -= floor_loc.air.gases[/datum/gas/plasma][MOLES] * 0.05
		floor_loc.air_update_turf()
		for(var/mob/living/carbon/live_mob in turf_loc)
			live_mob.adjustStaminaLoss(stamina_damage)
			live_mob.adjust_bodytemperature(-150)
	qdel(src)

/obj/item/grenade/gas_crystal/proto_nitrate_crystal/prime(mob/living/lanced_by)
	. = ..()
	update_mob()
	playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
	for(var/turf/turf_loc in view(refill_range, loc))
		if(!isopenturf(turf_loc))
			continue
		var/distance_from_center = get_dist(turf_loc, loc)
		var/turf/open/floor_loc = turf_loc
		switch(distance_from_center)
			if(0)
				floor_loc.atmos_spawn_air("n2=400;TEMP=273")
				floor_loc.atmos_spawn_air("o2=100;TEMP=273")
			if(1)
				floor_loc.atmos_spawn_air("n2=250;TEMP=273")
				floor_loc.atmos_spawn_air("o2=65;TEMP=273")
			if(2)
				floor_loc.atmos_spawn_air("n2=125;TEMP=273")
				floor_loc.atmos_spawn_air("o2=35;TEMP=273")
			else
				floor_loc.atmos_spawn_air("n2=75;TEMP=273")
				floor_loc.atmos_spawn_air("o2=20;TEMP=273")
		floor_loc.air_update_turf()
	qdel(src)

/obj/item/grenade/gas_crystal/cyrion_b_crystal/prime(mob/living/lanced_by)
	. = ..()
	update_mob()
	qdel(src)
