/obj/item/device/mmi/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	w_class = 3
	origin_tech = "biotech=3;programming=2"
	var/searching = 0
	var/askDelay = 10 * 60 * 1
	brainmob = null
	req_access = list(access_robotics)
	locked = 0
	mecha = null//This does not appear to be used outside of reference in mecha.dm.
	braintype = "Android"


/obj/item/device/mmi/posibrain/attack_self(mob/user as mob)
	return //Code for deleting personalities recommended here.


/obj/item/device/mmi/posibrain/attack_ghost(mob/user)
	if((brainmob && brainmob.key) || jobban_isbanned(user,"posibrain"))
		return

	var/posi_ask = alert("Become a positronic brain? (Warning, You can no longer be cloned, and all past lives will be forgotten!)","Are you positive?","Yes","No")
	if(posi_ask == "No" || gc_destroyed)
		return
	transfer_personality(user)

/obj/item/device/mmi/posibrain/transfer_identity(var/mob/living/carbon/H)
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

/obj/item/device/mmi/posibrain/proc/transfer_personality(var/mob/candidate)

	searching = 0
	brainmob.mind = candidate.mind
	brainmob.ckey = candidate.ckey
	name = "positronic brain ([brainmob.name])"

	brainmob.mind.remove_all_antag()
	brainmob.mind.wipe_memory()

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
	notify_ghosts("Positronic Brain created in [get_area(src)].")

	..()


/obj/item/device/mmi/posibrain/attackby(var/obj/item/O as obj, var/mob/user as mob)
	return


/obj/item/device/mmi/posibrain/update_icon()
	if(brainmob && brainmob.key)
		icon_state = "posibrain-occupied"
	else
		icon_state = "posibrain"
