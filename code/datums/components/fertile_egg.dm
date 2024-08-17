/**
 * ### A fertile egg component!
 *
 * This component tracks over time if the atom is in ideal conditions,
 * and eventually hatches into the embryonic type.
 *
 * The initial design of this component was to make more generic the code for
 * chickens laying eggs.
 */
/datum/component/fertile_egg
	/// What will come out of the egg when it's done.
	var/embryo_type

	/// Minimum growth rate per tick
	var/minimum_growth_rate

	/// Maximum growth rate per tick
	var/maximum_growth_rate

	/// Total growth required before hatching.
	var/total_growth_required

	/// The current amount of growth.
	var/current_growth

	/// List of locations which, if set, the egg will only develop if in those locations.
	var/list/location_allowlist

	/// If true, being in an unsuitable location spoils the egg (ie. kills the component). If false, it just pauses the egg's development.
	var/spoilable

	///callback after the egg hatches
	var/datum/callback/post_hatch

/datum/component/fertile_egg/Initialize(embryo_type, minimum_growth_rate, maximum_growth_rate, total_growth_required, current_growth, location_allowlist, spoilable, examine_message, post_hatch)
	// Quite how an _area_ can be a fertile egg is an open question, but it still has a location. Technically.
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.embryo_type = embryo_type
	src.minimum_growth_rate = minimum_growth_rate
	src.maximum_growth_rate = maximum_growth_rate
	src.total_growth_required = total_growth_required
	src.current_growth = current_growth
	src.location_allowlist = location_allowlist
	src.spoilable = spoilable
	src.post_hatch = post_hatch

	START_PROCESSING(SSobj, src)

/datum/component/fertile_egg/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/datum/component/fertile_egg/process(seconds_per_tick)
	var/atom/parent_atom = parent

	if(location_allowlist && !is_type_in_typecache(parent_atom.loc, location_allowlist))
		// In a zone that is not allowed, do nothing, and possibly self destruct
		if(spoilable)
			qdel(src)
		return

	current_growth += rand(minimum_growth_rate, maximum_growth_rate) * seconds_per_tick
	if(current_growth < total_growth_required)
		return
	parent_atom.visible_message(span_notice("[parent] hatches with a quiet cracking sound."))
	new embryo_type(get_turf(parent_atom))
	post_hatch?.Invoke(embryo_type)
	// We destroy the parent on hatch, which will destroy the component as well, which will stop us processing.
	qdel(parent_atom)
