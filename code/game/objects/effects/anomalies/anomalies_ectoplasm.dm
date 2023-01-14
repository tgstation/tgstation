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
		if(26 to 64)
			. += span_notice("The space around the anomaly seems to vibrate, letting out a noise that sounds like ghastly moaning. Someone should probably do something about that.")
		if(65 to 100)
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

		var/player_count = length(GLOB.player_list)
		var/total_dead = length(GLOB.dead_player_list + GLOB.current_observers_list)

		//The actual event severity is determined by what % the current ghosts are circling the anomaly.
		var/severity = ghosts_orbiting / total_dead * 100
		//Max severity is gated by what % of the player count are dead players, double for leniency's sake. Used to cap severity unless a certain amount of the server is dead.
		var/max_severity = total_dead / player_count * 200
		//This is done to prevent anomalies from being too powerful on lowpop, where 3 orbiters out of 6 would be enough for a catastrophic severity.

		effect_power = clamp(severity, 0, max_severity)

		if(effect_power >= 60)
			icon_state = "ectoplasm_heavy"
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
			if(!isplatingturf(impacted_thing) && isfloorturf(impacted_thing) && prob(20))
				var/turf/open/floor/floor_to_break = impacted_thing
				if(floor_to_break.overfloor_placed && floor_to_break.floor_tile)
					new floor_to_break.floor_tile(floor_to_break)
				floor_to_break.broken = TRUE
				floor_to_break.burnt = TRUE
				floor_to_break.make_plating(TRUE)

			if(ishuman(impacted_thing))
				var/mob/living/carbon/human/mob_to_infect
				mob_to_infect.ForceContractDisease(new /datum/disease/revblight(), FALSE, TRUE)
				new /obj/effect/temp_visual/revenant(get_turf(mob_to_infect))
				to_chat(mob_to_infect, span_revenminor("A cacophony of ghostly wailing floods your ears for a moment. The noise subsides, but a distant whispering continues to echo inside of your head..."))

			if(istype(impacted_thing, /obj/structure/window))
				var/obj/structure/window/window_to_damage = impacted_thing
				window_to_damage.take_damage(rand(60, 90))
				if(window_to_damage?.fulltile)
					new /obj/effect/temp_visual/revenant/cracks(get_turf(window_to_damage))

	if(effect_power >= 35)
		var/effect_range = ghosts_orbiting + 3
		haunt_outburst(get_turf(src), effect_range, 45)

	if(effect_power >= 60) //Summon a ghost swarm!
		var/list/candidate_list = list()
		for(var/mob/dead/observer/orbiter in orbiters?.orbiter_list)
			candidate_list += orbiter

		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(make_ghost_swarm), get_turf(src), candidate_list)

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


/**
 * Generates a poll for observers, spawning anyone who signs up in a large group of ghost simplemobs
 *
 * Generates a poll that asks anyone observing for participation. Spawns a bunch of simplemob ghosts with the keys of candidates who have signed up.
 * Ghosts are deleted two minutes after being made, and exist to wreck anything in their immediate view.
 */

/proc/make_ghost_swarm(turf/spawn_location, list/candidate_list)
	var/list/candidates = poll_candidates("Would you like to participate in a spooky ghost swarm?", ROLE_SENTIENCE, FALSE, 10 SECONDS, group = candidate_list)
	var/list/ghost_list = list()
	for(var/candidate in candidates)
		if(!isobserver(candidate))
			continue
		var/mob/dead/observer/candidate_ghost = candidate //typecast so we can pull their key
		var/mob/living/basic/ghost/new_ghost = new /mob/living/basic/ghost(spawn_location)
		new_ghost.ghostize(FALSE)
		new_ghost.key = candidate_ghost.key
		new_ghost.log_message("was returned to the living world as a ghost by an ectoplasmic anomaly.", LOG_GAME)
		to_chat(new_ghost, span_revenboldnotice("You are a vengeful spirit, brought back from beyond the grave. Your time on this plane is limited, and you have but one purpose: Smash everything you see!"))
		ghost_list += new_ghost
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(cleanup_ghosts), ghost_list), 2 MINUTES)

/**
 * Gives a farewell message and deletes the ghosts the anomaly produced.
 *
 * Handles cleanup of all ghost mobs spawned by the anomaly. Iterates through the list
 * and calls qdel on its contents.
 *
 * * ghost_list - a list of the mobs to be messaged and deleted.
 */

/proc/cleanup_ghosts(list/ghost_list)
	for(var/mob/living/mob_to_delete in ghost_list)
		mob_to_delete.visible_message(span_alert("The [mob_to_delete] wails as it is torn back into the void!"), span_alert("You let out one last wail as you are sucked back into the realm of the dead. Then suddenly, you're back in the comforting embrace of the afterlife."), span_hear("You hear ethereal wailing."))
		qdel(mob_to_delete)
