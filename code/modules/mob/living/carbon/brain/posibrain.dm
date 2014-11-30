/obj/item/device/mmi/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	w_class = 3
	origin_tech = "engineering=4;materials=4;bluespace=2;programming=4"

	var/searching = 0
	var/askDelay = 10 * 60 * 1
	//var/mob/living/carbon/brain/brainmob = null
	var/list/ghost_volunteers[0]
	req_access = list(access_robotics)
	locked = 0
	mecha = null//This does not appear to be used outside of reference in mecha.dm.


	attack_self(mob/user as mob)
		if(brainmob && !brainmob.key && searching == 0)
			//Start the process of searching for a new user.
			user << "\blue You carefully locate the manual activation switch and start the positronic brain's boot process."
			icon_state = "posibrain-searching"
			ghost_volunteers.Cut()
			src.searching = 1
			src.request_player()
			spawn(600)
				if(ghost_volunteers.len)
					var/mob/dead/observer/O = pick(ghost_volunteers)
					if(istype(O) && O.client && O.key)
						transfer_personality(O)
				reset_search()

	proc/request_player()
		for(var/mob/dead/observer/O in get_active_candidates(ROLE_POSIBRAIN,poll="\A [src] has been activated."))
			if(O.client)
				if(check_observer(O))
					O << "<span class=\"recruit\">You are a possible candidate for \a [src]. Get ready. (<a href='?src=\ref[O];jump=\ref[src]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Retract</a>)</span>"
					ghost_volunteers += O

	proc/check_observer(var/mob/dead/observer/O)
		if(O.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
			return 0
		if(jobban_isbanned(O, "pAI"))
			return 0
		if(O.client)
			return 1
		return 0

	proc/question(var/client/C)
		spawn(0)
			if(!C)	return
			var/response = alert(C, "Someone is requesting a personality for a positronic brain. Would you like to play as one?", "Positronic brain request", "Yes", "No", "Never for this round")
			if(!C || brainmob.key || 0 == searching)	return		//handle logouts that happen whilst the alert is waiting for a response, and responses issued after a brain has been located.
			if(response == "Yes")
				transfer_personality(C.mob)

	proc/transfer_personality(var/mob/candidate)

		src.searching = 0
		//src.brainmob.mind = candidate.mind Causes issues with traitor overlays and traitor specific chat.
		//src.brainmob.key = candidate.key
		src.brainmob.ckey = candidate.ckey
		src.brainmob.stat = 0
		src.name = "positronic brain ([src.brainmob.name])"

		src.brainmob << "<b>You are a positronic brain, brought into existence on [station_name()].</b>"
		src.brainmob << "<b>As a synthetic intelligence, you answer to all crewmembers, as well as the AI.</b>"
		src.brainmob << "<b>Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>"
		src.brainmob << "<b>Use say :b to speak to other artificial intelligences.</b>"
		src.brainmob.mind.assigned_role = "Positronic Brain"

		var/turf/T = get_turf_or_move(src.loc)
		for (var/mob/M in viewers(T))
			M.show_message("\blue The positronic brain chimes quietly.")
		icon_state = "posibrain-occupied"

	proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.

		if(src.brainmob && src.brainmob.key) return

		src.searching = 0
		icon_state = "posibrain"

		var/turf/T = get_turf_or_move(src.loc)
		for (var/mob/M in viewers(T))
			M.show_message("\blue The positronic brain buzzes quietly, and the golden lights fade away. Perhaps you could try again?")

	Topic(href,href_list)
		if("signup" in href_list)
			var/mob/dead/observer/O = locate(href_list["signup"])
			if(!O) return
			volunteer(O)

	proc/volunteer(var/mob/dead/observer/O)
		if(!searching)
			O << "Not looking for a ghost, yet."
			return
		if(!istype(O))
			O << "\red NO."
			return
		if(O in ghost_volunteers)
			O << "\blue Removed from registration list."
			ghost_volunteers.Remove(O)
			return
		if(!check_observer(O))
			O << "\red You cannot be \a [src]."
			return
		O.<< "\blue You've been added to the list of ghosts that may become this [src].  Click again to unvolunteer."
		ghost_volunteers.Add(O)


/obj/item/device/mmi/posibrain/examine()

	set src in oview()

	if(!usr || !src)	return
	if( (usr.sdisabilities & BLIND || usr.blinded || usr.stat) && !istype(usr,/mob/dead/observer) )
		usr << "<span class='notice'>Something is there but you can't see it.</span>"
		return


	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\living\carbon\brain\posibrain.dm:86: var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n[desc]\n"
	var/msg = {"<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n[desc]\n
<span class='warning'>"}
	// END AUTOFIX
	if(src.brainmob && src.brainmob.key)
		switch(src.brainmob.stat)
			if(CONSCIOUS)
				if(!src.brainmob.client)	msg += "It appears to be in stand-by mode.\n" //afk
			if(UNCONSCIOUS)		msg += "<span class='warning'>It doesn't seem to be responsive.</span>\n"
			if(DEAD)			msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	else
		msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	msg += "<span class='info'>*---------*</span>"
	usr << msg
	return

/obj/item/device/mmi/posibrain/emp_act(severity)
	if(!src.brainmob)
		return
	else
		switch(severity)
			if(1)
				src.brainmob.emp_damage += rand(20,30)
			if(2)
				src.brainmob.emp_damage += rand(10,20)
			if(3)
				src.brainmob.emp_damage += rand(0,10)
	..()

/obj/item/device/mmi/posibrain/New()

	src.brainmob = new(src)
	src.brainmob.name = "[pick(list("PBU","HIU","SINA","ARMA","OSI"))]-[rand(100, 999)]"
	src.brainmob.real_name = src.brainmob.name
	src.brainmob.loc = src
	src.brainmob.container = src
	src.brainmob.robot_talk_understand = 0
	src.brainmob.stat = 0
	src.brainmob.silent = 0
	dead_mob_list -= src.brainmob

	..()

/obj/item/device/mmi/posibrain/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(try_handling_mommi_construction(O,user))
		return
	..()

/obj/item/device/mmi/posibrain/attack_ghost(var/mob/dead/observer/O)
	if(searching)
		volunteer(O)
	else
		var/turf/T = get_turf_or_move(src.loc)
		for (var/mob/M in viewers(T))
			M.show_message("\blue The positronic brain pings softly.")
