// A vendor machine for modular computer portable devices - Laptops and Tablets

/obj/machinery/lapvend
	name = "computer vendor"
	desc = "A vending machine with microfabricator capable of dispensing various NT-branded computers."
	icon = 'icons/obj/vending.dmi'
	icon_state = "robotics"
	layer = 2.9
	anchored = 1
	density = 1

	// The actual laptop/tablet
	var/obj/machinery/modular_computer/laptop/fabricated_laptop = null
	var/obj/item/modular_computer/tablet/fabricated_tablet = null

	// Utility vars
	var/state = 0 							// 0: Select device type, 1: Select loadout, 2: Payment, 3: Thankyou screen
	var/devtype = 0 						// 0: None(unselected), 1: Laptop, 2: Tablet
	var/total_price = 0						// Price of currently vended device.
	var/credits = 0

	// Device loadout
	var/dev_cpu = 1							// 1: Default, 2: Upgraded
	var/dev_battery = 1						// 1: Default, 2: Upgraded, 3: Advanced
	var/dev_disk = 1						// 1: Default, 2: Upgraded, 3: Advanced
	var/dev_netcard = 0						// 0: None, 1: Basic, 2: Long-Range
	var/dev_tesla = 0						// 0: None, 1: Standard (LAPTOP ONLY)
	var/dev_nanoprint = 0					// 0: None, 1: Standard
	var/dev_card = 0						// 0: None, 1: Standard

// Removes all traces of old order and allows you to begin configuration from scratch.
/obj/machinery/lapvend/proc/reset_order()
	state = 0
	devtype = 0
	if(fabricated_laptop)
		qdel(fabricated_laptop)
		fabricated_laptop = null
	if(fabricated_tablet)
		qdel(fabricated_tablet)
		fabricated_tablet = null
	dev_cpu = 1
	dev_battery = 1
	dev_disk = 1
	dev_netcard = 0
	dev_tesla = 0
	dev_nanoprint = 0
	dev_card = 0

// Recalculates the price and optionally even fabricates the device.
/obj/machinery/lapvend/proc/fabricate_and_recalc_price(fabricate = 0)
	total_price = 0
	if(devtype == 1) 		// Laptop, generally cheaper to make it accessible for most station roles
		if(fabricate)
			fabricated_laptop = new(src)
		total_price = 99
		switch(dev_cpu)
			if(1)
				if(fabricate)
					fabricated_laptop.cpu.processor_unit = new/obj/item/weapon/computer_hardware/processor_unit/small(fabricated_laptop.cpu)
			if(2)
				if(fabricate)
					fabricated_laptop.cpu.processor_unit = new/obj/item/weapon/computer_hardware/processor_unit(fabricated_laptop.cpu)
				total_price += 299
		switch(dev_battery)
			if(1) // Basic(750C)
				if(fabricate)
					fabricated_laptop.cpu.battery_module = new/obj/item/weapon/computer_hardware/battery_module(fabricated_laptop.cpu)
			if(2) // Upgraded(1100C)
				if(fabricate)
					fabricated_laptop.cpu.battery_module = new/obj/item/weapon/computer_hardware/battery_module/advanced(fabricated_laptop.cpu)
				total_price += 199
			if(3) // Advanced(1500C)
				if(fabricate)
					fabricated_laptop.cpu.battery_module = new/obj/item/weapon/computer_hardware/battery_module/super(fabricated_laptop.cpu)
				total_price += 499
		switch(dev_disk)
			if(1) // Basic(128GQ)
				if(fabricate)
					fabricated_laptop.cpu.hard_drive = new/obj/item/weapon/computer_hardware/hard_drive(fabricated_laptop.cpu)
			if(2) // Upgraded(256GQ)
				if(fabricate)
					fabricated_laptop.cpu.hard_drive = new/obj/item/weapon/computer_hardware/hard_drive/advanced(fabricated_laptop.cpu)
				total_price += 99
			if(3) // Advanced(512GQ)
				if(fabricate)
					fabricated_laptop.cpu.hard_drive = new/obj/item/weapon/computer_hardware/hard_drive/super(fabricated_laptop.cpu)
				total_price += 299
		switch(dev_netcard)
			if(1) // Basic(Short-Range)
				if(fabricate)
					fabricated_laptop.cpu.network_card = new/obj/item/weapon/computer_hardware/network_card(fabricated_laptop.cpu)
				total_price += 99
			if(2) // Advanced (Long Range)
				if(fabricate)
					fabricated_laptop.cpu.network_card = new/obj/item/weapon/computer_hardware/network_card/advanced(fabricated_laptop.cpu)
				total_price += 299
		if(dev_tesla)
			total_price += 399
			if(fabricate)
				fabricated_laptop.tesla_link = new/obj/item/weapon/computer_hardware/tesla_link(fabricated_laptop)
		if(dev_nanoprint)
			total_price += 99
			if(fabricate)
				fabricated_laptop.cpu.nano_printer = new/obj/item/weapon/computer_hardware/nano_printer(fabricated_laptop.cpu)
		if(dev_card)
			total_price += 199
			if(fabricate)
				fabricated_laptop.cpu.card_slot = new/obj/item/weapon/computer_hardware/card_slot(fabricated_laptop.cpu)

		return total_price
	else if(devtype == 2) 	// Tablet, more expensive, not everyone could probably afford this.
		if(fabricate)
			fabricated_tablet = new(src)
			fabricated_tablet.processor_unit = new/obj/item/weapon/computer_hardware/processor_unit/small(fabricated_tablet)
		total_price = 199
		switch(dev_battery)
			if(1) // Basic(300C)
				if(fabricate)
					fabricated_tablet.battery_module = new/obj/item/weapon/computer_hardware/battery_module/nano(fabricated_tablet)
			if(2) // Upgraded(500C)
				if(fabricate)
					fabricated_tablet.battery_module = new/obj/item/weapon/computer_hardware/battery_module/micro(fabricated_tablet)
				total_price += 199
			if(3) // Advanced(750C)
				if(fabricate)
					fabricated_tablet.battery_module = new/obj/item/weapon/computer_hardware/battery_module(fabricated_tablet)
				total_price += 499
		switch(dev_disk)
			if(1) // Basic(32GQ)
				if(fabricate)
					fabricated_tablet.hard_drive = new/obj/item/weapon/computer_hardware/hard_drive/micro(fabricated_tablet)
			if(2) // Upgraded(64GQ)
				if(fabricate)
					fabricated_tablet.hard_drive = new/obj/item/weapon/computer_hardware/hard_drive/small(fabricated_tablet)
				total_price += 99
			if(3) // Advanced(128GQ)
				if(fabricate)
					fabricated_tablet.hard_drive = new/obj/item/weapon/computer_hardware/hard_drive(fabricated_tablet)
				total_price += 299
		switch(dev_netcard)
			if(1) // Basic(Short-Range)
				if(fabricate)
					fabricated_tablet.network_card = new/obj/item/weapon/computer_hardware/network_card(fabricated_tablet)
				total_price += 99
			if(2) // Advanced (Long Range)
				if(fabricate)
					fabricated_tablet.network_card = new/obj/item/weapon/computer_hardware/network_card/advanced(fabricated_tablet)
				total_price += 299
		if(dev_nanoprint)
			total_price += 99
			if(fabricate)
				fabricated_tablet.nano_printer = new/obj/item/weapon/computer_hardware/nano_printer(fabricated_tablet)
		if(dev_card)
			total_price += 199
			if(fabricate)
				fabricated_tablet.card_slot = new/obj/item/weapon/computer_hardware/card_slot(fabricated_tablet)
		return total_price
	return 0





/obj/machinery/lapvend/ui_act(action, params)
	if(..())
		return 1

	switch(action)
		if("pick_device")
			if(state) // We've already picked a device type
				return 0
			devtype = text2num(params["pick"])
			state = 1
			fabricate_and_recalc_price(0)
			return 1
		if("clean_order")
			reset_order()
			return 1
	if((state != 1) && devtype) // Following IFs should only be usable when in the Select Loadout mode
		return 0
	switch(action)
		if("confirm_order")
			state = 2 // Wait for ID swipe for payment processing
			fabricate_and_recalc_price(0)
			return 1
		if("hw_cpu")
			dev_cpu = text2num(params["cpu"])
			fabricate_and_recalc_price(0)
			return 1
		if("hw_battery")
			dev_battery = text2num(params["battery"])
			fabricate_and_recalc_price(0)
			return 1
		if("hw_disk")
			dev_disk = text2num(params["disk"])
			fabricate_and_recalc_price(0)
			return 1
		if("hw_netcard")
			dev_netcard = text2num(params["netcard"])
			fabricate_and_recalc_price(0)
			return 1
		if("hw_tesla")
			dev_tesla = text2num(params["tesla"])
			fabricate_and_recalc_price(0)
			return 1
		if("hw_nanoprint")
			dev_nanoprint = text2num(params["print"])
			fabricate_and_recalc_price(0)
			return 1
		if("hw_card")
			dev_card = text2num(params["card"])
			fabricate_and_recalc_price(0)
			return 1
	return 0

/obj/machinery/lapvend/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/lapvend/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	if(stat & (BROKEN | NOPOWER | MAINT))
		if(ui)
			ui.close()
		return 0



	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "computer_fabricator", "Personal Computer Vendor", 500, 400, state = state)
		ui.open()
		ui.set_autoupdate(state = 1)


obj/machinery/lapvend/attackby(obj/item/I as obj, mob/user as mob)

	if(istype(I,/obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/c = I

		if(!user.drop_item(c))
			return
		credits += c.value
		qdel(c)
		return


	var/obj/item/weapon/card/id/D = I.GetID()
	// Awaiting payment state
	if(state == 2 && D)
		if(process_payment(D,I))
			fabricate_and_recalc_price(1)
			if((devtype == 1) && fabricated_laptop)
				fabricated_laptop.cpu.battery_module.charge_to_full()
				fabricated_laptop.forceMove(src.loc)
				fabricated_laptop.close_laptop()
				fabricated_laptop = null
			else if((devtype == 2) && fabricated_tablet)
				fabricated_tablet.battery_module.charge_to_full()
				fabricated_tablet.forceMove(src.loc)
				fabricated_tablet = null
			say("Enjoy your new product!")
			state = 3
			return 1
		return 0
	return ..()


// Simplified payment processing, returns 1 on success.
/obj/machinery/lapvend/proc/process_payment(obj/item/weapon/card/id/I, obj/item/ID_container, obj/item/stack/spacecash)
	if(total_price > credits)
		say("Insufficient credits.")
		return 0
	else
		return 1

	visible_message("<span class='info'>\The [usr] swipes \the [I] through \the [src].</span>")

/obj/machinery/lapvend/ui_data(mob/user)

	var/list/data = list()
	data["state"] = state
	if(state == 1)
		data["devtype"] = devtype
		data["hw_battery"] = dev_battery
		data["hw_disk"] = dev_disk
		data["hw_netcard"] = dev_netcard
		data["hw_tesla"] = dev_tesla
		data["hw_nanoprint"] = dev_nanoprint
		data["hw_card"] = dev_card
		data["hw_cpu"] = dev_cpu
	if(state == 1 || state == 2)
		data["totalprice"] = total_price

	return data