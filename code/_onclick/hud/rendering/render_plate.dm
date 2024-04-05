/*!
 * Custom rendering solution to allow for advanced effects
 * We (ab)use plane masters and render source/target to cheaply render 2+ planes as 1
 * if you want to read more read the _render_readme.md
 */

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

/atom/movable/screen/plane_master/rendering_plate/master/set_distance_from_owner(mob/relevant, new_distance, multiz_boundary, lowest_possible_offset, highest_possible_offset)
	. = ..()
	if(!.)
		return
	if(offset == 0)
		return
	if(distance_from_owner == 0)
		remove_relay_from(GET_NEW_PLANE(RENDER_PLANE_TRANSPARENT, offset - 1))
	else
		add_relay_to(GET_NEW_PLANE(RENDER_PLANE_TRANSPARENT, offset - 1))

///renders general in charachter game objects
/atom/movable/screen/plane_master/rendering_plate/game_plate
	name = "Game rendering plate"
	documentation = "Holds all objects that are ahhh, in character? is maybe the best way to describe it.\
		<br>We apply a displacement effect from the gravity pulse plane too, so we can warp the game world.\
		<br>If we have fov enabled we'll relay this onto two different rendering plates to apply fov effects to only a portion. If not, we just draw straight to master"
	plane = RENDER_PLANE_GAME
	render_relay_planes = list(RENDER_PLANE_MASTER)

/atom/movable/screen/plane_master/rendering_plate/game_plate/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
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
	remove_relay_from(GET_NEW_PLANE(RENDER_PLANE_MASTER, offset))

/atom/movable/screen/plane_master/rendering_plate/game_plate/proc/fov_disabled(mob/source)
	SIGNAL_HANDLER
	remove_relay_from(GET_NEW_PLANE(RENDER_PLANE_GAME_UNMASKED, offset))
	remove_relay_from(GET_NEW_PLANE(RENDER_PLANE_GAME_MASKED, offset))
	add_relay_to(GET_NEW_PLANE(RENDER_PLANE_MASTER, offset))

///renders the parts of the plate unmasked by fov
/atom/movable/screen/plane_master/rendering_plate/unmasked_game_plate
	name = "Unmasked Game rendering plate"
	documentation = "Holds the bits of the game plate that aren't impacted by fov.\
		<br>We use an alpha mask to cut out the bits we plan on dealing with elsewhere"
	plane = RENDER_PLANE_GAME_UNMASKED
	render_relay_planes = list(RENDER_PLANE_MASTER)

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
	render_relay_planes = list(RENDER_PLANE_MASTER)

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
	render_target = GAME_WORLD_RENDER_TARGET
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/rendering_plate/game_world_ao
	name = "Game world ambient occlusion"
	documentation = "Alright so we want like a dark outline around the world right? The way you'd typically do this is with the dropshadow filter.\
		<br>But it's slow as HELL. This is mostly cause of the blur filter. (Dropshadow is a composite of blur, offsetting and layering)\
		<br>It'd be like 20% of our client budget for 1 z layer. That's no good.\
		<br>There's a fun trick we can do though. We can use transforms to scale down the game world, and then blur THAT.\
		<br>This essentially quarters the amount of work we need to do. Then we just bump it back up and we're golden."
	plane = RENDER_PLANE_GAME_WORLD_AO
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_planes = list()

/atom/movable/screen/plane_master/rendering_plate/game_world_ao/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset)
	. = ..()
	// For.. some reason submaps do not play well with transforms, so none for now
	// When it's fixed we can remove this
	if(home.key != PLANE_GROUP_MAIN)
		hide_plane()
		return
	var/matrix/scale_down_matrix = new /matrix()
	scale_down_matrix.Translate(0, -2)
	scale_down_matrix.Scale(1/AO_TRANSFORM_CONSTANT)
	// The way I WANT to do this is just run a relay from the game world to this plate (and transform the relay and such)
	// Fuckin can't tho cause of funny byond bugs (I think it's not properly differenciating between relays somehow). So we gotta do this instead. Sadge
	// Also of note, I'd like to somehow scale down the thing we're rendering "onto" before we render, since that should save even more time. I can't seem to though
	// Like if I try and transform this rendering plate it somehow psychically effects the other instance of the game world plate? I have no god damn idea what byond is smoking
	add_filter("game_world", 0, layering_filter(render_source = OFFSET_RENDER_TARGET(GAME_WORLD_RENDER_TARGET, offset), color = "#04080F6F", transform = scale_down_matrix))
	add_filter("blur", 2, gauss_blur_filter(1))
	var/matrix/scale_up_matrix = new /matrix()
	scale_up_matrix.Scale(AO_TRANSFORM_CONSTANT)
	add_relay_to(GET_NEW_PLANE(RENDER_PLANE_GAME, offset), relay_transform = scale_up_matrix, relay_appearance_flags = PIXEL_SCALE)

/atom/movable/screen/plane_master/rendering_plate/game_world_ao/show_to(mob/mymob)
	. = ..()
	if(!.)
		return
	if(!mymob?.client?.prefs?.read_preference(/datum/preference/toggle/ambient_occlusion))
		hide_plane(mymob)

/atom/movable/screen/plane_master/rendering_plate/game_world_ao/set_distance_from_owner(mob/relevant, new_distance, multiz_boundary, lowest_possible_offset, highest_possible_offset)
	. = ..()
	if(!.)
		return
	// We run AO on just the plane below us, since it becomes unremarkable 1 more layer down
	if(abs(distance_from_owner) <= 1)
		show_to(relevant)
	else
		hide_from(relevant)

///Contains all lighting objects
/atom/movable/screen/plane_master/rendering_plate/lighting
	name = "Lighting plate"
	documentation = "Anything on this plane will be <b>multiplied</b> with the plane it's rendered onto (typically the game plane).\
		<br>That's how lighting functions at base. Because it uses BLEND_MULTIPLY and occasionally color matrixes, it needs a backdrop of blackness.\
		<br>See <a href=\"https://secure.byond.com/forum/?post=2141928\">This byond post</a>\
		<br>Lemme see uh, we're masked by the emissive plane so it can actually function (IE: make things glow in the dark).\
		<br>We're also masked by the overlay lighting plane, which contains all the well overlay lights in the game. It draws to us and also the game plane.\
		<br>Masks us out so it has the breathing room to apply its effect.\
		<br>Oh and we quite often have our alpha changed to achive night vision effects, or things of that sort."
	plane = RENDER_PLANE_LIGHTING
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	critical = PLANE_CRITICAL_DISPLAY
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
	add_filter("object_lighting", 2, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(O_LIGHTING_VISUAL_RENDER_TARGET, offset), flags = MASK_INVERSE))
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

	set_light_cutoff(mymob.lighting_cutoff, mymob.lighting_color_cutoffs)

/atom/movable/screen/plane_master/rendering_plate/lighting/hide_from(mob/oldmob)
	. = ..()
	oldmob.clear_fullscreen("lighting_backdrop_lit_[home.key]#[offset]", animated = 0)
	oldmob.clear_fullscreen("lighting_backdrop_unlit_[home.key]#[offset]", animated = 0)

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
	allow_rendering_in_place = FALSE

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
	allow_rendering_in_place = FALSE
	// We blend against the game plane, so she's gotta multiply!
	blend_mode = BLEND_MULTIPLY
	render_relay_planes = list()

/atom/movable/screen/plane_master/rendering_plate/light_mask/set_distance_from_owner(mob/relevant, new_distance, multiz_boundary, lowest_possible_offset, highest_possible_offset)
	var/old_hidden_by_distance = hidden_by_distance
	. = ..()
	if(!.)
		return
	#warn need to disable planes that are in between "chunks" of view
	/// OOOOK if we are not like "in" the view of our parent don't draw us, yeah?
	/// This is to prevent situations where we're drawing "between" like a low z layer and a high one
	/// Ideally we would cull out the unused layers in between but that's a lot of work and this is a super rare case sooo
	if(!home.depths_in_view[offset + 1])
		hide_from(relevant)
	else if(old_hidden_by_distance != NOT_HIDDEN)
		show_to(relevant)		

/atom/movable/screen/plane_master/rendering_plate/light_mask/show_to(mob/mymob)
	. = ..()
	if(!.)
		return

	RegisterSignal(mymob, COMSIG_MOB_SIGHT_CHANGE, PROC_REF(handle_sight), override = TRUE)
	handle_sight(mymob, mymob.sight, NONE)

/atom/movable/screen/plane_master/rendering_plate/light_mask/hide_from(mob/oldmob)
	. = ..()
	var/atom/movable/screen/plane_master/overlay_lights = home.get_plane(GET_NEW_PLANE(O_LIGHTING_VISUAL_PLANE, offset))
	overlay_lights.remove_filter("lighting_mask")
	var/atom/movable/screen/plane_master/emissive = home.get_plane(GET_NEW_PLANE(EMISSIVE_RENDER_PLATE, offset))
	emissive.remove_filter("lighting_mask")
	remove_relay_from(GET_NEW_PLANE(RENDER_PLANE_GAME, offset))
	UnregisterSignal(oldmob, COMSIG_MOB_SIGHT_CHANGE)

/atom/movable/screen/plane_master/rendering_plate/light_mask/proc/handle_sight(datum/source, new_sight, old_sight)
	// If we can see something that shows "through" blackness, and we can't see turfs, disable our draw to the game plane
	// And instead mask JUST the overlay lighting plane, since that will look fuckin wrong
	var/atom/movable/screen/plane_master/overlay_lights = home.get_plane(GET_NEW_PLANE(O_LIGHTING_VISUAL_PLANE, offset))
	var/atom/movable/screen/plane_master/emissive = home.get_plane(GET_NEW_PLANE(EMISSIVE_RENDER_PLATE, offset))
	if(new_sight & SEE_AVOID_TURF_BLACKNESS && !(new_sight & SEE_TURFS))
		remove_relay_from(GET_NEW_PLANE(RENDER_PLANE_GAME, offset))
		overlay_lights.add_filter("lighting_mask", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(LIGHT_MASK_RENDER_TARGET, offset)))
		emissive.add_filter("lighting_mask", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(LIGHT_MASK_RENDER_TARGET, offset)))
	// If we CAN'T see through the black, then draw er down brother!
	else
		overlay_lights.remove_filter("lighting_mask")
		emissive.remove_filter("lighting_mask")
		// We max alpha here, so our darkness is actually.. dark
		// Can't do it before cause it fucks with the filter
		add_relay_to(GET_NEW_PLANE(RENDER_PLANE_GAME, offset), relay_color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,1))

///render plate for OOC stuff like ghosts, hud-screen effects, etc
/atom/movable/screen/plane_master/rendering_plate/non_game
	name = "Non-Game rendering plate"
	documentation = "Renders anything that's out of character. Mostly useful as a converse to the game rendering plate."
	plane = RENDER_PLANE_NON_GAME
	render_relay_planes = list(RENDER_PLANE_MASTER)

/atom/movable/screen/plane_master/rendering_plate/runechat_ao
	name = "Runechat ambient occlusion"
	documentation = "This is essentially the same effect as the game world AO, except for its scope.\
		<br>The amount of pixels this actually modifies is drastically less then the game world. Doesn't impact our logic tho."
	plane = RENDER_PLANE_RUNECHAT_AO
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_planes = list()

/atom/movable/screen/plane_master/rendering_plate/runechat_ao/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset)
	. = ..()
	// For.. some reason submaps do not play well with transforms, so none for now
	if(home.key != PLANE_GROUP_MAIN)
		hide_plane()
		return
	var/matrix/scale_down_matrix = new /matrix()
	scale_down_matrix.Translate(0, -2)
	scale_down_matrix.Scale(1/AO_TRANSFORM_CONSTANT)
	add_filter("runechat", 0, layering_filter(render_source = OFFSET_RENDER_TARGET(RUNECHAT_RENDER_TARGET, offset), color = "#04080F6F", transform = scale_down_matrix))
	add_filter("blur", 2, gauss_blur_filter(1))
	var/matrix/scale_up_matrix = new /matrix()
	scale_up_matrix.Scale(AO_TRANSFORM_CONSTANT)
	add_relay_to(GET_NEW_PLANE(RENDER_PLANE_NON_GAME, offset), relay_transform = scale_up_matrix, relay_appearance_flags = PIXEL_SCALE)

/atom/movable/screen/plane_master/rendering_plate/runechat_ao/show_to(mob/mymob)
	. = ..()
	if(!.)
		return
	if(!mymob?.client?.prefs?.read_preference(/datum/preference/toggle/ambient_occlusion))
		hide_plane(mymob)

/atom/movable/screen/plane_master/rendering_plate/runechat_ao/set_distance_from_owner(mob/relevant, new_distance, multiz_boundary, lowest_possible_offset, highest_possible_offset)
	. = ..()
	if(!.)
		return
	// No sense wasting gpu time on this
	if(distance_from_owner == 0)
		show_to(relevant)
	else
		hide_from(relevant)

