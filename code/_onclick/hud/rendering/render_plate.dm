/*!
 * Custom rendering solution to allow for advanced effects
 * We (ab)use plane masters and render source/target to cheaply render 2+ planes as 1
 * if you want to read more read the _render_readme.md
 */


/**
 * Render relay object assigned to a plane master to be able to relay its render onto other planes that are not its own
 */
/atom/movable/render_plane_relay
	screen_loc = "CENTER"
	layer = -1
	plane = 0
	appearance_flags = PASS_MOUSE | NO_CLIENT_COLOR | KEEP_TOGETHER
	/// If we render into a critical plane master, or not
	var/critical_target = FALSE

/**
 * ## Rendering plate
 *
 * Acts like a plane master, but for plane masters
 * Renders other planes onto this plane, through the use of render objects
 * Any effects applied onto this plane will act on the unified plane
 * IE a bulge filter will apply as if the world was one object
 * remember that once planes are unified on a render plate you cant change the layering of them!
 */
/atom/movable/screen/plane_master/rendering_plate
	name = "Default rendering plate"
	multiz_scaled = FALSE

///this plate renders the final screen to show to the player
/atom/movable/screen/plane_master/rendering_plate/master
	name = "Master rendering plate"
	documentation = "The endpoint of all plane masters, you can think of this as the final \"view\" we draw.\
		<br>If offset is not 0 this will be drawn to the transparent plane of the floor above, but otherwise this is drawn to nothing, or shown to the player."
	plane = RENDER_PLANE_MASTER
	render_relay_planes = list()

/atom/movable/screen/plane_master/rendering_plate/master/show_to(mob/mymob)
	. = ..()
	if(!.)
		return
	if(offset == 0)
		return
	// Non 0 offset render plates will relay up to the transparent plane above them, assuming they're not on the same z level as their target of course
	var/datum/hud/hud = home.our_hud
	// show_to can be called twice successfully with no hide_from call. Ensure no runtimes off the registers from this
	if(hud)
		RegisterSignal(hud, COMSIG_HUD_OFFSET_CHANGED, PROC_REF(on_offset_change), override = TRUE)
	offset_change(hud?.current_plane_offset || 0)

/atom/movable/screen/plane_master/rendering_plate/master/hide_from(mob/oldmob)
	. = ..()
	if(offset == 0)
		return
	var/datum/hud/hud = home.our_hud
	if(hud)
		UnregisterSignal(hud, COMSIG_HUD_OFFSET_CHANGED, PROC_REF(on_offset_change))

/atom/movable/screen/plane_master/rendering_plate/master/proc/on_offset_change(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	offset_change(new_offset)

/atom/movable/screen/plane_master/rendering_plate/master/proc/offset_change(new_offset)
	if(new_offset == offset) // If we're on our own z layer, relay to nothing, just draw
		remove_relay_from(GET_NEW_PLANE(RENDER_PLANE_TRANSPARENT, offset - 1))
	else // Otherwise, regenerate the relay
		add_relay_to(GET_NEW_PLANE(RENDER_PLANE_TRANSPARENT, offset - 1))

///renders general in charachter game objects
/atom/movable/screen/plane_master/rendering_plate/game_plate
	name = "Game rendering plate"
	documentation = "Holds all objects that are ahhh, in character? is maybe the best way to describe it.\
		<br>We apply a displacement effect from the gravity pulse plane too, so we can warp the game world.\
		<br>If we have fov enabled we'll relay this onto two different rendering plates to apply fov effects to only a portion. If not, we just draw straight to master"
	plane = RENDER_PLANE_GAME
	render_relay_planes = list(LIT_GAME_RENDER_PLATE)

/atom/movable/screen/plane_master/rendering_plate/game_plate/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	add_relay_to(GET_NEW_PLANE(EMISSIVE_BLOOM_PLATE, offset), blend_override = BLEND_MULTIPLY)
	RegisterSignal(GLOB, SIGNAL_ADDTRAIT(TRAIT_DISTORTION_IN_USE(offset)), PROC_REF(distortion_enabled))
	RegisterSignal(GLOB, SIGNAL_REMOVETRAIT(TRAIT_DISTORTION_IN_USE(offset)), PROC_REF(distortion_disabled))
	if(HAS_TRAIT(GLOB, TRAIT_DISTORTION_IN_USE(offset)))
		distortion_enabled()

/atom/movable/screen/plane_master/rendering_plate/game_plate/proc/distortion_enabled(datum/source)
	SIGNAL_HANDLER
	add_filter("displacer", 1, displacement_map_filter(render_source = OFFSET_RENDER_TARGET(GRAVITY_PULSE_RENDER_TARGET, offset), size = 10))

/atom/movable/screen/plane_master/rendering_plate/game_plate/proc/distortion_disabled(datum/source)
	SIGNAL_HANDLER
	remove_filter("displacer")

/atom/movable/screen/plane_master/rendering_plate/game_plate/show_to(mob/mymob)
	. = ..()
	if(!. || !mymob)
		return .
	RegisterSignal(mymob, SIGNAL_ADDTRAIT(TRAIT_FOV_APPLIED), PROC_REF(fov_enabled), override = TRUE)
	RegisterSignal(mymob, SIGNAL_REMOVETRAIT(TRAIT_FOV_APPLIED), PROC_REF(fov_disabled), override = TRUE)
	if(HAS_TRAIT(mymob, TRAIT_FOV_APPLIED))
		fov_enabled(mymob)
	else
		fov_disabled(mymob)

/atom/movable/screen/plane_master/rendering_plate/game_plate/proc/fov_enabled(mob/source)
	SIGNAL_HANDLER
	add_relay_to(GET_NEW_PLANE(RENDER_PLANE_GAME_UNMASKED, offset))
	add_relay_to(GET_NEW_PLANE(RENDER_PLANE_GAME_MASKED, offset))
	remove_relay_from(GET_NEW_PLANE(LIT_GAME_RENDER_PLATE, offset))

/atom/movable/screen/plane_master/rendering_plate/game_plate/proc/fov_disabled(mob/source)
	SIGNAL_HANDLER
	remove_relay_from(GET_NEW_PLANE(RENDER_PLANE_GAME_UNMASKED, offset))
	remove_relay_from(GET_NEW_PLANE(RENDER_PLANE_GAME_MASKED, offset))
	add_relay_to(GET_NEW_PLANE(LIT_GAME_RENDER_PLATE, offset))

///renders the parts of the plate unmasked by fov
/atom/movable/screen/plane_master/rendering_plate/unmasked_game_plate
	name = "Unmasked Game rendering plate"
	documentation = "Holds the bits of the game plate that aren't impacted by fov.\
		<br>We use an alpha mask to cut out the bits we plan on dealing with elsewhere"
	plane = RENDER_PLANE_GAME_UNMASKED
	render_relay_planes = list(LIT_GAME_RENDER_PLATE)

/atom/movable/screen/plane_master/rendering_plate/unmasked_game_plate/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset)
	. = ..()
	add_filter("fov_handled", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(FIELD_OF_VISION_BLOCKER_RENDER_TARGET, offset), flags = MASK_INVERSE))

/atom/movable/screen/plane_master/rendering_plate/unmasked_game_plate/show_to(mob/mymob)
	. = ..()
	if(!. || !mymob)
		return .
	RegisterSignal(mymob, SIGNAL_ADDTRAIT(TRAIT_FOV_APPLIED), PROC_REF(fov_enabled), override = TRUE)
	RegisterSignal(mymob, SIGNAL_REMOVETRAIT(TRAIT_FOV_APPLIED), PROC_REF(fov_disabled), override = TRUE)
	if(HAS_TRAIT(mymob, TRAIT_FOV_APPLIED))
		fov_enabled(mymob)
	else
		fov_disabled(mymob)

/atom/movable/screen/plane_master/rendering_plate/unmasked_game_plate/proc/fov_enabled(mob/source)
	SIGNAL_HANDLER
	if(force_hidden == FALSE)
		return
	unhide_plane(source)

/atom/movable/screen/plane_master/rendering_plate/unmasked_game_plate/proc/fov_disabled(mob/source)
	SIGNAL_HANDLER
	hide_plane(source)

///renders the parts of the plate masked by fov
/atom/movable/screen/plane_master/rendering_plate/masked_game_plate
	name = "FOV Game rendering plate"
	documentation = "Contains the bits of the game plate that are hidden by some form of fov\
		<br>Applies a color matrix to dim and create contrast, alongside a blur. Goal is only half being able to see stuff"
	plane = RENDER_PLANE_GAME_MASKED
	render_relay_planes = list(LIT_GAME_RENDER_PLATE)

/atom/movable/screen/plane_master/rendering_plate/masked_game_plate/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset)
	. = ..()
	add_filter("fov_blur", 1, gauss_blur_filter(1.8))
	add_filter("fov_handled_space", 2, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(FIELD_OF_VISION_BLOCKER_RENDER_TARGET, offset)))
	add_filter("fov_matrix", 3, color_matrix_filter(list(0.5,-0.15,-0.15,0, -0.15,0.5,-0.15,0, -0.15,-0.15,0.5,0, 0,0,0,1, 0,0,0,0)))

/atom/movable/screen/plane_master/rendering_plate/masked_game_plate/show_to(mob/mymob)
	. = ..()
	if(!. || !mymob)
		return .
	RegisterSignal(mymob, SIGNAL_ADDTRAIT(TRAIT_FOV_APPLIED), PROC_REF(fov_enabled), override = TRUE)
	RegisterSignal(mymob, SIGNAL_REMOVETRAIT(TRAIT_FOV_APPLIED), PROC_REF(fov_disabled), override = TRUE)
	if(HAS_TRAIT(mymob, TRAIT_FOV_APPLIED))
		fov_enabled(mymob)
	else
		fov_disabled(mymob)

/atom/movable/screen/plane_master/rendering_plate/masked_game_plate/proc/fov_enabled(mob/source)
	SIGNAL_HANDLER
	if(force_hidden == FALSE)
		return
	unhide_plane(source)

/atom/movable/screen/plane_master/rendering_plate/masked_game_plate/proc/fov_disabled(mob/source)
	SIGNAL_HANDLER
	hide_plane(source)

// Blackness renders weird when you view down openspace, because of transforms and borders and such
// This is a consequence of not using lummy's grouped transparency, but I couldn't get that to work without totally fucking up
// Sight flags, and shooting vis_contents usage to the moon. So we're doin it different.
// If image vis contents worked (it should in 515), and we were ok with a maptick cost (wait for threaded maptick) this could be fixed
/atom/movable/screen/plane_master/rendering_plate/transparent
	name = "Transparent plate"
	documentation = "The master rendering plate from the offset below ours will be mirrored onto this plane. That way we achive a \"stack\" effect.\
		<br>This plane exists to uplayer the master rendering plate to the correct spot in our z layer's rendering order"
	plane = RENDER_PLANE_TRANSPARENT
	appearance_flags = PLANE_MASTER

/atom/movable/screen/plane_master/rendering_plate/transparent/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset)
	. = ..()
	// Don't display us if we're below everything else yeah?
	AddComponent(/datum/component/plane_hide_highest_offset)
	color = list(0.9,0,0,0, 0,0.9,0,0, 0,0,0.9,0, 0,0,0,1, 0,0,0,0)

///Contains most things in the game world
/atom/movable/screen/plane_master/rendering_plate/game_world
	name = "Game world plate"
	documentation = "Contains most of the objects in the world. Mobs, machines, etc. Note the drop shadow, it gives a very nice depth effect."
	plane = RENDER_PLANE_GAME_WORLD
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/rendering_plate/game_world/show_to(mob/mymob)
	. = ..()
	if(!.)
		return
	remove_filter("AO")
	if(istype(mymob) && mymob.canon_client?.prefs?.read_preference(/datum/preference/toggle/ambient_occlusion))
		add_filter("AO", 1, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#04080FAA"))

///Contains all lighting objects
/atom/movable/screen/plane_master/rendering_plate/lighting
	name = "Lighting plate"
	documentation = "Anything on this plane will be <b>multiplied</b> with the plane it's rendered onto (typically the game plane).\
		<br>That's how lighting functions at base. Because it uses BLEND_MULTIPLY and occasionally color matrixes, it needs a backdrop of blackness.\
		<br>See <a href=\"https://secure.byond.com/forum/?post=2141928\">this byond post</a>\
		<br>Lemme see uh, we're masked by the emissive plane so it can actually function (IE: make things glow in the dark).\
		<br>We're also masked by the overlay lighting plane, which contains all the well overlay lights in the game. It draws to us and also the game plane.\
		<br>Masks us out so it has the breathing room to apply its effect.\
		<br>Oh and we quite often have our alpha changed to achive night vision effects, or things of that sort."
	plane = RENDER_PLANE_LIGHTING
	blend_mode_override = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	critical = PLANE_CRITICAL_DISPLAY
	render_relay_planes = list(LIT_GAME_RENDER_PLATE)
	/// A list of light cutoffs we're actively using, (mass, r, g, b) to avoid filter churn
	var/list/light_cutoffs

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
/atom/movable/screen/plane_master/rendering_plate/lighting/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	add_filter("emissives", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(EMISSIVE_RENDER_TARGET, offset), flags = MASK_INVERSE))
	set_light_cutoff(10)

/atom/movable/screen/plane_master/rendering_plate/lighting/show_to(mob/mymob)
	. = ..()
	if(!.)
		return
	// This applies a backdrop to our lighting plane
	// Why do plane masters need a backdrop sometimes? Read https://secure.byond.com/forum/?post=2141928
	// Basically, we need something to brighten
	// unlit is perhaps less needed rn, it exists to provide a fullbright for things that can't see the lighting plane
	// but we don't actually use invisibility to hide the lighting plane anymore, so it's pointless
	var/atom/movable/screen/backdrop = mymob.overlay_fullscreen("lighting_backdrop_lit_[home.key]#[offset]", /atom/movable/screen/fullscreen/lighting_backdrop/lit)
	// Need to make sure they're on our plane, ALL the time. We always need a backdrop
	SET_PLANE_EXPLICIT(backdrop, PLANE_TO_TRUE(backdrop.plane), src)
	backdrop = mymob.overlay_fullscreen("lighting_backdrop_unlit_[home.key]#[offset]", /atom/movable/screen/fullscreen/lighting_backdrop/unlit)
	SET_PLANE_EXPLICIT(backdrop, PLANE_TO_TRUE(backdrop.plane), src)

	// Sorry, this is a bit annoying
	// Basically, we only want the lighting plane we can actually see to attempt to render
	// If we don't our lower plane gets totally overriden by the black void of the upper plane
	var/datum/hud/hud = home.our_hud
	// show_to can be called twice successfully with no hide_from call. Ensure no runtimes off the registers from this
	if(hud)
		RegisterSignal(hud, COMSIG_HUD_OFFSET_CHANGED, PROC_REF(on_offset_change), override = TRUE)
	offset_change(hud?.current_plane_offset || 0)
	set_light_cutoff(mymob.lighting_cutoff, mymob.lighting_color_cutoffs)

/atom/movable/screen/plane_master/rendering_plate/lighting/hide_from(mob/oldmob)
	. = ..()
	oldmob.clear_fullscreen("lighting_backdrop_lit_[home.key]#[offset]")
	oldmob.clear_fullscreen("lighting_backdrop_unlit_[home.key]#[offset]")
	var/datum/hud/hud = home.our_hud
	if(hud)
		UnregisterSignal(hud, COMSIG_HUD_OFFSET_CHANGED, PROC_REF(on_offset_change))

/atom/movable/screen/plane_master/rendering_plate/lighting/proc/on_offset_change(datum/source, old_offset, new_offset)
	SIGNAL_HANDLER
	offset_change(new_offset)

/atom/movable/screen/plane_master/rendering_plate/lighting/proc/offset_change(mob_offset)
	// Offsets stack down remember. This implies that we're above the mob's view plane, and shouldn't render
	if(offset < mob_offset)
		disable_alpha()
	else
		enable_alpha()

/atom/movable/screen/plane_master/rendering_plate/lighting/proc/set_light_cutoff(light_cutoff, list/color_cutoffs)
	var/list/new_cutoffs = list(light_cutoff)
	new_cutoffs += color_cutoffs
	if(new_cutoffs ~= light_cutoffs)
		return

	remove_filter(list("light_cutdown", "light_cutup"))

	var/ratio = light_cutoff/100
	if(!color_cutoffs)
		color_cutoffs = list(0, 0, 0)

	var/red = color_cutoffs[1] / 100
	var/green = color_cutoffs[2] / 100
	var/blue = color_cutoffs[3] / 100
	add_filter("light_cutdown", 3, color_matrix_filter(list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, -(ratio + red),-(ratio+green),-(ratio+blue),0)))
	add_filter("light_cutup", 4, color_matrix_filter(list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, ratio+red,ratio+green,ratio+blue,0)))

/atom/movable/screen/plane_master/rendering_plate/emissive_slate
	name = "Emissive Plate"
	documentation = "This system works by exploiting BYONDs color matrix filter to use layers to handle emissive blockers.\
		<br>Emissive overlays are pasted with an atom color that converts them to be entirely some specific color.\
		<br>Emissive blockers are pasted with an atom color that converts them to be entirely some different color.\
		<br>Emissive overlays and emissive blockers are put onto the same plane (This one).\
		<br>The layers for the emissive overlays and emissive blockers cause them to mask eachother similar to normal BYOND objects.\
		<br>A color matrix filter is applied to the emissive plane to mask out anything that isn't whatever the emissive color is.\
		<br>This is then used to alpha mask the lighting plane."
	plane = EMISSIVE_RENDER_PLATE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = EMISSIVE_RENDER_TARGET
	render_relay_planes = list()
	critical = PLANE_CRITICAL_DISPLAY

/atom/movable/screen/plane_master/rendering_plate/emissive_slate/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset)
	. = ..()
	add_filter("em_block_masking", 2, color_matrix_filter(GLOB.em_mask_matrix))
	if(offset != 0)
		add_relay_to(GET_NEW_PLANE(EMISSIVE_RENDER_PLATE, offset - 1), relay_layer = EMISSIVE_Z_BELOW_LAYER)

/atom/movable/screen/plane_master/rendering_plate/light_mask
	name = "Light Mask"
	documentation = "Any part of this plane that is transparent will be black below it on the game rendering plate.\
		<br>This is done to ensure emissives and overlay lights don't light things up \"through\" the darkness that normally sits at the bottom of the lighting plane.\
		<br>We relay copies of the space, floor and wall planes to it, so we can use them as masks. Then we just boost any existing alpha to 100% and we're done.\
		<br>If we ever switch to a sight setup that shows say, mobs but not floors, we instead mask just overlay lighting and emissives.\
		<br>This avoids dumb seethrough without breaking stuff like thermals."
	plane = LIGHT_MASK_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	// Fullwhite where there's anything, no color otherwise
	color = list(255,255,255,255, 255,255,255,255, 255,255,255,255, 255,255,255,255, 0,0,0,0)
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = LIGHT_MASK_RENDER_TARGET
	// We blend against the game plane, so she's gotta multiply!
	blend_mode = BLEND_MULTIPLY
	render_relay_planes = list(LIT_GAME_RENDER_PLATE)

/atom/movable/screen/plane_master/rendering_plate/light_mask/show_to(mob/mymob)
	. = ..()
	if(!.)
		return

	RegisterSignal(mymob, COMSIG_MOB_SIGHT_CHANGE, PROC_REF(handle_sight), override = TRUE)
	handle_sight(mymob, mymob.sight, NONE)

/atom/movable/screen/plane_master/rendering_plate/light_mask/hide_from(mob/oldmob)
	. = ..()
	var/atom/movable/screen/plane_master/emissive = home.get_plane(GET_NEW_PLANE(EMISSIVE_RENDER_PLATE, offset))
	emissive.remove_filter("lighting_mask")
	remove_relay_from(GET_NEW_PLANE(LIT_GAME_RENDER_PLATE, offset))
	UnregisterSignal(oldmob, COMSIG_MOB_SIGHT_CHANGE)

/atom/movable/screen/plane_master/rendering_plate/light_mask/proc/handle_sight(datum/source, new_sight, old_sight)
	// If we can see something that shows "through" blackness, and we can't see turfs, disable our draw to the game plane
	// And instead mask JUST the overlay lighting plane, since that will look fuckin wrong
	var/atom/movable/screen/plane_master/emissive = home.get_plane(GET_NEW_PLANE(EMISSIVE_RENDER_PLATE, offset))
	if(new_sight & SEE_AVOID_TURF_BLACKNESS && !(new_sight & SEE_TURFS))
		remove_relay_from(GET_NEW_PLANE(LIT_GAME_RENDER_PLATE, offset))
		emissive.add_filter("lighting_mask", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(LIGHT_MASK_RENDER_TARGET, offset)))
	// If we CAN'T see through the black, then draw er down brother!
	else
		emissive.remove_filter("lighting_mask")
		// We max alpha here, so our darkness is actually.. dark
		// Can't do it before cause it fucks with the filter
		add_relay_to(GET_NEW_PLANE(LIT_GAME_RENDER_PLATE, offset), relay_color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,1))

///render plate for OOC stuff like ghosts, hud-screen effects, etc
/atom/movable/screen/plane_master/rendering_plate/non_game
	name = "Non-Game rendering plate"
	documentation = "Renders anything that's out of character. Mostly useful as a converse to the game rendering plate."
	plane = RENDER_PLANE_NON_GAME
	render_relay_planes = list(RENDER_PLANE_MASTER)

/atom/movable/screen/plane_master/rendering_plate/emissive_bloom_mask
	name = "Emissive bloom mask plate"
	documentation = "A holder plate used purely as a way to full-white bloom emissives before applying them as a mask onto the emissive bloom plate."
	plane = EMISSIVE_BLOOM_MASK_PLATE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_planes = list()
	render_target = EMISSIVE_BLOOM_MASK_TARGET
	critical = PLANE_CRITICAL_DISPLAY

/atom/movable/screen/plane_master/rendering_plate/emissive_bloom
	name = "Emissive bloom plate"
	documentation = "Plate used to bloom emissives before adding them onto the overlay lighting plane. We do this by multiplying the game plate\
		onto a fullbright emissive, then alpha masking it by emissive's color to solve the problem of blockers, both alone and covered by emissives."
	plane = EMISSIVE_BLOOM_PLATE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_ADD
	render_relay_planes = list(O_LIGHTING_VISUAL_PLANE)
	critical = PLANE_CRITICAL_DISPLAY

/atom/movable/screen/plane_master/rendering_plate/emissive_bloom/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset)
	. = ..()
	add_filter("emissive_mask", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(EMISSIVE_BLOOM_MASK_TARGET, offset)))
	add_filter("emissive_bloom", 2, bloom_filter(threshold = COLOR_BLACK, size = 2, offset = 1))

/atom/movable/screen/plane_master/rendering_plate/turf_lighting
	name = "Turf lighting post-processing plate"
	documentation = "Used by overlay lighting, and possibly over plates, to mask out turf lighting."
	plane = TURF_LIGHTING_PLATE
	render_relay_planes = list(RENDER_PLANE_LIGHTING)
	blend_mode = BLEND_ADD
	critical = PLANE_CRITICAL_DISPLAY

/atom/movable/screen/plane_master/rendering_plate/lit_game
	name = "Lit game rendering plate"
	documentation = "Plate which is used to multiply the game rendering plate by lighting visuals and rendering fullbright stuff. Exists so we can fetch fullbright game plate for emissive VFX."
	plane = LIT_GAME_RENDER_PLATE
	render_relay_planes = list(RENDER_PLANE_MASTER)
	critical = PLANE_CRITICAL_DISPLAY

/**
 * Plane master proc called in Initialize() that creates relay objects, and sets them up as needed
 * Sets:
 * * layer from plane to avoid z-fighting
 * * planes to relay the render to
 * * render_source so that the plane will render on these objects
 * * mouse opacity to ensure proper mouse hit tracking
 * * name for debugging purposes
 * Other vars such as alpha will automatically be applied with the render source
 */
/atom/movable/screen/plane_master/proc/generate_render_relays()
	var/relay_loc = home?.relay_loc || "1,1"
	// If we're using a submap (say for a popup window) make sure we draw onto it
	if(home?.map)
		relay_loc = "[home.map]:[relay_loc]"

	var/list/generated_planes = list()
	for(var/atom/movable/render_plane_relay/relay as anything in relays)
		generated_planes += relay.plane

	for(var/relay_plane in (render_relay_planes - generated_planes))
		generate_relay_to(relay_plane, relay_loc)

	if(blend_mode != BLEND_MULTIPLY)
		blend_mode = BLEND_DEFAULT
	relays_generated = TRUE

/// Creates a connection between this plane master and the passed in plane
/// Helper for out of system code, shouldn't be used in this file
/// Build system to differenchiate between generated and non generated render relays
/atom/movable/screen/plane_master/proc/add_relay_to(target_plane, blend_override, relay_layer, relay_color)
	if(get_relay_to(target_plane))
		return
	render_relay_planes += target_plane
	var/client/display_lad = home?.our_hud?.mymob?.canon_client
	var/atom/movable/render_plane_relay/relay = generate_relay_to(target_plane, show_to = display_lad, blend_override = blend_override, relay_layer = relay_layer)
	relay.color = relay_color

/proc/get_plane_master_render_base(name)
	return "*[name]: AUTOGENERATED RENDER TGT"

/atom/movable/screen/plane_master/proc/generate_relay_to(target_plane, relay_loc, client/show_to, blend_override, relay_layer)
	if(!length(relays) && !initial(render_target))
		render_target = OFFSET_RENDER_TARGET(get_plane_master_render_base(name), offset)
	if(!relay_loc)
		relay_loc = "1,1"
		// If we're using a submap (say for a popup window) make sure we draw onto it
		if(home?.map)
			relay_loc = "[home.map]:[relay_loc]"
	var/blend_to_use = blend_override
	if(isnull(blend_to_use))
		blend_to_use = blend_mode_override || initial(blend_mode)

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
	relay.critical_target = PLANE_IS_CRITICAL(target_plane)
	relays += relay
	// Relays are sometimes generated early, before huds have a mob to display stuff to
	// That's what this is for
	if(show_to)
		show_to.screen += relay
	if(offsetting_flags & OFFSET_RELAYS_MATCH_HIGHEST && home.our_hud)
		offset_relay(relay, home.our_hud.current_plane_offset)
	return relay

/// Breaks a connection between this plane master, and the passed in place
/atom/movable/screen/plane_master/proc/remove_relay_from(target_plane)
	render_relay_planes -= target_plane
	var/atom/movable/render_plane_relay/existing_relay = get_relay_to(target_plane)
	if(!existing_relay)
		return
	relays -= existing_relay
	if(!length(relays) && !initial(render_target))
		render_target = null
	var/client/lad = home?.our_hud?.mymob?.canon_client
	if(lad)
		lad.screen -= existing_relay

/// Gets the relay atom we're using to connect to the target plane, if one exists
/atom/movable/screen/plane_master/proc/get_relay_to(target_plane)
	for(var/atom/movable/render_plane_relay/relay in relays)
		if(relay.plane == target_plane)
			return relay

	return null

/**
 * Offsets our relays in place using the given parameter by adjusting their plane and
 * layer values, avoiding changing the layer for relays with custom-set layers.
 *
 * Used in [proc/build_planes_offset] to make the relays for non-offsetting planes
 * match the highest rendering plane that matches the target, to avoid them rendering
 * on the highest level above things that should be visible.
 *
 * Parameters:
 * - new_offset: the offset we will adjust our relays to
 */
/atom/movable/screen/plane_master/proc/offset_relays_in_place(new_offset)
	for(var/atom/movable/render_plane_relay/rpr in relays)
		offset_relay(rpr, new_offset)

/**
 * Offsets a given render relay using the given parameter by adjusting its plane and
 * layer values, avoiding changing the layer if it has a custom-set layer.
 *
 * Parameters:
 * - rpr: the render plane relay we will offset
 * - new_offset: the offset we will adjust it by
 */
/atom/movable/screen/plane_master/proc/offset_relay(atom/movable/render_plane_relay/rpr, new_offset)
	var/base_relay_plane = PLANE_TO_TRUE(rpr.plane)
	var/old_offset = PLANE_TO_OFFSET(rpr.plane)
	rpr.plane = GET_NEW_PLANE(base_relay_plane, new_offset)

	var/old_offset_plane = real_plane - (PLANE_RANGE * old_offset)
	var/old_layer = (old_offset_plane + abs(LOWEST_EVER_PLANE * 30))
	if(rpr.layer != old_layer) // Avoid overriding custom-set layers
		return

	var/offset_plane = real_plane - (PLANE_RANGE * new_offset)
	var/new_layer = (offset_plane + abs(LOWEST_EVER_PLANE * 30))
	rpr.layer = new_layer
