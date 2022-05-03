/datum/supermatter_delamination
	///Power amount of the SM at the moment of death
	var/supermatter_power = 0
	///Amount of total gases interacting with the SM
	var/supermatter_gas_amount = 0
	///Base number of anomalies to spawn (can go up or down with a random small amount)
	var/anomalies_to_spawn = 10
	///Can we spawn anomalies after dealing with the delamination type?
	var/should_spawn_anomalies = TRUE
	///Reference to the supermatter turf
	var/turf/supermatter_turf
	///Baseline strenght of the explosion caused by the SM
	var/supermatter_explosion_power = 0
	///Amount the gasmix will affect the explosion size
	var/supermatter_gasmix_power_ratio = 0

/datum/supermatter_delamination/New(supermatter_power, supermatter_gas_amount, turf/supermatter_turf, supermatter_explosion_power, supermatter_gasmix_power_ratio, can_spawn_anomalies)
	. = ..()

	src.supermatter_power = supermatter_power
	src.supermatter_gas_amount = supermatter_gas_amount
	src.supermatter_turf = supermatter_turf
	src.supermatter_explosion_power = supermatter_explosion_power
	src.supermatter_gasmix_power_ratio = supermatter_gasmix_power_ratio

	setup_mob_interaction()
	setup_delamination_type()

	if(!should_spawn_anomalies || !can_spawn_anomalies)
		qdel(src)
		return

	setup_anomalies()

/datum/supermatter_delamination/proc/setup_mob_interaction()
	for(var/mob/living/victim as anything in GLOB.alive_mob_list)
		if(!istype(victim) || victim.z != supermatter_turf.z)
			continue

		if(ishuman(victim))
			//Hilariously enough, running into a closet should make you get hit the hardest.
			var/mob/living/carbon/human/human = victim
			human.hallucination += max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(victim, src) + 1)) ) )

		if (get_dist(victim, src) <= DETONATION_RADIATION_RANGE)
			SSradiation.irradiate(victim)

	for(var/mob/victim as anything in GLOB.player_list)
		var/turf/mob_turf = get_turf(victim)
		if(supermatter_turf.z != mob_turf.z)
			continue

		SEND_SOUND(victim, 'sound/magic/charge.ogg')

		if (victim.z != supermatter_turf.z)
			to_chat(victim, span_boldannounce("You hold onto \the [victim.loc] as hard as you can, as reality distorts around you. You feel safe."))
			continue

		to_chat(victim, span_boldannounce("You feel reality distort for a moment..."))
		SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "delam", /datum/mood_event/delam)

/datum/supermatter_delamination/proc/setup_delamination_type()
	if(supermatter_gas_amount > MOLE_PENALTY_THRESHOLD)
		call_singulo()
		return
	if(supermatter_power > POWER_PENALTY_THRESHOLD)
		call_tesla()
		return

	call_explosion()

/datum/supermatter_delamination/proc/call_singulo()
	if(!supermatter_turf) //If something fucks up we blow anyhow. This fix is 4 years old and none ever said why it's here. help.
		call_explosion()
		return
	var/obj/singularity/created_singularity = new(supermatter_turf)
	created_singularity.energy = 800
	created_singularity.consume(src)
	should_spawn_anomalies = FALSE

/datum/supermatter_delamination/proc/call_tesla()
	if(supermatter_turf)
		var/obj/energy_ball/created_tesla = new(supermatter_turf)
		created_tesla.energy = 200 //Gets us about 9 balls
	call_explosion()
	should_spawn_anomalies = FALSE

/datum/supermatter_delamination/proc/call_explosion()
	//Dear mappers, balance the sm max explosion radius to 17.5, 37, 39, 41
	explosion(origin = supermatter_turf,
		devastation_range = supermatter_explosion_power * max(supermatter_gasmix_power_ratio, 0.205) * 0.5,
		heavy_impact_range = supermatter_explosion_power * max(supermatter_gasmix_power_ratio, 0.205) + 2,
		light_impact_range = supermatter_explosion_power * max(supermatter_gasmix_power_ratio, 0.205) + 4,
		flash_range = supermatter_explosion_power * max(supermatter_gasmix_power_ratio, 0.205) + 6,
		adminlog = TRUE,
		ignorecap = TRUE
	)

/datum/supermatter_delamination/proc/setup_anomalies()
	anomalies_to_spawn = max(round(0.005 * supermatter_power, 1) + rand(-2, 5), 1)
	spawn_anomalies()

/datum/supermatter_delamination/proc/spawn_anomalies()
	var/list/anomaly_types = list(FLUX_ANOMALY = 65, GRAVITATIONAL_ANOMALY = 55, HALLUCINATION_ANOMALY = 45, PYRO_ANOMALY = 5, VORTEX_ANOMALY = 1)
	var/list/anomaly_places = GLOB.generic_event_spawns
	var/currently_spawning_anomalies = round(anomalies_to_spawn * 0.5, 1)
	anomalies_to_spawn -= currently_spawning_anomalies
	for(var/i in 1 to currently_spawning_anomalies)
		var/anomaly_to_spawn = pick_weight(anomaly_types)
		var/anomaly_location = pick_n_take(anomaly_places)
		supermatter_anomaly_gen(anomaly_location, anomaly_to_spawn, has_changed_lifespan = FALSE)

	spawn_overtime()

/datum/supermatter_delamination/proc/spawn_overtime()

	var/list/anomaly_types = list(FLUX_ANOMALY = 65, GRAVITATIONAL_ANOMALY = 55, HALLUCINATION_ANOMALY = 45, PYRO_ANOMALY = 5, VORTEX_ANOMALY = 1)
	var/list/anomaly_places = GLOB.generic_event_spawns

	var/current_spawn = rand(5 SECONDS, 10 SECONDS)
	for(var/i in 1 to anomalies_to_spawn)
		var/anomaly_to_spawn = pick_weight(anomaly_types)
		var/anomaly_location = pick_n_take(anomaly_places)
		var/next_spawn = rand(5 SECONDS, 10 SECONDS)
		var/extended_spawn = 0
		if(DT_PROB(1, next_spawn))
			extended_spawn = rand(5 MINUTES, 15 MINUTES)
		addtimer(CALLBACK(src, .proc/spawn_anomaly, anomaly_location, anomaly_to_spawn), current_spawn + extended_spawn)
		current_spawn += next_spawn

/datum/supermatter_delamination/proc/spawn_anomaly(location, type)
	supermatter_anomaly_gen(location, type, has_changed_lifespan = FALSE)
