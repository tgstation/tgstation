//Acid rain is part of the natural weather cycle in the humid forests of LV, and cause acid damage to anyone unprotected.
/datum/weather/rain
	name = "rain"
	desc = "Heavy thunderstorms rain down below, drenching anyone caught in it."

	//target_trait = ZTRAIT_RAINSTORM

	telegraph_message = span_danger("Thunder rumbles far above. You hear droplets drumming against the canopy.")
	telegraph_overlay = "rain_med"
	telegraph_sound = 'sound/ambience/weather/rain/rain_start.ogg'
	telegraph_duration = 13.3 SECONDS // rain_start.ogg total time

	weather_message = span_userdanger("<i>Rain pours down around you!</i>")
	weather_overlay = "rain_high"

	end_message = span_bolddanger("The downpour gradually slows to a light shower.")
	end_overlay = "rain_low"
	end_sound = 'sound/ambience/weather/rain/rain_end.ogg'
	end_duration = 20.7 SECONDS // rain_end.ogg total time

	weather_duration_lower = 3 MINUTES
	weather_duration_upper = 5 MINUTES
	// the default rain color when weather is aesethic otherwise gets overriden by reagent color
	weather_color = "#516a91ff"

//	telegraph_sound = 'sound/ambience/weather/rain/rain_start.ogg'
//	weather_sound = 'sound/ambience/weather/rain/rain_mid.ogg'

	/// need to remove these since I'm using them for debugging
	//protect_indoors = TRUE
	area_type = /area/

	barometer_predictable = TRUE

	/// A weighted list of possible reagents that will rain down from the sky.
	/// Only one of these will be selected to be used as the reagent
	var/list/whitelist_weather_reagents
	/// A list of reagents that are forbidden from being selected when there is no
	/// whitelist and the reagents are randomized
	var/list/blacklist_weather_reagents
	/// The selected reagent that will be rained down
	var/datum/reagent/rain_reagent

	/// A list of weather bitflags to control weather settings
	var/weather_flags = NONE // MOBS|TURFS|THUNDER|

	var/list/weak_sounds = list()
	var/list/strong_sounds = list()

	var/sound_plays_entire_z_level = FALSE

/datum/weather/rain/New(z_levels)
	..()

	if(aesthetic)
		return

	var/reagent_id

	if(whitelist_weather_reagents)
		reagent_id = pick_weight_recursive(whitelist_weather_reagents)
	else // randomized
		reagent_id = get_random_reagent_id(blacklist_weather_reagents)

	rain_reagent = find_reagent_object_from_type(reagent_id)

	// water reagent color has an ugly transparent grey that looks nasty so it's skipped
	if(!istype(rain_reagent, /datum/reagent/water))
		weather_color = rain_reagent.color // other reagents get their colored applied

	//create_reagents(INFINITY, NO_REACT)
	//reagents.add_reagent(dispensedreagent, INFINITY)

/*
	var/datum/looping_sound/acidrain/sound_active_acidrain = new(list(), FALSE, TRUE)

/datum/weather/acid_rain/telegraph()
	. = ..()
	for(var/mob/impacted_mob AS in GLOB.player_list)
		if(!(impacted_mob?.client?.prefs?.toggles_sound & SOUND_WEATHER))
			continue
		var/turf/impacted_mob_turf = get_turf(impacted_mob)
		if(!impacted_mob_turf || !(impacted_mob.z in impacted_z_levels))
			continue
		sound_active_acidrain.output_atoms |= impacted_mob
		CHECK_TICK

/datum/weather/acid_rain/start()
	. = ..()
	sound_active_acidrain.start()

/datum/weather/acid_rain/end()
	. = ..()
	sound_active_acidrain.stop()
*/

/*
/datum/weather/rain/telegraph()
	. = ..()
	for(var/area/impacted_area as anything in impacted_areas)
		strong_sounds[impacted_area] = /datum/looping_sound/rain
		CHECK_TICK

	GLOB.rain_storm_sounds += strong_sounds

/datum/weather/rain/start()
	GLOB.rain_storm_sounds -= weak_sounds
	GLOB.rain_storm_sounds += strong_sounds
	return ..()

/datum/weather/rain/wind_down()
	GLOB.rain_storm_sounds -= strong_sounds
	GLOB.rain_storm_sounds += weak_sounds
	return ..()
*/

/datum/weather/rain/telegraph()
	. = ..()

	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.rain_storm_sounds[impacted_area] = /datum/looping_sound/rain
		CHECK_TICK

	//We modify this list instead of setting it to weak/stron sounds in order to preserve things that hold a reference to it
	//It's essentially a playlist for a bunch of components that chose what sound to loop based on the area a player is in
	//GLOB.rain_storm_sounds += weak_sounds


/datum/weather/rain/start()
	//GLOB.rain_storm_sounds -= weak_sounds
/*
	GLOB.rain_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.rain_storm_sounds[impacted_area] = /datum/looping_sound/rain
*/
	return ..()

/datum/weather/rain/wind_down()
	GLOB.rain_storm_sounds.Cut()
	//GLOB.rain_storm_sounds.Cut() //-= strong_sounds
	return ..()

/datum/weather/rain/weather_act(mob/living/living)
/*
	/var/chem = /datum/reagent/water

	/datum/blobstrain/reagent/attack_living(mob/living/L)
		var/mob_protection = L.getarmor(null, BIO) * 0.01
		reagent.expose_mob(L, VAPOR, BLOB_REAGENTATK_VOL, TRUE, mob_protection, overmind)




	/datum/reagent/water/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume)/

	var/datum/reagents/reagent_splash = new()
	reagent_splash.add_reagent(/datum/reagent/water, 30)

	var/obj/item/reagent_containers/RG = attacking_item
	RG.reagents.add_reagent(/datum/reagent/water, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
	to_chat(user, span_notice("You fill [RG] from [src]. Gross."))

	var/datum/reagents/dispensed_reagent = new /datum/reagents(reagents_amount)
	dispensed_reagent.my_atom = vent
	if (forced_reagent_type)
		dispensed_reagent.add_reagent(forced_reagent_type, reagents_amount)
	else if (prob(danger_chance))
		dispensed_reagent.add_reagent(get_overflowing_reagent(dangerous = TRUE), reagents_amount)
*/
	if(istype(rain_reagent, /datum/reagent/water))
		living.wash()

	//var/datum/reagent/water/water = new /datum/reagent/water()
	rain_reagent.expose_mob(living, TOUCH, 5)

/*
	if(src.has_water_reclaimer)
		reagents.add_reagent(reagent_id, reagent_capacity)

	if(!reagents)
		return
	rain_reagent.expose(get_turf(src))
	for(var/atom/thing as anything in get_turf(src))
		reagents.expose(thing)
*/
	var/rain_type = lowertext(rain_reagent.name)
	if(prob(5))
		var/wetmessage = pick( "You're drenched in [rain_type]!",
		"You're completely soaked by the [rain_type] rainfall!",
		"You become soaked by the heavy [rain_type] rainfall!",
		"[capitalize(rain_type)] drips off your uniform as the rain soaks your outfit!",
		"Rushing [rain_type] rolls off your face as the rain soaks you completely!",
		"Heavy [rain_type] raindrops hit your face as the rain thoroughly soaks your body!",
		"As you move through the heavy [rain_type] rain, your clothes become completely soaked!",
		)
		to_chat(living, span_warning(wetmessage))

/datum/weather/rain/water
	whitelist_weather_reagents = list(/datum/reagent/water)

/datum/weather/rain/blood
	whitelist_weather_reagents = list(/datum/reagent/blood)

/datum/weather/rain/plasma
	whitelist_weather_reagents = list(/datum/reagent/toxin/plasma)

/datum/weather/rain/acid
	name = "acid rain"
	desc = "The planet's thunderstorms are by nature acidic, and will incinerate anyone standing beneath them without protection."

	telegraph_duration = 40 SECONDS
	telegraph_message = span_warning("Thunder rumbles far above. You hear acidic droplets hissing against the canopy. Seek shelter!")
	telegraph_sound = 'sound/effects/siren.ogg'

	weather_message = span_userdanger("<i>Acidic rain pours down around you! Get inside!</i>")
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 2 MINUTES

	end_duration = 10 SECONDS
	end_message = span_bolddanger("The downpour gradually slows to a light shower. It should be safe outside now.")

	// these are weighted by acidpwr which causes more damage the higher it is
	whitelist_weather_reagents = list(
		/datum/reagent/toxin/acid/nitracid = 3,
		/datum/reagent/toxin/acid = 2,
		/datum/reagent/toxin/acid/fluacid = 1,
	)

/*
	//var/datum/looping_sound/acidrain/sound_active_acidrain = new(list(), FALSE, TRUE)

/datum/weather/rain/acid/start()
	. = ..()
	//sound_active_acidrain.start()

/datum/weather/rain/acid/end()
	. = ..()
	//sound_active_acidrain.stop()

/datum/weather/rain/acid/weather_act(mob/living/living)
	if(living.stat == DEAD)
		return

	if(prob(living.modify_by_armor(100, ACID)))
		living.adjustFireLoss(7)
		to_chat(living, span_danger("You feel the acid rain melting you away!"))
	if(living.fire_stacks > -20)
		living.fire_stacks = max(-20, living.fire_stacks - 1)
*/
