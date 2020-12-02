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
	///Things that are being griddled right now
	var/list/griddled_objects = list()
	var/datum/looping_sound/deep_fryer/fry_loop

/obj/machinery/deepfryer/Initialize()
	. = ..()
	fry_loop = new(list(src), FALSE)


/obj/machinery/deepfryer/attackby(obj/item/I, mob/user)
	if(user.transferItemToLoc(I, drop_location(), silent = FALSE))
		var/list/click_params = params2list(params)
		//Center the icon where the user clicked.
		if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
			return
		//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
		I.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
		I.pixel_y = clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
		vis_contents += I
		RegisterSignal(I, COMSIG_MOVABLE_MOVED, .proc/ItemMoved)

/obj/machinery/deepfryer/proc/ItemMoved(obj/item/I, mob/user)


/obj/machinery/deepfryer/process(delta_time)
	..()
	var/datum/reagent/consumable/cooking_oil/C = reagents.has_reagent(/datum/reagent/consumable/cooking_oil)
	if(!C)
		return
	reagents.chem_temp = C.fry_temperature
	if(frying)
		reagents.trans_to(frying, oil_use * delta_time, multiplier = fry_speed * 3) //Fried foods gain more of the reagent thanks to space magic
		cook_time += fry_speed * delta_time
		if(cook_time >= DEEPFRYER_COOKTIME && !frying_fried)
			frying_fried = TRUE //frying... frying... fried
			playsound(src.loc, 'sound/machines/ding.ogg', 50, TRUE)
			audible_message("<span class='notice'>[src] dings!</span>")
		else if (cook_time >= DEEPFRYER_BURNTIME && !frying_burnt)
			frying_burnt = TRUE
			visible_message("<span class='warning'>[src] emits an acrid smell!</span>")
