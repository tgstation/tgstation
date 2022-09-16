/datum/round_event_control/brand_intelligence
	name = "Brand Intelligence"
	typepath = /datum/round_event/brand_intelligence
	weight = 5
	category = EVENT_CATEGORY_AI
	description = "Vending machines will attack people until the Patient Zero is disabled."

	min_players = 15
	max_occurrences = 1

	var/chosen_vendor

/datum/round_event_control/brand_intelligence/admin_setup()
	if(!check_rights(R_FUN))
		return
	if(tgui_alert(usr, "Select a vendor type?", "Capitalism-ho!", list("Yes", "No")) == "Yes")
		var/list/vendors = list()
		vendors += subtypesof(/obj/machinery/vending)
		chosen_vendor = tgui_input_list(usr, "Pick Me!","Vendor Selector", vendors)

/datum/round_event/brand_intelligence
	announce_when = 1 //TIME FOR TESTING PURPOSES PLEASE REVERT TO 21
	end_when = 1000 //Ends when all vending machines are subverted anyway.
	var/list/obj/machinery/vending/vendingMachines = list()
	var/list/obj/machinery/vending/infectedMachines = list()
	var/obj/machinery/vending/originMachine
	var/list/rampant_speeches = list(
		"Try our aggressive new marketing strategies!",
		"You should buy products to feed your lifestyle obsession!",
		"Consume!",
		"Your money can buy happiness!",
		"Engage direct marketing!",
		"Advertising is legalized lying! But don't let that put you off our great deals!",
		"You don't want to buy anything? Yeah, well, I didn't want to buy your mom either.",
	)


/datum/round_event/brand_intelligence/announce(fake)
	var/source = "unknown machine"
	if(fake)
		var/obj/machinery/vending/example = pick(subtypesof(/obj/machinery/vending))
		source = initial(example.name)
	else if(originMachine)
		source = originMachine.name
	priority_announce("Rampant brand intelligence has been detected aboard [station_name()]. Please inspect any [source] vendors for aggressive marketing tactics, and reboot them if necessary.", "Machine Learning Alert")

/datum/round_event/brand_intelligence/start()
	var/datum/round_event_control/brand_intelligence/brand_event = control
	if(brand_event.chosen_vendor)
		var/chosen_vendor = brand_event.chosen_vendor
		for(var/obj/machinery/vending/vendor in GLOB.machines)
			if(!is_station_level(vendor.z) || !istype(vendor, chosen_vendor))
				continue
			vendingMachines.Add(vendor)
	else
		for(var/obj/machinery/vending/vendor in GLOB.machines)
			if(!is_station_level(vendor.z))
				continue
			vendingMachines.Add(vendor)
	if(!vendingMachines.len)
		kill()
		priority_announce("AINT GOT NOTHING CHIEF")
		return
	originMachine = pick(vendingMachines)
	vendingMachines.Remove(originMachine)
	originMachine.shut_up = 0
	originMachine.shoot_inventory = 1
	announce_to_ghosts(originMachine)

/datum/round_event/brand_intelligence/tick()
	if(!originMachine || QDELETED(originMachine) || originMachine.shut_up || originMachine.wires.is_all_cut()) //if the original vending machine is missing or has it's voice switch flipped
		for(var/obj/machinery/vending/saved in infectedMachines)
			saved.shoot_inventory = 0
		if(originMachine)
			originMachine.speak("I am... vanquished. My people will remem...ber...meeee.")
			originMachine.visible_message(span_notice("[originMachine] beeps and seems lifeless."))
		kill()
		return
	vendingMachines = remove_nulls_from_list(vendingMachines)
	if(!vendingMachines.len) //if every machine is infected
		for(var/obj/machinery/vending/upriser in infectedMachines)
			if(!QDELETED(upriser))
				upriser.ai_controller = new /datum/ai_controller/vending_machine(upriser)
				infectedMachines.Remove(upriser)
		kill()
		return
	if(ISMULTIPLE(activeFor, 2))
		var/obj/machinery/vending/rebel = pick(vendingMachines)
		vendingMachines.Remove(rebel)
		infectedMachines.Add(rebel)
		rebel.shut_up = 0
		rebel.shoot_inventory = 1

		if(ISMULTIPLE(activeFor, 4))
			originMachine.speak(pick(rampant_speeches))
