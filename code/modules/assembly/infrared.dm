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
	var/on = FALSE
	var/visible = FALSE
	var/max_beam_length = 9
	var/hearing_range = 3
	var/beam_pass_flags = PASSTABLE|PASSGLASS|PASSGRILLE
	VAR_FINAL/datum/beam/active_beam

/obj/item/assembly/infra/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/item/assembly/infra/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/item/assembly/infra/examine(mob/user)
	. = ..()
	. += span_notice("The infrared trigger is [on ? "on" : "off"].")

/// Checks if the passed movable can block the beam.
/obj/item/assembly/infra/proc/atom_blocks_beam(atom/movable/beam_atom)
	if(isnull(beam_atom))
		return FALSE
	if(beam_atom == src || beam_atom == holder)
		return FALSE
	if(istype(beam_atom, /obj/effect/ebeam))
		return FALSE
	if(!beam_atom.density)
		return FALSE
	if(beam_atom.pass_flags_self & beam_pass_flags)
		return FALSE
	if(isitem(beam_atom))
		var/obj/item/beam_item = beam_atom
		if(beam_item.item_flags & ABSTRACT)
			return FALSE

	return TRUE

/// Checks if the passed turf (or something on it) can block the beam.
/obj/item/assembly/infra/proc/turf_blocks_beam(turf/beam_turf)
	if(isnull(beam_turf))
		return FALSE
	if(beam_turf.density)
		return TRUE
	for(var/atom/movable/blocker as anything in beam_turf)
		if(atom_blocks_beam(blocker))
			return TRUE
	return FALSE

/obj/item/assembly/infra/proc/make_beam()
	QDEL_NULL(active_beam)
	if(!on || !secured)
		return

	var/turf/start_turf = get_turf(src)
	if(isnull(start_turf))
		return
	var/list/turf/potential_turfs = get_line(start_turf, get_ranged_target_turf(start_turf, dir, max_beam_length))
	if(!length(potential_turfs))
		return

	var/list/turf/final_turfs = list()
	for(var/turf/target_turf as anything in potential_turfs)
		final_turfs += target_turf
		// We do this break after adding to turfs so we get 1 extra turf of leeway
		if(turf_blocks_beam(target_turf))
			break

	if(!length(final_turfs))
		return
	var/turf/last_turf = final_turfs[length(final_turfs)]
	var/atom/start_loc = holder || src

	active_beam = start_loc.Beam(
		BeamTarget = last_turf,
		maxdistance = max_beam_length + 1,
		beam_type = /obj/effect/ebeam/reacting/infrared,
		icon = 'icons/effects/beam.dmi',
		icon_state = "1-full",
		beam_color = COLOR_RED,
		emissive = TRUE,
		override_target_pixel_x = pixel_x,
		override_target_pixel_y = pixel_y,
	)
	RegisterSignal(active_beam, COMSIG_BEAM_ENTERED, PROC_REF(beam_entered))
	RegisterSignal(active_beam, COMSIG_BEAM_EXITED, PROC_REF(beam_exited))
	RegisterSignal(active_beam, COMSIG_BEAM_TURFS_CHANGED, PROC_REF(beam_turfs_changed))
	update_visible()

/obj/item/assembly/infra/proc/beam_entered(datum/beam/source, obj/effect/ebeam/hit, atom/movable/entered)
	SIGNAL_HANDLER

	// You can't trigger off the final beam, it's a buffer element
	if(hit == active_beam.elements[length(active_beam.elements)])
		return
	if(!atom_blocks_beam(entered))
		return

	INVOKE_ASYNC(src, PROC_REF(beam_trigger), hit, entered)

/obj/item/assembly/infra/proc/beam_exited(datum/beam/source, obj/effect/ebeam/hit, atom/movable/exited)
	SIGNAL_HANDLER

	if(!atom_blocks_beam(exited))
		return

	// Something that blocked us has left the beam, remake the beam to accomodate
	INVOKE_ASYNC(src, PROC_REF(make_beam))

/obj/item/assembly/infra/proc/beam_turfs_changed(datum/beam/source, list/datum/callback/post_change_callbacks)
	SIGNAL_HANDLER
	// If the turfs changed it's possible something is now blocking it, remake when done
	post_change_callbacks += CALLBACK(src, PROC_REF(make_beam))

/obj/item/assembly/infra/proc/beam_trigger(obj/effect/ebeam/hit, atom/movable/entered)
	if(!COOLDOWN_FINISHED(src, next_activate))
		return

	pulse()
	audible_message(
		message = span_infoplain("[icon2html(src, hearers(src))] *beep* *beep* *beep*"),
		hearing_distance = hearing_range,
	)
	playsound(src, 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE, extrarange = hearing_range - SOUND_RANGE + 1)
	COOLDOWN_START(src, next_activate, 3 SECONDS)
	make_beam()

/obj/item/assembly/infra/activate()
	. = ..()
	if(!.)
		return

	toggle_on()

/obj/item/assembly/infra/toggle_secure()
	. = ..()
	make_beam()

/obj/item/assembly/infra/proc/toggle_on()
	on = !on
	make_beam()
	update_appearance()

/obj/item/assembly/infra/proc/toggle_visible()
	visible = !visible
	update_visible()
	update_appearance()

/obj/item/assembly/infra/proc/update_visible()
	if(visible)
		for(var/obj/effect/ebeam/beam as anything in active_beam?.elements)
			beam.RemoveInvisibility(type)
	else
		for(var/obj/effect/ebeam/beam as anything in active_beam?.elements)
			beam.SetInvisibility(INVISIBILITY_ABSTRACT, type)

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
		INVOKE_ASYNC(src, PROC_REF(make_beam))

/obj/item/assembly/infra/on_attach()
	. = ..()
	make_beam()

/obj/item/assembly/infra/on_detach()
	. = ..()
	if(!.)
		return
	make_beam()

/obj/item/assembly/infra/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(loc == old_loc)
		return
	make_beam()
	if(!visible || forced || !movement_dir || !loc.Adjacent(old_loc))
		return
	// Fake move between tiles to look better
	// var/x_move = 0
	// var/y_move = 0
	// if(movement_dir & NORTH)
	// 	y_move = -32
	// if(movement_dir & SOUTH)
	// 	y_move = 32
	// if(movement_dir & WEST)
	// 	x_move = 32
	// if(movement_dir & EAST)
	// 	x_move = -32
	// for(var/obj/effect/ebeam/beam as anything in active_beam?.elements)
	// 	var/pre_x = beam.pixel_x
	// 	var/pre_y = beam.pixel_y
	// 	beam.pixel_x += x_move
	// 	beam.pixel_y += y_move
	// 	animate(beam, pixel_x = pre_x, pixel_y = pre_y, time = 32 / glide_size)

// /obj/item/assembly/infra/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
// 	. = ..()
// 	if(!olddir)
// 		return
// 	setDir(olddir)
// 	olddir = NONE

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

/obj/item/assembly/infra/ui_act(action, params)
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

/obj/effect/ebeam/reacting/infrared
	name = "infrared beam"
	alpha = 200
