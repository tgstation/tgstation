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

/obj/machinery/griddle/Initialize()
	. = ..()
	grill_loop = new(list(src), FALSE)
	if(isnum(variant))
		variant = rand(1,3)
	RegisterSignal(src, COMSIG_ATOM_EXPOSE_REAGENT, .proc/on_expose_reagent)

/obj/machinery/griddle/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(flags_1 & NODECONSTRUCT_1)
		return
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
	visible_message("<span class='notice'>[exposing_reagent] begins to cook on [src].</span>")
	return NONE

/obj/machinery/griddle/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	return default_deconstruction_crowbar(I, ignore_panel = TRUE)


/obj/machinery/griddle/attackby(obj/item/I, mob/user, params)
	if(griddled_objects.len >= max_items)
		to_chat(user, "<span class='notice'>[src] can't fit more items!</span>")
		return
	var/list/click_params = params2list(params)
	//Center the icon where the user clicked.
	if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
		return
	if(user.transferItemToLoc(I, src, silent = FALSE))
		//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
		I.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
		I.pixel_y = clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
		to_chat(user, "<span class='notice'>You place [I] on [src].</span>")
		AddToGrill(I, user)
		update_icon()
	else
		return ..()

/obj/machinery/griddle/attack_hand(mob/user)
	. = ..()
	on = !on
	if(on)
		begin_processing()
	else
		end_processing()
	update_icon()
	update_grill_audio()


/obj/machinery/griddle/proc/AddToGrill(obj/item/item_to_grill, mob/user)
	vis_contents += item_to_grill
	griddled_objects += item_to_grill
	item_to_grill.flags_1 |= IS_ONTOP_1
	RegisterSignal(item_to_grill, COMSIG_MOVABLE_MOVED, .proc/ItemMoved)
	RegisterSignal(item_to_grill, COMSIG_GRILL_COMPLETED, .proc/GrillCompleted)
	RegisterSignal(item_to_grill, COMSIG_PARENT_QDELETING, .proc/ItemRemovedFromGrill)
	update_grill_audio()

/obj/machinery/griddle/proc/ItemRemovedFromGrill(obj/item/I)
	I.flags_1 &= ~IS_ONTOP_1
	griddled_objects -= I
	vis_contents -= I
	UnregisterSignal(I, list(COMSIG_GRILL_COMPLETED, COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
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

///Override to prevent storage dumping onto the griddle until I figure out how to navigate the mess that is storage code to allow me to nicely move the dumped objects onto the griddle.
/obj/machinery/griddle/get_dumping_location(obj/item/storage/source, mob/user)
	return

/obj/machinery/griddle/process(delta_time)
	..()
	for(var/i in griddled_objects)
		var/obj/item/griddled_item = i
		if(SEND_SIGNAL(griddled_item, COMSIG_ITEM_GRILLED, src, delta_time) & COMPONENT_HANDLED_GRILLING)
			continue
		griddled_item.fire_act(1000) //Hot hot hot!
		if(prob(10))
			visible_message("<span class='danger'>[griddled_item] doesn't seem to be doing too great on the [src]!</span>")

/obj/machinery/griddle/update_icon_state()
	. = ..()
	icon_state = "griddle[variant]_[on ? "on" : "off"]"

/obj/machinery/griddle/stand
	name = "griddle stand"
	desc = "A more commercialized version of your traditional griddle. What happened to the good old days where people griddled with passion?"
	variant = "stand"

/obj/machinery/griddle/stand/update_overlays()
	. = ..()
	. += "front_bar"
