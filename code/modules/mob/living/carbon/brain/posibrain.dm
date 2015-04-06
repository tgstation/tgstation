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
		user << "<span class='notice'>You carefully locate the manual activation switch and start \the [src]'s boot process.</span>"
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
				O << "<span class=\"recruit\">You are a possible candidate for \a [src]. Get ready. (<a href='?src=\ref[O];jump=\ref[src]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Retract</a>)</span>"
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

	src.brainmob << "<b>You are \a [src], brought into existence on [station_name()].</b>"
	src.brainmob << "<b>As a synthetic intelligence, you answer to all crewmembers, as well as the AI.</b>"
	src.brainmob << "<b>Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>"
	src.brainmob << "<b>Use say :b to speak to other artificial intelligences.</b>"
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
		O << "Not looking for a ghost, yet."
		return
	if(!istype(O))
		O << "<span class='warning'>NO.</span>"
		return
	if(O in ghost_volunteers)
		O << "<span class='notice'>Removed from registration list.</span>"
		ghost_volunteers.Remove(O)
		return
	if(!check_observer(O))
		O << "<span class='warning'>You cannot be \a [src].</span>"
		return
	O.<< "<span class='notice'>You've been added to the list of ghosts that may become this [src].  Click again to unvolunteer.</span>"
	ghost_volunteers.Add(O)

/obj/item/device/mmi/posibrain/examine(mob/user)
//	user << "<span class='info'>*---------</span>*"
	..()
	if(src.brainmob)
		if(src.brainmob.stat == DEAD)
			user << "<span class='deadsay'>It appears to be completely inactive.</span>" //suicided
		else if(!src.brainmob.client)
			user << "<span class='notice'>It appears to be in stand-by mode.</span>" //closed game window
		else if(!src.brainmob.key)
			user << "<span class='warning'>It doesn't seem to be responsive.</span>" //ghosted
//	user << "<span class='info'>*---------*</span>"

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
