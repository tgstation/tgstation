/obj/machinery/toaster
	name = "toaster"
	desc = "Turns bread slices into toasts. Somehow, it can work even without power. That is still a mystery. Tends to release its energy in a violent explosion if destroyed."
	icon = 'icons/obj/machines/kitchen.dmi'
	base_icon_state = "toaster"
	icon_state = "toaster"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	pass_flags = PASSTABLE
	anchored_tabletop_offset = 8
	max_integrity = 250
	use_power = NO_POWER_USE
	circuit = null /// Nanotrasen only allows one toaster per station. Those are extremely expensive for their ability to work without power at all. Plus they explode like a syndicate minibomb but without the gib.
	///Time it takes to make a toast
	var/toasting_time = 5 SECONDS
	///Max amount of bread at one time
	var/max_bread = 2
	/// Bread currently inside
	var/list/loaded_bread = list()
	/// Allowed types of bread and their toasting results
	var/list/toasting_list = list(
		/obj/item/food/breadslice/plain = /obj/item/food/griddle_toast/toaster,
		/obj/item/food/griddle_toast = /obj/item/food/griddle_toast/toastest,
		/obj/item/food/griddle_toast/toaster = /obj/item/food/griddle_toast/toastest
	)

/obj/machinery/toaster/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_DESTRUCTION, PROC_REF(kaboom))

/obj/machinery/toaster/proc/kaboom()
	SIGNAL_HANDLER
	explosion(
		src,
		heavy_impact_range = 2,
		light_impact_range = 4,
		flame_range = 2,
		flash_range = 3,
		adminlog = TRUE,
		smoke = TRUE,
	)

/obj/machinery/toaster/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/obj/item/food/food = tool

	if(!(food.type in toasting_list) || !istype(food))
		return NONE

	if(loaded_bread.len >= max_bread)
		user.balloon_alert(user, "[src] is already full!")
		return ITEM_INTERACT_BLOCKING

	if(!user.transferItemToLoc(tool, src))
		user.balloon_alert(user, "stuck to your hand!")
		return ITEM_INTERACT_BLOCKING

	loaded_bread += tool
	addtimer(CALLBACK(src, PROC_REF(finish_toasting), tool), toasting_time)
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/toaster/proc/finish_toasting(obj/item/food/ourbread)
	if(QDELETED(src) || QDELETED(ourbread) || !(ourbread in loaded_bread))
		return
	playsound(src, 'sound/machines/microwave/microwave-end.ogg', 50, FALSE)
	var/cooked_bread = toasting_list[ourbread.type]
	if(!cooked_bread)
		return
	new cooked_bread(drop_location())
	qdel(ourbread)
	update_appearance()

/obj/machinery/toaster/update_overlays()
	. = ..()
	if(loaded_bread.len > 0)
		. += mutable_appearance('icons/obj/machines/kitchen.dmi', "toaster_switch-on")
	else
		. += mutable_appearance('icons/obj/machines/kitchen.dmi', "toaster_switch-off")
	if(loaded_bread.len >= 1)
		. += mutable_appearance('icons/obj/machines/kitchen.dmi', "toaster-1")
	if(loaded_bread.len >= 2)
		. += mutable_appearance('icons/obj/machines/kitchen.dmi', "toaster-2")

/obj/machinery/toaster/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool))
		update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/toaster/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone in loaded_bread)
		loaded_bread -= gone
		update_appearance()
