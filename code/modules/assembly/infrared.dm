/obj/item/assembly/infra
	name = "infrared emitter"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon_state = "infrared"
	base_icon_state = "infrared"
	custom_materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 5,
	)
	is_position_sensitive = TRUE
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	set_dir_on_move = FALSE
	/// Whether the beam is beaming
	var/on = FALSE
	/// Whether the beam is visible
	var/visible = FALSE
	/// The length the beam can go
	var/max_beam_length = 8
	/// The radius of which people can hear triggers
	var/hearing_range = 3
	/// Pass flags the beam uses to determine what it can pass through
	var/beam_pass_flags = PASSTABLE|PASSGLASS|PASSGRILLE
	/// The current active beam datum
	VAR_FINAL/datum/beam/active_beam
	/// A reference to the turf at the END of our active beam
	VAR_FINAL/turf/buffer_turf

/obj/item/assembly/infra/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/item/assembly/infra/Destroy()
	QDEL_NULL(active_beam)
	buffer_turf = null
	return ..()


/obj/item/assembly/infra/examine(mob/user)
	. = ..()
	. += span_notice("The infrared trigger is [on ? "on" : "off"].")

/// Checks if the passed movable can block the beam.
/obj/item/assembly/infra/proc/atom_blocks_beam(atom/movable/beam_atom)
	if(isnull(beam_atom))
		return FALSE
	if(beam_atom == src || beam_atom == holder)
		return FALSE
	// Blocks beams from triggering themselves, important to avoid infinite loops
	if(istype(beam_atom, /obj/effect/ebeam))
		return FALSE
	// Anti-revenant / anti-ghost guard
	if(beam_atom.invisibility)
		return FALSE
	// In general non-dense items should not block beams, but make special cases for things being thrown
	if(!beam_atom.density && !beam_atom.throwing)
		return FALSE
	// The actually important check. Ensures stuff like mobs trip it but stuff like laser projectiles don't
	if(beam_atom.pass_flags_self & beam_pass_flags)
		return FALSE
	if(isitem(beam_atom))
		var/obj/item/beam_item = beam_atom
		if(beam_item.item_flags & ABSTRACT)
			return FALSE

	return TRUE

/// Checks if the passed turf (or something on it) can block the beam.
/obj/item/assembly/infra/proc/turf_blocks_beam(turf/beam_turf)
	if(beam_turf.density)
		return TRUE
	for(var/atom/movable/blocker as anything in beam_turf)
		if(atom_blocks_beam(blocker))
			return TRUE
	return FALSE

/// Used to refresh the beam in whatever context.
/obj/item/assembly/infra/proc/make_beam()
	SHOULD_NOT_SLEEP(TRUE)

	if(!isnull(buffer_turf))
		UnregisterSignal(buffer_turf, list(COMSIG_ATOM_EXITED, COMSIG_TURF_CHANGE))
		buffer_turf = null

	QDEL_NULL(active_beam)
	if(!on || !secured)
		return

	var/atom/start_loc = holder || src
	var/turf/start_turf = start_loc.loc
	if(!istype(start_turf))
		return
	// One extra turf is added to max length to get an extra buffer
	var/list/turf/potential_turfs = get_line(start_turf, get_ranged_target_turf(start_turf, dir, max_beam_length + 1))
	if(!length(potential_turfs))
		return

	var/list/turf/final_turfs = list()
	for(var/turf/target_turf as anything in potential_turfs)
		if(target_turf != start_turf && turf_blocks_beam(target_turf))
			break
		final_turfs += target_turf

	if(!length(final_turfs))
		return

	var/turf/last_turf = final_turfs[length(final_turfs)]
	buffer_turf = get_step(last_turf, dir)

	active_beam = start_loc.Beam(
		BeamTarget = last_turf,
		beam_type = /obj/effect/ebeam/reacting/infrared,
		icon = 'icons/effects/beam.dmi',
		icon_state = "infrared",
		emissive = TRUE,
		override_target_pixel_x = pixel_x,
		override_target_pixel_y = pixel_y,
	)
	RegisterSignal(active_beam, COMSIG_BEAM_ENTERED, PROC_REF(beam_entered))
	RegisterSignal(active_beam, COMSIG_BEAM_TURFS_CHANGED, PROC_REF(beam_turfs_changed))
	update_visible()
	// Buffer can be null (if we're at map edge for an example) but this fine
	if(!isnull(buffer_turf))
		// We need to check the state of the turf at the end of the beam, to determine when we need to re-grow (if blocked)
		RegisterSignal(buffer_turf, COMSIG_ATOM_EXITED, PROC_REF(buffer_exited))
		RegisterSignal(buffer_turf, COMSIG_TURF_CHANGE, PROC_REF(buffer_changed))

/obj/item/assembly/infra/proc/beam_entered(datum/beam/source, obj/effect/ebeam/hit, atom/movable/entered)
	SIGNAL_HANDLER

	// First doesn't count
	if(hit == active_beam.elements[1])
		return
	if(!atom_blocks_beam(entered))
		return

	beam_trigger(hit, entered)

/obj/item/assembly/infra/proc/beam_turfs_changed(datum/beam/source, list/datum/callback/post_change_callbacks)
	SIGNAL_HANDLER
	// If the turfs changed it's possible something is now blocking it, remake when done
	post_change_callbacks += CALLBACK(src, PROC_REF(make_beam))

/obj/item/assembly/infra/proc/buffer_exited(turf/source, atom/movable/exited, ...)
	SIGNAL_HANDLER

	if(!atom_blocks_beam(exited))
		return

	make_beam()

/obj/item/assembly/infra/proc/buffer_changed(turf/source, path, list/new_baseturfs, flags, list/datum/callback/post_change_callbacks)
	SIGNAL_HANDLER

	post_change_callbacks += CALLBACK(src, PROC_REF(make_beam))

/obj/item/assembly/infra/proc/beam_trigger(obj/effect/ebeam/hit, atom/movable/entered)
	make_beam()
	if(!COOLDOWN_FINISHED(src, next_activate))
		return

	pulse()
	audible_message(
		message = span_infoplain("[icon2html(src, hearers(holder || src))] *beep* *beep* *beep*"),
		hearing_distance = hearing_range,
	)
	playsound(src, 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE, extrarange = hearing_range - SOUND_RANGE + 1, falloff_distance = hearing_range)
	COOLDOWN_START(src, next_activate, 3 SECONDS)

/obj/item/assembly/infra/activate()
	. = ..()
	if(!.)
		return

	toggle_on()

/obj/item/assembly/infra/toggle_secure()
	. = ..()
	make_beam()

/// Toggles the beam on or off.
/obj/item/assembly/infra/proc/toggle_on()
	on = !on
	make_beam()
	update_appearance()

/// Toggles the visibility of the beam.
/obj/item/assembly/infra/proc/toggle_visible()
	visible = !visible
	update_visible()
	update_appearance()

/// Updates the visibility of the beam (if active).
/obj/item/assembly/infra/proc/update_visible()
	if(visible)
		for(var/obj/effect/ebeam/beam as anything in active_beam?.elements)
			beam.RemoveInvisibility(REF(src))
	else
		for(var/obj/effect/ebeam/beam as anything in active_beam?.elements)
			beam.SetInvisibility(INVISIBILITY_ABSTRACT, REF(src))

/obj/item/assembly/infra/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	switch(var_name)
		if(NAMEOF(src, visible))
			update_visible()
			update_appearance()

		if(NAMEOF(src, on), NAMEOF(src, max_beam_length), NAMEOF(src, beam_pass_flags))
			make_beam()
			update_appearance()

/obj/item/assembly/infra/update_appearance(updates)
	. = ..()
	holder?.update_appearance(updates)

/obj/item/assembly/infra/update_overlays()
	. = ..()
	attached_overlays = list()
	if(on)
		attached_overlays += "[base_icon_state]_on"

	. += attached_overlays

/obj/item/assembly/infra/dropped()
	. = ..()
	if(holder)
		holder_movement() //sync the dir of the device as well if it's contained in a TTV or an assembly holder
	else
		make_beam()

/obj/item/assembly/infra/on_attach()
	. = ..()
	make_beam()
	holder.set_dir_on_move = set_dir_on_move

/obj/item/assembly/infra/on_detach()
	holder.set_dir_on_move = initial(holder.set_dir_on_move)
	. = ..()
	if(!.)
		return
	make_beam()

/obj/item/assembly/infra/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(loc == old_loc)
		return
	make_beam()
	if(!visible || forced || !movement_dir || !Adjacent(old_loc))
		return
	// Because the new beam is made in the new loc, it "jumps" from one turf to another
	// We can do an animate to pretend we're gliding between turfs rather than making a whole new beam
	var/x_move = 0
	var/y_move = 0
	if(movement_dir & NORTH)
		y_move = -32
	else if(movement_dir & SOUTH)
		y_move = 32
	if(movement_dir & WEST)
		x_move = 32
	else if(movement_dir & EAST)
		x_move = -32

	var/fake_glide_time = round(world.icon_size / glide_size * world.tick_lag, world.tick_lag)
	for(var/obj/effect/ebeam/beam as anything in active_beam?.elements)
		var/matrix/base_transform = matrix(beam.transform)
		beam.transform = beam.transform.Translate(x_move, y_move)
		animate(beam, transform = base_transform, time = fake_glide_time)

/obj/item/assembly/infra/setDir(newdir)
	var/prev_dir = dir
	. = ..()
	if(dir == prev_dir)
		return
	make_beam()

/obj/item/assembly/infra/ui_status(mob/user, datum/ui_state/state)
	return is_secured(user) ? ..() : UI_CLOSE

/obj/item/assembly/infra/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "InfraredEmitter", name)
		ui.open()

/obj/item/assembly/infra/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["visible"] = visible
	return data

/obj/item/assembly/infra/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return .

	switch(action)
		if("power")
			toggle_on()
			return TRUE
		if("visibility")
			toggle_visible()
			return TRUE

// Beam subtype for the infrared emitter
/obj/effect/ebeam/reacting/infrared
	name = "infrared beam"
	alpha = 175
