#define GOLFCART_RIDING_SOURCE "riding_golfcart"
#define HUMAN_LOWER_LAYER (MOB_LAYER)
#define CARGO_HITBOX_LAYER (ABOVE_ALL_MOB_LAYER)
#define BELOW_HUMAN_HITBOX_LAYER (ABOVE_MOB_LAYER + 0.01)
#define HUMAN_RIDING_LAYER (BELOW_HUMAN_HITBOX_LAYER + 0.02)

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
	///Currently buckled cargo
	var/obj/cargo = null
	///Was this move triggered by the parent?
	var/moving_from_parent = FALSE
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

///Try to load something onto the cart. This proc may fail if the obj is not in allowed_cargo or is in banned_cargo.
/obj/golfcart_rear/proc/load(obj/to_load)
	if (!to_load)
		return
	if (cargo)
		return
	if (to_load.anchored)
		return
	if (to_load.has_buckled_mobs())
		// can't stack buckles and whatever
		return
	if (istype(to_load, /obj/structure/closet))
		var/obj/structure/closet/crate = to_load
		crate.close()
	to_load.forceMove(src)
	cargo = to_load
	layer = CARGO_HITBOX_LAYER
	parent.update_appearance(UPDATE_ICON)

/obj/golfcart_rear/proc/unload()
	if (!cargo)
		return
	var/list/candidates = list(
		get_step(src, turn(dir, 180)),
		get_step(src, turn(dir, 90)),
		get_step(src, turn(dir, 270)),
	)
	var/atom/dropoff = get_turf(src)
	for (var/atom/turf in candidates)
		if (turf.Enter(cargo, src))
			dropoff = turf
			break
	cargo.forceMove(dropoff)
	cargo = null
	layer = BELOW_HUMAN_HITBOX_LAYER
	parent.update_appearance(UPDATE_ICON)

///Jiggles the cargo_image as long as someone is trying to jiggle it.
/obj/golfcart_rear/proc/check_if_shake()
	if (!cargo)
		return FALSE

	// Assuming we decide to shake again, how long until we check to shake again
	var/next_check_time = 0.75 SECONDS

	// How long we shake between different calls of Shake(), so that it starts shaking and stops, instead of a steady shake
	var/shake_duration =  0.125 SECONDS

	for(var/mob/living/mob in cargo.contents)
		if(DOING_INTERACTION_WITH_TARGET(mob, src))
			// Shake and queue another check_if_shake
			parent.shake_cargo(1, 6, shake_duration)
			addtimer(CALLBACK(src, PROC_REF(check_if_shake)), next_check_time)
			return TRUE

	// If we reach here, nobody is resisting, so don't shake
	return FALSE

/obj/golfcart_rear/proc/after_escape(obj/container, mob/living/user)
	user?.visible_message(
		span_danger("The [container] falls off of the [src]!"),
		span_userdanger("You knock the crate off the [src]!")
	)
	container.SpinAnimation(5, 1)
	if (user && istype(container, /obj/structure/closet))
		var/obj/structure/closet/closet = container
		if (closet.can_open(user))
			closet.open()

///Unload the container from the golfcart if it is cargo
/obj/golfcart_rear/proc/easy_escape(mob/living/user, obj/container)
	if (!cargo || cargo != container)
		return
	unload()
	after_escape(container, user)

///Unload the container from the golfcart if it is cargo and after a little jiggling and a some time
/obj/golfcart_rear/proc/hard_escape(mob/living/user, obj/container)
	addtimer(CALLBACK(src, PROC_REF(check_if_shake)), 0)
	if (do_after(user, 5 SECONDS, target=src, timed_action_flags=IGNORE_USER_LOC_CHANGE))
		if (!cargo || cargo != container || !(user in cargo))
			return
		unload()
		after_escape(container, user)

///Called when someone resists inside of the cargo hitch.
/obj/golfcart_rear/relay_container_resist_act(mob/living/user, obj/container)
	user.visible_message(
		span_danger("[user] tries to escape the [container]!"),
		span_userdanger("You try to escape the [container]!"),
	)
	if (parent.has_buckled_mobs())
		for (var/mob/driver in parent.buckled_mobs)
			if (!parent.is_driver(driver))
				continue
			driver.show_message(span_userdanger("The [container] shakes violently!"))
	if (istype(container, /obj/structure/closet))
		var/obj/structure/closet/closet = container
		if (!closet.welded)
			return easy_escape(user, container)
		return hard_escape(user, container)
	return easy_escape(user, container)

/obj/golfcart_rear/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	if (!parent)
		return
	return parent.take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)

/obj/golfcart_rear/attack_hand(mob/user, list/modifiers)
	if(!isnull(cargo))
		unload()
		return TRUE
	return ..()

/obj/golfcart_rear/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if (!cargo)
		return
	tool.play_tool_sound(src, 50)
	unload()
	return ITEM_INTERACT_SUCCESS

/obj/golfcart_rear/proc/can_load(thing)
	return is_type_in_typecache(thing, parent.allowed_cargo) && (!is_type_in_typecache(thing, parent.banned_cargo)) && (!has_buckled_mobs())

/obj/golfcart_rear/mouse_drop_receive(atom/dropped, mob/user, params)
	if (!can_load(dropped))
		if (!isliving(dropped) || (has_buckled_mobs() && buckled_mobs.len >= max_buckled_mobs))
			balloon_alert_to_viewers("blocked!")
			return
		//Allow either 2 standing mobs or 1 lying down mob
		//If a mob is already lying down it's obviously blocked.
		if (has_buckled_mobs())
			for (var/mob/living/carbon/carbon_sitter in buckled_mobs)
				if (carbon_sitter.body_position == LYING_DOWN)
					balloon_alert_to_viewers("blocked!")
					return
		var/mob/living/dropped_liver = dropped
		if (dropped_liver.has_buckled_mobs())
			//This sucks
			balloon_alert_to_viewers("blocked!")
			return
		if (iscarbon(dropped_liver))
			var/mob/living/carbon/dropped_carbon = dropped_liver
			if (dropped_carbon.body_position == LYING_DOWN && has_buckled_mobs())
				balloon_alert_to_viewers("stand up!")
				return
		return ..()
	var/obj/dropped_obj = dropped
	return load(dropped_obj)

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

///Called if the rear of the golfcart MUST move to destination and must NOT notify the parent about it.
/obj/golfcart_rear/proc/move_from_parent(atom/destination)
	moving_from_parent = TRUE
	currently_z_moving = destination.z != loc.z
	. = forceMove(destination)
	moving_from_parent = FALSE

/obj/golfcart_rear/doMove(atom/destination)
	. = ..()
	if (!moving_from_parent)
		return
	for (var/mob/buckled_mob in buckled_mobs)
		if (currently_z_moving)
			buckled_mob.currently_z_moving = currently_z_moving
			buckled_mob.forceMove(destination)
		else
			// this is not a good hack - this should never happen
			// but stairs are a particularly problematic area
			if (!buckled_mob.Move(destination, dir, glide_size))
				// this is a terrible hack because mob/living forwards forceMove calls to buckled
				// unless currently_z_moving is non-null
				buckled_mob.currently_z_moving = CURRENTLY_Z_MOVING_GENERIC
				buckled_mob.forceMove(destination)
				buckled_mob.currently_z_moving = FALSE


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
	if (moving_from_parent)
		return

	if(pulledby)
		var/olddir = dir
		var/newdir
		if (direct & (EAST | WEST))
			newdir = (direct & EAST) ? EAST : WEST
		else if (direct & (NORTH | SOUTH))
			newdir = (direct & NORTH) ? NORTH : SOUTH
		else
			newdir = direct
		set_glide_size(glide_size_override ? glide_size_override : pulledby.glide_size)
		. = ..()
		dir = newdir
		if (get_step(src, turn(dir, 180)) != get_turf(pulledby))
			setDir(turn(dir, 180))
		var/atom/behind = get_step(src, dir)
		if (!behind.Enter(parent))
			setDir(olddir)
			behind = get_step(src, dir)
		parent.set_glide_size(glide_size_override ? glide_size_override : pulledby.glide_size)
		parent.forceMove(behind)
		parent.setDir(dir)
		parent.update_appearance(UPDATE_ICON)
		return

	return parent.Move(get_step(parent, get_dir(loc, newloc)), direct)

///Called for COMSIG_ATOM_TRIED_PASS on passengers buckled to the cart. Allows them to not block each other's movement / get blocked by the cart.
/obj/golfcart_rear/proc/allow_movement_between_bed_passengers(atom/source, atom/mover)
	SIGNAL_HANDLER

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

///Called from COMSIG_ATOM_POST_DIR_CHANGE on the rear of the cart. Only used to change buckled mobs' position / layers.
/obj/golfcart_rear/proc/on_dir_changed(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER

	if (!has_buckled_mobs())
		return
	update_passenger_layers(new_dir)

/obj/golfcart_rear/Initialize(mapload, obj/vehicle/ridden/golfcart/progenitor)
	. = ..()
	parent = progenitor
	layer = BELOW_HUMAN_HITBOX_LAYER
	RegisterSignal(parent, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(on_dir_changed))

/obj/golfcart_rear/update_overlays()
	. = ..()
	if (dir & NORTH)
		var/mutable_appearance/hitbox_overlay = mutable_appearance(icon, "rear_hitbox_overlay", layer)
		hitbox_overlay.pixel_y += 32
		. += hitbox_overlay
	else if (dir & SOUTH)
		. += mutable_appearance(icon, "rear_hitbox_lower", OBJ_LAYER + 0.01)
	if(!cargo)
		return
	var/vector/rear_offsets = parent.get_rear_offset()
	. += parent.generate_cargo_overlay(-rear_offsets.x, -rear_offsets.y, layer=layer)

///Called when a passenger tries lying down/getting up. Automatically drops out people who can't stay on
/obj/golfcart_rear/proc/passenger_falling_down(atom/source, new_bodypos)
	SIGNAL_HANDLER

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
	// these are to_viewers because you can buckle someone on their behalf
	if (cargo)
		balloon_alert_to_viewers("blocked!")
		return FALSE
	if (target.body_position != STANDING_UP)
		if (has_buckled_mobs())
			balloon_alert_to_viewers("stand up!")
			return FALSE
		return ..()
	for (var/mob/blocker in buckled_mobs)
		if (!isliving(blocker))
			balloon_alert_to_viewers("blocked!")
			return FALSE
		var/mob/living/living_blocker = blocker
		if (living_blocker.body_position != STANDING_UP)
			balloon_alert_to_viewers("blocked!")
			return FALSE
	return ..()

///Called on COMSIG_MOVABLE_PREBUCKLE for anything that's buckled to us. Disallows stacking buckles
/obj/golfcart_rear/proc/on_attempted_bucklestack()
	SIGNAL_HANDLER

	return COMPONENT_BLOCK_BUCKLE

/obj/golfcart_rear/post_buckle_mob(mob/living/buckled_mob)
	buckled_mob.pulledby?.stop_pulling()
	RegisterSignal(buckled_mob, COMSIG_ATOM_TRIED_PASS, PROC_REF(allow_movement_between_bed_passengers))
	RegisterSignal(buckled_mob, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(passenger_falling_down))
	RegisterSignal(buckled_mob, COMSIG_MOVABLE_PREBUCKLE, PROC_REF(on_attempted_bucklestack))
	. = ..()
	update_passenger_layers()

/obj/golfcart_rear/post_unbuckle_mob(mob/living/buckled_mob)
	UnregisterSignal(buckled_mob, COMSIG_ATOM_TRIED_PASS)
	UnregisterSignal(buckled_mob, COMSIG_LIVING_SET_BODY_POSITION)
	UnregisterSignal(buckled_mob, COMSIG_MOVABLE_PREBUCKLE)
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
	if (cargo && !QDELETED(cargo))
		cargo.forceMove(drop_location())
	cargo = null
	return ..()

#undef CARGO_HITBOX_LAYER
#undef HUMAN_LOWER_LAYER
#undef HUMAN_RIDING_LAYER
#undef GOLFCART_RIDING_SOURCE
#undef BELOW_HUMAN_HITBOX_LAYER
