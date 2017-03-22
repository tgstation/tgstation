// the SMES
// stores power

#define SMESRATE 0.05			// rate of internal charge to external power

//Cache defines
#define SMES_CLEVEL_1		1
#define SMES_CLEVEL_2		2
#define SMES_CLEVEL_3		3
#define SMES_CLEVEL_4		4
#define SMES_CLEVEL_5		5
#define SMES_OUTPUTTING		6
#define SMES_NOT_OUTPUTTING 7
#define SMES_INPUTTING		8
#define SMES_INPUT_ATTEMPT	9

/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = 1
	anchored = 1
	use_power = 0
	var/capacity = 5e6 // maximum charge
	var/charge = 0 // actual charge

	var/input_attempt = 1 // 1 = attempting to charge, 0 = not attempting to charge
	var/inputting = 1 // 1 = actually inputting, 0 = not inputting
	var/input_level = 50000 // amount of power the SMES attempts to charge by
	var/input_level_max = 200000 // cap on input_level
	var/input_available = 0 // amount of charge available from input last tick

	var/output_attempt = 1 // 1 = attempting to output, 0 = not attempting to output
	var/outputting = 1 // 1 = actually outputting, 0 = not outputting
	var/output_level = 50000 // amount of power the SMES attempts to output
	var/output_level_max = 200000 // cap on output_level
	var/output_used = 0 // amount of power actually outputted. may be less than output_level if the powernet returns excess power

	var/obj/machinery/power/terminal/terminal = null

	var/static/list/smesImageCache


/obj/machinery/power/smes/examine(user)
	..()
	if(!terminal)
		to_chat(user, "<span class='warning'>This SMES has no power terminal!</span>")

/obj/machinery/power/smes/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/smes(null)
	B.apply_default_parts(src)

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
		update_icon()
	return

/obj/item/weapon/circuitboard/machine/smes
	name = "SMES (Machine Board)"
	build_path = /obj/machinery/power/smes
	origin_tech = "programming=3;powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/cell = 5,
							/obj/item/weapon/stock_parts/capacitor = 1)
	def_components = list(/obj/item/weapon/stock_parts/cell = /obj/item/weapon/stock_parts/cell/high/empty)

/obj/machinery/power/smes/RefreshParts()
	var/IO = 0
	var/MC = 0
	var/C
	for(var/obj/item/weapon/stock_parts/capacitor/CP in component_parts)
		IO += CP.rating
	input_level_max = initial(input_level_max) * IO
	output_level_max = initial(output_level_max) * IO
	for(var/obj/item/weapon/stock_parts/cell/PC in component_parts)
		MC += PC.maxcharge
		C += PC.charge
	capacity = MC / (15000) * 1e6
	if(!initial(charge) && !charge)
		charge = C / 15000 * 1e6

/obj/machinery/power/smes/attackby(obj/item/I, mob/user, params)
	//opening using screwdriver
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		update_icon()
		return

	//changing direction using wrench
	if(default_change_direction_wrench(user, I))
		terminal = null
		var/turf/T = get_step(src, dir)
		for(var/obj/machinery/power/terminal/term in T)
			if(term && term.dir == turn(dir, 180))
				terminal = term
				terminal.master = src
				to_chat(user, "<span class='notice'>Terminal found.</span>")
				break
		if(!terminal)
			to_chat(user, "<span class='alert'>No power terminal found.</span>")
			return
		stat &= ~BROKEN
		update_icon()
		return

	//exchanging parts using the RPE
	if(exchange_parts(user, I))
		return

	//building and linking a terminal
	if(istype(I, /obj/item/stack/cable_coil))
		var/dir = get_dir(user,src)
		if(dir & (dir-1))//we don't want diagonal click
			return

		if(terminal) //is there already a terminal ?
			to_chat(user, "<span class='warning'>This SMES already has a power terminal!</span>")
			return

		if(!panel_open) //is the panel open ?
			to_chat(user, "<span class='warning'>You must open the maintenance panel first!</span>")
			return

		var/turf/T = get_turf(user)
		if (T.intact) //is the floor plating removed ?
			to_chat(user, "<span class='warning'>You must first remove the floor plating!</span>")
			return


		var/obj/item/stack/cable_coil/C = I
		if(C.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need more wires!</span>")
			return

		to_chat(user, "<span class='notice'>You start building the power terminal...</span>")
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

		if(do_after(user, 20, target = src) && C.get_amount() >= 10)
			if(C.get_amount() < 10 || !C)
				return
			var/obj/structure/cable/N = T.get_cable_node() //get the connecting node cable, if there's one
			if (prob(50) && electrocute_mob(usr, N, N, 1, TRUE)) //animate the electrocution if uncautious and unlucky
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				return

			C.use(10)
			user.visible_message(\
				"[user.name] has built a power terminal.",\
				"<span class='notice'>You build the power terminal.</span>")

			//build the terminal and link it to the network
			make_terminal(T)
			terminal.connect_to_network()
		return

	//disassembling the terminal
	if(istype(I, /obj/item/weapon/wirecutters) && terminal && panel_open)
		terminal.dismantle(user, I)
		return

	//crowbarring it !
	var/turf/T = get_turf(src)
	if(default_deconstruction_crowbar(I))
		message_admins("[src] has been deconstructed by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) in ([T.x],[T.y],[T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)",0,1)
		log_game("[src] has been deconstructed by [key_name(user)]")
		investigate_log("SMES deconstructed by [key_name(user)]","singulo")
		return
	else if(panel_open && istype(I, /obj/item/weapon/crowbar))
		return

	return ..()

/obj/machinery/power/smes/default_deconstruction_crowbar(obj/item/weapon/crowbar/C)
	if(istype(C) && terminal)
		to_chat(usr, "<span class='warning'>You must first remove the power terminal!</span>")
		return FALSE

	return ..()

/obj/machinery/power/smes/on_deconstruction()
	for(var/obj/item/weapon/stock_parts/cell/cell in component_parts)
		cell.charge = (charge / capacity) * cell.maxcharge

/obj/machinery/power/smes/Destroy()
	if(SSticker && SSticker.current_state == GAME_STATE_PLAYING)
		var/area/area = get_area(src)
		message_admins("SMES deleted at (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>[area.name]</a>)")
		log_game("SMES deleted at ([area.name])")
		investigate_log("<font color='red'>deleted</font> at ([area.name])","singulo")
	if(terminal)
		disconnect_terminal()
	return ..()

// create a terminal object pointing towards the SMES
// wires will attach to this
/obj/machinery/power/smes/proc/make_terminal(turf/T)
	terminal = new/obj/machinery/power/terminal(T)
	terminal.setDir(get_dir(T,src))
	terminal.master = src
	stat &= ~BROKEN

/obj/machinery/power/smes/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null
		stat |= BROKEN


/obj/machinery/power/smes/update_icon()
	cut_overlays()
	if(stat & BROKEN)
		return

	if(panel_open)
		return

	if(!smesImageCache || !smesImageCache.len)
		smesImageCache = list()
		smesImageCache.len = 9

		smesImageCache[SMES_CLEVEL_1] = image('icons/obj/power.dmi',"smes-og1")
		smesImageCache[SMES_CLEVEL_2] = image('icons/obj/power.dmi',"smes-og2")
		smesImageCache[SMES_CLEVEL_3] = image('icons/obj/power.dmi',"smes-og3")
		smesImageCache[SMES_CLEVEL_4] = image('icons/obj/power.dmi',"smes-og4")
		smesImageCache[SMES_CLEVEL_5] = image('icons/obj/power.dmi',"smes-og5")

		smesImageCache[SMES_OUTPUTTING] = image('icons/obj/power.dmi', "smes-op1")
		smesImageCache[SMES_NOT_OUTPUTTING] = image('icons/obj/power.dmi',"smes-op0")
		smesImageCache[SMES_INPUTTING] = image('icons/obj/power.dmi', "smes-oc1")
		smesImageCache[SMES_INPUT_ATTEMPT] = image('icons/obj/power.dmi', "smes-oc0")

	if(outputting)
		add_overlay(smesImageCache[SMES_OUTPUTTING])
	else
		add_overlay(smesImageCache[SMES_NOT_OUTPUTTING])

	if(inputting)
		add_overlay(smesImageCache[SMES_INPUTTING])
	else
		if(input_attempt)
			add_overlay(smesImageCache[SMES_INPUT_ATTEMPT])

	var/clevel = chargedisplay()
	if(clevel>0)
		add_overlay(smesImageCache[clevel])
	return


/obj/machinery/power/smes/proc/chargedisplay()
	return round(5.5*charge/capacity)

/obj/machinery/power/smes/process()
	if(stat & BROKEN)
		return

	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_chrg = inputting
	var/last_onln = outputting

	//inputting
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
			if(input_attempt && input_available > 0 && input_available >= input_level)
				inputting = 1
	else
		inputting = 0

	//outputting
	if(output_attempt)
		if(outputting)
			output_used = min( charge/SMESRATE, output_level)		//limit output to that stored

			charge -= output_used*SMESRATE		// reduce the storage (may be recovered in /restore() if excessive)

			add_avail(output_used)				// add output to powernet (smes side)

			if(output_used < 0.0001)		// either from no charge or set to 0
				outputting = 0
				investigate_log("lost power and turned <font color='red'>off</font>","singulo")
		else if(output_attempt && charge > output_level && output_level > 0)
			outputting = 1
		else
			output_used = 0
	else
		outputting = 0

	// only update icon if state changed
	if(last_disp != chargedisplay() || last_chrg != inputting || last_onln != outputting)
		update_icon()



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

	charge += excess * SMESRATE			// restore unused power
	powernet.netexcess -= excess		// remove the excess from the powernet, so later SMESes don't try to use it

	output_used -= excess

	if(clev != chargedisplay() ) //if needed updates the icons overlay
		update_icon()
	return


/obj/machinery/power/smes/add_load(amount)
	if(terminal && terminal.powernet)
		terminal.powernet.load += amount

/obj/machinery/power/smes/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
										datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "smes", name, 340, 440, master_ui, state)
		ui.open()

/obj/machinery/power/smes/ui_data()
	var/list/data = list(
		"capacityPercent" = round(100*charge/capacity, 0.1),
		"capacity" = capacity,
		"charge" = charge,

		"inputAttempt" = input_attempt,
		"inputting" = inputting,
		"inputLevel" = input_level,
		"inputLevelMax" = input_level_max,
		"inputAvailable" = input_available,

		"outputAttempt" = output_attempt,
		"outputting" = outputting,
		"outputLevel" = output_level,
		"outputLevelMax" = output_level_max,
		"outputUsed" = output_used
	)
	return data

/obj/machinery/power/smes/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("tryinput")
			input_attempt = !input_attempt
			log_smes(usr.ckey)
			update_icon()
			. = TRUE
		if("tryoutput")
			output_attempt = !output_attempt
			log_smes(usr.ckey)
			update_icon()
			. = TRUE
		if("input")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("New input target (0-[input_level_max]):", name, input_level) as num|null
				if(!isnull(target) && !..())
					. = TRUE
			else if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = input_level_max
				. = TRUE
			else if(adjust)
				target = input_level + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				input_level = Clamp(target, 0, input_level_max)
				log_smes(usr.ckey)
		if("output")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("New output target (0-[output_level_max]):", name, output_level) as num|null
				if(!isnull(target) && !..())
					. = TRUE
			else if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = output_level_max
				. = TRUE
			else if(adjust)
				target = output_level + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				output_level = Clamp(target, 0, output_level_max)
				log_smes(usr.ckey)

/obj/machinery/power/smes/proc/log_smes(user = "")
	investigate_log("input/output; [input_level>output_level?"<font color='green'>":"<font color='red'>"][input_level]/[output_level]</font> | Charge: [charge] | Output-mode: [output_attempt?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [input_attempt?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [user]", "singulo")


/obj/machinery/power/smes/emp_act(severity)
	input_attempt = rand(0,1)
	inputting = input_attempt
	output_attempt = rand(0,1)
	outputting = output_attempt
	output_level = rand(0, output_level_max)
	input_level = rand(0, input_level_max)
	charge -= 1e6/severity
	if (charge < 0)
		charge = 0
	update_icon()
	log_smes("an emp")
	..()

/obj/machinery/power/smes/engineering
	charge = 1.5e6 // Engineering starts with some charge for singulo

/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power."

/obj/machinery/power/smes/magical/process()
	capacity = INFINITY
	charge = INFINITY
	..()


#undef SMESRATE

#undef SMES_CLEVEL_1
#undef SMES_CLEVEL_2
#undef SMES_CLEVEL_3
#undef SMES_CLEVEL_4
#undef SMES_CLEVEL_5
#undef SMES_OUTPUTTING
#undef SMES_NOT_OUTPUTTING
#undef SMES_INPUTTING
#undef SMES_INPUT_ATTEMPT
