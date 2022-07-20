// These are supposed to be discrete effects so we can tell at a glance what does each override
// of [/datum/sm_delam_strat/proc/delaminate] does.
// Please keep them discrete and give them proper, descriptive function names.
// Oh and all of them returns true if the effect succeeded.

/// Irradiates mobs around 20 tiles of the sm.
/// Just the mobs apparently.
/datum/sm_delam_strat/proc/effect_irradiate(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	for (var/mob/living/victim in range(20, sm))
		if(victim.z != sm_turf.z)
			continue
		SSradiation.irradiate(victim)
	return TRUE

/// Hallucinates and makes mobs in Z level sad.
/datum/sm_delam_strat/proc/effect_demoralize(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	for(var/mob/living/victim as anything in GLOB.alive_mob_list)
		if(!istype(victim) || victim.z != sm_turf.z)
			continue
		if(ishuman(victim))
			//Hilariously enough, running into a closet should make you get hit the hardest.
			var/mob/living/carbon/human/human = victim
			human.hallucination += max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(victim, src) + 1)) ) )

	for(var/mob/victim as anything in GLOB.player_list)
		var/turf/mob_turf = get_turf(victim)
		if(sm_turf.z != mob_turf.z)
			continue
		SEND_SOUND(victim, 'sound/magic/charge.ogg')
		if (victim.z != sm_turf.z)
			to_chat(victim, span_boldannounce("You hold onto \the [victim.loc] as hard as you can, as reality distorts around you. You feel safe."))
			continue
		to_chat(victim, span_boldannounce("You feel reality distort for a moment..."))
		SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "delam", /datum/mood_event/delam)
	return TRUE

/// Spawns anomalies all over the station. Half instantly, the other half over time.
/datum/sm_delam_strat/proc/effect_anomaly(obj/machinery/power/supermatter_crystal/sm)
	var/anomalies = 10
	var/list/anomaly_types = list(GRAVITATIONAL_ANOMALY = 55, HALLUCINATION_ANOMALY = 45, DELIMBER_ANOMALY = 35, FLUX_ANOMALY = 25, PYRO_ANOMALY = 5, VORTEX_ANOMALY = 1)
	var/list/anomaly_places = GLOB.generic_event_spawns

	// Spawns this many anomalies instantly. Spawns the rest with callbacks.
	var/cutoff_point = round(anomalies * 0.5, 1)

	for(var/i in 1 to anomalies)
		var/anomaly_to_spawn = pick_weight(anomaly_types)
		var/anomaly_location = pick_n_take(anomaly_places)
		
		if(i < cutoff_point)
			supermatter_anomaly_gen(anomaly_location, anomaly_to_spawn, has_changed_lifespan = FALSE)
			continue

		var/current_spawn = rand(5 SECONDS, 10 SECONDS)
		var/next_spawn = rand(5 SECONDS, 10 SECONDS)
		var/extended_spawn = 0
		if(DT_PROB(1, next_spawn))
			extended_spawn = rand(5 MINUTES, 15 MINUTES)
		addtimer(CALLBACK(src, /proc/supermatter_anomaly_gen, anomaly_location, anomaly_to_spawn, TRUE), current_spawn + extended_spawn)
	return TRUE

/// Explodes
/datum/sm_delam_strat/proc/effect_explosion(obj/machinery/power/supermatter_crystal/sm)
	var/explosion_power = sm.explosion_power
	var/power_scaling = sm.gasmix_power_ratio
	var/turf/sm_turf = get_turf(sm)
	//Dear mappers, balance the sm max explosion radius to 17.5, 37, 39, 41
	explosion(origin = sm_turf,
		devastation_range = explosion_power * max(power_scaling, 0.205) * 0.5,
		heavy_impact_range = explosion_power * max(power_scaling, 0.205) + 2,
		light_impact_range = explosion_power * max(power_scaling, 0.205) + 4,
		flash_range = explosion_power * max(power_scaling, 0.205) + 6,
		adminlog = TRUE,
		ignorecap = TRUE
	)
	return TRUE

/// Explodes
/datum/sm_delam_strat/proc/effect_singulo(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	if(!sm_turf)
		return FALSE
	var/obj/singularity/created_singularity = new(sm_turf)
	created_singularity.energy = 800
	created_singularity.consume(src)
	return TRUE

/// Teslas
/datum/sm_delam_strat/proc/effect_tesla(obj/machinery/power/supermatter_crystal/sm)
	var/turf/sm_turf = get_turf(sm)
	if(!sm_turf)
		return FALSE
	var/obj/energy_ball/created_tesla = new(sm_turf)
	created_tesla.energy = 200 //Gets us about 9 balls
	return TRUE
