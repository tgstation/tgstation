#define NEIGHBOR_REFRESH_TIME 100

/obj/effect/plantsegment/proc/get_cardinal_neighbors()
	var/list/cardinal_neighbors = list()
	for(var/check_dir in cardinal)
		var/turf/simulated/T = get_step(get_turf(src), check_dir)
		if(istype(T))
			cardinal_neighbors |= T
	return cardinal_neighbors

/obj/effect/plantsegment/proc/update_neighbors()
	// Update our list of valid neighboring turfs.
	neighbors = list()
	for(var/turf/simulated/floor in get_cardinal_neighbors())
		if(get_dist(epicenter, floor) > spread_distance)
			continue
		if(locate(/obj/effect/plantsegment) in floor.contents)
			continue
		if(floor.density)
			if(!isnull(seed.chems["pacid"]))
				spawn(rand(5,25)) floor.ex_act(3)
			continue
		if(!Adjacent(floor) || !floor.Enter(src))
			continue
		neighbors |= floor
	// Update all of our friends.
	var/turf/T = get_turf(src)
	for(var/obj/effect/plantsegment/neighbor in range(1,src))
		neighbor.neighbors -= T

/obj/effect/plantsegment/process()
	if(timestopped) return 0

	// Something is very wrong, kill ourselves.
	if(!seed)
		die_off()
		return 0

	// Handle life.
	var/turf/simulated/T = get_turf(src)
	if(T && istype(T))
		var/datum/gas_mixture/environment = T.return_air()
		if(environment)
			if(environment.return_pressure() > seed.highkpa_tolerance) //Kudzu can live at 0KPA, otherwise you could just vent the room to kill it.
				health -= rand(5,10)

			if(abs(environment.temperature - seed.ideal_heat) > seed.heat_tolerance)
				health -= rand(5,10)
				return

			// Kudzu does NOT need light, otherwise, you could just turn off the lights to kill it.

	if(health < max_health)
		health = min(max_health, health + rand(3,5))

	if(prob(80)) age++

	if(!harvest && prob(3) && age > mature_time + seed.production)
		harvest = 1

	update_icon()

	if(is_mature() && special_cooldown())
		if(locked_atoms && locked_atoms.len)
			var/mob/V = locked_atoms[1]
			if(istype(V, /mob/living/carbon/human))
				do_chem_inject(V)
				do_carnivorous_bite(V, seed.potency)
		else
			if(seed.carnivorous == 2)
				var/mob/living/victim = locate() in range(src,1)
				if(victim)
					grab_mob(victim)
			else
				if(prob(round(seed.potency/2)))
					var/mob/living/victim = locate() in get_turf(src)
					if(victim)
						grab_mob(victim)

	if(world.time >= last_tick+NEIGHBOR_REFRESH_TIME)
		last_tick = world.time
		update_neighbors()

	if(sampled)
		//Should be between 2-7 for given the default range of values for production time.
		var/chance = max(1, round(30/seed.production))
		if(prob(chance))
			sampled = 0

	if(is_mature() && neighbors.len && prob(spread_chance))
		//spread to 1-3 adjacent turfs depending on yield trait.
		var/max_spread = Clamp(round(seed.yield*3/14), 1, 3) // 3/14? Why?

		for(var/i in 1 to max_spread)
			if(prob(spread_chance))
				sleep(rand(3,5))
				if(gcDestroyed || !neighbors.len)
					break
				var/turf/target_turf = pick(neighbors)
				var/obj/effect/plantsegment/child = new(get_turf(src),seed,epicenter)
				// Update neighboring squares.
				for(var/obj/effect/plantsegment/neighbor in range(1,target_turf))
					neighbor.neighbors -= target_turf
				spawn(1) // This should do a little bit of animation.
					child.loc = target_turf
					child.update_icon()

	// We shouldn't have spawned if the controller doesn't exist.
	check_health()
	// Keep processing us until we've done all there is for us to do in life.
	if(neighbors.len || health != max_health || !harvest || locked_atoms.len)
		plant_controller.add_plant(src)

/obj/effect/plantsegment/proc/die_off()
	if(seed && harvest)
		if(harvest && prob(10)) seed.harvest(src)
	// This turf is clear now, let our buddies know.
	for(var/turf/simulated/check_turf in get_cardinal_neighbors())
		if(!istype(check_turf))
			continue
		for(var/obj/effect/plantsegment/neighbor in check_turf.contents)
			neighbor.neighbors |= check_turf
			plant_controller.add_plant(neighbor)
	spawn(1) if(src) qdel(src) //fuck linebreaks amirite

#undef NEIGHBOR_REFRESH_TIME
