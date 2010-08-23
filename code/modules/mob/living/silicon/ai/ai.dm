/mob/living/silicon/ai/proc/ai_alerts()
	set category = "AI Commands"
	set name = "Show Alerts"

	var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A HREF='?src=\ref[src];mach_close=aialerts'>Close</A><BR><BR>"
	for (var/cat in src.alarms)
		dat += text("<B>[]</B><BR>\n", cat)
		var/list/L = src.alarms[cat]
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

	src.viewalerts = 1
	src << browse(dat, "window=aialerts&can_close=0")

/mob/living/silicon/ai/proc/ai_cancel_call()
	set category = "AI Commands"
	if(usr.stat == 2)
		usr << "You can't send the shuttle back because you are dead!"
		return
	cancel_call_proc(src)
	return

/mob/living/silicon/ai/check_eye(var/mob/user as mob)
	if (!src.current)
		return null
	user.reset_view(src.current)
	return 1

/mob/living/silicon/ai/blob_act()
	if (src.stat != 2)
		src.bruteloss += 30
		src.updatehealth()
		return 1
	return 0

/mob/living/silicon/ai/restrained()
	return 0

/mob/living/silicon/ai/ex_act(severity)
	flick("flash", src.flash)

	var/b_loss = src.bruteloss
	var/f_loss = src.fireloss
	switch(severity)
		if(1.0)
			if (src.stat != 2)
				b_loss += 100
				f_loss += 100
		if(2.0)
			if (src.stat != 2)
				b_loss += 60
				f_loss += 60
		if(3.0)
			if (src.stat != 2)
				b_loss += 30
	src.bruteloss = b_loss
	src.fireloss = f_loss
	src.updatehealth()


/mob/living/silicon/ai/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		if (href_list["mach_close"] == "aialerts")
			src.viewalerts = 0
		var/t1 = text("window=[]", href_list["mach_close"])
		src.machine = null
		src << browse(null, t1)
	if (href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"]))
	if (href_list["showalerts"])
		ai_alerts()
	return

/mob/living/silicon/ai/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [] has been hit by []", src, O), 1)
		//Foreach goto(19)
	if (src.health > 0)
		src.bruteloss += 30
		if ((O.icon_state == "flaming"))
			src.fireloss += 40
		src.updatehealth()
	return

/mob/living/silicon/ai/bullet_act(flag)
	if (flag == PROJECTILE_BULLET)
		if (src.stat != 2)
			src.bruteloss += 60
			src.updatehealth()
			src.weakened = 10
	else if (flag == PROJECTILE_TASER)
		if (prob(75))
			src.stunned = 15
		else
			src.weakened = 15
	else if(flag == PROJECTILE_LASER)
		if (src.stat != 2)
			src.bruteloss += 20
			src.updatehealth()
			if (prob(25))
				src.stunned = 1
	else if(flag == PROJECTILE_PULSE)
		if (src.stat != 2)
			src.bruteloss += 40
			src.updatehealth()
			if (prob(50))
				src.stunned = min(5, src.stunned)
	return

/mob/living/silicon/ai/proc/show_laws_verb()
	set category = "AI Commands"
	set name = "Show Laws"
	src.show_laws()

/mob/living/silicon/ai/show_laws(var/everyone = 0)
	var/who

	if (everyone)
		who = world
	else
		who = src
		who << "<b>Obey these laws:</b>"

	src.laws_sanity_check()
	src.laws_object.show_laws(who)

/mob/living/silicon/ai/proc/laws_sanity_check()
	if (!src.laws_object)
		src.laws_object = new /datum/ai_laws/asimov

/mob/living/silicon/ai/proc/set_zeroth_law(var/law)
	src.laws_sanity_check()
	src.laws_object.set_zeroth_law(law)

/mob/living/silicon/ai/proc/add_inherent_law(var/number, var/law)
	src.laws_sanity_check()
	src.laws_object.add_inherent_law(number, law)

/mob/living/silicon/ai/proc/add_supplied_law(var/number, var/law)
	src.laws_sanity_check()
	src.laws_object.add_supplied_law(number, law)

/mob/living/silicon/ai/proc/clear_supplied_laws()
	src.laws_sanity_check()
	src.laws_object.clear_supplied_laws()

/mob/living/silicon/ai/proc/clear_inherent_laws()
	src.laws_sanity_check()
	src.laws_object.clear_inherent_laws()

/mob/living/silicon/ai/proc/switchCamera(var/obj/machinery/camera/C)
	usr:cameraFollow = null
	if (!C)
		src.machine = null
		src.reset_view(null)
		return 0
	if (stat == 2 || !C.status || C.network != src.network) return 0

	// ok, we're alive, camera is good and in our network...

	src.machine = src
	src:current = C
	src.reset_view(C)
	return 1

/mob/living/silicon/ai/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if (stat == 2)
		return 1
	var/list/L = src.alarms[class]
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
	if (src.viewalerts) src.ai_alerts()
	return 1

/mob/living/silicon/ai/cancelAlarm(var/class, area/A as area, obj/origin)
	var/list/L = src.alarms[class]
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
		if (src.viewalerts) src.ai_alerts()
	return !cleared

/mob/living/silicon/ai/cancel_camera()
	set category = "AI Commands"
	set name = "Cancel Camera View"
	src.reset_view(null)
	src.machine = null
	src:cameraFollow = null

/mob/living/silicon/ai/verb/change_network()
	set category = "AI Commands"
	set name = "Change Camera Network"
	src.reset_view(null)
	src.machine = null
	src:cameraFollow = null
	if(src.network == "AI Satellite")
		src.network = "SS13"
	else if (src.network == "Prison")
		src.network = "AI Satellite"
	else //(src.network == "SS13")
		src.network = "Prison"
//		src.network = "AI Satellite"
	src << "\blue Switched to [src.network] camera network."

/mob/living/silicon/ai/verb/statelaws() // -- TLE
	set category = "AI Commands"
	set name = "State Laws"
	src.say("Current Active Laws:")
	//src.laws_sanity_check()
	//src.laws_object.show_laws(world)
	var/number = 1
	sleep(10)
	for (var/index = 1, index <= src.laws_object.inherent.len, index++)
		var/law = src.laws_object.inherent[index]

		if (length(law) > 0)
			src.say("[number]. [law]")
			number++
			sleep(10)

	for (var/index = 1, index <= src.laws_object.supplied.len, index++)
		var/law = src.laws_object.supplied[index]
		if (length(law) > 0)
			src.say("[number]. [law]")
			number++
			sleep(10)


/mob/living/silicon/ai/proc/choose_modules()
	set category = "AI Commands"
	set name = "Choose Module"

	src.malf_picker.use(src)





