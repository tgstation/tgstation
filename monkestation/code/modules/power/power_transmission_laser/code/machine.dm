#define MINIMUM_POWER 1 MW
/obj/machinery/power/transmission_laser
	name = "power transmission laser"
	desc = "Sends power over a giant laser beam to an NT power processing facility."

	icon = 'goon/icons/obj/pt_laser.dmi'
	icon_state = "ptl"

	max_integrity = 10000

	density = TRUE
	anchored = TRUE

	///3x3 tiles
	bound_width = 96
	bound_height = 96

	///variables go below here
	///the terminal this is connected to
	var/obj/machinery/power/terminal/terminal = null
	///the range we have this basically determines how far the beam goes its redone on creation so its set to a small number here
	var/range = 5
	///amount of power we are outputting
	var/output_level = 0
	///the total capacity of the laser
	var/capacity = INFINITY
	///our current charge
	var/charge = 0
	///should we try to input charge paired with the var below to check if its fully inputing
	var/input_attempt = TRUE
	///are we currently inputting
	var/inputting = TRUE
	///the amount of charge coming in from the inputs last tick
	var/input_available = 0
	///have we been switched on?
	var/turned_on = FALSE
	///are we attempting to fire the laser currently?
	var/firing = FALSE
	///we need to create a list of all lasers we are creating so we can delete them in the end
	var/list/laser_effects = list()
	///list of all blocking turfs or objects
	var/list/blocked_objects = list()
	///our max load we can set
	var/max_grid_load = 0
	///our current grid load
	var/current_grid_load = 0
	///out power formatting multiplier used inside tgui to convert to things like mW gW to watts for ease of setting
	var/power_format_multi = 1
	///same as above but for output
	var/power_format_multi_output = 1

	/// Are we selling the power or just sending it into the ether
	var/selling_power = FALSE

	/// How much power have we sold in total
	var/total_power = 0
	/// How much power do you have to sell in order to get an announcement
	var/announcement_treshold = 1 MW

	/// How much credits we have earned in total
	var/total_earnings = 0
	/// The amount of money we haven't sent to cargo yet
	var/unsent_earnings = 0

	///how much we are inputing pre multiplier
	var/input_number = 0
	///how much we are outputting pre multiplier
	var/output_number = 0
	///our set input pulling
	var/input_pulling = 0

/obj/machinery/power/transmission_laser/Initialize(mapload)
	. = ..()

	range = get_dist(get_step(get_front_turf(), dir), get_edge_target_turf(get_front_turf(), dir))
	var/turf/back_turf = get_step(get_back_turf(), turn(dir, 180))
	terminal = locate(/obj/machinery/power/terminal) in back_turf

	if(!terminal)
		machine_stat |= BROKEN
		return
	terminal.master = src
	update_appearance()

/obj/machinery/power/transmission_laser/Destroy()
	. = ..()
	if(length(laser_effects))
		destroy_lasers()
	blocked_objects = null

/obj/machinery/power/transmission_laser/proc/get_back_turf()
	//this is weird as i believe byond sets the bottom left corner as the source corner like
	// x-x-x
	// x-x-x
	// o-x-x
	//which would mean finding the true back turf would require centering than taking a step in the inverse direction
	var/turf/center = locate(x + 1, y + 1, z)
	if(!center)///what
		return
	var/inverse_direction = turn(dir, 180)
	return get_step(center, inverse_direction)

/obj/machinery/power/transmission_laser/proc/get_front_turf()
	//this is weird as i believe byond sets the bottom left corner as the source corner like
	// x-x-x
	// x-x-x
	// o-x-x
	//which would mean finding the true front turf would require centering than taking a step in the primary direction
	var/turf/center = locate(x + 1, y + 1, z)
	if(!center)///what
		return
	return get_step(center, dir)

/obj/machinery/power/transmission_laser/examine(mob/user)
	. = ..()
	. += span_notice("Laser currently has [unsent_earnings] unsent credits.")
	. += span_notice("Laser has generated [total_earnings] credits.")
	. += span_notice("Laser has sold [total_power] Watts")
///appearance changes are here

/obj/machinery/power/transmission_laser/update_overlays()
	. = ..()
	if((machine_stat & BROKEN) || !charge)
		. += "unpowered"
		return
	if(input_available > 0)
		. += "green_light"
		. += emissive_appearance(icon, "green_light", src)
	if(turned_on)
		. += "red_light"
		. += emissive_appearance(icon, "red_light", src)
		if(firing)
			. +="firing"
			. += emissive_appearance(icon, "firing", src)

	var/charge_level = return_charge()
	if(charge_level == 6)
		. += "charge_full"
		. += emissive_appearance(icon, "charge_full", src)
	else if(charge_level > 0)
		. += "charge_[charge_level]"
		. += emissive_appearance(icon, "charge_[charge_level]", src)

///returns the charge level from [0 to 6]
/obj/machinery/power/transmission_laser/proc/return_charge()
	if(!output_level)
		return 0
	return min(round((charge / abs(output_level)) * 6), 6)


/obj/machinery/power/transmission_laser/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TransmissionLaser")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/power/transmission_laser/ui_data(mob/user)
	. = ..()
	var/list/data = list()

	data["output"] = output_level
	data["total_earnings"] = total_earnings
	data["unsent_earnings"] = unsent_earnings
	data["held_power"] = charge
	data["selling_power"] = selling_power
	data["max_capacity"] = capacity
	data["max_grid_load"] = max_grid_load

	data["accepting_power"] = turned_on
	data["sucking_power"] = inputting
	data["firing"] = firing

	data["power_format"] = power_format_multi
	data["input_number"] = input_number
	data["avalible_input"] = input_available
	data["output_number"] = output_number
	data["output_multiplier"] = power_format_multi_output
	data["input_total"] = input_number * power_format_multi
	data["output_total"] = output_number * power_format_multi_output

	return data

/obj/machinery/power/transmission_laser/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("toggle_input")
			turned_on = !turned_on
			update_appearance()
		if("toggle_output")
			firing = !firing
			update_appearance()

		if("set_input")
			input_number = clamp(params["set_input"], 0, 999) //multiplies our input by if input
		if("set_output")
			output_number = clamp(params["set_output"], 0, 999)

		if("inputW")
			power_format_multi = 1
		if("inputKW")
			power_format_multi = 1 KW
		if("inputMW")
			power_format_multi = 1 MW
		if("inputGW")
			power_format_multi = 1 GW
		if("inputTW")
			power_format_multi = 1 TW
		if("inputPW")
			power_format_multi = 1 PW

		if("outputW")
			power_format_multi_output = 1
		if("outputKW")
			power_format_multi_output = 1 KW
		if("outputMW")
			power_format_multi_output = 1 MW
		if("outputGW")
			power_format_multi_output = 1 GW
		if("outputTW")
			power_format_multi_output = 1 TW
		if("outputPW")
			power_format_multi_output = 1 PW


/obj/machinery/power/transmission_laser/process()
	max_grid_load = terminal.surplus()
	input_available = terminal.surplus()
	if((machine_stat & BROKEN) || !turned_on)
		return

	if(total_power >= announcement_treshold)
		send_ptl_announcement()

	var/last_disp = return_charge()
	var/last_chrg = inputting
	var/last_fire = firing

	if(last_disp != return_charge() || last_chrg != inputting || last_fire != firing)
		update_appearance()

	if(terminal && input_attempt)
		input_pulling = min(input_available , input_number * power_format_multi)

		if(inputting)
			if(input_pulling > 0)
				terminal.add_load(input_pulling)
				charge += input_pulling
			else
				inputting = FALSE
		else
			if(input_attempt && input_pulling > 0)
				inputting = TRUE
	else
		inputting = FALSE

	if(charge < MINIMUM_POWER)
		firing = FALSE
		output_level = 0
		destroy_lasers()
		return

	if(!firing)
		return

	output_level = min(charge, output_number * power_format_multi_output)
	if(!length(laser_effects))
		setup_lasers()

	if(length(blocked_objects))
		var/atom/listed_atom = blocked_objects[1]
		if(prob(max((abs(output_level) * 0.1) / 500 KW, 1))) ///increased by a single % per 500 KW
			listed_atom.visible_message(span_danger("[listed_atom] is melted away by the [src]!"))
			blocked_objects -= listed_atom
			qdel(listed_atom)

	else
		sell_power(output_level)

	charge -= output_level

////selling defines are here
#define MINIMUM_BAR 25
#define PROCESS_CAP 5000 - MINIMUM_BAR

#define A1_CURVE 70

/obj/machinery/power/transmission_laser/proc/sell_power(power_amount)
	var/mw_power = power_amount / (1 MW)

	var/generated_cash = (2 * mw_power * PROCESS_CAP) / (2 * mw_power + PROCESS_CAP * A1_CURVE)
	generated_cash += (4 * mw_power * MINIMUM_BAR) / (4 * mw_power + MINIMUM_BAR)
	generated_cash = round(generated_cash)
	if(generated_cash < 0)
		return

	total_power += power_amount
	total_earnings += generated_cash
	generated_cash += unsent_earnings
	unsent_earnings = generated_cash

	var/datum/bank_account/department/engineering_bank_account = SSeconomy.get_dep_account(ACCOUNT_ENG)
	var/datum/bank_account/department/cargo_bank_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/datum/bank_account/department/security_bank_account = SSeconomy.get_dep_account(ACCOUNT_SEC)

	var/medium_cut = generated_cash * 0.25
	var/high_cut = generated_cash * 0.50

	///the other 25% will be sent to engineers in the future but for now its stored inside
	security_bank_account.adjust_money(medium_cut, "Transmission Laser Payout")
	unsent_earnings -= medium_cut

	cargo_bank_account.adjust_money(medium_cut, "Transmission Laser Payout")
	unsent_earnings -= medium_cut

	engineering_bank_account.adjust_money(high_cut, "Transmission Laser Payout")
	unsent_earnings -= high_cut

#undef A1_CURVE
#undef PROCESS_CAP
#undef MINIMUM_BAR

// Beam related procs

/obj/machinery/power/transmission_laser/proc/setup_lasers()
	///this is why we set the range we did
	var/turf/last_step = get_step(get_front_turf(), dir)
	for(var/num = 1 to range + 1)
		var/obj/effect/transmission_beam/new_beam = new(last_step)
		new_beam.host = src
		new_beam.dir = dir
		laser_effects += new_beam

		last_step = get_step(last_step, dir)

/obj/machinery/power/transmission_laser/proc/destroy_lasers()
	if(firing) // this is incase we turn the laser back on manually
		return
	for(var/obj/effect/transmission_beam/listed_beam as anything in laser_effects)
		laser_effects -= listed_beam
		qdel(listed_beam)

///this is called every time something enters our beams
/obj/machinery/power/transmission_laser/proc/atom_entered_beam(obj/effect/transmission_beam/triggered, atom/movable/potential_victim)
	var/mw_power = (output_number * power_format_multi_output) / (1 MW)
	if(!isliving(potential_victim))
		return
	var/mob/living/victim = potential_victim
	switch(mw_power)
		if(0 to 25)
			victim.adjustFireLoss(-mw_power * 15)
			return
		if(26 to 50)
			victim.gib(FALSE)
		else
			explosion(victim, 3, 2, 2)
			victim.gib(FALSE)
