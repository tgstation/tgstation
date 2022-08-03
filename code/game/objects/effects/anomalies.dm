//Anomalies, used for events. Note that these DO NOT work by themselves; their procs are called by the event datum.

/// Chance of taking a step per second
#define ANOMALY_MOVECHANCE 45

/obj/effect/anomaly
	name = "anomaly"
	desc = "A mysterious anomaly, seen commonly only in the region of space that the station orbits..."
	icon_state = "bhole3"
	density = FALSE
	anchored = TRUE
	light_range = 3

	var/obj/item/assembly/signaler/anomaly/aSignal = /obj/item/assembly/signaler/anomaly
	var/area/impact_area

	var/lifespan = 990
	var/death_time

	var/countdown_colour
	var/obj/effect/countdown/anomaly/countdown

	/// Do we drop a core when we're neutralized?
	var/drops_core = TRUE
	///Do we keep on living forever?
	var/immortal = FALSE

/obj/effect/anomaly/Initialize(mapload, new_lifespan, drops_core = TRUE)
	. = ..()

	SSpoints_of_interest.make_point_of_interest(src)

	START_PROCESSING(SSobj, src)
	impact_area = get_area(src)

	if (!impact_area)
		return INITIALIZE_HINT_QDEL

	src.drops_core = drops_core

	aSignal = new aSignal(src)
	aSignal.code = rand(1,100)
	aSignal.anomaly_type = type

	var/frequency = rand(MIN_FREE_FREQ, MAX_FREE_FREQ)
	if(ISMULTIPLE(frequency, 2))//signaller frequencies are always uneven!
		frequency++
	aSignal.set_frequency(frequency)

	if(new_lifespan)
		lifespan = new_lifespan
	death_time = world.time + lifespan
	countdown = new(src)
	if(countdown_colour)
		countdown.color = countdown_colour
	if(immortal)
		return
	countdown.start()

/obj/effect/anomaly/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, immortal))
		if(vval)
			countdown.stop()
		else
			countdown.start()

/obj/effect/anomaly/process(delta_time)
	anomalyEffect(delta_time)
	if(death_time < world.time && !immortal)
		if(loc)
			detonate()
		qdel(src)

/obj/effect/anomaly/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(countdown)
	if(aSignal)
		QDEL_NULL(aSignal)
	return ..()

/obj/effect/anomaly/proc/anomalyEffect(delta_time)
	if(DT_PROB(ANOMALY_MOVECHANCE, delta_time))
		step(src,pick(GLOB.alldirs))

/obj/effect/anomaly/proc/detonate()
	return

/obj/effect/anomaly/ex_act(severity, target)
	if(severity >= EXPLODE_DEVASTATE)
		qdel(src)

/obj/effect/anomaly/proc/anomalyNeutralize()
	new /obj/effect/particle_effect/fluid/smoke/bad(loc)

	if(drops_core)
		aSignal.forceMove(drop_location())
		aSignal = null
	// else, anomaly core gets deleted by qdel(src).

	qdel(src)


/obj/effect/anomaly/attackby(obj/item/weapon, mob/user, params)
	if(weapon.tool_behaviour == TOOL_ANALYZER)
		to_chat(user, span_notice("Analyzing... [src]'s unstable field is fluctuating along frequency [format_frequency(aSignal.frequency)], code [aSignal.code]."))
		return TRUE

	return ..()

///////////////////////

/atom/movable/warp_effect
	plane = GRAVITY_PULSE_PLANE
	appearance_flags = PIXEL_SCALE|LONG_GLIDE // no tile bound so you can see it around corners and so
	icon = 'icons/effects/light_overlays/light_352.dmi'
	icon_state = "light"
	pixel_x = -176
	pixel_y = -176

/obj/effect/anomaly/grav
	name = "gravitational anomaly"
	icon_state = "shield2"
	density = FALSE
	aSignal = /obj/item/assembly/signaler/anomaly/grav
	var/boing = 0
	///Warp effect holder for displacement filter to "pulse" the anomaly
	var/atom/movable/warp_effect/warp

/obj/effect/anomaly/grav/Initialize(mapload, new_lifespan, drops_core)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	warp = new(src)
	vis_contents += warp

/obj/effect/anomaly/grav/Destroy()
	vis_contents -= warp
	warp = null
	return ..()

/obj/effect/anomaly/grav/anomalyEffect(delta_time)
	..()
	boing = 1
	for(var/obj/O in orange(4, src))
		if(!O.anchored)
			step_towards(O,src)
	for(var/mob/living/M in range(0, src))
		gravShock(M)
	for(var/mob/living/M in orange(4, src))
		if(!M.mob_negates_gravity())
			step_towards(M,src)
	for(var/obj/O in range(0,src))
		if(!O.anchored)
			if(isturf(O.loc))
				var/turf/T = O.loc
				if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE && HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
					continue
			var/mob/living/target = locate() in view(4,src)
			if(target && !target.stat)
				O.throw_at(target, 5, 10)

	//anomaly quickly contracts then slowly expands it's ring
	animate(warp, time = delta_time*3, transform = matrix().Scale(0.5,0.5))
	animate(time = delta_time*7, transform = matrix())

/obj/effect/anomaly/grav/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	gravShock(AM)

/obj/effect/anomaly/grav/Bump(atom/A)
	gravShock(A)

/obj/effect/anomaly/grav/Bumped(atom/movable/AM)
	gravShock(AM)

/obj/effect/anomaly/grav/proc/gravShock(mob/living/A)
	if(boing && isliving(A) && !A.stat)
		A.Paralyze(40)
		var/atom/target = get_edge_target_turf(A, get_dir(src, get_step_away(A, src)))
		A.throw_at(target, 5, 1)
		boing = 0

/obj/effect/anomaly/grav/high
	var/datum/proximity_monitor/advanced/gravity/grav_field

/obj/effect/anomaly/grav/high/Initialize(mapload, new_lifespan)
	. = ..()
	INVOKE_ASYNC(src, .proc/setup_grav_field)

/obj/effect/anomaly/grav/high/proc/setup_grav_field()
	grav_field = new(src, 7, TRUE, rand(0, 3))

/obj/effect/anomaly/grav/high/detonate()
	for(var/obj/machinery/gravity_generator/main/the_generator in GLOB.machines)
		if(is_station_level(the_generator.z))
			the_generator.blackout()

/obj/effect/anomaly/grav/high/Destroy()
	QDEL_NULL(grav_field)
	. = ..()

/////////////////////

/obj/effect/anomaly/flux
	name = "flux wave anomaly"
	icon_state = "electricity2"
	density = TRUE
	aSignal = /obj/item/assembly/signaler/anomaly/flux
	var/canshock = FALSE
	var/shockdamage = 20
	var/explosive = FLUX_EXPLOSIVE

/obj/effect/anomaly/flux/Initialize(mapload, new_lifespan, drops_core = TRUE, explosive = FLUX_EXPLOSIVE)
	. = ..()
	src.explosive = explosive
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/anomaly/flux/anomalyEffect()
	..()
	canshock = TRUE
	for(var/mob/living/M in range(0, src))
		mobShock(M)

/obj/effect/anomaly/flux/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, alpha=src.alpha)

/obj/effect/anomaly/flux/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	mobShock(AM)

/obj/effect/anomaly/flux/Bump(atom/A)
	mobShock(A)

/obj/effect/anomaly/flux/Bumped(atom/movable/AM)
	mobShock(AM)

/obj/effect/anomaly/flux/proc/mobShock(mob/living/M)
	if(canshock && istype(M))
		canshock = FALSE
		M.electrocute_act(shockdamage, name, flags = SHOCK_NOGLOVES)

/obj/effect/anomaly/flux/detonate()
	switch(explosive)
		if(FLUX_EXPLOSIVE)
			explosion(src, devastation_range = 1, heavy_impact_range = 4, light_impact_range = 16, flash_range = 18) //Low devastation, but hits a lot of stuff.
		if(FLUX_LOW_EXPLOSIVE)
			explosion(src, heavy_impact_range = 1, light_impact_range = 4, flash_range = 6)
		if(FLUX_NO_EXPLOSION)
			new /obj/effect/particle_effect/sparks(loc)

/////////////////////

/obj/effect/anomaly/bluespace
	name = "bluespace anomaly"
	icon = 'icons/obj/guns/projectiles.dmi'
	icon_state = "bluespace"
	density = TRUE
	aSignal = /obj/item/assembly/signaler/anomaly/bluespace

/obj/effect/anomaly/bluespace/anomalyEffect()
	..()
	for(var/mob/living/M in range(1,src))
		do_teleport(M, locate(M.x, M.y, M.z), 4, channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/effect/anomaly/bluespace/Bumped(atom/movable/AM)
	if(isliving(AM))
		do_teleport(AM, locate(AM.x, AM.y, AM.z), 8, channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/effect/anomaly/bluespace/detonate()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(!T)
		return

	// Calculate new position (searches through beacons in world)
	var/obj/item/beacon/chosen
	var/list/possible = list()
	for(var/obj/item/beacon/W in GLOB.teleportbeacons)
		possible += W

	if(possible.len > 0)
		chosen = pick(possible)

	if(!chosen)
		return

	// Calculate previous position for transition
	var/turf/FROM = T // the turf of origin we're travelling FROM
	var/turf/TO = get_turf(chosen) // the turf of origin we're travelling TO

	playsound(TO, 'sound/effects/phasein.ogg', 100, TRUE)
	priority_announce("Massive bluespace translocation detected.", "Anomaly Alert")

	var/list/flashers = list()
	for(var/mob/living/carbon/C in viewers(TO, null))
		if(C.flash_act())
			flashers += C

	var/y_distance = TO.y - FROM.y
	var/x_distance = TO.x - FROM.x
	for (var/atom/movable/A in urange(12, FROM )) // iterate thru list of mobs in the area
		if(istype(A, /obj/item/beacon))
			continue // don't teleport beacons because that's just insanely stupid
		if(iscameramob(A))
			continue // Don't mess with AI eye, blob eye, xenobio or advanced cameras
		if(A.anchored)
			continue

		var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, TO.z) // calculate the new place
		if(!A.Move(newloc) && newloc) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
			A.forceMove(newloc)

		if(ismob(A) && !(A in flashers)) // don't flash if we're already doing an effect
			var/mob/give_sparkles = A
			if(give_sparkles.client)
				blue_effect(give_sparkles)

/obj/effect/anomaly/bluespace/proc/blue_effect(mob/make_sparkle)
	make_sparkle.overlay_fullscreen("bluespace_flash", /atom/movable/screen/fullscreen/bluespace_sparkle, 1)
	addtimer(CALLBACK(make_sparkle, /mob/.proc/clear_fullscreen, "bluespace_flash"), 2 SECONDS)

/////////////////////

/obj/effect/anomaly/pyro
	name = "pyroclastic anomaly"
	icon_state = "mustard"
	var/ticks = 0
	/// How many seconds between each gas release
	var/releasedelay = 10
	aSignal = /obj/item/assembly/signaler/anomaly/pyro

/obj/effect/anomaly/pyro/anomalyEffect(delta_time)
	..()
	ticks += delta_time
	if(ticks < releasedelay)
		return
	else
		ticks -= releasedelay
	var/turf/open/T = get_turf(src)
	if(istype(T))
		T.atmos_spawn_air("o2=5;plasma=5;TEMP=1000")

/obj/effect/anomaly/pyro/detonate()
	INVOKE_ASYNC(src, .proc/makepyroslime)

/obj/effect/anomaly/pyro/proc/makepyroslime()
	var/turf/open/T = get_turf(src)
	if(istype(T))
		T.atmos_spawn_air("o2=500;plasma=500;TEMP=1000") //Make it hot and burny for the new slime
	var/new_colour = pick("red", "orange")
	var/mob/living/simple_animal/slime/S = new(T, new_colour)
	S.rabid = TRUE
	S.amount_grown = SLIME_EVOLUTION_THRESHOLD
	S.Evolve()
	var/datum/action/innate/slime/reproduce/A = new
	A.Grant(S)

	var/list/mob/dead/observer/candidates = poll_candidates_for_mob("Do you want to play as a pyroclastic anomaly slime?", ROLE_SENTIENCE, null, 10 SECONDS, S, POLL_IGNORE_PYROSLIME)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/chosen = pick(candidates)
		S.key = chosen.key
		S.mind.special_role = ROLE_PYROCLASTIC_SLIME
		var/policy = get_policy(ROLE_PYROCLASTIC_SLIME)
		if (policy)
			to_chat(S, policy)
		log_game("[key_name(S.key)] was made into a slime by pyroclastic anomaly at [AREACOORD(T)].")

/////////////////////

/obj/effect/anomaly/bhole
	name = "vortex anomaly"
	icon_state = "bhole3"
	desc = "That's a nice station you have there. It'd be a shame if something happened to it."
	aSignal = /obj/item/assembly/signaler/anomaly/vortex

/obj/effect/anomaly/bhole/anomalyEffect()
	..()
	if(!isturf(loc)) //blackhole cannot be contained inside anything. Weird stuff might happen
		qdel(src)
		return

	grav(rand(0,3), rand(2,3), 50, 25)

	//Throwing stuff around!
	for(var/obj/O in range(2,src))
		if(O == src)
			return //DON'T DELETE YOURSELF GOD DAMN
		if(!O.anchored)
			var/mob/living/target = locate() in view(4,src)
			if(target && !target.stat)
				O.throw_at(target, 7, 5)
		else
			SSexplosions.med_mov_atom += O

/obj/effect/anomaly/bhole/proc/grav(r, ex_act_force, pull_chance, turf_removal_chance)
	for(var/t = -r, t < r, t++)
		affect_coord(x+t, y-r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x-t, y+r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x+r, y+t, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x-r, y-t, ex_act_force, pull_chance, turf_removal_chance)

/obj/effect/anomaly/bhole/proc/affect_coord(x, y, ex_act_force, pull_chance, turf_removal_chance)
	//Get turf at coordinate
	var/turf/T = locate(x, y, z)
	if(isnull(T))
		return

	//Pulling and/or ex_act-ing movable atoms in that turf
	if(prob(pull_chance))
		for(var/obj/O in T.contents)
			if(O.anchored)
				switch(ex_act_force)
					if(EXPLODE_DEVASTATE)
						SSexplosions.high_mov_atom += O
					if(EXPLODE_HEAVY)
						SSexplosions.med_mov_atom += O
					if(EXPLODE_LIGHT)
						SSexplosions.low_mov_atom += O
			else
				step_towards(O,src)
		for(var/mob/living/M in T.contents)
			step_towards(M,src)

	//Damaging the turf
	if( T && prob(turf_removal_chance) )
		switch(ex_act_force)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highturf += T
			if(EXPLODE_HEAVY)
				SSexplosions.medturf += T
			if(EXPLODE_LIGHT)
				SSexplosions.lowturf += T

/obj/effect/anomaly/bioscrambler
	name = "bioscrambler anomaly"
	icon_state = "bioscrambler_anomaly"
	aSignal = /obj/item/assembly/signaler/anomaly/bioscrambler
	immortal = TRUE
	/// Cooldown for every anomaly pulse
	COOLDOWN_DECLARE(pulse_cooldown)
	/// How many seconds between each anomaly pulses
	var/pulse_delay = 15 SECONDS
	/// Range of the anomaly pulse
	var/range = 5
	///Lists for zones and bodyparts to swap and randomize
	var/static/list/zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/static/list/chests
	var/static/list/heads
	var/static/list/l_arms
	var/static/list/r_arms
	var/static/list/l_legs
	var/static/list/r_legs

/obj/effect/anomaly/bioscrambler/Initialize(mapload, new_lifespan, drops_core)
	. = ..()
	if(!chests)
		chests = typesof(/obj/item/bodypart/chest)
	if(!heads)
		heads = typesof(/obj/item/bodypart/head)
	if(!l_arms)
		l_arms = typesof(/obj/item/bodypart/l_arm)
	if(!r_arms)
		r_arms = typesof(/obj/item/bodypart/r_arm)
	if(!l_legs)
		l_legs = typesof(/obj/item/bodypart/l_leg)
	if(!r_legs)
		r_legs = typesof(/obj/item/bodypart/r_leg)

/obj/effect/anomaly/bioscrambler/anomalyEffect(delta_time)
	. = ..()

	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return

	COOLDOWN_START(src, pulse_cooldown, pulse_delay)

	swap_parts(range)

/obj/effect/anomaly/bioscrambler/proc/swap_parts(swap_range)
	for(var/mob/living/carbon/nearby in range(swap_range, src))
		if(nearby.run_armor_check(attack_flag = BIO, absorb_text = "Your armor protects you from [src]!") >= 100)
			continue //We are protected
		var/picked_zone = pick(zones)
		var/obj/item/bodypart/picked_user_part = nearby.get_bodypart(picked_zone)
		var/obj/item/bodypart/picked_part
		switch(picked_zone)
			if(BODY_ZONE_HEAD)
				picked_part = pick(heads)
			if(BODY_ZONE_CHEST)
				picked_part = pick(chests)
			if(BODY_ZONE_L_ARM)
				picked_part = pick(l_arms)
			if(BODY_ZONE_R_ARM)
				picked_part = pick(r_arms)
			if(BODY_ZONE_L_LEG)
				picked_part = pick(l_legs)
			if(BODY_ZONE_R_LEG)
				picked_part = pick(r_legs)
		var/obj/item/bodypart/new_part = new picked_part()
		new_part.replace_limb(nearby, TRUE)
		if(picked_user_part)
			qdel(picked_user_part)
		nearby.update_body(TRUE)
		balloon_alert(nearby, "something has changed about you")

/obj/effect/anomaly/hallucination
	name = "hallucination anomaly"
	icon_state = "hallucination_anomaly"
	aSignal = /obj/item/assembly/signaler/anomaly/hallucination
	/// Time passed since the last effect, increased by delta_time of the SSobj
	var/ticks = 0
	/// How many seconds between each small hallucination pulses
	var/release_delay = 5

/obj/effect/anomaly/hallucination/anomalyEffect(delta_time)
	. = ..()
	ticks += delta_time
	if(ticks < release_delay)
		return
	ticks -= release_delay
	var/turf/open/our_turf = get_turf(src)
	if(istype(our_turf))
		hallucination_pulse(our_turf, 5)

/obj/effect/anomaly/hallucination/detonate()
	var/turf/open/our_turf = get_turf(src)
	if(istype(our_turf))
		hallucination_pulse(our_turf, 10)

/obj/effect/anomaly/hallucination/proc/hallucination_pulse(turf/open/location, range)
	for(var/mob/living/carbon/human/near in view(location, range))
		// If they are immune to hallucinations.
		if (HAS_TRAIT(near, TRAIT_MADNESS_IMMUNE) || (near.mind && HAS_TRAIT(near.mind, TRAIT_MADNESS_IMMUNE)))
			continue

		// Blind people don't get hallucinations.
		if (near.is_blind())
			continue

		// Everyone else gets hallucinations.
		var/dist = sqrt(1 / max(1, get_dist(near, location)))
		near.hallucination += 50 * dist
		near.hallucination = clamp(near.hallucination, 0, 150)
		var/list/messages = list(
			"You feel your conscious mind fall apart!",
			"Reality warps around you!",
			"Something's wispering around you!",
			"You are going insane!",
		)
		to_chat(near, span_warning(pick(messages)))

#undef ANOMALY_MOVECHANCE
