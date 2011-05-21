/mob/living/silicon/ai/New(loc, var/datum/ai_laws/L, var/obj/item/device/mmi/B, var/safety = 0)
	PickName
	name = pick(ai_names)
	for (var/mob/living/silicon/ai/A in world)
		if (A.real_name == name)
			goto PickName//It'll get stuck in an infinite loop if all default names are chosen but that's... a remote possibility.
	real_name = name
	anchored = 1
	canmove = 0
	loc = loc

	proc_holder_list = new()

	if(L)
		if (istype(L, /datum/ai_laws))
			laws_object = L
	else
		laws_object = new /datum/ai_laws/asimov

	verbs += /mob/living/silicon/ai/proc/show_laws_verb

	if (istype(loc, /turf))
		verbs += /mob/living/silicon/ai/proc/ai_call_shuttle
		verbs += /mob/living/silicon/ai/proc/ai_camera_track
		verbs += /mob/living/silicon/ai/proc/ai_camera_list
		//Added ai_network_change by Mord_Sith
		verbs += /mob/living/silicon/ai/proc/ai_network_change
		verbs += /mob/living/silicon/ai/proc/lockdown
		verbs += /mob/living/silicon/ai/proc/disablelockdown
		verbs += /mob/living/silicon/ai/proc/ai_statuschange
	if(!safety)//Only used by AIize() to successfully spawn an AI.
		if (!B)//If there is no player/brain inside.
			new/obj/AIcore/deactivated(loc)//New empty terminal.
			del(src)//Delete AI.
			return
		else
			if (B.brainmob.mind)
				B.brainmob.mind.transfer_to(src)

			src << "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>"
			src << "<B>To look at other parts of the station, double-click yourself to get a camera menu.</B>"
			src << "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>"
			src << "To use something, simply double-click it."
			src << "Currently right-click functions will not work for the AI (except examine), and will either be replaced with dialogs or won't be usable by the AI."

			show_laws()
			src << "<b>These laws may be changed by other players, or by you being the traitor.</b>"

			job = "AI"

			spawn(0)
				ainame(src)

/mob/living/silicon/ai/Stat()
	..()
	statpanel("Status")
	if (client.statpanel == "Status")
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

		if(ticker.mode.name == "AI malfunction")
			var/datum/game_mode/malfunction/malf = ticker.mode
			for (var/datum/mind/malfai in malf.malf_ai)
				if (mind == malfai)
					if (malf.apcs >= 3)
						stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/(malf.apcs/3), 0)] seconds")

		if(!stat)
			stat(null, text("System integrity: [(health+100)/2]%"))
		else
			stat(null, text("Systems nonfunctional"))

	if (proc_holder_list.len)//Generic list for proc_holder objects.
		for(var/obj/proc_holder/P in proc_holder_list)
			statpanel("[P.panel]","",P)

/mob/living/silicon/ai/proc/ai_alerts()
	set category = "AI Commands"
	set name = "Show Alerts"

	var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A HREF='?src=\ref[src];mach_close=aialerts'>Close</A><BR><BR>"
	for (var/cat in alarms)
		dat += text("<B>[]</B><BR>\n", cat)
		var/list/L = alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/C = alm[2]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				if (C && istype(C, /list))
					var/dat2 = ""
					for (var/obj/machinery/camera/I in C)
						dat2 += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (dat2=="") ? "" : " | ", src, I, I.c_tag)
					dat += text("-- [] ([])", A.name, (dat2!="") ? dat2 : "No Camera")
				else if (C && istype(C, /obj/machinery/camera))
					var/obj/machinery/camera/Ctmp = C
					dat += text("-- [] (<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>)", A.name, src, C, Ctmp.c_tag)
				else
					dat += text("-- [] (No Camera)", A.name)
				if (sources.len > 1)
					dat += text("- [] sources", sources.len)
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	viewalerts = 1
	src << browse(dat, "window=aialerts&can_close=0")

/mob/living/silicon/ai/proc/ai_roster()
	set category = "AI Commands"
	set name = "Show Crew Manifest"

	var/dat = "<html><head><title>Crew Roster</title></head><body><b>Crew Roster:</b><br><br>"

	for (var/datum/data/record/t in data_core.general)
		dat += "[t.fields["name"]] - [t.fields["rank"]]<br>"

	dat += "</body></html>"

	src << browse(dat, "window=airoster")
	onclose(src, "airoster")

/mob/living/silicon/ai/proc/ai_cancel_call()
	set category = "AI Commands"
	if(usr.stat == 2)
		usr << "You can't send the shuttle back because you are dead!"
		return
	cancel_call_proc(src)
	return

/mob/living/silicon/ai/check_eye(var/mob/user as mob)
	if (!current)
		return null
	user.reset_view(current)
	return 1

/mob/living/silicon/ai/blob_act()
	if (stat != 2)
		bruteloss += 60
		updatehealth()
		return 1
	return 0

/mob/living/silicon/ai/restrained()
	return 0

/mob/living/silicon/ai/emp_act(severity)
	if (prob(30))
		switch(pick(1,2,3)) //Add Random laws.
			if(1)
				cancel_camera()
			if(2)
				lockdown()
			if(3)
				ai_call_shuttle()
	..()

/mob/living/silicon/ai/ex_act(severity)
	flick("flash", flash)

	var/b_loss = bruteloss
	var/f_loss = fireloss
	switch(severity)
		if(1.0)
			if (stat != 2)
				b_loss += 100
				f_loss += 100
		if(2.0)
			if (stat != 2)
				b_loss += 60
				f_loss += 60
		if(3.0)
			if (stat != 2)
				b_loss += 30
	bruteloss = b_loss
	fireloss = f_loss
	updatehealth()


/mob/living/silicon/ai/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		if (href_list["mach_close"] == "aialerts")
			viewalerts = 0
		var/t1 = text("window=[]", href_list["mach_close"])
		machine = null
		src << browse(null, t1)
	if (href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"]))
	if (href_list["showalerts"])
		ai_alerts()


	if (href_list["lawc"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawc"])
		switch(lawcheck[L+1])
			if ("Yes") lawcheck[L+1] = "No"
			if ("No") lawcheck[L+1] = "Yes"
//		src << text ("Switching Law [L]'s report status to []", lawcheck[L+1])
		checklaws()

	if (href_list["lawi"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawi"])
		switch(ioncheck[L])
			if ("Yes") ioncheck[L] = "No"
			if ("No") ioncheck[L] = "Yes"
//		src << text ("Switching Law [L]'s report status to []", lawcheck[L+1])
		checklaws()

	if (href_list["laws"]) // With how my law selection code works, I changed statelaws from a verb to a proc, and call it through my law selection panel. --NeoFite
		statelaws()

	return

/mob/living/silicon/ai/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [] has been hit by []", src, O), 1)
		//Foreach goto(19)
	if (health > 0)
		bruteloss += 30
		if ((O.icon_state == "flaming"))
			fireloss += 40
		updatehealth()
	return

/mob/living/silicon/ai/bullet_act(flag)
	if (flag == PROJECTILE_BULLET)
		if (stat != 2)
			bruteloss += 60
			updatehealth()
			weakened = 10
	else if (flag == PROJECTILE_TASER)
		if (prob(75))
			stunned = 15
		else
			weakened = 15
	else if (flag == PROJECTILE_DART)
		return
	else if(flag == PROJECTILE_LASER)
		if (stat != 2)
			bruteloss += 20
			updatehealth()
			if (prob(25))
				stunned = 1
	else if(flag == PROJECTILE_PULSE)
		if (stat != 2)
			bruteloss += 40
			updatehealth()
			if (prob(50))
				stunned = min(5, stunned)
	return

/mob/living/silicon/ai/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	switch(M.a_intent)

		if ("help")
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\blue [M] caresses [src]'s plating with its scythe like arm."), 1)

		else //harm
			var/damage = rand(10, 20)
			if (prob(90))
				playsound(loc, 'slash.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has slashed at []!</B>", M, src), 1)
				if(prob(8))
					flick("noise", flash)
				bruteloss += damage
				updatehealth()
			else
				playsound(loc, 'slashmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] took a swipe at []!</B>", M, src), 1)
	return

/mob/living/silicon/ai/attack_hand(mob/living/carbon/M as mob)
	if(ishuman(M))//Checks to see if they are ninja
		if(istype(M:gloves, /obj/item/clothing/gloves/space_ninja)&&M:gloves:candrain&&!M:gloves:draining)
			if(M:wear_suit:control)
				M:wear_suit:transfer_ai("AICORE", "NINJASUIT", src, M)
			else
				M << "\red <b>ERROR</b>: \black Remote access channel disabled."
	return

/mob/living/silicon/ai/proc/switchCamera(var/obj/machinery/camera/C)
	usr:cameraFollow = null
	if (!C)
		machine = null
		reset_view(null)
		return 0
	if (stat == 2 || !C.status || C.network != network) return 0

	// ok, we're alive, camera is good and in our network...

	machine = src
	src:current = C
	reset_view(C)
	return 1

/mob/living/silicon/ai/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if (stat == 2)
		return 1
	var/list/L = alarms[class]
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(alarmsource in sources))
				sources += alarmsource
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if (O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	if (O)
		if (C && C.status)
			src << text("--- [] alarm detected in []! (<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>)", class, A.name, src, C, C.c_tag)
		else if (CL && CL.len)
			var/foo = 0
			var/dat2 = ""
			for (var/obj/machinery/camera/I in CL)
				dat2 += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (!foo) ? "" : " | ", src, I, I.c_tag)
				foo = 1
			src << text ("--- [] alarm detected in []! ([])", class, A.name, dat2)
		else
			src << text("--- [] alarm detected in []! (No Camera)", class, A.name)
	else
		src << text("--- [] alarm detected in []! (No Camera)", class, A.name)
	if (viewalerts) ai_alerts()
	return 1

/mob/living/silicon/ai/cancelAlarm(var/class, area/A as area, obj/origin)
	var/list/L = alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	if (cleared)
		src << text("--- [] alarm in [] has been cleared.", class, A.name)
		if (viewalerts) ai_alerts()
	return !cleared

/mob/living/silicon/ai/cancel_camera()
	set category = "AI Commands"
	set name = "Cancel Camera View"
	reset_view(null)
	machine = null
	src:cameraFollow = null

//Replaces /mob/living/silicon/ai/verb/change_network() in ai.dm & camera.dm
//Adds in /mob/living/silicon/ai/proc/ai_network_change() instead
//Addition by Mord_Sith to define AI's network change ability
/mob/living/silicon/ai/proc/ai_network_change()
	set category = "AI Commands"
	set name = "Change Camera Network"
	reset_view(null)
	machine = null
	src:cameraFollow = null
	var/cameralist[0]

	if(usr.stat == 2)
		usr << "You can't change your camera network because you are dead!"
		return

	for (var/obj/machinery/camera/C in world)
		if(!C.status)
			continue
		if(C.network == "AI Satellite")
			if (ticker.mode.name == "AI malfunction")
				var/datum/game_mode/malfunction/malf = ticker.mode
				for (var/datum/mind/M in malf.malf_ai)
					if (mind == M)
						cameralist[C.network] = C.network
		else
			if(C.network != "CREED" && C.network != "thunder" && C.network != "RD" && C.network != "toxins" && C.network != "Prison")
				cameralist[C.network] = C.network

	network = input(usr, "Which network would you like to view?") as null|anything in cameralist
	src << "\blue Switched to [network] camera network."
//End of code by Mord_Sith


/mob/living/silicon/ai/proc/choose_modules()
	set category = "Malfunction"
	set name = "Choose Module"

	malf_picker.use(src)





