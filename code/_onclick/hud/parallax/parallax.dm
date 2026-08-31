/// Decides if parallax should be rendered or not, and sets things up accordingly
/atom/movable/screen/parallax_home/proc/check_parallax()
	/// Applies our preferences to our existing display
	apply_parallax_pref()

	// Because other parts of the code can just REMOVE US FROM THE SCREEN for no reason as a joke
	if (displaying_layers)
		ADD_TRAIT(owner, TRAIT_PARALLAX_DISPLAYED(submap), TRAIT_GENERIC)
		owner.screen |= src
	else
		REMOVE_TRAIT(owner, TRAIT_PARALLAX_DISPLAYED(submap), TRAIT_GENERIC)
		owner.screen -= src

/atom/movable/screen/parallax_home/proc/apply_parallax_pref()
	var/turf/screen_location = get_turf(perspective)

	if(SSmapping.level_trait(screen_location?.z, ZTRAIT_NOPARALLAX))
		set_layer_settings(layers_to_draw = 0, draw_old_space = FALSE, animate_parallax = FALSE)
		return

	if (SSlag_switch.measures[DISABLE_PARALLAX] && (!owner?.mob || !HAS_TRAIT(owner.mob, TRAIT_BYPASS_MEASURES)))
		set_layer_settings(layers_to_draw = 0, draw_old_space = FALSE, animate_parallax = FALSE)
		return

	// Default to HIGH
	var/parallax_selection = owner?.prefs.read_preference(/datum/preference/choiced/parallax) || PARALLAX_HIGH

	switch(parallax_selection)
		if (PARALLAX_INSANE)
			set_layer_settings(layers_to_draw = 5, draw_old_space = FALSE, animate_parallax = TRUE)
			return

		if(PARALLAX_HIGH)
			set_layer_settings(layers_to_draw = 4, draw_old_space = FALSE, animate_parallax = TRUE)
			return

		if (PARALLAX_MED)
			set_layer_settings(layers_to_draw = 3, draw_old_space = FALSE, animate_parallax = TRUE)
			return

		if (PARALLAX_LOW)
			set_layer_settings(layers_to_draw = 1, draw_old_space = FALSE, animate_parallax = FALSE)
			return

		if (PARALLAX_BOOMER)
			set_layer_settings(layers_to_draw = 0, draw_old_space = TRUE, animate_parallax = TRUE)
			return

		if (PARALLAX_DISABLE)
			set_layer_settings(layers_to_draw = 0, draw_old_space = FALSE, animate_parallax = FALSE)
			return

/client/proc/update_parallax_prefs()
	for(var/atom/movable/screen/parallax_home/instance as anything in parallax_instances)
		instance.check_parallax()
		instance.update_parallax()

// This sets which way the current shuttle is moving (returns true if the shuttle has stopped moving so the caller can append their animation)
/atom/movable/screen/parallax_home/proc/set_parallax_movedir(new_parallax_movedir = NONE, skip_windups)
	if(new_parallax_movedir == parallax_movedir)
		return FALSE

	var/animation_dir = new_parallax_movedir || parallax_movedir
	var/matrix/new_transform
	switch(animation_dir)
		if(NORTH)
			new_transform = matrix(1, 0, 0, 0, 1, 480)
		if(SOUTH)
			new_transform = matrix(1, 0, 0, 0, 1,-480)
		if(EAST)
			new_transform = matrix(1, 0, 480, 0, 1, 0)
		if(WEST)
			new_transform = matrix(1, 0,-480, 0, 1, 0)

	var/longest_timer = 0
	for(var/key in parallax_animate_timers)
		deltimer(parallax_animate_timers[key])
	parallax_animate_timers = list()
	for(var/atom/movable/screen/parallax_layer/layer as anything in parallax_layers)
		var/scaled_time = PARALLAX_LOOP_TIME / layer.speed
		if(new_parallax_movedir == NONE) // If we're stopping, we need to stop on the same dime, yeah?
			scaled_time = PARALLAX_LOOP_TIME
		longest_timer = max(longest_timer, scaled_time)

		if(skip_windups)
			update_parallax_motionblur(layer, new_parallax_movedir, new_transform)
			continue

		layer.transform = new_transform
		animate(layer, transform = matrix(), time = scaled_time, easing = QUAD_EASING | (new_parallax_movedir ? EASE_IN : EASE_OUT))
		if (new_parallax_movedir == NONE)
			continue
		//queue up another animate so lag doesn't create a shutter
		animate(transform = new_transform, time = 0)
		animate(transform = matrix(), time = scaled_time / 2)
		parallax_animate_timers[layer] = addtimer(CALLBACK(src, PROC_REF(update_parallax_motionblur), layer, new_parallax_movedir, new_transform), scaled_time, TIMER_CLIENT_TIME|TIMER_STOPPABLE)

	dont_animate_parallax = world.time + min(longest_timer, PARALLAX_LOOP_TIME)
	parallax_movedir = new_parallax_movedir
	return TRUE

/atom/movable/screen/parallax_home/proc/update_parallax_motionblur(atom/movable/screen/parallax_layer/layer, new_parallax_movedir, matrix/new_transform)
	parallax_animate_timers -= layer
	// If we are moving in a direction, we used the QUAD_EASING function with EASE_IN
	// This means our position function is x^2. This is always LESS then the linear we're using here
	// But if we just used the same time delay, our rate of change would mismatch. f'(1) = 2x for quad easing, rather then the 1 we get for linear
	// (This is because of how derivatives work right?)
	// Because of this, while our actual rate of change from before was PARALLAX_LOOP_TIME, our perceived rate of change was PARALLAX_LOOP_TIME / 2 (lower == faster).
	// Let's account for that here
	var/scaled_time = (PARALLAX_LOOP_TIME / layer.speed) / 2
	animate(layer, transform = new_transform, time = 0, loop = -1, flags = ANIMATION_END_NOW)
	animate(transform = matrix(), time = scaled_time)

/atom/movable/screen/parallax_home/proc/update_parallax()
	var/turf/viewing_from = get_turf(perspective)
	if(!viewing_from)
		return

	var/area/areaobj = viewing_from.loc
	set_perspective_area(areaobj)

	// Update the movement direction of the parallax if necessary (for shuttles and such)
	var/quickstart_parallax = FALSE
	if(!current_turf || (current_turf.z != viewing_from.z))
		current_turf = viewing_from
		quickstart_parallax = TRUE

	set_parallax_movedir(areaobj.parallax_movedir, quickstart_parallax)

	//Doing it this way prevents parallax layers from "jumping" when you change Z-Levels.
	var/offset_x = viewing_from.x - current_turf.x
	var/offset_y = viewing_from.y - current_turf.y

	var/glide_rate = round(ICON_SIZE_ALL / perspective.glide_size * world.tick_lag, world.tick_lag)
	current_turf = viewing_from

	var/largest_change = max(abs(offset_x), abs(offset_y))
	var/max_allowed_dist = (glide_rate / world.tick_lag) + 1

	// If we aren't already moving/don't allow parallax, have made some movement, and that movement was smaller then our "glide" size, animate
	var/run_parralax = (animate_parallax && glide_rate && !areaobj.parallax_movedir && dont_animate_parallax <= world.time && largest_change <= max_allowed_dist)

	for(var/atom/movable/screen/parallax_layer/parallax_layer as anything in parallax_layers)
		var/our_speed = parallax_layer.speed
		var/change_x
		var/change_y
		var/old_x = parallax_layer.offset_x
		var/old_y = parallax_layer.offset_y
		if(parallax_layer.absolute)
			// We use change here so the typically large absolute objects (just lavaland for now) don't jitter so much
			change_x = (viewing_from.x - SSparallax.planet_x_offset) * our_speed + old_x
			change_y = (viewing_from.y - SSparallax.planet_y_offset) * our_speed + old_y
		else
			change_x = offset_x * our_speed
			change_y = offset_y * our_speed

			// This is how we tile parralax sprites
			// It doesn't use change because we really don't want to animate this
			if(old_x - change_x > 240)
				parallax_layer.offset_x -= 480
				parallax_layer.pixel_w = parallax_layer.offset_x
			else if(old_x - change_x < -240)
				parallax_layer.offset_x += 480
				parallax_layer.pixel_w = parallax_layer.offset_x
			if(old_y - change_y > 240)
				parallax_layer.offset_y -= 480
				parallax_layer.pixel_z = parallax_layer.offset_y
			else if(old_y - change_y < -240)
				parallax_layer.offset_y += 480
				parallax_layer.pixel_z = parallax_layer.offset_y

		parallax_layer.offset_x -= change_x
		parallax_layer.offset_y -= change_y
		// Now that we have our offsets, let's do our positioning
		// We're going to use an animate to "glide" that last movement out, so it looks nicer
		// Don't do any animates if we're not actually moving enough distance yeah? thanks lad
		if(run_parralax && (largest_change * our_speed > 1))
			animate(parallax_layer, pixel_w = round(parallax_layer.offset_x, 1), pixel_z = round(parallax_layer.offset_y, 1), time = glide_rate)
		else
			parallax_layer.pixel_w = round(parallax_layer.offset_x, 1)
			parallax_layer.pixel_z = round(parallax_layer.offset_y, 1)

// Root object for parallax, all parallax layers are drawn onto this and it manages them
/atom/movable/screen/parallax_home
	icon = null
	blend_mode = BLEND_ADD
	plane = PLANE_SPACE_PARALLAX
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// The submap we are displaying on
	var/submap = null
	/// The submap string to draw with, if any
	var/submap_text = null
	/// Layers we are currently displaying
	var/list/atom/movable/screen/parallax_layer/parallax_layers = list()
	/// Pallet of layers we CAN display if we choose to, depending on our client's prefs
	/// ensures quick removal/reinsertion doesn't cause cycling qdels
	var/list/atom/movable/screen/parallax_layer/parallax_layers_cached = list()
	/// How many normal space layers we want to draw, in increasing order of "depth"
	var/layers_to_draw = 0
	/// If we want to draw the old space layer
	var/draw_old_space = FALSE
	/// Are we currently displaying any layers?
	var/displaying_layers = FALSE
	/// Are we animating parallax?
	var/animate_parallax = FALSE
	/// The movable we are being drawn from the perspective of
	var/atom/movable/perspective
	/// The turf we are currently displaying "from"
	var/turf/current_turf
	/// The client that owns us
	var/client/owner
	/// Timers for the area directional animation, one for each layer
	var/list/parallax_animate_timers
	/// world.time of when we can state animate()ing parallax again
	var/dont_animate_parallax
	/// Direction our current area wants to move parallax
	var/parallax_movedir = NONE
	/// The area our perspective is currently in
	var/area/perspective_area

/atom/movable/screen/parallax_home/Initialize(mapload, datum/hud/hud_owner, client/owner, submap = null)
	. = ..()
	src.owner = owner
	owner.parallax_instances += src
	src.submap = submap
	if(submap)
		src.submap_text = "[submap]:"
	if(!isnull(submap_text))
		screen_loc = "[submap_text][screen_loc]"

/atom/movable/screen/parallax_home/Destroy()
	REMOVE_TRAIT(owner, TRAIT_PARALLAX_DISPLAYED(submap), TRAIT_GENERIC)
	clear_layers()
	set_perspective(null)
	current_turf = null
	owner.screen -= src
	owner.parallax_instances -= src
	if(owner.eye_parallax == src)
		owner.eye_parallax = null
	owner = null
	return ..()

/atom/movable/screen/parallax_home/proc/set_perspective(atom/movable/new_perspective)
	if(perspective == new_perspective)
		return
	var/old_perspective = perspective
	if(old_perspective)
		UnregisterSignal(old_perspective, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_Z_CHANGED))
	perspective = new_perspective

	if(!perspective)
		SEND_SIGNAL(src, COMSIG_PARALLAX_PERSPECTIVE_CHANGED, old_perspective, new_perspective)
		return
	var/static/list/container_connections = list(
		COMSIG_MOVABLE_MOVED = PROC_REF(perspective_loc_moved),
	)
	AddComponent(/datum/component/connect_containers, perspective, container_connections)
	RegisterSignal(perspective, COMSIG_MOVABLE_MOVED, PROC_REF(perspective_moved))
	RegisterSignal(perspective, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(perspective_z_changed))
	SEND_SIGNAL(src, COMSIG_PARALLAX_PERSPECTIVE_CHANGED, old_perspective, new_perspective)
	check_parallax()
	update_parallax()

/atom/movable/screen/parallax_home/proc/perspective_loc_moved(atom/movable/source)
	if(source.moving_diagonally == FIRST_DIAG_STEP)
		return
	update_parallax()

/atom/movable/screen/parallax_home/proc/perspective_moved(datum/source)
	SIGNAL_HANDLER
	// We don't do this all the time because diag movements should trigger one call to this, not two
	// Waste of cpu time, and it fucks the animate
	if(perspective.moving_diagonally == FIRST_DIAG_STEP)
		return
	update_parallax()

/atom/movable/screen/parallax_home/proc/perspective_z_changed(datum/source)
	SIGNAL_HANDLER
	check_parallax()
	update_parallax()

/atom/movable/screen/parallax_home/proc/set_perspective_area(area/new_area)
	if(perspective_area == new_area)
		return
	if(perspective_area)
		UnregisterSignal(perspective_area, COMSIG_AREA_PARALLAX_DIR_CHANGED)

	perspective_area = new_area
	RegisterSignal(perspective_area, COMSIG_AREA_PARALLAX_DIR_CHANGED, PROC_REF(area_parallax_dir_changed))

/atom/movable/screen/parallax_home/proc/area_parallax_dir_changed(datum/source)
	SIGNAL_HANDLER
	update_parallax()

/atom/movable/screen/parallax_home/proc/display_layers()
	if(displaying_layers || length(parallax_layers_cached) == 0)
		return
	parallax_layers = parallax_layers_cached
	vis_contents = parallax_layers_cached
	displaying_layers = TRUE

/atom/movable/screen/parallax_home/proc/hide_layers()
	if(!displaying_layers)
		return
	parallax_layers = list()
	vis_contents = list()
	displaying_layers = FALSE

/atom/movable/screen/parallax_home/proc/set_layer_settings(layers_to_draw, draw_old_space, animate_parallax)
	src.animate_parallax = animate_parallax
	if(src.layers_to_draw == layers_to_draw && src.draw_old_space == draw_old_space)
		return
	src.layers_to_draw = layers_to_draw
	src.draw_old_space = draw_old_space
	regenerate_layers()

/atom/movable/screen/parallax_home/proc/generate_space_layer(index)
	switch(index)
		if(1)
			return new /atom/movable/screen/parallax_layer/layer_1(null, null, src)
		if(2)
			return new /atom/movable/screen/parallax_layer/layer_2(null, null, src)
		if(3)
			return new /atom/movable/screen/parallax_layer/planet(null, null, src)
		if(4)
			if(SSparallax.random_layer)
				return new SSparallax.random_layer.type(null, null, src, FALSE, SSparallax.random_layer)
			else
				return new /atom/movable/screen/parallax_layer/layer_3(null, null, src)
		if(5)
			if(SSparallax.random_layer)
				return new /atom/movable/screen/parallax_layer/layer_3(null, null, src)

/atom/movable/screen/parallax_home/proc/regenerate_layers()
	clear_layers()
	if(layers_to_draw == 0 && !draw_old_space)
		return

	parallax_layers_cached = list()
	for(var/space_layer in 1 to layers_to_draw)
		var/atom/movable/screen/parallax_layer/parallax = generate_space_layer(space_layer)
		if (parallax)
			parallax_layers_cached += parallax

	if(draw_old_space)
		parallax_layers_cached += new /atom/movable/screen/parallax_layer/old(null, null, src)

	display_layers()

/atom/movable/screen/parallax_home/proc/clear_layers()
	hide_layers()
	QDEL_LIST(parallax_layers_cached)

// We need parallax to always pass its args down into initialize, so we immediate init it
/atom/movable/screen/parallax_layer
	icon = 'icons/effects/parallax.dmi'
	var/speed = 1
	var/offset_x = 0
	var/offset_y = 0
	var/absolute = FALSE
	appearance_flags = APPEARANCE_UI | KEEP_TOGETHER
	blend_mode = BLEND_ADD
	plane = PLANE_SPACE_PARALLAX
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// View size we're being rendered with
	var/working_view = ""
	/// The parallax home that owns us
	var/atom/movable/screen/parallax_home/home

/atom/movable/screen/parallax_layer/Initialize(mapload, datum/hud/hud_owner, atom/movable/screen/parallax_home/home, template = FALSE)
	. = ..()
	// Parallax layers are independent of hud, they care about client
	// Not doing this will just create a bunch of hard deletes
	set_new_hud(hud_owner = null)

	if(template)
		return

	src.home = home
	var/client/owner = home.owner
	if(QDELETED(owner)) // If this typepath all starts to harddel your culprit is likely this
		return INITIALIZE_HINT_QDEL

	if(!isnull(home.submap_text))
		screen_loc = "[home.submap_text][screen_loc]"

	// I do not want to know bestie
	var/view = owner.view || world.view
	update_o(view)
	RegisterSignal(owner, COMSIG_VIEW_SET, PROC_REF(on_view_change))

/atom/movable/screen/parallax_layer/Destroy()
	if(home)
		home.parallax_layers_cached -= src
		home.parallax_layers -= src
		home = null
	return ..()

/atom/movable/screen/parallax_layer/proc/on_view_change(datum/source, new_size)
	SIGNAL_HANDLER
	update_o(new_size)

/atom/movable/screen/parallax_layer/proc/update_o(new_view)
	if(working_view == new_view)
		return
	working_view = new_view
	update_appearance()

/atom/movable/screen/parallax_layer/update_overlays()
	. = ..()
	var/overlay_view = working_view
	if (!overlay_view)
		overlay_view = world.view
	var/pixel_grid_size = ICON_SIZE_ALL * 15
	var/parallax_scaler = ICON_SIZE_ALL / pixel_grid_size

	// Turn the view size into a grid of correctly scaled overlays
	var/list/viewscales = getviewsize(overlay_view)
	// This could be half the size but we need to provide space for parallax movement on mob movement, and movement on scroll from shuttles, so like this instead
	var/countx = (CEILING((viewscales[1] / 2) * parallax_scaler, 1) + 1)
	var/county = (CEILING((viewscales[2] / 2) * parallax_scaler, 1) + 1)
	for(var/x in -countx to countx)
		for(var/y in -county to county)
			if(x == 0 && y == 0)
				continue
			var/mutable_appearance/texture_overlay = tileable_appearance()
			texture_overlay.pixel_w += pixel_grid_size * x
			texture_overlay.pixel_z += pixel_grid_size * y
			. += texture_overlay

/atom/movable/screen/parallax_layer/proc/tileable_appearance()
	return mutable_appearance(icon, icon_state)

/atom/movable/screen/parallax_layer/layer_1
	icon_state = "layer1"
	speed = 0.6
	layer = 1

/atom/movable/screen/parallax_layer/layer_2
	icon_state = "layer2"
	speed = 1
	layer = 2

/atom/movable/screen/parallax_layer/layer_3
	icon_state = "layer3"
	speed = 1.4
	layer = 3

/atom/movable/screen/parallax_layer/old
	icon = null
	icon_state = null // dog there's gonna be so many overlays...
	speed = 0.6
	layer = 1 // Draws on its own

/atom/movable/screen/parallax_layer/old/tileable_appearance()
	var/mutable_appearance/copy = mutable_appearance(null, "")
	// We have to use render targets to draw one of these flat and reuse it for this because FOR SOME REASON
	// 16 (tile count) * (14 (animated state count) * 4 (frame count) + 1 (1 is not animated)) 480x480 states
	// is TOO MUCH for the client. Whatever, see if I care.
	copy.render_source = "*old_space_parallax"
	return copy

/atom/movable/screen/parallax_layer/old/update_overlays()
	. = ..()
	var/mutable_appearance/relayed_overlay = mutable_appearance('icons/effects/old_parallax.dmi', "1", appearance_flags = RESET_TRANSFORM|PIXEL_SCALE|KEEP_TOGETHER|KEEP_APART)
	var/list/old_states = list("19", "21", "23", "24", "26", "29", "30", "31", "34", "35", "36", "37", "43", "46")
	var/list/holder_overlays = list()
	for(var/state in old_states)
		holder_overlays += mutable_appearance('icons/effects/old_parallax.dmi', state)
	relayed_overlay.overlays = holder_overlays
	relayed_overlay.render_target = "*old_space_parallax"
	// Renders the like, "input" appearance we draw to everything else
	. += relayed_overlay
	// The 0,0 appearance, can't reuse relayed_overlay for this because otherwise transforms would stack
	. += tileable_appearance()

/atom/movable/screen/parallax_layer/planet
	icon_state = "planet"
	blend_mode = BLEND_OVERLAY
	absolute = TRUE //Status of separation
	speed = 3
	layer = 30

/atom/movable/screen/parallax_layer/planet/Initialize(mapload, datum/hud/hud_owner, atom/movable/screen/parallax_home/home)
	. = ..()
	RegisterSignal(home, COMSIG_PARALLAX_PERSPECTIVE_CHANGED, PROC_REF(perspective_changed))
	perspective_changed(home, null, home.perspective)

/atom/movable/screen/parallax_layer/planet/proc/perspective_changed(datum/source, atom/old_perspective, atom/new_perspective)
	SIGNAL_HANDLER
	if(old_perspective == new_perspective)
		return
	if(old_perspective)
		UnregisterSignal(old_perspective, COMSIG_MOVABLE_Z_CHANGED)
	if(new_perspective)
		RegisterSignal(new_perspective, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_change))
	on_z_change(new_perspective)

/atom/movable/screen/parallax_layer/planet/proc/on_z_change(atom/source)
	SIGNAL_HANDLER
	var/turf/viewing_from = get_turf(home?.perspective)
	if(isnull(viewing_from))
		return
	SetInvisibility(is_station_level(viewing_from.z) ? INVISIBILITY_NONE : INVISIBILITY_ABSTRACT, id=type)

/atom/movable/screen/parallax_layer/planet/update_o()
	return //Shit won't move
