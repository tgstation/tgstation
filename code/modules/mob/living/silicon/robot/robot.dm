/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'//
	icon_state = "robot"
	maxHealth = 100
	health = 100
	var/sight_mode = 0
	var/custom_name = ""

//Hud stuff

	var/obj/screen/cells = null
	var/obj/screen/inv1 = null
	var/obj/screen/inv2 = null
	var/obj/screen/inv3 = null

//3 Modules can be activated at any one time.
	var/obj/item/weapon/robot_module/module = null
	var/module_active = null
	var/module_state_1 = null
	var/module_state_2 = null
	var/module_state_3 = null

	var/obj/item/device/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/cell/cell = null
	var/obj/machinery/camera/camera = null

	var/obj/item/device/mmi/mmi = null
	var/datum/wires/robot/wires = null

	var/opened = 0
	var/emagged = 0
	var/wiresexposed = 0
	var/locked = 1
	var/list/req_access = list(access_robotics)
	var/ident = 0
	//var/list/laws = list()
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list())
	var/viewalerts = 0
	var/modtype = "robot"
	var/lower_mod = 0
	var/jetpack = 0
	var/datum/effect/effect/system/ion_trail_follow/ion_trail = null
	var/datum/effect/effect/system/spark_spread/spark_system//So they can initialize sparks whenever/N
	var/jeton = 0

	var/killswitch = 0
	var/killswitch_time = 60
	var/weapon_lock = 0
	var/weaponlock_time = 120
	var/lawupdate = 1 //Cyborgs will sync their laws with their AI by default
	var/lockcharge //Boolean of whether the borg is locked down or not
	var/speed = 0 //Cause sec borgs gotta go fast //No they dont!
	var/scrambledcodes = 0 // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.

	var/obj/item/weapon/tank/internal = null	//Hatred. Used if a borg has a jetpack.
	var/obj/item/robot_parts/robot_suit/robot_suit = null //Used for deconstruction to remember what the borg was constructed out of..



/mob/living/silicon/robot/New(loc,var/syndie = 0)
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	wires = new(src)

	ident = rand(1, 999)
	updatename("Default")
	updateicon()

	if(!cell)
		cell = new /obj/item/weapon/cell(src)
		cell.maxcharge = 7500
		cell.charge = 7500

	if(syndie)
		laws = new /datum/ai_laws/antimov()
		lawupdate = 0
		scrambledcodes = 1
		cell.maxcharge = 25000
		cell.charge = 25000
		module = new /obj/item/weapon/robot_module/syndicate(src)
		hands.icon_state = "standard"
		icon_state = "secborg"
		modtype = "Synd"
	else
		laws = new /datum/ai_laws/asimov()
		connected_ai = select_active_ai_with_fewest_borgs()
		if(connected_ai)
			connected_ai.connected_robots += src
			lawsync()
			lawupdate = 1
		else
			lawupdate = 0

	radio = new /obj/item/device/radio/borg(src)
	if(!scrambledcodes && !camera)
		camera = new /obj/machinery/camera(src)
		camera.c_tag = real_name
		camera.network = list("SS13")
		if(wires.IsCameraCut()) // 5 = BORG CAMERA
			camera.status = 0
	..()

	//MMI stuff. Held togheter by magic. ~Miauw
	mmi = new(src)
	mmi.brain = new /obj/item/organ/brain(mmi)
	mmi.brain.name = "[src.real_name]'s brain"
	mmi.locked = 1
	mmi.icon_state = "mmi_full"
	mmi.name = "Man-Machine Interface: [src.real_name]"
	mmi.brainmob = new(src)
	mmi.brainmob.name = src.real_name
	mmi.brainmob.real_name = src.real_name
	mmi.brainmob.container = mmi
	mmi.contents += mmi.brainmob

	playsound(loc, 'sound/voice/liveagain.ogg', 75, 1)


//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
//Improved /N
/mob/living/silicon/robot/Del()
	if(mmi && mind)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/T = get_turf(loc)//To hopefully prevent run time errors.
		if(T)	mmi.loc = T
		mind.transfer_to(mmi.brainmob)
		mmi = null
	..()

/mob/living/silicon/robot/proc/pick_module()
	if(module)
		return
	var/mod = input("Please, select a module!", "Robot", null, null) in list("Standard", "Engineering", "Medical", "Miner", "Janitor","Service", "Security")
	if(module)
		return
	switch(mod)
		if("Standard")
			updatename(mod)
			module = new /obj/item/weapon/robot_module/standard(src)
			hands.icon_state = "standard"
			icon_state = "robot"
			modtype = "Stand"
			feedback_inc("cyborg_standard",1)

		if("Service")
			updatename(mod)
			module = new /obj/item/weapon/robot_module/butler(src)
			hands.icon_state = "service"
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Waitress", "Bro", "Butler", "Kent", "Rich")
			switch(icontype)
				if("Waitress")	icon_state = "Service"
				if("Kent")		icon_state = "toiletbot"
				if("Bro")		icon_state = "Brobot"
				if("Rich")		icon_state = "maximillion"
				else				icon_state = "Service2"
			modtype = "Butler"
			feedback_inc("cyborg_service",1)

		if("Miner")
			updatename(mod)
			module = new /obj/item/weapon/robot_module/miner(src)
			hands.icon_state = "miner"
			icon_state = "Miner"
			modtype = "Miner"
			feedback_inc("cyborg_miner",1)

		if("Medical")
			updatename(mod)
			module = new /obj/item/weapon/robot_module/medical(src)
			hands.icon_state = "medical"
			icon_state = "surgeon"
			modtype = "Med"
			status_flags &= ~CANPUSH
			feedback_inc("cyborg_medical",1)

		if("Security")
			updatename(mod)
			module = new /obj/item/weapon/robot_module/security(src)
			hands.icon_state = "security"
			icon_state = "bloodhound"
			modtype = "Sec"
			//speed = -1 Secborgs have nerfed tasers now, so the speed boost is not necessary
			status_flags &= ~CANPUSH
			feedback_inc("cyborg_security",1)

		if("Engineering")
			updatename(mod)
			module = new /obj/item/weapon/robot_module/engineering(src)
			hands.icon_state = "engineer"
			icon_state = "landmate"
			modtype = "Eng"
			feedback_inc("cyborg_engineering",1)

		if("Janitor")
			updatename(mod)
			module = new /obj/item/weapon/robot_module/janitor(src)
			hands.icon_state = "janitor"
			icon_state = "mopgearrex"
			modtype = "Jan"
			feedback_inc("cyborg_janitor",1)

	overlays -= "eyes" //Takes off the eyes that it started with
	updateicon()

/mob/living/silicon/robot/proc/updatename(var/prefix as text)

	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
	else
		changed_name = "[(prefix ? "[prefix] " : "")]Cyborg-[num2text(ident)]"
	real_name = changed_name
	name = real_name
	if(camera)
		camera.c_tag = real_name	//update the camera name too


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
		adjustBruteLoss(60)
		updatehealth()
		return 1
	else
		gib()
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
				if(connected_ai)
					if(connected_ai.mind == malfai)
						if(malf.apcs >= 3)
							stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/(malf.apcs/3), 0)] seconds")
				else if(ticker.mode:malf_mode_declared)
					stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")

		if(cell)
			stat(null, text("Charge Left: [cell.charge]/[cell.maxcharge]"))
		else
			stat(null, text("No Cell Inserted!"))

		if(module)
			internal = locate(/obj/item/weapon/tank/jetpack) in module.modules
			if(internal)
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())

/mob/living/silicon/robot/restrained()
	return 0


/mob/living/silicon/robot/ex_act(severity)
	if(!blinded)
		flick("flash", flash)

	if (stat == 2 && client)
		gib()
		return

	else if (stat == 2 && !client)
		del(src)
		return

	switch(severity)
		if(1.0)
			if (stat != 2)
				adjustBruteLoss(100)
				adjustFireLoss(100)
				gib()
				return
		if(2.0)
			if (stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if (stat != 2)
				adjustBruteLoss(30)

	updatehealth()


/mob/living/silicon/robot/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [src] has been hit by [O]"), 1)
		//Foreach goto(19)
	if (health > 0)
		adjustBruteLoss(30)
		if ((O.icon_state == "flaming"))
			adjustFireLoss(40)
		updatehealth()
	return


/mob/living/silicon/robot/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	updatehealth()
	if(prob(75) && Proj.damage > 0) spark_system.start()
	return 2

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
	queueAlarm(text("--- [class] alarm detected in [A.name]!"), class)
//	if (viewalerts) robot_alerts()
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
		queueAlarm(text("--- [class] alarm in [A.name] has been cleared."), class, 0)
//		if (viewalerts) robot_alerts()
	return !cleared


/mob/living/silicon/robot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/handcuffs)) // fuck i don't even know why isrobot() in handcuff code isn't working so this will have to do
		return

	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if (src == user)
			user << "<span class='warning'>You lack the reach to be able to repair yourself.</span>"
			return
		if (src.health >= src.maxHealth)
			user << "<span class='warning'>[src] is already in good condition.</span>"
			return
		if (WT.remove_fuel(0))
			adjustBruteLoss(-30)
			updatehealth()
			add_fingerprint(user)
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [user] has fixed some of the dents on [src]!"), 1)
		else
			user << "Need more welding fuel!"
			return

	else if(istype(W, /obj/item/weapon/cable_coil) && wiresexposed)
		var/obj/item/weapon/cable_coil/coil = W
		adjustFireLoss(-30)
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
			user << "Close the cover first."
		else if(cell)
			user << "There is a power cell already installed."
		else
			user.drop_item()
			W.loc = src
			cell = W
			user << "You insert the power cell."
//			chargecount = 0
		updateicon()

	else if (istype(W, /obj/item/weapon/wirecutters) || istype(W, /obj/item/device/multitool) || istype(W, /obj/item/device/assembly/signaler))
		if (wiresexposed)
			wires.Interact(user)
		else
			user << "You can't reach the wiring."

	else if(istype(W, /obj/item/weapon/screwdriver) && opened && !cell)	// haxing
		wiresexposed = !wiresexposed
		user << "The wires have been [wiresexposed ? "exposed" : "unexposed"]"
		updateicon()

	else if(istype(W, /obj/item/weapon/screwdriver) && opened && cell)	// radio
		if(radio)
			radio.attackby(W,user)//Push it to the radio to let it handle everything
		else
			user << "Unable to locate a radio."
		updateicon()

	else if(istype(W, /obj/item/weapon/wrench) && opened && !cell) //Deconstruction. The flashes break from the fall, to prevent this from being a ghetto reset module.
		if(!lockcharge)
			user << "\red <b>[src]'s bolts spark! Maybe you should lock them down first!</b>"
			spark_system.start()
			return
		else
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user, 50) && !cell)
				user.visible_message("\red [user] deconstructs [src]!", "\blue You unfasten the securing bolts, and [src] falls to pieces!")
				deconstruct()

	else if(istype(W, /obj/item/device/encryptionkey/) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(W,user)//GTFO, you have your own procs
		else
			user << "Unable to locate a radio."

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))			// trying to unlock the interface with an ID card
		if(emagged)//still allow them to open the cover
			user << "The interface seems slightly damaged"
		if(opened)
			user << "You must close the cover to swipe an ID card."
		else
			if(allowed(usr))
				locked = !locked
				user << "You [ locked ? "lock" : "unlock"] [src]'s cover."
				updateicon()
			else
				user << "\red Access denied."

	else if(istype(W, /obj/item/weapon/card/emag))		// trying to unlock with an emag card
		if(!opened)//Cover is closed
			if(locked)
				if(prob(90))
					user << "You emag the cover lock."
					locked = 0
				else
					user << "You fail to emag the cover lock."
					if(prob(25))
						src << "Hack attempt detected."
			else
				user << "The cover is already unlocked."
			return

		if(opened)//Cover is open
			if(emagged)	return//Prevents the X has hit Y with Z message also you cant emag them twice
			if(wiresexposed)
				user << "You must close the cover first"
				return
			else
				sleep(6)
				if(prob(50))
					emagged = 1
					lawupdate = 0
					connected_ai = null
					user << "You emag [src]'s interface."
//					message_admins("[key_name_admin(user)] emagged cyborg [key_name_admin(src)].  Laws overridden.")
					log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
					clear_supplied_laws()
					clear_inherent_laws()
					laws = new /datum/ai_laws/syndicate_override
					var/time = time2text(world.realtime,"hh:mm:ss")
					lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
					set_zeroth_law("Only [user.real_name] and people he designates as being such are Syndicate Agents.")
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
					src << "\red > N"
					sleep(20)
					src << "\red ERRORERRORERROR"
					src << "<b>Obey these laws:</b>"
					laws.show_laws(src)
					src << "\red \b ALERT: [user.real_name] is your new master. Obey your new laws and his commands."
					if(src.module && istype(src.module, /obj/item/weapon/robot_module/miner))
						for(var/obj/item/weapon/pickaxe/borgdrill/D in src.module.modules)
							del(D)
						src.module.modules += new /obj/item/weapon/pickaxe/diamonddrill(src.module)
						src.module.rebuild()
					updateicon()
				else
					user << "You fail to [ locked ? "unlock" : "lock"] [src]'s interface."
					if(prob(25))
						src << "Hack attempt detected."
			return

	else if(istype(W, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = W
		if(!opened)
			usr << "You must access the borgs internals!"
		else if(!src.module && U.require_module)
			usr << "The borg must choose a module before he can be upgraded!"
		else if(U.locked)
			usr << "The upgrade is locked and cannot be used yet!"
		else
			if(U.action(src))
				usr << "You apply the upgrade to [src]!"
				usr.drop_item()
				U.loc = src
			else
				usr << "Upgrade error!"


	else
		spark_system.start()
		return ..()

/mob/living/silicon/robot/verb/unlock_own_cover()
	set category = "Robot Commands"
	set name = "Unlock Cover"
	set desc = "Unlocks your own cover if it is locked. You can not lock it again. A human will have to lock it for you."
	if(locked)
		switch(alert("You can not lock your cover again, are you sure?\n      (You can still ask for a human to lock it)", "Unlock Own Cover", "Yes", "No"))
			if("Yes")
				locked = 0
				updateicon()
				usr << "You unlock your cover."

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
			if (M == src || anchored)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src )

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)

		if ("harm")
			var/damage = rand(10, 20)
			if (prob(90))
				/*
				if (M.class == "combat")
					damage += 15
					if(prob(20))
						weakened = max(weakened,4)
						stunned = max(stunned,4)
				What is this?*/

				playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>[] has slashed at []!</B>", M, src), 1)
				if(prob(8))
					flick("noise", flash)
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] took a swipe at []!</B>", M, src), 1)

		if ("disarm")
			if(!(lying))
				if (rand(1,100) <= 85)
					Stun(7)
					step(src,get_dir(M,src))
					spawn(5) step(src,get_dir(M,src))
					playsound(loc, 'sound/weapons/pierce.ogg', 50, 1, -1)
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has forced back []!</B>", M, src), 1)
				else
					playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] attempted to force back []!</B>", M, src), 1)
	return



/mob/living/silicon/robot/attack_slime(mob/living/carbon/slime/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if(M.Victim) return // can't attack while eating!

	if (health > -100)

		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>The [M.name] glomps []!</B>", src), 1)

		var/damage = rand(1, 3)

		if(istype(src, /mob/living/carbon/slime/adult))
			damage = rand(20, 40)
		else
			damage = rand(5, 35)

		damage = round(damage / 2) // borgs recieve half damage
		adjustBruteLoss(damage)


		if(M.powerlevel > 0)
			var/stunprob = 10

			switch(M.powerlevel)
				if(1 to 2) stunprob = 20
				if(3 to 4) stunprob = 30
				if(5 to 6) stunprob = 40
				if(7 to 8) stunprob = 60
				if(9) 	   stunprob = 70
				if(10) 	   stunprob = 95

			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>The [M.name] has electrified []!</B>", src), 1)

				flick("noise", flash)

				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()

				if (prob(stunprob) && M.powerlevel >= 8)
					adjustBruteLoss(M.powerlevel * rand(6,10))


		updatehealth()

	return

/mob/living/silicon/robot/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[M]</B> [M.attacktext] [src]!", 1)
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		updatehealth()


/mob/living/silicon/robot/attack_hand(mob/user)

	add_fingerprint(user)

	if(opened && !wiresexposed && (!istype(user, /mob/living/silicon)))
		if(cell)
			cell.updateicon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			user << "You remove \the [cell]."
			cell = null
			updateicon()

	if(!opened && (!istype(user, /mob/living/silicon)))
		if (user.a_intent == "help")
			user.visible_message("<span class='notice'>[user] pets [src]!</span>", \
								"<span class='notice'>You pet [src]!</span>")

/mob/living/silicon/robot/attack_paw(mob/user)

	return attack_hand(user)

/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access(null))
		return 1
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_hand()) || check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/george = M
		//they can only hold things :(
		if(george.get_active_hand() && istype(george.get_active_hand(), /obj/item/weapon/card/id) && check_access(george.get_active_hand()))
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

	overlays.Cut()
	if(stat == 0)
		overlays += "eyes"
		if(icon_state == "robot")
			overlays.Cut()
			overlays += "eyes-standard"
		if(icon_state == "toiletbot")
			overlays.Cut()
			overlays += "eyes-toiletbot"
		if(icon_state == "bloodhound")
			overlays.Cut()
			overlays += "eyes-bloodhound"
		if(icon_state =="landmate")
			overlays.Cut()
			overlays += "eyes-landmate"
		if(icon_state =="mopgearrex")
			overlays.Cut()
			overlays += "eyes-mopgearrex"
		if(icon_state =="Miner" || icon_state =="Miner+j")
			overlays.Cut()
			overlays += "eyes-Miner"
	else
		overlays -= "eyes"

	if(opened)
		if(wiresexposed)
			overlays += "ov-opencover +w"
		else if(cell)
			overlays += "ov-opencover +c"
		else
			overlays += "ov-opencover -c"

	update_fire()
	return



/mob/living/silicon/robot/proc/installed_modules()
	if(weapon_lock)
		src << "\red Weapon lock active, unable to use modules! Count:[weaponlock_time]"
		return

	if(!module)
		pick_module()
		return
	var/dat = {"<A HREF='?src=\ref[src];mach_close=robotmod'>Close</A>
	<BR>
	<BR>
	<B>Activated Modules</B>
	<BR>
	<table border='0'>
	<tr><td>Module 1:</td><td>[module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]</td></tr>
	<tr><td>Module 2:</td><td>[module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]</td></tr>
	<tr><td>Module 3:</td><td>[module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]</td></tr>
	</table><BR>
	<B>Installed Modules</B><BR><BR>

	<table border='0'>"}

	for (var/obj in module.modules)
		if (!obj)
			dat += text("<tr><td><B>Resource depleted</B></td></tr>")
		else if(activated(obj))
			dat += text("<tr><td>[obj]</td><td><B>Activated</B></td></tr>")
		else
			dat += text("<tr><td>[obj]</td><td><A HREF=?src=\ref[src];act=\ref[obj]>Activate</A></td></tr>")
	if (emagged)
		if(activated(module.emag))
			dat += text("<tr><td>[module.emag]</td><td><B>Activated</B></td></tr>")
		else
			dat += text("<tr><td>[module.emag]</td><td><A HREF=?src=\ref[src];act=\ref[module.emag]>Activate</A></td></tr>")
	dat += "</table>"
/*
		if(activated(obj))
			dat += text("[obj]: \[<B>Activated</B> | <A HREF=?src=\ref[src];deact=\ref[obj]>Deactivate</A>\]<BR>")
		else
			dat += text("[obj]: \[<A HREF=?src=\ref[src];act=\ref[obj]>Activate</A> | <B>Deactivated</B>\]<BR>")
*/
	var/datum/browser/popup = new(src, "robotmod", "Modules")
	popup.set_content(dat)
	popup.open()


/mob/living/silicon/robot/Topic(href, href_list)
	..()
	if(usr && (src != usr))
		return

	if (href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)
		return

	if (href_list["showalerts"])
		robot_alerts()
		return

	if (href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		if (O)
			O.attack_self(src)

	if (href_list["act"])
		var/obj/item/O = locate(href_list["act"])
		if(!(locate(O) in src.module.modules) && O != src.module.emag)
			return
		if(activated(O))
			src << "Already activated"
			return
		if(!module_state_1)
			module_state_1 = O
			O.layer = 20
			contents += O
			if(istype(module_state_1,/obj/item/borg/sight))
				sight_mode |= module_state_1:sight_mode
		else if(!module_state_2)
			module_state_2 = O
			O.layer = 20
			contents += O
			if(istype(module_state_2,/obj/item/borg/sight))
				sight_mode |= module_state_2:sight_mode
		else if(!module_state_3)
			module_state_3 = O
			O.layer = 20
			contents += O
			if(istype(module_state_3,/obj/item/borg/sight))
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

/mob/living/silicon/robot/proc/radio_menu()
	radio.interact(src)//Just use the radio's Topic() instead of bullshit special-snowflake code


/mob/living/silicon/robot/Move(a, b, flag)

	. = ..()

	if(module)
		if(module.type == /obj/item/weapon/robot_module/janitor)
			var/turf/tile = loc
			if(isturf(tile))
				tile.clean_blood()
				for(var/A in tile)
					if(istype(A, /obj/effect))
						if(istype(A, /obj/effect/rune) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay))
							del(A)
					else if(istype(A, /obj/item))
						var/obj/item/cleaned_item = A
						cleaned_item.clean_blood()
					else if(istype(A, /mob/living/carbon/human))
						var/mob/living/carbon/human/cleaned_human = A
						if(cleaned_human.lying)
							if(cleaned_human.head)
								cleaned_human.head.clean_blood()
								cleaned_human.update_inv_head(0)
							if(cleaned_human.wear_suit)
								cleaned_human.wear_suit.clean_blood()
								cleaned_human.update_inv_wear_suit(0)
							else if(cleaned_human.w_uniform)
								cleaned_human.w_uniform.clean_blood()
								cleaned_human.update_inv_w_uniform(0)
							if(cleaned_human.shoes)
								cleaned_human.shoes.clean_blood()
								cleaned_human.update_inv_shoes(0)
							cleaned_human.clean_blood()
							cleaned_human << "\red [src] cleans your face!"
		return

/mob/living/silicon/robot/proc/self_destruct()
	gib()
	return

/mob/living/silicon/robot/proc/UnlinkSelf()
	if (src.connected_ai)
		src.connected_ai = null
	lawupdate = 0
	lockcharge = 0
	canmove = 1
	scrambledcodes = 1
	//Disconnect it's camera so it's not so easily tracked.
	if(src.camera)
		del(src.camera)
		src.camera = null
		// I'm trying to get the Cyborg to not be listed in the camera list
		// Instead of being listed as "deactivated". The downside is that I'm going
		// to have to check if every camera is null or not before doing anything, to prevent runtime errors.
		// I could change the network to null but I don't know what would happen, and it seems too hacky for me.


/mob/living/silicon/robot/proc/ResetSecurityCodes()
	set category = "Robot Commands"
	set name = "Reset Identity Codes"
	set desc = "Scrambles your security and identification codes and resets your current buffers.  Unlocks you and but permenantly severs you from your AI and the robotics console and will deactivate your camera system."

	var/mob/living/silicon/robot/R = src

	if(R)
		R.UnlinkSelf()
		R << "Buffers flushed and reset. Camera system shutdown.  All systems operational."
		src.verbs -= /mob/living/silicon/robot/proc/ResetSecurityCodes

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	var/obj/item/W = get_active_hand()
	if (W)
		W.attack_self(src)

	return

/mob/living/silicon/robot/proc/SetLockdown(var/state = 1)
	// They stay locked down if their wire is cut.
	if(wires.LockedCut())
		state = 1
	lockcharge = state
	update_canmove()



/mob/living/silicon/robot/verb/outputlaws()
	set category = "Robot Commands"
	set name = "State Laws"

	checklaws()

/mob/living/silicon/robot/proc/deconstruct()
	var/turf/T = get_turf(src)
	if (robot_suit)
		robot_suit.loc = T
		robot_suit.l_leg.loc = T
		robot_suit.l_leg = null
		robot_suit.r_leg.loc = T
		robot_suit.r_leg = null
		new /obj/item/weapon/cable_coil(T, robot_suit.chest.wires)
		robot_suit.chest.loc = T
		robot_suit.chest.wires = 0.0
		robot_suit.chest = null
		robot_suit.l_arm.loc = T
		robot_suit.l_arm = null
		robot_suit.r_arm.loc = T
		robot_suit.r_arm = null
		robot_suit.head.loc = T
		robot_suit.head.flash1.loc = T
		robot_suit.head.flash1.burn_out()
		robot_suit.head.flash1 = null
		robot_suit.head.flash2.loc = T
		robot_suit.head.flash2.burn_out()
		robot_suit.head.flash2 = null
		robot_suit.head = null
		robot_suit.updateicon()
	else
		new /obj/item/robot_parts/robot_suit(T)
		new /obj/item/robot_parts/l_leg(T)
		new /obj/item/robot_parts/r_leg(T)
		new /obj/item/weapon/cable_coil(T, 1)
		new /obj/item/robot_parts/chest(T)
		new /obj/item/robot_parts/l_arm(T)
		new /obj/item/robot_parts/r_arm(T)
		new /obj/item/robot_parts/head(T)
		var/b
		for(b=0, b!=2, b++)
			var/obj/item/device/flash/F = new /obj/item/device/flash(T)
			F.burn_out()
	if (cell) //Sanity check.
		cell.loc = T
		cell = null
	del(src)
