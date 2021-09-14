/obj/machinery/plate_press
	name = "license plate press"
	desc = "You know, we're making a lot of license plates for a station with literally no cars in it."
	icon = 'icons/obj/machines/prison.dmi'
	icon_state = "offline"
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 50
	var/obj/item/stack/license_plates/empty/current_plate
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

/obj/machinery/plate_press/attackby(obj/item/I, mob/living/user, params)
	if(!is_operational)
		to_chat(user, span_warning("[src] has to be on to do this!"))
		return FALSE
	if(current_plate)
		to_chat(user, span_warning("[src] already has a plate in it!"))
		return FALSE
	if(istype(I, /obj/item/stack/license_plates/empty))
		var/obj/item/stack/license_plates/empty/plate = I
		plate.use(1)
		current_plate = new plate.type(src, 1) //Spawn a new single sheet in the machine
		update_appearance()
	else
		return ..()

/obj/machinery/plate_press/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!pressing && current_plate)
		work_press(user)

///This proc attempts to create a plate. User cannot move during this process.
/obj/machinery/plate_press/proc/work_press(mob/living/user)

	pressing = TRUE
	update_appearance()
	to_chat(user, span_notice("You start pressing a new license plate!"))

	if(!do_after(user, 40, target = src))
		pressing = FALSE
		update_appearance()
		return FALSE

	use_power(100)
	to_chat(user, span_notice("You finish pressing a new license plate!"))

	pressing = FALSE
	QDEL_NULL(current_plate)
	update_appearance()

	new /obj/item/stack/license_plates/filled(drop_location(), 1)
