
#define CRACK_PROPAGATION_DELAY 0.1 SECONDS
#define CRACK_TURN_CHANCE 50
#define CRACK_DELAY_CHANCE 33

/obj/effect/weakpoint
	name = "weakpoint crack"
	desc = "A suspicious crack runs along the ground."
	icon = 'icons/effects/effects.dmi'
	icon_state = "weakpoint"
	base_icon_state = "weakpoint"
	layer = ABOVE_NORMAL_TURF_LAYER
	move_resist = INFINITY
	alpha = 0

	/// The required strength of explosion for a weakpoint to propogate
	var/required_strength = EXPLODE_LIGHT
	//How many turfs should this weakpoint crack when triggered? Crack length splits by default and doesn't recurse
	var/crack_length = 8
	/// How many split off cracks are expected?
	var/crack_split_count = 2

	/// When the crack is finished expanding, will it spawn more cracks?
	var/spawns_children = TRUE
	/// How many children weakpoints will this crack spawn when it propagates?
	var/new_weakpoints = 2
	/// These turfs are things we don't want to spawn new cracks onto.
	var/static/list/skip_turfs = typecacheof(list(
		/turf/open/space,
		/turf/open/misc/asteroid,
		/turf/open/misc/snow,
	))

/obj/effect/weakpoint/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, INVISIBILITY_OBSERVER, use_anchor = TRUE)
	RegisterSignal(src, COMSIG_TURF_CHANGE, PROC_REF(turf_changed))
	register_context()
	animate(src, alpha = 255, time = 0.3 SECONDS)

/obj/effect/weakpoint/ex_act(severity, target)
	. = ..()
	if(severity < required_strength)
		balloon_alert_to_hearers("*crack*")
		playsound(source = src, soundin = SFX_HULL_CREAKING, vol = 50, vary = TRUE, pressure_affected = FALSE, ignore_walls = TRUE)
		return //return ominous sounds when we're under the threshold.

	var/list/chain_turfs = get_crack_chain(get_turf(src), 8, TRUE, skip_turfs) // Get a nice chain of turfs
	for(var/atom/along_length in chain_turfs)
		for(var/extra_turfs in get_adjacent_turfs(chain_turfs[along_length])) //use get_adjacent turfs to help add extra turfs.
			if(chain_turfs[extra_turfs])
				continue
			chain_turfs += extra_turfs

	var/crack_delay = 0
	for(var/turf/crack_turf in chain_turfs)
		addtimer(CALLBACK(crack_turf, TYPE_PROC_REF(/atom, ex_act), severity, crack_turf), CRACK_PROPAGATION_DELAY * crack_delay)
		playsound(source = crack_turf, soundin = SFX_HULL_CREAKING, vol = 35, vary = TRUE, pressure_affected = FALSE, ignore_walls = TRUE)
		if(prob(33))
			crack_delay++

	if(spawns_children)
		addtimer(CALLBACK(src, PROC_REF(create_new_cracks), chain_turfs, new_weakpoints), CRACK_PROPAGATION_DELAY * length(chain_turfs))
	qdel(src)

/obj/effect/weakpoint/welder_act(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("You begin to strengthen [src]..."))
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 1, volume=50))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("\The [src] is fully sealed, eliminating the risk of the weakpoint growing."))
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/effect/weakpoint/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stack/medical/wrap/sticky_tape))
		var/obj/item/stack/medical/wrap/sticky_tape/duct_tape = tool
		if(!duct_tape.use(1))
			return ITEM_INTERACT_BLOCKING
		to_chat(user, span_notice("\The [src] is sealed with a little elbow grease and a mound of [duct_tape]."))
		qdel(src)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/effect/weakpoint/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item?.tool_behaviour == TOOL_WELDER)
		context[SCREENTIP_CONTEXT_LMB] = "Repair weakpoint"
		return CONTEXTUAL_SCREENTIP_SET
	return .

/obj/effect/weakpoint/examine(mob/user)
	. = ..()
	. += span_notice("\The [src] could be repaired with a welder.")
	. += span_warning("A strong enough explosion will cause [src] to expand.")

/**
 * Generates a list of turfs from the start location meandering along a randomized set of turns.
 * * start_location: The turf to begin the chain of turfs from.
 * * length: How many lengths this chain needs to be.
 * * add_splits: Should this crack chain apply additional instances of get_crack_chain while recursively cracking even further.
 * * turfs_to_skip: a typecache of turfs that we block spreading to when getting a chain.
 */
/obj/effect/weakpoint/proc/get_crack_chain(start_location, length, add_splits = TRUE, turfs_to_skip = list())
	if(!length)
		CRASH("Weakpoint spawned with no length value!")
	if(!start_location)
		CRASH("No start location for crack specified!")

	var/list/turf/cracked_turfs = list()
	var/turf/current = loc //Start on top of ourselves
	var/direction = pick(NORTH, SOUTH, EAST, WEST)

	for(var/i in 1 to length)
		if(length(turfs_to_skip) && is_type_in_typecache(current, turfs_to_skip))
			continue

		cracked_turfs += current
		// Randomly branch or continue
		if(prob(CRACK_TURN_CHANCE))
			direction = turn(direction, pick(90, 135, 180, 225, 270))
		current = get_turf(get_step(current, direction))
		if(!isturf(current))
			break
	if(add_splits)
		for(var/subcrack in 1 to crack_split_count)
			cracked_turfs += get_crack_chain(pick(cracked_turfs), max(round(length/2 ), 1), FALSE, turfs_to_skip) //Stop recursion here

	message_admins("Station weakpoint triggered, affecting [length(cracked_turfs)] turfs in [loc_name(start_location)].")
	log_game("Station weakpoint triggered, affecting [length(cracked_turfs)] turfs in [loc_name(start_location)].")
	return cracked_turfs

/// If this turf becomes something we can't spawn a crack on, we should try and shift the crack or otherwise qdel.
/obj/effect/weakpoint/proc/turf_changed(turf/source)
	SIGNAL_HANDLER
	var/turf/option
	var/list/turf/choices = get_adjacent_open_turfs(src)
	while(!option && length(choices))
		option = pick_n_take(get_adjacent_open_turfs(src))
		if(locate(/obj/effect/weakpoint) in option)
			continue
		if(is_type_in_typecache(option, skip_turfs))
			continue
	if(!option)
		qdel(src)
		return
	forceMove(option)

/**
 * Used by weakpoint cracks to spawn new cracks after the crack is finished propagating.
 * * chain_turfs: The list of turfs that we're going to pull from in order to generate a new weakpoint. Generated by ex_act on the parent weakpoint.
 */
/obj/effect/weakpoint/proc/create_new_cracks(list/chain_turfs, new_weakpoints = 1)
	if(!chain_turfs || !length(chain_turfs))
		return FALSE
	chain_turfs = typecache_filter_list_reverse(chain_turfs, skip_turfs) //Filter out things that we don't want to spawn new weakpoints onto.

	var/active_count = 1
	while(active_count < new_weakpoints)
		if(!length(chain_turfs))
			return
		var/spawn_location = pick_n_take(chain_turfs)
		if(is_type_in_typecache(spawn_location, skip_turfs))
			continue
		var/obj/effect/weakpoint/newpoint = new(spawn_location)
		//inherit parent var values in case of var-editing.
		newpoint.new_weakpoints =  new_weakpoints
		newpoint.crack_length = crack_length
		newpoint.crack_split_count = crack_split_count


/obj/effect/weakpoint/big
	name = "dangerous weakpoint"
	desc = "A suspicious crack runs along the ground. This one makes you feel particuarly uneasy."
	icon_state = "weakpoint"
	crack_length = 15
	crack_split_count = 6
	new_weakpoints = 3

#undef CRACK_PROPAGATION_DELAY
#undef CRACK_TURN_CHANCE
#undef CRACK_DELAY_CHANCE
