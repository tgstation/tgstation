//Can be used on a communications console to recall the shuttle. Leaves visible evidence.
/datum/action/innate/darkspawn/silver_tongue
	name = "Silver Tongue"
	id = "silver_tongue"
	desc = "When used near a communications console, allows you to forcefully transmit a message to Central Command, initiating a shuttle recall. Only usable if the shuttle is inbound. Costs 60 Psi."
	button_icon_state = "silver_tongue"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_STUN
	psi_cost = 60
	lucidity_price = 1 //Very niche, so low cost

/datum/action/innate/darkspawn/silver_tongue/IsAvailable()
	if(SSshuttle.emergency.mode != SHUTTLE_CALL)
		return
	return ..()

/datum/action/innate/darkspawn/silver_tongue/Activate()
	in_use = TRUE
	var/obj/machinery/computer/communications/C = locate() in range(1, owner)
	if(!C)
		to_chat(owner, "<span class='warning'>There are no communications consoles nearby</span>")
		return
	if(C.stat)
		to_chat(owner, "<span class='warning'>[C] is depowered.</span>")
		return
	owner.visible_message("<span class='warning'>[owner] briefly touches [src]'s screen, and the keys begin to move by themselves!</span>", \
	"<span class='velvet bold'>[pick("Oknnu. Pda ywlpwej swo hkccaz ej.", "Pda aiancajyu eo kran. Oknnu bkn swopejc ukqn peia.", "We swo knzanaz xu Hws Psk. Whh ckkz jks.")]</span><br>\
	<span class='velvet'>You begin transmitting a recall message to Central Command...</span>")
	play_recall_sounds(C)
	if(!do_after(owner, 80, target = C))
		in_use = FALSE
		return
	if(!C)
		in_use = FALSE
		return
	if(C.stat)
		to_chat(owner, "<span class='warning'>[C] has lost power.</span>")
		in_use = FALSE
		return
	in_use = FALSE
	SSshuttle.emergency.cancel()
	to_chat(owner, "<span class='velvet'>The ruse was a success. The shuttle is on its way back.</span>")
	return TRUE

/datum/action/innate/darkspawn/silver_tongue/proc/play_recall_sounds(obj/machinery/C) //neato sound effects
	set waitfor = FALSE
	for(var/i in 1 to 4)
		sleep(10)
		if(!C || C.stat)
			return
		playsound(C, "terminal_type", 50, TRUE)
		if(prob(25))
			playsound(C, 'sound/machines/terminal_alert.ogg', 50, FALSE)
			do_sparks(5, TRUE, get_turf(C))
	playsound(C, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
	sleep(5)
	if(!C || C.stat)
		return
	playsound(C, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
