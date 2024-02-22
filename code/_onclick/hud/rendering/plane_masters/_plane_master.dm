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
	/// Our real alpha value, so alpha can persist through being hidden/shown
	var/true_alpha = 255
	/// Tracks if we're using our true alpha, or being manipulated in some other way
	var/alpha_enabled = TRUE

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
	/// blend mode to apply to the render relay in case you dont want to use the plane_masters blend_mode
	var/blend_mode_override
	/// list of current relays this plane is utilizing to render
	var/list/atom/movable/render_plane_relay/relays = list()
	/// if render relays have already be generated
	var/relays_generated = FALSE

	/// If this plane master should be hidden from the player at roundstart
	/// We do this so PMs can opt into being temporary, to reduce load on clients
	var/start_hidden = FALSE
	/// If this plane master is being forced to hide.
	/// Hidden PMs will dump ANYTHING relayed or drawn onto them. Be careful with this
	/// Remember: a hidden plane master will dump anything drawn directly to it onto the output render. It does NOT hide its contents
	/// Use alpha for that
	var/force_hidden = FALSE

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
	var/hidden_by_distance = FALSE

/atom/movable/screen/plane_master/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset = 0)
	. = ..()
	src.offset = offset
	true_alpha = alpha
	real_plane = plane

	if(!set_home(home))
		return INITIALIZE_HINT_QDEL
	update_offset()
	if(!documentation && !(istype(src, /atom/movable/screen/plane_master) || istype(src, /atom/movable/screen/plane_master/rendering_plate)))
		stack_trace("Plane master created without a description. Document how your thing works so people will know in future, and we can display it in the debug menu")
	if(start_hidden)
		hide_plane(home.our_hud?.mymob)
	generate_render_relays()

/atom/movable/screen/plane_master/Destroy()
	if(home)
		// NOTE! We do not clear ourselves from client screens
		// We relay on whoever qdel'd us to reset our hud, and properly purge us
		home.plane_masters -= "[plane]"
		home = null
	. = ..()
	QDEL_LIST(relays)

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

/// Updates our "offset", basically what layer of multiz we're meant to render
/// Top is 0, goes up as you go down
/// It's taken into account by render targets and relays, so we gotta make sure they're on the same page
/atom/movable/screen/plane_master/proc/update_offset()
	name = "[initial(name)] #[offset]"
	SET_PLANE_W_SCALAR(src, real_plane, offset)
	for(var/i in 1 to length(render_relay_planes))
		render_relay_planes[i] = GET_NEW_PLANE(render_relay_planes[i], offset)
	if(initial(render_target))
		render_target = OFFSET_RENDER_TARGET(initial(render_target), offset)

/atom/movable/screen/plane_master/proc/set_alpha(new_alpha)
	true_alpha = new_alpha
	if(!alpha_enabled)
		return
	alpha = new_alpha

/atom/movable/screen/plane_master/proc/disable_alpha()
	alpha_enabled = FALSE
	alpha = 0

/atom/movable/screen/plane_master/proc/enable_alpha()
	alpha_enabled = TRUE
	alpha = true_alpha

/// Shows a plane master to the passed in mob
/// Override this to apply unique effects and such
/// Returns TRUE if the call is allowed, FALSE otherwise
/atom/movable/screen/plane_master/proc/show_to(mob/mymob)
	SHOULD_CALL_PARENT(TRUE)
	if(force_hidden)
		return FALSE

	var/client/our_client = mymob?.canon_client
	if(!our_client)
		return TRUE

	our_client.screen += src
	// Alright, let's get this out of the way
	// Mobs can move z levels without their client. If this happens, we need to ensure critical display settings are respected
	// This is done here. Mild to severe pain but it's nessesary
	// (We check to see if we use the critical system, then if we don't want some realys, then if we are actually outside bounds)
	// If we want all our relays then there's no point doing this now is there
	if(!(critical & (PLANE_CRITICAL_DISPLAY|PLANE_CRITICAL_SOURCE)) || !(critical & PLANE_CRITICAL_NO_RELAY) || !check_outside_bounds())
		our_client.screen += relays
	return TRUE

/// Hook to allow planes to work around is_outside_bounds
/// Return false to allow a show, true otherwise
/atom/movable/screen/plane_master/proc/check_outside_bounds()
	return hidden_by_distance

/// Hides a plane master from the passeed in mob
/// Do your effect cleanup here
/atom/movable/screen/plane_master/proc/hide_from(mob/oldmob)
	SHOULD_CALL_PARENT(TRUE)
	var/client/their_client = oldmob?.client
	if(!their_client)
		return
	their_client.screen -= src
	their_client.screen -= relays


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
	// If we are above our owner's z layer
	#warn in order to make this work disabling a plane fully needs to disable any relays that draw at it
	#warn otherwise this shit is fucked. so we need a linkback list.
	#warn (do we need to disable all of them? I guess we would, and then prevent adding new ones without asking)
	#warn this is gonna fuck up plane master handling real bad, need to make removing/readding relays efficent somehow
	#warn group them by when we remove them maybe and then stick em in the vis_contents of screen objects?
	#warn also we need hidden_by_distance to track what kind of hidden we are, so we can fullhide everything on the z layer below the bottom displayed
	//if(distance_from_owner > 0)
	//	if(hidden_by_distance || force_hidden)
	//		return critical & PLANE_CRITICAL_SOURCE
	//	hidden_by_distance = TRUE
	//	// If critical, hold on
	//	if(critical & PLANE_CRITICAL_SOURCE)
	//		retain_hidden_plane(relevant)
	//		return TRUE
	//	// otherwise, hide that shit
	//	hide_from(relevant)
	//	return FALSE
	// If we are below the acceptable z level offset (set by pref)
	// (Or if we're just not visible at all)
	//else
	if(distance_from_owner < 0 && (offset > lowest_possible_offset || \
		multiz_boundary != MULTIZ_PERFORMANCE_DISABLE && abs(distance_from_owner) > multiz_boundary))
		if(hidden_by_distance || force_hidden)
			return (critical & PLANE_CRITICAL_DISPLAY && offset < lowest_possible_offset) // yeah this is dumb I'm sorry
		hidden_by_distance = TRUE
		// If it's critical to how lower layers look visually (mostly lighting)
		// Keep the bare bones
		if(critical & PLANE_CRITICAL_DISPLAY && (offset < lowest_possible_offset))
			retain_hidden_plane(relevant)
			return TRUE
		// Otherwise, yayeeet
		hide_from(relevant)
		return FALSE
	else if(hidden_by_distance)
		hidden_by_distance = FALSE
		if(critical & (PLANE_CRITICAL_SOURCE|PLANE_CRITICAL_DISPLAY))
			restore_hidden_plane(relevant)
			return TRUE
		show_to(relevant)
	return TRUE

/// Hides a plane from either relays or render targets (or both), but does not actually remove it from the screen
/// Lets us partially hide planes for performance reasons without fully disabling them
/atom/movable/screen/plane_master/proc/retain_hidden_plane(mob/relevant)
	// We here assume that your render target starts with *
	if(critical & PLANE_CRITICAL_CUT_RENDER && render_target)
		render_target = copytext_char(render_target, 2)
	if(!(critical & PLANE_CRITICAL_NO_RELAY))
		return
	var/client/our_client = relevant.client
	if(!our_client)
		return
	for(var/atom/movable/render_plane_relay/relay as anything in relays)
		our_client.screen -= relay

/// Restores a formerly partially hidden plane
/atom/movable/screen/plane_master/proc/restore_hidden_plane(mob/relevant)
	// We once again assume that your render target WANTS to start with *
	if(critical & PLANE_CRITICAL_CUT_RENDER && render_target)
		render_target = "*[render_target]"
	if(!(critical & PLANE_CRITICAL_NO_RELAY))
		return
	var/client/our_client = relevant.client
	if(!our_client)
		return
	for(var/atom/movable/render_plane_relay/relay as anything in relays)
		our_client.screen += relay
