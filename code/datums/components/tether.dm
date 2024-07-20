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

/datum/component/tether/Initialize(atom/tether_target, max_dist = 7, tether_name, atom/embed_target = null, start_distance = null)
	if(!ismovable(parent) || !istype(tether_target) || !tether_target.loc)
		return COMPONENT_INCOMPATIBLE

	src.tether_target = tether_target
	src.embed_target = embed_target
	src.max_dist = max_dist
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

/datum/component/tether/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED))
	if (!QDELETED(tether_target))
		UnregisterSignal(tether_target, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	if (!QDELETED(tether_beam))
		UnregisterSignal(tether_beam.visuals, list(COMSIG_CLICK, COMSIG_QDELETING))
		qdel(tether_beam)
	if (!QDELETED(embed_target))
		UnregisterSignal(embed_target, list(COMSIG_ITEM_UNEMBEDDED, COMSIG_QDELETING))

/datum/component/tether/proc/check_tether(atom/source, new_loc)
	SIGNAL_HANDLER

	if (check_snap())
		return

	if (!isturf(new_loc))
		to_chat(source, span_warning("[tether_name] prevents you from entering [new_loc]!"))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

	var/atom/movable/anchor = (source == tether_target ? parent : tether_target)
	if (get_dist(anchor, new_loc) > cur_dist)
		if (!istype(anchor) || anchor.anchored || !anchor.Move(get_step_towards(anchor, new_loc)))
			to_chat(source, span_warning("[tether_name] runs out of slack and prevents you from moving!"))
			return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

	var/atom/blocker
	var/anchor_dir = get_dir(source, anchor)
	for (var/turf/line_turf in get_line(anchor, new_loc))
		if (line_turf.density && line_turf != anchor.loc && line_turf != source.loc)
			blocker = line_turf
			break
		if (line_turf == anchor.loc || line_turf == source.loc)
			for (var/atom/in_turf in line_turf)
				if ((in_turf.flags_1 & ON_BORDER_1) && (in_turf.dir & anchor_dir))
					blocker = in_turf
					break
		else
			for (var/atom/in_turf in line_turf)
				if (in_turf.density && in_turf != source && in_turf != tether_target)
					blocker = in_turf
					break

		if (!isnull(blocker))
			break

	if (blocker)
		to_chat(source, span_warning("[tether_name] catches on [blocker] and prevents you from moving!"))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

	if (get_dist(anchor, new_loc) != cur_dist || !ismovable(source))
		return

	var/atom/movable/movable_source = source
	var/datum/drift_handler/handler = movable_source.drift_handler
	if (isnull(handler))
		return
	handler.remove_angle_force(get_angle(anchor, source))

/datum/component/tether/proc/check_snap()
	SIGNAL_HANDLER

	var/atom/atom_target = parent
	// Something broke us out, snap the tether
	if (get_dist(atom_target, tether_target) > cur_dist + 1 || !isturf(atom_target.loc) || !isturf(tether_target.loc) || atom_target.z != tether_target.z)
		atom_target.visible_message(span_warning("[atom_target]'s [tether_name] snaps!"), span_userdanger("Your [tether_name] snaps!"), span_hear("You hear a cable snapping."))
		qdel(src)

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
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		location.balloon_alert(user, "cutting the tether...")
		if (!do_after(user, 5 SECONDS, user))
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

	if (cur_dist <= 1)
		location.balloon_alert(user, "too short!")
		return

	if (cur_dist > get_dist(parent, tether_target))
		cur_dist -= 1
		location.balloon_alert(user, "tether shortened")
		return

	if (!ismovable(parent) && !ismovable(tether_target))
		location.balloon_alert(user, "too short!")
		return

	var/atom/movable/movable_parent = parent
	var/atom/movable/movable_target = tether_target

	if (istype(movable_parent) && movable_parent.Move(get_step(movable_parent.loc, get_dir(movable_parent, movable_target))))
		cur_dist -= 1
		location.balloon_alert(user, "tether shortened")
		return

	if (istype(movable_target) && movable_target.Move(get_step(movable_target.loc, get_dir(movable_target, movable_parent))))
		cur_dist -= 1
		location.balloon_alert(user, "tether shortened")
		return

	location.balloon_alert(user, "too short!")

/obj/effect/ebeam/tether
	mouse_opacity = MOUSE_OPACITY_ICON
