/// The gravitational singularity
/obj/singularity
	name = "gravitational singularity"
	desc = "A gravitational singularity."
	icon = 'icons/obj/engine/singularity.dmi'
	icon_state = "singularity_s1"
	anchored = TRUE
	density = TRUE
	move_resist = INFINITY
	plane = MASSIVE_OBJ_PLANE
	plane = ABOVE_LIGHTING_PLANE
	light_range = 6
	appearance_flags = LONG_GLIDE

	/// The singularity component itself.
	/// A weak ref in case an admin removes the component to preserve the functionality.
	var/datum/weakref/singularity_component

	///Current singularity size, from 1 to 6
	var/current_size = 1
	///Current allowed size for the singulo
	var/allowed_size = 1
	///How strong are we?
	var/energy = 100
	///Do we lose energy over time?
	var/dissipate = TRUE
	/// How long should it take for us to dissipate in seconds?
	var/dissipate_delay = 20
	/// How much energy do we lose every dissipate_delay?
	var/dissipate_strength = 1
	/// How long its been (in seconds) since the last dissipation
	var/time_since_last_dissipiation = 0
	///Prob for event each tick
	var/event_chance = 10
	///Can i move by myself?
	var/move_self = TRUE
	///If the singularity has eaten a supermatter shard and can go to stage six
	var/consumed_supermatter = FALSE
	/// How long it's been since the singulo last acted, in seconds
	var/time_since_act = 0

	flags_1 = SUPERMATTER_IGNORES_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION

/obj/singularity/Initialize(mapload, starting_energy = 50)
	. = ..()

	energy = starting_energy

	START_PROCESSING(SSsinguloprocess, src)
	SSpoints_of_interest.make_point_of_interest(src)

	var/datum/component/singularity/new_component = AddComponent(
		/datum/component/singularity, \
		consume_callback = CALLBACK(src, PROC_REF(consume)), \
	)

	singularity_component = WEAKREF(new_component)

	expand(current_size)

	for (var/obj/machinery/power/singularity_beacon/singu_beacon in GLOB.machines)
		if (singu_beacon.active)
			new_component.target = singu_beacon
			break

	if (!mapload)
		notify_ghosts(
			"IT'S LOOSE",
			source = src,
			action = NOTIFY_ORBIT,
			flashwindow = FALSE,
			ghost_sound = 'sound/machines/warning-buzzer.ogg',
			header = "IT'S LOOSE",
			notify_volume = 75
		)


/obj/singularity/Destroy()
	STOP_PROCESSING(SSsinguloprocess, src)
	return ..()

/obj/singularity/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	var/mob/living/carbon/jedi = user
	jedi.visible_message(
		span_danger("[jedi]'s head begins to collapse in on itself!"),
		span_userdanger("Your head feels like it's collapsing in on itself! This was really not a good idea!"),
		span_hear("You hear something crack and explode in gore.")
		)
	jedi.Stun(3 SECONDS)
	new /obj/effect/gibspawner/generic(get_turf(jedi), jedi)
	jedi.apply_damage(30, BRUTE, BODY_ZONE_HEAD)
	if(QDELETED(jedi))
		return // damage was too much
	if(jedi.stat == DEAD)
		jedi.ghostize()
		var/obj/item/bodypart/head/rip_u = jedi.get_bodypart(BODY_ZONE_HEAD)
		rip_u.dismember(BURN) //nice try jedi
		qdel(rip_u)
		return
	addtimer(CALLBACK(src, PROC_REF(carbon_tk_part_two), jedi), 0.1 SECONDS)

/obj/singularity/proc/carbon_tk_part_two(mob/living/carbon/jedi)
	if(QDELETED(jedi))
		return
	new /obj/effect/gibspawner/generic(get_turf(jedi), jedi)
	jedi.apply_damage(30, BRUTE, BODY_ZONE_HEAD)
	if(QDELETED(jedi))
		return // damage was too much
	if(jedi.stat == DEAD)
		jedi.ghostize()
		var/obj/item/bodypart/head/rip_u = jedi.get_bodypart(BODY_ZONE_HEAD)
		if(rip_u)
			rip_u.dismember(BURN)
			qdel(rip_u)
		return
	addtimer(CALLBACK(src, PROC_REF(carbon_tk_part_three), jedi), 0.1 SECONDS)

/obj/singularity/proc/carbon_tk_part_three(mob/living/carbon/jedi)
	if(QDELETED(jedi))
		return
	new /obj/effect/gibspawner/generic(get_turf(jedi), jedi)
	jedi.apply_damage(30, BRUTE, BODY_ZONE_HEAD)
	if(QDELETED(jedi))
		return // damage was too much
	jedi.ghostize()
	var/obj/item/bodypart/head/rip_u = jedi.get_bodypart(BODY_ZONE_HEAD)
	if(rip_u)
		rip_u.dismember(BURN)
		qdel(rip_u)

/obj/singularity/ex_act(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(current_size <= STAGE_TWO)
				investigate_log("has been destroyed by a heavy explosion.", INVESTIGATE_ENGINE)
				qdel(src)
				return

			energy -= round(((energy + 1) / 2), 1)
		if(EXPLODE_HEAVY)
			energy -= round(((energy + 1) / 3), 1)
		if(EXPLODE_LIGHT)
			energy -= round(((energy + 1) / 4), 1)

/obj/singularity/process(delta_time)
	time_since_act += delta_time
	if(time_since_act < 2)
		return
	time_since_act = 0
	if(current_size >= STAGE_TWO)
		if(prob(event_chance))
			event()
	dissipate(delta_time)
	check_energy()

/obj/singularity/proc/dissipate(delta_time)
	if (!dissipate)
		return

	time_since_last_dissipiation += delta_time

	// Uses a while in case of especially long delta times
	while (time_since_last_dissipiation >= dissipate_delay)
		energy -= dissipate_strength
		time_since_last_dissipiation -= dissipate_delay

/obj/singularity/proc/expand(force_size)
	var/temp_allowed_size = allowed_size

	if(force_size)
		temp_allowed_size = force_size

	if(temp_allowed_size >= STAGE_SIX && !consumed_supermatter)
		temp_allowed_size = STAGE_FIVE

	var/new_grav_pull
	var/new_consume_range

	switch(temp_allowed_size)
		if(STAGE_ONE)
			current_size = STAGE_ONE
			icon = 'icons/obj/engine/singularity.dmi'
			icon_state = "singularity_s1"
			pixel_x = 0
			pixel_y = 0
			new_grav_pull = 4
			new_consume_range = 0
			dissipate_delay = 10
			time_since_last_dissipiation = 0
			dissipate_strength = 1
		if(STAGE_TWO)
			if(check_cardinals_range(1, TRUE))
				current_size = STAGE_TWO
				icon = 'icons/effects/96x96.dmi'
				icon_state = "singularity_s3"
				pixel_x = -32
				pixel_y = -32
				new_grav_pull = 6
				new_consume_range = 1
				dissipate_delay = 5
				time_since_last_dissipiation = 0
				dissipate_strength = 5
		if(STAGE_THREE)
			if(check_cardinals_range(2, TRUE))
				current_size = STAGE_THREE
				icon = 'icons/effects/160x160.dmi'
				icon_state = "singularity_s5"
				pixel_x = -64
				pixel_y = -64
				new_grav_pull = 8
				new_consume_range = 2
				dissipate_delay = 4
				time_since_last_dissipiation = 0
				dissipate_strength = 20
		if(STAGE_FOUR)
			if(check_cardinals_range(3, TRUE))
				current_size = STAGE_FOUR
				icon = 'icons/effects/224x224.dmi'
				icon_state = "singularity_s7"
				pixel_x = -96
				pixel_y = -96
				new_grav_pull = 10
				new_consume_range = 3
				dissipate_delay = 10
				time_since_last_dissipiation = 0
				dissipate_strength = 10
		if(STAGE_FIVE)//this one also lacks a check for gens because it eats everything
			current_size = STAGE_FIVE
			icon = 'icons/effects/288x288.dmi'
			icon_state = "singularity_s9"
			pixel_x = -128
			pixel_y = -128
			new_grav_pull = 10
			new_consume_range = 4
			dissipate = FALSE //It cant go smaller due to e loss
		if(STAGE_SIX) //This only happens if a stage 5 singulo consumes a supermatter shard.
			current_size = STAGE_SIX
			icon = 'icons/effects/352x352.dmi'
			icon_state = "singularity_s11"
			pixel_x = -160
			pixel_y = -160
			new_grav_pull = 15
			new_consume_range = 5
			dissipate = FALSE

	var/datum/component/singularity/resolved_singularity = singularity_component.resolve()
	if (!isnull(resolved_singularity))
		resolved_singularity.consume_range = new_consume_range
		resolved_singularity.grav_pull = new_grav_pull
		resolved_singularity.disregard_failed_movements = current_size >= STAGE_FIVE
		resolved_singularity.roaming = move_self && current_size >= STAGE_TWO
		resolved_singularity.singularity_size = current_size

	if(current_size == allowed_size)
		investigate_log("grew to size [current_size].", INVESTIGATE_ENGINE)
		return TRUE
	else if(current_size < (--temp_allowed_size))
		expand(temp_allowed_size)
	else
		return FALSE

/obj/singularity/proc/check_energy()
	if(energy <= 0)
		investigate_log("collapsed.", INVESTIGATE_ENGINE)
		qdel(src)
		return FALSE
	switch(energy)//Some of these numbers might need to be changed up later -Mport
		if(1 to 199)
			allowed_size = STAGE_ONE
		if(200 to 499)
			allowed_size = STAGE_TWO
		if(500 to 999)
			allowed_size = STAGE_THREE
		if(1000 to 1999)
			allowed_size = STAGE_FOUR
		if(2000 to INFINITY)
			if(energy >= 3000 && consumed_supermatter)
				allowed_size = STAGE_SIX
			else
				allowed_size = STAGE_FIVE
	if(current_size != allowed_size)
		expand()
	return TRUE

/obj/singularity/proc/consume(atom/thing)
	var/gain = thing.singularity_act(current_size, src)
	energy += gain
	if(istype(thing, /obj/machinery/power/supermatter_crystal) && !consumed_supermatter)
		desc = "[initial(desc)] It glows fiercely with inner fire."
		name = "supermatter-charged [initial(name)]"
		consumed_supermatter = TRUE
		set_light(10)

/obj/singularity/proc/check_cardinals_range(steps, retry_with_move = FALSE)
	. = length(GLOB.cardinals) //Should be 4.
	for(var/i in GLOB.cardinals)
		. -= check_turfs_in(i, steps) //-1 for each working direction
	if(. && retry_with_move) //If there's still a positive value it means it didn't pass. Retry with move if applicable
		for(var/i in GLOB.cardinals)
			if(step(src, i)) //Move in each direction.
				if(check_cardinals_range(steps, FALSE)) //New location passes, return true.
					return TRUE
	return !.

/obj/singularity/proc/check_turfs_in(direction = 0, step = 0)
	if(!direction)
		return FALSE
	var/steps = 0
	if(!step)
		switch(current_size)
			if(STAGE_ONE)
				steps = 1
			if(STAGE_TWO)
				steps = 3//Yes this is right
			if(STAGE_THREE)
				steps = 3
			if(STAGE_FOUR)
				steps = 4
			if(STAGE_FIVE)
				steps = 5
	else
		steps = step
	var/list/turfs = list()
	var/turf/considered_turf = loc
	for(var/i in 1 to steps)
		considered_turf = get_step(considered_turf,direction)
	if(!isturf(considered_turf))
		return FALSE
	turfs.Add(considered_turf)
	var/dir2 = 0
	var/dir3 = 0
	switch(direction)
		if(NORTH, SOUTH)
			dir2 = 4
			dir3 = 8
		if(EAST, WEST)
			dir2 = 1
			dir3 = 2
	var/turf/other_turf = considered_turf
	for(var/j = 1 to steps-1)
		other_turf = get_step(other_turf,dir2)
		if(!isturf(other_turf))
			return FALSE
		turfs.Add(other_turf)
	for(var/k = 1 to steps-1)
		considered_turf = get_step(considered_turf,dir3)
		if(!isturf(considered_turf))
			return FALSE
		turfs.Add(considered_turf)
	for(var/turf/check_turf in turfs)
		if(isnull(check_turf))
			continue
		if(!can_move(check_turf))
			return FALSE
	return TRUE

/obj/singularity/proc/can_move(turf/considered_turf)
	if(!considered_turf)
		return FALSE
	if((locate(/obj/machinery/field/containment) in considered_turf) || (locate(/obj/machinery/shieldwall) in considered_turf))
		return FALSE
	else if(locate(/obj/machinery/field/generator) in considered_turf)
		var/obj/machinery/field/generator/check_generator = locate(/obj/machinery/field/generator) in considered_turf
		if(check_generator?.active)
			return FALSE
	else if(locate(/obj/machinery/power/shieldwallgen) in considered_turf)
		var/obj/machinery/power/shieldwallgen/check_shield = locate(/obj/machinery/power/shieldwallgen) in considered_turf
		if(check_shield?.active)
			return FALSE
	return TRUE

/obj/singularity/proc/event()
	var/numb = rand(1,4)
	switch(numb)
		if(1)//EMP
			emp_area()
		if(2)//Stun mobs who lack optic scanners
			mezzer()
		if(3,4) //Sets all nearby mobs on fire
			if(current_size < STAGE_SIX)
				return FALSE
			combust_mobs()
		else
			return FALSE
	return TRUE

/obj/singularity/proc/combust_mobs()
	for(var/mob/living/carbon/burned_mob in urange(20, src, 1))
		burned_mob.visible_message(
			span_warning("[burned_mob]'s skin bursts into flame!"),
			span_userdanger("You feel an inner fire as your skin bursts into flames!")
		)
		burned_mob.adjust_fire_stacks(5)
		burned_mob.ignite_mob()
	return

/obj/singularity/proc/mezzer()
	for(var/mob/living/carbon/stunned_mob in oviewers(8, src))
		if(stunned_mob.stat == DEAD || stunned_mob.is_blind())
			continue

		if(!ishuman(stunned_mob))
			apply_stun(stunned_mob)
			continue

		var/mob/living/carbon/human/stunned_human = stunned_mob
		if(istype(stunned_human.glasses, /obj/item/clothing/glasses/meson))
			var/obj/item/clothing/glasses/meson/check_meson = stunned_human.glasses
			if(check_meson.vision_flags & SEE_TURFS)
				to_chat(stunned_human, span_notice("You look directly into the [name], good thing you had your protective eyewear on!"))
				continue

		apply_stun(stunned_mob)

/obj/singularity/proc/apply_stun(mob/living/carbon/stunned_mob)
	stunned_mob.apply_effect(60, EFFECT_STUN)
	stunned_mob.visible_message(
		span_danger("[stunned_mob] stares blankly at the [name]!"),
		span_userdanger("You look directly into the [name] and feel weak.")
	)

/obj/singularity/proc/emp_area()
	empulse(src, 8, 10)

/obj/singularity/singularity_act()
	var/gain = (energy/2)
	var/dist = max((current_size - 2),1)
	investigate_log("has been destroyed by another singularity.", INVESTIGATE_ENGINE)
	explosion(
		src,
		devastation_range = dist,
		heavy_impact_range = dist * 2,
		light_impact_range = dist * 4
	)
	qdel(src)
	return gain

/obj/singularity/deadchat_plays(mode = DEMOCRACY_MODE, cooldown = 12 SECONDS)
	. = AddComponent(/datum/component/deadchat_control/cardinal_movement, mode, list(), cooldown, CALLBACK(src, PROC_REF(stop_deadchat_plays)))

	if(. == COMPONENT_INCOMPATIBLE)
		return

	move_self = FALSE

/obj/singularity/proc/stop_deadchat_plays()
	move_self = TRUE

/obj/singularity/deadchat_controlled/Initialize(mapload, starting_energy)
	. = ..()
	deadchat_plays(mode = DEMOCRACY_MODE)
