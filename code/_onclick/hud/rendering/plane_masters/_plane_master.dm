// I hate this place
INITIALIZE_IMMEDIATE(/atom/movable/screen/plane_master)

/atom/movable/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	plane = LOWEST_EVER_PLANE
	/// Will be sent to the debug ui as a description for each plane
	/// Also useful as a place to explain to coders how/why your plane works, and what it's meant to do
	/// Plaintext and basic html are fine to use here.
	/// I'll bonk you if I find you putting "lmao stuff" in here, make this useful.
	var/documentation = ""

	/// The plane master group we're a member of, our "home"
	var/datum/plane_master_group/home

	/// If our plane master allows for offsetting
	/// Mostly used for planes that really don't need to be duplicated, like the hud planes
	var/allows_offsetting = TRUE
	/// Our offset from our "true" plane, see below
	var/offset
	/// When rendering multiz, lower levels get their own set of plane masters
	/// Real plane here represents the "true" plane value of something, ignoring the offset required to handle lower levels
	var/real_plane

	//--rendering relay vars--
	/// list of planes we will relay this plane's render to
	var/list/render_relay_planes = list(RENDER_PLANE_GAME)
	/// list of current relays this plane is utilizing to render
	var/list/atom/movable/render_plane_relay/relays = list()
	/// list in the form render_source -> list(interested_filters)
	var/list/source_to_filters = list()

	/// How many active relays do we have
	var/active_relays = 0
	/// Are we rendering in place
	var/render_in_place = TRUE
	/// Do we allow rendering in place
	var/allow_rendering_in_place = TRUE
	/// If render relays have already be generated
	var/relays_generated = FALSE

	/// If this plane master should be hidden from the player at roundstart
	/// We do this so PMs can opt into being temporary, to reduce load on clients
	var/start_hidden = FALSE
	/// If this plane master is being forced to hide.
	/// Hidden PMs will dump ANYTHING relayed or drawn onto them. Be careful with this
	/// Remember: a hidden plane master will dump anything drawn directly to it onto the output render. It does NOT hide its contents
	/// Use alpha for that
	var/force_hidden = FALSE

	/// If this plane master is currently hidden by anything
	var/hidden = FALSE

	/// If this plane should be scaled by multiz
	/// Planes with this set should NEVER be relay'd into each other, as that will cause visual fuck
	var/multiz_scaled = TRUE

	/// Bitfield that describes how this plane master will render if its z layer is being "optimized"
	/// If a plane master is NOT critical, it will be completely dropped if we start to render outside a client's multiz boundary prefs
	/// Of note: most of the time we will relay renders to non critical planes in this stage. so the plane master will end up drawing roughly "in order" with its friends
	/// This is NOT done for parallax and other problem children, because the rules of BLEND_MULTIPLY appear to not behave as expected :(
	/// This will also just make debugging harder, because we do fragile things in order to ensure things operate as epected. I'm sorry
	/// Compile time
	/// See [code\__DEFINES\layers.dm] for our bitflags
	var/critical = NONE

	/// How far this plane master is from the z layer of our owner
	/// + means it's higher, - means it's lower
	var/distance_from_owner = 0
	/// If this plane master has been hidden by its z layer distance
	var/hidden_by_distance = NOT_HIDDEN

/atom/movable/screen/plane_master/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset = 0)
	. = ..()
	src.offset = offset
	real_plane = plane

	if(!set_home(home))
		return INITIALIZE_HINT_QDEL
	update_offset()
	if(!documentation && !(istype(src, /atom/movable/screen/plane_master) || istype(src, /atom/movable/screen/plane_master/rendering_plate)))
		stack_trace("Plane master created without a description. Document how your thing works so people will know in future, and we can display it in the debug menu")
	if(start_hidden)
		hide_plane(home.our_hud?.mymob)
	remember_render_relays()
	generate_render_relays()

/atom/movable/screen/plane_master/Destroy()
	QDEL_LIST(relays)
	if(home)
		// NOTE! We do not clear ourselves from client screens
		// We relay on whoever qdel'd us to reset our hud, and properly purge us
		home.plane_masters -= "[plane]"
		home = null
	return ..()

/// Sets the plane group that owns us, it also determines what screen we render to
/// Returns FALSE if the set_home fails, TRUE otherwise
/atom/movable/screen/plane_master/proc/set_home(datum/plane_master_group/home)
	if(!istype(home, /datum/plane_master_group))
		return FALSE
	src.home = home
	if(home.map)
		screen_loc = "[home.map]:[screen_loc]"
		assigned_map = home.map
	return TRUE

/// Setup proc, updates our "offset", basically what layer of multiz we're meant to render
/// Top is 0, goes up as you go down
/// It's taken into account by render targets and relays, so we gotta make sure they're on the same page
/atom/movable/screen/plane_master/proc/update_offset()
	name = "[initial(name)] #[offset]"
	SET_PLANE_W_SCALAR(src, real_plane, offset)
	for(var/i in 1 to length(render_relay_planes))
		render_relay_planes[i] = GET_NEW_PLANE(render_relay_planes[i], offset)
	// Get our base render target
	if(!initial(render_target))
		render_target = get_plane_master_render_base(name)
	else
		render_target = initial(render_target)
	// Figure out its offset
	render_target = OFFSET_RENDER_TARGET(render_target, offset)
	// Decide how to render it
	if(allow_rendering_in_place)
		set_render_in_place(TRUE)
	else
		set_render_in_place(FALSE)

/atom/movable/screen/plane_master/proc/set_render_in_place(render_apart = FALSE)
	render_in_place = render_apart
	var/in_place = copytext(render_target, 1, 2) != "*"
	if(render_apart == in_place)
		return

	var/bare_render_target
	var/old_render_target = render_target
	if(render_apart)
		render_target = copytext(render_target, 2)
		bare_render_target = render_target
	else
		render_target = "*[render_target]"
		bare_render_target = old_render_target

	#warn unit test for this
	// We assert that all initial render targets will have no *
	// Swapping em around
	home.canon_source_to_reality -= render_target
	home.canon_source_to_reality[old_render_target] = render_target

	for(var/atom/movable/render_plane_relay/relay as anything in relays)
		relay.render_source = render_target

	SEND_SIGNAL(home, SIGNAL_RENDER_IN_PLACE_CHANGED(bare_render_target), old_render_target, render_target)

// This is stupid, I AM sorry
// plane masters can change their render targets to render in place
// I want filters to be able to update to match that new target
// So I'm gonna hook into a signal off the plane master group that alerts us to a render target change so we can rehook
/atom/movable/screen/plane_master/add_filter(name, priority, list/params)
	var/source = params["render_source"]
	if(!source)
		return ..()
	// If the source is different from its initial value, let's figure out what it SHOULD be you feel?
	var/existing_source = home.canon_source_to_reality[source]
	if(existing_source)
		params["render_source"] = existing_source
		source = existing_source

	. = ..()
	hook_into_source(source, name)

/atom/movable/screen/plane_master/remove_filter(name_or_names)
	if(!filter_data)
		return ..()

	if(!islist(name_or_names))
		name_or_names = list(name_or_names)
	for(var/filter_name in name_or_names)
		var/list/filter_info = filter_data[name]
		if(!filter_info)
			continue
		var/source = filter_info["render_source"]
		if(!source)
			continue
		clear_from_source(source, filter_name)
	return ..()

/atom/movable/screen/plane_master/proc/hook_into_source(source, filter_name)
	// Trim off the * so we can hit the right hook here
	if(copytext(source, 1, 2) == "*")
		source = copytext(source, 2)

	if(source_to_filters[source])
		source_to_filters[source] += filter_name
		return
	RegisterSignal(home, SIGNAL_RENDER_IN_PLACE_CHANGED(source), PROC_REF(filter_source_changed))
	source_to_filters[source] += list(filter_name)

/atom/movable/screen/plane_master/proc/clear_from_source(source, filter_name)
	if(copytext(source, 1, 2) == "*")
		source = copytext(source, 2)

	source_to_filters[source] -= filter_name
	if(length(source_to_filters[source]))
		return
	UnregisterSignal(home, SIGNAL_RENDER_IN_PLACE_CHANGED(source))
	source_to_filters -= source

/atom/movable/screen/plane_master/proc/filter_source_changed(datum/source, old_source, new_source)
	SIGNAL_HANDLER
	if(old_source == new_source)
		return

	var/operating_source = new_source
	if(copytext(operating_source, 1, 2) == "*")
		operating_source = copytext(operating_source, 2)

	for(var/filter_name as anything in source_to_filters[operating_source])
		var/list/data = filter_data[filter_name]
		data["render_source"] = new_source
	update_filters()

/// Shows a plane master to the passed in mob
/// Override this to apply unique effects and such
/// Returns TRUE if the call is allowed, FALSE otherwise
/atom/movable/screen/plane_master/proc/show_to(mob/mymob)
	SHOULD_CALL_PARENT(TRUE)
	if(force_hidden)
		return FALSE

	hidden = FALSE
	var/client/our_client = mymob?.canon_client
	if(!our_client)
		return TRUE

	our_client.screen += src
	for(var/atom/movable/render_plane_relay/relay as anything in relays)
		relay.sync_relay(our_client)
	for(var/atom/movable/render_plane_relay/relay as anything in home.relays["[plane]"])
		relay.sync_relay(our_client)

	return TRUE

/// Hides a plane master from the passeed in mob
/// Do your effect cleanup here
/atom/movable/screen/plane_master/proc/hide_from(mob/oldmob)
	SHOULD_CALL_PARENT(TRUE)
	hidden = TRUE
	var/client/their_client = oldmob?.client
	if(!their_client)
		return
	their_client.screen -= src
	for(var/atom/movable/render_plane_relay/relay as anything in relays)
		relay.sync_relay(their_client)
	for(var/atom/movable/render_plane_relay/relay as anything in home.relays["[plane]"])
		relay.sync_relay(their_client)

/// We have a relay pointing at the target plane
/// Should we wipe it out? or keep a hold of it
/atom/movable/screen/plane_master/proc/should_hide_relay(target_plane)
	return TRUE

/// Forces this plane master to hide, until unhide_plane is called
/// This allows us to disable unused PMs without breaking anything else
/atom/movable/screen/plane_master/proc/hide_plane(mob/cast_away)
	force_hidden = TRUE
	hide_from(cast_away)

/// Disables any forced hiding, allows the plane master to be used as normal
/atom/movable/screen/plane_master/proc/unhide_plane(mob/enfold)
	force_hidden = FALSE
	show_to(enfold)

/// Mirrors our force hidden state to the hidden state of the plane that came before, assuming it's valid
/// This allows us to mirror any hidden sets from before we were created, no matter how low that chance is
/atom/movable/screen/plane_master/proc/mirror_parent_hidden()
	var/mob/our_mob = home?.our_hud?.mymob
	var/atom/movable/screen/plane_master/true_plane = our_mob?.hud_used?.get_plane_master(plane)
	if(true_plane == src || !true_plane)
		return

	if(true_plane.force_hidden == force_hidden)
		return

	// If one of us already exists and it's not hidden, unhide ourselves
	if(true_plane.force_hidden)
		hide_plane(our_mob)
	else
		unhide_plane(our_mob)

/// Sets and reacts to the distance we are from our owner's z layer
/// This is what handles culling plane masters that are out of the sight of our mob
/// Takse the mob to apply changes to, the new working distance,
// the multiz_boundary of the mob and the lowest possible offset for anything the mob will see  (expensive lookup, faster this way)
/// Returns TRUE if the plane master is still visible, FALSE if it's hidden
/atom/movable/screen/plane_master/proc/set_distance_from_owner(mob/relevant, new_distance, multiz_boundary, lowest_possible_offset)
	SHOULD_CALL_PARENT(TRUE)
	distance_from_owner = new_distance
	var/old_hidden = hidden_by_distance
	#warn being unforce hid needs to rerun distance calcs
	// If we are above our owner's z layer nuke er
	if(distance_from_owner > 0)
		if(hidden_by_distance == HIDDEN_ABOVE)
			return critical & PLANE_CRITICAL_SOURCE

		// Need to maintain consistency
		if(hidden_by_distance != NOT_HIDDEN)
			show_to(relevant)

		hidden_by_distance = HIDDEN_ABOVE
		// If critical, hold on
		if(critical & PLANE_CRITICAL_SOURCE)
			retain_hidden_plane(relevant)
			return TRUE
		// otherwise, hide that shit
		hide_from(relevant)
		return FALSE
	// If we're just not visible at all
	else if(distance_from_owner < 0 && offset > lowest_possible_offset)
		if(hidden_by_distance == HIDDEN_BELOW_THE_BOTTOM)
			return FALSE
		hidden_by_distance = HIDDEN_BELOW_THE_BOTTOM
		hide_from(relevant)
		return FALSE
	// If we are below the acceptable z level offset (set by pref)
	else if(distance_from_owner < 0 && (multiz_boundary != MULTIZ_PERFORMANCE_DISABLE && abs(distance_from_owner) > multiz_boundary))
		if(hidden_by_distance)
			return critical & PLANE_CRITICAL_DISPLAY // yeah this is dumb I'm sorry

		// Need to maintain consistency
		if(hidden_by_distance != NOT_HIDDEN)
			show_to(relevant)

		hidden_by_distance = HIDDEN_BELOW
		// If it's critical to how lower layers look visually (mostly lighting)
		// Keep the bare bones
		if((critical & PLANE_CRITICAL_DISPLAY))
			retain_hidden_plane(relevant)
			return TRUE
		// Otherwise, yayeeet
		hide_from(relevant)
		return FALSE
	else if(hidden_by_distance != NOT_HIDDEN)
		hidden_by_distance = NOT_HIDDEN
		if(old_hidden == HIDDEN_ABOVE && (critical & PLANE_CRITICAL_SOURCE) || \
			old_hidden == HIDDEN_BELOW && (critical & PLANE_CRITICAL_DISPLAY))
			restore_hidden_plane(relevant)
			return TRUE
		show_to(relevant)
	return TRUE

// idea is if no relays exist we'll want to render "in place" based off our plane var
// if we do have relays, we should send to them instead
// needs to account for existing filters
/atom/movable/screen/plane_master/proc/relays_lost()
	if(!allow_rendering_in_place)
		return
	if(render_in_place)
		return
	if(!render_target)
		return
	set_render_in_place(TRUE)

/atom/movable/screen/plane_master/proc/relays_gained()
	if(!allow_rendering_in_place)
		return
	if(!render_in_place)
		return
	if(!render_target)
		return
	set_render_in_place(FALSE)

/// Lets us partially hide planes for performance reasons without fully disabling them
/atom/movable/screen/plane_master/proc/retain_hidden_plane(mob/relevant)
	return

/// Restores a formerly partially hidden plane
/atom/movable/screen/plane_master/proc/restore_hidden_plane(mob/relevant)
	return

/// Called to inform relays that render onto us that we now like, exist and stuff
/atom/movable/screen/plane_master/proc/remember_render_relays()
	var/client/source = home?.our_hud?.mymob?.client
	for(var/atom/movable/render_plane_relay/relay as anything in home.relays["[plane]"])
		relay.target = src
		if(source)
			relay.sync_relay(source)

/**
 * Plane master proc called in Initialize() that creates relay objects, and sets them uo as needed
 * Sets:
 * * layer from plane to avoid z-fighting
 * * planes to relay the render to
 * * render_source so that the plane will render on these objects
 * * mouse opacity to ensure proper mouse hit tracking
 * * name for debugging purposes
 * Other vars such as alpha will automatically be applied with the render source
 */
/atom/movable/screen/plane_master/proc/generate_render_relays()
	var/relay_loc = home?.relay_loc || "CENTER"
	// If we're using a submap (say for a popup window) make sure we draw onto it
	if(home?.map)
		relay_loc = "[home.map]:[relay_loc]"

	var/list/generated_planes = list()
	for(var/atom/movable/render_plane_relay/relay as anything in relays)
		generated_planes += relay.plane

	for(var/relay_plane in (render_relay_planes - generated_planes))
		generate_relay_to(relay_plane, relay_loc)

	relays_generated = TRUE

/// Creates a connection between this plane master and the passed in plane
/// Helper for out of system code, shouldn't be used in this file
/// Build system to differenchiate between generated and non generated render relays
/atom/movable/screen/plane_master/proc/add_relay_to(target_plane, blend_override, relay_layer, relay_color, relay_transform, relay_appearance_flags)
	if(get_relay_to(target_plane))
		return
	render_relay_planes += target_plane
	var/client/display_lad = home?.our_hud?.mymob?.canon_client
	var/atom/movable/render_plane_relay/relay = generate_relay_to(target_plane, show_to = display_lad, blend_override = blend_override, relay_layer = relay_layer)
	relay.color = relay_color
	if(relay_transform)
		relay.transform = relay_transform
	if(relay_appearance_flags)
		relay.appearance_flags |= relay_appearance_flags

/proc/get_plane_master_render_base(name)
	return "[name]: AUTOGENERATED RENDER TGT"

/atom/movable/screen/plane_master/proc/generate_relay_to(target_plane, relay_loc, client/show_to, blend_override, relay_layer)
	if(!relay_loc)
		relay_loc = "CENTER"
		// If we're using a submap (say for a popup window) make sure we draw onto it
		if(home?.map)
			relay_loc = "[home.map]:[relay_loc]"
	var/blend_to_use = blend_override
	if(isnull(blend_to_use))
		blend_to_use = initial(blend_mode)

	var/atom/movable/render_plane_relay/relay = new()
	relay.render_source = render_target
	relay.plane = target_plane
	relay.screen_loc = relay_loc
	// There are two rules here
	// 1: layer needs to be positive (negative layers are treated as float layers)
	// 2: lower planes (including offset ones) need to be layered below higher ones (because otherwise they'll render fucky)
	// By multiplying LOWEST_EVER_PLANE by 30, we give 30 offsets worth of room to planes before they start going negative
	// Bet
	// We allow for manuel override if requested. careful with this
	relay.layer = relay_layer || (plane + abs(LOWEST_EVER_PLANE * 30)) //layer must be positive but can be a decimal
	relay.blend_mode = blend_to_use
	relay.mouse_opacity = mouse_opacity
	relay.name = render_target
	relays += relay
	relay.source = src
	var/atom/movable/screen/plane_master/target = home.plane_masters["[target_plane]"]
	if(target)
		relay.target = target
	home.relays["[target_plane]"] += list(relay)

	// Relays are sometimes generated early, before huds have a mob to display stuff to
	// That's what this is for
	if(show_to)
		relay.sync_relay(show_to)
	return relay

/// Breaks a connection between this plane master, and the passed in place
/atom/movable/screen/plane_master/proc/remove_relay_from(target_plane)
	var/atom/movable/render_plane_relay/existing_relay = get_relay_to(target_plane)
	if(!existing_relay)
		render_relay_planes -= target_plane
		return
	qdel(existing_relay)

/// Gets the relay atom we're using to connect to the target plane, if one exists
/atom/movable/screen/plane_master/proc/get_relay_to(target_plane)
	for(var/atom/movable/render_plane_relay/relay in relays)
		if(relay.plane == target_plane)
			return relay

	return null

/atom/movable/screen/plane_master/proc/relay_activated()
	if(active_relays == 0)
		relays_gained()
	active_relays += 1

/atom/movable/screen/plane_master/proc/relay_removed()
	active_relays -= 1
	if(active_relays == 0)
		relays_lost()
