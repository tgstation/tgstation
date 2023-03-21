/obj/machinery/dish_drive
	name = "dish drive"
	desc = "A culinary marvel that uses matter-to-energy conversion to store dishes and shards. Convenient! \
	Additional features include a vacuum function to suck in nearby dishes, and an automatic transfer beam that empties its contents into nearby disposal bins every now and then. \
	Or you can just drop your plates on the floor, like civilized folk."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "synthesizer"
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.04
	density = FALSE
	circuit = /obj/item/circuitboard/machine/dish_drive
	pass_flags = PASSTABLE
	var/static/list/collectable_items = list(/obj/item/trash/waffles,
		/obj/item/trash/tray,
		/obj/item/reagent_containers/cup/bowl,
		/obj/item/reagent_containers/cup/glass/drinkingglass,
		/obj/item/kitchen/fork,
		/obj/item/shard,
		/obj/item/broken_bottle)
	var/static/list/disposable_items = list(/obj/item/trash/waffles,
		/obj/item/trash/tray,
		/obj/item/shard,
		/obj/item/broken_bottle)
	var/time_since_dishes = 0
	var/suction_enabled = TRUE
	var/transmit_enabled = TRUE
	var/list/dish_drive_contents

/obj/machinery/dish_drive/Initialize(mapload)
	. = ..()
	RefreshParts()

/obj/machinery/dish_drive/examine(mob/user)
	. = ..()
	if(user.Adjacent(src))
		. += span_notice("Alt-click it to beam its contents to any nearby disposal bins.")

/obj/machinery/dish_drive/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!LAZYLEN(dish_drive_contents))
		to_chat(user, span_warning("There's nothing in [src]!"))
		return
	var/obj/item/I = LAZYACCESS(dish_drive_contents, LAZYLEN(dish_drive_contents)) //the most recently-added item
	LAZYREMOVE(dish_drive_contents, I)
	user.put_in_hands(I)
	to_chat(user, span_notice("You take out [I] from [src]."))
	playsound(src, 'sound/items/pshoom.ogg', 50, TRUE)
	flick("synthesizer_beam", src)

/obj/machinery/dish_drive/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/dish_drive/attackby(obj/item/I, mob/living/user, params)
	if(is_type_in_list(I, collectable_items) && !user.combat_mode)
		if(!user.transferItemToLoc(I, src))
			return
		LAZYADD(dish_drive_contents, I)
		to_chat(user, span_notice("You put [I] in [src], and it's beamed into energy!"))
		playsound(src, 'sound/items/pshoom.ogg', 50, TRUE)
		flick("synthesizer_beam", src)
		return
	else if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		return
	else if(default_deconstruction_crowbar(I, FALSE))
		return
	..()

/obj/machinery/dish_drive/RefreshParts()
	. = ..()
	var/total_rating = 0
	for(var/datum/stock_part/stock_part in component_parts)
		total_rating += stock_part.tier
	if(total_rating >= 9)
		update_mode_power_usage(ACTIVE_POWER_USE, 0)
	else
		update_mode_power_usage(IDLE_POWER_USE, max(0, initial(idle_power_usage) - total_rating))
		update_mode_power_usage(ACTIVE_POWER_USE, max(0, initial(active_power_usage) - total_rating))
	var/obj/item/circuitboard/machine/dish_drive/board = locate() in component_parts
	if(board)
		suction_enabled = board.suction
		transmit_enabled = board.transmit

/obj/machinery/dish_drive/process()
	if(time_since_dishes <= world.time && transmit_enabled)
		do_the_dishes()
	if(!suction_enabled)
		return
	for(var/obj/item/I in view(4, src))
		if(is_type_in_list(I, collectable_items) && I.loc != src && (!I.reagents || !I.reagents.total_volume))
			if(I.Adjacent(src))
				LAZYADD(dish_drive_contents, I)
				visible_message(span_notice("[src] beams up [I]!"))
				I.forceMove(src)
				playsound(src, 'sound/items/pshoom.ogg', 50, TRUE)
				flick("synthesizer_beam", src)
			else
				step_towards(I, src)

/obj/machinery/dish_drive/attack_ai(mob/living/user)
	if(machine_stat)
		return
	to_chat(user, span_notice("You send a disposal transmission signal to [src]."))
	do_the_dishes(TRUE)

/obj/machinery/dish_drive/AltClick(mob/living/user)
	if(user.can_perform_action(src, ALLOW_SILICON_REACH))
		do_the_dishes(TRUE)

/obj/machinery/dish_drive/proc/do_the_dishes(manual)
	if(!LAZYLEN(dish_drive_contents))
		if(manual)
			visible_message(span_notice("[src] is empty!"))
		return
	var/obj/machinery/disposal/bin/bin = locate() in view(7, src)
	if(!bin)
		if(manual)
			visible_message(span_warning("[src] buzzes. There are no disposal bins in range!"))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return
	var/disposed = 0
	for(var/obj/item/I in dish_drive_contents)
		if(is_type_in_list(I, disposable_items))
			LAZYREMOVE(dish_drive_contents, I)
			I.forceMove(bin)
			use_power(active_power_usage)
			disposed++
	if (disposed)
		visible_message(span_notice("[src] [pick("whooshes", "bwooms", "fwooms", "pshooms")] and beams [disposed] stored item\s into the nearby [bin.name]."))
		playsound(src, 'sound/items/pshoom.ogg', 50, TRUE)
		playsound(bin, 'sound/items/pshoom.ogg', 50, TRUE)
		Beam(bin, icon_state = "rped_upgrade", time = 5)
		bin.update_appearance()
		flick("synthesizer_beam", src)
	else
		visible_message(span_notice("There are no disposable items in [src]!"))
	time_since_dishes = world.time + 600
