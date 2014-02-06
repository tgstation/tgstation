// the SMES
// stores power

#define SMES_MAX_INPUT_LEVEL 200000
#define SMES_MAX_OUTPUT_LEVEL 200000

/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = 1
	anchored = 1
	use_power = 0
	var/capacity = 5e6 // maximum charge
	var/charge = 1e6 //actual charge

	var/input_attempt = 0 // 1 = attempting to charge, 0 = not attempting to charge
	var/inputting = 0 // 1 = actually inputting, 0 = not inputting
	var/input_level = 50000 // amount of power the SMES attempts to charge by
	var/input_available = 0 //amount of charge available from input last tick

	var/output_attempt = 1 //1 = attempting to output, 0 = not attempting to output
	var/outputting = 1 //1 = actually outputting, 0 = not outputting
	var/output_level = 50000 // amount of power the SMES attempts to output
	var/output_used = 0 // amount of power actually outputted. may be less than output_level if the powernet returns excess power

	var/obj/machinery/power/terminal/terminal = null


/obj/machinery/power/smes/New()
	..()
	spawn(5)
		dir_loop:
			for(var/d in cardinal)
				var/turf/T = get_step(src, d)
				for(var/obj/machinery/power/terminal/term in T)
					if(term && term.dir == turn(d, 180))
						terminal = term
						break dir_loop
		if(!terminal)
			stat |= BROKEN
			return
		terminal.master = src
		updateicon()
	return

/obj/machinery/power/smes/Del()
	message_admins("SMES deleted at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
	log_game("SMES deleted at ([x],[y],[z])")
	investigate_log("<font color='red'>deleted</font> at ([x],[y],[z])","singulo")
	..()

/obj/machinery/power/smes/proc/updateicon()
	overlays.Cut()
	if(stat & BROKEN)	return

	overlays += image('icons/obj/power.dmi', "smes-op[outputting]")

	if(inputting)
		overlays += image('icons/obj/power.dmi', "smes-oc1")
	else
		if(input_attempt)
			overlays += image('icons/obj/power.dmi', "smes-oc0")

	var/clevel = chargedisplay()
	if(clevel>0)
		overlays += image('icons/obj/power.dmi', "smes-og[clevel]")
	return


/obj/machinery/power/smes/proc/chargedisplay()
	return round(5.5*charge/capacity)

#define SMESRATE 0.05			// rate of internal charge to external power


/obj/machinery/power/smes/process()

	if(stat & BROKEN)	return

	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_chrg = inputting
	var/last_onln = outputting

	if(terminal && input_attempt)
		input_available = terminal.surplus()

		if(inputting)
			if(input_available > 0 && input_available >= input_level)		// if there's power available, try to charge

				var/load = min((capacity-charge)/SMESRATE, input_level)		// charge at set rate, limited to spare capacity

				charge += load * SMESRATE	// increase the charge

				add_load(load)		// add the load to the terminal side network

			else					// if not enough capcity
				inputting = 0		// stop inputting

		else
			if(input_available > 0 && input_available >= input_level)
				inputting = 1


	if(outputting)
		output_used = min( charge/SMESRATE, output_level)		//limit output to that stored

		charge -= output_used*SMESRATE		// reduce the storage (may be recovered in /restore() if excessive)

		add_avail(output_used)				// add output to powernet (smes side)

		if(charge < 0.0001)
			outputting = 0
			output_attempt = 0
			investigate_log("lost power and turned <font color='red'>off</font>","singulo")
	else if(output_attempt && charge > 0)
		outputting = 1

	// only update icon if state changed
	if(last_disp != chargedisplay() || last_chrg != inputting || last_onln != outputting)
		updateicon()



// called after all power processes are finished
// restores charge level to smes if there was excess this ptick

/obj/machinery/power/smes/proc/restore()
	if(stat & BROKEN)
		return

	if(!outputting)
		output_used = 0
		return

	var/excess = powernet.netexcess		// this was how much wasn't used on the network last ptick, minus any removed by other SMESes

	excess = min(output_used, excess)				// clamp it to how much was actually output by this SMES last ptick

	excess = min((capacity-charge)/SMESRATE, excess)	// for safety, also limit recharge by space capacity of SMES (shouldn't happen)

	// now recharge this amount

	var/clev = chargedisplay()

	charge += excess * SMESRATE
	powernet.netexcess -= excess		// remove the excess from the powernet, so later SMESes don't try to use it

	output_used -= excess

	if(clev != chargedisplay() )
		updateicon()
	return


/obj/machinery/power/smes/add_load(var/amount)
	if(terminal && terminal.powernet)
		terminal.powernet.newload += amount


/obj/machinery/power/smes/attack_ai(mob/user)
	if(stat & BROKEN) return
	ui_interact(user)


/obj/machinery/power/smes/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & BROKEN) return
	ui_interact(user)


/obj/machinery/power/smes/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(!user)
		return

	var/list/data = list(
		"capacityPercent" = round(100.0*charge/capacity, 0.1),
		"capacity" = capacity,
		"charge" = charge,

		"inputAttempt" = input_attempt,
		"inputting" = inputting,
		"inputLevel" = input_level,
		"inputAvailable" = input_available,

		"outputAttempt" = output_attempt,
		"outputting" = outputting,
		"outputLevel" = output_level,
		"outputUsed" = output_used
	)

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "smes.tmpl", "SMES - [name]", 540, 360)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/power/smes/Topic(href, href_list)
	if(..())
		return

//world << "[href] ; [href_list[href]]"

	else if( href_list["input_attempt"] )
		input_attempt = text2num(href_list["input_attempt"])
		if(!input_attempt)
			inputting = 0
		investigate_log("input/output; [input_level>output_level?"<font color='green'>":"<font color='red'>"][input_level]/[output_level]</font> | Output-mode: [outputting?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [input_attempt?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [usr.key]","singulo")
		updateicon()

	else if( href_list["output_attempt"] )
		output_attempt = text2num(href_list["output_attempt"])
		if(!output_attempt)
			outputting = 0
		investigate_log("input/output; [input_level>output_level?"<font color='green'>":"<font color='red'>"][input_level]/[output_level]</font> | Output-mode: [outputting?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [input_attempt?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [usr.key]","singulo")
		updateicon()

	else if( href_list["set_input_level"] )
		switch(href_list["set_input_level"])
			if("max")
				input_level = SMES_MAX_INPUT_LEVEL
			if("custom")
				var/custom = input(usr, "What rate would you like this SMES to attempt to charge at? Max is [SMES_MAX_INPUT_LEVEL].") as null|num
				if(isnum(custom))
					input_level = custom
			else
				var/n = text2num(href_list["set_input_level"])
				if(isnum(n))
					input_level = n

		input_level = Clamp(input_level, 0, SMES_MAX_INPUT_LEVEL)
		investigate_log("input/output; [input_level>output_level?"<font color='green'>":"<font color='red'>"][input_level]/[output_level]</font> | Output-mode: [outputting?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [input_attempt?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [usr.key]","singulo")

	else if(href_list["set_output_level"])
		switch(href_list["set_output_level"])
			if("max")
				output_level = SMES_MAX_OUTPUT_LEVEL
			if("custom")
				var/custom = input(usr, "What rate would you like this SMES to attempt to output at? Max is [SMES_MAX_OUTPUT_LEVEL].") as null|num
				if(isnum(custom))
					output_level = custom
			else
				var/n = text2num(href_list["set_output_level"])
				if(isnum(n))
					output_level = n

		output_level = Clamp(output_level, 0, SMES_MAX_OUTPUT_LEVEL)
		investigate_log("input/output; [input_level>output_level?"<font color='green'>":"<font color='red'>"][input_level]/[output_level]</font> | Output-mode: [outputting?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [input_attempt?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [usr.key]","singulo")

	add_fingerprint(usr)

/*
/obj/machinery/power/smes/proc/ion_act()
	if(src.z == 1)
		if(prob(1)) //explosion
			world << "\red SMES explosion in [src.loc.loc]"
			for(var/mob/M in viewers(src))
				M.show_message("\red The [src.name] is making strange noises!", 3, "\red You hear sizzling electronics.", 2)
			sleep(10*pick(4,5,6,7,10,14))
			var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
			smoke.set_up(3, 0, src.loc)
			smoke.attach(src)
			smoke.start()
			explosion(src.loc, -1, 0, 1, 3, 0)
			del(src)
			return
		if(prob(15)) //Power drain
			world << "\red SMES power drain in [src.loc.loc]"
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			if(prob(50))
				emp_act(1)
			else
				emp_act(2)
		if(prob(5)) //smoke only
			world << "\red SMES smoke in [src.loc.loc]"
			var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
			smoke.set_up(3, 0, src.loc)
			smoke.attach(src)
			smoke.start()
*/


/obj/machinery/power/smes/emp_act(severity)
	outputting = 0
	output_attempt = 0
	inputting = 0
	input_attempt = 0
	output_level = 0
	input_level = 0
	charge -= 1e6/severity
	if (charge < 0)
		charge = 0
	spawn(100)
		output_level = initial(output_level)
		input_level = initial(input_level)
		inputting = initial(inputting)
		outputting = initial(outputting)
		output_attempt = initial(output_attempt)
		input_attempt = initial(input_attempt)
	..()



/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power."
	process()
		capacity = INFINITY
		charge = INFINITY
		..()



/proc/rate_control(var/S, var/V, var/C, var/Min=1, var/Max=5, var/Limit=null)
	var/href = "<A href='?src=\ref[S];rate control=1;[V]"
	var/rate = "[href]=-[Max]'>-</A>[href]=-[Min]'>-</A> [(C?C : 0)] [href]=[Min]'>+</A>[href]=[Max]'>+</A>"
	if(Limit) return "[href]=-[Limit]'>-</A>"+rate+"[href]=[Limit]'>+</A>"
	return rate


#undef SMESRATE