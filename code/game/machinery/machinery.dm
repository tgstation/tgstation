/*
Overview:
   Used to create objects that need a per step proc call.  Default definition of 'New()'
   stores a reference to src machine in global 'machines list'.  Default definition
   of 'Del' removes reference to src machine in global 'machines list'.

Class Variables:
   use_power (num)
      current state of auto power use.
      Possible Values:
         0 -- no auto power use
         1 -- machine is using power at its idle power level
         2 -- machine is using power at its active power level

   active_power_usage (num)
      Value for the amount of power to use when in active power mode

   idle_power_usage (num)
      Value for the amount of power to use when in idle power mode

   power_channel (num)
      What channel to draw from when drawing power for power mode
      Possible Values:
         EQUIP:0 -- Equipment Channel
         LIGHT:2 -- Lighting Channel
         ENVIRON:3 -- Environment Channel

   component_parts (list)
      A list of component parts of machine used by frame based machines.

   uid (num)
      Unique id of machine across all machines.

   gl_uid (global num)
      Next uid value in sequence

   stat (bitflag)
      Machine status bit flags.
      Possible bit flags:
         BROKEN:1 -- Machine is broken
         NOPOWER:2 -- No power is being supplied to machine.
         POWEROFF:4 -- tbd
         MAINT:8 -- machine is currently under going maintenance.
         EMPED:16 -- temporary broken by EMP pulse

   printer_types (list) > (list)s
      The available sounds, timings, and probabilities for printing in the following format for each element:
      	"my_printer" = list(string/startSound, string/printSound, string/jamSound, number/warmupTime, number/printTimeTillEject, number/printTimeFinish, number/jamProb)

      printTimeTillEject is how much time it takes until the paper is finally ejected
      printTimeFinish is the remaining time until the printer is ready to process the next print job
      jamProb is the probability of jamming

      If a falsey value is given for sounds, a visible message replacement will be used.

   default_printer (string)
      The default set of sounds, timings, and probabilities called by name

   max_printjobs (num)
      The maxium amount of print jobs until the machine emits an error and rejects it
      Zero for unlimited

   printer_jam_time (num)
      How long it takes until the print is unjammed

Class Procs:
   New()                     'game/machinery/machine.dm'

   Destroy()                   'game/machinery/machine.dm'

   auto_use_power()            'game/machinery/machine.dm'
      This proc determines how power mode power is deducted by the machine.
      'auto_use_power()' is called by the 'master_controller' game_controller every
      tick.

      Return Value:
         return:1 -- if object is powered
         return:0 -- if object is not powered.

      Default definition uses 'use_power', 'power_channel', 'active_power_usage',
      'idle_power_usage', 'powered()', and 'use_power()' implement behavior.

   powered(chan = EQUIP)         'modules/power/power.dm'
      Checks to see if area that contains the object has power available for power
      channel given in 'chan'.

   use_power(amount, chan=EQUIP)   'modules/power/power.dm'
      Deducts 'amount' from the power channel 'chan' of the area that contains the object.

   power_change()               'modules/power/power.dm'
      Called by the area that contains the object when ever that area under goes a
      power state change (area runs out of power, or area channel is turned off).

   RefreshParts()               'game/machinery/machine.dm'
      Called to refresh the variables in the machine that are contributed to by parts
      contained in the component_parts list. (example: glass and material amounts for
      the autolathe)

      Default definition does nothing.

   assign_uid()               'game/machinery/machine.dm'
      Called by machine to assign a value to the uid variable.

   process()                  'game/machinery/machine.dm'
      Called by the 'machinery subsystem' once per machinery tick for each machine that is listed in its 'machines' list.

   process_atmos()
      Called by the 'air subsystem' once per atmos tick for each machine that is listed in its 'atmos_machines' list.

   is_operational()
		Returns 0 if the machine is unpowered, broken or undergoing maintenance, something else if not

   new_printjob(string/title, string/text, string/printer, obj/item)
      Creates and queues a printjob to be done on the machine either with plain paper or any object.
      Returns false if queuing failed for any reason, true otherwise.

      Using item will suppress title, text, and paper generation.
	  string/title is the title, or name, of the paper you wish to print.
	  string/text is the text, or info, put onto the paper.
	  string/printer is the name for the set of sounds, timings, and probablities to use for the printjob as avaiable in printer_types.
	  obj/item is the object to be treated as if it was a print job. Suppresses title, text, and normal paper generation.

   print_can_print(number/alert)
	  Checks if the printer can print and, optionally, display a visible message if it can not.

   Compiled by Aygar
*/

/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	verb_say = "beeps"
	verb_yell = "blares"
	pressure_resistance = 15
	obj_integrity = 200
	max_integrity = 200

	var/stat = 0
	var/emagged = 0
	var/use_power = 1
		//0 = dont run the auto
		//1 = run auto, use idle
		//2 = run auto, use active
	var/idle_power_usage = 0
	var/active_power_usage = 0
	var/power_channel = EQUIP
		//EQUIP,ENVIRON or LIGHT
	var/list/component_parts = null //list of all the parts used to build it, if made from certain kinds of frames.
	var/uid
	var/global/gl_uid = 1
	var/panel_open = 0
	var/state_open = 0
	var/critical_machine = FALSE //If this machine is critical to station operation and should have the area be excempted from power failures.
	var/mob/living/occupant = null
	var/unsecuring_tool = /obj/item/weapon/wrench
	var/interact_open = 0 // Can the machine be interacted with when in maint/when the panel is open.
	var/interact_offline = 0 // Can the machine be interacted with while de-powered.
	var/speed_process = 0 // Process as fast as possible?
	// Machine Printing
	// list/printer_spooler holds print jobs formated in list(string/title, string/text, string/printer, obj/item)
	// See new_printjob for more information.
	var/list/printer_spooler = list()
	// boolean/printing if the printer is busy
	var/printing = FALSE
	var/list/printer_types = list(
		"text_only" = list(0, 0, 0, 150, 200, 25, 10),
		"inkjet" = list("sound/machines/printer/inkjet/start.ogg", "sound/machines/printer/inkjet/printing.ogg", 0, 63, 105, 25, 10),
		"dot_matrix" = list(0, "sound/machines/printer/dotmatrix/printing.ogg", 0, 0, 60, 10, 0) // Dot matrix printers are bulletproof man
	)
	var/default_printer = "dot_matrix"
	var/max_printjobs = 0
	// boolean/printer_jammed to keep track if the printer needs to annouce it was unjammed
	var/printer_jammed = FALSE
	var/printer_jam_time = 50

/obj/machinery/New()
	if (!armor)
		armor = list(melee = 25, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 70)
	..()
	machines += src
	if(!speed_process)
		START_PROCESSING(SSmachine, src)
	else
		START_PROCESSING(SSfastprocess, src)
	power_change()

/obj/machinery/Destroy()
	machines.Remove(src)
	if(!speed_process)
		STOP_PROCESSING(SSmachine, src)
	else
		STOP_PROCESSING(SSfastprocess, src)
	printer_clear()
	dropContents()
	return ..()

/obj/machinery/proc/locate_machinery()
	return

/obj/machinery/process()//If you dont use process or power why are you here
	return PROCESS_KILL

/obj/machinery/proc/process_atmos()//If you dont use process why are you here
	return PROCESS_KILL

/obj/machinery/emp_act(severity)
	if(use_power && !stat)
		use_power(7500/severity)
		new /obj/effect/overlay/temp/emp(loc)
	..()

/obj/machinery/proc/open_machine(drop = 1)
	state_open = 1
	density = 0
	if(drop)
		dropContents()
	update_icon()
	updateUsrDialog()

/obj/machinery/proc/dropContents()
	var/turf/T = get_turf(src)
	for(var/atom/movable/A in contents)
		A.forceMove(T)
		if(isliving(A))
			var/mob/living/L = A
			L.update_canmove()
	occupant = null

/obj/machinery/proc/close_machine(mob/living/target = null)
	state_open = 0
	density = 1
	if(!target)
		for(var/mob/living/carbon/C in loc)
			if(C.buckled || C.has_buckled_mobs())
				continue
			else
				target = C
	if(target && !target.buckled && !target.has_buckled_mobs())
		occupant = target
		target.forceMove(src)
	updateUsrDialog()
	update_icon()

/obj/machinery/proc/auto_use_power()
	if(!powered(power_channel))
		return 0
	if(use_power == 1)
		use_power(idle_power_usage,power_channel)
	else if(use_power >= 2)
		use_power(active_power_usage,power_channel)
	return 1

/obj/machinery/proc/is_operational()
	return !(stat & (NOPOWER|BROKEN|MAINT))

/obj/machinery/proc/is_interactable()
	if((stat & (NOPOWER|BROKEN)) && !interact_offline)
		return FALSE
	if(panel_open && !interact_open)
		return FALSE
	return TRUE


////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/interact(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/ui_status(mob/user)
	if(is_interactable())
		return ..()
	return UI_CLOSE

/obj/machinery/ui_act(action, params)
	add_fingerprint(usr)
	return ..()

/obj/machinery/Topic(href, href_list)
	..()
	if(!is_interactable())
		return 1
	if(!usr.canUseTopic(src))
		return 1
	add_fingerprint(usr)
	return 0


////////////////////////////////////////////////////////////////////////////////////////////



/obj/machinery/attack_paw(mob/living/user)
	if(user.a_intent != INTENT_HARM)
		return attack_hand(user)
	else
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		user.visible_message("<span class='danger'>[user.name] smashes against \the [src.name] with its paws.</span>", null, null, COMBAT_MESSAGE_RANGE)
		take_damage(4, BRUTE, "melee", 1)


/obj/machinery/attack_ai(mob/user)
	if(iscyborg(user))// For some reason attack_robot doesn't work
		var/mob/living/silicon/robot/R = user
		if(R.client && R.client.eye == R && !R.low_power_mode)// This is to stop robots from using cameras to remotely control machines; and from using machines when the borg has no power.
			return attack_hand(user)
	else
		return attack_hand(user)


//set_machine must be 0 if clicking the machinery doesn't bring up a dialog
/obj/machinery/attack_hand(mob/user, check_power = 1, set_machine = 1)
	if(..())// unbuckling etc
		return 1
	if((user.lying || user.stat) && !IsAdminGhost(user))
		return 1
	if(!user.IsAdvancedToolUser() && !IsAdminGhost(user))
		usr << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return 1
	if(!is_interactable())
		return 1
	if(set_machine)
		user.set_machine(src)
	interact(user)
	add_fingerprint(user)
	return 0

/obj/machinery/CheckParts(list/parts_list)
	..()
	RefreshParts()

/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return

/obj/machinery/proc/assign_uid()
	uid = gl_uid
	gl_uid++

/obj/machinery/proc/default_pry_open(obj/item/weapon/crowbar/C)
	. = !(state_open || panel_open || is_operational() || (flags & NODECONSTRUCT)) && istype(C)
	if(.)
		playsound(loc, C.usesound, 50, 1)
		visible_message("<span class='notice'>[usr] pries open \the [src].</span>", "<span class='notice'>You pry open \the [src].</span>")
		open_machine()
		return 1

/obj/machinery/proc/default_deconstruction_crowbar(obj/item/weapon/crowbar/C, ignore_panel = 0)
	. = istype(C) && (panel_open || ignore_panel) &&  !(flags & NODECONSTRUCT)
	if(.)
		playsound(loc, C.usesound, 50, 1)
		deconstruct(TRUE)

/obj/machinery/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		on_deconstruction()
		if(component_parts && component_parts.len)
			spawn_frame(disassembled)
			for(var/obj/item/I in component_parts)
				I.forceMove(loc)
	qdel(src)

/obj/machinery/proc/spawn_frame(disassembled)
	var/obj/structure/frame/machine/M = new /obj/structure/frame/machine(loc)
	. = M
	M.anchored = anchored
	if(!disassembled)
		M.obj_integrity = M.max_integrity * 0.5 //the frame is already half broken
	transfer_fingerprints_to(M)
	M.state = 2
	M.icon_state = "box_1"

/obj/machinery/obj_break(damage_flag)
	if(!(flags & NODECONSTRUCT))
		stat |= BROKEN

/obj/machinery/contents_explosion(severity, target)
	if(occupant)
		occupant.ex_act(severity, target)

/obj/machinery/handle_atom_del(atom/A)
	if(A == occupant)
		occupant = null
		update_icon()
		updateUsrDialog()

/obj/machinery/proc/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/weapon/screwdriver/S)
	if(istype(S) &&  !(flags & NODECONSTRUCT))
		playsound(loc, S.usesound, 50, 1)
		if(!panel_open)
			panel_open = 1
			icon_state = icon_state_open
			user << "<span class='notice'>You open the maintenance hatch of [src].</span>"
		else
			panel_open = 0
			icon_state = icon_state_closed
			user << "<span class='notice'>You close the maintenance hatch of [src].</span>"
		return 1
	return 0

/obj/machinery/proc/default_change_direction_wrench(mob/user, obj/item/weapon/wrench/W)
	if(panel_open && istype(W))
		playsound(loc, W.usesound, 50, 1)
		setDir(turn(dir,-90))
		user << "<span class='notice'>You rotate [src].</span>"
		return 1
	return 0

/obj/proc/can_be_unfasten_wrench(mob/user)
	if(!isfloorturf(loc) && !anchored)
		user << "<span class='warning'>[src] needs to be on the floor to be secured!</span>"
		return FAILED_UNFASTEN
	return SUCCESSFUL_UNFASTEN

/obj/proc/default_unfasten_wrench(mob/user, obj/item/weapon/wrench/W, time = 20)
	if(istype(W) && !(flags & NODECONSTRUCT))
		var/can_be_unfasten = can_be_unfasten_wrench(user)
		if(!can_be_unfasten || can_be_unfasten == FAILED_UNFASTEN)
			return can_be_unfasten
		if(time)
			user << "<span class='notice'>You begin [anchored ? "un" : ""]securing [src]...</span>"
		playsound(loc, W.usesound, 50, 1)
		var/prev_anchored = anchored
		//as long as we're the same anchored state and we're either on a floor or are anchored, toggle our anchored state
		if(!time || (do_after(user, time*W.toolspeed, target = src) && anchored == prev_anchored))
			can_be_unfasten = can_be_unfasten_wrench(user)
			if(!can_be_unfasten || can_be_unfasten == FAILED_UNFASTEN)
				return can_be_unfasten
			user << "<span class='notice'>You [anchored ? "un" : ""]secure [src].</span>"
			anchored = !anchored
			playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
			return SUCCESSFUL_UNFASTEN
		return FAILED_UNFASTEN
	return CANT_UNFASTEN

/obj/machinery/proc/exchange_parts(mob/user, obj/item/weapon/storage/part_replacer/W)
	if(!istype(W))
		return
	if((flags & NODECONSTRUCT) && !W.works_from_distance)
		return
	var/shouldplaysound = 0
	if(component_parts)
		if(panel_open || W.works_from_distance)
			var/obj/item/weapon/circuitboard/machine/CB = locate(/obj/item/weapon/circuitboard/machine) in component_parts
			var/P
			if(W.works_from_distance)
				display_parts(user)
			for(var/obj/item/weapon/stock_parts/A in component_parts)
				for(var/D in CB.req_components)
					if(ispath(A.type, D))
						P = D
						break
				for(var/obj/item/weapon/stock_parts/B in W.contents)
					if(istype(B, P) && istype(A, P))
						if(B.rating > A.rating)
							W.remove_from_storage(B, src)
							W.handle_item_insertion(A, 1)
							component_parts -= A
							component_parts += B
							B.loc = null
							user << "<span class='notice'>[A.name] replaced with [B.name].</span>"
							shouldplaysound = 1 //Only play the sound when parts are actually replaced!
							break
			RefreshParts()
		else
			display_parts(user)
		if(shouldplaysound)
			W.play_rped_sound()
		return 1
	return 0

/obj/machinery/proc/display_parts(mob/user)
	user << "<span class='notice'>Following parts detected in the machine:</span>"
	for(var/obj/item/C in component_parts)
		user << "<span class='notice'>\icon[C] [C.name]</span>"

/obj/machinery/examine(mob/user)
	..()
	if(stat & BROKEN)
		user << "<span class='notice'>It looks broken and non functional.</span>"
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			user << "<span class='warning'>It's on fire!</span>"
		var/healthpercent = (obj_integrity/max_integrity) * 100
		switch(healthpercent)
			if(50 to 99)
				user <<  "It looks slightly damaged."
			if(25 to 50)
				user <<  "It appears heavily damaged."
			if(0 to 25)
				user <<  "<span class='warning'>It's falling apart!</span>"
	if(user.research_scanner && component_parts)
		display_parts(user)

//called on machinery construction (i.e from frame to machinery) but not on initialization
/obj/machinery/proc/on_construction()
	return

//called on deconstruction before the final deletion
/obj/machinery/proc/on_deconstruction()
	printer_clear()
	return

/obj/machinery/allow_drop()
	return 0

// Hook for html_interface module to prevent updates to clients who don't have this as their active machine.
/obj/machinery/proc/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
	if (hclient.client.mob && (hclient.client.mob.stat == 0 || IsAdminGhost(hclient.client.mob)))
		if (isAI(hclient.client.mob) || IsAdminGhost(hclient.client.mob)) return TRUE
		else                          return hclient.client.mob.machine == src && Adjacent(hclient.client.mob)
	else
		return FALSE

// Hook for html_interface module to unset the active machine when the window is closed by the player.
/obj/machinery/proc/hiOnHide(datum/html_interface_client/hclient)
	if (hclient.client.mob && hclient.client.mob.machine == src) hclient.client.mob.unset_machine()

/obj/machinery/proc/can_be_overridden()
	. = 1


/obj/machinery/tesla_act(power, explosive = FALSE)
	..()
	if(prob(85) && explosive)
		explosion(src.loc,1,2,4,flame_range = 2, adminlog = 0, smoke = 0)
	else if(prob(50))
		emp_act(2)
	else
		ex_act(2)

/obj/machinery/proc/printer_can_print(alert = FALSE)
	if(max_printjobs && printer_spooler.len >= max_printjobs)
		if(alert)
			printer_memory_full()
		return FALSE
	else
		return TRUE

/obj/machinery/proc/printer_memory_full()
	if(prob(20))
		src.visible_message("<span class='danger'>The [src] printer beeps with a message: PC LOAD LETTER</span>")
	else
		src.visible_message("<span class='danger'>The [src] printer beeps with a message: MEMORY FULL</span>")
	return

/obj/machinery/proc/new_printjob(title = "Printed Paper" , text = "", printer = default_printer, obj/item = null)
	if(is_operational())
		if(!printer_can_print(1))
			if(item)
				qdel(item)
			return FALSE // Print job can not print
		printer_spooler[++printer_spooler.len] = list(title, text, printer, item)
		if(!printing)
			var/list/cur_printer = printer_types[printer]
			printing = TRUE
			if(cur_printer[1])
				playsound(src.loc, cur_printer[1], 100, 0)
			else
				src.visible_message("<span class='notice'>The [src] printer makes a noisy clatter as it warms up.</span>")
			addtimer(CALLBACK(src, .proc/printer_warmed_up), cur_printer[4])
		return TRUE // Print job has been sent.
	else
		printer_clear() // Power turned off or broken. Clear spooler.
		return FALSE // Print job can not print

/obj/machinery/proc/printer_warmed_up() // If we want to do something special.
	printer_start_print()
	return

/obj/machinery/proc/printer_start_print()
	if(is_operational() && printing)
		var/list/printjob = printer_spooler[1]
		var/list/printer = printer_types[printjob[3]]
		if(printer[7])
			if(prob(printer[7]))
				if(printer[3])
					playsound(src.loc, printer[2], 100, 0)
					src.visible_message("<span class='danger'>The [src] printer beeps with a message: JAM</span>")
				else
					src.visible_message("<span class='danger'>The [src] printer makes a cringing crunch before it beeps with a message: JAM</span>")
				printer_is_jammed()
				return
		printer_printing_paper()
	else
		printer_clear()
		printing = FALSE
	return
/obj/machinery/proc/printer_is_jammed()
	printer_jammed = TRUE
	addtimer(CALLBACK(src, .proc/printer_is_unjammed), printer_jam_time)
	return

/obj/machinery/proc/printer_is_unjammed()
	printer_jammed = FALSE
	src.visible_message("<span class='notice'>The [src] printer unjams itself, continuing to print.</span>")
	printer_printing_paper()
	return

/obj/machinery/proc/printer_printing_paper()
	if(is_operational() && printing)
		var/list/printjob = printer_spooler[1]
		var/list/printer = printer_types[printjob[3]]
		if(printer[2])
			playsound(src.loc, printer[2], 100, 0)
		else
			src.visible_message("<span class='notice'>The [src] printer whirrs noisily as it prints a document.</span>")
		addtimer(CALLBACK(src, .proc/printer_ejecting_paper), printer[5])
	else
		printer_clear()
		printing = FALSE
		printer_jammed = FALSE
	return

/obj/machinery/proc/printer_ejecting_paper()
	if(is_operational() && printing) // Gotta check one more time. Don't want to eject paper into nothing or without power.
		var/list/printjob = printer_spooler[1]
		var/list/printer = printer_types[printjob[3]]
		if(!printjob[4])
			var/obj/item/weapon/paper/P = new/obj/item/weapon/paper(src.loc)
			P.name = printjob[1]
			P.info = printjob[2]
			P.update_icon()
			P.updateinfolinks()
		else // This printjob has an item. Eject it.
			var/turf/T = get_turf(src)
			var/obj/item = printjob[4]
			item.forceMove(T)
		printer_spooler.Cut(1,2)
		addtimer(CALLBACK(src, .proc/printer_finished_printing), printer[6])
	else
		printer_clear()
		printing = FALSE
	return

/obj/machinery/proc/printer_finished_printing()
	if(printer_spooler.len)
		printer_start_print()
	else
		printing = FALSE
	return

/obj/machinery/proc/printer_clear() // Removes printjobs safely.
	for(var/i = 1 to printer_spooler.len) // SureokaywhateveryousayIguess
		var/list/printjob = printer_spooler[i]
		if(printjob[4])
			qdel(printjob[4])
	printer_spooler.len = 0
	return