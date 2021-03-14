/// The gravitational singularity
/obj/singularity
	name = "gravitational singularity"
	desc = "A gravitational singularity."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"
	anchored = TRUE
	density = TRUE
	move_resist = INFINITY
	layer = MASSIVE_OBJ_LAYER
	plane = ABOVE_LIGHTING_PLANE
	light_range = 6
	appearance_flags = LONG_GLIDE

	/// The singularity component itself.
	/// A weak ref in case an admin removes the component to preserve the functionality.
	var/datum/weakref/singularity_component

	var/current_size = 1
	var/allowed_size = 1
	var/energy = 100 //How strong are we?
	var/dissipate = TRUE //Do we lose energy over time?
	/// How long should it take for us to dissipate in seconds?
	var/dissipate_delay = 20
	/// How much energy do we lose every dissipate_delay?
	var/dissipate_strength = 1
	/// How long its been (in seconds) since the last dissipation
	var/time_since_last_dissipiation = 0
	var/event_chance = 10 //Prob for event each tick
	var/move_self = TRUE
	var/consumed_supermatter = FALSE //If the singularity has eaten a supermatter shard and can go to stage six

	flags_1 = SUPERMATTER_IGNORES_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION

/obj/singularity/Initialize(mapload, starting_energy = 50)
	. = ..()

	energy = starting_energy

	START_PROCESSING(SSobj, src)
	AddElement(/datum/element/point_of_interest)
	GLOB.singularities |= src

	var/datum/component/singularity/new_component = AddComponent(
		/datum/component/singularity, \
		consume_callback = CALLBACK(src, .proc/consume), \
	)

	singularity_component = WEAKREF(new_component)

	expand(current_size)

	for (var/obj/machinery/power/singularity_beacon/singubeacon in GLOB.machines)
		if (singubeacon.active)
			new_component.target = singubeacon
			break

	if (!mapload)
		notify_ghosts("IT'S LOOSE", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, ghost_sound = 'sound/machines/warning-buzzer.ogg', header = "IT'S LOOSE", notify_volume = 75)

/obj/singularity/Destroy()
	STOP_PROCESSING(SSobj, src)
	GLOB.singularities.Remove(src)
	return ..()

/obj/singularity/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	var/mob/living/carbon/jedi = user
	jedi.visible_message(
		"<span class='danger'>[jedi]'s head begins to collapse in on itself!</span>",
		"<span class='userdanger'>Your head feels like it's collapsing in on itself! This was really not a good idea!</span>",
		"<span class='hear'>You hear something crack and explode in gore.</span>"
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
	addtimer(CALLBACK(GLOBAL_PROC, .proc/carbon_tk_part_two, jedi), 0.1 SECONDS)


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
	addtimer(CALLBACK(GLOBAL_PROC, .proc/carbon_tk_part_three, jedi), 0.1 SECONDS)


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
		if(1)
			if(current_size <= STAGE_TWO)
				investigate_log("has been destroyed by a heavy explosion.", INVESTIGATE_SINGULO)
				qdel(src)
				return
			else
				energy -= round(((energy+1)/2),1)
		if(2)
			energy -= round(((energy+1)/3),1)
		if(3)
			energy -= round(((energy+1)/4),1)

/obj/singularity/process(delta_time)
	if(current_size >= STAGE_TWO)
		if(prob(event_chance))//Chance for it to run a special event TODO:Come up with one or two more that fit
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
	var/temp_allowed_size = src.allowed_size

	if(force_size)
		temp_allowed_size = force_size

	if(temp_allowed_size >= STAGE_SIX && !consumed_supermatter)
		temp_allowed_size = STAGE_FIVE

	var/new_grav_pull
	var/new_consume_range

	switch(temp_allowed_size)
		if(STAGE_ONE)
			current_size = STAGE_ONE
			icon = 'icons/obj/singularity.dmi'
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
		investigate_log("<font color='red'>grew to size [current_size]</font>", INVESTIGATE_SINGULO)
		return TRUE
	else if(current_size < (--temp_allowed_size))
		expand(temp_allowed_size)
	else
		return FALSE


/obj/singularity/proc/check_energy()
	if(energy <= 0)
		investigate_log("collapsed.", INVESTIGATE_SINGULO)
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
	var/turf/T = src.loc
	for(var/i = 1 to steps)
		T = get_step(T,direction)
	if(!isturf(T))
		return FALSE
	turfs.Add(T)
	var/dir2 = 0
	var/dir3 = 0
	switch(direction)
		if(NORTH||SOUTH)
			dir2 = 4
			dir3 = 8
		if(EAST||WEST)
			dir2 = 1
			dir3 = 2
	var/turf/T2 = T
	for(var/j = 1 to steps-1)
		T2 = get_step(T2,dir2)
		if(!isturf(T2))
			return FALSE
		turfs.Add(T2)
	for(var/k = 1 to steps-1)
		T = get_step(T,dir3)
		if(!isturf(T))
			return FALSE
		turfs.Add(T)
	for(var/turf/T3 in turfs)
		if(isnull(T3))
			continue
		if(!can_move(T3))
			return FALSE
	return TRUE


/obj/singularity/proc/can_move(turf/T)
	if(!T)
		return FALSE
	if((locate(/obj/machinery/field/containment) in T)||(locate(/obj/machinery/shieldwall) in T))
		return FALSE
	else if(locate(/obj/machinery/field/generator) in T)
		var/obj/machinery/field/generator/G = locate(/obj/machinery/field/generator) in T
		if(G?.active)
			return FALSE
	else if(locate(/obj/machinery/power/shieldwallgen) in T)
		var/obj/machinery/power/shieldwallgen/S = locate(/obj/machinery/power/shieldwallgen) in T
		if(S?.active)
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
	for(var/mob/living/carbon/C in urange(20, src, 1))
		C.visible_message("<span class='warning'>[C]'s skin bursts into flame!</span>", \
						  "<span class='userdanger'>You feel an inner fire as your skin bursts into flames!</span>")
		C.adjust_fire_stacks(5)
		C.IgniteMob()
	return


/obj/singularity/proc/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(isbrain(M)) //Ignore brains
			continue

		if(M.stat == CONSCIOUS)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if(istype(H.glasses, /obj/item/clothing/glasses/meson))
					var/obj/item/clothing/glasses/meson/MS = H.glasses
					if(MS.vision_flags == SEE_TURFS)
						to_chat(H, "<span class='notice'>You look directly into the [src.name], good thing you had your protective eyewear on!</span>")
						return

		M.apply_effect(60, EFFECT_STUN)
		M.visible_message("<span class='danger'>[M] stares blankly at the [src.name]!</span>", \
						"<span class='userdanger'>You look directly into the [src.name] and feel weak.</span>")
	return


/obj/singularity/proc/emp_area()
	empulse(src, 8, 10)

/obj/singularity/singularity_act()
	var/gain = (energy/2)
	var/dist = max((current_size - 2),1)
	explosion(src.loc,(dist),(dist*2),(dist*4))
	qdel(src)
	return gain

/obj/singularity/deadchat_plays(mode = DEMOCRACY_MODE, cooldown = 12 SECONDS)
	. = AddComponent(/datum/component/deadchat_control/cardinal_movement, mode, list(), cooldown, CALLBACK(src, .proc/stop_deadchat_plays))

	if(. == COMPONENT_INCOMPATIBLE)
		return

	move_self = FALSE

/obj/singularity/proc/stop_deadchat_plays()
	move_self = TRUE

/obj/singularity/deadchat_controlled/Initialize(mapload, starting_energy)
	. = ..()
	deadchat_plays(mode = DEMOCRACY_MODE)

