/obj/structure/flippedtable
	name = "flipped table"
	desc = "A flipped table."
	icon = 'modular_nova/modules/tableflip/icons/flipped_tables.dmi'
	icon_state = "table"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	opacity = FALSE
	interaction_flags_click = NEED_DEXTERITY
	/// type of table that this becomes when unflipped
	var/table_type = /obj/structure/table

/obj/structure/flippedtable/Initialize(mapload)
	. = ..()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/flippedtable/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(table_type == /obj/structure/table/glass)
		if(istype(mover) && (mover.pass_flags & PASSGLASS))
			return TRUE
	if(istype(mover, /obj/projectile))
		var/obj/projectile/projectile = mover
		//Lets through bullets shot from behind the cover of the table
		if(projectile.trajectory && angle2dir_cardinal(projectile.trajectory.angle) == dir)
			return TRUE
		return FALSE
	if(border_dir == dir)
		return FALSE
	return TRUE

/obj/structure/flippedtable/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(table_type == /obj/structure/table/glass)
		if(istype(leaving) && (leaving.pass_flags & PASSGLASS))
			return

	if(istype(leaving, /obj/projectile))
		return

	if(direction == dir)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/flippedtable/click_ctrl_shift(mob/user)
	if(!istype(user) || iscorticalborer(user))
		return FALSE
	user.balloon_alert_to_viewers("flipping table upright...")
	if(do_after(user, max_integrity * 0.25))
		var/obj/structure/table/unflipped_table = new table_type(src.loc)
		unflipped_table.update_integrity(src.get_integrity())
		if(flags_1 & HOLOGRAM_1) // no unflipping holographic tables into reality
			var/area/station/holodeck/holo_area = get_area(unflipped_table)
			if(!istype(holo_area))
				qdel(unflipped_table)
				return
			holo_area.linked.add_to_spawned(unflipped_table)
		if(custom_materials)
			unflipped_table.set_custom_materials(custom_materials)
		user.balloon_alert_to_viewers("table flipped upright")
		playsound(src, 'sound/items/trayhit2.ogg', 100)
		qdel(src)

//TABLES
/obj/structure/table/
	interaction_flags_click = NEED_DEXTERITY

/obj/structure/table/click_ctrl_shift(mob/user)
	if(!istype(user) || iscorticalborer(user))
		return
	if(!can_flip)
		return
	user.balloon_alert_to_viewers("flipping table...")
	if(!do_after(user, max_integrity * 0.25))
		return

	var/obj/structure/flippedtable/flipped_table = new flipped_table_type(src.loc)
	flipped_table.name = "flipped [src.name]"
	flipped_table.desc = "[src.desc]<br> It's been flipped on its side!"
	flipped_table.icon_state = src.base_icon_state
	var/new_dir = get_dir(user, flipped_table)
	flipped_table.dir = new_dir
	if(new_dir == NORTH)
		flipped_table.layer = BELOW_MOB_LAYER
	flipped_table.max_integrity = src.max_integrity
	flipped_table.update_integrity(src.get_integrity())
	flipped_table.table_type = src.type
	if(istype(src, /obj/structure/table/greyscale)) //Greyscale tables need greyscale flags!
		flipped_table.material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR
	if(flags_1 & HOLOGRAM_1) // no flipping holographic tables into reality
		var/area/station/holodeck/holo_area = get_area(flipped_table)
		if(!istype(holo_area))
			qdel(flipped_table)
			return
		holo_area.linked.add_to_spawned(flipped_table)
	//Finally, add the custom materials, so the flags still apply to it
	flipped_table.set_custom_materials(custom_materials)

	var/sound_volume = 100
	var/balloon_message = "table flipped"
	var/user_pacifist = HAS_TRAIT(user, TRAIT_PACIFISM)

	if (user_pacifist)
		balloon_message = "table gently flipped"
		sound_volume = 40

	user.balloon_alert_to_viewers(balloon_message)
	playsound(src, 'sound/items/trayhit2.ogg', sound_volume)
	qdel(src)

	var/turf/throw_target = get_step(flipped_table, flipped_table.dir)
	if (!isnull(throw_target) && !user_pacifist)
		for (var/atom/movable/movable_entity in flipped_table.loc)
			if (movable_entity == flipped_table)
				continue
			if (movable_entity.anchored)
				continue
			if (movable_entity.invisibility > SEE_INVISIBLE_LIVING)
				continue
			if(!ismob(movable_entity) && !isobj(movable_entity))
				continue
			if(movable_entity.throwing || (movable_entity.movement_type & (FLOATING|FLYING)))
				continue
			movable_entity.safe_throw_at(throw_target, range = 1, speed = 1, force = MOVE_FORCE_NORMAL, gentle = TRUE)

/obj/structure/table
	var/flipped_table_type = /obj/structure/flippedtable
	var/can_flip = TRUE

/obj/structure/table/rolling
	can_flip = FALSE

/obj/structure/table/wood/shuttle_bar
	can_flip = FALSE

/obj/structure/table/reinforced
	can_flip = FALSE

/obj/structure/table/optable
	can_flip = FALSE

/obj/structure/table/survival_pod
	can_flip = FALSE
