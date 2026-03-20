/// Decides if parallax should be rendered or not, and sets things up accordingly
/datum/hud/proc/check_parallax()
	var/client/displaying_client = mymob.client
	if(isnull(displaying_client.parallax_rock))
		displaying_client.parallax_rock = new(null, null, displaying_client)

	/// Applies our preferences to our existing display
	apply_parallax_pref()
	var/atom/movable/screen/parallax_home/rock = displaying_client?.parallax_rock

	// Because other parts of the code can just REMOVE US FROM THE SCREEN for no reason as a joke
	if (rock.displaying_layers)
		ADD_TRAIT(src, TRAIT_PARALLAX_DISPLAYED, TRAIT_GENERIC)
		displaying_client.screen |= rock
	else
		REMOVE_TRAIT(src, TRAIT_PARALLAX_DISPLAYED, TRAIT_GENERIC)
		displaying_client.screen -= rock

/datum/hud/proc/apply_parallax_pref()
	var/turf/screen_location = get_turf(mymob)
	var/client/displaying_client = mymob.client
	var/atom/movable/screen/parallax_home/rock = displaying_client.parallax_rock

	if(SSmapping.level_trait(screen_location?.z, ZTRAIT_NOPARALLAX))
		rock.set_layer_settings(layers_to_draw = 0, draw_old_space = FALSE, animate_parallax = FALSE)
		return

	if (SSlag_switch.measures[DISABLE_PARALLAX] && !HAS_TRAIT(mymob, TRAIT_BYPASS_MEASURES))
		rock.set_layer_settings(layers_to_draw = 0, draw_old_space = FALSE, animate_parallax = FALSE)
		return

	// Default to HIGH
	var/parallax_selection = displaying_client?.prefs.read_preference(/datum/preference/choiced/parallax) || PARALLAX_HIGH

	switch(parallax_selection)
		if (PARALLAX_INSANE)
			rock.set_layer_settings(layers_to_draw = 5, draw_old_space = FALSE, animate_parallax = TRUE)
			return

		if(PARALLAX_HIGH)
			rock.set_layer_settings(layers_to_draw = 4, draw_old_space = FALSE, animate_parallax = TRUE)
			return

		if (PARALLAX_MED)
			rock.set_layer_settings(layers_to_draw = 3, draw_old_space = FALSE, animate_parallax = TRUE)
			return

		if (PARALLAX_LOW)
			rock.set_layer_settings(layers_to_draw = 1, draw_old_space = FALSE, animate_parallax = FALSE)
			return

		if (PARALLAX_BOOMER)
			rock.set_layer_settings(layers_to_draw = 0, draw_old_space = TRUE, animate_parallax = TRUE)
			return

		if (PARALLAX_DISABLE)
			rock.set_layer_settings(layers_to_draw = 0, draw_old_space = FALSE, animate_parallax = FALSE)
			return

/datum/hud/proc/update_parallax_pref()
	if(!mymob.client)
		return
	check_parallax()
	update_parallax()

// This sets which way the current shuttle is moving (returns true if the shuttle has stopped moving so the caller can append their animation)
/datum/hud/proc/set_parallax_movedir(new_parallax_movedir = NONE, skip_windups)
	. = FALSE
	var/client/displaying_client = mymob.client
	if(new_parallax_movedir == displaying_client.parallax_movedir)
		return

	var/animation_dir = new_parallax_movedir || displaying_client.parallax_movedir
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
	for(var/key in displaying_client.parallax_animate_timers)
		deltimer(displaying_client.parallax_animate_timers[key])
	displaying_client.parallax_animate_timers = list()
	for(var/atom/movable/screen/parallax_layer/layer as anything in displaying_client.parallax_rock.parallax_layers)
		var/scaled_time = PARALLAX_LOOP_TIME / layer.speed
		if(new_parallax_movedir == NONE) // If we're stopping, we need to stop on the same dime, yeah?
			scaled_time = PARALLAX_LOOP_TIME
		longest_timer = max(longest_timer, scaled_time)

		if(skip_windups)
			update_parallax_motionblur(displaying_client, layer, new_parallax_movedir, new_transform)
			continue

		layer.transform = new_transform
		animate(layer, transform = matrix(), time = scaled_time, easing = QUAD_EASING | (new_parallax_movedir ? EASE_IN : EASE_OUT))
		if (new_parallax_movedir == NONE)
			continue
		//queue up another animate so lag doesn't create a shutter
		animate(transform = new_transform, time = 0)
		animate(transform = matrix(), time = scaled_time / 2)
		displaying_client.parallax_animate_timers[layer] = addtimer(CALLBACK(src, PROC_REF(update_parallax_motionblur), displaying_client, layer, new_parallax_movedir, new_transform), scaled_time, TIMER_CLIENT_TIME|TIMER_STOPPABLE)

	displaying_client.dont_animate_parallax = world.time + min(longest_timer, PARALLAX_LOOP_TIME)
	displaying_client.parallax_movedir = new_parallax_movedir

/datum/hud/proc/update_parallax_motionblur(client/displaying_client, atom/movable/screen/parallax_layer/layer, new_parallax_movedir, matrix/new_transform)
	if(!displaying_client)
		return
	displaying_client.parallax_animate_timers -= layer

	// If we are moving in a direction, we used the QUAD_EASING function with EASE_IN
	// This means our position function is x^2. This is always LESS then the linear we're using here
	// But if we just used the same time delay, our rate of change would mismatch. f'(1) = 2x for quad easing, rather then the 1 we get for linear
	// (This is because of how derivatives work right?)
	// Because of this, while our actual rate of change from before was PARALLAX_LOOP_TIME, our perceived rate of change was PARALLAX_LOOP_TIME / 2 (lower == faster).
	// Let's account for that here
	var/scaled_time = (PARALLAX_LOOP_TIME / layer.speed) / 2
	animate(layer, transform = new_transform, time = 0, loop = -1, flags = ANIMATION_END_NOW)
	animate(transform = matrix(), time = scaled_time)

/datum/hud/proc/update_parallax()
	var/client/displaying_client = mymob.client
	var/turf/posobj = get_turf(displaying_client.eye)
	if(!posobj)
		return

	var/area/areaobj = posobj.loc
	// Update the movement direction of the parallax if necessary (for shuttles)
	set_parallax_movedir(areaobj.parallax_movedir, FALSE, mymob)

	if(!displaying_client.previous_turf || (displaying_client.previous_turf.z != posobj.z))
		displaying_client.previous_turf = posobj

	//Doing it this way prevents parallax layers from "jumping" when you change Z-Levels.
	var/offset_x = posobj.x - displaying_client.previous_turf.x
	var/offset_y = posobj.y - displaying_client.previous_turf.y

	var/glide_rate = round(ICON_SIZE_ALL / mymob.glide_size * world.tick_lag, world.tick_lag)
	displaying_client.previous_turf = posobj

	var/largest_change = max(abs(offset_x), abs(offset_y))
	var/max_allowed_dist = (glide_rate / world.tick_lag) + 1
	var/atom/movable/screen/parallax_home/rock = displaying_client.parallax_rock

	// If we aren't already moving/don't allow parallax, have made some movement, and that movement was smaller then our "glide" size, animate
	var/run_parralax = (rock.animate_parallax && glide_rate && !areaobj.parallax_movedir && displaying_client.dont_animate_parallax <= world.time && largest_change <= max_allowed_dist)

	for(var/atom/movable/screen/parallax_layer/parallax_layer as anything in rock.parallax_layers)
		var/our_speed = parallax_layer.speed
		var/change_x
		var/change_y
		var/old_x = parallax_layer.offset_x
		var/old_y = parallax_layer.offset_y
		if(parallax_layer.absolute)
			// We use change here so the typically large absolute objects (just lavaland for now) don't jitter so much
			change_x = (posobj.x - SSparallax.planet_x_offset) * our_speed + old_x
			change_y = (posobj.y - SSparallax.planet_y_offset) * our_speed + old_y
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

/atom/movable/proc/update_parallax_contents()
	for(var/mob/client_mob as anything in client_mobs_in_contents)
		if(client_mob?.client?.parallax_rock?.displaying_layers && client_mob.hud_used)
			client_mob.hud_used.update_parallax()

/mob/proc/update_parallax_teleport() //used for arrivals shuttle
	if(client?.eye && hud_used && client?.parallax_rock?.displaying_layers)
		var/area/areaobj = get_area(client.eye)
		hud_used.set_parallax_movedir(areaobj.parallax_movedir, TRUE)

// Root object for parallax, all parallax layers are drawn onto this and it manages them
INITIALIZE_IMMEDIATE(/atom/movable/screen/parallax_home)
/atom/movable/screen/parallax_home
	icon = null
	blend_mode = BLEND_ADD
	plane = PLANE_SPACE_PARALLAX
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
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
	/// The client that owns us
	var/client/owner

/atom/movable/screen/parallax_home/Initialize(mapload, datum/hud/hud_owner, client/owner)
	. = ..()
	src.owner = owner

/atom/movable/screen/parallax_home/Destroy()
	clear_layers()
	owner = null
	return ..()

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
			return new /atom/movable/screen/parallax_layer/layer_1(null, null, owner)
		if(2)
			return new /atom/movable/screen/parallax_layer/layer_2(null, null, owner)
		if(3)
			return new /atom/movable/screen/parallax_layer/planet(null, null, owner)
		if(4)
			if(SSparallax.random_layer)
				return new SSparallax.random_layer.type(null, null, owner, FALSE, SSparallax.random_layer)
			else
				return new /atom/movable/screen/parallax_layer/layer_3(null, null, owner)
		if(5)
			if(SSparallax.random_layer)
				return new /atom/movable/screen/parallax_layer/layer_3(null, null, owner)

/atom/movable/screen/parallax_home/proc/regenerate_layers()
	clear_layers()
	if(layers_to_draw == 0 && !draw_old_space)
		return

	parallax_layers_cached = list()
	for(var/space_layer in 1 to layers_to_draw)
		parallax_layers_cached += generate_space_layer(space_layer)

	if(draw_old_space)
		parallax_layers_cached += new /atom/movable/screen/parallax_layer/old(null, null, owner)

	display_layers()

/atom/movable/screen/parallax_home/proc/clear_layers()
	hide_layers()
	QDEL_LIST(parallax_layers_cached)

// We need parallax to always pass its args down into initialize, so we immediate init it
INITIALIZE_IMMEDIATE(/atom/movable/screen/parallax_layer)
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

/atom/movable/screen/parallax_layer/Initialize(mapload, datum/hud/hud_owner, client/owner, template = FALSE)
	. = ..()
	// Parallax layers are independent of hud, they care about client
	// Not doing this will just create a bunch of hard deletes
	set_new_hud(hud_owner = null)

	if(template)
		return

	if(!owner) // If this typepath all starts to harddel your culprit is likely this
		return INITIALIZE_HINT_QDEL

	// I do not want to know bestie
	var/view = owner.view || world.view
	update_o(view)
	RegisterSignal(owner, COMSIG_VIEW_SET, PROC_REF(on_view_change))

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

/atom/movable/screen/parallax_layer/planet/Initialize(mapload, datum/hud/hud_owner, client/owner)
	. = ..()
	if(!owner)
		return
	var/static/list/connections = list(
		COMSIG_MOVABLE_Z_CHANGED = PROC_REF(on_z_change),
		COMSIG_MOB_LOGOUT = PROC_REF(on_mob_logout),
	)
	AddComponent(/datum/component/connect_mob_behalf, owner, connections)
	on_z_change(owner.mob)

/atom/movable/screen/parallax_layer/planet/proc/on_mob_logout(mob/source)
	SIGNAL_HANDLER
	var/client/boss = source.canon_client
	on_z_change(boss.mob)

/atom/movable/screen/parallax_layer/planet/proc/on_z_change(mob/source)
	SIGNAL_HANDLER
	var/client/boss = source.client
	var/turf/posobj = get_turf(boss?.eye)
	if(!posobj)
		return
	SetInvisibility(is_station_level(posobj.z) ? INVISIBILITY_NONE : INVISIBILITY_ABSTRACT, id=type)

/atom/movable/screen/parallax_layer/planet/update_o()
	return //Shit won't move
