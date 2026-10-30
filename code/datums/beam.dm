/// Glows list index for full-length segments. 1 to 31 hold the last segment's glow, since it gets cut short to fit
#define BEAM_FULL_SEGMENT_GLOW_INDEX 32
/// Max number of different beam looks we keep spare visuals for
#define BEAM_MAX_LOOKS_WITH_SPARE_VISUALS 64
/// Max spare visuals we keep per look
#define BEAM_MAX_SPARE_VISUALS_PER_LOOK 4
/// Segments share one glow overlay per look instead of each building their own
#define BEAM_REUSE_SHARED_GLOWS (1<<0)
/// On a redraw, a segment that would land on the same turf is kept instead of remade
#define BEAM_REUSE_OLD_SEGMENTS (1<<1)
/// A new beam can take the visuals a finished beam with the same look left behind
#define BEAM_REUSE_SPARE_VISUALS (1<<2)
/// All of the above. Only plain /datum/beam and /obj/effect/ebeam get these, subtypes have to opt in (see reuse_flags_by_beam_type)
#define BEAM_REUSE_ALL (BEAM_REUSE_SHARED_GLOWS | BEAM_REUSE_OLD_SEGMENTS | BEAM_REUSE_SPARE_VISUALS)

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
	///Cache of the last segment's icon cut short to fit, "[icon]" -> icon_state -> icon per cut row (1 to 31). See get_terminal_icon_cut_at()
	var/static/list/cached_terminal_icons
	///Our beam's alpha
	var/alpha = 255
	///The beam will qdel if it's longer than this many tiles.
	var/max_distance = 0
	///the objects placed in the elements list
	var/beam_type = /obj/effect/ebeam
	///This is used as the visual_contents of beams, so you can apply one effect to this and the whole beam will look like that. never gets deleted on redrawing.
	var/obj/effect/ebeam/visuals
	///Key for how our beam looks, "[icon]|[icon_state]|[beam_color]|[emissive]|[beam_layer]". Only set if our visuals can go to the next beam that looks the same
	var/visuals_look_key
	///Visuals left behind by finished beams, waiting for a new beam with the same look. look -> list(the look's appearance, then the spares)
	var/static/list/spare_visuals_by_look
	///The color of the beam we're drawing.
	var/beam_color
	///If we use an emissive appearance, and if so, what type?
	var/emissive = EMISSIVE_NO_BLOOM
	///Alpha (strength) of our emissive
	var/emissive_alpha = 255
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
	///world.time our current Draw() started, null when not drawing. Stored as a time so if Draw() runtimes we're only stuck for the rest of that tick
	var/draw_start_time
	///Something asked for a Draw() while we were already drawing, so we draw again once we're done
	var/redraw_requested_mid_draw = FALSE
	///Glow overlays shared by every beam that looks like ours on our plane offset (see BEAM_FULL_SEGMENT_GLOW_INDEX for the layout)
	var/list/shared_glows
	///Plane offset our glows were made for. Changes with the z-level, so we grab a new list when it does
	var/shared_glows_plane_offset
	///All the shared glows lists, by "[icon]|[icon_state]|[emissive]|[alpha]|[emissive_alpha]|[plane offset]"
	var/static/list/shared_glows_by_look
	///Which BEAM_REUSE_* flags we use, worked out in Start() from our beam type and segment type
	var/reuse_flags = NONE
	///Reuse flags for beam subtypes, exact type only. Anything not listed reuses nothing and works like it always did. These are not datum vars deliberately, so new subtypes/ones in downstreams are unaffected.
	var/static/list/reuse_flags_by_beam_type = list(
		// Tesla bolts come in bursts and never redraw, and every segment rolls its own icon state, so nothing's worth keeping
		/datum/beam/varied = BEAM_REUSE_SHARED_GLOWS | BEAM_REUSE_SPARE_VISUALS,
		// Fishing lines and borg vacuum hoses redraw whenever their holder walks or turns
		/datum/beam/held = BEAM_REUSE_OLD_SEGMENTS,
		/datum/beam/held/vacuum = BEAM_REUSE_OLD_SEGMENTS,
	)
	///Reuse flags for segment subtypes, exact type only. A beam only uses a flag if its beam type allows it too. These are not datum vars deliberately, so new subtypes/ones in downstreams are unaffected.
	var/static/list/reuse_flags_by_segment_type = list(
		// These follow a mob or projectile around, so they redraw a lot
		/obj/effect/ebeam/chain = BEAM_REUSE_SHARED_GLOWS | BEAM_REUSE_OLD_SEGMENTS,
		/obj/effect/ebeam/cosmic = BEAM_REUSE_SHARED_GLOWS | BEAM_REUSE_OLD_SEGMENTS,
		/obj/effect/ebeam/curse_arm = BEAM_REUSE_SHARED_GLOWS | BEAM_REUSE_OLD_SEGMENTS,
		/obj/effect/ebeam/electrodes_nozap = BEAM_REUSE_SHARED_GLOWS | BEAM_REUSE_OLD_SEGMENTS,
		/obj/effect/ebeam/medical = BEAM_REUSE_SHARED_GLOWS | BEAM_REUSE_OLD_SEGMENTS,
		// Kept vine segments still hurt whoever steps on them. No glows, we haven't tested those on vines
		/obj/effect/ebeam/vine = BEAM_REUSE_OLD_SEGMENTS,
		// Nothing draws these with a glow
		/obj/effect/ebeam/goliath = BEAM_REUSE_OLD_SEGMENTS,
		/obj/effect/ebeam/tether = BEAM_REUSE_OLD_SEGMENTS,
		// Glows only. Kept segments would keep their turf signals and light too, and we haven't tested that
		/obj/effect/ebeam/reacting/electrodes = BEAM_REUSE_SHARED_GLOWS,
	)

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
	emissive_alpha = 255,
	animate = TRUE,
	override_origin_pixel_x = null,
	override_origin_pixel_y = null,
	override_target_pixel_x = null,
	override_target_pixel_y = null,
	beam_layer = ABOVE_ALL_MOB_LAYER,
	alpha = 255,
)
	src.origin = origin
	src.target = target
	src.icon = icon
	src.icon_state = icon_state
	src.alpha = alpha
	src.max_distance = max_distance
	src.beam_type = beam_type
	src.beam_color = beam_color
	src.emissive = emissive
	src.emissive_alpha = emissive_alpha
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
	// Plain /datum/beam and /obj/effect/ebeam reuse everything, subtypes only what they're listed for, and we only use what both types allow
	var/beam_type_reuse_flags = type == /datum/beam ? BEAM_REUSE_ALL : reuse_flags_by_beam_type[type]
	var/segment_type_reuse_flags = beam_type == /obj/effect/ebeam ? BEAM_REUSE_ALL : reuse_flags_by_segment_type[beam_type]
	reuse_flags = beam_type_reuse_flags & segment_type_reuse_flags
	// Reuse visuals a finished beam with our look left behind (see Destroy()). Our look has to work as a text key, so runtime icons don't
	if((reuse_flags & BEAM_REUSE_SPARE_VISUALS) && isfile(icon) && istext(icon_state) && (isnull(beam_color) || istext(beam_color)))
		// 9 digits, since "[beam_layer]" only keeps 6 and two layers could end up with the same key
		visuals_look_key = "[icon]|[icon_state]|[beam_color]|[emissive]|[num2text(beam_layer, 9)]"
		var/list/spares_for_look = LAZYACCESS(spare_visuals_by_look, visuals_look_key)
		var/obj/effect/ebeam/taken_spare_visuals = null
		// Index 1 is the look's appearance, the spares come after
		for(var/spare_index in length(spares_for_look) to 2 step -1)
			taken_spare_visuals = spares_for_look[spare_index]
			spares_for_look.Cut(spare_index)
			// Something else might've deleted it while it was waiting
			if(!QDELETED(taken_spare_visuals))
				break
			taken_spare_visuals = null
		if(taken_spare_visuals)
			visuals = taken_spare_visuals
		else
			visuals = new beam_type()
			set_up_effect(visuals, icon_state)
			if(!spares_for_look)
				add_look_for_spare_visuals()
	else
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
	var/list/spares_for_look = visuals_look_key ? LAZYACCESS(spare_visuals_by_look, visuals_look_key) : null
	// Only leave our visuals behind if there's room and nothing else can reach them (no refs, weak ref or tag), so nobody ends up holding another beam's visuals
	var/has_room_and_no_other_holders = spares_for_look && length(spares_for_look) <= BEAM_MAX_SPARE_VISUALS_PER_LOOK && !QDELETED(visuals) && refcount(visuals) == 1 && !visuals.weak_reference && !visuals.tag
	// They also have to be unchanged, so still our look's appearance and nothing an appearance doesn't cover (vis_contents, traits, owner, var edits)
	if(has_room_and_no_other_holders && visuals.appearance == spares_for_look[1] && !length(visuals.vis_contents) && !visuals._status_traits && !visuals.owner && !(visuals.datum_flags & DF_VAR_EDITED))
		// Stop any animation on them. One that ended where it started looks unchanged, so the check above can't see it
		animate(visuals)
		spares_for_look += visuals
		visuals = null
	else
		QDEL_NULL(visuals)
	UnregisterSignal(origin, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	UnregisterSignal(target, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	target = null
	origin = null
	return ..()

// These are macros instead of procs to save a proc call per segment - this is hot!

/// Declares final_x and final_y, the turf the segment lands on (counted from start_atom's), and segment_pixel_x_on_turf and segment_pixel_y_on_turf, its pixel offset on that turf
// No sideways offset for a beam running straight along an axis. Whole tiles move the segment onto another turf (rounded toward start_atom), the rest stays as pixel offset
#define BEAM_DECLARE_SEGMENT_POSITION(start_atom) \
	var/segment_pixel_x_on_turf = (delta_x == 0) ? 0 : round(sin_angle + sin_angle * (segment_start + 16), 1);\
	var/segment_pixel_y_on_turf = (delta_y == 0) ? 0 : round(cos_angle + cos_angle * (segment_start + 16), 1);\
	var/final_x = start_atom.x;\
	var/final_y = start_atom.y;\
	if(abs(segment_pixel_x_on_turf) > 32) {\
		final_x += segment_pixel_x_on_turf > 0 ? round(segment_pixel_x_on_turf / 32) : ceil(segment_pixel_x_on_turf / 32);\
		segment_pixel_x_on_turf %= 32;\
	}\
	if(abs(segment_pixel_y_on_turf) > 32) {\
		final_y += segment_pixel_y_on_turf > 0 ? round(segment_pixel_y_on_turf / 32) : ceil(segment_pixel_y_on_turf / 32);\
		segment_pixel_y_on_turf %= 32;\
	}

/// Sets a segment's alpha, layer and pixel offsets in Draw(), sliding it over from where the old beam had it when we animate
// Segments start as far along the old beam (as it was mid-animation) as they end up along the new one, so redraws don't snap. Ones past its end fade in
#define BEAM_PLACE_AND_ANIMATE_SEGMENT \
	segment.alpha = alpha;\
	segment.layer = beam_layer;\
	var/new_pixel_x = origin_px + segment_pixel_x_on_turf;\
	var/new_pixel_y = origin_py + segment_pixel_y_on_turf;\
	if(animate_time) {\
		var/vector/old_visual = old_origin_world + old_beam_direction * clamp(segment_start + 16, 0, old_length);\
		var/new_visual_x = final_x * ICON_SIZE_X + new_pixel_x;\
		var/new_visual_y = final_y * ICON_SIZE_Y + new_pixel_y;\
		segment.pixel_x = new_pixel_x + round(old_visual.x - new_visual_x, 1);\
		segment.pixel_y = new_pixel_y + round(old_visual.y - new_visual_y, 1);\
		if(segment_start >= old_length) {\
			segment.alpha = 0;\
			animate(segment, alpha = alpha, time = animate_time, flags = ANIMATION_PARALLEL);\
		}\
		if(animate_rotation) {\
			animate(segment, pixel_x = new_pixel_x, pixel_y = new_pixel_y, transform = rot_matrix, time = animate_time, flags = ANIMATION_PARALLEL);\
		} else {\
			animate(segment, pixel_x = new_pixel_x, pixel_y = new_pixel_y, time = animate_time, flags = ANIMATION_PARALLEL);\
		}\
	} else {\
		segment.pixel_x = new_pixel_x;\
		segment.pixel_y = new_pixel_y;\
	}

/// Gives a segment its own emissive overlay, for when it's not using a shared glow
#define BEAM_GIVE_SEGMENT_ITS_OWN_EMISSIVE segment.add_overlay(emissive_appearance(terminal_icon ? terminal_icon : icon, terminal_icon ? "" : icon_state, segment, alpha = segment.alpha * emissive_alpha / 255, effect_type = emissive))

/**
 * Creates the beam effects and places them in a line from the origin to the target. Sets their rotation to make the beams face the target, too.
 */
/datum/beam/proc/Draw(atom/movable/mover = null, atom/oldloc = null)
	// Placing a segment can set off something that moves the beam's ends mid-Draw(). Rather than drawing inside our own Draw(), we redraw once we're done
	if(draw_start_time == world.time)
		redraw_requested_mid_draw = TRUE
		return
	if((SEND_SIGNAL(src, COMSIG_BEAM_BEFORE_DRAW) & BEAM_CANCEL_DRAW) || QDELETED(src))
		return
	// draw_start_time is still set from an earlier tick, so that Draw() runtimed and never finished. Go ahead anyway
	draw_start_time = world.time
	redraw_requested_mid_draw = FALSE
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

	var/angle = get_angle_raw(origin.x, origin.y, origin_px, origin_py, target.x, target.y, target_px, target_py)
	var/sin_angle = sin(angle)
	var/cos_angle = cos(angle)
	var/vector/beam_direction = vector(sin_angle, cos_angle)
	// Old angle from the interpolated endpoints.
	var/vector/old_beam_delta = old_target_world - old_origin_world
	var/old_delta_x = old_beam_delta.x
	var/old_delta_y = old_beam_delta.y
	var/old_angle
	if(!old_delta_y)
		old_angle = (old_delta_x >= 0) ? 90 : 270
	else
		old_angle = arctan(old_delta_x / old_delta_y)
		if(old_delta_y < 0)
			old_angle += 180
		else if(old_delta_x < 0)
			old_angle += 360
	var/matrix/rot_matrix = matrix()
	var/matrix/old_rot_matrix = matrix()
	var/turf/origin_turf = get_turf(origin)
	rot_matrix.Turn(angle)
	old_rot_matrix.Turn(old_angle)
	var/raw_angle_delta = abs(angle - old_angle)
	if(raw_angle_delta > 180) // Normalize to shortest-path angle across the 0/360 seam.
		raw_angle_delta = 360 - raw_angle_delta
	// Byond doesn't handle 180 degree rotations well
	var/animate_rotation = animate_time && raw_angle_delta < 90

	var/vector/beam_delta = target_world - origin_world
	var/delta_x = beam_delta.x
	var/delta_y = beam_delta.y
	var/beam_length = round(beam_delta.size)
	var/old_length = round(old_beam_delta.size)
	var/vector/old_beam_direction = vector(sin(old_angle), cos(old_angle))

	var/list/old_elements = elements
	var/list/new_elements = list()
	// Use the shared glows for our look if our types allow it, instead of building an emissive overlay for every segment every Draw()
	if(emissive && (reuse_flags & BEAM_REUSE_SHARED_GLOWS))
		var/origin_plane_offset = GET_TURF_PLANE_OFFSET(origin_turf)
		if(isnull(shared_glows) || origin_plane_offset != shared_glows_plane_offset)
			shared_glows_plane_offset = origin_plane_offset
			shared_glows = get_shared_glows_for_look()
	var/old_count = length(old_elements)
	// TRUE at the index of each old segment we're keeping
	var/list/kept_old_segment_indexes
	// Keep an old segment when a new one would land on its turf, if our types allow it. Otherwise every segment gets made fresh
	if(old_count && (reuse_flags & BEAM_REUSE_OLD_SEGMENTS))
		var/keepable_old_segment_count = old_count
		// If the beam got shorter and its tail is fading out, only keep segments the new beam still covers so the tail fades like it always did
		if(animate_time && progress >= 1)
			keepable_old_segment_count = min(old_count, ceil(beam_length / 32))
		var/list/old_segment_index_by_turf = list()
		// Backwards, so each turf points at the first old segment on it
		for(var/old_index in keepable_old_segment_count to 1 step -1)
			var/obj/effect/ebeam/old_segment = old_elements[old_index]
			if(!QDELETED(old_segment) && old_segment.loc)
				old_segment_index_by_turf[old_segment.loc] = old_index

		for(var/segment_start in 0 to beam_length - 1 step 32)
			if(QDELETED(src))
				break
			BEAM_DECLARE_SEGMENT_POSITION(origin_turf)
			var/turf/destination_turf = locate(final_x, final_y, origin_turf.z)

			var/obj/effect/ebeam/segment = null
			var/matching_old_segment_index = destination_turf ? old_segment_index_by_turf[destination_turf] : null
			if(matching_old_segment_index)
				segment = old_elements[matching_old_segment_index]
				// Diagonal beams can put two segments in a row on one turf, so point the turf at the next old segment if it's there too
				var/obj/effect/ebeam/next_old_segment = matching_old_segment_index < keepable_old_segment_count ? old_elements[matching_old_segment_index + 1] : null
				old_segment_index_by_turf[destination_turf] = (next_old_segment?.loc == destination_turf) ? matching_old_segment_index + 1 : null
				// It got deleted or moved, or we already kept it, so make a new one like before
				if(QDELETED(segment) || segment.loc != destination_turf || kept_old_segment_indexes?[matching_old_segment_index])
					segment = null
			// TRUE if this is an old segment we're keeping. Kept segments never leave their turf
			var/is_kept_old_segment = !isnull(segment)
			// TRUE if it still shows our visuals from the last Draw()
			var/is_showing_our_visuals = FALSE
			if(is_kept_old_segment)
				if(!kept_old_segment_indexes)
					kept_old_segment_indexes = new /list(keepable_old_segment_count)
				kept_old_segment_indexes[matching_old_segment_index] = TRUE
				// Undo what the last Draw() did to a kept segment so it ends up exactly like a new one
				if(anim_duration)
					animate(segment)
				// Keep its glow, it gets swapped further down if it needs a different one
				if(!segment.shared_glow)
					segment.cut_overlays()
				// If it was the last segment last time, it has a cut-short icon and our color, so reset those
				if(matching_old_segment_index == old_count && segment.icon != initial(segment.icon))
					segment.icon = initial(segment.icon)
					segment.color = initial(segment.color)
				else
					is_showing_our_visuals = TRUE
			else
				segment = new beam_type(origin_turf, src)
			new_elements += segment

			var/terminal_icon = null
			if(segment_start + 32 > beam_length)
				terminal_icon = get_terminal_icon_cut_at(beam_length - segment_start)
				if(is_showing_our_visuals)
					segment.vis_contents -= visuals
				segment.icon = terminal_icon
				segment.color = beam_color
			else if(!is_showing_our_visuals)
				set_subsegment_appearance(segment)
			if(animate_rotation)
				segment.transform = old_rot_matrix
			else
				segment.transform = rot_matrix

			if(!is_kept_old_segment)
				segment.forceMove(destination_turf)
			BEAM_PLACE_AND_ANIMATE_SEGMENT
			// Shared glows are made for our z-level's plane offset. If placing the segment knocked it into nullspace, it builds its own glow below instead
			if(shared_glows && segment.loc)
				var/glow_index = terminal_icon ? beam_length - segment_start : BEAM_FULL_SEGMENT_GLOW_INDEX
				var/mutable_appearance/shared_glow = shared_glows[glow_index] || build_shared_glow(segment, glow_index, terminal_icon)
				// A kept segment already has the right glow, unless it went from last segment to full one (or back), or the last segment's length changed
				if(segment.shared_glow != shared_glow)
					if(segment.shared_glow)
						segment.cut_overlays()
					segment.shared_glow = shared_glow
					segment.add_overlay(shared_glow)
			else if(emissive)
				BEAM_GIVE_SEGMENT_ITS_OWN_EMISSIVE
	else
		// Nothing to keep (first Draw(), or a beam that doesn't keep segments), so every segment is new and we skip the keeping logic
		for(var/segment_start in 0 to beam_length - 1 step 32)
			if(QDELETED(src))
				break
			var/obj/effect/ebeam/segment = new beam_type(origin_turf, src)
			new_elements += segment

			var/terminal_icon = null
			if(segment_start + 32 > beam_length)
				terminal_icon = get_terminal_icon_cut_at(beam_length - segment_start)
				segment.icon = terminal_icon
				segment.color = beam_color
			else
				set_subsegment_appearance(segment)
			if(animate_rotation)
				segment.transform = old_rot_matrix
			else
				segment.transform = rot_matrix

			BEAM_DECLARE_SEGMENT_POSITION(segment)
			segment.forceMove(locate(final_x, final_y, segment.z))
			BEAM_PLACE_AND_ANIMATE_SEGMENT
			if(shared_glows && segment.loc)
				var/glow_index = terminal_icon ? beam_length - segment_start : BEAM_FULL_SEGMENT_GLOW_INDEX
				segment.shared_glow = shared_glows[glow_index] || build_shared_glow(segment, glow_index, terminal_icon)
				segment.add_overlay(segment.shared_glow)
			else if(emissive)
				BEAM_GIVE_SEGMENT_ITS_OWN_EMISSIVE

	// Something our segments set off deleted the beam. Destroy() already got the old segments, so we delete the new ones
	if(QDELETED(src))
		QDEL_LIST(new_elements)
		draw_start_time = null
		return
	elements = new_elements
	// Fade out extra segments before deleting them so shrinking the beam does not pop the tail.
	var/new_count = length(new_elements)
	if(animate_time && old_count > new_count && progress >= 1)
		// Old segments we kept are part of the new beam now, don't delete them
		if(kept_old_segment_indexes)
			for(var/old_index in 1 to new_count)
				if(!kept_old_segment_indexes[old_index])
					qdel(old_elements[old_index])
		else
			for(var/old_index in 1 to new_count)
				qdel(old_elements[old_index])
		var/list/fading_segments_to_delete = new /list(old_count - new_count)
		for(var/old_index in new_count + 1 to old_count)
			var/obj/effect/ebeam/dying = old_elements[old_index]
			// Project the dying segment onto the new beam and clamp it to the tip.
			var/proj_pos = clamp((old_index - 1) * ICON_SIZE_ALL + 16, 0, beam_length)
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
			fading_segments_to_delete[old_count - old_index + 1] = dying
		QDEL_LIST_IN(fading_segments_to_delete, animate_time)
	else if(kept_old_segment_indexes)
		for(var/old_index in 1 to old_count)
			if(!kept_old_segment_indexes[old_index])
				qdel(old_elements[old_index])
		old_elements.Cut()
	else
		QDEL_LIST(old_elements)
	// Deleting old segments can set off something that deletes the beam too, and then Destroy() already got the new ones
	if(QDELETED(src))
		draw_start_time = null
		return

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
	draw_start_time = null
	// Something asked for a Draw() while we were drawing, so draw again from where the ends are now
	if(redraw_requested_mid_draw)
		redraw_requested_mid_draw = FALSE
		Draw()

#undef BEAM_DECLARE_SEGMENT_POSITION
#undef BEAM_PLACE_AND_ANIMATE_SEGMENT
#undef BEAM_GIVE_SEGMENT_ITS_OWN_EMISSIVE

/**
 * Returns the icon for the beam's last segment, cut short so the beam ends right at its target
 *
 * Beams are drawn in 32 pixel segments, so unless a beam's length is a multiple of 32 its last segment would poke out past the target.
 * To stop that we copy our sprite, clear every pixel row from cut_row up, and fade out the few rows just below the cut so the end isn't a hard line.
 *
 * That's a fair bit of icon work, so for sprites loaded from a file we only build each cut once and keep it in cached_terminal_icons.
 * Keeping them costs nothing extra, since BYOND holds onto every rsc icon for the rest of the round anyway and dedupes identical ones.
 * Icons made at runtime all read as "" when turned into text, so we can't tell them apart to cache them and build them every time.
 *
 * Arguments:
 * * cut_row - the first pixel row to clear, 1 to 31. Everything below it stays
 */
/datum/beam/proc/get_terminal_icon_cut_at(cut_row)
	var/icon_file_key = (isfile(icon) && istext(icon_state)) ? "[icon]" : null
	var/list/terminal_icons_for_state = null
	if(icon_file_key)
		terminal_icons_for_state = cached_terminal_icons?[icon_file_key]?[icon_state]
		if(terminal_icons_for_state?[cut_row])
			return terminal_icons_for_state[cut_row]
	var/icon/terminal_icon = new(icon, icon_state)
	terminal_icon.DrawBox(null, 1, cut_row, 32, 32)
	// Soft alpha falloff so the tip isn't a hard line.
	var/fade_height = min(4, cut_row - 1)
	if(fade_height > 0)
		var/icon/alpha_mask = new(icon, icon_state)
		alpha_mask.DrawBox(rgb(255, 255, 255, 255), 1, 1, 32, 32)
		var/band_start = cut_row - fade_height
		for(var/row in band_start to cut_row - 1)
			var/from_tip = (cut_row - 1) - row // 0 at the tip row, fade_height-1 furthest back
			var/row_alpha = round(255 * (from_tip + 1) / (fade_height + 1), 1)
			alpha_mask.DrawBox(rgb(255, 255, 255, row_alpha), 1, row, 32, row)
		alpha_mask.DrawBox(null, 1, cut_row, 32, 32)
		terminal_icon.Blend(alpha_mask, ICON_MULTIPLY)
	var/cropped_icon = fcopy_rsc(terminal_icon)
	if(!icon_file_key)
		return cropped_icon
	if(!terminal_icons_for_state)
		terminal_icons_for_state = new /list(31)
		LAZYINITLIST(cached_terminal_icons)
		LAZYSET(cached_terminal_icons[icon_file_key], icon_state, terminal_icons_for_state)
	terminal_icons_for_state[cut_row] = cropped_icon
	return cropped_icon

/// Returns the shared glows list for our look and plane offset, or null if our icon can't be a text key (runtime icons all turn into "")
/datum/beam/proc/get_shared_glows_for_look()
	var/icon_file_key = (isfile(icon) && istext(icon_state)) ? "[icon]" : null
	if(!icon_file_key)
		return null
	var/glows_look_key = "[icon_file_key]|[icon_state]|[emissive]|[alpha]|[emissive_alpha]|[shared_glows_plane_offset]"
	var/list/glows_for_look = LAZYACCESS(shared_glows_by_look, glows_look_key)
	if(!glows_for_look)
		glows_for_look = new /list(BEAM_FULL_SEGMENT_GLOW_INDEX)
		LAZYSET(shared_glows_by_look, glows_look_key, glows_for_look)
	return glows_for_look

/// Saves our new visuals' appearance as our look's, so finished beams with our look can leave their visuals behind for the next one (see Destroy())
/datum/beam/proc/add_look_for_spare_visuals()
	if(length(spare_visuals_by_look) >= BEAM_MAX_LOOKS_WITH_SPARE_VISUALS)
		// Player-picked and random colors could make endless looks, so the oldest look and its spares get dropped
		var/list/oldest_look_spares = spare_visuals_by_look[spare_visuals_by_look[1]]
		for(var/spare_index in 2 to length(oldest_look_spares))
			qdel(oldest_look_spares[spare_index])
		spare_visuals_by_look.Cut(1, 2)
	LAZYSET(spare_visuals_by_look, visuals_look_key, list(visuals.appearance))

/**
 * Builds one of our shared glows, the emissive overlay every segment of our look shares
 *
 * Arguments:
 * * segment - a segment from this Draw() on our z-level. Its location picks the glow's layer and plane offset, its alpha picks how strong it is
 * * glow_index - the last segment's cut row, or BEAM_FULL_SEGMENT_GLOW_INDEX for full ones
 * * terminal_icon - the last segment's cut-short icon, null for full ones
 */
/datum/beam/proc/build_shared_glow(obj/effect/ebeam/segment, glow_index, terminal_icon)
	var/mutable_appearance/shared_glow = emissive_appearance(terminal_icon ? terminal_icon : icon, terminal_icon ? "" : icon_state, segment, alpha = segment.alpha * emissive_alpha / 255, effect_type = emissive)
	shared_glows[glow_index] = shared_glow
	return shared_glow

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
	alpha = 255,
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
	///The shared glow we're showing, if our beam uses shared glows (see /datum/beam/var/shared_glows)
	var/mutable_appearance/shared_glow

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
	alpha = 255,
	emissive_alpha = 255,
)
	var/datum/beam/newbeam

	if(icon_state_variants <= 0)
		newbeam = new(src,BeamTarget,icon,icon_state,time,maxdistance,beam_type, beam_color, emissive, emissive_alpha, animate, override_origin_pixel_x, override_origin_pixel_y, override_target_pixel_x, override_target_pixel_y, layer, alpha)
	else
		newbeam = new /datum/beam/varied(src,BeamTarget,icon,icon_state,time,maxdistance,beam_type, beam_color, emissive, emissive_alpha, animate, override_origin_pixel_x, override_origin_pixel_y, override_target_pixel_x, override_target_pixel_y, layer, alpha, icon_state_variants)
	// Seed the glide before Start()'s first Draw() runs (INVOKE_ASYNC runs it synchronously here since
	// Draw() never sleeps), so a rebuilt beam animates from its predecessor instead of snapping.
	newbeam.inherit_glide(glide_seed, glide_time)
	INVOKE_ASYNC(newbeam, TYPE_PROC_REF(/datum/beam/, Start))
	return newbeam

#undef BEAM_FULL_SEGMENT_GLOW_INDEX
#undef BEAM_MAX_LOOKS_WITH_SPARE_VISUALS
#undef BEAM_MAX_SPARE_VISUALS_PER_LOOK
#undef BEAM_REUSE_SHARED_GLOWS
#undef BEAM_REUSE_OLD_SEGMENTS
#undef BEAM_REUSE_SPARE_VISUALS
#undef BEAM_REUSE_ALL
