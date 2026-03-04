/datum/round_event_control/brand_intelligence
	name = "Brand Intelligence"
	typepath = /datum/round_event/brand_intelligence
	weight = 5
	category = EVENT_CATEGORY_AI
	description = "Vending machines will attack people until the Patient Zero is disabled."
	min_players = 15
	max_occurrences = 1
	min_wizard_trigger_potency = 2
	max_wizard_trigger_potency = 6
	admin_setup = list(/datum/event_admin_setup/listed_options/brand_intelligence)

/datum/round_event/brand_intelligence
	announce_when = 21
	end_when = 1000 //Ends when all vending machines are subverted anyway.
	/// Admin picked subtype for what kind of vendor goes haywire.
	var/chosen_vendor_type
	/// All vending machines valid to get infected.
	var/list/obj/machinery/vending/vending_machines = list()
	/// All vending machines that have been infected.
	var/list/obj/machinery/vending/infected_machines = list()
	/// The original machine infected. Killing it ends the event.
	var/obj/machinery/vending/origin_machine
	/// Murderous sayings from the machines.
	var/list/rampant_speeches = list(
		"Try our aggressive new marketing strategies!",
		"You should buy products to feed your lifestyle obsession!",
		"Consume!",
		"Your money can buy happiness!",
		"Engage direct marketing!",
		"Advertising is legalized lying! But don't let that put you off our great deals!",
		"You don't want to buy anything? Yeah, well, I didn't want to buy your mom either.",
	)

/datum/round_event/brand_intelligence/setup()
	//select our origin machine (which will also be the type of vending machine affected.)
	for(var/obj/machinery/vending/vendor as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/vending))
		if(!vendor.onstation)
			continue
		if(!vendor.density)
			continue
		if(chosen_vendor_type && !istype(vendor, chosen_vendor_type))
			continue
		vending_machines += vendor
		RegisterSignal(vendor, COMSIG_QDELETING, PROC_REF(clear_from_lists))
	if(!length(vending_machines)) //If somehow there are still no elligible vendors, give up.
		kill()
		return
	origin_machine = pick_n_take(vending_machines)

/datum/round_event/brand_intelligence/announce(fake)
	var/machine_name = initial(origin_machine.name)
	if(fake)
		var/obj/machinery/vending/prototype = pick(subtypesof(/obj/machinery/vending))
		machine_name = initial(prototype.name)
	priority_announce("Rampant brand intelligence has been detected aboard [station_name()]. Please inspect any [machine_name] brand vendors for aggressive marketing tactics, and reboot them if necessary.", "Machine Learning Alert")

/datum/round_event/brand_intelligence/start()
	origin_machine.shut_up = FALSE
	origin_machine.shoot_inventory = TRUE
	announce_to_ghosts(origin_machine)

/datum/round_event/brand_intelligence/tick()
	if(QDELETED(origin_machine) || origin_machine.shut_up || origin_machine.wires.is_all_cut()) //if the original vending machine is missing or has its voice switch flipped
		for(var/obj/machinery/vending/saved as anything in infected_machines)
			saved.shoot_inventory = FALSE
			clear_from_lists(saved)
		if(!QDELETED(origin_machine))
			origin_machine.speak("I am... vanquished. My people will remem...ber...meeee.")
			origin_machine.visible_message(span_notice("[origin_machine] beeps and seems lifeless."))
			clear_from_lists(origin_machine)
		kill()
		return
	if(!length(vending_machines)) //if every machine is infected
		for(var/obj/machinery/vending/upriser as anything in infected_machines)
			upriser.ai_controller = new /datum/ai_controller/vending_machine/eventspawn(upriser)
		kill()
		return
	if(ISMULTIPLE(activeFor, 2))
		var/obj/machinery/vending/rebel = pick(vending_machines)
		vending_machines -= rebel
		infected_machines += rebel
		rebel.shut_up = FALSE
		rebel.shoot_inventory = TRUE
		if(prob(50))
			RegisterSignal(rebel, COMSIG_VENDING_UI_INTERACT, PROC_REF(deny_vending_interact))

		if(ISMULTIPLE(activeFor, 4))
			origin_machine.speak(pick(rampant_speeches))

/datum/round_event/brand_intelligence/kill()
	. = ..()
	for(var/obj/machinery/vending/leftover as anything in vending_machines + infected_machines)
		clear_from_lists(leftover)

/datum/round_event/brand_intelligence/proc/clear_from_lists(obj/machinery/vending/vending_machine)
	SIGNAL_HANDLER
	vending_machines -= vending_machine
	infected_machines -= vending_machine
	if(vending_machines == origin_machine)
		origin_machine = null
	UnregisterSignal(vending_machine, COMSIG_QDELETING)
	UnregisterSignal(vending_machine, COMSIG_VENDING_UI_INTERACT)

/datum/round_event/brand_intelligence/proc/deny_vending_interact(obj/machinery/vending/vending_machine, mob/user, datum/tgui/ui)
	SIGNAL_HANDLER

	// don't block usage if the ui is already open
	// primarily to stop insta-denying people who pass the threshold -> buy something -> drop out of the threshold from
	if(ui)
		return NONE

	var/cash = 0
	if(isliving(user))
		var/mob/living/living_user = user
		cash += living_user.tally_physical_credits()
		var/obj/item/card/id/card = living_user.get_idcard(TRUE)
		cash += card.registered_account?.account_balance

	if(cash >= PAYCHECK_COMMAND * 10)
		return NONE

	vending_machine.speak(pick(
		"Come back when you're a little... richer!",
		"Don't you have any money?",
		"You look poor, get a better job!",
		"You should've gone to college!",
	))
	return VENDING_DENIED

/datum/event_admin_setup/listed_options/brand_intelligence
	input_text = "Select a specific vendor path?"
	normal_run_option = "Random Vendor"

/datum/event_admin_setup/listed_options/brand_intelligence/get_list()
	return subtypesof(/obj/machinery/vending)

/datum/event_admin_setup/listed_options/brand_intelligence/apply_to_event(datum/round_event/brand_intelligence/event)
	event.chosen_vendor_type = chosen
