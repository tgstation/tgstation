/obj/machinery/griddle
	name = "griddle"
	desc = "Because using pans is for pansies."
	icon = 'icons/obj/machines/griddle.dmi'
	icon_state = "griddle1_off"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
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











/obj/machinery/griddle/proc/ItemMoved(obj/item/I, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	ItemRemovedFromGrill(I)

/obj/machinery/griddle/proc/GrillCompleted(obj/item/source, atom/grilled_result)
	SIGNAL_HANDLER
	AddToGrill(grilled_result)



/obj/machinery/oven
	name = "oven"
	desc = "Why do they call it oven when you of in the cold food of out hot eat the food?"
	icon = 'icons/obj/machines/griddle.dmi'
	icon_state = "griddle1_off"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/oven
	processing_flags = START_PROCESSING_MANUALLY
	resistance_flags = FIRE_PROOF

	///The tray inside of this oven, if there is one.
	var/obj/item/plate/oven_tray/used_tray
	///Whether or not the oven is on, duh.
	var/on
	///Whether or not the oven is open.
	var/open
	///Looping sound for the oven
	var/datum/looping_sound/oven/oven_loop

/obj/machinery/oven/Initialize()
	. = ..()
	oven_loop = new(list(src), FALSE)

/obj/machinery/oven/Destroy()
	QDEL_NULL(oven_loop)
	. = ..()

/obj/machinery/griddle/attack_hand(mob/user, modifiers)
	if(used_tray)
		remove_tray(user)


/obj/machinery/griddle/attack_hand_secondary(mob/user, modifiers)
	. = ..()
	on = !on
	if(on)
		begin_processing()
	else
		end_processing()
	update_appearance()
	update_grill_audio()

/obj/machinery/oven/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(flags_1 & NODECONSTRUCT_1)
		return
	if(default_deconstruction_crowbar(I, ignore_panel = TRUE))
		return


/obj/machinery/oven/proc/update_grill_audio()
	if(on && !open)
		oven_loop.start()
	else
		oven_loop.stop()

/obj/machinery/oven/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I, 2 SECONDS)
	return TRUE

/obj/machinery/griddle/attackby(obj/item/I, mob/user, params)
	if(!used_tray && istype(I, /obj/item/plate/oven_tray))
		if(user.transferItemToLoc(I, src, silent = FALSE))
			to_chat(user, span_notice("You put [I] in [src]."))
			add_to_oven(I, user)
			update_appearance()
	else
		return ..()

///Adds a tray to the oven, making sure the shit can get baked.
/obj/machinery/griddle/proc/add_to_oven(obj/item/plate/oven_tray, mob/user)
	used_tray = oven_tray

	if(used_tray)
	RegisterSignal(item_to_grill, COMSIG_ITEM_BAKE_COMPLETED, .proc/GrillCompleted)
	update_grill_audio()


/obj/machinery/oven/process(delta_time)
	..()
	if(!used_tray) //No tray? Don't bother.
		return
	for(var/obj/item/baked_item in used_tray.contents)
		if(SEND_SIGNAL(baked_item, COMSIG_ITEM_BAKED, src, delta_time) & COMPONENT_HANDLED_BAKING)
			continue
		griddled_item.fire_act(1000) //Hot hot hot!
		if(DT_PROB(10))
			visible_message(span_danger("A nasty smell comes from [baked_item] inside of the [src]!"))


/obj/machinery/oven/update_icon_state()
	icon_state = "griddle[variant]_[on ? "on" : "off"]"
	return ..()

/obj/item/plate/oven_tray
	name = "oven tray"
	desc = "Time to bake cookies!"
	icon = 'icons/obj/kitchen.dmi'



