/obj/item/device/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	w_class = 3
	origin_tech = "engineering=4;materials=4;bluespace=2;programming=6"

	var/list/construction_cost = list("metal"=500,"glass"=500,"silver"=200,"gold"=200,"plasma"=100,"diamond"=10)
	var/construction_time = 75
	var/searching = 0
	var/askDelay = 10 * 60 * 1

	req_access = list(access_robotics)
	var/locked = 0
	var/mob/living/carbon/brain/brainmob = null//The current occupant.
	var/obj/mecha = null//This does not appear to be used outside of reference in mecha.dm.

	attack_self(mob/user as mob)
		if(!brainmob && searching == 0)
			//Start the process of searching for a new user.
			user << "\blue You carefully locate the manual activation switch and start the positronic brain's boot process."
			icon_state = "posibrain-searching"
			src.searching = 1
			src.request_player()

	proc/request_player()
		for(var/mob/dead/observer/O in player_list)
			if(jobban_isbanned(O, "pAI"))
				continue
			if(O.client)
				if(O.client.be_pai)
					question(O.client)

	proc/question(var/client/C)
		spawn(0)
			if(!C)	return
			var/response = alert(C, "Someone is requesting a personality for a positronic brain. Would you like to play as one?", "Positronic brain request", "Yes", "No", "Never for this round")
			if(!C || brainmob)	return		//handle logouts that happen whilst the alert is waiting for a response, and responses issued after a brain has been located.
			if(response == "Yes")
				transfer_personality(C.mob)
			else if (response == "Never for this round")
				C.be_pai = 0


	proc/transfer_personality(var/mob/candidate)

		var/mob/living/carbon/brain/B = new(src)

		src.searching = 0

		src.brainmob = B
		src.brainmob.mind = candidate.mind

		src.brainmob.name = "PBU-[rand(100, 999)]"
		src.brainmob.real_name = "PBU-[rand(100, 999)]"
		src.brainmob.loc = src
		src.brainmob.container = src
		src.brainmob.stat = 0
		src.brainmob.silent = 0
		src.brainmob.brain_op_stage = 4.0
		src.brainmob.key = candidate.key

		dead_mob_list -= src.brainmob
		living_mob_list += src.brainmob

		var/turf/T = get_turf_or_move(src.loc)
		for (var/mob/M in viewers(T))
			M.show_message("\blue The positronic brain chimes quietly.")
		icon_state = "posibrain-occupied"

	proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.

		if(brainmob) return

		src.searching = 0
		icon_state = "posibrain"

		var/turf/T = get_turf_or_move(src.loc)
		for (var/mob/M in viewers(T))
			M.show_message("\blue The positronic brain buzzes quietly, and the golden lights fade away. Perhaps you could try again?")

/obj/item/device/posibrain/examine()

	set src in oview()

	if(!usr || !src)	return
	if( (usr.sdisabilities & BLIND || usr.blinded || usr.stat) && !istype(usr,/mob/dead/observer) )
		usr << "<span class='notice'>Something is there but you can't see it.</span>"
		return

	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n[desc]\n"
	msg += "<span class='warning'>"

	if(src.brainmob)
		switch(src.brainmob.stat)
			if(CONSCIOUS)
				if(!src.brainmob.client)	msg += "It appears to be in stand-by mode.\n" //afk
			if(UNCONSCIOUS)		msg += "<span class='warning'>It doesn't seem to be responsive.</span>\n"
			if(DEAD)			msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	else
		msg += "[desc]\n"
	msg += "*---------*</span>"
	usr << msg
	return

/obj/item/device/posibrain/emp_act(severity)
	if(!brainmob)
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage += rand(20,30)
			if(2)
				brainmob.emp_damage += rand(10,20)
			if(3)
				brainmob.emp_damage += rand(0,10)
	..()