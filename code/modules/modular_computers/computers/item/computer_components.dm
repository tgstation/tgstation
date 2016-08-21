// Installs component.
/obj/item/modular_computer/proc/install_component(obj/item/weapon/computer_hardware/H, mob/living/user = null)
	if(!H.can_install)
		return 0

	if(user && !user.unEquip(H))
		return 0

	if(H.w_class > max_hardware_size)
		user << "<span class='warning'>This component is too large for \the [src]!</span>"
		return 0

	if(!H.on_install(src, user))
		return 0

	if(istype(H, /obj/item/weapon/computer_hardware/hard_drive/portable))
		if(portable_drive)
			user << "<span class='warning'>This computer's FDD is already occupied by \the [portable_drive].</span>"
			return 0
		portable_drive = H

	else if(istype(H, /obj/item/weapon/computer_hardware/processor_unit))
		if(processor_unit)
			user << "<span class='warning'>This computer's CPU slot is already occupied by \the [processor_unit].</span>"
			return 0
		processor_unit = H
	else if(istype(H, /obj/item/weapon/computer_hardware/hard_drive))
		if(hard_drive)
			user << "<span class='warning'>This computer's data port is already occupied by \the [hard_drive].</span>"
			return 0
		hard_drive = H

	else if(istype(H, /obj/item/weapon/computer_hardware/battery))
		if(battery_module)
			user << "<span class='warning'>This computer's power converter slot is already occupied by \the [battery_module].</span>"
			return 0
		battery_module = H
	else if(istype(H, /obj/item/weapon/computer_hardware/recharger))
		if(recharger)
			user << "<span class='warning'>This computer's recharger slot is already occupied by \the [recharger].</span>"
			return 0
		recharger = H

	else if(istype(H, /obj/item/weapon/computer_hardware/card_slot))
		if(card_slot)
			user << "<span class='warning'>This computer's card reader slot is already occupied by \the [card_slot].</span>"
			return 0
		card_slot = H
	else if(istype(H, /obj/item/weapon/computer_hardware/network_card))
		if(network_card)
			user << "<span class='warning'>This computer's network card is already occupied by \the [network_card].</span>"
			return 0
		network_card = H
	else if(istype(H, /obj/item/weapon/computer_hardware/printer))
		if(printer)
			user << "<span class='warning'>This computer's printer slot is already occupied by \the [printer].</span>"
			return 0
		printer = H

	user << "<span class='notice'>You install \the [H] into \the [src].</span>"
	H.forceMove(src)
	H.holder = src
	all_components |= H
	return 1


// Uninstalls component.
/obj/item/modular_computer/proc/uninstall_component(obj/item/weapon/computer_hardware/H, mob/living/user = null)
	if(H.holder != src) // Not our component at all.
		return 0

	if(!H.on_remove(src, user))
		return 0

	if(processor_unit == H)
		processor_unit = null
	if(hard_drive == H)
		hard_drive = null

	if(battery_module == H)
		battery_module = null
	if(recharger == H)
		recharger = null

	if(card_slot == H)
		card_slot = null
	if(network_card == H)
		network_card = null
	if(printer == H)
		printer = null
	if(portable_drive == H)
		portable_drive = null

	user << "<span class='notice'>You remove \the [H] from \the [src].</span>"

	H.forceMove(get_turf(src))
	H.holder = null
	all_components -= H
	if(enabled && (!processor_unit || !hard_drive || !use_power()))
		shutdown_computer()
	return 1


// Checks all hardware pieces to determine if name matches, if yes, returns the hardware piece, otherwise returns null
/obj/item/modular_computer/proc/find_hardware_by_name(name)
	for(var/i in all_components)
		var/obj/O = i
		if(O.name == name)
			return O
	return null
