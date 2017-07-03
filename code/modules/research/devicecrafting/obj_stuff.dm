/obj/var/datum/devicecrafting/holder/devicecrafting_holder


/obj/proc/add_device_holder(var/amount_of_slots)
	devicecrafting_holder = new
	devicecrafting_holder.my_obj = src
	devicecrafting_holder.max_devices = amount_of_slots
	devicecrafting_holder.init_holder()

/obj/attack_hand(mob/user)
	if(devicecrafting_holder)
		devicecrafting_holder.on_attack_hand(user)
	return

/obj/attack_ai(mob/user)
	if(devicecrafting_holder)
		devicecrafting_holder.on_attack_hand(user)
	return

/obj/examine(mob/user)
	..()
	if(devicecrafting_holder)
		if(devicecrafting_holder.devices.len)
			user << "The device frame holds the following:"
			for(var/obj/item/devicecrafting/device/D in devicecrafting_holder.devices)
				user << "[D]"
		else
			user << "The device frame is empty."