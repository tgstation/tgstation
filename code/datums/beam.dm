
/** # Beam Datum and Effect
 * **IF YOU ARE LAZY AND DO NOT WANT TO READ, GO TO THE BOTTOM OF THE FILE AND USE THAT PROC!**
 *
 * This is the beam datum! It's a really neat effect for the game in drawing a line from one atom to another.
 * It has two parts:
 * The datum itself which manages redrawing the beam to constantly keep it pointing from the origin to the target.
 * The effect which is what the beams are made out of. They're placed in a line from the origin to target, rotated towards the target and snipped off at the end.
 * These effects are kept in a list and constantly created and destroyed (hence the proc names draw and reset, reset destroying all effects and draw creating more.)
 *
 * You can add more special effects to the beam itself by changing what the drawn beam effects do. For example you can make a vine that pricks people by making the beam_type
 * include a crossed proc that damages the crosser. Examples in venus_human_trap.dm
*/
/datum/beam
	///where the beam goes from
	var/atom/origin = null
	///where the beam goes to
	var/atom/target = null
	///list of beam objects. These have their visuals set by the visuals var which is created on starting
	var/list/elements = list()
	///icon used by the beam.
	var/icon
	///icon state of the main segments of the beam
	var/icon_state = ""
	///The beam will qdel if it's longer than this many tiles.
	var/max_distance = 0
	///the objects placed in the elements list
	var/beam_type = /obj/effect/ebeam
	///This is used as the visual_contents of beams, so you can apply one effect to this and the whole beam will look like that. never gets deleted on redrawing.
	var/obj/effect/ebeam/visuals
	///The color of the beam we're drawing.
	var/beam_color
	///If we use an emissive appearance
	var/emissive = TRUE
	/// If FALSE, redraws snap per update instead of using animate() interpolation.
	var/animate = TRUE
	/// If set will be used instead of origin's pixel_x in offset calculations
	var/override_origin_pixel_x = null
	/// If set will be used instead of origin's pixel_y in offset calculations
	var/override_origin_pixel_y = null
	/// If set will be used instead of targets's pixel_x in offset calculations
	var/override_target_pixel_x = null
	/// If set will be used instead of targets's pixel_y in offset calculations
	var/override_target_pixel_y = null
	///the layer of our beam
	var/beam_layer
	///Whether we have a cached last-drawn geometry from a previous Draw().
	var/last_draw_valid = FALSE
	///Last drawn origin tile/pixel coordinates (used as the "from" frame for animated redraws).
	var/last_origin_x = 0
	var/last_origin_y = 0
	var/last_origin_px = 0
	var/last_origin_py = 0
	///Last drawn target tile/pixel coordinates.
	var/last_target_x = 0
	var/last_target_y = 0
	var/last_target_px = 0
	var/last_target_py = 0
	///Animate time queued for the pending redraw. We take the largest (slowest glide) of any movers that triggered the redraw.
	var/pending_animate_time = 0
	///Last animation's "from" (where segments were seeded at draw time) — origin endpoint.
	var/anim_from_origin_x = 0
	var/anim_from_origin_y = 0
	var/anim_from_origin_px = 0
	var/anim_from_origin_py = 0
	///Last animation's "from" — target endpoint.
	var/anim_from_target_x = 0
	var/anim_from_target_y = 0
	var/anim_from_target_px = 0
	var/anim_from_target_py = 0
	///world.time at which the last animation began. Combined with anim_duration to estimate segments' current visual position mid-animation.
	var/anim_start_time = 0
	///Duration of the last animation, in deciseconds (matches the time= passed to animate()).
	var/anim_duration = 0

/datum/beam/New(
	origin,
	target,
	icon = 'icons/effects/beam.dmi',
	icon_state = "b_beam",
	time = INFINITY,
	max_distance = INFINITY,
	beam_type = /obj/effect/ebeam,
	beam_color = null,
	emissive = TRUE,
	animate = TRUE,
	override_origin_pixel_x = null,
	override_origin_pixel_y = null,
	override_target_pixel_x = null,
	override_target_pixel_y = null,
	beam_layer = ABOVE_ALL_MOB_LAYER
)
	src.origin = origin
	src.target = target
	src.icon = icon
	src.icon_state = icon_state
	src.max_distance = max_distance
	src.beam_type = beam_type
	src.beam_color = beam_color
	src.emissive = emissive
	src.animate = animate
	src.override_origin_pixel_x = override_origin_pixel_x
	src.override_origin_pixel_y = override_origin_pixel_y
	src.override_target_pixel_x = override_target_pixel_x
	src.override_target_pixel_y = override_target_pixel_y
	src.beam_layer = beam_layer
	if(time < INFINITY)
		QDEL_IN(src, time)

/**
 * Proc called by the atom Beam() proc. Sets up signals, and draws the beam for the first time.
 */
/datum/beam/proc/Start()
	visuals = new beam_type()
	set_up_effect(visuals, icon_state)
	Draw()
	RegisterSignals(origin, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(redrawing))
	RegisterSignals(target, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(redrawing))

/**
 * Triggered by signals set up when the beam is set up. If it's still sane to create a beam, it removes the old beam, creates a new one. Otherwise it kills the beam.
 *
 * Arguments:
 * mover: either the origin of the beam or the target of the beam that moved.
 * oldloc: from where mover moved.
 * direction: in what direction mover moved from.
 */
/datum/beam/proc/redrawing(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	if(QDELING(src))
		return
	if(QDELETED(origin) || QDELETED(target) || get_dist(origin, target) >= max_distance || origin.z != target.z)
		qdel(src)
		return
	var/queued_time = 0
	if(animate && istype(mover))
		queued_time = ICON_SIZE_ALL / max(mover.glide_size, MIN_GLIDE_SIZE) * world.tick_lag
	if(queued_time > pending_animate_time)
		pending_animate_time = queued_time
	// Synchronous: deferring via INVOKE_ASYNC would start animate() one render frame after the mob's
	// BYOND-managed glide, making the beam trail. Draw() doesn't sleep, so calling it here is safe.
	Draw()

/** Returns the last drawn endpoints for reuse by inherit_glide(), or null if undrawn. */
/datum/beam/proc/get_last_geometry()
	if(!last_draw_valid)
		return null
	return list(
		"origin_x" = last_origin_x,
		"origin_y" = last_origin_y,
		"origin_px" = last_origin_px,
		"origin_py" = last_origin_py,
		"target_x" = last_target_x,
		"target_y" = last_target_y,
		"target_px" = last_target_px,
		"target_py" = last_target_py,
	)

/** Seeds the next Draw() from saved geometry so rebuilt beams glide instead of snapping. */
/datum/beam/proc/inherit_glide(list/geometry, animate_time)
	if(!geometry || animate_time <= 0)
		return
	last_origin_x = geometry["origin_x"]
	last_origin_y = geometry["origin_y"]
	last_origin_px = geometry["origin_px"]
	last_origin_py = geometry["origin_py"]
	last_target_x = geometry["target_x"]
	last_target_y = geometry["target_y"]
	last_target_px = geometry["target_px"]
	last_target_py = geometry["target_py"]
	// Mirror into the anim "from" frame; with anim_duration 0 the next Draw() treats progress as 1 and
	// seeds segments exactly at these endpoints, then animates to the (new) live position.
	anim_from_origin_x = last_origin_x
	anim_from_origin_y = last_origin_y
	anim_from_origin_px = last_origin_px
	anim_from_origin_py = last_origin_py
	anim_from_target_x = last_target_x
	anim_from_target_y = last_target_y
	anim_from_target_px = last_target_px
	anim_from_target_py = last_target_py
	anim_duration = 0
	anim_start_time = world.time
	last_draw_valid = TRUE
	pending_animate_time = animate_time

/datum/beam/Destroy()
	QDEL_LIST(elements)
	QDEL_NULL(visuals)
	UnregisterSignal(origin, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	UnregisterSignal(target, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	target = null
	origin = null
	return ..()

/**
 * Creates the beam effects and places them in a line from the origin to the target. Sets their rotation to make the beams face the target, too.
 */
/datum/beam/proc/Draw(atom/movable/mover = null, atom/oldloc = null)
	if(SEND_SIGNAL(src, COMSIG_BEAM_BEFORE_DRAW) & BEAM_CANCEL_DRAW)
		return
	var/animate_time = pending_animate_time
	pending_animate_time = 0
	if(!animate)
		animate_time = 0
	var/origin_px = (isnull(override_origin_pixel_x) ? origin.pixel_x : override_origin_pixel_x) + origin.pixel_w
	var/origin_py = (isnull(override_origin_pixel_y) ? origin.pixel_y : override_origin_pixel_y) + origin.pixel_z
	var/target_px = (isnull(override_target_pixel_x) ? target.pixel_x : override_target_pixel_x) + target.pixel_w
	var/target_py = (isnull(override_target_pixel_y) ? target.pixel_y : override_target_pixel_y) + target.pixel_z

	// Seed from where segments visually are *now*, not where the last Draw asked them to end up.
	// If the previous animation is still in flight (e.g. consecutive-tick or mid-diagonal moves),
	// using the cached destination teleports segments forward then animates back — the diagonal jump.
	// Lerp last from→to by elapsed time to get the real current frame.
	var/progress = 1
	if(last_draw_valid && anim_duration > 0)
		progress = clamp((world.time - anim_start_time) / anim_duration, 0, 1)
	var/old_origin_x_f = last_draw_valid ? (anim_from_origin_x + (last_origin_x - anim_from_origin_x) * progress) : origin.x
	var/old_origin_y_f = last_draw_valid ? (anim_from_origin_y + (last_origin_y - anim_from_origin_y) * progress) : origin.y
	var/old_origin_px_f = last_draw_valid ? (anim_from_origin_px + (last_origin_px - anim_from_origin_px) * progress) : origin_px
	var/old_origin_py_f = last_draw_valid ? (anim_from_origin_py + (last_origin_py - anim_from_origin_py) * progress) : origin_py
	var/old_target_x_f = last_draw_valid ? (anim_from_target_x + (last_target_x - anim_from_target_x) * progress) : target.x
	var/old_target_y_f = last_draw_valid ? (anim_from_target_y + (last_target_y - anim_from_target_y) * progress) : target.y
	var/old_target_px_f = last_draw_valid ? (anim_from_target_px + (last_target_px - anim_from_target_px) * progress) : target_px
	var/old_target_py_f = last_draw_valid ? (anim_from_target_py + (last_target_py - anim_from_target_py) * progress) : target_py
	if(!last_draw_valid)
		animate_time = 0

	// Endpoints in absolute world-pixel coordinates.
	var/vector/origin_world = vector(origin.x * ICON_SIZE_X + origin_px, origin.y * ICON_SIZE_Y + origin_py)
	var/vector/target_world = vector(target.x * ICON_SIZE_X + target_px, target.y * ICON_SIZE_Y + target_py)
	var/vector/old_origin_world = vector(old_origin_x_f * ICON_SIZE_X + old_origin_px_f, old_origin_y_f * ICON_SIZE_Y + old_origin_py_f)
	var/vector/old_target_world = vector(old_target_x_f * ICON_SIZE_X + old_target_px_f, old_target_y_f * ICON_SIZE_Y + old_target_py_f)

	var/Angle = get_angle_raw(origin.x, origin.y, origin_px, origin_py, target.x, target.y, target_px, target_py)
	var/vector/beam_direction = vector(sin(Angle), cos(Angle))
	// Old angle from the interpolated endpoints.
	var/vector/old_beam_delta = old_target_world - old_origin_world
	var/OLD_DX_F = old_beam_delta.x
	var/OLD_DY_F = old_beam_delta.y
	var/old_angle
	if(!OLD_DY_F)
		old_angle = (OLD_DX_F >= 0) ? 90 : 270
	else
		old_angle = arctan(OLD_DX_F / OLD_DY_F)
		if(OLD_DY_F < 0)
			old_angle += 180
		else if(OLD_DX_F < 0)
			old_angle += 360
	var/matrix/rot_matrix = matrix()
	var/matrix/old_rot_matrix = matrix()
	var/turf/origin_turf = get_turf(origin)
	rot_matrix.Turn(Angle)
	old_rot_matrix.Turn(old_angle)
	var/raw_angle_delta = abs(Angle - old_angle)
	if(raw_angle_delta > 180) // Normalize to shortest-path angle across the 0/360 seam.
		raw_angle_delta = 360 - raw_angle_delta
	// Byond doesn't handle 180 degree rotations well
	var/animate_rotation = animate_time && raw_angle_delta < 90

	var/vector/beam_delta = target_world - origin_world
	var/DX = beam_delta.x
	var/DY = beam_delta.y
	var/N = 0
	var/length = round(beam_delta.size)
	var/old_length = round(old_beam_delta.size)
	var/vector/old_beam_direction = vector(sin(old_angle), cos(old_angle))

	var/list/old_elements = elements
	var/list/new_elements = list()

	for(N in 0 to length-1 step 32)
		if(QDELETED(src))
			break
		// Map each new segment to the same offset on the interpolated old beam.
		var/old_pos = clamp(N + 16, 0, old_length)
		var/obj/effect/ebeam/segment = new beam_type(origin_turf, src)
		new_elements += segment

		var/icon/terminal_icon = null
		if(N+32>length)
			terminal_icon = new(icon, icon_state)
			var/cut_row = length - N
			terminal_icon.DrawBox(null, 1, cut_row, 32, 32)
			// Soft alpha falloff so the tip isn't a hard line.
			var/fade_height = min(4, cut_row - 1)
			if(fade_height > 0)
				var/icon/alpha_mask = new(icon, icon_state)
				alpha_mask.DrawBox(rgb(255, 255, 255, 255), 1, 1, 32, 32)
				var/band_start = cut_row - fade_height
				for(var/y in band_start to cut_row - 1)
					var/from_tip = (cut_row - 1) - y // 0 at the tip row, fade_height-1 furthest back
					var/a = round(255 * (from_tip + 1) / (fade_height + 1), 1)
					alpha_mask.DrawBox(rgb(255, 255, 255, a), 1, y, 32, y)
				alpha_mask.DrawBox(null, 1, cut_row, 32, 32)
				terminal_icon.Blend(alpha_mask, ICON_MULTIPLY)
			segment.icon = terminal_icon
			segment.color = beam_color
		else
			set_subsegment_appearance(segment)
		if(animate_rotation)
			segment.transform = old_rot_matrix
		else
			segment.transform = rot_matrix

		var/Pixel_x = (DX == 0) ? 0 : round(sin(Angle) + 32 * sin(Angle) * (N + 16) / 32, 1)
		var/Pixel_y = (DY == 0) ? 0 : round(cos(Angle) + 32 * cos(Angle) * (N + 16) / 32, 1)

		var/final_x = segment.x
		var/final_y = segment.y
		if(abs(Pixel_x)>32)
			final_x += Pixel_x > 0 ? round(Pixel_x/32) : ceil(Pixel_x/32)
			Pixel_x %= 32
		if(abs(Pixel_y)>32)
			final_y += Pixel_y > 0 ? round(Pixel_y/32) : ceil(Pixel_y/32)
			Pixel_y %= 32
		segment.forceMove(locate(final_x, final_y, segment.z))
		var/new_pixel_x = origin_px + Pixel_x
		var/new_pixel_y = origin_py + Pixel_y
		if(animate_time)
			// Seed from interpolated old endpoints so consecutive redraws don't snap.
			var/vector/old_visual = old_origin_world + old_beam_direction * old_pos
			var/new_visual_x = final_x * ICON_SIZE_X + new_pixel_x
			var/new_visual_y = final_y * ICON_SIZE_Y + new_pixel_y
			segment.pixel_x = new_pixel_x + round(old_visual.x - new_visual_x, 1)
			segment.pixel_y = new_pixel_y + round(old_visual.y - new_visual_y, 1)
			// Segments past the old beam's end fade in instead of popping.
			if(N >= old_length)
				segment.alpha = 0
				animate(segment, alpha = 255, time = animate_time, flags = ANIMATION_PARALLEL)
			if(animate_rotation)
				animate(segment, pixel_x = new_pixel_x, pixel_y = new_pixel_y, transform = rot_matrix, time = animate_time, flags = ANIMATION_PARALLEL)
			else
				animate(segment, pixel_x = new_pixel_x, pixel_y = new_pixel_y, time = animate_time, flags = ANIMATION_PARALLEL)
		else
			segment.pixel_x = new_pixel_x
			segment.pixel_y = new_pixel_y
		if(emissive)
			segment.add_overlay(emissive_appearance(terminal_icon ? terminal_icon : icon, terminal_icon ? "" : icon_state, segment, alpha = segment.alpha))

	elements = new_elements
	// Fade out extra segments before deleting them so shrinking the beam does not pop the tail.
	var/old_count = length(old_elements)
	var/new_count = length(new_elements)
	if(animate_time && old_count > new_count && progress >= 1)
		for(var/i in 1 to new_count)
			qdel(old_elements[i])
		for(var/i in new_count + 1 to old_count)
			var/obj/effect/ebeam/dying = old_elements[i]
			// Project the dying segment onto the new beam and clamp it to the tip.
			var/proj_pos = clamp((i - 1) * ICON_SIZE_ALL + 16, 0, length)
			var/vector/proj_world = origin_world + beam_direction * proj_pos
			var/dying_world_x = dying.x * ICON_SIZE_X
			var/dying_world_y = dying.y * ICON_SIZE_Y
			var/target_px_anim = round(proj_world.x - dying_world_x, 1)
			var/target_py_anim = round(proj_world.y - dying_world_y, 1)
			dying.cut_overlays() // Remove emissive overlay so it doesn't glow while the segment fades out.
			if(animate_rotation)
				animate(dying, pixel_x = target_px_anim, pixel_y = target_py_anim, transform = rot_matrix, alpha = 0, time = animate_time, flags = ANIMATION_PARALLEL)
			else
				animate(dying, pixel_x = target_px_anim, pixel_y = target_py_anim, alpha = 0, time = animate_time, flags = ANIMATION_PARALLEL)
			QDEL_IN(dying, animate_time)
	else
		QDEL_LIST(old_elements)

	// Cache this draw's seed and destination so the next Draw() can lerp mid-animation.
	anim_from_origin_x = old_origin_x_f
	anim_from_origin_y = old_origin_y_f
	anim_from_origin_px = old_origin_px_f
	anim_from_origin_py = old_origin_py_f
	anim_from_target_x = old_target_x_f
	anim_from_target_y = old_target_y_f
	anim_from_target_px = old_target_px_f
	anim_from_target_py = old_target_py_f
	last_origin_x = origin.x
	last_origin_y = origin.y
	last_origin_px = origin_px
	last_origin_py = origin_py
	last_target_x = target.x
	last_target_y = target.y
	last_target_px = target_px
	last_target_py = target_py
	anim_start_time = world.time
	anim_duration = animate_time
	last_draw_valid = TRUE

/datum/beam/proc/set_up_effect(obj/effect/ebeam/beam_effect, effect_icon_state)
	beam_effect.icon = icon
	beam_effect.icon_state = effect_icon_state
	beam_effect.color = beam_color
	beam_effect.vis_flags = VIS_INHERIT_PLANE|VIS_INHERIT_LAYER
	beam_effect.emissive = emissive
	beam_effect.layer = beam_layer
	beam_effect.update_appearance()

///sets the sprite of the segment, using the more performant viscontents by default
/datum/beam/proc/set_subsegment_appearance(obj/effect/ebeam/segment)
	//Assign our single visual ebeam to each ebeam's vis_contents
	segment.vis_contents += visuals

//for when you don't want each segment to look identital
/datum/beam/varied
	//how many variants do we have in addition to the unnumbered state we use as a base icon state and terminal segment
	var/icon_state_variants = 1

/datum/beam/varied/New(
	origin,
	target,
	icon = 'icons/effects/beam.dmi',
	icon_state = "b_beam",
	time = INFINITY,
	max_distance = INFINITY,
	beam_type = /obj/effect/ebeam,
	beam_color = null,
	emissive = TRUE,
	animate = TRUE,
	override_origin_pixel_x = null,
	override_origin_pixel_y = null,
	override_target_pixel_x = null,
	override_target_pixel_y = null,
	beam_layer = ABOVE_ALL_MOB_LAYER,
	icon_state_variants = 1
	)
	. = ..()

	src.icon_state_variants = icon_state_variants

/datum/beam/varied/set_subsegment_appearance(obj/effect/ebeam/segment)
	//we use reall ass icon states here.
	set_up_effect(segment, "[icon_state][rand(1, icon_state_variants)]")

/obj/effect/ebeam
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	blocks_emissive = EMISSIVE_BLOCK_NONE
	var/emissive = TRUE
	var/datum/beam/owner

/obj/effect/ebeam/Initialize(mapload, beam_owner)
	owner = beam_owner
	return ..()

/obj/effect/ebeam/Destroy()
	owner = null
	return ..()

/obj/effect/ebeam/singularity_pull(atom/singularity, current_size)
	return

/obj/effect/ebeam/singularity_act()
	return

/obj/effect/ebeam/Process_Spacemove(movement_dir, continuous_move)
	return TRUE

/// A beam subtype used for advanced beams, to react to atoms entering the beam
/obj/effect/ebeam/reacting
	/// If TRUE, atoms that exist in the beam's loc when inited count as "entering" the beam
	var/react_on_init = FALSE

/obj/effect/ebeam/reacting/Initialize(mapload, beam_owner)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
		COMSIG_TURF_CHANGE = PROC_REF(on_turf_change),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	if(!isturf(loc) || isnull(owner) || mapload || !react_on_init)
		return

	for(var/atom/movable/existing as anything in loc)
		beam_entered(existing)

/obj/effect/ebeam/reacting/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(isnull(owner))
		return

	beam_entered(entered)

/obj/effect/ebeam/reacting/proc/on_exited(datum/source, atom/movable/exited)
	SIGNAL_HANDLER

	if(isnull(owner))
		return

	beam_exited(exited)

/obj/effect/ebeam/reacting/proc/on_turf_change(datum/source, path, new_baseturfs, flags, list/datum/callback/post_change_callbacks)
	SIGNAL_HANDLER

	if(isnull(owner))
		return

	beam_turfs_changed(post_change_callbacks)

/// Some atom entered the beam's line
/obj/effect/ebeam/reacting/proc/beam_entered(atom/movable/entered)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(owner, COMSIG_BEAM_ENTERED, src, entered)

/// Some atom exited the beam's line
/obj/effect/ebeam/reacting/proc/beam_exited(atom/movable/exited)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(owner, COMSIG_BEAM_EXITED, src, exited)

/// Some turf the beam covers has changed to a new turf type
/obj/effect/ebeam/reacting/proc/beam_turfs_changed(list/datum/callback/post_change_callbacks)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(owner, COMSIG_BEAM_TURFS_CHANGED, post_change_callbacks)

/// For beams that might be from a held item.
/datum/beam/held
	// Is the fishing rod held in left side hand
	var/lefthand = FALSE

	// Make these inline with final sprites
	var/righthand_s_px = 13
	var/righthand_s_py = 16

	var/righthand_e_px = 18
	var/righthand_e_py = 16

	var/righthand_w_px = -20
	var/righthand_w_py = 18

	var/righthand_n_px = -14
	var/righthand_n_py = 16

	var/lefthand_s_px = -13
	var/lefthand_s_py = 15

	var/lefthand_e_px = 24
	var/lefthand_e_py = 18

	var/lefthand_w_px = -17
	var/lefthand_w_py = 16

	var/lefthand_n_px = 13
	var/lefthand_n_py = 15

/datum/beam/held/Start()
	update_offsets(origin.dir)
	. = ..()
	RegisterSignal(origin, COMSIG_ATOM_DIR_CHANGE, PROC_REF(handle_dir_change))

/datum/beam/held/Destroy()
	UnregisterSignal(origin, COMSIG_ATOM_DIR_CHANGE)
	. = ..()

/datum/beam/held/proc/handle_dir_change(atom/movable/source, olddir, newdir)
	SIGNAL_HANDLER
	update_offsets(newdir)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/beam, redrawing))

/datum/beam/held/proc/update_offsets(user_dir)
	switch(user_dir)
		if(SOUTH)
			override_origin_pixel_x = lefthand ? lefthand_s_px : righthand_s_px
			override_origin_pixel_y = lefthand ? lefthand_s_py : righthand_s_py
		if(EAST)
			override_origin_pixel_x = lefthand ? lefthand_e_px : righthand_e_px
			override_origin_pixel_y = lefthand ? lefthand_e_py : righthand_e_py
		if(WEST)
			override_origin_pixel_x = lefthand ? lefthand_w_px : righthand_w_px
			override_origin_pixel_y = lefthand ? lefthand_w_py : righthand_w_py
		if(NORTH)
			override_origin_pixel_x = lefthand ? lefthand_n_px : righthand_n_px
			override_origin_pixel_y = lefthand ? lefthand_n_py : righthand_n_py

	override_origin_pixel_x += origin.pixel_x
	override_origin_pixel_y += origin.pixel_y

/**
 * This is what you use to start a beam. Example: origin.Beam(target, args). **Store the return of this proc if you don't set maxdist or time, you need it to delete the beam.**
 *
 * Unless you're making a custom beam effect (see the beam_type argument), you won't actually have to mess with any other procs. Make sure you store the return of this Proc, you'll need it
 * to kill the beam.
 * **Arguments:**
 * BeamTarget: Where you're beaming from. Where do you get origin? You didn't read the docs, fuck you.
 * icon_state: What the beam's icon_state is. The datum effect isn't the ebeam object, it doesn't hold any icon and isn't type dependent.
 * icon: What the beam's icon file is. Don't change this, man. All beam icons should be in beam.dmi anyways.
 * maxdistance: how far the beam will go before stopping itself. Used mainly for two things: preventing lag if the beam may go in that direction and setting a range to abilities that use beams.
 * beam_type: The type of your custom beam. This is for adding other wacky stuff for your beam only. Most likely, you won't (and shouldn't) change it.
 */
/atom/proc/Beam(atom/BeamTarget,
	icon_state="b_beam",
	icon='icons/effects/beam.dmi',
	time=INFINITY,maxdistance=INFINITY,
	beam_type=/obj/effect/ebeam,
	beam_color = null, emissive = TRUE,
	animate = TRUE,
	override_origin_pixel_x = null,
	override_origin_pixel_y = null,
	override_target_pixel_x = null,
	override_target_pixel_y = null,
	layer = ABOVE_ALL_MOB_LAYER,
	icon_state_variants = 0,
	glide_seed = null,
	glide_time = 0,
)
	var/datum/beam/newbeam

	if(icon_state_variants <= 0)
		newbeam = new(src,BeamTarget,icon,icon_state,time,maxdistance,beam_type, beam_color, emissive, animate, override_origin_pixel_x, override_origin_pixel_y, override_target_pixel_x, override_target_pixel_y, layer)
	else
		newbeam = new /datum/beam/varied(src,BeamTarget,icon,icon_state,time,maxdistance,beam_type, beam_color, emissive, animate, override_origin_pixel_x, override_origin_pixel_y, override_target_pixel_x, override_target_pixel_y, layer, icon_state_variants)
	// Seed the glide before Start()'s first Draw() runs (INVOKE_ASYNC runs it synchronously here since
	// Draw() never sleeps), so a rebuilt beam animates from its predecessor instead of snapping.
	newbeam.inherit_glide(glide_seed, glide_time)
	INVOKE_ASYNC(newbeam, TYPE_PROC_REF(/datum/beam/, Start))
	return newbeam
