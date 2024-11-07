// dummy carbon to do item stuff for machines
/mob/living/carbon/machine_user
	invisibility = INVISIBILITY_ABSTRACT

/mob/living/carbon/machine_user/Initialize(mapload, obj/target)
	name = target.name
	real_name = target.name
	add_traits(list(TRAIT_TEMPORARY_BODY, TRAIT_HANDS_BLOCKED, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT), INNATE_TRAIT)
	// used to runtime in Life without this but now that i overrided that its probably pointless
	// best keep this to avoid any problems with limbs
	create_bodyparts() // FUCK
	return ..()

/mob/living/carbon/machine_user/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	return //we dont do life, we dont have one!

/mob/living/carbon/machine_user/update_damage_overlays() // we dont exist actually
	return

/mob/living/carbon/machine_user/update_body(is_creating = FALSE) // we dont exist actually
	return

/mob/living/carbon/machine_user/update_body_parts() // we dont exist actually
	return


/obj/machinery/power/manufacturing/user
	name = "manufacturing user"
	desc = "Experimental prototype biological machine capable of adapting to use an item on the first (untouched) item infront of it. Items will be sent to a tile diagonal to the machine. It may also receive an item from a conveyor to equip them if one is missing."
	icon_state = "user"
	circuit = /obj/item/circuitboard/machine/manuuser
	/// power per interaction
	var/power_cost = 4 KILO WATTS
	/// held object we use to interact with stuff infront of us
	var/obj/item/held_object
	/// inner carbon to handle items
	var/mob/living/carbon/itemuser
	/// is our output flipped
	var/output_flipped = FALSE
	/// are we fed right now
	var/fed = FALSE
	/// timer until we get hungry
	var/fed_timer
	/// how long do we say fed
	var/fed_time = 6 MINUTES

/obj/machinery/power/manufacturing/user/Initialize(mapload)
	. = ..()
	itemuser = new /mob/living/carbon/machine_user(null, src)
	RegisterSignals(itemuser, list(COMSIG_LIVING_DEATH, COMSIG_MOVABLE_MOVED, COMSIG_MOB_MIND_INITIALIZED, COMSIG_MOB_MIND_TRANSFERRED_INTO), PROC_REF(user_kil))
	RegisterSignal(itemuser, COMSIG_QDELETING, PROC_REF(user_deleted))
	START_PROCESSING(SSmanufacturing, src)
	register_context()

/obj/machinery/power/manufacturing/user/proc/user_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/obj/machinery/power/manufacturing/user/proc/user_kil(datum/source)
	SIGNAL_HANDLER
	atom_destruction()

/obj/machinery/power/manufacturing/user/proc/stop_attack(datum/source)
	SIGNAL_HANDLER
	return COMPONENT_CANCEL_ATTACK_CHAIN // hopefully prevents the machine from trying to unload a handgun into whatever is infront of it

/obj/machinery/power/manufacturing/user/examine(mob/user)
	. = ..()
	. += span_notice("Use a multitool to flip the direction items are sent.")
	if(panel_open)
		. += span_warning("The panel is open, blocking you from replacing whatever it is holding.")
		if(!fed)
			. += span_cult("It is hungry.") + span_notice(" Feed it a stray animal or actual food to slightly improve its speed.")
		else
			. += span_notice("It is sated.")

/obj/machinery/power/manufacturing/user/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!isnull(held_object))
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Remove held object"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/power/manufacturing/user/update_overlays()
	. = ..()
	var/mutable_appearance/arm = mutable_appearance(icon, "userarm", layer = layer+0.01)
	arm.pixel_y = 16
	. += arm
	if(panel_open)
		. += "useropendoor"
		. += mutable_appearance(icon, "userinner")
		. += mutable_appearance(icon, "usermouth")
	var/list/dir_offset = dir2offset(dir)
	dir_offset[1] *= 32
	dir_offset[2] *= 32
	var/overlay_dir = turn(dir, output_flipped ? -90 : 90)
	var/image/nonemissive = image(icon=icon, icon_state="ioarrow", dir = overlay_dir)
	nonemissive.pixel_x = dir_offset[1]
	nonemissive.pixel_y = dir_offset[2]
	nonemissive.color = COLOR_MODERATE_BLUE
	var/mutable_appearance/emissive = emissive_appearance(nonemissive.icon, nonemissive.icon_state, offset_spokesman = src, alpha = nonemissive.alpha)
	emissive.pixel_y = nonemissive.pixel_y
	emissive.pixel_x = nonemissive.pixel_x
	emissive.dir = overlay_dir
	. += list(nonemissive, emissive)

/obj/machinery/power/manufacturing/user/receive_resource(obj/receiving, atom/from, receive_dir)
	if(!isnull(held_object))
		return MANUFACTURING_FAIL
	receiving.Move(src)
	held_object = receiving
	RegisterSignal(held_object, COMSIG_ITEM_PRE_ATTACK, PROC_REF(stop_attack))
	return MANUFACTURING_SUCCESS

/obj/machinery/power/manufacturing/user/atom_destruction(damage_flag)
	held_object.Move(drop_location())
	return ..()

/obj/machinery/power/manufacturing/user/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == held_object)
		UnregisterSignal(held_object, COMSIG_ITEM_PRE_ATTACK)
		held_object = null

/obj/machinery/power/manufacturing/user/Destroy()
	. = ..()
	QDEL_NULL(itemuser)
	QDEL_NULL(held_object)
	deltimer(fed_timer)

/obj/machinery/power/manufacturing/user/item_interaction(mob/living/user, obj/item/item, list/modifiers)
	. = NONE
	if(panel_open)
		return feed(item, user)
	if(user.combat_mode)
		return
	if(!user.transferItemToLoc(item, src))
		return ITEM_INTERACT_BLOCKING
	if(!isnull(held_object))
		try_put_in_hand(held_object)
	held_object = item
	RegisterSignal(held_object, COMSIG_ITEM_PRE_ATTACK, PROC_REF(stop_attack))
	to_chat(user, span_notice("You install [item] in [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/manufacturing/user/proc/feed(obj/item/food/food, mob/user)
	var/obj/item/clothing/head/mob_holder/potential_held_mob = food
	if(istype(potential_held_mob)) // FEED ME A STRAY CAT
		var/mob/living/eaten = potential_held_mob.held_mob
		potential_held_mob.release(display_messages = FALSE)
		eaten.Move(loc)
		eaten.gib(DROP_BRAIN | DROP_ITEMS)
		visible_message(span_danger("[src] voraciously devours [eaten]!"))
		playsound(loc,'sound/items/eatfood.ogg', 50, TRUE)
		fed()
		return ITEM_INTERACT_SUCCESS
	if(!istype(food))
		return ITEM_INTERACT_BLOCKING
	if(!user?.transferItemToLoc(food, src))
		return ITEM_INTERACT_FAILURE
	qdel(food)
	visible_message(span_notice("[src] devours [food]."))
	playsound(loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	fed()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/manufacturing/user/proc/fed()
	deltimer(fed_timer)
	if(fed) //we dont have the bonus
		itemuser.add_actionspeed_modifier(/datum/actionspeed_modifier/manufacturing_user)
	addtimer(CALLBACK(src, PROC_REF(get_hungry)), fed_time, TIMER_STOPPABLE | TIMER_UNIQUE)
	fed = TRUE

/obj/machinery/power/manufacturing/user/proc/get_hungry()
	fed = FALSE
	itemuser.remove_actionspeed_modifier(/datum/actionspeed_modifier/manufacturing_user)
	fed_timer = null

/obj/machinery/power/manufacturing/user/multitool_act(mob/living/user, obj/item/tool)
	output_flipped = !output_flipped
	balloon_alert(user, "flipped output")
	update_appearance(UPDATE_OVERLAYS)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/manufacturing/user/click_ctrl(mob/user)
	if(isnull(held_object))
		return
	return try_put_in_hand(held_object, user) ? CLICK_ACTION_SUCCESS : CLICK_ACTION_BLOCKING

/// Is this item considered useless to us after we use it on something?
/obj/machinery/power/manufacturing/user/proc/is_useless(obj/item/target)
	. = FALSE
	//drop empty beakers and welding tools after use
	if((is_reagent_container(target) || istype(target, /obj/item/weldingtool)) && target.reagents?.total_volume <= 0)
		return TRUE

/// Do any special actions for our held object before using it, if any
/obj/machinery/power/manufacturing/user/proc/preuse_held()
	if(isnull(held_object))
		return
	var/obj/item/weldingtool/welder = held_object
	if(istype(welder))
		welder.switched_on(itemuser)

/// Do any special actions for our held object after using it, if any
/obj/machinery/power/manufacturing/user/proc/postuse_held()
	if(isnull(held_object))
		return
	var/obj/item/weldingtool/welder = held_object
	if(istype(welder))
		welder.switched_off(itemuser)

/obj/machinery/power/manufacturing/user/process(seconds_per_tick)
	if(!anchored || isnull(held_object))
		return
	if(LAZYLEN(itemuser.do_afters))
		return //we busy
	if(surplus() < power_cost)
		return
	INVOKE_ASYNC(src, PROC_REF(async_interact))

/obj/machinery/power/manufacturing/user/proc/async_interact()
	var/turf/infront = get_step(src, dir)
	var/turf/target_turf = get_step(infront, turn(dir, output_flipped ? -90 : 90))
	for(var/obj/item/item in infront)
		add_load(power_cost)
		preuse_held()
		held_object.melee_attack_chain(user = itemuser, target = item, params = "")
		visible_message(span_notice("[src] attempts to use [held_object] on [item]."))
		postuse_held()
		send_resource(item, target_turf, dir_proxy = infront)
		if(!isnull(held_object) && is_useless(held_object))
			held_object.Move(drop_location())
		return
