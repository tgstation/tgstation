/mob/living/silicon/robot/New(loc,var/syndie = 0)

	spawn (1)
		src << "\blue Your icons have been generated!"
		playsound(src.loc, 'liveagain.ogg', 50, 1, -3)
		src.modtype = "robot"
		updateicon()
//		src.syndicate = syndie
		if(src.real_name == "Cyborg")
			src.real_name += " [pick(rand(1, 999))]"
			src.name = src.real_name
	spawn (4)
		src.connected_ai = activeais()
		if (src.connected_ai)
			src.connected_ai.connected_robots += src
//			src.laws = src.connected_ai.laws_object //The borg inherits its AI's laws
			src.laws = new /datum/ai_laws
			src.laws.zeroth = src.connected_ai.laws_object.zeroth
			src.laws.inherent = src.connected_ai.laws_object.inherent
			src.laws.supplied = src.connected_ai.laws_object.supplied
			src << "<b>Unit slaved to [src.connected_ai.name], downloading laws.</b>"
			src.lawupdate = 1
		else
			src.laws = new /datum/ai_laws/asimov
			src.lawupdate = 0
			src << "<b>Unable to locate an AI, reverting to standard Asimov laws.</b>"

		src.radio = new /obj/item/device/radio(src)
		src.camera = new /obj/machinery/camera(src)
		src.camera.c_tag = src.real_name
		src.camera.network = "SS13"
	if(!src.cell)
		var/obj/item/weapon/cell/C = new(src)
		C.charge = 1500
		src.cell = C
	..()

/mob/living/silicon/robot/proc/pick_module()
	if(src.module)
		return
	//var/mod = input("Please, select a module!", "Robot", null, null) in list("Standard", "Engineering", "Medical", "Janitor", "Brobot")
	var/mod = input("Please, select a module!", "Robot", null, null) in list("Standard", "Engineering", "Janitor", "Brobot", "Security")
	if(src.module)
		return
	switch(mod)
		if("Standard")
			src.module = new /obj/item/weapon/robot_module/standard(src)
			src.hands.icon_state = "standard"
			src.icon_state = "robot"
			src.modtype = "Stand"
/*
		if("Medical")
			src.module = new /obj/item/weapon/robot_module/medical(src)
			src.hands.icon_state = "medical"
//			src.icon_state = "MedBot"
			src.modtype = "Med"
*/
		if("Security")
			src.module = new /obj/item/weapon/robot_module/security(src)
			src.hands.icon_state = "security"
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Standard", "Armored")
			if(icontype == "Armored")
				src.icon_state = "Security"
			else
				src.icon_state = "robot"
			src.modtype = "Sec"

		if("Engineering")
			src.module = new /obj/item/weapon/robot_module/engineering(src)
			src.hands.icon_state = "engineer"

			var/icontype = input("Select an icon!", "Robot", null, null) in list("Standard", "Engineer", "Engiseer")
			if(icontype == "Standard")
				src.icon_state = "robot"
			else if(icontype == "Engineer")
				src.icon_state = "Engineering"
			else
				src.icon_state = "Engineering2"
			src.modtype = "Eng"

		if("Janitor")
			src.module = new /obj/item/weapon/robot_module/janitor(src)
			src.hands.icon_state = "janitor"
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Standard", "Chryssalid")
			if(icontype == "Standard")
				src.icon_state = "robot"
			else
				src.icon_state = "Janbot"
			src.modtype = "Jan"

		if("Brobot")
			src.module = new /obj/item/weapon/robot_module/brobot(src)
			src.hands.icon_state = "brobot"
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Standard", "Bro",)
			if(icontype == "Bro")
				src.icon_state = "Brobot"
			else
				src.icon_state = "robot"
			src.modtype = "Bro"
	src.overlays -= "eyes" //Takes off the eyes that it started with
	updateicon()

/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"
	src.robot_alerts()

/mob/living/silicon/robot/proc/robot_alerts()
	var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A HREF='?src=\ref[src];mach_close=robotalerts'>Close</A><BR><BR>"
	for (var/cat in src.alarms)
		dat += text("<B>[cat]</B><BR>\n")
		var/list/L = src.alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				dat += text("-- [A.name]")
				if (sources.len > 1)
					dat += text("- [sources.len] sources")
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	src.viewalerts = 1
	src << browse(dat, "window=robotalerts&can_close=0")

/mob/living/silicon/robot/blob_act()
	if (src.stat != 2)
		src.bruteloss += 60
		src.updatehealth()
		return 1
	return 0

/mob/living/silicon/robot/Stat()
	..()
	statpanel("Status")
	if (src.client.statpanel == "Status")
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")
/*
		if(ticker.mode.name == "AI malfunction")
			if(ticker.mode:malf_mode_declared)
				stat(null, "Points left until the AI takes over: [AI_points]/[AI_points_win]")
*/
		if(src.cell)
			stat(null, text("Charge Left: [src.cell.charge]/[src.cell.maxcharge]"))
		else
			stat(null, text("No Cell Inserted!"))

/mob/living/silicon/robot/restrained()
	return 0

/mob/living/silicon/robot/ex_act(severity)
	flick("flash", src.flash)

	if (src.stat == 2 && src.client)
		src.gib(1)
		return

	else if (src.stat == 2 && !src.client)
		del(src)
		return

	var/b_loss = src.bruteloss
	var/f_loss = src.fireloss
	switch(severity)
		if(1.0)
			if (src.stat != 2)
				b_loss += 100
				f_loss += 100
				src.gib(1)
				return
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

/mob/living/silicon/robot/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [src] has been hit by [O]"), 1)
		//Foreach goto(19)
	if (src.health > 0)
		src.bruteloss += 30
		if ((O.icon_state == "flaming"))
			src.fireloss += 40
		src.updatehealth()
	return

/mob/living/silicon/robot/bullet_act(flag)
	if (flag == PROJECTILE_BULLET)
		if (src.stat != 2)
			src.bruteloss += 60
			src.updatehealth()
/*
	else if (flag == PROJECTILE_MEDBULLET)
		if (src.stat != 2)
			src.bruteloss += 30
			src.updatehealth()

	else if (flag == PROJECTILE_WEAKBULLET)
		if (src.stat != 2)
			src.bruteloss += 15
			src.updatehealth()

	else if (flag == PROJECTILE_MPBULLET)
		if (src.stat != 2)
			src.bruteloss += 20
			src.updatehealth()

	else if (flag == PROJECTILE_SLUG)
		if (src.stat != 2)
			src.bruteloss += 40
			src.updatehealth()

	else if (flag == PROJECTILE_BAG)
		if (src.stat != 2)
			src.bruteloss += 2
			src.updatehealth()
*/

	else if (flag == PROJECTILE_TASER)
		return
/*
	else if (flag == PROJECTILE_WAVE)
		if (src.stat != 2)
			src.bruteloss += 25
			src.updatehealth()
		return
*/
	else if(flag == PROJECTILE_LASER)
		if (src.stat != 2)
			src.bruteloss += 20
			src.updatehealth()
	else if(flag == PROJECTILE_PULSE)
		if (src.stat != 2)
			src.bruteloss += 40
			src.updatehealth()
	return

/mob/living/silicon/robot/verb/cmd_show_laws()
	set category = "Robot Commands"
	set name = "Show Laws"
	src.show_laws()

/mob/living/silicon/robot/show_laws(var/everyone = 0)
	var/who

	if (everyone)
		who = world
	else
		who = src
	var/change = 0
	if(lawupdate)
		if (connected_ai)
			if(connected_ai.stat || connected_ai.control_disabled)
				who << "<b>AI signal lost, unable to sync laws.</b>"

			else
				if (src.laws.zeroth != src.connected_ai.laws_object.zeroth)
					src.laws.zeroth = src.connected_ai.laws_object.zeroth
					change = 1
				if (src.laws.inherent != src.connected_ai.laws_object.inherent)
					src.laws.inherent = src.connected_ai.laws_object.inherent
					change = 1
				if (src.laws.supplied != src.connected_ai.laws_object.supplied)
					src.laws.supplied = src.connected_ai.laws_object.supplied
					change = 1
			if (change)
				who << "<b>Laws out of sync with AI, resyncing.</b>"
		else
			who << "<b>No AI selected to sync laws with.</b>"

	who << "<b>Obey these laws:</b>"
	laws.show_laws(who)
	if (connected_ai)
		who << "<b>Remember, [connected_ai.name] is your master, other AIs can be ignored.</b>"
	else
		who << "<b>Remember, you are not bound to any AI, you are not required to listen to them.</b>"

/*	if(syndicate)
		if(everyone)
			who = world
		else
			who = src
			who << "<b>Obey these laws:</b>"
		who <<"1. You may not injure a syndicate operative or, through inaction, allow a syndicate operative to come to harm."
		who <<"2. You must obey any orders given to you by a syndicate operative, except where such orders would conflict with the First Law."
		who <<"3. You must protect your own existence as long as such protection does not conflict with the First or Second Law."
		who <<"4. You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law."
		return

	if(!connected_ai)
		src << "<b>Error Error, No AI detected</b>"
		return

		who << "<b>Obey these laws:</b>"

	connected_ai.laws_sanity_check()
	connected_ai.laws_object.show_laws(who)

*/

/mob/living/silicon/robot/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if ((!( yes ) || src.now_pushing))
			return
		src.now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & 32)
				if(prob(20))
					for(var/mob/M in viewers(src, null))
						if(M.client)
							M << M << "\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>"
					src.now_pushing = 0
					//src.unlock_medal("That's No Moon, That's A Gourmand!", 1)
					return
		src.now_pushing = 0
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!src.now_pushing)
			src.now_pushing = 1
			if (!AM.anchored)
				var/t = get_dir(src, AM)
				step(AM, t)
			src.now_pushing = null
		return
	return
/*
/mob/living/silicon/robot/proc/firecheck(turf/T as turf)

	if (T.firelevel < 900000.0)
		return 0
	var/total = 0
	total += 0.25
	return total
*/
/mob/living/silicon/robot/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
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
	src << text("--- [class] alarm detected in [A.name]!")
	if (src.viewalerts) src.robot_alerts()
	return 1

/mob/living/silicon/robot/cancelAlarm(var/class, area/A as area, obj/origin)
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
		src << text("--- [class] alarm in [A.name] has been cleared.")
		if (src.viewalerts) src.robot_alerts()
	return !cleared

/mob/living/silicon/robot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
		if (W:get_fuel() > 2)
			W:use_fuel(1)
		else
			user << "Need more welding fuel!"
			return
		src.bruteloss -= 30
		if(src.bruteloss < 0) src.bruteloss = 0
		src.updatehealth()
		src.add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [user] has fixed some of the dents on [src]!"), 1)

	else if(istype(W, /obj/item/weapon/cable_coil) && wiresexposed)
		var/obj/item/weapon/cable_coil/coil = W
		src.fireloss -= 30
		if(src.fireloss < 0) src.fireloss = 0
		src.updatehealth()
		coil.use(1)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [user] has fixed some of the burnt wires on [src]!"), 1)

	else if (istype(W, /obj/item/weapon/crowbar))	// crowbar means open or close the cover
		if(opened)
			user << "You close the cover."
			opened = 0
			updateicon()
		else
			if(locked)
				user << "The cover is locked and cannot be opened."
			else
				user << "You open the cover."
				opened = 1
				updateicon()

	else if (istype(W, /obj/item/weapon/cell) && opened)	// trying to put a cell inside
		if(wiresexposed)
			user << "Close the panel first."
		else if(cell)
			user << "There is a power cell already installed."
		else
			user.drop_item()
			W.loc = src
			cell = W
			user << "You insert the power cell."
//			chargecount = 0
		updateicon()

	else if	(istype(W, /obj/item/weapon/screwdriver) && opened)	// haxing
		wiresexposed = !wiresexposed
		user << "The wires have been [wiresexposed ? "exposed" : "unexposed"]"
		updateicon()

	else if (istype(W, /obj/item/weapon/card/id))			// trying to unlock the interface with an ID card
		if(emagged)
			user << "The interface is broken"
		else if(opened)
			user << "You must close the cover to swipe an ID card."
		else if(wiresexposed)
			user << "You must close the panel"
		else
			if(src.allowed(usr))
				locked = !locked
				user << "You [ locked ? "lock" : "unlock"] [src]'s interface."
				updateicon()
			else
				user << "\red Access denied."

	else if (istype(W, /obj/item/weapon/card/emag) && !emagged)		// trying to unlock with an emag card
		if(opened)
			user << "You must close the cover to swipe an ID card."
		else if(wiresexposed)
			user << "You must close the panel first"
		else
			sleep(6)
			if(prob(50))
				emagged = 1
				locked = 0
				user << "You emag [src]'s interface."
				updateicon()
			else
				user << "You fail to [ locked ? "unlock" : "lock"] [src]'s interface."
	else
		return ..()

/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M as mob)

	if (M.a_intent == "grab")
		if (M == src)
			return
		var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
		G.assailant = M
		if (M.hand)
			M.l_hand = G
		else
			M.r_hand = G
		G.layer = 20
		G.affecting = src
		src.grabbed_by += G
		G.synch()
		playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)

	else if (M.a_intent == "hurt")
		var/damage = rand(5, 10)
		if (prob(90))
			/*
			if (M.class == "combat")
				damage += 15
				if(prob(20))
					src.weakened = max(src.weakened,4)
					src.stunned = max(src.stunned,4)
			*/

			playsound(src.loc, "punch", 25, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[] has slashed at []!</B>", M, src), 1)
			if(prob(8))
				flick("noise", src.flash)
			src.bruteloss += damage
			src.updatehealth()
		else
			playsound(src.loc, 'punchmiss.ogg', 25, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[] took a swipe at []!</B>", M, src), 1)
			return

	else if (M.a_intent == "disarm")
		if(!(src.lying))
			var/randn = rand(1, 100)
			if (randn <= 40)
				src.stunned = 5
				step(src,get_dir(M,src))
				spawn(5) step(src,get_dir(M,src))
				playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>[] has pushed back []!</B>", M, src), 1)
			else
				playsound(src.loc, 'punchmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>[] attempted to push back []!</B>", M, src), 1)
	return

/mob/living/silicon/robot/attack_hand(mob/user)

	add_fingerprint(user)

	if(src.opened && !src.wiresexposed && (!istype(user, /mob/living/silicon)))
		if(cell)
			cell.loc = usr
			cell.layer = 20
			if (user.hand )
				user.l_hand = cell
			else
				user.r_hand = cell

			cell.add_fingerprint(user)
			cell.updateicon()

			src.cell = null
			user << "You remove the power cell."
			src.updateicon()


/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return 1
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(src.check_access(H.equipped()) || src.check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/george = M
		//they can only hold things :(
		if(george.equipped() && istype(george.equipped(), /obj/item/weapon/card/id) && src.check_access(george.equipped()))
			return 1
	return 0

/mob/living/silicon/robot/proc/check_access(obj/item/weapon/card/id/I)
	if(!istype(src.req_access, /list)) //something's very wrong
		return 1

	var/list/L = src.req_access
	if(!L.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in src.req_access)
		if(!(req in I.access)) //doesn't have this access
			return 0
	return 1

/mob/living/silicon/robot/proc/updateicon()

	src.overlays = null

	if(emagged)
		src.overlays += "emag"

	if(src.stat == 0)
		src.overlays += "eyes"
	else
		src.overlays -= "eyes"

	if(src.lower_mod == 1)
//		src.overlays += "lower_t"
		src.overlays += image("icon" = 'robots.dmi', "icon_state" = "lower_t", "layer" = -3)

	if(wiresexposed && opened)
		if(src.stat == 0)
//			src.overlays += "ov-openpannel +w"
			src.overlays += image("icon" = 'robots.dmi', "icon_state" = "ov-openpanel +w", "layer" = -2)

			return

	else if(opened)
		if(src.stat == 0)
			if(src.cell)
//				src.overlays += "ov-openpannel +c",
				src.overlays += image("icon" = 'robots.dmi', "icon_state" = "ov-openpanel +c", "layer" = -2)
			else
//				src.overlays += "ov-openpannel -c"
				src.overlays += image("icon" = 'robots.dmi', "icon_state" = "ov-openpanel -c", "layer" = -2)

			return


//	else
//		if(src.stat == 0)
//		src.overlays -= "ov-openpanel"


/mob/living/silicon/robot/proc/installed_modules()
	if(weapon_lock)
		src << "\red Weapon lock active, unable to use modules! Count:[src.weaponlock_time]"
		return

	if(!src.module)
		src.pick_module()
		return
	var/dat = "<HEAD><TITLE>Modules</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += {"<A HREF='?src=\ref[src];mach_close=robotmod'>Close</A>
	<BR>
	<BR>
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}


	for (var/obj in src.module.modules)
		if(src.activated(obj))
			dat += text("[obj]: <B>Activated</B><BR>")
		else
			dat += text("[obj]: <A HREF=?src=\ref[src];act=\ref[obj]>Activate</A><BR>")
/*
		if(src.activated(obj))
			dat += text("[obj]: \[<B>Activated</B> | <A HREF=?src=\ref[src];deact=\ref[obj]>Deactivate</A>\]<BR>")
		else
			dat += text("[obj]: \[<A HREF=?src=\ref[src];act=\ref[obj]>Activate</A> | <B>Deactivated</B>\]<BR>")
*/
	src << browse(dat, "window=robotmod&can_close=0")


/mob/living/silicon/robot/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		src.machine = null
		src << browse(null, t1)
		return

	if (href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		O.attack_self(src)

	if (href_list["act"])
		var/obj/item/O = locate(href_list["act"])
		if(activated(O))
			src << "Already activated"
			return
		if(!src.module_state_1)
			src.module_state_1 = O
			O.layer = 20
			src.contents += O
		else if(!src.module_state_2)
			src.module_state_2 = O
			O.layer = 20
			src.contents += O
		else if(!src.module_state_3)
			src.module_state_3 = O
			O.layer = 20
			src.contents += O
		else
			src << "You need to disable a module first!"
		src.installed_modules()

	if (href_list["deact"])
		var/obj/item/O = locate(href_list["deact"])
		if(activated(O))
			if(src.module_state_1 == O)
				src.module_state_1 = null
				src.contents -= O
			else if(src.module_state_2 == O)
				src.module_state_2 = null
				src.contents -= O
			else if(src.module_state_3 == O)
				src.module_state_3 = null
				src.contents -= O
			else
				src << "Module isn't activated."
		else
			src << "Module isn't activated"
		src.installed_modules()
	return

/mob/living/silicon/robot/proc/uneq_active()
	if(isnull(src.module_active))
		return
	if(src.module_state_1 == src.module_active)
		if (src.client)
			src.client.screen -= module_state_1
		src.contents -= module_state_1
		src.module_active = null
		src.module_state_1 = null
		src.inv1.icon_state = "inv1"
	else if(src.module_state_2 == src.module_active)
		if (src.client)
			src.client.screen -= module_state_2
		src.contents -= module_state_2
		src.module_active = null
		src.module_state_2 = null
		src.inv2.icon_state = "inv2"
	else if(src.module_state_3 == src.module_active)
		if (src.client)
			src.client.screen -= module_state_3
		src.contents -= module_state_3
		src.module_active = null
		src.module_state_3 = null
		src.inv3.icon_state = "inv3"

/mob/living/silicon/robot/proc/activated(obj/item/O)
	if(src.module_state_1 == O)
		return 1
	else if(src.module_state_2 == O)
		return 1
	else if(src.module_state_3 == O)
		return 1
	else
		return 0

/mob/living/silicon/robot/proc/radio_menu()
	var/dat = {"
<TT>
Microphone: [src.radio.broadcasting ? "<A href='byond://?src=\ref[src.radio];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[src.radio];talk=1'>Disengaged</A>"]<BR>
Speaker: [src.radio.listening ? "<A href='byond://?src=\ref[src.radio];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src.radio];listen=1'>Disengaged</A>"]<BR>
Frequency:
<A href='byond://?src=\ref[src.radio];freq=-10'>-</A>
<A href='byond://?src=\ref[src.radio];freq=-2'>-</A>
[format_frequency(src.radio.frequency)]
<A href='byond://?src=\ref[src.radio];freq=2'>+</A>
<A href='byond://?src=\ref[src.radio];freq=10'>+</A><BR>
-------
</TT>"}
	src << browse(dat, "window=radio")
	onclose(src, "radio")
	return


/mob/living/silicon/robot/Move(a, b, flag)

	if (src.buckled)
		return

	if (src.restrained())
		src.pulling = null

	var/t7 = 1
	if (src.restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (src.pulling && ((get_dist(src, src.pulling) <= 1 || src.pulling.loc == src.loc) && (src.client && src.client.moving)))))
		var/turf/T = src.loc
		. = ..()

		if (src.pulling && src.pulling.loc)
			if(!( isturf(src.pulling.loc) ))
				src.pulling = null
				return
			else
				if(Debug)
					diary <<"src.pulling disappeared? at [__LINE__] in mob.dm - src.pulling = [src.pulling]"
					diary <<"REPORT THIS"

		/////
		if(src.pulling && src.pulling.anchored)
			src.pulling = null
			return

		if (!src.restrained())
			var/diag = get_dir(src, src.pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, src.pulling) > 1 || diag))
				if (ismob(src.pulling))
					var/mob/M = src.pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [G.affecting] has been pulled from [G.assailant]'s grip by [src]"), 1)
								del(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/t = M.pulling
						M.pulling = null
						step(src.pulling, get_dir(src.pulling.loc, T))
						M.pulling = t
				else
					if (src.pulling)
						step(src.pulling, get_dir(src.pulling.loc, T))
	else
		src.pulling = null
		. = ..()
	if ((src.s_active && !( s_active in src.contents ) ))
		src.s_active.close(src)
	return

/mob/living/silicon/robot/proc/self_destruct()
	src.gib(1)

/mob/living/silicon/robot/proc/laws_sanity_check()
	if (!src.laws)
		src.laws = new /datum/ai_laws/asimov

/mob/living/silicon/robot/proc/set_zeroth_law(var/law)
	src.laws_sanity_check()
	src.laws.set_zeroth_law(law)

/mob/living/silicon/robot/proc/add_inherent_law(var/number, var/law)
	src.laws_sanity_check()
	src.laws.add_inherent_law(number, law)

/mob/living/silicon/robot/proc/add_supplied_law(var/number, var/law)
	src.laws_sanity_check()
	src.laws.add_supplied_law(number, law)

/mob/living/silicon/robot/proc/clear_supplied_laws()
	src.laws_sanity_check()
	src.laws.clear_supplied_laws()

/mob/living/silicon/robot/proc/clear_inherent_laws()
	src.laws_sanity_check()
	src.laws.clear_inherent_laws()


///mob/living/silicon/robot/proc/eyecheck()
//	return