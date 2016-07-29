<<<<<<< HEAD
var/global/posibrain_notif_cooldown = 0

=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/obj/item/device/mmi/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
<<<<<<< HEAD
	w_class = 3
	origin_tech = "biotech=3;programming=3;plasmatech=2"
	var/notified = 0
	var/askDelay = 600 //one minute
	var/used = 0 //Prevents split personality virus. May be reset if personality deletion code is added.
	brainmob = null
	req_access = list(access_robotics)
	mecha = null//This does not appear to be used outside of reference in mecha.dm.
	braintype = "Android"
	var/begin_activation_message = "<span class='notice'>You carefully locate the manual activation switch and start the positronic brain's boot process.</span>"
	var/success_message = "<span class='notice'>The positronic brain pings, and its lights start flashing. Success!</span>"
	var/fail_message = "<span class='notice'>The positronic brain buzzes quietly, and the golden lights fade away. Perhaps you could try again?</span>"
	var/new_role = "Positronic Brain"
	var/welcome_message = "<span class='warning'>ALL PAST LIVES ARE FORGOTTEN.</span>\n\
	<b>You are a positronic brain, brought into existence aboard Space Station 13.\n\
	As a synthetic intelligence, you answer to all crewmembers and the AI.\n\
	Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>"
	var/new_mob_message = "<span class='notice'>The positronic brain chimes quietly.</span>"
	var/dead_message = "<span class='deadsay'>It appears to be completely inactive. The reset light is blinking.</span>"
	var/list/fluff_names = list("PBU","HIU","SINA","ARMA","OSI","HBL","MSO","RR","CHRI","CDB","HG","XSI","ORNG","GUN","KOR","MET","FRE","XIS","SLI","PKP","HOG","RZH","GOOF","MRPR","JJR","FIRC","INC","PHL","BGB","ANTR","MIW","WJ","JRD","CHOC","ANCL","JLLO","JNLG","KOS","TKRG","XAL","STLP","CBOS","DUNC","FXMC","DRSD")


/obj/item/device/mmi/posibrain/Topic(href, href_list)
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			activate(ghost)

/obj/item/device/mmi/posibrain/proc/ping_ghosts(msg, newlymade)
	if(newlymade || !posibrain_notif_cooldown)
		notify_ghosts("[name] [msg] in [get_area(src)]!", ghost_sound = !newlymade ? 'sound/effects/ghost2.ogg':null, enter_link = "<a href=?src=\ref[src];activate=1>(Click to enter)</a>", source = src, action = NOTIFY_ATTACK)
		if(!newlymade)
			posibrain_notif_cooldown = 1
			addtimer(src, "reset_posibrain_cooldown", askDelay, FALSE)

/obj/item/device/mmi/posibrain/proc/reset_posibrain_cooldown()
	posibrain_notif_cooldown = 0

/obj/item/device/mmi/posibrain/attack_self(mob/user)
	if(brainmob && !brainmob.key && !notified)
		//Start the process of requesting a new ghost.
		user << begin_activation_message
		ping_ghosts("requested", FALSE)
		notified = 1
		used = 0
		update_icon()
		spawn(askDelay) //Seperate from the global cooldown.
			notified = 0
			update_icon()
			if(brainmob.client)
				visible_message(success_message)
			else
				visible_message(fail_message)

	return //Code for deleting personalities recommended here.


/obj/item/device/mmi/posibrain/attack_ghost(mob/user)
	activate(user)

//Two ways to activate a positronic brain. A clickable link in the ghost notif, or simply clicking the object itself.
/obj/item/device/mmi/posibrain/proc/activate(mob/user)
	if(used || (brainmob && brainmob.key) || jobban_isbanned(user,"posibrain"))
		return

	var/posi_ask = alert("Become a [name]? (Warning, You can no longer be cloned, and all past lives will be forgotten!)","Are you positive?","Yes","No")
	if(posi_ask == "No" || qdeleted(src))
		return
	transfer_personality(user)

/obj/item/device/mmi/posibrain/transfer_identity(mob/living/carbon/C)
	name = "[initial(name)] ([C])"
	brainmob.name = C.real_name
	brainmob.real_name = C.real_name
	brainmob.dna = C.dna
	if(C.has_dna())
		if(!brainmob.dna)
			brainmob.dna = new /datum/dna(brainmob)
		C.dna.copy_dna(brainmob.dna)
	brainmob.timeofhostdeath = C.timeofdeath
	brainmob.stat = CONSCIOUS
	if(brainmob.mind)
		brainmob.mind.assigned_role = new_role
	if(C.mind)
		C.mind.transfer_to(brainmob)

	brainmob.mind.remove_all_antag()
	brainmob.mind.wipe_memory()
	update_icon()
	return

/obj/item/device/mmi/posibrain/proc/transfer_personality(mob/candidate)
	if(used || (brainmob && brainmob.key)) //Prevents hostile takeover if two ghosts get the prompt or link for the same brain.
		candidate << "This brain has already been taken! Please try your possesion again later!"
		return
	notified = 0
	brainmob.ckey = candidate.ckey
	name = "[initial(name)] ([brainmob.name])"
	brainmob << welcome_message
	brainmob.mind.assigned_role = new_role
	brainmob.stat = CONSCIOUS
	dead_mob_list -= brainmob
	living_mob_list += brainmob
	if(clockwork)
		add_servant_of_ratvar(brainmob, TRUE)

	visible_message(new_mob_message)
	update_icon()
	used = 1


/obj/item/device/mmi/posibrain/examine()

	set src in oview()

	if(!usr || !src)
		return
	if( (usr.disabilities & BLIND || usr.stat) && !istype(usr,/mob/dead/observer) )
		usr << "<span class='notice'>Something is there but you can't see it.</span>"
		return

	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n[desc]\n"
	msg += "<span class='warning'>"

	if(brainmob && brainmob.key)
		switch(brainmob.stat)
			if(CONSCIOUS)
				if(!src.brainmob.client)
					msg += "It appears to be in stand-by mode.\n" //afk
			if(DEAD)
				msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	else
		msg += "[dead_message]\n"
	msg += "<span class='info'>*---------*</span>"
	usr << msg
	return

/obj/item/device/mmi/posibrain/New()
	brainmob = new(src)
	brainmob.name = "[pick(fluff_names)]-[rand(100, 999)]"
	brainmob.real_name = brainmob.name
	brainmob.loc = src
	brainmob.container = src
	ping_ghosts("created", TRUE)
	..()


/obj/item/device/mmi/posibrain/attackby(obj/item/O, mob/user)
	return


/obj/item/device/mmi/posibrain/update_icon()
	if(notified)
		icon_state = "[initial(icon_state)]-searching"
		return
	if(brainmob && brainmob.key)
		icon_state = "[initial(icon_state)]-occupied"
	else
		icon_state = initial(icon_state)
=======
	w_class = W_CLASS_MEDIUM
	origin_tech = "engineering=4;materials=4;bluespace=2;programming=4"

	var/searching = 0
	var/askDelay = 10 * 60 * 1
	//var/mob/living/carbon/brain/brainmob = null
	var/list/ghost_volunteers[0]
	req_access = list(access_robotics)
	locked = 2
	mecha = null//This does not appear to be used outside of reference in mecha.dm.

#ifdef DEBUG_ROLESELECT
/obj/item/device/mmi/posibrain/test/New()
	..()
	search_for_candidates()
#endif

/obj/item/device/mmi/posibrain/attack_self(mob/user as mob)
	if(brainmob && !brainmob.key && searching == 0)
		//Start the process of searching for a new user.
		to_chat(user, "<span class='notice'>You carefully locate the manual activation switch and start \the [src]'s boot process.</span>")
		search_for_candidates()

/obj/item/device/mmi/posibrain/proc/search_for_candidates()
	icon_state = "posibrain-searching"
	ghost_volunteers.len = 0
	src.searching = 1
	src.request_player()
	spawn(600)
		if(ghost_volunteers.len)
			var/mob/dead/observer/O = pick(ghost_volunteers)
			if(istype(O) && O.client && O.key)
				transfer_personality(O)
		reset_search()

/obj/item/device/mmi/posibrain/proc/request_player()
	for(var/mob/dead/observer/O in get_active_candidates(ROLE_POSIBRAIN))
		if(O.client)
			if(check_observer(O))
				to_chat(O, "<span class=\"recruit\">You are a possible candidate for \a [src]. Get ready. (<a href='?src=\ref[O];jump=\ref[src]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Retract</a>)</span>")
				ghost_volunteers += O

/obj/item/device/mmi/posibrain/proc/check_observer(var/mob/dead/observer/O)
	if(O.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
		return 0
	if(jobban_isbanned(O, ROLE_POSIBRAIN)) // Was pAI
		return 0
	if(O.client)
		return 1
	return 0

/obj/item/device/mmi/posibrain/proc/question(var/client/C)
	spawn(0)
		if(!C)	return
		var/response = alert(C, "Someone is requesting a personality for \a [src]. Would you like to play as one?", "[src] request", "Yes", "No", "Never for this round")
		if(!C || brainmob.key || 0 == searching)	return		//handle logouts that happen whilst the alert is waiting for a response, and responses issued after a brain has been located.
		if(response == "Yes")
			transfer_personality(C.mob)

/obj/item/device/mmi/posibrain/proc/transfer_personality(var/mob/candidate)


	src.searching = 0
	//src.brainmob.mind = candidate.mind Causes issues with traitor overlays and traitor specific chat.
	//src.brainmob.key = candidate.key
	src.brainmob.ckey = candidate.ckey
	src.brainmob.stat = 0
	src.name = "positronic brain ([src.brainmob.name])"

	to_chat(src.brainmob, "<b>You are \a [src], brought into existence on [station_name()].</b>")
	to_chat(src.brainmob, "<b>As a synthetic intelligence, you answer to all crewmembers, as well as the AI.</b>")
	to_chat(src.brainmob, "<b>Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>")
	src.brainmob.mind.assigned_role = "Positronic Brain"

	var/turf/T = get_turf(src.loc)
	for (var/mob/M in viewers(T))
		M.show_message("<span class='notice'>\The [src] chimes quietly.</span>")
	icon_state = "posibrain-occupied"

/obj/item/device/mmi/posibrain/proc/reset_search() //We give the players sixty seconds to decide, then reset the timer.


	if(src.brainmob && src.brainmob.key) return

	src.searching = 0
	icon_state = "posibrain"

	var/turf/T = get_turf(src.loc)
	for (var/mob/M in viewers(T))
		M.show_message("<span class='notice'>The [src] buzzes quietly, and the golden lights fade away. Perhaps you could try again?</span>")

/obj/item/device/mmi/posibrain/Topic(href,href_list)
	if("signup" in href_list)
		var/mob/dead/observer/O = locate(href_list["signup"])
		if(!O) return
		volunteer(O)

/obj/item/device/mmi/posibrain/proc/volunteer(var/mob/dead/observer/O)
	if(!searching)
		to_chat(O, "Not looking for a ghost, yet.")
		return
	if(!istype(O))
		to_chat(O, "<span class='warning'>NO.</span>")
		return
	if(O in ghost_volunteers)
		to_chat(O, "<span class='notice'>Removed from registration list.</span>")
		ghost_volunteers.Remove(O)
		return
	if(!check_observer(O))
		to_chat(O, "<span class='warning'>You cannot be \a [src].</span>")
		return
	to_chat(O., "<span class='notice'>You've been added to the list of ghosts that may become this [src].  Click again to unvolunteer.</span>")
	ghost_volunteers.Add(O)

/obj/item/device/mmi/posibrain/examine(mob/user)
//	to_chat(user, "<span class='info'>*---------</span>*")
	..()
	if(src.brainmob)
		if(src.brainmob.stat == DEAD)
			to_chat(user, "<span class='deadsay'>It appears to be completely inactive.</span>")//suicided

		else if(!src.brainmob.client)
			to_chat(user, "<span class='notice'>It appears to be in stand-by mode.</span>")//closed game window

		else if(!src.brainmob.key)
			to_chat(user, "<span class='warning'>It doesn't seem to be responsive.</span>")//ghosted

//	to_chat(user, "<span class='info'>*---------*</span>")

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
		var/turf/T = get_turf(src.loc)
		for (var/mob/M in viewers(T))
			M.show_message("<span class='notice'>\The [src] pings softly.</span>")

/obj/item/device/mmi/posibrain/OnMobDeath(var/mob/living/carbon/brain/B)
	visible_message(message = "<span class='danger'>[B] begins to go dark, having seemingly thought himself to death</span>", blind_message = "<span class='danger'>You hear the wistful sigh of a hopeful machine powering off with a tone of finality.<span>")
	icon_state = "posibrain"
	searching = 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
