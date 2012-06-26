//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:05
#define STATE_DEFAULT 1
#define STATE_INJECTOR  2
#define STATE_ENGINE 3


/obj/machinery/computer/am_engine
	name = "Antimatter Engine Console"
	icon = 'stationobjs.dmi'
	icon_state = "comm_computer"
	req_access = list(ACCESS_ENGINE)
	var/engine_id = 0
	var/authenticated = 0
	var/obj/machinery/power/am_engine/engine/connected_E = null
	var/obj/machinery/power/am_engine/injector/connected_I = null
	var/state = STATE_DEFAULT

/obj/machinery/computer/am_engine/New()
	..()
	spawn( 24 )
		for(var/obj/machinery/power/am_engine/engine/E in world)
			if(E.engine_id == src.engine_id)
				src.connected_E = E
		for(var/obj/machinery/power/am_engine/injector/I in world)
			if(I.engine_id == src.engine_id)
				src.connected_I = I
	return

/obj/machinery/computer/am_engine/Topic(href, href_list)
	if(..())
		return
	usr.machine = src

	if(!href_list["operation"])
		return
	switch(href_list["operation"])
		// main interface
		if("activate")
			src.connected_E.engine_process()
		if("engine")
			src.state = STATE_ENGINE
		if("injector")
			src.state = STATE_INJECTOR
		if("main")
			src.state = STATE_DEFAULT
		if("login")
			var/mob/M = usr
			var/obj/item/weapon/card/id/I = M.equipped()
			if (I && istype(I))
				if(src.check_access(I))
					authenticated = 1
		if("deactivate")
			src.connected_E.stopping = 1
		if("logout")
			authenticated = 0

	src.updateUsrDialog()

/obj/machinery/computer/am_engine/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/am_engine/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/am_engine/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.machine = src
	var/dat = "<head><title>Engine Computer</title></head><body>"
	switch(src.state)
		if(STATE_DEFAULT)
			if (src.authenticated)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=logout'>Log Out</A> \]<br>"
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=engine'>Engine Menu</A> \]"
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=injector'>Injector Menu</A> \]"
			else
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=login'>Log In</A> \]"
		if(STATE_INJECTOR)
			if(src.connected_I.injecting)
				dat += "<BR>\[ Injecting \]<br>"
			else
				dat += "<BR>\[ Injecting not in progress \]<br>"
		if(STATE_ENGINE)
			if(src.connected_E.stopping)
				dat += "<BR>\[ STOPPING \]"
			else if(src.connected_E.operating && !src.connected_E.stopping)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=deactivate'>Emergency Stop</A> \]"
			else
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=activate'>Activate Engine</A> \]"
			dat += "<BR>Contents:<br>[src.connected_E.H_fuel]kg of Hydrogen<br>[src.connected_E.antiH_fuel]kg of Anti-Hydrogen<br>"

	dat += "<BR>\[ [(src.state != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
	user << browse(dat, "window=communications;size=400x500")
	onclose(user, "communications")

