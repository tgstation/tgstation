/obj/machinery/griddle
	name = "griddle"
	desc = "Because using pans is for pansies."
	icon = 'icons/obj/machines/kitchen.dmi'
	icon_state = "griddle1_off"
	density = TRUE
	pass_flags_self = PASSMACHINE | PASSTABLE| LETPASSTHROW // It's roughly the height of a table.
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/griddle
	processing_flags = START_PROCESSING_MANUALLY
	resistance_flags = FIRE_PROOF

	///Things that are being griddled right now
	var/list/griddled_objects = list()
	///Looping sound for the grill
	var/datum/looping_sound/grill/grill_loop
	///Whether or not the machine is turned on right now
	var/on = FALSE
	///What variant of griddle is this?
	var/variant = 1
	///How many shit fits on the griddle?
	var/max_items = 8

/obj/machinery/griddle/Initialize(mapload)
	. = ..()
	grill_loop = new(src, FALSE)
	if(isnum(variant))
		variant = rand(1,3)
	RegisterSignal(src, COMSIG_ATOM_EXPOSE_REAGENT, PROC_REF(on_expose_reagent))
	RegisterSignal(src, COMSIG_STORAGE_DUMP_CONTENT, PROC_REF(on_storage_dump))

/obj/machinery/griddle/Destroy()
	QDEL_NULL(grill_loop)
	return ..()

/obj/machinery/griddle/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_deconstruction_crowbar(I, ignore_panel = TRUE))
		return
	variant = rand(1,3)

/obj/machinery/griddle/proc/on_expose_reagent(atom/parent_atom, datum/reagent/exposing_reagent, reac_volume)
	SIGNAL_HANDLER

	if(griddled_objects.len >= max_items || !istype(exposing_reagent, /datum/reagent/consumable/pancakebatter) || reac_volume < 5)
		return NONE //make sure you have space... it's actually batter... and a proper amount of it.

	for(var/pancakes in 1 to FLOOR(reac_volume, 5) step 5) //this adds as many pancakes as you possibly could make, with 5u needed per pancake
		var/obj/item/food/pancakes/raw/new_pancake = new(src)
		new_pancake.pixel_x = rand(16,-16)
		new_pancake.pixel_y = rand(16,-16)
		AddToGrill(new_pancake)
		if(griddled_objects.len >= max_items)
			break
	visible_message(span_notice("[exposing_reagent] begins to cook on [src]."))
	return NONE

/obj/machinery/griddle/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	return default_deconstruction_crowbar(I, ignore_panel = TRUE)


/obj/machinery/griddle/attackby(obj/item/I, mob/user, params)

	if(griddled_objects.len >= max_items)
		to_chat(user, span_notice("[src] can't fit more items!"))
		return
	var/list/modifiers = params2list(params)
	//Center the icon where the user clicked.
	if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
		return
	if(user.transferItemToLoc(I, src, silent = FALSE))
		//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
		I.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(world.icon_size/2), world.icon_size/2)
		I.pixel_y = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(world.icon_size/2), world.icon_size/2)
		to_chat(user, span_notice("You place [I] on [src]."))
		AddToGrill(I, user)
	else
		return ..()

/obj/machinery/griddle/item_interaction_secondary(mob/living/user, obj/item/item, list/modifiers)
	if(isnull(item.atom_storage))
		return NONE

	for(var/obj/tray_item in griddled_objects)
		item.atom_storage.attempt_insert(tray_item, user, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/griddle/item_interaction(mob/living/user, obj/item/item, list/modifiers)
	if(isnull(item.atom_storage))
		return NONE

	if(length(contents) >= max_items)
		balloon_alert(user, "it's full!")
		return ITEM_INTERACT_BLOCKING

	if(!istype(item, /obj/item/storage/bag/tray))
		// Non-tray dumping requires a do_after
		to_chat(user, span_notice("You start dumping out the contents of [item] into [src]..."))
		if(!do_after(user, 2 SECONDS, target = item))
			return ITEM_INTERACT_BLOCKING

	var/loaded = 0
	for(var/obj/tray_item in item)
		if(!IS_EDIBLE(tray_item))
			continue
		if(length(contents) >= max_items)
			break
		if(item.atom_storage.attempt_remove(tray_item, src))
			loaded++
			AddToGrill(tray_item, user)
	if(loaded)
		to_chat(user, span_notice("You insert [loaded] item\s into [src]."))
		update_appearance()
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/griddle/attack_hand(mob/user, list/modifiers)
	. = ..()
	toggle_mode()

/obj/machinery/griddle/attack_robot(mob/user)
	. = ..()
	toggle_mode()

/obj/machinery/griddle/proc/toggle_mode()
	on = !on
	if(on)
		begin_processing()
	else
		end_processing()
	update_appearance()
	update_grill_audio()

/obj/machinery/griddle/begin_processing()
	. = ..()
	for(var/obj/item/item_to_grill as anything in griddled_objects)
		SEND_SIGNAL(item_to_grill, COMSIG_ITEM_GRILL_TURNED_ON)

/obj/machinery/griddle/end_processing()
	. = ..()
	for(var/obj/item/item_to_grill as anything in griddled_objects)
		SEND_SIGNAL(item_to_grill, COMSIG_ITEM_GRILL_TURNED_OFF)

/obj/machinery/griddle/proc/AddToGrill(obj/item/item_to_grill, mob/user)
	vis_contents += item_to_grill
	griddled_objects += item_to_grill
	item_to_grill.flags_1 |= IS_ONTOP_1
	item_to_grill.vis_flags |= VIS_INHERIT_PLANE

	SEND_SIGNAL(item_to_grill, COMSIG_ITEM_GRILL_PLACED, user)
	if(on)
		SEND_SIGNAL(item_to_grill, COMSIG_ITEM_GRILL_TURNED_ON)
	RegisterSignal(item_to_grill, COMSIG_MOVABLE_MOVED, PROC_REF(ItemMoved))
	RegisterSignal(item_to_grill, COMSIG_ITEM_GRILLED, PROC_REF(GrillCompleted))
	RegisterSignal(item_to_grill, COMSIG_QDELETING, PROC_REF(ItemRemovedFromGrill))
	update_grill_audio()
	update_appearance()

/obj/machinery/griddle/proc/ItemRemovedFromGrill(obj/item/ungrill)
	SIGNAL_HANDLER
	ungrill.flags_1 &= ~IS_ONTOP_1
	ungrill.vis_flags &= ~VIS_INHERIT_PLANE
	griddled_objects -= ungrill
	vis_contents -= ungrill
	UnregisterSignal(ungrill, list(COMSIG_ITEM_GRILLED, COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	update_grill_audio()

/obj/machinery/griddle/proc/ItemMoved(obj/item/I, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	ItemRemovedFromGrill(I)

/obj/machinery/griddle/proc/GrillCompleted(obj/item/source, atom/grilled_result)
	SIGNAL_HANDLER
	AddToGrill(grilled_result)

/obj/machinery/griddle/proc/update_grill_audio()
	if(on && griddled_objects.len)
		grill_loop.start()
	else
		grill_loop.stop()

/obj/machinery/griddle/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 2 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/griddle/proc/on_storage_dump(datum/source, datum/storage/storage, mob/user)
	SIGNAL_HANDLER

	for(var/obj/item/to_dump in storage.real_location)
		if(griddled_objects.len >= max_items)
			break

		if(!storage.attempt_remove(to_dump, src, silent = TRUE))
			continue

		to_dump.pixel_x = to_dump.base_pixel_x + rand(-5, 5)
		to_dump.pixel_y = to_dump.base_pixel_y + rand(-5, 5)
		AddToGrill(to_dump, user)

	to_chat(user, span_notice("You dump out [storage.parent] onto [src]."))
	return STORAGE_DUMP_HANDLED

/obj/machinery/griddle/process(seconds_per_tick)
	for(var/obj/item/griddled_item as anything in griddled_objects)
		if(SEND_SIGNAL(griddled_item, COMSIG_ITEM_GRILL_PROCESS, src, seconds_per_tick) & COMPONENT_HANDLED_GRILLING)
			continue
		griddled_item.fire_act(1000) //Hot hot hot!
		if(prob(10))
			visible_message(span_danger("[griddled_item] doesn't seem to be doing too great on the [src]!"))

		use_energy(active_power_usage)

	var/turf/griddle_loc = loc
	if(isturf(griddle_loc))
		griddle_loc.hotspot_expose(800, 100)

/obj/machinery/griddle/update_icon_state()
	icon_state = "griddle[variant]_[on ? "on" : "off"]"
	return ..()

/obj/machinery/griddle/stand
	name = "griddle stand"
	desc = "A more commercialized version of your traditional griddle. What happened to the good old days where people griddled with passion?"
	variant = "stand"

/obj/machinery/griddle/stand/update_overlays()
	. = ..()
	. += "front_bar"
