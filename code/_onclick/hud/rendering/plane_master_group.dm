/// Datum that represents one "group" of plane masters
/// So all the main window planes would be in one, all the spyglass planes in another
/// Etc
/datum/plane_master_group
	/// Our key in the group list on /datum/hud
	/// Should be unique for any group of plane masters in the world
	var/key
	/// Our parent hud
	var/datum/hud/our_hud
	/// List in the form "[plane]" = object, the plane masters we own
	var/list/atom/movable/screen/plane_master/plane_masters = list()
	/// The visual offset we are currently using
	var/active_offset = 0
	/// What, if any, submap we render onto
	var/map = ""
	/// Controls the screen_loc that owned plane masters will use when generating relays. Due to a Byond bug, relays using the CENTER positional loc
	/// Will be improperly offset
	var/relay_loc = "CENTER"

/datum/plane_master_group/New(key, map = "")
	. = ..()
	src.key = key
	src.map = map
	build_plane_masters(0, SSmapping.max_plane_offset)

/datum/plane_master_group/Destroy()
	set_hud(null)
	QDEL_LIST_ASSOC_VAL(plane_masters)
	return ..()

/datum/plane_master_group/proc/set_hud(datum/hud/new_hud)
	if(new_hud == our_hud)
		return
	if(our_hud)
		our_hud.master_groups -= key
		hide_hud()
	our_hud = new_hud
	if(new_hud)
		our_hud.master_groups[key] = src
		show_hud()
		build_planes_offset(our_hud, active_offset)
	SEND_SIGNAL(src, COMSIG_GROUP_HUD_CHANGED, our_hud)

/// Display a plane master group to some viewer, so show all our planes to it
/datum/plane_master_group/proc/attach_to(datum/hud/viewing_hud)
	if(viewing_hud.master_groups[key])
		stack_trace("Hey brother, our key [key] is already in use by a plane master group on the passed in hud, belonging to [viewing_hud.mymob]. Ya fucked up, why are there dupes")
		return

#if MIN_COMPILER_VERSION > 516
	#warn Fully change default relay_loc to "1,1", rather than changing it based on client version
#endif

	set_hud(viewing_hud)
	our_hud.master_groups[key] = src
	show_hud()
	build_planes_offset(our_hud, active_offset)

	if(viewing_hud.mymob?.client?.byond_version > 515)
		relay_loc = "1,1"
		rebuild_plane_masters()

/// Well, refresh our group, mostly useful for plane specific updates
/datum/plane_master_group/proc/refresh_hud()
	hide_hud()
	show_hud()

/// Fully regenerate our group, resetting our planes to their compile time values
/datum/plane_master_group/proc/rebuild_hud()
	hide_hud()
	rebuild_plane_masters()
	show_hud()
	our_hud.update_parallax_pref()
	build_planes_offset(our_hud, active_offset)

/// Regenerate our plane masters, this is useful if we don't have a mob but still want to rebuild. Such in the case of changing the screen_loc of relays
/datum/plane_master_group/proc/rebuild_plane_masters()
	QDEL_LIST_ASSOC_VAL(plane_masters)
	build_plane_masters(0, SSmapping.max_plane_offset)

/datum/plane_master_group/proc/hide_hud()
	for(var/thing in plane_masters)
		var/atom/movable/screen/plane_master/plane = plane_masters[thing]
		plane.hide_from(our_hud.mymob)

/datum/plane_master_group/proc/show_hud()
	for(var/thing in plane_masters)
		var/atom/movable/screen/plane_master/plane = plane_masters[thing]
		show_plane(plane)

/// This is mostly a proc so it can be overriden by popups, since they have unique behavior they want to do
/datum/plane_master_group/proc/show_plane(atom/movable/screen/plane_master/plane)
	plane.show_to(our_hud.mymob)

/// Nice wrapper for the "[]"ing
/datum/plane_master_group/proc/get_plane(plane)
	return plane_masters["[plane]"]

/// Returns a list of all the plane master types we want to create
/datum/plane_master_group/proc/get_plane_types()
	return subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/rendering_plate

/// Actually generate our plane masters, in some offset range (where offset is the z layers to render to, because each "layer" in a multiz stack gets its own plane master cube)
/datum/plane_master_group/proc/build_plane_masters(starting_offset, ending_offset)
	for(var/atom/movable/screen/plane_master/mytype as anything in get_plane_types())
		for(var/plane_offset in starting_offset to ending_offset)
			if(plane_offset != 0 && (initial(mytype.offsetting_flags) & BLOCKS_PLANE_OFFSETTING))
				continue
			var/atom/movable/screen/plane_master/instance = new mytype(null, null, src, plane_offset)
			plane_masters["[instance.plane]"] = instance
			prep_plane_instance(instance)

/// Similarly, exists so subtypes can do unique behavior to planes on creation
/datum/plane_master_group/proc/prep_plane_instance(atom/movable/screen/plane_master/instance)
	return

// It would be nice to setup parallaxing for stairs and things when doing this
// So they look nicer. if you can't it's all good, if you think you can sanely look at monster's work
// It's hard, and potentially expensive. be careful
/datum/plane_master_group/proc/build_planes_offset(datum/hud/source, new_offset, use_scale = TRUE)
	// Check if this feature is disabled for the client, in which case don't use scale.
	var/mob/our_mob = our_hud?.mymob
	if(!our_mob?.client?.prefs?.read_preference(/datum/preference/toggle/multiz_parallax))
		use_scale = FALSE

	// No offset? piss off
	if(!SSmapping.max_plane_offset)
		return

	active_offset = new_offset

	// Each time we go "down" a visual z level, we'll reduce the scale by this amount
	// Chosen because mothblocks liked it, didn't cause motion sickness while also giving a sense of height
	var/scale_by = 0.965
	if(!use_scale)
		// This is a workaround for two things
		// First of all, if a mob can see objects but not turfs, they will not be shown the holder objects we use for
		// What I'd like to do is revert to images if this case throws, but image vis_contents is broken
		// https://www.byond.com/forum/post/2821969
		// If that's ever fixed, please just use that. thanks :)
		scale_by = 1

	var/list/offsets = list()
	var/multiz_boundary = our_mob?.client?.prefs?.read_preference(/datum/preference/numeric/multiz_performance)

	// We accept negatives so going down "zooms" away the drop above as it goes
	for(var/offset in -SSmapping.max_plane_offset to SSmapping.max_plane_offset)
		// Multiz boundaries disable transforms
		if(multiz_boundary != MULTIZ_PERFORMANCE_DISABLE && (multiz_boundary < abs(offset)))
			offsets += null
			continue

		// No transformations if we're landing ON you
		if(offset == 0)
			offsets += null
			continue

		var/scale = scale_by ** (offset)
		var/matrix/multiz_shrink = matrix()
		multiz_shrink.Scale(scale)
		offsets += multiz_shrink

	// So we can talk in 1 -> max_offset * 2 + 1, rather then -max_offset -> max_offset
	var/offset_offset = SSmapping.max_plane_offset + 1

	for(var/plane_key in plane_masters)
		var/atom/movable/screen/plane_master/plane = plane_masters[plane_key]
		if(plane.offsetting_flags & BLOCKS_PLANE_OFFSETTING)
			if(plane.offsetting_flags & OFFSET_RELAYS_MATCH_HIGHEST)
				// Don't offset the plane, do offset where the relays point
				// Required for making things like the blind fullscreen not render over runechat
				plane.offset_relays_in_place(new_offset)
			continue

		var/visual_offset = plane.offset - new_offset

		// Basically uh, if we're showing something down X amount of levels, or up any amount of levels
		if(multiz_boundary != MULTIZ_PERFORMANCE_DISABLE && (visual_offset > multiz_boundary || visual_offset < 0))
			plane.outside_bounds(our_mob)
		else if(plane.is_outside_bounds)
			plane.inside_bounds(our_mob)

		if(!plane.multiz_scaled)
			continue

		if(plane.force_hidden || plane.is_outside_bounds || visual_offset < 0)
			// We don't animate here because it should be invisble, but we do mark because it'll look nice
			plane.transform = offsets[visual_offset + offset_offset]
			continue

		animate(plane, transform = offsets[visual_offset + offset_offset], 0.05 SECONDS, easing = LINEAR_EASING)

/// Holds plane masters for popups, like camera windows
/// Note: We do not scale this plane, even though we could
/// This is because it's annoying to get turfs to position inside it correctly
/// If you wanna try someday feel free, but I can't manage it
/datum/plane_master_group/popup

/// Note do not use return ..() because it will cause client crush when screen gets deleted
/// TOOD: Remove this entirely when 516 is stable
/datum/plane_master_group/popup/attach_to(datum/hud/viewing_hud)
	if(viewing_hud.master_groups[key])
		stack_trace("[key] is already in use by a plane master group on the passed in hud, belonging to [viewing_hud.mymob]!")
		return
	relay_loc = "1,1"
	rebuild_plane_masters()
	set_hud(viewing_hud)
	show_hud()

/datum/plane_master_group/popup/build_planes_offset(datum/hud/source, new_offset, use_scale = TRUE)
	return ..(source, new_offset, FALSE)

/// Holds the main plane master
/datum/plane_master_group/main

/datum/plane_master_group/main/build_planes_offset(datum/hud/source, new_offset, use_scale = TRUE)
	if(use_scale)
		return ..(source, new_offset, source.should_use_scale())
	return ..()

/// Hudless group. Exists for testing
/datum/plane_master_group/hudless
	var/mob/our_mob

/datum/plane_master_group/hudless/Destroy()
	. = ..()
	our_mob = null

/datum/plane_master_group/hudless/hide_hud()
	for(var/thing in plane_masters)
		var/atom/movable/screen/plane_master/plane = plane_masters[thing]
		plane.hide_from(our_mob)

/// This is mostly a proc so it can be overriden by popups, since they have unique behavior they want to do
/datum/plane_master_group/hudless/show_plane(atom/movable/screen/plane_master/plane)
	plane.show_to(our_mob)
