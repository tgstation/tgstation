/obj/item/computer_hardware/cartridge_slot
	name = "cartridge reader" // \improper breaks the find_hardware_by_name proc
	desc = "A module allowing this tablet to read programs off of old-school PDA cartridges."
	power_usage = 0
	icon_state = "cartridge_mini"
	w_class = WEIGHT_CLASS_TINY
	device_type = MC_CART

	var/obj/item/cartridge/stored_cart
	var/stored_programs = list()

/obj/item/computer_hardware/cartridge_slot/Destroy()
	if(stored_cart)
		QDEL_NULL(stored_cart)
	return ..()

/obj/item/computer_hardware/cartridge_slot/proc/CanSpam() // whether or not we are currently capable of using the send to all feature (the only one that matters)
	return stored_cart?.spam_enabled

/obj/item/computer_hardware/cartridge_slot/try_insert(obj/item/I, mob/living/user = null)
	if(!holder)
		return FALSE
	if(!istype(I, /obj/item/cartridge))
		return FALSE
	if(!in_range(user, I))
		return FALSE

	if(stored_cart)
		if(user && !issilicon(user) && in_range(src, user))
			user.put_in_hands(stored_cart)
		else
			stored_cart.forceMove(drop_location())
			stored_cart = null
			stored_programs = list()

	if(user)
		if(!user.transferItemToLoc(I, src))
			return FALSE
	else
		I.forceMove(src)

	stored_cart = I
	set_program(stored_cart)
	to_chat(user, span_notice("You insert \the [I] into [src]."))
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)

	return TRUE

/obj/item/computer_hardware/cartridge_slot/try_eject(mob/living/user = null, forced = FALSE)
	if(!stored_cart)
		to_chat(user, span_warning("There is no cart in \the [src]."))
		return FALSE

	if(user && !issilicon(user) && in_range(src, user))
		user.put_in_hands(stored_cart)
	else
		stored_cart.forceMove(drop_location())

	stored_cart = null
	stored_programs = list()

	to_chat(user, span_notice("You remove the cart from \the [src]."))
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)

	return TRUE

// finds the program to store in the cart reader
/obj/item/computer_hardware/cartridge_slot/proc/set_program(obj/item/cartridge/cart)
	stored_programs = list()

	if(istype(cart, /obj/item/cartridge/engineering))
		var/datum/computer_file/program/power_monitor/pm = new(src)
		stored_programs += pm

/obj/item/computer_hardware/cartridge_slot/proc/find_file_by_name(filename)
	if(!filename)
		return null

	if(!stored_programs)
		return null

	for(var/datum/computer_file/F in stored_programs)
		if(F.filename == filename)
			return F
	return null
