var/global/posibrain_notif_cooldown = 0

/obj/item/device/mmi/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "biotech=3;programming=3;plasmatech=2"
	var/notified = 0
	var/askDelay = 600 //one minute
	var/used = 0 //Prevents split personality virus. May be reset if personality deletion code is added.
	brainmob = null
	req_access = list(access_robotics)
	mecha = null//This does not appear to be used outside of reference in mecha.dm.
	braintype = "Android"
	var/autoping = TRUE //if it pings on creation immediately
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
	var/picked_fluff_name //which fluff name we picked


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
			addtimer(CALLBACK(src, .proc/reset_posibrain_cooldown), askDelay)

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
	if(C.has_dna())
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		C.dna.copy_dna(brainmob.stored_dna)
	brainmob.timeofhostdeath = C.timeofdeath
	brainmob.stat = CONSCIOUS
	if(brainmob.mind)
		brainmob.mind.assigned_role = new_role
	if(C.mind)
		C.mind.transfer_to(brainmob)

	brainmob.mind.remove_all_antag()
	brainmob.mind.wipe_memory()
	update_icon()

/obj/item/device/mmi/posibrain/proc/transfer_personality(mob/candidate)
	if(used || (brainmob && brainmob.key)) //Prevents hostile takeover if two ghosts get the prompt or link for the same brain.
		candidate << "This brain has already been taken! Please try your possesion again later!"
		return FALSE
	notified = 0
	if(candidate.mind && !isobserver(candidate))
		candidate.mind.transfer_to(brainmob)
	else
		brainmob.ckey = candidate.ckey
	name = "[initial(name)] ([brainmob.name])"
	brainmob << welcome_message
	brainmob.mind.assigned_role = new_role
	brainmob.stat = CONSCIOUS
	dead_mob_list -= brainmob
	living_mob_list += brainmob

	visible_message(new_mob_message)
	update_icon()
	used = 1
	return TRUE


/obj/item/device/mmi/posibrain/examine()

	set src in oview()

	if(!usr || !src)
		return
	if((usr.disabilities & BLIND || usr.stat) && !isobserver(usr))
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
	picked_fluff_name = pick(fluff_names)
	brainmob.name = "[picked_fluff_name]-[rand(100, 999)]"
	brainmob.real_name = brainmob.name
	brainmob.loc = src
	brainmob.container = src
	if(autoping)
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
