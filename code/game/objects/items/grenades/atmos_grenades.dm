/obj/item/grenade/gas_crystal
	desc = "Some kind of crystal, this shouldn't spawn"
	name = "Gas Crystal"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "bluefrag"
	inhand_icon_state = "flashbang"
	resistance_flags = FIRE_PROOF


/obj/item/grenade/gas_crystal/raynar_crystal
	name = "Raynar crystal"
	desc = "A crystal made from the Raynar gas, it's cold to the touch."
	icon_state = "raynar_crystal"
	var/stamina_damage = 30
	var/freeze_range = 4

/obj/item/grenade/gas_crystal/roinneil_crystal
	name = "Roinneil crystal"
	desc = "A crystal made from the Roinneil gas, you can see the liquid gases inside."
	icon_state = "roinneil_crystal"
	var/refill_range = 5

/obj/item/grenade/gas_crystal/cymar_crystal
	name = "Cymar crystal"
	desc = "A crystal made from the Cymar Gas, you can see the liquid plasma inside."
	icon_state = "cymar_crystal"
	ex_dev = 1
	ex_heavy = 2
	ex_light = 4
	ex_flame = 2

/obj/item/grenade/gas_crystal/preprime(mob/user, delayoverride, msg = TRUE, volume = 60)
	var/turf/T = get_turf(src)
	log_grenade(user, T) //Inbuilt admin procs already handle null users
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

/obj/item/grenade/gas_crystal/raynar_crystal/prime(mob/living/lanced_by)
	. = ..()
	update_mob()
	playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
	for(var/turf/T in view(freeze_range,loc))
		if(isopenturf(T))
			var/turf/open/F = T
			if(F.air.temperature > 260 && F.air.temperature < 370)
				F.atmos_spawn_air("Nitrogen = 100; TEMP = 273")
			if(F.air.temperature > 370)
				F.atmos_spawn_air("Nitrogen = 250; TEMP = 30")
				F.MakeSlippery(TURF_WET_PERMAFROST, 1 MINUTES)
			if(F.air.gases[/datum/gas/plasma])
				F.air.gases[/datum/gas/plasma][MOLES] -= F.air.gases[/datum/gas/plasma][MOLES] * 0.5
			F.air.gases[/datum/gas/nitrogen][MOLES] += 50
			F.air_update_turf()
			for(var/mob/living/carbon/L in T)
				L.adjustStaminaLoss(stamina_damage)
				L.adjust_bodytemperature(-150)
	qdel(src)

/obj/item/grenade/gas_crystal/roinneil_crystal/prime(mob/living/lanced_by)
	. = ..()
	update_mob()
	playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
	for(var/turf/T in view(refill_range,loc))
		if(isopenturf(T))
			var/turf/open/F = T
			F.air.gases[/datum/gas/nitrogen][MOLES] += 400
			F.air.gases[/datum/gas/oxygen][MOLES] += 100
			F.air_update_turf()
	qdel(src)

/obj/item/grenade/gas_crystal/cymar_crystal/prime(mob/living/lanced_by)
	. = ..()
	update_mob()
	qdel(src)
