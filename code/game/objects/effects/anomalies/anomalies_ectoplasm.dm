/obj/effect/anomaly/ectoplasm
	name = "ectoplasm anomaly"
	desc = "It looks like the souls of the damned are trying to break into the realm of the living again. How upsetting."
	icon_state = "ectoplasm"
	aSignal = /obj/item/assembly/signaler/anomaly/ectoplasm
	lifespan = 10 SECONDS //debug value pls change
	///Blocks the anomaly from updating ghost count. Used in case an admin wants to manually trigger the event.
	var/override_ghosts = FALSE
	///The numerical power of the anomaly. Calculated in anomalyEffect. Also used in determining the category of detonation effects.
	var/effect_power = 0
	///The actual number of ghosts orbiting the anomaly.
	var/ghosts_orbiting = 0

/obj/effect/anomaly/ectoplasm/Initialize(mapload, new_lifespan, drops_core)
	. = ..()

	AddComponent(/datum/component/deadchat_control/cardinal_movement, ANARCHY_MODE, list(), 2 SECONDS)

	if(. == COMPONENT_INCOMPATIBLE)
		return

/obj/effect/anomaly/ectoplasm/examine_more(mob/user)
	. = ..()

	if(isobserver(user))
		. += span_info("Orbiting this anomaly will increase its effect power. It will also accept directional commands!")

	switch(effect_power)
		if(0 to 25)
			. += span_notice("The space around the anomaly faintly resonates. It doesn't seem very powerful at the moment.")
		if(26 to 49)
			. += span_notice("The space around the anomaly seems to vibrate, letting out a noise that sounds like ghastly moaning. Someone should probably do something about that.")
		if(50 to 100)
			. += span_alert("The anomaly pulsates heavily, about to burst with unearthly energy. This can't be good.")

/obj/effect/anomaly/ectoplasm/anomalyEffect(delta_time) //Updates ghost count
	. = ..()
	if(!override_ghosts)
		ghosts_orbiting = 0
		for(var/mob/dead/observer/orbiter in orbiters?.orbiter_list)
			ghosts_orbiting++

		if(!ghosts_orbiting)
			effect_power = 0
			return

		var/total_dead = length(GLOB.dead_player_list + GLOB.current_observers_list)

		//The actual event severity is determined by what % the current ghosts are circling the anomaly.
		effect_power = ghosts_orbiting / total_dead * 100

		if(effect_power >= 50) //If we're at the threshold for the highest tier effect, we change sprites in preparation for the spooks.
			icon_state = "ectoplasm_heavy"
			update_appearance(UPDATE_ICON_STATE)
		else
			icon_state = "ectoplasm"
			update_appearance(UPDATE_ICON_STATE)

/obj/effect/anomaly/ectoplasm/detonate()
	. = ..()

	if(effect_power < 10) //Under 10% participation, we do nothing more than a small visual *poof*.
		new /obj/effect/temp_visual/revenant/cracks(get_turf(src))
		return

	if(effect_power >= 10) //Performs something akin to a revenant defile spell.
		var/effect_range = ghosts_orbiting + 5
		var/effect_area = spiral_range(effect_range, src)

		for(var/impacted_thing in effect_area)
			if(isfloorturf(impacted_thing))
				if(prob(5))
					new /obj/effect/decal/cleanable/blood(get_turf(impacted_thing))
				else if(prob(10))
					new /obj/effect/decal/cleanable/greenglow/ecto(get_turf(impacted_thing))
				else if(prob(10))
					new /obj/effect/decal/cleanable/dirt/dust(get_turf(impacted_thing))

				if(!isplatingturf(impacted_thing))
					var/turf/open/floor/floor_to_break = impacted_thing
					if(floor_to_break.overfloor_placed && floor_to_break.floor_tile && prob(20))
						new floor_to_break.floor_tile(floor_to_break)
						floor_to_break.make_plating(TRUE)
						floor_to_break.broken = TRUE
						floor_to_break.burnt = TRUE

			if(ishuman(impacted_thing))
				var/mob/living/carbon/human/mob_to_infect
				mob_to_infect.ForceContractDisease(new /datum/disease/revblight(), FALSE, TRUE)
				new /obj/effect/temp_visual/revenant(get_turf(mob_to_infect))
				to_chat(mob_to_infect, span_revenminor("A cacophony of ghostly wailing floods your ears for a moment. The noise subsides, but a distant whispering continues echoing inside of your head..."))

			if(istype(impacted_thing, /obj/structure/window))
				var/obj/structure/window/window_to_damage = impacted_thing
				window_to_damage.take_damage(rand(60, 90))
				if(window_to_damage?.fulltile)
					new /obj/effect/temp_visual/revenant/cracks(get_turf(window_to_damage))

	if(effect_power >= 35)
		var/effect_range = ghosts_orbiting + 3
		haunt_outburst(get_turf(src), effect_range, 45)

	if(effect_power >= 50) //Summon a ghost swarm!
		var/list/candidate_list = list()
		for(var/mob/dead/observer/orbiter in orbiters?.orbiter_list)
			candidate_list += orbiter

		new /obj/structure/ghost_portal(get_turf(src), candidate_list)

	priority_announce("Ectoplasmic outburst detected.", "Anomaly Alert")

/**
 * Takes a given area and chance, applying the haunted_item component to objects in the area.
 *
 * Takes an epicenter, and within the range around it, runs a haunt_chance percent chance of
 * applying the haunted_item component to nearby objects.
 *
 * * epicenter - The center of the outburst area.
 * * range - The range of the outburst, centered around the epicenter.
 * * haunt_chance - The percent chance that an object caught in the epicenter will be haunted.
 */

/proc/haunt_outburst(epicenter, range, haunt_chance)
	var/effect_area = range(range, epicenter)
	for(var/obj/item/object_to_possess in effect_area)
		if(!prob(haunt_chance))
			continue
		object_to_possess.AddComponent(/datum/component/haunted_item, \
			haunt_color = "#52336e", \
			haunt_duration = rand(1 MINUTES, 3 MINUTES), \
			aggro_radius = range, \
			spawn_message = span_revenwarning("[object_to_possess] slowly rises upward, hanging menacingly in the air..."), \
			despawn_message = span_revenwarning("[object_to_possess] settles to the floor, lifeless and unmoving."), \
		)

//TODO -- MOVE THE FOLLOWING PROCS TO A SPOOKY GHOST PORTAL STRUCTURE INSTEAD

/obj/structure/ghost_portal
	name = "Spooky Portal"
	desc = "A portal between our dimension and who-knows-where? It's emitting an absolutely ungodly wailing sound."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	anchored = TRUE
	density = TRUE
	var/static/list/spooky_noises = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')
	var/list/ghosts_spawned = list()

/obj/structure/ghost_portal/Initialize(mapload, candidate_list)
	. = ..()

	START_PROCESSING(SSobj, src)
	INVOKE_ASYNC(src, PROC_REF(make_ghost_swarm), candidate_list)
	playsound(src, pick(spooky_noises), 100, TRUE)
	QDEL_IN(src, 2 MINUTES)

/obj/structure/ghost_portal/process(delta_time)
	. = ..()

	if(prob(5))
		playsound(src, pick(spooky_noises), 100)

/obj/structure/ghost_portal/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, pick(spooky_noises), 50)

/obj/structure/ghost_portal/Destroy()
	. = ..()

	STOP_PROCESSING(SSobj, src)
	cleanup_ghosts()

/**
 * Generates a poll for observers, spawning anyone who signs up in a large group of ghost simplemobs
 *
 * Generates a poll that asks anyone observing for participation. Spawns a bunch of simplemob ghosts with the keys of candidates who have signed up.
 * Ghosts are deleted two minutes after being made, and exist to wreck anything in their immediate view.
 */

/obj/structure/ghost_portal/proc/make_ghost_swarm(list/candidate_list)
	var/list/candidates = poll_candidates("Would you like to participate in a spooky ghost swarm?", ROLE_SENTIENCE, FALSE, 10 SECONDS, group = candidate_list)
	for(var/candidate in candidates)
		if(!isobserver(candidate))
			continue
		var/mob/dead/observer/candidate_ghost = candidate //typecast so we can pull their key
		var/mob/living/basic/ghost/new_ghost = new /mob/living/basic/ghost(get_turf(src))
		new_ghost.ghostize(FALSE)
		new_ghost.key = candidate_ghost.key
		new_ghost.log_message("was returned to the living world as a ghost by an ectoplasmic anomaly.", LOG_GAME)
		var/policy = get_policy(ROLE_PYROCLASTIC_SLIME)
		if (policy)
			to_chat(new_ghost, policy)
		else
			to_chat(new_ghost, span_revenboldnotice("You are a lost soul, brought back to the realm of the living. Your time on this plane is limited, and you will soon be dragged back into the void!"))
		ghosts_spawned += new_ghost

/**
 * Gives a farewell message and deletes the ghosts the anomaly produced.
 *
 * Handles cleanup of all ghost mobs spawned by the anomaly. Iterates through the list
 * and calls qdel on its contents.
 */

/obj/structure/ghost_portal/proc/cleanup_ghosts()
	for(var/mob/living/mob_to_delete in ghosts_spawned)
		mob_to_delete.visible_message(span_alert("The [mob_to_delete] wails as it is torn back into the void!"), span_alert("You let out one last wail as you are sucked back into the realm of the dead. Then suddenly, you're back in the comforting embrace of the afterlife."), span_hear("You hear ethereal wailing."))
		playsound(src, pick(spooky_noises), 50)
		new /obj/effect/temp_visual/revenant/cracks(get_turf(src))
		qdel(mob_to_delete)
