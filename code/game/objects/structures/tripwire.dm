/obj/structure/tripwire
	name = "tripwire post?"
	desc = "This should not be here. Somebody should be told about this."
	icon = 'icons/obj/tripwire.dmi'
	icon_state = "tripwire_post"
	anchored = TRUE
	density = TRUE
	abstract_type = /obj/structure/tripwire

/obj/structure/tripwire/post
	name = "stanchion"
	desc = "A sturdy post made to support one end of a large cable."
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3.5)
	/// The post that the other end of this post's tripwire, if any. Also serves as a check for if we have a tripwire.
	var/obj/structure/tripwire/post/opposing_post
	/// The wire or wires between us and the opposing post. Only one post in the pair will have this list filled.
	var/list/obj/structure/tripwire/cable/tripwires = list()

/obj/structure/tripwire/post/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/tripwire/post/Destroy(force)
	clear_wire()
	return ..()

/obj/structure/tripwire/post/proc/clear_wire()
	if(opposing_post)
		opposing_post.opposing_post = null
		opposing_post.clear_wire()
		opposing_post = null
	for(var/tripwire in tripwires)
		UnregisterSignal(tripwire, COMSIG_QDELETING)
		qdel(tripwire)
	tripwires = list()
	update_appearance(UPDATE_ICON)

/obj/structure/tripwire/post/proc/wire_qdeleted(datum/source)
	tripwires -= source
	UnregisterSignal(source, COMSIG_QDELETING)
	clear_wire()

/obj/structure/tripwire/post/proc/connect_to_post(obj/structure/tripwire/post/connected_post, new_direction)
	dir = new_direction
	opposing_post = connected_post
	update_appearance(UPDATE_ICON)

/obj/structure/tripwire/post/update_appearance(updates)
	. = ..()
	icon_state = "tripwire_post[opposing_post ? "_tied" : ""]"

/obj/structure/tripwire/post/wirecutter_act(mob/living/user, obj/item/tool)
	if(!opposing_post)
		return NONE

	visible_message(span_notice("[user] begins cutting through \the [src]'s tripwire..."), \
					span_notice("You begin cutting through \the [src]'s tripwire..."), \
					span_hear("You hear snipping."))
	if(!tool.use_tool(src, user, 5 SECONDS))
		return ITEM_INTERACT_BLOCKING

	if(!opposing_post)
		return ITEM_INTERACT_BLOCKING

	visible_message(span_notice("[user] cuts away \the [src]'s tripwire."), \
					span_notice("You finish cutting \the [src]'s tripwire."), \
					span_hear("You hear a final snip."))
	new /obj/item/stack/cable_coil(drop_location(), 20)
	clear_wire()
	return ITEM_INTERACT_SUCCESS

/obj/structure/tripwire/post/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/tripwire_cable))
		return NONE

	if(!anchored || opposing_post)
		return NONE

	var/obj/item/tripwire_cable/irrelevant_cable = tool

	var/obj/structure/tripwire/post/connecting_post = irrelevant_cable.connecting_post?.resolve()

	var/are_we_tying = FALSE
	if(!connecting_post || connecting_post.z != z)
		are_we_tying = TRUE

	var/distance_between = get_dist(src, connecting_post)
	if(distance_between > 6)
		are_we_tying = TRUE

	if(are_we_tying)// if it's on a different z level, or further than would be reasonable, refuse to acknowledge the distance and mulligan.
		to_chat(user, span_notice("You tie one end of \the [irrelevant_cable] around \the [src]."))
		irrelevant_cable.connecting_post = WEAKREF(src)
		return ITEM_INTERACT_SUCCESS

	if(connecting_post == src)
		return ITEM_INTERACT_BLOCKING

	if(!connecting_post.anchored)
		return ITEM_INTERACT_BLOCKING

	if(distance_between > 4)
		to_chat(user, span_notice("The post on the other end is too far away!"))
		return ITEM_INTERACT_BLOCKING

	if(distance_between == 0)
		to_chat(user, span_notice("No point in connecting them, they're already together."))
		return ITEM_INTERACT_BLOCKING

	if(connecting_post.x != x && connecting_post.y != y)
		to_chat(user, span_notice("The wire will be much less effective at an angle."))
		return ITEM_INTERACT_BLOCKING

	var/turf/end_point_turf = get_turf(connecting_post)

	if(!do_after(user, distance_between * 3 SECONDS, src))
		return ITEM_INTERACT_BLOCKING

	if(!anchored || opposing_post || !connecting_post?.anchored || connecting_post.opposing_post || end_point_turf != get_turf(connecting_post))
		return ITEM_INTERACT_BLOCKING

	var/direction_to_extend = get_dir(src, connecting_post)
	var/turf/iterating_turf = get_turf(src)
	for(var/distance_extended in 1 to distance_between)
		iterating_turf = get_step(iterating_turf, direction_to_extend)
		if(iterating_turf == end_point_turf)
			connect_to_post(connecting_post, direction_to_extend)
			connecting_post.connect_to_post(src, REVERSE_DIR(direction_to_extend))
			to_chat(user, span_notice("You successfully wire together the two posts."))
			qdel(irrelevant_cable)
			return ITEM_INTERACT_SUCCESS

		if(iterating_turf.is_blocked_turf(TRUE))
			clear_wire()
			to_chat(user, span_notice("You can't feed the cable through solid objects."))
			return ITEM_INTERACT_BLOCKING

		var/obj/structure/tripwire/cable/new_wire = new(iterating_turf)
		switch(distance_between)
			// if(1) we'd have already dropped out at connecting the two posts together, and wouldn't get here
			if(2)
				new_wire.icon_state = "tripwire_1" // post - wire(1) - post
			if(3)
				new_wire.icon_state = "tripwire_2" // post - wire(2)(L) - wire(2)(R) - post
			if(4)
				new_wire.icon_state = "tripwire_[distance_extended == 2 ? "3" : "2"]" // post - wire(2)(L) - wire(3) - wire(2)(R) - post

		new_wire.dir = (distance_extended > (distance_between / 2)) ? direction_to_extend : REVERSE_DIR(direction_to_extend) // Switch directions once we're halfway there


		RegisterSignal(new_wire, COMSIG_QDELETING, PROC_REF(wire_qdeleted))
		tripwires += new_wire

	// HOW DID WE GET HERE WE SHOULD NEVER GET HERE BURN IT ALL
	clear_wire()
	return ITEM_INTERACT_BLOCKING

/obj/structure/tripwire/post/wrench_act(mob/living/user, obj/item/tool)
	if(opposing_post)
		balloon_alert(user, "unwire first!")
		return ITEM_INTERACT_BLOCKING

	if(!tool.use_tool(src, user, 0))
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "[anchored ? "un" : ""]anchored")
	set_anchored(!anchored)
	return ITEM_INTERACT_SUCCESS

/obj/structure/tripwire/post/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	clear_wire()
	return ..()

/obj/structure/tripwire/post/CanAllowThrough(atom/movable/mover, border_dir)
	if(!opposing_post)
		return TRUE

	return ..()

/obj/structure/tripwire/post/on_entered(datum/source, atom/movable/entered)
	if(!opposing_post)
		return

	return ..()

/obj/structure/tripwire/cable
	name = "heavy cable"
	desc = "A very thick cable made to withstand great force."
	icon_state = "tripwire_1"

/obj/structure/tripwire/cable/Initialize(mapload)
	. = ..()
	RegisterSignal(get_turf(src), COMSIG_ATOM_ENTERED, PROC_REF(on_entered)) // No need for connect_loc, we won't be moving.

/obj/structure/tripwire/cable/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(attacking_item.sharpness)
		MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, 10)
	return ..()

/obj/structure/tripwire/cable/wirecutter_act(mob/living/user, obj/item/tool)
	visible_message(span_notice("[user] begins cutting through \the [src]..."), \
					span_notice("You begin cutting through \the [src]..."), \
					span_hear("You hear snipping."))

	if(!tool.use_tool(src, user, 5 SECONDS))
		return ITEM_INTERACT_BLOCKING

	visible_message(span_notice("[user] cuts away \the [src]."), \
					span_notice("You finish cutting \the [src]."), \
					span_hear("You hear a final snip."))
	new /obj/item/stack/cable_coil(drop_location(), 20)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/tripwire/cable/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(!QDELING(src))
		qdel(src)

/obj/structure/tripwire/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()

	if(.)
		return .

	if(isprojectile(mover))
		return TRUE

	if(mover.dir == dir || mover.dir == REVERSE_DIR(dir))
		return TRUE

	if(!mover.has_gravity())
		return TRUE

	if(mover.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return TRUE

	if(iscarbon(mover))
		var/mob/living/carbon/moving_carbon = mover
		if(moving_carbon.body_position == LYING_DOWN) // Crawl under it. Bonus of allowing dragging dying people.
			return TRUE

		if(moving_carbon.move_intent == MOVE_INTENT_WALK)
			return TRUE

	if(ismecha(mover))
		if(istype(mover, /obj/vehicle/sealed/mecha/clarke)) // treads
			return FALSE

		return TRUE

	return FALSE


/obj/structure/tripwire/proc/on_entered(datum/source, atom/movable/entered)
	if(!ismecha(entered))
		return

	var/obj/vehicle/sealed/mecha/falling_down = entered
	if(falling_down.toppled) // did you trip directly into a tripwire? We don't want this to chain, however amusing the image might be.
		return

	if(astype(falling_down, /obj/vehicle/sealed/mecha/phazon)?.phasing)
		return

	if(falling_down.dir == dir || falling_down.dir == REVERSE_DIR(dir))
		return

	var/damage_value = falling_down.max_integrity / 5

	var/falling_angle
	if(falling_down.dir == WEST)
		falling_angle = 270
	else if(falling_down.dir == EAST)
		falling_angle = 90
	else
		falling_angle = pick(90, 270)

	// For disambiguation, damage_value is the mech's health / 5. damage_value is the base for all the rest of the numbers.
	// damage_value is applied directly as damage to whoever it falls on. That person is also paralyzed for damage_value / 10 seconds.
	// The pilot of the falling mech receives damage_value / 5 as a head trauma.
	// The mech itself receives damage_value * 0.15 seconds of immobility(can still attack, but can't rotate). (damage_value / 10 * 1.5)
	falling_down.toppled = TRUE
	falling_down.forceMove(get_turf(src))
	var/tripped = falling_down.fall_and_crush(get_step(falling_down, falling_down.dir), damage_value, 15, paralyze_time = damage_value, rotation = falling_angle)
	addtimer(CALLBACK(falling_down, TYPE_PROC_REF(/obj/vehicle/sealed/mecha, right_self), falling_angle), damage_value * 1.5)
	if (!(tripped & SUCCESSFULLY_FELL_OVER))
		falling_down.toppled = FALSE
		return // Don't know how it'd be avoided, but if you beat it, you beat it

	var/drivers = falling_down.return_drivers()

	visible_message(span_danger("[falling_down] topples over \the [src]!"), \
		blind_message = span_danger("You hear a deafening CRASH!"), \
		ignored_mobs = drivers)

	for(var/mob/living/driver as anything in drivers) // can any mechs have two drivers? No. Could they? yes.
		var/damage = driver.apply_damage(damage_value / 3, BRUTE, BODY_ZONE_HEAD, driver.run_armor_check(BODY_ZONE_HEAD, MELEE), wound_bonus = 30, wound_clothing = FALSE)
		var/falling_string
		switch(damage)
			if(0)
				falling_string = "You rapidly fall forward but only lightly hit [falling_down]'s controls. "
			if(0 to 10)
				falling_string = "You rapidly fall forward and hit your head on [falling_down]'s controls! "
			if(10 to INFINITY)
				falling_string = "You rapidly fall forward and smash your head against [falling_down]'s controls! "

		falling_string += "When you recover, you [damage_value > 40 ? "slowly" : "quickly"] begin righting [falling_down]."
		to_chat(driver, span_danger(falling_string))

/obj/item/tripwire_cable
	name = "sturdy cable"
	desc = "A coil of extremely thick cable that can withstand great force."
	icon = 'icons/obj/tripwire.dmi'
	icon_state = "tripwire_cable"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	inhand_icon_state = "coil_yellow"
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 3, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 3)
	/// The post we're trying to connect at the moment, if any.
	var/datum/weakref/connecting_post

/obj/item/tripwire_cable/attack_self(mob/user, modifiers)
	if(!connecting_post.resolve())
		return
	to_chat(user, span_notice("You recoil the length of cable until it's all back together again."))
	connecting_post = null

/obj/item/tripwire_cable/wirecutter_act(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("You cut off the cable's excess bulk."))
	new /obj/item/stack/cable_coil(drop_location(), 15)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/datum/crafting_recipe/tripwire_cable
	name = "Tripwire Cable"
	result = /obj/item/tripwire_cable
	reqs = list(
		/obj/item/stack/cable_coil = 30,
	)
	tool_behaviors = list(TOOL_WIRECUTTER)
	time = 10 SECONDS
	category = CAT_MISC
