/////////////////////////////////////////////
//// SMOKE SYSTEMS
/////////////////////////////////////////////

/**
 * A group of fluid objects.
 */
/datum/fluid_group
	/// The set of fluid objects currently in this group.
	var/list/nodes
	/// The number of fluid object that this group wants to have contained.
	var/target_size
	/// The total number of fluid objects that have ever been in this group.
	var/total_size = 0

/datum/fluid_group/New(target_size = 0)
	. = ..()
	src.nodes = list()
	src.target_size = target_size

/datum/fluid_group/Destroy(force)
	QDEL_LAZYLIST(nodes)
	return ..()

/**
 * Adds a fluid node to this fluid group.
 *
 * Is a noop if the node is already in the group.
 * Removes the node from any other fluid groups it is in.
 * Syncs the group of the node with the group it is being added to (this one).
 * Increments the total size of the fluid group.
 *
 * Arguments:
 * - [node][/obj/effect/particle_effect/fluid]: The fluid node that is going to be added to this group.
 *
 * Returns:
 * - [TRUE]: If the node to be added is in this group by the end of the proc.
 * - [FALSE]: Otherwise.
 */
/datum/fluid_group/proc/add_node(obj/effect/particle_effect/fluid/node)
	if(!istype(node))
		CRASH("Attempted to add non-fluid node [isnull(node) ? "NULL" : node] to a fluid group.")
	if(QDELING(node))
		CRASH("Attempted to add qdeling node to a fluid group")

	if(node.group)
		if(node.group == src)
			return TRUE
		if(!node.group.remove_node(node))
			return FALSE

	nodes += node
	node.group = src
	total_size++
	return TRUE


/**
 * Removes a fluid node from this fluid group.
 *
 * Is a noop if the node is not in this group.
 * Nulls the nodes fluid group ref to sync it with its new state.
 * DOES NOT decrement the total size of the fluid group.
 *
 * Arguments:
 * - [node][/obj/effect/particle_effect/fluid]: The fluid node that is going to be removed from this group.
 *
 * Returns:
 * - [TRUE]: If the node to be removed is not in the group by the end of the proc.
 */
/datum/fluid_group/proc/remove_node(obj/effect/particle_effect/fluid/node)
	if(node.group != src)
		return TRUE

	nodes -= node
	node.group = null
	return TRUE // Note: does not decrement total size since we don't want the group to expand again when it begins to dissipate or it will never stop.


/**
 * A particle effect that belongs to a fluid group.
 */
/obj/effect/particle_effect/fluid
	name = "fluid"
	///	The fluid group that this particle effect belongs to.
	var/datum/fluid_group/group
	/// What SSfluid bucket this particle effect is currently in.
	var/tmp/effect_bucket
	/// The index of the fluid spread bucket this is being spread in.
	var/tmp/spread_bucket

/obj/effect/particle_effect/fluid/Initialize(mapload, datum/fluid_group/group, obj/effect/particle_effect/fluid/source)
	// We don't pass on explosions. Don't wanna set off a chain reaction in our reagents
	flags_1 |= PREVENT_CONTENTS_EXPLOSION_1
	. = ..()
	if(!group)
		group = source?.group || new
	group.add_node(src)

/obj/effect/particle_effect/fluid/Destroy()
	group.remove_node(src)
	return ..()

/**
 * Attempts to spread this fluid node to wherever it can spread.
 *
 * Exact results vary by subtype implementation.
 */
/obj/effect/particle_effect/fluid/proc/spread()
	CRASH("The base fluid spread proc is not implemented and should not be called. You called it.")


/**
 * A factory which produces fluid groups.
 */
/datum/effect_system/fluid_spread
	effect_type = /obj/effect/particle_effect/fluid
	/// The amount of smoke to produce.
	var/amount = 10

/datum/effect_system/fluid_spread/set_up(range = 1, amount = DIAMOND_AREA(range), atom/location, ...)
	src.location = get_turf(location)
	src.amount = amount

/datum/effect_system/fluid_spread/start()
	var/location = holder ? get_turf(holder) : src.location
	var/obj/effect/particle_effect/fluid/flood = new effect_type(location, new /datum/fluid_group(amount))
	flood.spread()
