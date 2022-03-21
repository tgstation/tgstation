// Replaces chemgrenade stuff, allowing reagent explosions to be called from anywhere.
// It should be called using a location, the range, and a list of reagents involved.

// Threatscale is a multiplier for the 'threat' of the grenade. If you're increasing the affected range drastically, you might want to improve this.
// Extra heat affects the temperature of the mixture, and may cause it to react in different ways.

/**
 * The basic chemical bomb proc.
 * Combines a set of reagent holders into one holder and reacts it.
 * If there are any reagents left over it spreads them across the surrounding environment.
 * The maximum volume of the holder is temporarily adjusted to allow for reactions which increase total volume to work at full effectiveness.
 * The maximum volume of the holder is then reset to its original value.
 *
 * Arguments:
 * - [epicenter][/turf]: The epicenter of the splash if some of the reagents aren't consumed.
 * - [holder][/datum/reagents]: The holder to combine all of the reagents into. A temporary one is created if this is null.
 * - [reactants][/list/datum/reagents]: The set of reagent holders to combine.
 * - extra_heat: Some amount to heat the combined reagents by before reacting them.
 * - threatscale: A multiplier for the reagent quantities involved.
 * - adminlog: Whether to alert the admins that this has occured.
 */
/proc/chem_splash(turf/epicenter, datum/reagents/holder = null, affected_range = 3, list/datum/reagents/reactants = list(), extra_heat = 0, threatscale = 1, adminlog = 1)
	if(!isturf(epicenter) || !reactants.len || threatscale <= 0)
		return

	var/total_reagents = holder?.total_volume
	var/maximum_reagents = holder?.maximum_volume
	for(var/datum/reagents/reactant in reactants)
		if(reactant.total_volume)
			total_reagents += reactant.total_volume
		maximum_reagents += reactant.maximum_volume

	if (total_reagents <= 0)
		return FALSE

	var/tmp_holder = null
	var/original_max_volume = null
	if (isnull(holder))
		tmp_holder = TRUE
		holder = new /datum/reagents(maximum_reagents * threatscale)
		holder.my_atom = epicenter
	else
		tmp_holder = FALSE
		original_max_volume = holder.maximum_volume
		if(threatscale < 1)
			holder.multiply_reagents(threatscale)
			holder.maximum_volume = maximum_reagents * threatscale
		else
			holder.maximum_volume = maximum_reagents * threatscale
			holder.multiply_reagents(threatscale)

	for(var/datum/reagents/reactant as anything in reactants)
		reactant.trans_to(holder, reactant.total_volume, threatscale, preserve_data = TRUE, no_react = TRUE)

	holder.chem_temp += extra_heat // Average temperature of reagents + extra heat.
	holder.handle_reactions() // React them now.

	if(holder.total_volume)
		if(affected_range >= 0)
			spread_reagents(holder, epicenter, affected_range)
		holder.clear_reagents()

	if(tmp_holder)
		qdel(holder)
	else
		holder.maximum_volume = original_max_volume

	return TRUE


/**
 * Exposes all accessible atoms within some distance of an epicenter to some reagents.
 * Does not clear the source reagent holder; that must be done manually if it is desired.
 *
 * Arguments:
 * - [source][/datum/reagents]: The reagents to spread around.
 * - [epicenter][/atom]: The epicenter/source location of the reagent spread.
 * - spread_range: The range in which to spread the reagents.
 */
/proc/spread_reagents(datum/reagents/source, atom/epicenter, spread_range)
	var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread()
	steam.set_up(10, 0, epicenter)
	steam.attach(epicenter)
	steam.start()


	var/list/viewable = view(spread_range, epicenter)
	var/list/accessible = list(epicenter)
	for(var/i in 1 to spread_range)
		var/list/turflist = list()
		for(var/turf/T in (orange(i, epicenter) - orange(i-1, epicenter)))
			turflist |= T
		for(var/turf/T in turflist)
			if(!(get_dir(T,epicenter) in GLOB.cardinals) && (abs(T.x - epicenter.x) == abs(T.y - epicenter.y) ))
				turflist.Remove(T)
				turflist.Add(T) // we move the purely diagonal turfs to the end of the list.
		for(var/turf/T in turflist)
			if(accessible[T])
				continue
			for(var/thing in T.get_atmos_adjacent_turfs(alldir = TRUE))
				var/turf/NT = thing
				if(!(NT in accessible))
					continue
				if(!(get_dir(T,NT) in GLOB.cardinals))
					continue
				accessible[T] = 1
				break

	var/chem_temp = source.chem_temp
	var/list/reactable = accessible
	for(var/turf/T in accessible)
		reactable += T
		for(var/atom/A in T.get_all_contents())
			if(!(A in viewable))
				continue
			reactable |= A
		if(chem_temp >= 300)
			T.hotspot_expose(chem_temp*2, 5)
	if(!reactable.len) //Nothing to react with. Probably means we're in nullspace.
		return
	for(var/thing in reactable)
		var/atom/A = thing
		var/distance = max(1, get_dist(A, epicenter))
		var/fraction = 0.5 / (2 ** distance) //50/25/12/6... for a 200u splash, 25/12/6/3... for a 100u, 12/6/3/1 for a 50u
		source.expose(A, TOUCH, fraction)
