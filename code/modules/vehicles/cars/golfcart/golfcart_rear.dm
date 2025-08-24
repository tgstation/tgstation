#define GOLFCART_RIDING_SOURCE "riding_golfcart"
#define HUMAN_LOWER_LAYER (MOB_LAYER)
#define HUMAN_RIDING_LAYER (ABOVE_MOB_LAYER + 0.02)

/obj/golfcart_rear
	name = "golf cart bed"
	icon = 'icons/obj/toys/golfcart_split.dmi'
	icon_state = "rear_hitbox"
	density = TRUE
	alpha = 1
	can_buckle = TRUE
	max_buckled_mobs = 2
	glide_size = MAX_GLIDE_SIZE
	layer = 0
	var/obj/vehicle/ridden/golfcart/parent = null
	///List of offsets for buckled passengers. Indexed by passenger index, then by direction string.
	var/static/list/list/vector/passenger_offsets = list(
		list(
			TEXT_NORTH = vector(-4, 0, 24),
			TEXT_SOUTH = vector(4, 0, 4),
			TEXT_EAST = vector(4, 0, 13),
			TEXT_WEST = vector(-4, 0, 13)
		),
		list(
			TEXT_NORTH = vector(4, 0, 20),
			TEXT_SOUTH = vector(-4, 8, 0),
			TEXT_EAST = vector(-8, 0, 13),
			TEXT_WEST = vector(8, 0, 13)
		)
	)
	///Same as [/obj/golfcart_rear/passenger_offsets], except for when the passenger is lying down.
	var/static/list/list/vector/lying_down_passenger_offsets = list(
		list(
			TEXT_NORTH = vector(0, 0, 16),
			TEXT_SOUTH = vector(0, 0, 8),
			TEXT_EAST = vector(2, 0, 8),
			TEXT_WEST = vector(-2, 0, 8),
		)
	)

/obj/golfcart_rear/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	if (!parent)
		return
	return parent.take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)

/obj/golfcart_rear/attack_hand(mob/user, list/modifiers)
	if(!isnull(parent.cargo))
		parent.unload()
		return TRUE
	return ..()

/obj/golfcart_rear/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if (!parent.cargo)
		return
	tool.play_tool_sound(src, 50)
	parent.unload()
	return ITEM_INTERACT_SUCCESS

/obj/golfcart_rear/mouse_drop_receive(atom/dropped, mob/user, params)
	if (!is_type_in_typecache(dropped, parent.allowed_cargo) || is_type_in_typecache(dropped, parent.banned_cargo))
		return ..()
	if (has_buckled_mobs())
		balloon_alert(user, "blocked!")
		return ..()
	var/obj/dropped_obj = dropped
	return parent.load(dropped_obj)

/obj/golfcart_rear/examine(mob/user)
	if (!parent)
		. = ..()
		. += span_warning("A lone golf cart bed must be a bad omen...")
		return
	return parent.examine(user)

/obj/golfcart_rear/examine_more(mob/user)
	if (!parent)
		return ..()
	return parent.examine_more(user)

/obj/golfcart_rear/doMove(atom/destination)
	. = ..()
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		buckled_mob.Move(destination, dir)
		// realistically should do something if move fails but not sure what

/obj/golfcart_rear/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if (!parent)
		return
	if (mover == parent)
		return TRUE
	if (mover in parent.buckled_mobs)
		return TRUE
	if (parent.allow_crawler_through(mover))
		return TRUE

/obj/golfcart_rear/Move(atom/newloc, direct, glide_size_override = 0, update_dir = TRUE)
	if(pulledby)
		var/olddir = dir
		var/newdir
		if (direct & (EAST | WEST))
			newdir = (direct & EAST) ? EAST : WEST
		else if (direct & (NORTH | SOUTH))
			newdir = (direct & NORTH) ? NORTH : SOUTH
		else
			newdir = direct
		. = ..()
		dir = newdir
		if (get_step(src, turn(dir, 180)) != get_turf(pulledby))
			setDir(turn(dir, 180))
		var/atom/behind = get_step(src, dir)
		if (!behind.Enter(parent))
			setDir(olddir)
			behind = get_step(src, dir)
		parent.set_glide_size(pulledby.glide_size)
		parent.forceMove(behind)
		parent.setDir(dir)
		parent.update_appearance(UPDATE_ICON)
		return

	return parent.Move(get_step(parent, get_dir(loc, newloc)), direct)

/obj/golfcart_rear/proc/allow_movement_between_bed_passengers(atom/source, atom/mover)
	if (mover == parent)
		return COMSIG_COMPONENT_PERMIT_PASSAGE
	if (parent && (mover in parent.buckled_mobs))
		return COMSIG_COMPONENT_PERMIT_PASSAGE
	if ((source in buckled_mobs) && (mover in buckled_mobs))
		return COMSIG_COMPONENT_PERMIT_PASSAGE

///Called when the golfcart rear turns in order to keep the buckled mobs in the right places
/obj/golfcart_rear/proc/update_passenger_layers(new_dir)
	if (isnull(new_dir))
		new_dir = dir
	var/layer = HUMAN_RIDING_LAYER
	var/invert_layer = FALSE
	if (new_dir & SOUTH)
		invert_layer = TRUE
	new_dir = "[new_dir]"
	for(var/i in 1 to buckled_mobs.len)
		var/mob/living/passenger = buckled_mobs[i]
		var/vector/offset
		if (passenger.body_position == LYING_DOWN)
			offset = lying_down_passenger_offsets[i][new_dir]
		else
			offset = passenger_offsets[i][new_dir]
		passenger.add_offsets(GOLFCART_RIDING_SOURCE,
			x_add = offset.x,
			y_add = offset.y,
			z_add = offset.z,
			animate = FALSE)
		passenger.layer = layer + ((i * 0.01) - 0.01) * (-invert_layer)

/obj/golfcart_rear/proc/on_dir_changed(datum/source, old_dir, new_dir)
	if (!has_buckled_mobs())
		return
	update_passenger_layers(new_dir)

/obj/golfcart_rear/Initialize(mapload, obj/vehicle/ridden/golfcart/progenitor)
	. = ..()
	parent = progenitor
	RegisterSignal(parent, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(on_dir_changed))

/obj/golfcart_rear/update_overlays()
	. = ..()
	if (dir & NORTH)
		var/mutable_appearance/hitbox_overlay = mutable_appearance(icon, "rear_hitbox_overlay", layer)
		hitbox_overlay.pixel_y += 32
		. += hitbox_overlay
	else if (dir & SOUTH)
		. += mutable_appearance(icon, "rear_hitbox_lower", OBJ_LAYER + 0.01)
	if(!parent.cargo)
		return
	var/vector/rear_offsets = parent.get_rear_offset()
	. += parent.generate_cargo_overlay(-rear_offsets.x, -rear_offsets.y, layer=layer)

///Called when a passenger tries lying down/getting up. Automatically drops out people who can't stay on
/obj/golfcart_rear/proc/passenger_falling_down(atom/source, new_bodypos)
	if (!isliving(source))
		return // should runtime?
	if (new_bodypos == STANDING_UP)
		update_passenger_layers()
		return
	if (buckled_mobs.len <= 1)
		update_passenger_layers()
		return // allow 1 laying down mob
	var/mob/living/passenger = source
	unbuckle_mob(passenger, TRUE)

/obj/golfcart_rear/is_buckle_possible(mob/living/target, force, check_loc)
	. = ..()
	// these are to_viewers because you can buckle someone on their behalf
	if (parent && parent.cargo)
		balloon_alert_to_viewers("blocked!")
		return FALSE
	if (target.body_position != STANDING_UP)
		if (!has_buckled_mobs())
			return TRUE
		balloon_alert_to_viewers("stand up!")
		return FALSE
	for (var/mob/blocker in buckled_mobs)
		if (!isliving(blocker))
			balloon_alert_to_viewers("blocked!")
			return FALSE
		var/mob/living/living_blocker = blocker
		if (living_blocker.body_position != STANDING_UP)
			balloon_alert_to_viewers("blocked!")
			return FALSE
	return TRUE

/obj/golfcart_rear/post_buckle_mob(mob/living/buckled_mob)
	buckled_mob.pulledby?.stop_pulling()
	RegisterSignal(buckled_mob, COMSIG_ATOM_TRIED_PASS, PROC_REF(allow_movement_between_bed_passengers))
	RegisterSignal(buckled_mob, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(passenger_falling_down))
	. = ..()
	update_passenger_layers()

/obj/golfcart_rear/post_unbuckle_mob(mob/living/buckled_mob)
	UnregisterSignal(buckled_mob, COMSIG_ATOM_TRIED_PASS)
	UnregisterSignal(buckled_mob, COMSIG_LIVING_SET_BODY_POSITION)
	buckled_mob.remove_offsets(GOLFCART_RIDING_SOURCE)
	if (buckled_mob.body_position == LYING_DOWN)
		buckled_mob.layer = LYING_MOB_LAYER
	else
		buckled_mob.layer = initial(buckled_mob.layer)
	return ..()

/obj/golfcart_rear/Destroy()
	if (parent)
		UnregisterSignal(parent, COMSIG_ATOM_POST_DIR_CHANGE)
	if (!QDELETED(parent))
		qdel(parent)
	parent = null
	return ..()

#undef HUMAN_LOWER_LAYER
#undef HUMAN_RIDING_LAYER
#undef GOLFCART_RIDING_SOURCE
