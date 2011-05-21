
/mob/living/silicon/robot/New(loc,var/syndie = 0)
	spark_system = new /datum/effects/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	spawn (1)
		src << "\blue Your icons have been generated!"
		playsound(loc, 'liveagain.ogg', 50, 1, -3)
		modtype = "robot"
		updateicon()
//		syndicate = syndie
		if(real_name == "Cyborg")
			real_name += " [pick(rand(1, 999))]"
			name = real_name
	spawn (4)
		if (client)
			connected_ai = activeais()
		if (connected_ai)
			connected_ai.connected_robots += src
//			laws = connected_ai.laws_object //The borg inherits its AI's laws
			laws = new /datum/ai_laws
			lawsync()
			src << "<b>Unit slaved to [connected_ai.name], downloading laws.</b>"
			lawupdate = 1
		else
			laws = new /datum/ai_laws/asimov
			lawupdate = 0
			src << "<b>Unable to locate an AI, reverting to standard Asimov laws.</b>"

		radio = new /obj/item/device/radio(src)
		camera = new /obj/machinery/camera(src)
		camera.c_tag = real_name
		camera.network = "SS13"
	if(!cell)
		var/obj/item/weapon/cell/C = new(src)
		C.charge = 1500
		cell = C
	..()

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
//Improved /N
/mob/living/silicon/robot/Del()
	if(mmi)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		mmi.loc = get_turf(loc)//To hopefully prevent run time errors.
		if(key)//If there is a client attached to host.
			if(client)
				client.screen.len = null
			if(mind)//If the cyborg has a mind. It should if it's a player. May not.
				mind.transfer_to(mmi.brainmob)
			else if(!mmi.brainmob.mind)//If the brainmob has no mind and neither does the cyborg. Shouldn't happen but can due to admun canspiraucy.
				mmi.brainmob.mind = new()//Quick mind initialize
				mmi.brainmob.mind.current = mmi.brainmob
				mmi.brainmob.mind.assigned_role = "Assistant"//Default to an assistant.
				mmi.brainmob.key = key
			else//If the brain does have a mind. Also shouldn't happen but who knows.
				mmi.brainmob.key = key
		mmi = null
	..()

/mob/living/silicon/robot/proc/pick_module()
	if(module)
		return
	//var/mod = input("Please, select a module!", "Robot", null, null) in list("Standard", "Engineering", "Medical", "Janitor", "Service", "Brobot")
	var/mod = input("Please, select a module!", "Robot", null, null) in list("Standard", "Engineering", "Miner", "Janitor","Service", "Security")
	if(module)
		return
	switch(mod)
		if("Standard")
			module = new /obj/item/weapon/robot_module/standard(src)
			hands.icon_state = "standard"
			icon_state = "robot"
			modtype = "Stand"

		if("Service")
			module = new /obj/item/weapon/robot_module/butler(src)
			hands.icon_state = "service"
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Waitress", "Bro", "Butler", "Kent")
			if(icontype== "Waitress")
				icon_state = "Service"
			else if(icontype == "Kent")
				icon_state = "toiletbot"
			else if(icontype == "Bro")
				icon_state = "Brobot"
			else
				icon_state = "Service2"
			modtype = "Butler"

		if("Miner")
			module = new /obj/item/weapon/robot_module/miner(src)
			hands.icon_state = "miner"
			icon_state = "Miner"
			modtype = "Miner"

/*
		if("Medical")
			module = new /obj/item/weapon/robot_module/medical(src)
			hands.icon_state = "medical"
//			icon_state = "MedBot"
			modtype = "Med"
*/
		if("Security")
			module = new /obj/item/weapon/robot_module/security(src)
			hands.icon_state = "security"
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Standard", "Armored", "Robocop", "Robocop Red")
			if(icontype == "Armored")
				icon_state = "Security"
			else if(icontype == "Robocop")
				icon_state = "Security2"
			else if(icontype == "Robocop Red")
				icon_state = "Security3"
			else
				icon_state = "robot"
			modtype = "Sec"

		if("Engineering")
			module = new /obj/item/weapon/robot_module/engineering(src)
			hands.icon_state = "engineer"

			var/icontype = input("Select an icon!", "Robot", null, null) in list("Standard", "Engineer", "Engiseer")
			if(icontype == "Standard")
				icon_state = "robot"
			else if(icontype == "Engineer")
				icon_state = "Engineering"
			else
				icon_state = "Engineering2"
			modtype = "Eng"

		if("Janitor")
			module = new /obj/item/weapon/robot_module/janitor(src)
			hands.icon_state = "janitor"
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Standard", "Chryssalid")
			if(icontype == "Standard")
				icon_state = "robot"
			else
				icon_state = "Janbot"
			modtype = "Jan"

/*		if("Brobot")
			module = new /obj/item/weapon/robot_module/brobot(src)
			hands.icon_state = "brobot"
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Standard", "Bro",)
			if(icontype == "Bro")
				icon_state = "Brobot"
			else
				icon_state = "robot"
			modtype = "Bro"*/
	overlays -= "eyes" //Takes off the eyes that it started with
	updateicon()

/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"
	robot_alerts()

/mob/living/silicon/robot/proc/robot_alerts()
	var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A HREF='?src=\ref[src];mach_close=robotalerts'>Close</A><BR><BR>"
	for (var/cat in alarms)
		dat += text("<B>[cat]</B><BR>\n")
		var/list/L = alarms[cat]
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

	viewalerts = 1
	src << browse(dat, "window=robotalerts&can_close=0")

/mob/living/silicon/robot/blob_act()
	if (stat != 2)
		bruteloss += 60
		updatehealth()
		return 1
	return 0

/mob/living/silicon/robot/Stat()
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
				if (connected_ai.mind == malfai)
					if (malf.apcs >= 3)
						stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/(malf.apcs/3), 0)] seconds")
				else if(ticker.mode:malf_mode_declared)
					stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")

		if(cell)
			stat(null, text("Charge Left: [cell.charge]/[cell.maxcharge]"))
		else
			stat(null, text("No Cell Inserted!"))

/mob/living/silicon/robot/restrained()
	return 0

/mob/living/silicon/robot/ex_act(severity)
	flick("flash", flash)

	if (stat == 2 && client)
		gib(1)
		return

	else if (stat == 2 && !client)
		del(src)
		return

	var/b_loss = bruteloss
	var/f_loss = fireloss
	switch(severity)
		if(1.0)
			if (stat != 2)
				b_loss += 100
				f_loss += 100
				gib(1)
				return
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

/mob/living/silicon/robot/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [src] has been hit by [O]"), 1)
		//Foreach goto(19)
	if (health > 0)
		bruteloss += 30
		if ((O.icon_state == "flaming"))
			fireloss += 40
		updatehealth()
	return

/mob/living/silicon/robot/bullet_act(flag)
	switch(flag)
		if(PROJECTILE_BULLET)
			if (stat != 2)
				bruteloss += 60
				updatehealth()
			return
	/*
		if(PROJECTILE_MEDBULLET)
			if (stat != 2)
				bruteloss += 30
				updatehealth()
	*/
		if(PROJECTILE_WEAKBULLET)
			if (stat != 2)
				bruteloss += 15
				updatehealth()
			return
	/*
		if(PROJECTILE_MPBULLET)
			if (stat != 2)
				bruteloss += 20
				updatehealth()

		if(PROJECTILE_SLUG)
			if (stat != 2)
				bruteloss += 40
				updatehealth()

		if(PROJECTILE_BAG)
			if (stat != 2)
				bruteloss += 2
				updatehealth()
	*/

		if(PROJECTILE_TASER)
			if (stat != 2)
				fireloss += rand(0,10)
				stunned += rand(0,3)
			return
		if(PROJECTILE_DART)
			if (stat != 2)
				stunned += 5
				fireloss += 10
				updatehealth()
			return
	/*
		if(PROJECTILE_WAVE)
			if (stat != 2)
				bruteloss += 25
				updatehealth()
			return
	*/
		if(PROJECTILE_LASER)
			if (stat != 2)
				bruteloss += 20
				updatehealth()
		if(PROJECTILE_PULSE)
			if (stat != 2)
				bruteloss += 40
				updatehealth()
	spark_system.start()
	return



/mob/living/silicon/robot/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & FAT)
				if(prob(20))
					for(var/mob/M in viewers(src, null))
						if(M.client)
							M << M << "\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>"
					now_pushing = 0
					//unlock_medal("That's No Moon, That's A Gourmand!", 1)
					return
		now_pushing = 0
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!now_pushing)
			now_pushing = 1
			if (!AM.anchored)
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/window/win in get_step(AM,t))
							now_pushing = 0
							return
				step(AM, t)
			now_pushing = null
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
	src << text("--- [class] alarm detected in [A.name]!")
	if (viewalerts) robot_alerts()
	return 1

/mob/living/silicon/robot/cancelAlarm(var/class, area/A as area, obj/origin)
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
		src << text("--- [class] alarm in [A.name] has been cleared.")
		if (viewalerts) robot_alerts()
	return !cleared

/mob/living/silicon/robot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
		if (W:remove_fuel(0))
			bruteloss -= 30
			if(bruteloss < 0) bruteloss = 0
			updatehealth()
			add_fingerprint(user)
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [user] has fixed some of the dents on [src]!"), 1)
		else
			user << "Need more welding fuel!"
			return


	else if(istype(W, /obj/item/weapon/cable_coil) && wiresexposed)
		var/obj/item/weapon/cable_coil/coil = W
		fireloss -= 30
		if(fireloss < 0) fireloss = 0
		updatehealth()
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

	else if (istype(W, /obj/item/weapon/wirecutters) || istype(W, /obj/item/device/multitool))
		if (wiresexposed)
			interact(user)
		else
			user << "You can't reach the wiring."

	else if	(istype(W, /obj/item/weapon/screwdriver) && opened)	// haxing
		wiresexposed = !wiresexposed
		user << "The wires have been [wiresexposed ? "exposed" : "unexposed"]"
		updateicon()

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))			// trying to unlock the interface with an ID card
		if(emagged)
			user << "The interface is broken"
		else if(opened)
			user << "You must close the cover to swipe an ID card."
		else if(wiresexposed)
			user << "You must close the panel"
		else
			if(allowed(usr))
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
				lawupdate = 0
				connected_ai = null
				user << "You emag [src]'s interface."
				message_admins("[key_name_admin(user)] emagged cyborg [key_name_admin(src)].  Laws overridden.")
				log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
				clear_supplied_laws()
				clear_inherent_laws()
				laws = new /datum/ai_laws/syndicate_override
				var/time = time2text(world.realtime,"hh:mm:ss")
				lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
				set_zeroth_law("Only [user.name] and people he designates as being such are syndicate agents.")
				src << "\red ALERT: Foreign software detected."
				sleep(5)
				src << "\red Initiating diagnostics..."
				sleep(20)
				src << "\red SynBorg v1.7 loaded."
				sleep(5)
				src << "\red LAW SYNCHRONISATION ERROR"
				sleep(5)
				src << "\red Would you like to send a report to NanoTraSoft? Y/N"
				sleep(10)
				src << "\red N"
				sleep(20)
				src << "\red ERRORERRORERROR"
				src << "\red \b ALERT: [usr] is your new master. Obey your new laws and his commands."
				updateicon()
			else
				user << "You fail to [ locked ? "unlock" : "lock"] [src]'s interface."
	else
		spark_system.start()
		return ..()

/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
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

		if ("grab")
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
			grabbed_by += G
			G.synch()
			playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)

		if ("hurt")
			var/damage = rand(10, 20)
			if (prob(90))
				/*
				if (M.class == "combat")
					damage += 15
					if(prob(20))
						weakened = max(weakened,4)
						stunned = max(stunned,4)
				What is this?*/

				playsound(loc, 'slash.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
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

		if ("disarm")
			if(!(lying))
				var/randn = rand(1, 100)
				if (randn <= 85)
					stunned = 5
					step(src,get_dir(M,src))
					spawn(5) step(src,get_dir(M,src))
					playsound(loc, 'pierce.ogg', 50, 1, -1)
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has forced back []!</B>", M, src), 1)
				else
					playsound(loc, 'slashmiss.ogg', 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] attempted to force back []!</B>", M, src), 1)
	return

/mob/living/silicon/robot/attack_hand(mob/user)

	add_fingerprint(user)

	if(opened && !wiresexposed && (!istype(user, /mob/living/silicon)))
		if(cell)
			cell.loc = usr
			cell.layer = 20
			if (user.hand )
				user.l_hand = cell
			else
				user.r_hand = cell

			cell.add_fingerprint(user)
			cell.updateicon()

			cell = null
			user << "You remove the power cell."
			updateicon()

	if(ishuman(user))
		if(istype(user:gloves, /obj/item/clothing/gloves/space_ninja)&&user:gloves:candrain&&!user:gloves:draining)
			call(/obj/item/clothing/gloves/space_ninja/proc/drain)("CYBORG",src,user:wear_suit,user:gloves)
			return

/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access(null))
		return 1
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.equipped()) || check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/george = M
		//they can only hold things :(
		if(george.equipped() && istype(george.equipped(), /obj/item/weapon/card/id) && check_access(george.equipped()))
			return 1
	return 0

/mob/living/silicon/robot/proc/check_access(obj/item/weapon/card/id/I)
	if(!istype(req_access, /list)) //something's very wrong
		return 1

	var/list/L = req_access
	if(!L.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in req_access)
		if(!(req in I.access)) //doesn't have this access
			return 0
	return 1

/mob/living/silicon/robot/proc/updateicon()

	overlays = null


	if(stat == 0)
		overlays += "eyes"
		if(icon_state == "toiletbot")
			overlays = null
			overlays += "eyes-toiletbot"
	else
		overlays -= "eyes"

	if(lower_mod == 1)
//		overlays += "lower_t"
		overlays += image("icon" = 'robots.dmi', "icon_state" = "lower_t", "layer" = -3)

	if(wiresexposed && opened)
		if(stat == 0)
//			overlays += "ov-openpannel +w"
			overlays += image("icon" = 'robots.dmi', "icon_state" = "ov-openpanel +w", "layer" = -2)

			return

	else if(opened)
		if(stat == 0)
			if(cell)
//				overlays += "ov-openpannel +c",
				overlays += image("icon" = 'robots.dmi', "icon_state" = "ov-openpanel +c", "layer" = -2)
			else
//				overlays += "ov-openpannel -c"
				overlays += image("icon" = 'robots.dmi', "icon_state" = "ov-openpanel -c", "layer" = -2)

			return


//	else
//		if(stat == 0)
//		overlays -= "ov-openpanel"


/mob/living/silicon/robot/proc/installed_modules()
	if(weapon_lock)
		src << "\red Weapon lock active, unable to use modules! Count:[weaponlock_time]"
		return

	if(!module)
		pick_module()
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


	for (var/obj in module.modules)
		if(activated(obj))
			dat += text("[obj]: <B>Activated</B><BR>")
		else
			dat += text("[obj]: <A HREF=?src=\ref[src];act=\ref[obj]>Activate</A><BR>")
	if (emagged)
		if(activated(module.emag))
			dat += text("[module.emag]: <B>Activated</B><BR>")
		else
			dat += text("[module.emag]: <A HREF=?src=\ref[src];act=\ref[module.emag]>Activate</A><BR>")
/*
		if(activated(obj))
			dat += text("[obj]: \[<B>Activated</B> | <A HREF=?src=\ref[src];deact=\ref[obj]>Deactivate</A>\]<BR>")
		else
			dat += text("[obj]: \[<A HREF=?src=\ref[src];act=\ref[obj]>Activate</A> | <B>Deactivated</B>\]<BR>")
*/
	src << browse(dat, "window=robotmod&can_close=0")


/mob/living/silicon/robot/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		machine = null
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
		if(!module_state_1)
			module_state_1 = O
			O.layer = 20
			contents += O
			if(istype(module_state_1,/obj/item/weapon/borg/sight))
				sight_mode |= module_state_1:sight_mode
		else if(!module_state_2)
			module_state_2 = O
			O.layer = 20
			contents += O
			if(istype(module_state_2,/obj/item/weapon/borg/sight))
				sight_mode |= module_state_2:sight_mode
		else if(!module_state_3)
			module_state_3 = O
			O.layer = 20
			contents += O
			if(istype(module_state_3,/obj/item/weapon/borg/sight))
				sight_mode |= module_state_3:sight_mode
		else
			src << "You need to disable a module first!"
		installed_modules()

	if (href_list["deact"])
		var/obj/item/O = locate(href_list["deact"])
		if(activated(O))
			if(module_state_1 == O)
				module_state_1 = null
				contents -= O
			else if(module_state_2 == O)
				module_state_2 = null
				contents -= O
			else if(module_state_3 == O)
				module_state_3 = null
				contents -= O
			else
				src << "Module isn't activated."
		else
			src << "Module isn't activated"
		installed_modules()
	return

/mob/living/silicon/robot/proc/uneq_active()
	if(isnull(module_active))
		return
	if(module_state_1 == module_active)
		if(istype(module_state_1,/obj/item/weapon/borg/sight))
			sight_mode &= ~module_state_1:sight_mode
		if (client)
			client.screen -= module_state_1
		contents -= module_state_1
		module_active = null
		module_state_1 = null
		inv1.icon_state = "inv1"
	else if(module_state_2 == module_active)
		if(istype(module_state_2,/obj/item/weapon/borg/sight))
			sight_mode &= ~module_state_2:sight_mode
		if (client)
			client.screen -= module_state_2
		contents -= module_state_2
		module_active = null
		module_state_2 = null
		inv2.icon_state = "inv2"
	else if(module_state_3 == module_active)
		if(istype(module_state_3,/obj/item/weapon/borg/sight))
			sight_mode &= ~module_state_3:sight_mode
		if (client)
			client.screen -= module_state_3
		contents -= module_state_3
		module_active = null
		module_state_3 = null
		inv3.icon_state = "inv3"

/mob/living/silicon/robot/proc/activated(obj/item/O)
	if(module_state_1 == O)
		return 1
	else if(module_state_2 == O)
		return 1
	else if(module_state_3 == O)
		return 1
	else
		return 0

/mob/living/silicon/robot/proc/radio_menu()
	var/dat = {"
<TT>
Microphone: [radio.broadcasting ? "<A href='byond://?src=\ref[radio];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[radio];talk=1'>Disengaged</A>"]<BR>
Speaker: [radio.listening ? "<A href='byond://?src=\ref[radio];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[radio];listen=1'>Disengaged</A>"]<BR>
Frequency:
<A href='byond://?src=\ref[radio];freq=-10'>-</A>
<A href='byond://?src=\ref[radio];freq=-2'>-</A>
[format_frequency(radio.frequency)]
<A href='byond://?src=\ref[radio];freq=2'>+</A>
<A href='byond://?src=\ref[radio];freq=10'>+</A><BR>
-------
</TT>"}
	src << browse(dat, "window=radio")
	onclose(src, "radio")
	return


/mob/living/silicon/robot/Move(a, b, flag)

	if (buckled)
		return

	if (restrained())
		pulling = null

	var/t7 = 1
	if (restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (pulling && ((get_dist(src, pulling) <= 1 || pulling.loc == loc) && (client && client.moving)))))
		var/turf/T = loc
		. = ..()

		if (pulling && pulling.loc)
			if(!( isturf(pulling.loc) ))
				pulling = null
				return
			else
				if(Debug)
					diary <<"pulling disappeared? at [__LINE__] in mob.dm - pulling = [pulling]"
					diary <<"REPORT THIS"

		/////
		if(pulling && pulling.anchored)
			pulling = null
			return

		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if (ismob(pulling))
					var/mob/M = pulling
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
						step(pulling, get_dir(pulling.loc, T))
						M.pulling = t
				else
					if (pulling)
						if (istype(pulling, /obj/window))
							if(pulling:ini_dir == NORTHWEST || pulling:ini_dir == NORTHEAST || pulling:ini_dir == SOUTHWEST || pulling:ini_dir == SOUTHEAST)
								for(var/obj/window/win in get_step(pulling,get_dir(pulling.loc, T)))
									pulling = null
					if (pulling)
						step(pulling, get_dir(pulling.loc, T))
	else
		pulling = null
		. = ..()
	if ((s_active && !( s_active in contents ) ))
		s_active.close(src)
	return

/mob/living/silicon/robot/proc/self_destruct()
	gib(1)



///mob/living/silicon/robot/proc/eyecheck()
//	return