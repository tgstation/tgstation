var/global/posibrain_notif_cooldown = 0

/obj/item/device/mmi/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	w_class = 3
	origin_tech = "biotech=3;programming=2"
	var/notified = 0
	var/askDelay = 10 * 60 * 1
	brainmob = null
	req_access = list(access_robotics)
	mecha = null//This does not appear to be used outside of reference in mecha.dm.
	braintype = "Android"

/obj/item/device/mmi/posibrain/Topic(href, href_list)
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			activate(ghost)

/obj/item/device/mmi/posibrain/proc/ping_ghosts(msg)
	if(!posibrain_notif_cooldown)
		notify_ghosts("Positronic brain [msg] in [get_area(src)]! <a href=?src=\ref[src];activate=1>(Click to enter)</a>", 'sound/effects/ghost2.ogg')
		posibrain_notif_cooldown = 1
		spawn(askDelay) //Global one minute cooldown to avoid spam.
			posibrain_notif_cooldown = 0

/obj/item/device/mmi/posibrain/attack_self(mob/user)
	if(brainmob && !brainmob.key && !notified)
		//Start the process of notified for a new user.
		user << "<span class='notice'>You carefully locate the manual activation switch and start the positronic brain's boot process.</span>"
		ping_ghosts("requested")
		notified = 1
		update_icon()
		spawn(askDelay) //Seperate from the global cooldown.
			notified = 0
			update_icon()
			visible_message("<span class='notice'>The positronic brain buzzes quietly, and the golden lights fade away. Perhaps you could try again?</span>")

	return //Code for deleting personalities recommended here.


/obj/item/device/mmi/posibrain/attack_ghost(mob/user)
	activate(user)

//Two ways to activate a positronic brain. A clickable link in the ghost notif, or simply clicking the object itself.
/obj/item/device/mmi/posibrain/proc/activate(mob/user)
	if((brainmob && brainmob.key) || jobban_isbanned(user,"posibrain"))
		return

	var/posi_ask = alert("Become a positronic brain? (Warning, You can no longer be cloned, and all past lives will be forgotten!)","Are you positive?","Yes","No")
	if(posi_ask == "No" || gc_destroyed)
		return
	transfer_personality(user)

/obj/item/device/mmi/posibrain/transfer_identity(mob/living/carbon/H)
	name = "positronic brain ([H])"
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna
	brainmob.timeofhostdeath = H.timeofdeath
	brainmob.stat = 0
	if(brainmob.mind)
		brainmob.mind.assigned_role = "Positronic Brain"
	if(H.mind)
		H.mind.transfer_to(brainmob)

	brainmob.mind.remove_all_antag()
	brainmob.mind.wipe_memory()

	brainmob << "<span class='warning'>ALL PAST LIVES ARE FORGOTTEN.</span>"

	brainmob << "<span class='notice'>Hello World!</span>"
	update_icon()
	return

/obj/item/device/mmi/posibrain/proc/transfer_personality(mob/candidate)
	if(brainmob && brainmob.key) //Prevents hostile takeover if two ghosts get the prompt or link for the same brain.
		candidate << "This brain has already been taken! Please try your possesion again later!"
		return
	notified = 0
	brainmob.ckey = candidate.ckey
	name = "positronic brain ([brainmob.name])"

	brainmob << "<span class='warning'>ALL PAST LIVES ARE FORGOTTEN.</span>"

	brainmob << "<b>You are a positronic brain, brought into existence on [station_name()].</b>"
	brainmob << "<b>As a synthetic intelligence, you answer to all crewmembers, as well as the AI.</b>"
	brainmob << "<b>Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>"
	brainmob.mind.assigned_role = "Positronic Brain"

	visible_message("<span class='notice'>The positronic brain chimes quietly.</span>")
	update_icon()


/obj/item/device/mmi/posibrain/examine()

	set src in oview()

	if(!usr || !src)	return
	if( (usr.disabilities & BLIND || usr.stat) && !istype(usr,/mob/dead/observer) )
		usr << "<span class='notice'>Something is there but you can't see it.</span>"
		return

	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n[desc]\n"
	msg += "<span class='warning'>"

	if(brainmob && brainmob.key)
		switch(brainmob.stat)
			if(CONSCIOUS)
				if(!src.brainmob.client)	msg += "It appears to be in stand-by mode.\n" //afk
			if(UNCONSCIOUS)		msg += "<span class='warning'>It doesn't seem to be responsive.</span>\n"
			if(DEAD)			msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	else
		msg += "<span class='deadsay'>It appears to be completely inactive.</span>\n"
	msg += "<span class='info'>*---------*</span>"
	usr << msg
	return

/obj/item/device/mmi/posibrain/New()

	brainmob = new(src)
	brainmob.name = "[pick(list("PBU","HIU","SINA","ARMA","OSI","HBL","MSO","RR"))]-[rand(100, 999)]"
	brainmob.real_name = brainmob.name
	brainmob.loc = src
	brainmob.container = src
	brainmob.stat = 0
	brainmob.silent = 0
	dead_mob_list -= brainmob
	ping_ghosts("created")

	..()


/obj/item/device/mmi/posibrain/attackby(obj/item/O, mob/user)
	return


/obj/item/device/mmi/posibrain/update_icon()
	if(notified)
		icon_state = "posibrain-searching"
		return
	if(brainmob && brainmob.key)
		icon_state = "posibrain-occupied"
	else
		icon_state = "posibrain"
