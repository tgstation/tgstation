// License plate printing
/obj/machinery/plate_press
	name = "license plate press"
	desc = "You know, we're making a lot of license plates for a station with literally no cars in it."
	icon = 'icons/obj/machines/prison.dmi'
	icon_state = "offline"
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.02
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.05
	/// Reference to currently held license plate.
	var/obj/item/stack/license_plates/empty/current_plate
	/// Is the press currently pressing?
	var/pressing = FALSE

/obj/machinery/plate_press/update_icon_state()
	if(!is_operational)
		icon_state = "offline"
		return ..()
	if(pressing)
		icon_state = "loop"
		return ..()
	if(current_plate)
		icon_state = "online_loaded"
		return ..()
	icon_state = "online"
	return ..()

/obj/machinery/plate_press/Destroy()
	QDEL_NULL(current_plate)
	. = ..()

/obj/machinery/plate_press/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/stack/license_plates/empty))
		return NONE
	if(!is_operational)
		to_chat(user, span_warning("[src] has to be on to be loaded!"))
		return ITEM_INTERACT_BLOCKING
	if(current_plate)
		to_chat(user, span_warning("[src] already has a plate in it!"))
		return ITEM_INTERACT_BLOCKING

	var/obj/item/stack/license_plates/empty/plate = tool
	plate.use(1)
	current_plate = new plate.type(src, 1) //Spawn a new single sheet in the machine
	update_appearance()
	post_press(user)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/plate_press/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!pressing && current_plate)
		work_press(user)

///This proc attempts to create a plate. User cannot move during this process.
/obj/machinery/plate_press/proc/work_press(mob/living/user)

	pressing = TRUE
	update_appearance()
	to_chat(user, span_notice("You start pressing a new license plate!"))
	playsound(src, 'sound/machines/kerchunk.ogg', 80)

	if(!do_after(user, 4 SECONDS, target = src))
		pressing = FALSE
		update_appearance()
		return FALSE

	use_energy(active_power_usage)
	to_chat(user, span_notice("You finish pressing a new license plate!"))

	pressing = FALSE
	QDEL_NULL(current_plate)
	update_appearance()

	new /obj/item/stack/license_plates/filled(drop_location())

/// Side effects after successfully pressing a license plate, including granting labor points.
/obj/machinery/plate_press/proc/post_press(mob/living/user)
	if(!user)
		return
	var/obj/item/card/id/id_card = user.get_idcard(TRUE)
	if(!istype(id_card, /obj/item/card/id/advanced/prisoner))
		return // No bonus effects if we're not a prisoner or there's no ID.
	var/obj/item/card/id/advanced/prisoner/prison_id = id_card
	prison_id.points += PRISON_LABOR_PLATE
	to_chat(user, span_notice("[PRISON_LABOR_PLATE] points added!"))

/// Global list of all locations where produce can be dropped off.
GLOBAL_LIST_EMPTY(produce_dropoff)

//Grown crop recepticle.
/obj/machinery/produceporter
	name = "produceporter"
	desc = "A beaten up, landline teleporter designed to teleport produce back to the service department. This has seen better days."
	icon = 'icons/obj/machines/prison.dmi'
	icon_state = "produceporter_off"
	density =  TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.01
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.1
	/// Maximum amount of produce the machine can hold before it has to be either emptied or sent.
	var/max_produce = 10
	/// Current count of held produce
	var/current_produce = 0

/obj/machinery/produceporter/Initialize(mapload)
	. = ..()
	register_context()
	update_appearance()

/obj/machinery/produceporter/LateInitialize()
	if(!length(GLOB.produce_dropoff))
		CRASH("A produceporter was spawned, however, there were no dropoff landmarks to send produce to!")

/obj/machinery/produceporter/update_icon_state()
	if(!is_operational)
		icon_state = "produceporter_off"
		return ..()
	icon_state = "produceporter"
	return ..()

/obj/machinery/produceporter/update_overlays()
	. = ..()
	if(is_operational)
		. += emissive_appearance(icon, "produceporter_emissive", src)

/obj/machinery/produceporter/examine(mob/user)
	. = ..()
	if(current_produce >= max_produce)
		. += span_notice("\The [src]'s bin is full, and can be sent back to the station for labor points.")
	else
		. += span_notice("\The [src] has room for more produce to be inserted.")
	. += span_notice("The lever can be pulled with [span_boldnotice("Right Click")] to send produce back to the station.")

/obj/machinery/produceporter/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/food/grown))
		if(current_produce >= max_produce)
			balloon_alert(user, "bin's full!")
			return ITEM_INTERACT_FAILURE
		tool.forceMove(src)
		playsound(src, 'sound/items/handling/component_drop.ogg', 30)
		update_produce()
		balloon_alert(user, "holding [current_produce] / [max_produce]")
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/produceporter/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!is_operational)
		balloon_alert(user, "nothing happens")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!current_produce)
		balloon_alert(user, "bin's empty!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	flick("produceporter_active", src)
	use_energy(active_power_usage)
	playsound(src, 'sound/items/weapons/emitter2.ogg', 50)
	var/sent = 0
	for(var/obj/item/food/grown/produce in contents)
		do_teleport(produce, pick(GLOB.produce_dropoff), 0, asoundout = 'sound/machines/woosh.ogg')
		sent++
	balloon_alert_to_viewers("kachunk!")
	post_delivery(user, sent)
	update_produce()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/produceporter/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(is_operational && current_produce > 0)
		context[SCREENTIP_CONTEXT_RMB] = "Send Produce"
	if(istype(held_item, /obj/item/food/grown))
		context[SCREENTIP_CONTEXT_LMB] = "Deposit Produce"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/produceporter/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_unfasten_wrench(user, tool, time = 1.5 SECONDS) == SUCCESSFUL_UNFASTEN)
		update_appearance(UPDATE_ICON_STATE)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/produceporter/proc/update_produce()
	current_produce = 0
	for(var/obj/item/food/grown/crops in contents)
		if(current_produce > max_produce)
			return
		current_produce++
	return current_produce

/obj/machinery/produceporter/proc/post_delivery(mob/living/user, sent = 0)
	if(!user)
		return
	var/obj/item/card/id/id_card = user.get_idcard(TRUE)
	if(!istype(id_card, /obj/item/card/id/advanced/prisoner))
		return // No bonus effects if we're not a prisoner or there's no ID.
	var/obj/item/card/id/advanced/prisoner/prison_id = id_card
	prison_id.points += PRISON_LABOR_CROPS * sent
	to_chat(user, span_notice("[PRISON_LABOR_CROPS * sent] points added!"))
