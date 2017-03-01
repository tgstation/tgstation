//Can be used on a communications console to recall the shuttle. Leaves visible evidence.
/datum/action/innate/umbrage/silver_tongue
	name = "Silver Tongue"
	id = "silver_tongue"
	desc = "When used near a communications console, allows you to forcefully transmit a message to Central Command, initiating a shuttle recall."
	button_icon_state = "umbrage_silver_tongue"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_STUNNED
	psi_cost = 100
	lucidity_cost = 1 //Very niche, so low cost
	blacklisted = 0

/datum/action/innate/umbrage/silver_tongue/IsAvailable()
	if(SSshuttle.emergency.mode != SHUTTLE_CALL)
		return
	return ..()

/datum/action/innate/umbrage/silver_tongue/Activate()
	var/obj/machinery/computer/communications/C = locate() in range(1, owner)
	if(!C)
		owner << "<span class='warning'>There are no communications consoles nearby.</span>"
		return
	if(C.stat)
		owner << "<span class='warning'>[C] is depowered.</span>"
		return
	owner.visible_message("<span class='warning'>[owner] presses \his hand against [src]'s keys, and they begin to move by themselves!</span>", \
	"<span class='velvet bold'>[pick("Oknnu. Pda ywlpwej swo hkccaz ej.", "Pda aiancajyu eo kran. Oknnu bkn swopejc ukqn peia.", "We swo knzanaz xu Hws Psk. Whh ckkz jks.")]</span>\n\
	<span class='notice'>You begin transmitting a recall message to Central Command...</span>")
	play_recall_sounds(C)
	if(!do_after(owner, 30, target = C))
		return
	if(C.stat)
		owner << "<span class='warning'>[C] has lost power.</span>"
		return
	owner << "<span class='notice'>The ruse was a success. The shuttle is on its way back.</span>"
	SSshuttle.cancelEvac(owner)
	return TRUE

/datum/action/innate/umbrage/silver_tongue/proc/play_recall_sounds(obj/machinery/C) //neato sound effects
	for(var/i in 1 to 4)
		sleep(10)
		if(!C || C.stat)
			return
		playsound(C, "terminal_type", 50, 1)
		if(prob(25))
			playsound(C, 'sound/machines/terminal_alert.ogg', 50, 0)
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(5, 1, get_turf(C))
			s.start()
	playsound(C, 'sound/machines/terminal_prompt.ogg', 50, 0)
	sleep(5)
	if(!C || C.stat)
		return
	playsound(C, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	owner << "<span class='notice'>Recall initiated...</span>"
