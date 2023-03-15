//Can be used on a communications console to recall the shuttle. Leaves visible evidence.
/datum/action/innate/darkspawn/silver_tongue
	name = "Silver Tongue"
	id = "silver_tongue"
	desc = "When used near a communications console, allows you to forcefully transmit a message to Central Command, initiating a shuttle recall. Only usable if the shuttle is inbound. Costs 60 Psi."
	button_icon_state = "silver_tongue"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	psi_cost = 60
	lucidity_price = 1 //Very niche, so low cost

/datum/action/innate/darkspawn/silver_tongue/IsAvailable(feedback = FALSE)
	if(SSshuttle.emergency.mode != SHUTTLE_CALL)
		return
	return ..()

/datum/action/innate/darkspawn/silver_tongue/Activate()
	in_use = TRUE
	var/obj/machinery/computer/communications/C = locate() in range(1, owner)
	if(!C)
		to_chat(owner, span_warning("There are no communications consoles nearby"))
		return
	if(C.is_operational)
		to_chat(owner, span_warning("[C] is depowered."))
		return
	owner.visible_message(span_warning("[owner] briefly touches [src]'s screen, and the keys begin to move by themselves!"), \
	"<span class='velvet bold'>[pick("Oknnu. Pda ywlpwej swo hkccaz ej.", "Pda aiancajyu eo kran. Oknnu bkn swopejc ukqn peia.", "We swo knzanaz xu Hws Psk. Whh ckkz jks.")]</span><br>\
	[span_velvet("You begin transmitting a recall message to Central Command...")]")
	play_recall_sounds(C)
	if(!do_after(owner, 8 SECONDS, C))
		in_use = FALSE
		return
	if(!C)
		in_use = FALSE
		return
	if(C.is_operational)
		to_chat(owner, span_warning("[C] has lost power."))
		in_use = FALSE
		return
	in_use = FALSE
	SSshuttle.emergency.cancel()
	to_chat(owner, span_velvet("The ruse was a success. The shuttle is on its way back."))
	return TRUE

/datum/action/innate/darkspawn/silver_tongue/proc/play_recall_sounds(obj/machinery/C) //neato sound effects
	set waitfor = FALSE
	for(var/i in 1 to 4)
		sleep(1 SECONDS)
		if(!C || C.is_operational)
			return
		playsound(C, "terminal_type", 50, TRUE)
		if(prob(25))
			playsound(C, 'sound/machines/terminal_alert.ogg', 50, FALSE)
			do_sparks(5, TRUE, get_turf(C))
	playsound(C, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
	sleep(0.5 SECONDS)
	if(!C || C.is_operational)
		return
	playsound(C, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
