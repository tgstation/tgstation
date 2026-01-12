
#define CRACK_PROPAGATION_DELAY 0.1 SECONDS
#define CRACK_TURN_CHANCE 50
#define CRACK_DELAY_CHANCE 33

/obj/effect/weakpoint
	name = "weakpoint crack"
	desc = "A suspicious crack runs along the ground."
	icon = 'icons/effects/effects.dmi'
	icon_state = "weakpoint"

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

/obj/effect/weakpoint/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, INVISIBILITY_OBSERVER, use_anchor = TRUE)
	register_context()

/obj/effect/weakpoint/ex_act(severity, target)
	. = ..()
	if(severity < required_strength)
		to_chat(world, "too weak!")
		playsound(source = src, soundin = sound(get_sfx(SFX_HULL_CREAKING)), vol = 50, vary = TRUE, pressure_affected = FALSE, ignore_walls = TRUE)
		return //return ominous sounds when we're under the threshold.

	var/list/chain_turfs = get_crack_chain(get_turf(src), 8, TRUE) // Get a nice chain of turfs

	var/crack_delay = 0
	for(var/turf/crack_turf in chain_turfs)
		addtimer(CALLBACK(crack_turf, TYPE_PROC_REF(/atom, ex_act), severity, crack_turf), CRACK_PROPAGATION_DELAY * crack_delay)
		playsound(source = crack_turf, soundin = sound(get_sfx(SFX_HULL_CREAKING)), vol = 35, vary = TRUE, pressure_affected = FALSE, ignore_walls = TRUE)
		if(prob(33))
			crack_delay++

	if(spawns_children)
		var/static/list/skip_turfs = typecacheof(list(
			/turf/open/space,
			/turf/open/misc/asteroid,
			/turf/open/misc/snow,
		))
		chain_turfs = typecache_filter_list_reverse(chain_turfs, skip_turfs) //Filter out things that we don't want to spawn new weakpoints onto.

		for(var/i in 1 to new_weakpoints)
			var/obj/effect/weakpoint/newpoint = new(pick(chain_turfs))
			//inherit parent var values in case of var-editing.
			newpoint.new_weakpoints =  new_weakpoints
			newpoint.crack_length = crack_length
			newpoint.crack_split_count = crack_split_count
	qdel(src)

/obj/effect/weakpoint/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	to_chat(user, span_notice("You begin to strengthen [src]..."))
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 1, volume=50))
		return TRUE
	balloon_alert_to_viewers("sealed!")
	to_chat(user, span_notice("\The [src] is fully sealed, eliminating the risk of growing."))
	qdel(src)

/obj/effect/weakpoint/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item.tool_behaviour == TOOL_WELDER)
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
 */
/obj/effect/weakpoint/proc/get_crack_chain(start_location, length, add_splits = TRUE)
	if(!length)
		CRASH("Weakpoint spawned with no length value!")
	if(!start_location)
		CRASH("No start location for crack specified!")

	var/list/turf/cracked_turfs = list()
	var/turf/current = loc //Start on top of ourselves
	var/direction = pick(NORTH, SOUTH, EAST, WEST)

	for(var/i in 1 to length)
		cracked_turfs += current
		// Randomly branch or continue
		if(prob(CRACK_TURN_CHANCE))
			direction = turn(direction, pick(-90, -45, 45, 90))
		current = get_turf(get_step(current, direction))
		if(!isturf(current))
			CRASH("Crack propagation was handed a non-turf.")
	if(add_splits)
		for(var/subcrack in 1 to crack_split_count)
			cracked_turfs += get_crack_chain(pick(cracked_turfs), max(round(length/2 ), 1), FALSE) //Stop recursion here

	message_admins("Station weakpoint triggered, affecting [length(cracked_turfs)] turfs in [loc_name(start_location)].")
	log_game("Station weakpoint triggered, affecting [length(cracked_turfs)] turfs in [loc_name(start_location)].")

	return cracked_turfs

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
