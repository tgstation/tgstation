/// Creates a tether between two objects that limits movement range. Tether requires LOS and can be adjusted by left/right clicking its
/datum/component/tether
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// Other side of the tether
	var/atom/tether_target
	/// Maximum (and initial) distance that this tether can be adjusted to
	var/max_dist
	/// What the tether is going to be called
	var/tether_name
	/// Current extension distance
	var/cur_dist
	/// Embedded item that the tether "should" originate from
	var/atom/embed_target
	/// Beam effect
	var/datum/beam/tether_beam
	/// Tether module if we were created by one
	var/obj/item/mod/module/tether/parent_module
	/// Ref of source, if any, for TRAIT_TETHER_ATTACHED we add
	var/tether_trait_source
	/// If TRUE, only add TRAIT_TETHER_ATTACHED to our parent
	var/no_target_trait
	/// Are we currently attempting to forcefully shorten the tether?
	var/force_moving_target = FALSE

/datum/component/tether/Initialize(atom/tether_target, max_dist = 7, tether_name, atom/embed_target = null, start_distance = null, \
	parent_module = null, tether_trait_source = null, no_target_trait = FALSE)
	if(!ismovable(parent) || !istype(tether_target) || !tether_target.loc)
		return COMPONENT_INCOMPATIBLE
	if(isatom(tether_trait_source))
		stack_trace("Tried to add a [src.type] with a tether_trait_source that is a hard ref! Use REF() first before passing!")
		return COMPONENT_INCOMPATIBLE

	src.tether_target = tether_target
	src.embed_target = embed_target
	src.max_dist = max_dist
	src.parent_module = parent_module
	src.tether_trait_source = tether_trait_source
	src.no_target_trait = no_target_trait
	cur_dist = max_dist
	if (start_distance != null)
		cur_dist = start_distance
	var/datum/beam/beam = tether_target.Beam(parent, "line", 'icons/obj/clothing/modsuit/mod_modules.dmi', emissive = FALSE, beam_type = /obj/effect/ebeam/tether)
	tether_beam = beam
	if (ispath(tether_name, /atom))
		var/atom/tmp = tether_name
		src.tether_name = initial(tmp.name)
	else
		src.tether_name = tether_name
	if (!isnull(tether_trait_source))
		ADD_TRAIT(parent, TRAIT_TETHER_ATTACHED, tether_trait_source)
		if (!no_target_trait)
			ADD_TRAIT(tether_target, TRAIT_TETHER_ATTACHED, tether_trait_source)

/datum/component/tether/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(check_tether))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(check_snap))
	RegisterSignal(tether_target, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(check_tether))
	RegisterSignal(tether_target, COMSIG_MOVABLE_MOVED, PROC_REF(check_snap))
	RegisterSignal(tether_target, COMSIG_QDELETING, PROC_REF(on_delete))
	RegisterSignal(tether_beam.visuals, COMSIG_CLICK, PROC_REF(beam_click))
	// Also snap if the beam gets deleted, more of a backup check than anything
	RegisterSignal(tether_beam.visuals, COMSIG_QDELETING, PROC_REF(on_delete))

	if (!isnull(embed_target))
		RegisterSignal(embed_target, COMSIG_ITEM_UNEMBEDDED, PROC_REF(on_embedded_removed))
		RegisterSignal(embed_target, COMSIG_QDELETING, PROC_REF(on_delete))

	if (!isnull(parent_module))
		RegisterSignals(parent_module, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED, COMSIG_MOD_TETHER_SNAP), PROC_REF(snap))
		RegisterSignal(parent_module, COMSIG_MODULE_TRIGGERED, PROC_REF(on_parent_use))

/datum/component/tether/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED))
	if (!isnull(tether_trait_source))
		REMOVE_TRAIT(parent, TRAIT_TETHER_ATTACHED, tether_trait_source)
	if (!QDELETED(tether_beam))
		UnregisterSignal(tether_beam.visuals, list(COMSIG_CLICK, COMSIG_QDELETING))
		qdel(tether_beam)
	if (!QDELETED(embed_target))
		UnregisterSignal(embed_target, list(COMSIG_ITEM_UNEMBEDDED, COMSIG_QDELETING))
	if (!QDELETED(tether_target))
		UnregisterSignal(tether_target, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
		if (!isnull(tether_trait_source) && !no_target_trait)
			REMOVE_TRAIT(tether_target, TRAIT_TETHER_ATTACHED, tether_trait_source)
		SEND_SIGNAL(tether_target, COMSIG_ATOM_TETHER_SNAPPED, tether_trait_source)
	SEND_SIGNAL(parent, COMSIG_ATOM_TETHER_SNAPPED, tether_trait_source)

/datum/component/tether/proc/check_tether(atom/source, new_loc)
	SIGNAL_HANDLER

	if (check_snap(is_moving = TRUE))
		return

	if (!isturf(new_loc))
		to_chat(source, span_warning("[tether_name] prevents you from entering [new_loc]!"))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

	// If this was called, we know its a movable
	var/atom/movable/movable_source = source
	var/atom/movable/anchor = (source == tether_target ? parent : tether_target)

	// Ignore distance limitations if we're attempting to move the other part of the tether
	if (get_dist(anchor, new_loc) > cur_dist && !force_moving_target)
		if (!istype(anchor) || anchor.anchored || anchor.move_resist > movable_source.move_force)
			to_chat(source, span_warning("[tether_name] runs out of slack and prevents you from moving!"))
			return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

		force_moving_target = TRUE
		if (!try_adjust_position(anchor, new_loc, source))
			force_moving_target = FALSE
			to_chat(source, span_warning("[tether_name] runs out of slack and prevents you from moving!"))
			return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

		force_moving_target = FALSE

	var/atom/blocker = check_line(anchor, new_loc, list(source))
	if (blocker)
		if (!istype(anchor) || anchor.anchored || anchor.move_resist > movable_source.move_force)
			to_chat(source, span_warning("[tether_name] runs out of slack and prevents you from moving!"))
			return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

		// If the tether would snag on something when we move, see if we could move to the side to get LOS back
		if (!try_adjust_position(anchor, new_loc, source))
			to_chat(source, span_warning("[tether_name] catches on [blocker] and prevents you from moving!"))
			return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

	if (get_dist(anchor, new_loc) != cur_dist || !ismovable(source) || force_moving_target)
		return

	var/datum/drift_handler/handler = movable_source.drift_handler
	if (handler)
		handler.remove_angle_force(get_angle(anchor, source))

/// Try adjust the anchor's position to move closer to the target or regain LOS
/// true_source is an optional argument in case we're looking for a LOS/closer turf to a new location rather than the actual owner, and need to ignore them
/datum/component/tether/proc/try_adjust_position(atom/movable/anchor, atom/target, atom/true_source)
	if (!istype(anchor) || anchor.anchored)
		return FALSE

	if (anchor.x == target.x && anchor.y == target.y)
		return TRUE

	var/datum/can_pass_info/pass_info = new(no_id = TRUE)
	pass_info.pass_flags = anchor.pass_flags
	pass_info.movement_type = anchor.movement_type
	if (isliving(anchor))
		var/mob/living/living_anchor = anchor
		pass_info.is_living = TRUE
		pass_info.mob_size = living_anchor.mob_size
		pass_info.incorporeal_move = living_anchor.incorporeal_move
		pass_info.is_bot = isbot(living_anchor)

	var/list/pass_turfs = list()
	var/turf/anchor_turf = get_turf(anchor)

	var/primary_cardinal = null
	if (abs(anchor.x - target.x) > abs(anchor.y - target.y))
		primary_cardinal = anchor.x > target.x ? WEST : EAST
	else
		primary_cardinal = anchor.y > target.y ? SOUTH : NORTH

	var/anchor_dir = get_dir(anchor, target)
	if (primary_cardinal == anchor_dir)
		pass_turfs += get_step(anchor, primary_cardinal)
	else if (get_dist(anchor, get_step(target, REVERSE_DIR(primary_cardinal))) >= get_dist(anchor, get_step(target, REVERSE_DIR(anchor_dir))))
		pass_turfs += get_step(anchor, anchor_dir)
		pass_turfs += get_step(anchor, primary_cardinal)
	else
		pass_turfs += get_step(anchor, primary_cardinal)
		pass_turfs += get_step(anchor, anchor_dir)

	// Make a list of secondary dirs to try and sidestep into if we cannot go in our main direction
	var/list/match_dirs = null
	if (primary_cardinal == NORTH || primary_cardinal == SOUTH)
		match_dirs = list(EAST, WEST)
	else
		match_dirs = list(NORTH, SOUTH)

	for (var/match_dir in match_dirs)
		if ((match_dir & primary_cardinal) != anchor_dir)
			pass_turfs += get_step(anchor, match_dir | primary_cardinal)

	for (var/match_dir in match_dirs)
		pass_turfs += get_step(anchor, match_dir)

	// The final list is something like (direct path, main cardinal, diagonals to main cardinal, 90* dirs to the main cardinal)
	// Whichever one we manage to move onto first is our pick

	var/list/turf_cache = list()
	for (var/turf/pass_turf in pass_turfs) // keep the typecheck in case we accidentally go out of map bounds
		if (pass_turf.density || get_dist(pass_turf, target) > cur_dist)
			continue
		if (anchor_turf.LinkBlockedWithAccess(pass_turf, pass_info))
			continue
		if (check_line(pass_turf, target, list(anchor, true_source), turf_cache))
			continue
		if (anchor.Move(pass_turf))
			return TRUE
	return FALSE

/// Check LOS availibility of a tile, returns a blocking atom, if any
/// turf_cache could be used to reduce the amount of calculations if multiple lines are cast and expected to have multiple shared turfs
/// by sharing located results
/datum/component/tether/proc/check_line(atom/start, atom/end, list/to_ignore, list/turf_cache = list())
	var/turf/start_loc = get_turf(start)
	var/turf/end_loc = get_turf(end)
	var/start_dir = get_dir(start_loc, end_loc)
	var/end_dir = REVERSE_DIR(start_dir)
	var/list/turf/turf_line = get_line(start_loc, end_loc)
	for (var/turf/line_turf in turf_line)
		if (turf_cache[line_turf])
			return turf_cache[line_turf]

		if (line_turf.density && line_turf != start_loc && line_turf != end_loc)
			turf_cache[line_turf] = line_turf
			return line_turf

		if (line_turf == start_loc)
			for (var/atom/in_turf in line_turf)
				if (in_turf.density && (in_turf.flags_1 & ON_BORDER_1) && (in_turf.dir & start_dir) && in_turf != start && !(in_turf in to_ignore))
					turf_cache[line_turf] = in_turf
					return in_turf
			continue

		if (line_turf == end_loc)
			for (var/atom/in_turf in line_turf)
				if (in_turf.density && (in_turf.flags_1 & ON_BORDER_1) && (in_turf.dir & end_dir) && in_turf != end && !(in_turf in to_ignore))
					turf_cache[line_turf] = in_turf
					return in_turf
			continue

		for (var/atom/in_turf in line_turf)
			if (!in_turf.density || (in_turf in to_ignore))
				continue
			if ((in_turf.flags_1 & ON_BORDER_1))
				// If the tether is in a straight line, we can ignore border objects parallel to us
				if (!(in_turf.dir & start_dir) && !(in_turf.dir & end_dir))
					continue
				// Also ignore objects that we don't intersect with
				if (!(get_step(in_turf, in_turf.dir) in turf_line))
					continue

			turf_cache[line_turf] = in_turf
			return in_turf

		turf_cache[line_turf] = null

/datum/component/tether/proc/check_snap(atom/movable/source, atom/old_loc, dir, forced, list/old_locs, is_moving = FALSE)
	SIGNAL_HANDLER

	var/atom/atom_target = parent
	// Something broke us out, snap the tether
	if (get_dist(atom_target, tether_target) > cur_dist + 1 || !isturf(atom_target.loc) || !isturf(tether_target.loc) || atom_target.z != tether_target.z)
		snap()
	else if (!is_moving && check_line(atom_target, tether_target) && !(try_adjust_position(atom_target, tether_target) || try_adjust_position(tether_target, atom_target)))
		snap()

/datum/component/tether/proc/snap()
	SIGNAL_HANDLER

	var/atom/atom_target = parent
	atom_target.visible_message(span_warning("[atom_target]'s [tether_name] snaps!"), span_userdanger("Your [tether_name] snaps!"), span_hear("You hear a cable snapping."))
	playsound(atom_target, 'sound/effects/snap.ogg', 50, TRUE)
	qdel(src)

/datum/component/tether/proc/on_parent_use(obj/item/mod/module/module, atom/target)
	SIGNAL_HANDLER

	if (get_turf(target) == get_turf(tether_target))
		return MOD_ABORT_USE

/datum/component/tether/proc/on_delete()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/tether/proc/on_embedded_removed(atom/source, mob/living/victim)
	SIGNAL_HANDLER
	parent.AddComponent(/datum/component/tether, source, max_dist, tether_name, cur_dist)
	qdel(src)

/datum/component/tether/proc/beam_click(atom/source, atom/location, control, params, mob/user)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(process_beam_click), source, location, params, user)

/datum/component/tether/proc/process_beam_click(atom/source, atom/location, params, mob/user)
	var/turf/nearest_turf
	for (var/turf/line_turf in get_line(get_turf(parent), get_turf(tether_target)))
		if (user.CanReach(line_turf))
			nearest_turf = line_turf
			break

	if (isnull(nearest_turf))
		return

	if (!user.can_perform_action(nearest_turf))
		nearest_turf.balloon_alert(user, "cannot reach!")
		return

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		location.balloon_alert(user, "cutting the tether...")
		if (!do_after(user, 2 SECONDS, user, (user == parent || user == tether_target) ? IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE : NONE))
			return

		qdel(src)
		location.balloon_alert(user, "tether cut!")
		to_chat(parent, span_danger("Your [tether_name] has been cut!"))
		return

	if (LAZYACCESS(modifiers, RIGHT_CLICK))
		if (cur_dist >= max_dist)
			location.balloon_alert(user, "no coil remaining!")
			return
		cur_dist += 1
		location.balloon_alert(user, "tether extended")
		return

	if (cur_dist <= 0)
		location.balloon_alert(user, "too short!")
		return

	if (cur_dist > CEILING(get_dist(parent, tether_target), 1))
		cur_dist -= 1
		location.balloon_alert(user, "tether shortened")
		return

	if (!ismovable(parent) && !ismovable(tether_target))
		location.balloon_alert(user, "too short!")
		return

	var/atom/movable/movable_parent = parent
	var/atom/movable/movable_target = tether_target

	if (istype(movable_parent) && !movable_parent.anchored && movable_parent.move_resist <= movable_target.move_force && movable_parent.Move(get_step(movable_parent.loc, get_dir(movable_parent, movable_target))))
		cur_dist -= 1
		location.balloon_alert(user, "tether shortened")
		return

	if (istype(movable_target) && !movable_target.anchored && movable_target.move_resist <= movable_parent.move_force && movable_target.Move(get_step(movable_target.loc, get_dir(movable_target, movable_parent))))
		cur_dist -= 1
		location.balloon_alert(user, "tether shortened")
		return

	location.balloon_alert(user, "too short!")

/obj/effect/ebeam/tether
	mouse_opacity = MOUSE_OPACITY_ICON
