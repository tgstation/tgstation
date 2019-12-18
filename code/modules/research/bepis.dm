//This system is designed to act as an in-between for cargo and science, and the first major money sink in the game outside of just buying things from cargo (As of 10/9/19, anyway).

//economics defined values, subject to change should anything be too high or low in practice.


/obj/machinery/rnd/bepis
	name = "\improper B.E.P.I.S. Chamber"
	desc = "A high fidelity testing device which unlocks the secrets of the known universe using the two most powerful substances available to man: excessive amounts of electricity and capital."
	icon = 'icons/obj/machines/bepis.dmi'
	icon_state = "chamber"
	layer = ABOVE_MOB_LAYER
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 1500
	circuit = /obj/item/circuitboard/machine/bepis

	var/banking_amount = 100
	var/banked_cash = 0					//stored player cash
	var/datum/bank_account/account		//payer's account.
	var/obj/item/card/id/Card   		//the account of the person using the console.
	var/chamber_status = 0
	var/error_cause = null
	var/powered = FALSE
	//Vars related to probability and chance of success for testing
	var/major_threshold = 6000
	var/minor_threshold = 3000
	var/std = 1000 //That's Standard Deviation, what did you think it was?
	//Stock part variables
	var/power_saver = 1
	var/inaccuracy_percentage = 1.5
	var/positive_cash_offset = 0
	var/negative_cash_offset = 0

/obj/machinery/rnd/bepis/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, "chamber_open", "chamber", O))
		update_icon_state()
		return
	else if(default_deconstruction_crowbar(O))
		return
	if(!is_operational())
		to_chat(user, "<span class='notice'>[src] can't accept money when it's not functioning.</span>")
		return
	if(istype(O, /obj/item/holochip) || istype(O, /obj/item/stack/spacecash))
		var/deposit_value = O.get_item_credit_value()
		banked_cash += deposit_value
		if (banked_cash >= 1)
			chamber_status = 2
		qdel(O)
		say("Deposited [deposit_value] credits into storage.")
		update_icon_state()
		return
	return ..()

/obj/machinery/rnd/bepis/RefreshParts()
	var/C = 0
	var/M = 0
	var/L = 0
	var/S = 0
	for(var/obj/item/stock_parts/capacitor/Cap in component_parts)
		C += ((Cap.rating - 1) * 0.1)
	power_saver = 1 - C
	for(var/obj/item/stock_parts/manipulator/Manip in component_parts)
		M += ((Manip.rating - 1) * 250)
	positive_cash_offset = M
	for(var/obj/item/stock_parts/micro_laser/Laser in component_parts)
		L += ((Laser.rating - 1) * 250)
	negative_cash_offset = L
	for(var/obj/item/stock_parts/scanning_module/Scan in component_parts)
		S += ((Scan.rating - 1) * 0.25)
	inaccuracy_percentage = (1.5 - S)

/obj/machinery/rnd/bepis/proc/depositcash()
	var/deposit_value = 0
	if(!Card)
		say("No account detected.")  //No freeloading off of science.
		return
	else if(Card.registered_account)
		account = Card.registered_account

	deposit_value = banking_amount
	if(deposit_value == 0)
		chamber_status = 1
		update_icon_state()
		say("Attempting to deposit 0 credits. Aborting.")
		return
	deposit_value = CLAMP(round(deposit_value, 1), 1, 30000)

	if(!account.has_money(deposit_value))
		say("You do not possess enough credits.")
		return
	else
		account.adjust_money(-deposit_value) //The money vanishes, not paid to any accounts.
		banked_cash += deposit_value
		use_power(1000 * power_saver)
		say("Cash deposit successful. There is [banked_cash] in the chamber.")

	if(banked_cash >= 1)
		chamber_status = 2
	else
		chamber_status = 1
	update_icon_state()
	return

/obj/machinery/rnd/bepis/proc/calcsuccess()
	var/turf/dropturf = get_turf(pick(view(1,src)))
	var/gauss_major = 0
	var/gauss_minor = 0
	var/gauss_real = 0
	if(!dropturf) //Check to verify the turf exists and the reward isn't lost somehow.
		dropturf = drop_location()
	gauss_major = (gaussian(major_threshold, std) - negative_cash_offset)	//This is the randomized profit value that this experiment has to surpass to unlock a tech.
	gauss_minor = (gaussian(minor_threshold, std) - negative_cash_offset)	//And this is the threshold to instead get a minor prize.
	gauss_real = (gaussian(banked_cash, std*inaccuracy_percentage) + positive_cash_offset)	//this is the randomized profit value that your experiment expects to give.
	say("Real: [gauss_real]. Minor: [gauss_minor]. Major: [gauss_major].")
	if(gauss_real >= gauss_major) //Major Success.
		say("Experiment concluded with major success. New technology node discovered on technology disc.")
		banked_cash = 0
		new /obj/item/disk/tech_disk/major(dropturf,1)
		flick("chamber_flash",src)
		update_icon_state()
		return
	else if(gauss_real >= gauss_minor) //Minor Success.
		var/reward_number = 1
		say("Experiment concluded with partial success. Dispensing compiled research efforts.")
		reward_number = rand(1,2)
		if(reward_number == 1)
			new /obj/item/stack/circuit_stack/full(dropturf)
		if(reward_number == 2)
			new /obj/item/airlock_painter/decal(dropturf)
		banked_cash = 0
		flick("chamber_flash",src)
		update_icon_state()
		return
	else if(gauss_real <= -1)	//Critical Failure
		say("ERROR: CRITICAL MACHIME MALFUNCTI- ON. CURRENCY IS NOT CRASH. CANNOT COMPUTE COMMAND: 'make bucks'") //not a typo, for once.
		banked_cash = 0
		new /mob/living/simple_animal/deer(dropturf, 1)
		use_power(500000 * power_saver) //To prevent gambling at low cost and also prevent spamming for infinite deer.
		flick("chamber_flash",src)
		update_icon_state()
		return
	else	//Minor Failure
		error_cause = pick("attempted to sell grey products to American dominated market.","attempted to sell gray products to British dominated market.","placed wild assumption that PDAs would go out of style.","simulated product #76 damaged brand reputation mortally.","simulated business model resembled 'pyramid scheme' by 98.7%.","product accidently granted override access to all station doors.")
		say("Experiment concluded with zero product viability. Cause of error: [error_cause]")
		banked_cash = 0
		flick("chamber_flash",src)
		update_icon_state()
	return

/obj/machinery/rnd/bepis/update_icon_state()
	if(is_operational() && (chamber_status < 2))
		chamber_status = 1
	if(((powered == FALSE) && (banked_cash == 0)) || (!is_operational()))
		chamber_status = 0
	if((powered == TRUE) && (banked_cash > 0) && (is_operational()))
		chamber_status = 2
	if (((powered == FALSE) && (banked_cash > 0)) || (banked_cash > 0) && (!is_operational()))
		chamber_status = 3
	if(panel_open == TRUE)
		chamber_status = 4
	switch(chamber_status)
		if(0)
			icon_state = "chamber"
		if(1)
			icon_state = "chamber_active"
		if(2)
			icon_state = "chamber_active_loaded"
		if(3)
			icon_state = "chamber_loaded"
		if(4)
			icon_state = "chamber_open"

/obj/machinery/rnd/bepis/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	var/mob/living/carbon/human/H   	//the person using the console in each instance.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "bepis", name, 500, 400, master_ui, state)
		ui.open()
	if(ishuman(user))
		H = user
		Card = H.get_idcard(TRUE)
	RefreshParts()

/obj/machinery/rnd/bepis/ui_data()
	var/list/data = list()

	data["amount"] = banking_amount
	data["stored_cash"] = banked_cash
	data["mean_value"] = major_threshold
	data["error_name"] = error_cause
	data["power_saver"] = power_saver
	data["accuracy_percentage"] = inaccuracy_percentage * 100
	data["positive_cash_offset"] = positive_cash_offset
	data["negative_cash_offset"] = negative_cash_offset
	data["manual_power"] = powered ? FALSE : TRUE
	return data

/obj/machinery/rnd/bepis/ui_act(action,params)
	if(..())
		return
	switch(action)
		if("deposit_cash")
			if(powered == FALSE)
				return
			depositcash()
			update_icon_state()
		if("begin_experiment")
			if(powered == FALSE)
				return
			if(banked_cash == 0)
				say("Please deposit funds to begin testing.")
				return
			calcsuccess()
			use_power(10000 * power_saver) //This thing should eat your APC battery if you're not careful.
		if("amount")
			var/input = text2num(params["amount"])
			if(input)
				banking_amount = input
		if("toggle_power")
			if(powered == FALSE)
				powered = TRUE
				idle_power_usage = 1500
			else
				powered = FALSE
				idle_power_usage = 0
			update_icon_state()
	. = TRUE
