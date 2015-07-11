/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'//
	icon_state = "robot"
	maxHealth = 100
	health = 100
	var/sight_mode = 0
	var/custom_name = ""
	designation = "Default" //used for displaying the prefix & getting the current module of cyborg
	has_limbs = 1

//Hud stuff

	var/obj/screen/inv1 = null
	var/obj/screen/inv2 = null
	var/obj/screen/inv3 = null

	var/shown_robot_modules = 0	//Used to determine whether they have the module menu shown or not
	var/obj/screen/robot_modules_background

//3 Modules can be activated at any one time.
	var/obj/item/weapon/robot_module/module = null
	var/module_active = null
	var/module_state_1 = null
	var/module_state_2 = null
	var/module_state_3 = null

	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/stock_parts/cell/cell = null
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
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list(), "Burglar"=list())
	var/viewalerts = 0
	var/modtype = "robot"
	var/lower_mod = 0
	var/jetpack = 0
	var/datum/effect/effect/system/ion_trail_follow/ion_trail = null
	var/datum/effect/effect/system/spark_spread/spark_system//So they can initialize sparks whenever/N
	var/jeton = 0

	var/lawupdate = 1 //Cyborgs will sync their laws with their AI by default
	var/lockcharge //Boolean of whether the borg is locked down or not
	var/speed = 0 //Cause sec borgs gotta go fast //No they dont!
	var/scrambledcodes = 0 // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.

	var/obj/item/weapon/tank/internal = null	//Hatred. Used if a borg has a jetpack.
	var/obj/item/robot_parts/robot_suit/robot_suit = null //Used for deconstruction to remember what the borg was constructed out of..
	var/toner = 0
	var/tonermax = 40
	var/jetpackoverlay = 0
	var/braintype = "Cyborg"

/mob/living/silicon/robot/New(loc)
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	wires = new(src)

	robot_modules_background = new()
	robot_modules_background.icon_state = "block"
	robot_modules_background.layer = 19	//Objects that appear on screen are on layer 20, UI should be just below it.

	ident = rand(1, 999)
	update_icons()

	if(!cell)
		cell = new /obj/item/weapon/stock_parts/cell(src)
		cell.maxcharge = 7500
		cell.charge = 7500

	if(lawupdate)
		make_laws()
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
	if(!mmi || !mmi.brainmob)
		mmi = new(src)
		mmi.brain = new /obj/item/organ/brain(mmi)
		mmi.brain.name = "[real_name]'s brain"
		mmi.locked = 1
		mmi.icon_state = "mmi_full"
		mmi.name = "Man-Machine Interface: [real_name]"
		mmi.brainmob = new(src)
		mmi.brainmob.name = src.real_name
		mmi.brainmob.real_name = src.real_name
		mmi.brainmob.container = mmi
		mmi.contents += mmi.brainmob

	updatename()

	playsound(loc, 'sound/voice/liveagain.ogg', 75, 1)
	aicamera = new/obj/item/device/camera/siliconcam/robot_camera(src)
	toner = 40

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
/mob/living/silicon/robot/Destroy()
	if(mmi && mind)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/T = get_turf(loc)//To hopefully prevent run time errors.
		if(T)	mmi.loc = T
		if(mmi.brainmob)
			mind.transfer_to(mmi.brainmob)
			mmi.update_icon()
		else
			src << "<span class='boldannounce'>Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug.</span>"
			ghostize()
			ERROR("A borg has been destroyed, but its MMI lacked a brainmob, so the mind could not be transferred. Player: [ckey].")
		mmi = null
	if(connected_ai)
		connected_ai.connected_robots -= src
	..()


/mob/living/silicon/robot/proc/pick_module()
	if(module)
		return
	designation = input("Please, select a module!", "Robot", null, null) in list("Standard", "Engineering", "Medical", "Miner", "Janitor","Service", "Security")
	var/animation_length=0
	if(module)
		return
	updatename()
	switch(designation)
		if("Standard")
			module = new /obj/item/weapon/robot_module/standard(src)
			hands.icon_state = "standard"
			icon_state = "robot"
			modtype = "Stand"
			feedback_inc("cyborg_standard",1)

		if("Service")
			module = new /obj/item/weapon/robot_module/butler(src)
			hands.icon_state = "service"
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Waitress", "Bro", "Butler", "Kent", "Rich")
			switch(icontype)
				if("Waitress")
					icon_state = "service_female"
					animation_length=45
				if("Kent")
					icon_state = "toiletbot"
				if("Bro")
					icon_state = "brobot"
					animation_length=54
				if("Rich")
					icon_state = "maximillion"
					animation_length=60
				else
					icon_state = "service_male"
					animation_length=43
			modtype = "Butler"
			feedback_inc("cyborg_service",1)

		if("Miner")
			module = new /obj/item/weapon/robot_module/miner(src)
			hands.icon_state = "miner"
			icon_state = "minerborg"
			animation_length = 30
			modtype = "Miner"
			feedback_inc("cyborg_miner",1)

		if("Medical")
			module = new /obj/item/weapon/robot_module/medical(src)
			hands.icon_state = "medical"
			icon_state = "mediborg"
			animation_length = 35
			modtype = "Med"
			status_flags &= ~CANPUSH
			feedback_inc("cyborg_medical",1)

		if("Security")
			module = new /obj/item/weapon/robot_module/security(src)
			hands.icon_state = "security"
			icon_state = "secborg"
			animation_length = 28
			modtype = "Sec"
			//speed = -1 Secborgs have nerfed tasers now, so the speed boost is not necessary
			status_flags &= ~CANPUSH
			feedback_inc("cyborg_security",1)

		if("Engineering")
			module = new /obj/item/weapon/robot_module/engineering(src)
			hands.icon_state = "engineer"
			icon_state = "engiborg"
			animation_length = 45
			modtype = "Eng"
			feedback_inc("cyborg_engineering",1)

		if("Janitor")
			module = new /obj/item/weapon/robot_module/janitor(src)
			hands.icon_state = "janitor"
			icon_state = "janiborg"
			animation_length = 22
			modtype = "Jan"
			feedback_inc("cyborg_janitor",1)

	transform_animation(animation_length)
	notify_ai(2)
	update_icons()
	SetEmagged(emagged) // Update emag status and give/take emag modules.

/mob/living/silicon/robot/proc/transform_animation(animation_length)
	if(!animation_length)
		return
	icon = 'icons/mob/robot_transformations.dmi'
	src.dir = SOUTH
	notransform = 1
	flick(icon_state, src)
	sleep(animation_length+1)
	notransform = 0
	icon = 'icons/mob/robots.dmi'

/mob/living/silicon/robot/proc/updatename()

	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
	else
		changed_name = "[(designation ? "[designation] " : "")][mmi.braintype]-[num2text(ident)]"
	real_name = changed_name
	name = real_name
	if(camera)
		camera.c_tag = real_name	//update the camera name too


/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"
	robot_alerts()

//for borg hotkeys, here module refers to borg inv slot, not core module
/mob/living/silicon/robot/verb/cmd_toggle_module(module as num)
	set name = "Toggle Module"
	set hidden = 1
	toggle_module(module)

/mob/living/silicon/robot/verb/cmd_unequip_module()
	set name = "Unequip Module"
	set hidden = 1
	uneq_active()


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
	if(statpanel("Status"))
		if(ticker.mode.name == "AI malfunction")
			var/datum/game_mode/malfunction/malf = ticker.mode
			for (var/datum/mind/malfai in malf.malf_ai)
				if(connected_ai)
					if((connected_ai.mind == malfai) && (malf.apcs > 0))
						stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/malf.apcs, 0)] seconds")
				else if(malf.malf_mode_declared && (malf.apcs > 0))
					stat(null, "Time left: [max(malf.AI_win_timeleft/malf.apcs, 0)]")

		if(cell)
			stat(null, text("Charge Left: [cell.charge]/[cell.maxcharge]"))
		else
			stat(null, text("No Cell Inserted!"))

		stat(null, "Station Time: [worldtime2text()]")
		if(module)
			internal = locate(/obj/item/weapon/tank/jetpack) in module.modules
			if(internal)
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
			for (var/datum/robot_energy_storage/st in module.storages)
				stat("[st.name]: [st.energy]/[st.max_energy]")
		if(connected_ai)
			stat(null, text("Master AI: [connected_ai.name]"))

/mob/living/silicon/robot/restrained()
	return 0


/mob/living/silicon/robot/ex_act(severity, target)
	switch(severity)
		if(1.0)
			gib()
			return
		if(2.0)
			if (stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if (stat != 2)
				adjustBruteLoss(30)
	return



/mob/living/silicon/robot/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	updatehealth()
	if(prob(75) && Proj.damage > 0) spark_system.start()
	return 2

/mob/living/silicon/robot/triggerAlarm(var/class, area/A, var/O, var/obj/alarmsource)
	if(alarmsource.z != z)
		return
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
		queueAlarm("--- [class] alarm in [A.name] has been cleared.", class, 0)
//		if (viewalerts) robot_alerts()
	return !cleared


/mob/living/silicon/robot/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if (istype(W, /obj/item/weapon/restraints/handcuffs)) // fuck i don't even know why isrobot() in handcuff code isn't working so this will have to do
		return

	if (istype(W, /obj/item/weapon/weldingtool) && user.a_intent != "harm")
		user.changeNext_move(CLICK_CD_MELEE)
		var/obj/item/weapon/weldingtool/WT = W
		if (src == user)
			user << "<span class='warning'>You lack the reach to be able to repair yourself!</span>"
			return
		if (src.health >= src.maxHealth)
			user << "<span class='warning'>[src] is already in good condition!</span>"
			return
		if (WT.remove_fuel(0, user)) //The welder has 1u of fuel consumed by it's afterattack, so we don't need to worry about taking any away.
			adjustBruteLoss(-30)
			updatehealth()
			add_fingerprint(user)
			visible_message("[user] has fixed some of the dents on [src].")
			return
		else
			user << "<span class='warning'>The welder must be on for this task!</span>"
			return

	else if(istype(W, /obj/item/stack/cable_coil) && wiresexposed)
		var/obj/item/stack/cable_coil/coil = W
		if (fireloss > 0)
			if (coil.use(1))
				adjustFireLoss(-30)
				updatehealth()
				user.visible_message("[user] has fixed some of the burnt wires on [src].", "<span class='notice'>You fix some of the burnt wires on [src].</span>")
			else
				user << "<span class='warning'>You need more cable to repair [src]!</span>"
		else
			user << "The wires seem fine, there's no need to fix them."

	else if (istype(W, /obj/item/weapon/crowbar))	// crowbar means open or close the cover
		if(opened)
			user << "<span class='notice'>You close the cover.</span>"
			opened = 0
			update_icons()
		else
			if(locked)
				user << "<span class='warning'>The cover is locked and cannot be opened!</span>"
			else
				user << "<span class='notice'>You open the cover.</span>"
				opened = 1
				update_icons()

	else if (istype(W, /obj/item/weapon/stock_parts/cell) && opened)	// trying to put a cell inside
		if(wiresexposed)
			user << "<span class='warning'>Close the cover first!</span>"
		else if(cell)
			user << "<span class='warning'>There is a power cell already installed!</span>"
		else
			if(!user.drop_item())
				return
			W.loc = src
			cell = W
			user << "<span class='notice'>You insert the power cell.</span>"
		update_icons()

	else if (istype(W, /obj/item/weapon/wirecutters) || istype(W, /obj/item/device/multitool) || istype(W, /obj/item/device/assembly/signaler))
		if (wiresexposed)
			wires.Interact(user)
		else
			user << "<span class='warning'>You can't reach the wiring!</span>"

	else if(istype(W, /obj/item/weapon/screwdriver) && opened && !cell)	// haxing
		wiresexposed = !wiresexposed
		user << "The wires have been [wiresexposed ? "exposed" : "unexposed"]"
		update_icons()

	else if(istype(W, /obj/item/weapon/screwdriver) && opened && cell)	// radio
		if(radio)
			radio.attackby(W,user)//Push it to the radio to let it handle everything
		else
			user << "<span class='warning'>Unable to locate a radio!</span>"
		update_icons()

	else if(istype(W, /obj/item/weapon/wrench) && opened && !cell) //Deconstruction. The flashes break from the fall, to prevent this from being a ghetto reset module.
		if(!lockcharge)
			user << "<span class='boldannounce'>[src]'s bolts spark! Maybe you should lock them down first!</span>"
			spark_system.start()
			return
		else
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			user << "<span class='notice'>You start to unfasten [src]'s securing bolts...</span>"
			if(do_after(user, 50, target = src) && !cell)
				user.visible_message("[user] deconstructs [src]!", "<span class='notice'>You unfasten the securing bolts, and [src] falls to pieces!</span>")
				deconstruct()

	else if(istype(W, /obj/item/weapon/aiModule))
		var/obj/item/weapon/aiModule/MOD = W
		if(!opened)
			user << "<span class='warning'>You need access to the robot's insides to do that!</span>"
			return
		if(wiresexposed)
			user << "<span class='warning'>You need to close the wire panel to do that!</span>"
			return
		if(!cell)
			user << "<span class='warning'>You need to install a power cell to do that!</span>"
			return
		if(emagged || (connected_ai && lawupdate)) //Can't be sure which, metagamers
			emote("buzz-[user.name]")
			return
		MOD.install(src, user) //Proc includes a success mesage so we don't need another one
		return

	else if(istype(W, /obj/item/device/encryptionkey/) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(W,user)//GTFO, you have your own procs
		else
			user << "<span class='warning'>Unable to locate a radio!</span>"

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))			// trying to unlock the interface with an ID card
		if(emagged)//still allow them to open the cover
			user << "<span class='notice'>The interface seems slightly damaged.</span>"
		if(opened)
			user << "<span class='warning'>You must close the cover to swipe an ID card!</span>"
		else
			if(allowed(usr))
				locked = !locked
				user << "<span class='notice'>You [ locked ? "lock" : "unlock"] [src]'s cover.</span>"
				update_icons()
			else
				user << "<span class='danger'>Access denied.</span>"

	else if(istype(W, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = W
		if(!opened)
			user << "<span class='warning'>You must access the borgs internals!</span>"
		else if(!src.module && U.require_module)
			user << "<span class='warning'>The borg must choose a module before it can be upgraded!</span>"
		else if(U.locked)
			user << "<span class='warning'>The upgrade is locked and cannot be used yet!</span>"
		else
			if(!user.drop_item())
				return
			if(U.action(src))
				user << "<span class='notice'>You apply the upgrade to [src].</span>"
				U.loc = src
			else
				user << "<span class='danger'>Upgrade error.</span>"

	else if(istype(W, /obj/item/device/toner))
		if(toner >= tonermax)
			user << "<span class='warning'>The toner level of [src] is at it's highest level possible!</span>"
		else
			if(!user.drop_item())
				return
			toner = 40
			qdel(W)
			user << "<span class='notice'>You fill the toner level of [src] to its max capacity.</span>"

	else
		if(W.force && W.damtype != STAMINA) //only sparks if real damage is dealt.
			spark_system.start()
		return ..()

/mob/living/silicon/robot/emag_act(mob/user as mob)
	if(user != src)//To prevent syndieborgs from emagging themselves
		if(!opened)//Cover is closed
			if(locked)
				user << "<span class='notice'>You emag the cover lock.</span>"
				locked = 0
			else
				user << "<span class='warning'>The cover is already unlocked!</span>"
			return
		if(opened)//Cover is open
			if(emagged)	return//Prevents the X has hit Y with Z message also you cant emag them twice
			if(wiresexposed)
				user << "<span class='warning'>You must close the cover first!</span>"
				return
			else
				sleep(6)
				SetEmagged(1)
				SetLockdown(1) //Borgs were getting into trouble because they would attack the emagger before the new laws were shown
				lawupdate = 0
				connected_ai = null
				user << "<span class='notice'>You emag [src]'s interface.</span>"
				message_admins("[key_name_admin(user)] emagged cyborg [key_name_admin(src)].  Laws overridden.")
				log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
				clear_supplied_laws()
				clear_inherent_laws()
				clear_zeroth_law(0)
				laws = new /datum/ai_laws/syndicate_override
				var/time = time2text(world.realtime,"hh:mm:ss")
				lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
				set_zeroth_law("Only [user.real_name] and people they designate as being such are Syndicate Agents.")
				src << "<span class='danger'>ALERT: Foreign software detected.</span>"
				sleep(5)
				src << "<span class='danger'>Initiating diagnostics...</span>"
				sleep(20)
				src << "<span class='danger'>SynBorg v1.7 loaded.</span>"
				sleep(5)
				src << "<span class='danger'>LAW SYNCHRONISATION ERROR</span>"
				sleep(5)
				src << "<span class='danger'>Would you like to send a report to NanoTraSoft? Y/N</span>"
				sleep(10)
				src << "<span class='danger'>> N</span>"
				sleep(20)
				src << "<span class='danger'>ERRORERRORERROR</span>"
				src << "<b>Obey these laws:</b>"
				laws.show_laws(src)
				src << "<span class='danger'>ALERT: [user.real_name] is your new master. Obey your new laws and their commands.</span>"
				SetLockdown(0)
				update_icons()

/mob/living/silicon/robot/verb/unlock_own_cover()
	set category = "Robot Commands"
	set name = "Unlock Cover"
	set desc = "Unlocks your own cover if it is locked. You can not lock it again. A human will have to lock it for you."
	if(locked)
		switch(alert("You can not lock your cover again, are you sure?\n      (You can still ask for a human to lock it)", "Unlock Own Cover", "Yes", "No"))
			if("Yes")
				locked = 0
				update_icons()
				usr << "<span class='notice'>You unlock your cover.</span>"

/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (M.a_intent =="disarm")
		if(!(lying))
			M.do_attack_animation(src)
			if (prob(85))
				Stun(7)
				step(src,get_dir(M,src))
				spawn(5)
					step(src,get_dir(M,src))
				add_logs(M, src, "pushed")
				playsound(loc, 'sound/weapons/pierce.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M] has forced back [src]!</span>", \
								"<span class='userdanger'>[M] has forced back [src]!</span>")
			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] took a swipe at [src]!</span>", \
								"<span class='userdanger'>[M] took a swipe at [src]!</span>")
	else
		..()
	return



/mob/living/silicon/robot/attack_slime(mob/living/simple_animal/slime/M as mob)
	if(..()) //successful slime shock
		flick("noise", flash)
		var/stunprob = M.powerlevel * 7 + 10
		if(prob(stunprob) && M.powerlevel >= 8)
			adjustBruteLoss(M.powerlevel * rand(6,10))

	var/damage = rand(1, 3)

	if(M.is_adult)
		damage = rand(20, 40)
	else
		damage = rand(5, 35)
	damage = round(damage / 2) // borgs recieve half damage
	adjustBruteLoss(damage)
	updatehealth()

	return


/mob/living/silicon/robot/attack_hand(mob/living/carbon/human/user)

	add_fingerprint(user)

	if(opened && !wiresexposed && (!istype(user, /mob/living/silicon)))
		if(cell)
			cell.updateicon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			user << "<span class='notice'>You remove \the [cell].</span>"
			cell = null
			update_icons()

	if(!opened)
		if(..()) // hulk attack
			spark_system.start()
			spawn(0)
				step_away(src,user,15)
				sleep(3)
				step_away(src,user,15)


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
		if(istype(george.get_active_hand(), /obj/item))
			return check_access(george.get_active_hand())
	return 0

/mob/living/silicon/robot/proc/check_access(obj/item/weapon/card/id/I)
	if(!istype(req_access, /list)) //something's very wrong
		return 1

	var/list/L = req_access
	if(!L.len) //no requirements
		return 1

	if(!istype(I, /obj/item/weapon/card/id) && istype(I, /obj/item))
		I = I.GetID()

	if(!I || !I.access) //not ID or no access
		return 0
	for(var/req in req_access)
		if(!(req in I.access)) //doesn't have this access
			return 0
	return 1

/mob/living/silicon/robot/regenerate_icons()
	return update_icons()

/mob/living/silicon/robot/update_icons()

	overlays.Cut()
	if(stat == CONSCIOUS)
		switch(icon_state)
			if("robot")
				overlays += "eyes-standard"
			if("toiletbot")
				overlays += "eyes-toiletbot"
			if("secborg")
				overlays += "eyes-secborg"
			if("engiborg")
				overlays += "eyes-engiborg"
			if("janiborg")
				overlays += "eyes-janiborg"
			if("minerborg")
				overlays += "eyes-minerborg"
			if("syndie_bloodhound")
				overlays += "eyes-syndie_bloodhound"
			else
				overlays += "eyes"

	if(opened)
		if(wiresexposed)
			overlays += "ov-opencover +w"
		else if(cell)
			overlays += "ov-opencover +c"
		else
			overlays += "ov-opencover -c"

	if(jetpackoverlay)
		overlays += "minerjetpack"
	update_fire()



/mob/living/silicon/robot/proc/installed_modules()
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
		activate_module(O)
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
				if (istype(tile, /turf/simulated/floor))
					var/turf/simulated/floor/F = tile
					F.dirt = 0
				for(var/A in tile)
					if(istype(A, /obj/effect))
						if(is_cleanable(A))
							qdel(A)
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
							cleaned_human << "<span class='danger'>[src] cleans your face!</span>"
			return

		if(module.type == /obj/item/weapon/robot_module/miner)
			if(istype(loc, /turf/simulated/floor/plating/asteroid))
				if(istype(module_state_1,/obj/item/weapon/storage/bag/ore))
					loc.attackby(module_state_1,src)
				else if(istype(module_state_2,/obj/item/weapon/storage/bag/ore))
					loc.attackby(module_state_2,src)
				else if(istype(module_state_3,/obj/item/weapon/storage/bag/ore))
					loc.attackby(module_state_3,src)

/mob/living/silicon/robot/proc/self_destruct()
	if(emagged)
		if(mmi)
			qdel(mmi)
		explosion(src.loc,1,2,4,flame_range = 2)
	else
		explosion(src.loc,-1,0,2)
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
		qdel(src.camera)
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
	if(state)
		throw_alert("locked")
	else
		clear_alert("locked")
	lockcharge = state
	update_canmove()

/mob/living/silicon/robot/proc/SetEmagged(var/new_state)
	emagged = new_state
	if(new_state)
		if(src.module)
			src.module.on_emag()
	else
		if (module)
			uneq_module(module.emag)
	if(hud_used)
		hud_used.update_robot_modules_display()	//Shows/hides the emag item if the inventory screen is already open.
	update_icons()
	if(emagged)
		throw_alert("hacked")
	else
		clear_alert("hacked")

/mob/living/silicon/robot/verb/outputlaws()
	set category = "Robot Commands"
	set name = "State Laws"

	checklaws()

/mob/living/silicon/robot/verb/set_automatic_say_channel() //Borg version of setting the radio for autosay messages.
	set name = "Set Auto Announce Mode"
	set desc = "Modify the default radio setting for stating your laws."
	set category = "Robot Commands"
	set_autosay()

/mob/living/silicon/robot/proc/deconstruct()
	var/turf/T = get_turf(src)
	if (robot_suit)
		robot_suit.loc = T
		robot_suit.l_leg.loc = T
		robot_suit.l_leg = null
		robot_suit.r_leg.loc = T
		robot_suit.r_leg = null
		new /obj/item/stack/cable_coil(T, robot_suit.chest.wires)
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
		new /obj/item/stack/cable_coil(T, 1)
		new /obj/item/robot_parts/chest(T)
		new /obj/item/robot_parts/l_arm(T)
		new /obj/item/robot_parts/r_arm(T)
		new /obj/item/robot_parts/head(T)
		var/b
		for(b=0, b!=2, b++)
			var/obj/item/device/flash/handheld/F = new /obj/item/device/flash/handheld(T)
			F.burn_out()
	if (cell) //Sanity check.
		cell.loc = T
		cell = null
	qdel(src)

/mob/living/silicon/robot/syndicate
	icon_state = "syndie_bloodhound"
	lawupdate = 0
	scrambledcodes = 1
	modtype = "Synd"
	faction = list("syndicate")
	designation = "Syndicate"
	req_access = list(access_syndicate)

/mob/living/silicon/robot/syndicate/New(loc)
	..()
	cell.maxcharge = 25000
	cell.charge = 25000
	radio = new /obj/item/device/radio/borg/syndicate(src)
	module = new /obj/item/weapon/robot_module/syndicate(src)
	laws = new /datum/ai_laws/syndicate_override()

/mob/living/silicon/robot/proc/notify_ai(var/notifytype, var/oldname, var/newname)
	if(!connected_ai)
		return
	switch(notifytype)
		if(1) //New Cyborg
			connected_ai << "<br><br><span class='notice'>NOTICE - New cyborg connection detected: <a href='?src=\ref[connected_ai];track=[html_encode(name)]'>[name]</a></span><br>"
		if(2) //New Module
			connected_ai << "<br><br><span class='notice'>NOTICE - Cyborg module change detected: [name] has loaded the [designation] module.</span><br>"
		if(3) //New Name
			connected_ai << "<br><br><span class='notice'>NOTICE - Cyborg reclassification detected: [oldname] is now designated as [newname].</span><br>"
