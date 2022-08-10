// I hate this place
INITIALIZE_IMMEDIATE(/atom/movable/screen/plane_master)
/atom/movable/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
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
	/// Whether this plane should get a render target automatically generated
	var/generate_render_target = TRUE
	/// blend mode to apply to the render relay in case you dont want to use the plane_masters blend_mode
	var/blend_mode_override
	/// list of current relays this plane is utilizing to render
	var/list/atom/movable/render_plane_relay/relays = list()
	/// if render relays have already be generated
	var/relays_generated = FALSE

/atom/movable/screen/plane_master/Initialize(mapload, datum/plane_master_group/home, offset = 0)
	src.offset = offset
	true_alpha = alpha
	real_plane = plane

	set_home(home)
	update_offset()
	if(!documentation && !(istype(src, /atom/movable/screen/plane_master) || istype(src, /atom/movable/screen/plane_master/rendering_plate)))
		stack_trace("Plane master created without a description. Document how your thing works so people will know in future, and we can display it in the debug menu")
	return ..()

/atom/movable/screen/plane_master/Destroy()
	if(home)
		// NOTE! We do not clear ourselves from client screens
		// We relay on whoever qdel'd us to reset our hud, and properly purge us
		home.plane_masters -= "[plane]"
		home = null
	. = ..()
	QDEL_LIST(relays)

/// Sets the plane group that owns us, it also determines what screen we render to
/atom/movable/screen/plane_master/proc/set_home(datum/plane_master_group/home)
	if(!istype(home, /datum/plane_master_group))
		qdel(src)
		return
	src.home = home
	if(home.map)
		screen_loc = "[home.map]:[screen_loc]"
		assigned_map = home.map

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
/atom/movable/screen/plane_master/proc/show_to(mob/mymob)
	SHOULD_CALL_PARENT(TRUE)
	if(length(render_relay_planes))
		relay_render_to_plane(mymob)

/// Hides a plane master from the passeed in mob
/// Do your effect cleanup here
/atom/movable/screen/plane_master/proc/hide_from(mob/oldmob)
	var/client/their_client = oldmob.client
	if(!their_client)
		return
	their_client.screen -= src
	their_client.screen -= relays

/atom/movable/screen/plane_master/parallax_white
	name = "Parallax whitifier"
	documentation = "Essentially a backdrop for the parallax plane. We're rendered just below it, so we'll be multiplied by its well, parallax.\
		<br>If you want something to look as if it has parallax on it, draw it to this plane."
	plane = PLANE_SPACE

///Contains space parallax
/atom/movable/screen/plane_master/parallax
	name = "Parallax"
	documentation = "Contains parallax, or to be more exact the screen objects that hold parallax.\
		<br>Note the BLEND_MULTIPLY. The trick here is how low our plane value is. Because of that, we draw below almost everything in the game.\
		<br>We abuse this to ensure we multiply against the Parallax whitifier plane, or space's plane. It's set to full white, so when you do the multiply you just get parallax out where it well, makes sense to be.\
		<br>Also notice that the parent parallax plane is mirrored down to all children. We want to support viewing parallax across all z levels at once."
	plane = PLANE_SPACE_PARALLAX
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/gravpulse
	name = "Gravpulse"
	documentation = "Ok so this one's fun. Basically, we want to be able to distort the game plane when a grav annom is around.\
		<br>So we draw the pattern we want to use to this plane, and it's then used as a render target by a distortion filter on the game plane.\
		<br>Note the blend mode and lack of relay targets. This plane exists only to distort, it's never rendered anywhere."
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = GRAVITY_PULSE_PLANE
	blend_mode = BLEND_ADD
	render_target = GRAVITY_PULSE_RENDER_TARGET
	render_relay_planes = list()

/atom/movable/screen/plane_master/parallax/Initialize(mapload, datum/plane_master_group/home, offset)
	. = ..()
	if(offset != 0)
		// You aren't the source? don't change yourself
		return
	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, .proc/on_offset_increase)
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

///For any transparent multi-z tiles we want to render
/atom/movable/screen/plane_master/transparent
	name = "Transparent"
	documentation = "The master rendering plate from the offset below ours will be mirrored onto this plane. That way we achive a \"stack\" effect."
	plane = TRANSPARENT_FLOOR_PLANE
	appearance_flags = PLANE_MASTER

/atom/movable/screen/plane_master/openspace
	name = "Open space"
	documentation = "The plane of JUST openspace turfs. We give ourselves a dropshadow border, so people can see where floor ends and underfloor begins."
	plane = OPENSPACE_PLANE
	appearance_flags = PLANE_MASTER

/atom/movable/screen/plane_master/openspace/Initialize(mapload)
	. = ..()
	add_filter("first_stage_openspace", 1, drop_shadow_filter(color = "#04080FAA", size = -10))
	add_filter("second_stage_openspace", 2, drop_shadow_filter(color = "#04080FAA", size = -15))
	add_filter("third_stage_openspace", 3, drop_shadow_filter(color = "#04080FAA", size = -20))

///Things rendered on "openspace"; holes in multi-z
///This applies that shadow that openspace tiles get
/atom/movable/screen/plane_master/openspace_backdrop
	name = "Open space backdrop"
	documentation = "Contains the little patches of darkess, we slide this between the upper and lower turfs to give a distance effect."
	plane = OPENSPACE_BACKDROP_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_MULTIPLY
	alpha = 255

///Contains just the floor
/atom/movable/screen/plane_master/floor
	name = "Floor"
	documentation = "The well, floor. This is mostly used as a sorting mechanism, but it also lets us create a \"border\" around the game world plane, so its drop shadow will actually work."
	plane = FLOOR_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

///Contains most things in the game world
/atom/movable/screen/plane_master/game_world
	name = "Game world"
	documentation = "Contains most of the objects in the world. Mobs, machines, etc. Note the drop shadow, it gives a very nice depth effect."
	plane = GAME_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/game_world/show_to(mob/mymob)
	. = ..()
	remove_filter("AO")
	if(istype(mymob) && mymob.client?.prefs?.read_preference(/datum/preference/toggle/ambient_occlusion))
		add_filter("AO", 1, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#04080FAA"))

/atom/movable/screen/plane_master/game_world_fov_hidden
	name = "Game world fov hidden"
	documentation = "If you want something to be hidden by fov, stick it on this plane. We're masked by the fov blocker plane, so the items on us can actually well, disappear."
	plane = GAME_PLANE_FOV_HIDDEN
	render_relay_planes = list(GAME_PLANE)
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/game_world_fov_hidden/Initialize()
	. = ..()
	add_filter("vision_cone", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(FIELD_OF_VISION_BLOCKER_RENDER_TARGET, offset), flags = MASK_INVERSE))

/atom/movable/screen/plane_master/field_of_vision_blocker
	name = "Field of vision blocker"
	documentation = "This is one of those planes that's only used as a filter. It masks out things that want to be hidden by fov.\
		<br>Literally just contains FOV images, or masks."
	plane = FIELD_OF_VISION_BLOCKER_PLANE
	render_target = FIELD_OF_VISION_BLOCKER_RENDER_TARGET
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_planes = list()
	// We do NOT allow offsetting, because there's no case where you would want to block only one layer, at least currently
	allows_offsetting = FALSE

/atom/movable/screen/plane_master/game_world_upper
	name = "Upper game world"
	documentation = "Ok so fov is kinda fucky, because planes in byond serve both as effect groupings and as rendering orderers. Since that's true, we need a plane that we can stick stuff that draws above fov blocked stuff on."
	plane = GAME_PLANE_UPPER
	render_relay_planes = list(GAME_PLANE)
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/game_world_upper_fov_hidden
	name = "Upper game world fov hidden"
	documentation = "Just as we need a place to draw things \"above\" the hidden fov plane, we also need to be able to hide stuff that draws over the upper game plane."
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	render_relay_planes = list(GAME_PLANE_FOV_HIDDEN)
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/game_world_above
	name = "Above game world"
	documentation = "We need a place that's unmasked by fov that also draws above the upper game world fov hidden plane. I told you fov was hacky man."
	plane = ABOVE_GAME_PLANE
	render_relay_planes = list(GAME_PLANE)
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/**
 * Plane master handling byond internal blackness
 * vars are set as to replicate behavior when rendering to other planes
 * do not touch this unless you know what you are doing
 */
/atom/movable/screen/plane_master/blackness
	name = "Darkness"
	documentation = "This is quite fiddly, so bear with me. By default (in byond) everything in the game is rendered onto plane 0. It's the default plane. \
		<br>But, because we've moved everything we control off plane 0, all that's left is stuff byond internally renders. \
		<br>What we're doing here is using plane 0 to capture \"Blackness\", or the mask that hides tiles. Note, this only works if our mob has the SEE_PIXELS or SEE_BLACKNESS sight flags.\
		<br>We relay this plane master (on plane 0) down to other copies of itself, depending on the layer your mob is on at the moment.\
		<br>Of note: plane master blackness, and the blackness that comes from having nothing to display look similar, but are not the same thing,\
		mind yourself when you're working with this plane, you might have accidentially been trying to work with the wrong thing."
	plane = BLACKNESS_PLANE
	// Note: we don't set this to blend multiply because it just dies when its alpha is modified, since there's no backdrop I think

/atom/movable/screen/plane_master/blackness/show_to(mob/mymob)
	. = ..()
	if(offset != 0)
		// You aren't the source? don't change yourself
		return
	RegisterSignal(mymob, COMSIG_MOB_SIGHT_CHANGE, .proc/handle_sight_value)
	handle_sight_value(mymob, mymob.sight, 0)
	var/datum/hud/hud = home.our_hud
	if(hud)
		RegisterSignal(hud, COMSIG_HUD_OFFSET_CHANGED, .proc/on_offset_change)
	offset_change(0, hud.current_plane_offset)

/atom/movable/screen/plane_master/blackness/hide_from(mob/oldmob)
	if(offset != 0)
		return
	UnregisterSignal(oldmob, COMSIG_MOB_SIGHT_CHANGE)
	var/datum/hud/hud = home.our_hud
	if(hud)
		UnregisterSignal(hud, COMSIG_HUD_OFFSET_CHANGED, .proc/on_offset_change)

/// Reacts to some new plane master value
/atom/movable/screen/plane_master/blackness/proc/handle_sight_value(datum/source, new_sight, old_sight)
	SIGNAL_HANDLER
	// Tryin to set a sight flag that cuts blackness eh?
	if(new_sight & BLACKNESS_CUTTING)
		// Better set alpha then, so it'll actually work
		// We just get the one because there is only one blackness PM, it's just mirrored around
		disable_alpha()
	else
		enable_alpha()

/atom/movable/screen/plane_master/blackness/proc/on_offset_change(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	offset_change(old_offset, new_offset)

/atom/movable/screen/plane_master/blackness/proc/offset_change(old_offset, new_offset)
	// Basically, the rule here is the blackness we harvest from the mob using the SEE_BLACKNESS flag will be relayed to the darkness
	// Plane that we're actually on
	if(old_offset != 0) // If our old target wasn't just ourselves
		remove_relay_from(GET_NEW_PLANE(plane, old_offset))

	if(new_offset != 0)
		add_relay_to(GET_NEW_PLANE(plane, new_offset))

/atom/movable/screen/plane_master/area
	name = "Area"
	documentation = "Holds the areas themselves, which ends up meaning it holds any overlays/effects we apply to areas. NOT snow or rad storms, those go on above lighting"
	plane = AREA_PLANE

/atom/movable/screen/plane_master/massive_obj
	name = "Massive object"
	documentation = "Huge objects need to render above everything else on the game plane, otherwise they'd well, get clipped and look not that huge. This does that."
	plane = MASSIVE_OBJ_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/point
	name = "Point"
	documentation = "I mean like, what do you want me to say? Points draw over pretty much everything else, so they get their own plane. Remember we layer render relays to draw planes in their proper order on render plates."
	plane = POINT_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

///Contains all lighting objects
/atom/movable/screen/plane_master/lighting
	name = "Lighting"
	documentation = "Anything on this plane will be <b>multiplied</b> with the plane it's rendered onto (typically the game plane).\
		<br>That's how lighting functions at base. Because it uses BLEND_MULTIPLY and occasionally color matrixes, it needs a backdrop of blackness.\
		<br>See <a href=\"https://secure.byond.com/forum/?post=2141928\">This byond post</a>\
		<br>Lemme see uh, we're masked by the emissive plane so it can actually function (IE: make things glow in the dark).\
		<br>We're also masked by the overlay lighting plane, which contains all the movable lights in the game. It draws to us and also the game plane.\
		<br>Masks us out so it has the breathing room to apply its effect.\
		<br>Oh and we quite often have our alpha changed to achive night vision effects, or things of that sort."
	plane = LIGHTING_PLANE
	blend_mode_override = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/lighting/show_to(mob/mymob)
	. = ..()
	// This applies a backdrop to our lighting plane
	// Why do plane masters need a backdrop sometimes? Read https://secure.byond.com/forum/?post=2141928
	// Basically, we need something to brighten
	// unlit is perhaps less needed rn, it exists to provide a fullbright for things that can't see the lighting plane
	// but we don't actually use invisibility to hide the lighting plane anymore, so it's pointless
	mymob.overlay_fullscreen("lighting_backdrop_lit", /atom/movable/screen/fullscreen/lighting_backdrop/lit)
	mymob.overlay_fullscreen("lighting_backdrop_unlit", /atom/movable/screen/fullscreen/lighting_backdrop/unlit)

	// Sorry, this is a bit annoying
	// Basically, we only want the lighting plane we can actually see to attempt to render
	// If we don't our lower plane gets totally overriden by the black void of the upper plane
	var/datum/hud/hud = home.our_hud
	if(hud)
		RegisterSignal(hud, COMSIG_HUD_OFFSET_CHANGED, .proc/on_offset_change)
	offset_change(hud.current_plane_offset)

/atom/movable/screen/plane_master/lighting/hide_from(mob/oldmob)
	oldmob.clear_fullscreen("lighting_backdrop_lit")
	oldmob.clear_fullscreen("lighting_backdrop_unlit")
	var/datum/hud/hud = home.our_hud
	if(hud)
		UnregisterSignal(hud, COMSIG_HUD_OFFSET_CHANGED, .proc/on_offset_change)

/atom/movable/screen/plane_master/lighting/proc/on_offset_change(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	offset_change(new_offset)

/atom/movable/screen/plane_master/lighting/proc/offset_change(mob_offset)
	// Offsets stack down remember. This implies that we're above the mob's view plane, and shouldn't render
	if(offset < mob_offset)
		disable_alpha()
	else
		enable_alpha()

/*!
 * This system works by exploiting BYONDs color matrix filter to use layers to handle emissive blockers.
 *
 * Emissive overlays are pasted with an atom color that converts them to be entirely some specific color.
 * Emissive blockers are pasted with an atom color that converts them to be entirely some different color.
 * Emissive overlays and emissive blockers are put onto the same plane.
 * The layers for the emissive overlays and emissive blockers cause them to mask eachother similar to normal BYOND objects.
 * A color matrix filter is applied to the emissive plane to mask out anything that isn't whatever the emissive color is.
 * This is then used to alpha mask the lighting plane.
 */
/atom/movable/screen/plane_master/lighting/Initialize(mapload)
	. = ..()
	add_filter("emissives", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(EMISSIVE_RENDER_TARGET, offset), flags = MASK_INVERSE))
	add_filter("object_lighting", 2, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(O_LIGHTING_VISUAL_RENDER_TARGET, offset), flags = MASK_INVERSE))


/atom/movable/screen/plane_master/o_light_visual
	name = "Overlight light visual"
	documentation = "Holds overlay lighting objects, or the sort of lighting that's a well, overlay stuck to something.\
		<br>Exists because lighting updating is really slow, and movement needs to feel smooth.\
		<br>We draw to the game plane, and mask out space for ourselves on the lighting plane so any color we have has the chance to display."
	plane = O_LIGHTING_VISUAL_PLANE
	render_target = O_LIGHTING_VISUAL_RENDER_TARGET
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_MULTIPLY

/atom/movable/screen/plane_master/above_lighting
	name = "Above lighting"
	plane = ABOVE_LIGHTING_PLANE
	documentation = "Anything on the game plane that needs a space to draw on that will be above the lighting plane.\
		<br>Mostly little alerts and effects, also sometimes contains things that are meant to look as if they glow."
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

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
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = EMISSIVE_RENDER_TARGET
	render_relay_planes = list()

/atom/movable/screen/plane_master/emissive/Initialize(mapload)
	. = ..()
	add_filter("em_block_masking", 1, color_matrix_filter(GLOB.em_mask_matrix))

/atom/movable/screen/plane_master/pipecrawl
	name = "Pipecrawl"
	documentation = "Holds pipecrawl images generated during well, pipecrawling.\
		<br>Has a few effects and a funky color matrix designed to make things a bit more visually readable."
	plane = PIPECRAWL_IMAGES_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/pipecrawl/Initialize(mapload)
	. = ..()
	// Makes everything on this plane slightly brighter
	// Has a nice effect, makes thing stand out
	color = list(1.2,0,0,0, 0,1.2,0,0, 0,0,1.2,0, 0,0,0,1, 0,0,0,0)
	// This serves a similar purpose, I want the pipes to pop
	add_filter("pipe_dropshadow", 1, drop_shadow_filter(x = -1, y= -1, size = 1, color = "#0000007A"))

/atom/movable/screen/plane_master/camera_static
	name = "Camera static"
	documentation = "Holds camera static images. Usually only visible to people who can well, see static.\
		<br>We use images rather then vis contents because they're lighter on maptick, and maptick sucks butt."
	plane = CAMERA_STATIC_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/excited_turfs
	name = "Atmos excited turfs"
	documentation = "Holds excited turf visualization images. Entirely a debug tool.\
		<br>Images are created at init, and stuck in a turf's viscontents if a global debug toggle is enabled.\
		<br>They're then displayed to the user by adding them to its images list, and toggling the plane's alpha."
	plane = ATMOS_GROUP_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	alpha = 0

/atom/movable/screen/plane_master/ghost
	name = "Ghost"
	documentation = "Ghosts draw here, so they don't get mixed up in the visuals of the game world. Note, this is not not how we HIDE ghosts from people, that's done with invisible and see_invisible."
	plane = GHOST_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/fullscreen
	name = "Fullscreen alert"
	documentation = "Holds anything that applies to or above the full screen. \
		<br>Note, it's still rendered underneath hud objects, but this lets us control the order that things like death/damage effects render in.\
		<br>Also contains some effects that it maybe shouldn't, like the mineral scanner and fov blindness effects."
	plane = FULLSCREEN_PLANE
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/runechat
	name = "Runechat"
	documentation = "Holds runechat images, that text that pops up when someone say something. Uses a dropshadow to well, look nice."
	plane = RUNECHAT_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/runechat/show_to(mob/mymob)
	. = ..()
	remove_filter("AO")
	if(istype(mymob) && mymob.client?.prefs?.read_preference(/datum/preference/toggle/ambient_occlusion))
		add_filter("AO", 1, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#04080FAA"))

/atom/movable/screen/plane_master/balloon_chat
	name = "Balloon chat"
	documentation = "Holds ballon chat images, those little text bars that pop up for a second when you do some things. NOT runechat."
	plane = BALLOON_CHAT_PLANE
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/hud
	name = "HUD"
	documentation = "Contains anything that want to be rendered on the hud. Typically is just screen elements."
	plane = HUD_PLANE
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	allows_offsetting = FALSE

/atom/movable/screen/plane_master/above_hud
	name = "Above HUD"
	documentation = "Anything that wants to be drawn ABOVE the rest of the hud. Typically close buttons and other elements that need to be always visible. Think preventing draggable action button memes."
	plane = ABOVE_HUD_PLANE
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	allows_offsetting = FALSE

/atom/movable/screen/plane_master/splashscreen
	name = "Splashscreen"
	documentation = "Anything that's drawn above LITERALLY everything else. Think cinimatics and the well, spashscreen."
	plane = SPLASHSCREEN_PLANE
	render_relay_planes = list(RENDER_PLANE_NON_GAME)
	allows_offsetting = FALSE
