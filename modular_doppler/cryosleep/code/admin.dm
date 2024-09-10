/// Send player in not-quiet cryopod. If with_paper = TRUE, place a paper with notification under player.
/mob/proc/send_to_cryo(with_paper = FALSE)
	//effect
	playsound(loc, 'sound/magic/Repulse.ogg', 100, 1)
	var/datum/effect_system/spark_spread/quantum/sparks = new
	sparks.set_up(10, 1, loc)
	sparks.attach(loc)
	sparks.start()

	//make a paper if need
	if(with_paper)
		var/obj/item/paper/cryo_paper = new /obj/item/paper(loc)
		cryo_paper.name = "Notification - [name]"
		cryo_paper.add_raw_text("Our sincerest apologies, [name][job ? ", [job]," : ""] had to be sent back in Cryogenic Storage for reasons that cannot be elaborated on at the moment.<br><br>Sincerely,<br><i>Nanotrasen Anti-Sudden Sleep Disorder Agency</i>")
		cryo_paper.update_appearance()
	//find cryopod
	for(var/obj/machinery/cryopod/cryo in GLOB.valid_cryopods)
		if(!cryo.occupant && cryo.state_open && !cryo.panel_open) //free, opened, and panel closed?
			if(buckled)
				buckled.unbuckle_mob(src, TRUE)
			if(buckled_mobs)
				for(var/mob/buckled_mob in buckled_mobs)
					unbuckle_mob(buckled_mob)
			cryo.close_machine(src) //put player
			break


