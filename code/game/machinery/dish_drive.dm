/obj/machinery/dish_drive
	name = "dish drive"
	desc = "A culinary marvel that uses matter-to-energy conversion to store dishes and shards. Convenient! \
	Additional features include a vacuum function to suck in nearby dishes, and an automatic transfer beam that empties its contents into nearby disposal bins every now and then. \
	Or you can just drop your plates on the floor, like civilized folk."
	icon = 'icons/obj/machines/kitchen.dmi'
	icon_state = "synthesizer"
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.04
	density = FALSE
	circuit = /obj/item/circuitboard/machine/dish_drive
	pass_flags = PASSTABLE
	interaction_flags_click = ALLOW_SILICON_REACH
	/// List of dishes the drive can hold
	var/static/list/collectable_items = list(
		/obj/item/broken_bottle,
		/obj/item/kitchen/fork,
		/obj/item/plate,
		/obj/item/plate_shard,
		/obj/item/reagent_containers/cup/bowl,
		/obj/item/reagent_containers/cup/glass/drinkingglass,
		/obj/item/shard,
		/obj/item/trash/tray,
	)
	/// List of items the drive detects as trash
	var/static/list/disposable_items = list(
		/obj/item/broken_bottle,
		/obj/item/plate_shard,
		/obj/item/shard,
		/obj/item/trash/tray,
	)
	/// Can this suck up dishes?
	var/suction_enabled = TRUE
	/// Does this automatically dispose of trash?
	var/transmit_enabled = TRUE
	/// List of dishes currently inside
	var/list/dish_drive_contents
	/// Distance this is capable of sucking dishes up over. (2 + servo tier)
	var/suck_distance = 0

	COOLDOWN_DECLARE(time_since_dishes)

/obj/machinery/dish_drive/examine(mob/user)
	. = ..()
	if(user.Adjacent(src))
		. += span_notice("Alt-click it to beam its contents to any nearby disposal bins.")
	if(!LAZYLEN(dish_drive_contents))
		. += "[src] is empty!"
		return
	// Makes a list of all dishes in the drive, as well as what dish will be taken out next.
	var/list/dish_list = list()
	// All the types in our list
	var/list/dish_types = list()
	for(var/obj/dish in dish_drive_contents)
		dish_types[dish.type] += 1
	for(var/dish_path in unique_list(dish_types))
		// Counts our dish
		var/dish_amount = dish_types[dish_path]
		// Handles plurals
		var/obj/dish = dish_path
		var/dish_name = dish_amount == 1 ? initial(dish.name) : "[initial(dish.name)][plural_s(initial(dish.name))]"
		dish_list += list("[dish_amount] [dish_name]")

	. += span_info("It contains [english_list(dish_list)].\n[peek(dish_drive_contents)] is at the top of the pile.")

/obj/machinery/dish_drive/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!LAZYLEN(dish_drive_contents))
		balloon_alert(user, "drive empty")
		return
	var/obj/item/dish = LAZYACCESS(dish_drive_contents, LAZYLEN(dish_drive_contents)) //the most recently-added item
	LAZYREMOVE(dish_drive_contents, dish)
	user.put_in_hands(dish)
	balloon_alert(user, "[dish] taken")
	playsound(src, 'sound/items/pshoom/pshoom.ogg', 50, TRUE)
	flick("synthesizer_beam", src)

/obj/machinery/dish_drive/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/dish_drive/attackby(obj/item/dish, mob/living/user, list/modifiers, list/attack_modifiers)
	if(is_type_in_list(dish, collectable_items) && !user.combat_mode)
		if(!user.transferItemToLoc(dish, src))
			return
		LAZYADD(dish_drive_contents, dish)
		balloon_alert(user, "[dish] placed in drive")
		playsound(src, 'sound/items/pshoom/pshoom.ogg', 50, TRUE)
		flick("synthesizer_beam", src)
		return
	else if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), dish))
		return
	else if(default_deconstruction_crowbar(dish, FALSE))
		return
	..()

/obj/machinery/dish_drive/RefreshParts()
	. = ..()
	suck_distance = 0
	for(var/datum/stock_part/servo/servo in component_parts)
		suck_distance = servo.tier
	// Lowers power use for total tier
	var/total_rating = 0
	for(var/datum/stock_part/stock_part in component_parts)
		total_rating += stock_part.tier
	if(total_rating >= 9)
		update_mode_power_usage(ACTIVE_POWER_USE, 0)
	else
		update_mode_power_usage(IDLE_POWER_USE, max(0, initial(idle_power_usage) - total_rating))
		update_mode_power_usage(ACTIVE_POWER_USE, max(0, initial(active_power_usage) - total_rating))
	// Board options
	var/obj/item/circuitboard/machine/dish_drive/board = locate() in component_parts
	if(board)
		suction_enabled = board.suction
		transmit_enabled = board.transmit

/obj/machinery/dish_drive/process()
	if(COOLDOWN_FINISHED(src, time_since_dishes) && transmit_enabled)
		do_the_dishes()
	if(!suction_enabled)
		return
	for(var/obj/item/dish in view(2 + suck_distance, src))
		if(is_type_in_list(dish, collectable_items) && dish.loc != src && (!dish.reagents || !dish.reagents.total_volume) && (dish.contents.len < 1))
			if(dish.Adjacent(src))
				LAZYADD(dish_drive_contents, dish)
				visible_message(span_notice("[src] beams up [dish]!"))
				dish.forceMove(src)
				playsound(src, 'sound/items/pshoom/pshoom.ogg', 50, TRUE)
				flick("synthesizer_beam", src)
			else
				step_towards(dish, src)

/obj/machinery/dish_drive/attack_ai(mob/living/user)
	if(machine_stat)
		return
	balloon_alert(user, "disposal signal sent")
	do_the_dishes(TRUE)

/obj/machinery/dish_drive/click_alt(mob/living/user)
	do_the_dishes(TRUE)
	return CLICK_ACTION_SUCCESS

/obj/machinery/dish_drive/proc/do_the_dishes(manual)
	if(!LAZYLEN(dish_drive_contents))
		if(manual)
			visible_message(span_notice("[src] is empty!"))
		return
	var/obj/machinery/disposal/bin/bin = locate() in view(7, src)
	if(!bin)
		if(manual)
			visible_message(span_warning("[src] buzzes. There are no disposal bins in range!"))
			playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 50, TRUE)
		return
	var/disposed = 0
	for(var/obj/item/dish in dish_drive_contents)
		if(is_type_in_list(dish, disposable_items))
			if(!use_energy(active_power_usage, force = FALSE))
				say("Not enough energy to continue!")
				break
			LAZYREMOVE(dish_drive_contents, dish)
			dish.forceMove(bin)
			disposed++
	if (disposed)
		visible_message(span_notice("[src] [pick("whooshes", "bwooms", "fwooms", "pshooms")] and beams [disposed] stored item\s into the nearby [bin.name]."))
		playsound(src, 'sound/items/pshoom/pshoom.ogg', 50, TRUE)
		playsound(bin, 'sound/items/pshoom/pshoom.ogg', 50, TRUE)
		Beam(bin, icon_state = "rped_upgrade", time = 5)
		bin.update_appearance()
		flick("synthesizer_beam", src)
	else
		if(manual)
			visible_message(span_notice("There are no disposable items in [src]!"))
		return
	COOLDOWN_START(src, time_since_dishes, 1 MINUTES)
