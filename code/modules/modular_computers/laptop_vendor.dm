// A vendor machine for modular computer portable devices - Laptops and Tablets

/obj/machinery/lapvend
	name = "computer vendor"
	desc = "A vending machine with microfabricator capable of dispensing various NT-branded computers."
	icon = 'icons/obj/vending.dmi'
	icon_state = "robotics"
	layer = 2.9
	density = TRUE

	// The actual laptop/tablet
	var/obj/item/modular_computer/laptop/fabricated_laptop = null
	var/obj/item/modular_computer/tablet/fabricated_tablet = null

	// Utility vars
	var/state = 0 // 0: Select device type, 1: Select loadout, 2: Payment, 3: Thankyou screen
	var/devtype = 0 // 0: None(unselected), 1: Laptop, 2: Tablet
	var/total_price = 0 // Price of currently vended device.
	var/credits = 0

	// Device loadout
	var/dev_battery = 1 // 1: Default, 2: Upgraded, 3: Advanced
	var/dev_card = 0 // 0: None, 1: Standard

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
	dev_battery = 1
	dev_card = 0

// Recalculates the price and optionally even fabricates the device.
/obj/machinery/lapvend/proc/fabricate_and_recalc_price(fabricate = FALSE)
	total_price = 0
	if(devtype == 1) // Laptop, generally cheaper to make it accessible for most station roles
		var/obj/item/computer_hardware/battery/battery_module = null
		if(fabricate)
			fabricated_laptop = new /obj/item/modular_computer/laptop/buildable(src)
			fabricated_laptop.install_component(new /obj/item/computer_hardware/card_slot)
			fabricated_laptop.install_component(new /obj/item/computer_hardware/battery)
			battery_module = fabricated_laptop.all_components[MC_CELL]
		total_price = 99
		switch(dev_battery)
			if(1) // Basic(750C)
				if(fabricate)
					battery_module.try_insert(new /obj/item/stock_parts/cell/computer)
			if(2) // Upgraded(1100C)
				if(fabricate)
					battery_module.try_insert(new /obj/item/stock_parts/cell/computer/advanced)
				total_price += 199
			if(3) // Advanced(1500C)
				if(fabricate)
					battery_module.try_insert(new /obj/item/stock_parts/cell/computer/super)
				total_price += 499
		if(dev_card)
			total_price += 199
			if(fabricate)
				fabricated_laptop.install_component(new /obj/item/computer_hardware/card_slot/secondary)

		return total_price
	else if(devtype == 2) // Tablet, more expensive, not everyone could probably afford this.
		var/obj/item/computer_hardware/battery/battery_module = null
		if(fabricate)
			fabricated_tablet = new(src)
			fabricated_tablet.install_component(new /obj/item/computer_hardware/battery)
			fabricated_tablet.install_component(new/obj/item/computer_hardware/card_slot)
			battery_module = fabricated_tablet.all_components[MC_CELL]
		total_price = 199
		switch(dev_battery)
			if(1) // Basic(300C)
				if(fabricate)
					battery_module.try_insert(new /obj/item/stock_parts/cell/computer/nano)
			if(2) // Upgraded(500C)
				if(fabricate)
					battery_module.try_insert(new /obj/item/stock_parts/cell/computer/micro)
				total_price += 199
			if(3) // Advanced(750C)
				if(fabricate)
					battery_module.try_insert(new /obj/item/stock_parts/cell/computer)
				total_price += 499
		if(dev_card)
			total_price += 199
			if(fabricate)
				fabricated_tablet.install_component(new/obj/item/computer_hardware/card_slot/secondary)
		return total_price
	return FALSE





/obj/machinery/lapvend/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("pick_device")
			if(state) // We've already picked a device type
				return FALSE
			devtype = text2num(params["pick"])
			state = 1
			fabricate_and_recalc_price(FALSE)
			return TRUE
		if("clean_order")
			reset_order()
			return TRUE
		if("purchase")
			try_purchase()
			return TRUE
	if((state != 1) && devtype) // Following IFs should only be usable when in the Select Loadout mode
		return FALSE
	switch(action)
		if("confirm_order")
			state = 2 // Wait for ID swipe for payment processing
			fabricate_and_recalc_price(FALSE)
			return TRUE
		if("hw_battery")
			dev_battery = text2num(params["battery"])
			fabricate_and_recalc_price(FALSE)
			return TRUE
		if("hw_card")
			dev_card = text2num(params["card"])
			fabricate_and_recalc_price(FALSE)
			return TRUE
	return FALSE

/obj/machinery/lapvend/ui_interact(mob/user, datum/tgui/ui)
	if(machine_stat & (BROKEN | NOPOWER | MAINT))
		if(ui)
			ui.close()
		return FALSE

	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "ComputerFabricator")
		ui.open()

/obj/machinery/lapvend/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/c = I
		if(!user.temporarilyRemoveItemFromInventory(c))
			return
		credits += c.value
		visible_message(span_info("[span_name("[user]")] inserts [c.value] cr into [src]."))
		qdel(c)
		return
	else if(istype(I, /obj/item/holochip))
		var/obj/item/holochip/HC = I
		credits += HC.credits
		visible_message(span_info("[user] inserts a [HC.credits] cr holocredit chip into [src]."))
		qdel(HC)
		return
	else if(isidcard(I))
		if(state != 2)
			return
		var/obj/item/card/id/ID = I
		var/datum/bank_account/account = ID.registered_account
		var/target_credits = total_price - credits
		if(!account.adjust_money(-target_credits, "Vending: Laptop Vendor"))
			say("Insufficient credits on card to purchase!")
			return
		credits += target_credits
		say("[target_credits] cr have been withdrawn from your account.")
		return
	return ..()

// Simplified payment processing, returns 1 on success.
/obj/machinery/lapvend/proc/process_payment()
	if(total_price > credits)
		say("Insufficient credits.")
		return FALSE
	else
		return TRUE

/obj/machinery/lapvend/ui_data(mob/user)

	var/list/data = list()
	data["state"] = state
	if(state == 1)
		data["devtype"] = devtype
		data["hw_battery"] = dev_battery
		data["hw_card"] = dev_card
	if(state == 1 || state == 2)
		data["totalprice"] = total_price
		data["credits"] = credits

	return data


/obj/machinery/lapvend/proc/try_purchase()
	// Awaiting payment state
	if(state == 2)
		if(process_payment())
			fabricate_and_recalc_price(1)
			if((devtype == 1) && fabricated_laptop)
				fabricated_laptop.forceMove(src.loc)
				fabricated_laptop = null
			else if((devtype == 2) && fabricated_tablet)
				fabricated_tablet.forceMove(src.loc)
				fabricated_tablet = null
			credits -= total_price
			say("Enjoy your new product!")
			state = 3
			addtimer(CALLBACK(src, .proc/reset_order), 100)
			return TRUE
		return FALSE
