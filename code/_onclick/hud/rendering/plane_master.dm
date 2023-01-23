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

	/// If this plane master is outside of our visual bounds right now
	var/is_outside_bounds = FALSE

/atom/movable/screen/plane_master/Initialize(mapload, datum/plane_master_group/home, offset = 0)
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
	if(force_hidden || is_outside_bounds)
		return FALSE

	var/client/our_client = mymob?.client
	if(!our_client)
		return TRUE

	our_client.screen += src
	our_client.screen += relays
	return TRUE

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

/atom/movable/screen/plane_master/proc/outside_bounds(mob/relevant)
	if(force_hidden || is_outside_bounds)
		return
	is_outside_bounds = TRUE
	// If we're of critical importance, AND we're below the rendering layer
	if(critical & PLANE_CRITICAL_DISPLAY)
		if(!(critical & PLANE_CRITICAL_NO_EMPTY_RELAY))
			return
		var/client/our_client = relevant.client
		if(!our_client)
			return
		for(var/atom/movable/render_plane_relay/relay as anything in relays)
			if(!relay.critical_target)
				our_client.screen -= relay

		// We here assume that your render target starts with *
		if(render_target)
			render_target = copytext_char(render_target, 2)
		return
	hide_from(relevant)

/atom/movable/screen/plane_master/proc/inside_bounds(mob/relevant)
	is_outside_bounds = FALSE
	if(critical & PLANE_CRITICAL_DISPLAY)
		if(!(critical & PLANE_CRITICAL_NO_EMPTY_RELAY))
			return
		var/client/our_client = relevant.client
		if(!our_client)
			return
		for(var/atom/movable/render_plane_relay/relay as anything in relays)
			if(!relay.critical_target)
				our_client.screen += relay

		// We here assume that your render target starts with *
		if(render_target)
			render_target = "*[render_target]"
		return
	show_to(relevant)

/atom/movable/screen/plane_master/clickcatcher
	name = "Click Catcher"
	documentation = "Contains the screen object we use as a backdrop to catch clicks on portions of the screen that would otherwise contain nothing else. \
		<br>Will always be below almost everything else"
	plane = CLICKCATCHER_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	multiz_scaled = FALSE
	critical = PLANE_CRITICAL_DISPLAY

/atom/movable/screen/plane_master/clickcatcher/Initialize(mapload, datum/plane_master_group/home, offset)
	. = ..()
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(offset_increased))
	offset_increased(SSmapping, 0, SSmapping.max_plane_offset)

/atom/movable/screen/plane_master/clickcatcher/proc/offset_increased(datum/source, old_off, new_off)
	SIGNAL_HANDLER
	// We only want need the lowest level
	// If my system better supported changing PM plane values mid op I'd do that, but I do NOT so
	if(new_off > offset)
		hide_plane(home?.our_hud?.mymob)

/atom/movable/screen/plane_master/parallax_white
	name = "Parallax whitifier"
	documentation = "Essentially a backdrop for the parallax plane. We're rendered just below it, so we'll be multiplied by its well, parallax.\
		<br>If you want something to look as if it has parallax on it, draw it to this plane."
	plane = PLANE_SPACE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_GAME, EMISSIVE_MASK_PLANE)
	critical = PLANE_CRITICAL_FUCKO_PARALLAX // goes funny when touched. no idea why I don't trust byond

///Contains space parallax
/atom/movable/screen/plane_master/parallax
	name = "Parallax"
	documentation = "Contains parallax, or to be more exact the screen objects that hold parallax.\
		<br>Note the BLEND_MULTIPLY. The trick here is how low our plane value is. Because of that, we draw below almost everything in the game.\
		<br>We abuse this to ensure we multiply against the Parallax whitifier plane, or space's plane. It's set to full white, so when you do the multiply you just get parallax out where it well, makes sense to be.\
		<br>Also notice that the parent parallax plane is mirrored down to all children. We want to support viewing parallax across all z levels at once."
	plane = PLANE_SPACE_PARALLAX
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	multiz_scaled = FALSE

/atom/movable/screen/plane_master/parallax/Initialize(mapload, datum/plane_master_group/home, offset)
	. = ..()
	if(offset != 0)
		// You aren't the source? don't change yourself
		return
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(on_offset_increase))
	offset_increase(0, SSmapping.max_plane_offset)

/atom/movable/screen/plane_master/parallax/proc/on_offset_increase(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	offset_increase(old_offset, new_offset)

/atom/movable/screen/plane_master/parallax/proc/offset_increase(old_offset, new_offset)
	// Parallax will be mirrored down to any new planes that are added, so it will properly render across mirage borders
	for(var/offset in old_offset to new_offset)
		if(offset != 0)
			// Overlay so we don't multiply twice, and thus fuck up our rendering
			add_relay_to(GET_NEW_PLANE(plane, offset), BLEND_OVERLAY)

// Hacky shit to ensure parallax works in perf mode
/atom/movable/screen/plane_master/parallax/outside_bounds(mob/relevant)
	if(offset == 0)
		remove_relay_from(GET_NEW_PLANE(RENDER_PLANE_GAME, 0))
		is_outside_bounds = TRUE // I'm sorry :(
		return
	// If we can't render, and we aren't the bottom layer, don't render us
	// This way we only multiply against stuff that's not fullwhite space
	var/atom/movable/screen/plane_master/parent_parallax = home.our_hud.get_plane_master(PLANE_SPACE_PARALLAX)
	var/turf/viewing_turf = get_turf(relevant)
	if(!viewing_turf || offset != GET_LOWEST_STACK_OFFSET(viewing_turf.z))
		parent_parallax.remove_relay_from(plane)
	else
		parent_parallax.add_relay_to(plane, BLEND_OVERLAY)
	return ..()

/atom/movable/screen/plane_master/parallax/inside_bounds(mob/relevant)
	if(offset == 0)
		add_relay_to(GET_NEW_PLANE(RENDER_PLANE_GAME, 0))
		is_outside_bounds = FALSE
		return
	// Always readd, just in case we lost it
	var/atom/movable/screen/plane_master/parent_parallax = home.our_hud.get_plane_master(PLANE_SPACE_PARALLAX)
	parent_parallax.add_relay_to(plane, BLEND_OVERLAY)
	return ..()

/atom/movable/screen/plane_master/gravpulse
	name = "Gravpulse"
	documentation = "Ok so this one's fun. Basically, we want to be able to distort the game plane when a grav annom is around.\
		<br>So we draw the pattern we want to use to this plane, and it's then used as a render target by a distortion filter on the game plane.\
		<br>Note the blend mode and lack of relay targets. This plane exists only to distort, it's never rendered anywhere."
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = GRAVITY_PULSE_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_ADD
	render_target = GRAVITY_PULSE_RENDER_TARGET
	render_relay_planes = list()

///Contains just the floor
/atom/movable/screen/plane_master/floor
	name = "Floor"
	documentation = "The well, floor. This is mostly used as a sorting mechanism, but it also lets us create a \"border\" around the game world plane, so its drop shadow will actually work."
	plane = FLOOR_PLANE
	render_relay_planes = list(RENDER_PLANE_GAME, EMISSIVE_MASK_PLANE)

/atom/movable/screen/plane_master/wall
	name = "Wall"
	documentation = "Holds all walls. We render this onto the game world. Separate so we can use this + space and floor planes as a guide for where byond blackness is NOT."
	plane = WALL_PLANE
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD, EMISSIVE_MASK_PLANE)

/atom/movable/screen/plane_master/game
	name = "Lower game world"
	documentation = "Exists mostly because of FOV shit. Basically, if you've just got a normal not ABOVE fov thing, and you don't want it masked, stick it here yeah?"
	plane = GAME_PLANE
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)

/atom/movable/screen/plane_master/game_world_fov_hidden
	name = "lower game world fov hidden"
	documentation = "If you want something to be hidden by fov, stick it on this plane. We're masked by the fov blocker plane, so the items on us can actually well, disappear."
	plane = GAME_PLANE_FOV_HIDDEN
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)

/atom/movable/screen/plane_master/game_world_fov_hidden/Initialize(mapload)
	. = ..()
	add_filter("vision_cone", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(FIELD_OF_VISION_BLOCKER_RENDER_TARGET, offset), flags = MASK_INVERSE))

/atom/movable/screen/plane_master/field_of_vision_blocker
	name = "Field of vision blocker"
	documentation = "This is one of those planes that's only used as a filter. It masks out things that want to be hidden by fov.\
		<br>Literally just contains FOV images, or masks."
	plane = FIELD_OF_VISION_BLOCKER_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_target = FIELD_OF_VISION_BLOCKER_RENDER_TARGET
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_planes = list()
	// We do NOT allow offsetting, because there's no case where you would want to block only one layer, at least currently
	allows_offsetting = FALSE
	start_hidden = TRUE
	// We mark as multiz_scaled FALSE so transforms don't effect us, and we draw to the planes below us as if they were us.
	// This is safe because we will ALWAYS be on the top z layer, so it DON'T MATTER
	multiz_scaled = FALSE

/atom/movable/screen/plane_master/field_of_vision_blocker/Initialize(mapload, datum/plane_master_group/home, offset)
	. = ..()
	mirror_parent_hidden()

/atom/movable/screen/plane_master/game_world_upper
	name = "Upper game world"
	documentation = "Ok so fov is kinda fucky, because planes in byond serve both as effect groupings and as rendering orderers. Since that's true, we need a plane that we can stick stuff that draws above fov blocked stuff on."
	plane = GAME_PLANE_UPPER
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)

/atom/movable/screen/plane_master/wall_upper
	name = "Upper wall"
	documentation = "There are some walls that want to render above most things (mostly minerals since they shift over.\
		<br>We draw them to their own plane so we can hijack them for our emissive mask stuff"
	plane = WALL_PLANE_UPPER
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD, EMISSIVE_MASK_PLANE)

/atom/movable/screen/plane_master/game_world_upper_fov_hidden
	name = "Upper game world fov hidden"
	documentation = "Just as we need a place to draw things \"above\" the hidden fov plane, we also need to be able to hide stuff that draws over the upper game plane."
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)

/atom/movable/screen/plane_master/game_world_upper_fov_hidden/Initialize()
	. = ..()
	// Dupe of the other hidden plane
	add_filter("vision_cone", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(FIELD_OF_VISION_BLOCKER_RENDER_TARGET, offset), flags = MASK_INVERSE))

/atom/movable/screen/plane_master/seethrough
	name = "Seethrough"
	documentation = "Holds the seethrough versions (done using image overrides) of large objects. Mouse transparent, so you can click through them."
	plane = SEETHROUGH_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)
	start_hidden = TRUE

/atom/movable/screen/plane_master/game_world_above
	name = "Above game world"
	documentation = "We need a place that's unmasked by fov that also draws above the upper game world fov hidden plane. I told you fov was hacky man."
	plane = ABOVE_GAME_PLANE
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)

/**
 * Plane master that byond will by default draw to
 * Shouldn't be used, exists to prevent people using plane 0
 * NOTE: If we used SEE_BLACKNESS on a map format that wasn't SIDE_MAP, this is where its darkness would land
 * This would allow us to control it and do fun things. But we can't because side map doesn't support it, so this is just a stub
 */
/atom/movable/screen/plane_master/default
	name = "Default"
	documentation = "This is quite fiddly, so bear with me. By default (in byond) everything in the game is rendered onto plane 0. It's the default plane. \
		<br>But, because we've moved everything we control off plane 0, all that's left is stuff byond internally renders. \
		<br>What I'd like to do with this is capture byond blackness by giving mobs the SEE_BLACKNESS sight flag. \
		<br>But we CAN'T because SEE_BLACKNESS does not work with our rendering format. So I just eat it I guess"
	plane = DEFAULT_PLANE
	multiz_scaled = FALSE
	start_hidden = TRUE // Doesn't DO anything, exists to hold this place

/atom/movable/screen/plane_master/area
	name = "Area"
	documentation = "Holds the areas themselves, which ends up meaning it holds any overlays/effects we apply to areas. NOT snow or rad storms, those go on above lighting"
	plane = AREA_PLANE

/atom/movable/screen/plane_master/massive_obj
	name = "Massive object"
	documentation = "Huge objects need to render above everything else on the game plane, otherwise they'd well, get clipped and look not that huge. This does that."
	plane = MASSIVE_OBJ_PLANE

/atom/movable/screen/plane_master/point
	name = "Point"
	documentation = "I mean like, what do you want me to say? Points draw over pretty much everything else, so they get their own plane. Remember we layer render relays to draw planes in their proper order on render plates."
	plane = POINT_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

///Contains all turf lighting
/atom/movable/screen/plane_master/turf_lighting
	name = "Turf Lighting"
	documentation = "Contains all lighting drawn to turfs. Not so complex, draws directly onto the lighting plate."
	plane = LIGHTING_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_LIGHTING)
	blend_mode_override = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	critical = PLANE_CRITICAL_DISPLAY

/// This will not work through multiz, because of a byond bug with BLEND_MULTIPLY
/// Bug report is up, waiting on a fix
/atom/movable/screen/plane_master/o_light_visual
	name = "Overlight light visual"
	documentation = "Holds overlay lighting objects, or the sort of lighting that's a well, overlay stuck to something.\
		<br>Exists because lighting updating is really slow, and movement needs to feel smooth.\
		<br>We draw to the game plane, and mask out space for ourselves on the lighting plane so any color we have has the chance to display."
	plane = O_LIGHTING_VISUAL_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_target = O_LIGHTING_VISUAL_RENDER_TARGET
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_MULTIPLY
	critical = PLANE_CRITICAL_DISPLAY

/atom/movable/screen/plane_master/above_lighting
	name = "Above lighting"
	plane = ABOVE_LIGHTING_PLANE
	documentation = "Anything on the game plane that needs a space to draw on that will be above the lighting plane.\
		<br>Mostly little alerts and effects, also sometimes contains things that are meant to look as if they glow."

/**
 * Handles emissive overlays and emissive blockers.
 */
/atom/movable/screen/plane_master/emissive
	name = "Emissive"
	documentation = "This system works by exploiting BYONDs color matrix filter to use layers to handle emissive blockers.\
		<br>Emissive overlays are pasted with an atom color that converts them to be entirely some specific color.\
		<br>Emissive blockers are pasted with an atom color that converts them to be entirely some different color.\
		<br>Emissive overlays and emissive blockers are put onto the same plane (This one).\
		<br>The layers for the emissive overlays and emissive blockers cause them to mask eachother similar to normal BYOND objects.\
		<br>A color matrix filter is applied to the emissive plane to mask out anything that isn't whatever the emissive color is.\
		<br>This is then used to alpha mask the lighting plane."
	plane = EMISSIVE_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = EMISSIVE_RENDER_TARGET
	render_relay_planes = list()
	critical = PLANE_CRITICAL_DISPLAY

/atom/movable/screen/plane_master/emissive/Initialize(mapload)
	. = ..()
	add_filter("emissive_mask", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(EMISSIVE_MASK_RENDER_TARGET, offset)))
	add_filter("em_block_masking", 2, color_matrix_filter(GLOB.em_mask_matrix))

/atom/movable/screen/plane_master/pipecrawl
	name = "Pipecrawl"
	documentation = "Holds pipecrawl images generated during well, pipecrawling.\
		<br>Has a few effects and a funky color matrix designed to make things a bit more visually readable."
	plane = PIPECRAWL_IMAGES_PLANE
	start_hidden = TRUE

/atom/movable/screen/plane_master/pipecrawl/Initialize(mapload)
	. = ..()
	// Makes everything on this plane slightly brighter
	// Has a nice effect, makes thing stand out
	color = list(1.2,0,0,0, 0,1.2,0,0, 0,0,1.2,0, 0,0,0,1, 0,0,0,0)
	// This serves a similar purpose, I want the pipes to pop
	add_filter("pipe_dropshadow", 1, drop_shadow_filter(x = -1, y= -1, size = 1, color = "#0000007A"))
	mirror_parent_hidden()

/atom/movable/screen/plane_master/camera_static
	name = "Camera static"
	documentation = "Holds camera static images. Usually only visible to people who can well, see static.\
		<br>We use images rather then vis contents because they're lighter on maptick, and maptick sucks butt."
	plane = CAMERA_STATIC_PLANE
	start_hidden = TRUE

/atom/movable/screen/plane_master/camera_static/show_to(mob/mymob)
	// If we aren't an AI, we have no need for this plane master (most of the time, ai eyes are weird and annoying)
	if(force_hidden && isAI(mymob))
		unhide_plane(mymob)
	. = ..()
	if(!.)
		return
	if(isAI(mymob))
		return
	return FALSE

/atom/movable/screen/plane_master/high_game
	name = "High Game"
	documentation = "Holds anything that wants to be displayed above the rest of the game plane, and doesn't want to be clickable. \
		<br>This includes atmos debug overlays, blind sound images, and mining scanners. \
		<br>Really only exists for its layering potential, we don't use this for any vfx"
	plane = HIGH_GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/ghost
	name = "Ghost"
	documentation = "Ghosts draw here, so they don't get mixed up in the visuals of the game world. Note, this is not not how we HIDE ghosts from people, that's done with invisible and see_invisible."
	plane = GHOST_PLANE
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/fullscreen
	name = "Fullscreen"
	documentation = "Holds anything that applies to or above the full screen. \
		<br>Note, it's still rendered underneath hud objects, but this lets us control the order that things like death/damage effects render in."
	plane = FULLSCREEN_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	allows_offsetting = FALSE

/atom/movable/screen/plane_master/runechat
	name = "Runechat"
	documentation = "Holds runechat images, that text that pops up when someone say something. Uses a dropshadow to well, look nice."
	plane = RUNECHAT_PLANE
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/runechat/show_to(mob/mymob)
	. = ..()
	if(!.)
		return
	remove_filter("AO")
	if(istype(mymob) && mymob.client?.prefs?.read_preference(/datum/preference/toggle/ambient_occlusion))
		add_filter("AO", 1, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#04080FAA"))

/atom/movable/screen/plane_master/balloon_chat
	name = "Balloon chat"
	documentation = "Holds ballon chat images, those little text bars that pop up for a second when you do some things. NOT runechat."
	plane = BALLOON_CHAT_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/hud
	name = "HUD"
	documentation = "Contains anything that want to be rendered on the hud. Typically is just screen elements."
	plane = HUD_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	allows_offsetting = FALSE

/atom/movable/screen/plane_master/above_hud
	name = "Above HUD"
	documentation = "Anything that wants to be drawn ABOVE the rest of the hud. Typically close buttons and other elements that need to be always visible. Think preventing draggable action button memes."
	plane = ABOVE_HUD_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	allows_offsetting = FALSE

/atom/movable/screen/plane_master/splashscreen
	name = "Splashscreen"
	documentation = "Cinematics and the splash screen."
	plane = SPLASHSCREEN_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	allows_offsetting = FALSE

/atom/movable/screen/plane_master/escape_menu
	name = "Escape Menu"
	documentation = "Anything relating to the escape menu."
	plane = ESCAPE_MENU_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_relay_planes = list(RENDER_PLANE_MASTER)
	allows_offsetting = FALSE
