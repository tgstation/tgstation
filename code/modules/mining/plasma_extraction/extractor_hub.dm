/**
 * Base plasma extraction machine
 */
/obj/structure/plasma_extraction_hub
	name = "plasma extraction hub"
	desc = "The hub to a connection of pipes. If there aren't any, then get building!"
	icon = 'icons/obj/machines/mining_machines.dmi' //icon state is set on main part's initialize
	base_icon_state = "extractor"
	anchored = TRUE
	density = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | INDESTRUCTIBLE

	///The number set during the part setup, used in deciding which icon state this part should be using.
	var/sprite_number

/obj/structure/plasma_extraction_hub/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[sprite_number]"

/**
 * Base plasma extraction machine part
 * All parts that don't have a pipe, use this.
 */
/obj/structure/plasma_extraction_hub/part
	///The main pipe that owns the whole 3x3 machine.
	var/obj/structure/plasma_extraction_hub/part/pipe/main/pipe_owner

/**
 * Plasma extraction machine pipe
 * There's 3 of these on each plasma extraction machine, one of which (the 'main' one) is the owner of the rest.
 */
/obj/structure/plasma_extraction_hub/part/pipe
	desc = "The start of a pipeline, use a pipe dispenser to construct one."
	///List of all pipes connected to this extraction part.
	var/list/obj/structure/liquid_plasma_extraction_pipe/connected_pipes = list()
	///Reference to the 'ending' pipe, the last one to be built. This has to exist for t he machien to work.
	var/obj/structure/liquid_plasma_ending/last_pipe
	///Boolean on whether the extraction hub is currently functioning.
	var/currently_functional = FALSE
	///Static list of mobs that are spawned by the spawner component. Taken from ore vents.
	var/static/list/defending_mobs = list(
		/mob/living/basic/mining/goliath,
		/mob/living/basic/mining/legion/spawner_made,
		/mob/living/basic/mining/watcher,
		/mob/living/basic/mining/lobstrosity/lava,
	)

/obj/structure/plasma_extraction_hub/part/pipe/Initialize(mapload)
	. = ..()
	register_context()
	AddComponent(/datum/component/pipe_laying, src)
	RegisterSignal(src, COMSIG_SPAWNER_SPAWNED, PROC_REF(log_mob_spawned))

/obj/structure/plasma_extraction_hub/part/pipe/Destroy()
	. = ..()
	if(last_pipe)
		QDEL_NULL(last_pipe)
	QDEL_LIST(connected_pipes)

/obj/structure/plasma_extraction_hub/part/pipe/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(istype(held_item, /obj/item/pipe_dispenser) && !length(connected_pipes))
		context[SCREENTIP_CONTEXT_LMB] = "Place pipes"
		return CONTEXTUAL_SCREENTIP_SET

/**
 * Called when a pipe connected to us is destroyed,
 * we'll give the pipe right before it the ability to lay pipes again (or src if there's no more pipes),
 * then destroy every single pipe made after it, and make sure they are out of our list, too.
 * If we're currently drilling, we'll stop all functions.
 */
/obj/structure/plasma_extraction_hub/part/pipe/proc/on_pipe_destroyed(obj/structure/liquid_plasma_extraction_pipe/broken_pipe)
	var/position_in_list = connected_pipes.Find(broken_pipe)
	if(position_in_list <= 1) //the first pipe won't have a previous pipe, so it goes back to us.
		AddComponent(/datum/component/pipe_laying, src)
	else
		var/obj/structure/liquid_plasma_extraction_pipe/previous_pipe = connected_pipes[position_in_list - 1]
		previous_pipe.AddComponent(/datum/component/pipe_laying, src)
	for(var/obj/structure/liquid_plasma_extraction_pipe/part_pipes as anything in connected_pipes)
		var/list_item_in_list = connected_pipes.Find(part_pipes)
		if(list_item_in_list > position_in_list)
			//we null them before destroying so they don't re-call this proc in their own destroys.
			part_pipes.connected_hub = null
			connected_pipes -= part_pipes
			qdel(part_pipes)
	if(last_pipe)
		QDEL_NULL(last_pipe)

	connected_pipes -= broken_pipe
	if(currently_functional)
		stop_drilling() //one of our pipes got destroyed, bitch!! god motherfuckin damn!

///Checks if the machine is able to start drilling, and starts if we can.
/obj/structure/plasma_extraction_hub/part/pipe/proc/start_drilling()
	if(!check_parts())
		return FALSE
	for(var/obj/structure/liquid_plasma_extraction_pipe/part_pipes as anything in connected_pipes)
		part_pipes.pipe_status = PIPE_STATUS_ON
		part_pipes.update_appearance(UPDATE_ICON)
	var/obj/structure/liquid_plasma_extraction_pipe/random_pipe = pick(connected_pipes)
	//one pipe on each side is spitting enemies, so we're putting randomness into spawn times.
	var/time_between_spawns = rand(15 SECONDS, 30 SECONDS)
	var/time_until_first_spawn = rand(10 SECONDS, 20 SECONDS)
	random_pipe.AddComponent(/datum/component/spawner, \
		spawn_types = defending_mobs, \
		spawn_time = time_between_spawns, \
		max_spawned = 2, \
		max_spawn_per_attempt = 1, \
		spawn_text = "emerges to assault", \
		spawn_distance = 4, \
		spawn_distance_exclude = 3, \
		initial_spawn_delay = time_until_first_spawn, \
		delete_on_conclusion = TRUE, \
	)
	currently_functional = TRUE

///Stops all drilling activities.
/obj/structure/plasma_extraction_hub/part/pipe/proc/stop_drilling()
	for(var/obj/structure/liquid_plasma_extraction_pipe/part_pipes as anything in connected_pipes)
		part_pipes.pipe_status = PIPE_STATUS_OFF
		part_pipes.update_appearance(UPDATE_ICON)
		SEND_SIGNAL(part_pipes, COMSIG_VENT_WAVE_CONCLUDED) //shuts off all spawners.
	currently_functional = FALSE

///Returns whether the pipe is able to drill. If it can't, and it currently is drilling,
///we'll call stop_drilling which shuts it all off and updates the pipes' icons/overlays.
/obj/structure/plasma_extraction_hub/part/pipe/proc/check_parts()
	if(!length(connected_pipes))
		return FALSE
	if(!last_pipe)
		return FALSE
	for(var/obj/structure/liquid_plasma_extraction_pipe/part_pipes as anything in connected_pipes)
		//if the pipe isn't perfectly built then it's not valid.
		if(part_pipes.pipe_state != PIPE_STATE_FINE)
			if(currently_functional)
				stop_drilling()
			return FALSE

	return TRUE

/**
 * Called when the machine has been completed, getting 100% plasma extraction.
 * This handles shutting off all spawners, as the machine will now infinitely run, we don't want constant
 * hoards of enemies coming from this.
 */
/obj/structure/plasma_extraction_hub/part/pipe/proc/on_completion()
	SHOULD_CALL_PARENT(TRUE)
	for(var/obj/structure/liquid_plasma_extraction_pipe/part_pipes as anything in connected_pipes)
		SEND_SIGNAL(part_pipes, COMSIG_VENT_WAVE_CONCLUDED) //shuts off all spawners.

/**
 * Handle logging for mobs spawned
 * Copied from ore vents so logs are consistent.
 */
/obj/structure/plasma_extraction_hub/part/pipe/proc/log_mob_spawned(datum/source, mob/living/created)
	SIGNAL_HANDLER
	log_game("Plasma extraction machine [key_name_and_tag(src)] spawned the following mob: [key_name_and_tag(created)]")
	SSblackbox.record_feedback("tally", "ore_vent_mobs_spawned", 1, created.type)
	RegisterSignal(created, COMSIG_LIVING_DEATH, PROC_REF(log_mob_killed))

/**
 * Handle logging for mobs killed
 * Copied from ore vents so logs are consistent.
 */
/obj/structure/plasma_extraction_hub/part/pipe/proc/log_mob_killed(datum/source, mob/living/killed)
	SIGNAL_HANDLER
	log_game("Plasma extraction machine mob [key_name_and_tag(killed)] was killed")
	SSblackbox.record_feedback("tally", "ore_vent_mobs_killed", 1, killed.type)
