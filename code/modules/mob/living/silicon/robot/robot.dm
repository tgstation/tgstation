/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 100
	health = 100
	macro_default = "robot-default"
	macro_hotkeys = "robot-hotkeys"
	bubble_icon = "robot"
	designation = "Default" //used for displaying the prefix & getting the current module of cyborg
	has_limbs = 1

	var/custom_name = ""
	var/braintype = "Cyborg"
	var/obj/item/robot_suit/robot_suit = null //Used for deconstruction to remember what the borg was constructed out of..
	var/obj/item/device/mmi/mmi = null


//Hud stuff

	var/obj/screen/inv1 = null
	var/obj/screen/inv2 = null
	var/obj/screen/inv3 = null
	var/obj/screen/lamp_button = null
	var/obj/screen/thruster_button = null
	var/obj/screen/hands = null

	var/shown_robot_modules = 0	//Used to determine whether they have the module menu shown or not
	var/obj/screen/robot_modules_background

//3 Modules can be activated at any one time.
	var/obj/item/weapon/robot_module/module = null
	var/obj/item/module_active = null
	held_items = list(null, null, null) //we use held_items for the module holding, because that makes sense to do!

	var/image/eye_lights

	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/stock_parts/cell/cell = null
	var/obj/machinery/camera/camera = null

	var/opened = 0
	var/emagged = 0
	var/emag_cooldown = 0
	var/wiresexposed = 0

	var/ident = 0
	var/locked = 1
	var/list/req_access = list(access_robotics)

	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list(), "Burglar"=list())

	var/speed = 0 // VTEC speed boost.
	var/magpulse = FALSE // Magboot-like effect.
	var/ionpulse = FALSE // Jetpack-like effect.
	var/ionpulse_on = FALSE // Jetpack-like effect.
	var/datum/effect_system/trail_follow/ion/ion_trail // Ionpulse effect.

	var/low_power_mode = 0 //whether the robot has no charge left.
	var/datum/effect_system/spark_spread/spark_system // So they can initialize sparks whenever/N

	var/lawupdate = 1 //Cyborgs will sync their laws with their AI by default
	var/scrambledcodes = 0 // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.
	var/lockcharge //Boolean of whether the borg is locked down or not

	var/toner = 0
	var/tonermax = 40

	var/lamp_max = 10 //Maximum brightness of a borg lamp. Set as a var for easy adjusting.
	var/lamp_intensity = 0 //Luminosity of the headlamp. 0 is off. Higher settings than the minimum require power.
	var/lamp_recharging = 0 //Flag for if the lamp is on cooldown after being forcibly disabled.

	var/sight_mode = 0
	var/updating = 0 //portable camera camerachunk update
	hud_possible = list(ANTAG_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_BATT_HUD)

	var/list/upgrades = list()

	var/obj/item/hat
	var/hat_offset = -3
	var/list/equippable_hats = list(/obj/item/clothing/head/caphat,
	/obj/item/clothing/head/hardhat/cakehat,
	/obj/item/clothing/head/centhat,
	/obj/item/clothing/head/HoS,
	/obj/item/clothing/head/hopcap,
	/obj/item/clothing/head/wizard,
	/obj/item/clothing/head/nursehat,
	/obj/item/clothing/head/sombrero,
	/obj/item/clothing/head/witchunter_hat)

	can_buckle = TRUE
	buckle_lying = FALSE
	var/datum/riding/cyborg/riding_datum = null

/mob/living/silicon/robot/New(loc)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	wires = new /datum/wires/robot(src)

	robot_modules_background = new()
	robot_modules_background.icon_state = "block"
	robot_modules_background.layer = HUD_LAYER	//Objects that appear on screen are on layer ABOVE_HUD_LAYER, UI should be just below it.
	robot_modules_background.plane = HUD_PLANE

	ident = rand(1, 999)

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
		if(wires.is_cut(WIRE_CAMERA))
			camera.status = 0
	module = new /obj/item/weapon/robot_module(src)
	module.rebuild_modules()
	update_icons()
	..()

	//MMI stuff. Held togheter by magic. ~Miauw
	if(!mmi || !mmi.brainmob)
		mmi = new (src)
		mmi.brain = new /obj/item/organ/brain(mmi)
		mmi.brain.name = "[real_name]'s brain"
		mmi.icon_state = "mmi_full"
		mmi.name = "Man-Machine Interface: [real_name]"
		mmi.brainmob = new(mmi)
		mmi.brainmob.name = src.real_name
		mmi.brainmob.real_name = src.real_name
		mmi.brainmob.container = mmi

	updatename()

	equippable_hats = typecacheof(equippable_hats)

	playsound(loc, 'sound/voice/liveagain.ogg', 75, 1)
	aicamera = new/obj/item/device/camera/siliconcam/robot_camera(src)
	toner = tonermax
	diag_hud_set_borgcell()

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
/mob/living/silicon/robot/Destroy()
	if(mmi && mind)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/T = get_turf(loc)//To hopefully prevent run time errors.
		if(T)
			mmi.loc = T
		if(mmi.brainmob)
			if(mmi.brainmob.stat == DEAD)
				mmi.brainmob.stat = CONSCIOUS
				dead_mob_list -= mmi.brainmob
				living_mob_list += mmi.brainmob
			mind.transfer_to(mmi.brainmob)
			mmi.update_icon()
		else
			src << "<span class='boldannounce'>Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug.</span>"
			ghostize()
			spawn(0)
				throw EXCEPTION("Borg MMI lacked a brainmob")
		mmi = null
	if(connected_ai)
		connected_ai.connected_robots -= src
	qdel(wires)
	qdel(module)
	qdel(eye_lights)
	wires = null
	module = null
	eye_lights = null
	camera = null
	cell = null
	return ..()


/mob/living/silicon/robot/proc/pick_module()
	if(module.type != /obj/item/weapon/robot_module)
		return

	var/list/modulelist = list("Standard" = /obj/item/weapon/robot_module/standard, \
	"Engineering" = /obj/item/weapon/robot_module/engineering, \
	"Medical" = /obj/item/weapon/robot_module/medical, \
	"Miner" = /obj/item/weapon/robot_module/miner, \
	"Janitor" = /obj/item/weapon/robot_module/janitor, \
	"Service" = /obj/item/weapon/robot_module/butler)
	if(!config.forbid_peaceborg)
		modulelist["Peacekeeper"] = /obj/item/weapon/robot_module/peacekeeper
	if(!config.forbid_secborg)
		modulelist["Security"] = /obj/item/weapon/robot_module/security

	var/input_module = input("Please, select a module!", "Robot", null, null) as null|anything in modulelist
	if(!input_module || module.type != /obj/item/weapon/robot_module)
		return

	module.transform_to(modulelist[input_module])


/mob/living/silicon/robot/proc/updatename()
	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
	if(changed_name == "" && client)
		changed_name = client.prefs.custom_names["cyborg"]
	if(!changed_name)
		changed_name = get_standard_name()

	real_name = changed_name
	name = real_name
	if(camera)
		camera.c_tag = real_name	//update the camera name too

/mob/living/silicon/robot/proc/get_standard_name()
	return "[(designation ? "[designation] " : "")][mmi.braintype]-[ident]"

/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"
	if(usr.stat == DEAD)
		src << "<span class='userdanger'>Alert: You are dead.</span>"
		return //won't work if dead
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
	var/dat = ""
	for (var/cat in alarms)
		dat += text("<B>[cat]</B><BR>\n")
		var/list/L = alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				dat += "<NOBR>"
				dat += text("-- [A.name]")
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	var/datum/browser/alerts = new(usr, "robotalerts", "Current Station Alerts", 400, 410)
	alerts.set_content(dat)
	alerts.open()

/mob/living/silicon/robot/proc/ionpulse()
	if(!ionpulse_on)
		return

	if(cell.charge <= 50)
		toggle_ionpulse()
		return

	cell.charge -= 50 // 500 steps on a default cell.
	return 1

/mob/living/silicon/robot/proc/toggle_ionpulse()
	if(!ionpulse)
		src << "<span class='notice'>No thrusters are installed!</span>"
		return

	if(!ion_trail)
		ion_trail = new
		ion_trail.set_up(src)

	ionpulse_on = !ionpulse_on
	src << "<span class='notice'>You [ionpulse_on ? null :"de"]activate your ion thrusters.</span>"
	if(ionpulse_on)
		ion_trail.start()
	else
		ion_trail.stop()
	if(thruster_button)
		thruster_button.icon_state = "ionpulse[ionpulse_on]"

/mob/living/silicon/robot/Stat()
	..()
	if(statpanel("Status"))
		if(cell)
			stat("Charge Left:", "[cell.charge]/[cell.maxcharge]")
		else
			stat(null, text("No Cell Inserted!"))

		if(module)
			for(var/datum/robot_energy_storage/st in module.storages)
				stat("[st.name]:", "[st.energy]/[st.max_energy]")
		if(connected_ai)
			stat("Master AI:", connected_ai.name)

/mob/living/silicon/robot/restrained(ignore_grab)
	. = 0

/mob/living/silicon/robot/triggerAlarm(class, area/A, O, obj/alarmsource)
	if(alarmsource.z != z)
		return
	if(stat == DEAD)
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
	return 1

/mob/living/silicon/robot/cancelAlarm(class, area/A, obj/origin)
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
	return !cleared

/mob/living/silicon/robot/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/weldingtool) && (user.a_intent != INTENT_HARM || user == src))
		user.changeNext_move(CLICK_CD_MELEE)
		var/obj/item/weapon/weldingtool/WT = W
		if (!getBruteLoss())
			user << "<span class='warning'>[src] is already in good condition!</span>"
			return
		if (WT.remove_fuel(0, user)) //The welder has 1u of fuel consumed by it's afterattack, so we don't need to worry about taking any away.
			if(src == user)
				user << "<span class='notice'>You start fixing yourself...</span>"
				if(!do_after(user, 50, target = src))
					return

			adjustBruteLoss(-30)
			updatehealth()
			add_fingerprint(user)
			visible_message("<span class='notice'>[user] has fixed some of the dents on [src].</span>")
			return
		else
			user << "<span class='warning'>The welder must be on for this task!</span>"
			return

	else if(istype(W, /obj/item/stack/cable_coil) && wiresexposed)
		user.changeNext_move(CLICK_CD_MELEE)
		var/obj/item/stack/cable_coil/coil = W
		if (getFireLoss() > 0)
			if(src == user)
				user << "<span class='notice'>You start fixing yourself...</span>"
				if(!do_after(user, 50, target = src))
					return
			if (coil.use(1))
				adjustFireLoss(-30)
				updatehealth()
				user.visible_message("[user] has fixed some of the burnt wires on [src].", "<span class='notice'>You fix some of the burnt wires on [src].</span>")
			else
				user << "<span class='warning'>You need more cable to repair [src]!</span>"
		else
			user << "The wires seem fine, there's no need to fix them."

	else if(istype(W, /obj/item/weapon/crowbar))	// crowbar means open or close the cover
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

	else if(istype(W, /obj/item/weapon/stock_parts/cell) && opened)	// trying to put a cell inside
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
		diag_hud_set_borgcell()

	else if(is_wire_tool(W))
		if (wiresexposed)
			wires.interact(user)
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
			playsound(src, W.usesound, 50, 1)
			user << "<span class='notice'>You start to unfasten [src]'s securing bolts...</span>"
			if(do_after(user, 50*W.toolspeed, target = src) && !cell)
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
		if(!mind) //A player mind is required for law procs to run antag checks.
			user << "<span class='warning'>[src] is entirely unresponsive!</span>"
			return
		MOD.install(laws, user) //Proc includes a success mesage so we don't need another one
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
			user << "<span class='warning'>You must access the borg's internals!</span>"
		else if(!src.module && U.require_module)
			user << "<span class='warning'>The borg must choose a module before it can be upgraded!</span>"
		else if(U.locked)
			user << "<span class='warning'>The upgrade is locked and cannot be used yet!</span>"
		else
			if(!user.drop_item())
				return
			if(U.action(src))
				user << "<span class='notice'>You apply the upgrade to [src].</span>"
				if(U.one_use)
					qdel(U)
				else
					U.forceMove(src)
					upgrades += U
			else
				user << "<span class='danger'>Upgrade error.</span>"

	else if(istype(W, /obj/item/device/toner))
		if(toner >= tonermax)
			user << "<span class='warning'>The toner level of [src] is at its highest level possible!</span>"
		else
			if(!user.drop_item())
				return
			toner = tonermax
			qdel(W)
			user << "<span class='notice'>You fill the toner level of [src] to its max capacity.</span>"
	else
		return ..()

/mob/living/silicon/robot/verb/unlock_own_cover()
	set category = "Robot Commands"
	set name = "Unlock Cover"
	set desc = "Unlocks your own cover if it is locked. You can not lock it again. A human will have to lock it for you."
	if(stat == DEAD)
		return //won't work if dead
	if(locked)
		switch(alert("You cannot lock your cover again, are you sure?\n      (You can still ask for a human to lock it)", "Unlock Own Cover", "Yes", "No"))
			if("Yes")
				locked = 0
				update_icons()
				usr << "<span class='notice'>You unlock your cover.</span>"

/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access(null))
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_held_item()) || check_access(H.wear_id))
			return 1
	else if(ismonkey(M))
		var/mob/living/carbon/monkey/george = M
		//they can only hold things :(
		if(istype(george.get_active_held_item(), /obj/item))
			return check_access(george.get_active_held_item())
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
	cut_overlays()
	icon_state = module.cyborg_base_icon
	if(stat != DEAD && !(paralysis || stunned || weakened || low_power_mode)) //Not dead, not stunned.
		if(!eye_lights)
			eye_lights = new()
		if(lamp_intensity > 2)
			eye_lights.icon_state = "[module.special_light_key ? "[module.special_light_key]":"[module.cyborg_base_icon]"]_l"
		else
			eye_lights.icon_state = "[module.special_light_key ? "[module.special_light_key]":"[module.cyborg_base_icon]"]_e[is_servant_of_ratvar(src) ? "_r" : ""]"
		eye_lights.icon = icon
		add_overlay(eye_lights)

	if(opened)
		if(wiresexposed)
			add_overlay("ov-opencover +w")
		else if(cell)
			add_overlay("ov-opencover +c")
		else
			add_overlay("ov-opencover -c")
	if(hat)
		var/image/head_overlay = hat.build_worn_icon(state = hat.icon_state, default_layer = 20, default_icon_file = 'icons/mob/head.dmi')
		head_overlay.pixel_y += hat_offset
		add_overlay(head_overlay)
	update_fire()

#define BORG_CAMERA_BUFFER 30
/mob/living/silicon/robot/Move(a, b, flag)
	var/oldLoc = src.loc
	. = ..()
	if(.)
		if(src.camera)
			if(!updating)
				updating = 1
				spawn(BORG_CAMERA_BUFFER)
					if(oldLoc != src.loc)
						cameranet.updatePortableCamera(src.camera)
					updating = 0
	if(module)
		if(istype(module, /obj/item/weapon/robot_module/janitor))
			var/turf/tile = loc
			if(isturf(tile))
				tile.clean_blood()
				for(var/A in tile)
					if(is_cleanable(A))
						qdel(A)
					else if(istype(A, /obj/item))
						var/obj/item/cleaned_item = A
						cleaned_item.clean_blood()
					else if(ishuman(A))
						var/mob/living/carbon/human/cleaned_human = A
						if(cleaned_human.lying)
							if(cleaned_human.head)
								cleaned_human.head.clean_blood()
								cleaned_human.update_inv_head()
							if(cleaned_human.wear_suit)
								cleaned_human.wear_suit.clean_blood()
								cleaned_human.update_inv_wear_suit()
							else if(cleaned_human.w_uniform)
								cleaned_human.w_uniform.clean_blood()
								cleaned_human.update_inv_w_uniform()
							if(cleaned_human.shoes)
								cleaned_human.shoes.clean_blood()
								cleaned_human.update_inv_shoes()
							cleaned_human.clean_blood()
							cleaned_human.wash_cream()
							cleaned_human << "<span class='danger'>[src] cleans your face!</span>"
			return

		if(istype(module, /obj/item/weapon/robot_module/miner))
			if(istype(loc, /turf/open/floor/plating/asteroid))
				for(var/obj/item/I in held_items)
					if(istype(I,/obj/item/weapon/storage/bag/ore))
						loc.attackby(I, src)
#undef BORG_CAMERA_BUFFER

/mob/living/silicon/robot/proc/self_destruct()
	if(emagged)
		if(mmi)
			qdel(mmi)
		explosion(src.loc,1,2,4,flame_range = 2)
	else
		explosion(src.loc,-1,0,2)
	gib()

/mob/living/silicon/robot/proc/UnlinkSelf()
	if(src.connected_ai)
		connected_ai.connected_robots -= src
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
	set desc = "Scrambles your security and identification codes and resets your current buffers. Unlocks you and permanently severs you from your AI and the robotics console and will deactivate your camera system."

	var/mob/living/silicon/robot/R = src

	if(R)
		R.UnlinkSelf()
		R << "Buffers flushed and reset. Camera system shutdown.  All systems operational."
		src.verbs -= /mob/living/silicon/robot/proc/ResetSecurityCodes

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	if(incapacitated())
		return
	var/obj/item/W = get_active_held_item()
	if(W)
		W.attack_self(src)


/mob/living/silicon/robot/proc/SetLockdown(state = 1)
	// They stay locked down if their wire is cut.
	if(wires.is_cut(WIRE_LOCKDOWN))
		state = 1
	if(state)
		throw_alert("locked", /obj/screen/alert/locked)
	else
		clear_alert("locked")
	lockcharge = state
	update_canmove()

/mob/living/silicon/robot/proc/SetEmagged(new_state)
	emagged = new_state
	module.rebuild_modules()
	update_icons()
	if(emagged)
		throw_alert("hacked", /obj/screen/alert/hacked)
	else
		clear_alert("hacked")

/mob/living/silicon/robot/verb/outputlaws()
	set category = "Robot Commands"
	set name = "State Laws"

	if(usr.stat == DEAD)
		return //won't work if dead
	checklaws()

/mob/living/silicon/robot/verb/set_automatic_say_channel() //Borg version of setting the radio for autosay messages.
	set name = "Set Auto Announce Mode"
	set desc = "Modify the default radio setting for stating your laws."
	set category = "Robot Commands"

	if(usr.stat == DEAD)
		return //won't work if dead
	set_autosay()

/mob/living/silicon/robot/proc/control_headlamp()
	if(stat || lamp_recharging || low_power_mode)
		src << "<span class='danger'>This function is currently offline.</span>"
		return

//Some sort of magical "modulo" thing which somehow increments lamp power by 2, until it hits the max and resets to 0.
	lamp_intensity = (lamp_intensity+2) % (lamp_max+2)
	src << "[lamp_intensity ? "Headlamp power set to Level [lamp_intensity/2]" : "Headlamp disabled."]"
	update_headlamp()

/mob/living/silicon/robot/proc/update_headlamp(var/turn_off = 0, var/cooldown = 100)
	SetLuminosity(0)

	if(lamp_intensity && (turn_off || stat || low_power_mode))
		src << "<span class='danger'>Your headlamp has been deactivated.</span>"
		lamp_intensity = 0
		lamp_recharging = 1
		spawn(cooldown) //10 seconds by default, if the source of the deactivation does not keep stat that long.
			lamp_recharging = 0
	else
		AddLuminosity(lamp_intensity)

	if(lamp_button)
		lamp_button.icon_state = "lamp[lamp_intensity]"

	update_icons()

/mob/living/silicon/robot/proc/deconstruct()
	var/turf/T = get_turf(src)
	if (robot_suit)
		robot_suit.loc = T
		robot_suit.l_leg.loc = T
		robot_suit.l_leg = null
		robot_suit.r_leg.loc = T
		robot_suit.r_leg = null
		new /obj/item/stack/cable_coil(T, robot_suit.chest.wired)
		robot_suit.chest.loc = T
		robot_suit.chest.wired = 0
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
		new /obj/item/robot_suit(T)
		new /obj/item/bodypart/l_leg/robot(T)
		new /obj/item/bodypart/r_leg/robot(T)
		new /obj/item/stack/cable_coil(T, 1)
		new /obj/item/bodypart/chest/robot(T)
		new /obj/item/bodypart/l_arm/robot(T)
		new /obj/item/bodypart/r_arm/robot(T)
		new /obj/item/bodypart/head/robot(T)
		var/b
		for(b=0, b!=2, b++)
			var/obj/item/device/assembly/flash/handheld/F = new /obj/item/device/assembly/flash/handheld(T)
			F.burn_out()
	if (cell) //Sanity check.
		cell.loc = T
		cell = null
	qdel(src)

/mob/living/silicon/robot/syndicate
	icon_state = "syndie_bloodhound"
	faction = list("syndicate")
	bubble_icon = "syndibot"
	req_access = list(access_syndicate)
	lawupdate = FALSE
	scrambledcodes = TRUE // These are rogue borgs.
	ionpulse = TRUE
	var/playstyle_string = "<span class='userdanger'>You are a Syndicate assault cyborg!</span><br>\
							<b>You are armed with powerful offensive tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
							Your cyborg LMG will slowly produce ammunition from your power supply, and your operative pinpointer will find and locate fellow nuclear operatives. \
							<i>Help the operatives secure the disk at all costs!</i></b>"
	var/set_module = /obj/item/weapon/robot_module/syndicate

/mob/living/silicon/robot/syndicate/New(loc)
	..()
	cell.maxcharge = 25000
	cell.charge = 25000
	radio = new /obj/item/device/radio/borg/syndicate(src)
	module.transform_to(set_module)
	laws = new /datum/ai_laws/syndicate_override()
	spawn(5)
		if(playstyle_string)
			src << playstyle_string

/mob/living/silicon/robot/syndicate/medical
	icon_state = "syndi-medi"
	playstyle_string = "<span class='userdanger'>You are a Syndicate medical cyborg!</span><br>\
						<b>You are armed with powerful medical tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
						Your hypospray will produce Restorative Nanites, a wonder-drug that will heal most types of bodily damages, including clone and brain damage. It also produces morphine for offense. \
						Your defibrillator paddles can revive operatives through their hardsuits, or can be used on harm intent to shock enemies! \
						Your energy saw functions as a circular saw, but can be activated to deal more damage, and your operative pinpointer will find and locate fellow nuclear operatives. \
						<i>Help the operatives secure the disk at all costs!</i></b>"
	set_module = /obj/item/weapon/robot_module/syndicate_medical

/mob/living/silicon/robot/proc/notify_ai(notifytype, oldname, newname)
	if(!connected_ai)
		return
	switch(notifytype)
		if(1) //New Cyborg
			connected_ai << "<br><br><span class='notice'>NOTICE - New cyborg connection detected: <a href='?src=\ref[connected_ai];track=[html_encode(name)]'>[name]</a></span><br>"
		if(2) //New Module
			connected_ai << "<br><br><span class='notice'>NOTICE - Cyborg module change detected: [name] has loaded the [designation] module.</span><br>"
		if(3) //New Name
			connected_ai << "<br><br><span class='notice'>NOTICE - Cyborg reclassification detected: [oldname] is now designated as [newname].</span><br>"

/mob/living/silicon/robot/canUseTopic(atom/movable/M, be_close = 0)
	if(stat || lockcharge || low_power_mode)
		return
	if(be_close && !in_range(M, src))
		return
	return 1

/mob/living/silicon/robot/updatehealth()
	..()
	if(health < maxHealth*0.5) //Gradual break down of modules as more damage is sustained
		if(uneq_module(held_items[3]))
			src << "<span class='warning'>SYSTEM ERROR: Module 3 OFFLINE.</span>"
		if(health < 0)
			if(uneq_module(held_items[2]))
				src << "<span class='warning'>SYSTEM ERROR: Module 2 OFFLINE.</span>"
			if(health < -maxHealth*0.5)
				if(uneq_module(held_items[1]))
					src << "<span class='warning'>CRITICAL ERROR: All modules OFFLINE.</span>"

/mob/living/silicon/robot/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_OBSERVER
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(sight_mode & BORGMESON)
		sight |= SEE_TURFS
		see_invisible = min(see_invisible, SEE_INVISIBLE_MINIMUM)
		see_in_dark = 1

	if(sight_mode & BORGMATERIAL)
		sight |= SEE_OBJS
		see_invisible = min(see_invisible, SEE_INVISIBLE_MINIMUM)
		see_in_dark = 1

	if(sight_mode & BORGXRAY)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_invisible = SEE_INVISIBLE_LIVING
		see_in_dark = 8

	if(sight_mode & BORGTHERM)
		sight |= SEE_MOBS
		see_invisible = min(see_invisible, SEE_INVISIBLE_LIVING)
		see_in_dark = 8

	if(see_override)
		see_invisible = see_override

/mob/living/silicon/robot/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= -maxHealth) //die only once
			death()
			return
		if(paralysis || stunned || weakened || getOxyLoss() > maxHealth*0.5)
			if(stat == CONSCIOUS)
				stat = UNCONSCIOUS
				blind_eyes(1)
				update_canmove()
				update_headlamp()
		else
			if(stat == UNCONSCIOUS)
				stat = CONSCIOUS
				adjust_blindness(-1)
				update_canmove()
				update_headlamp()
	diag_hud_set_status()
	diag_hud_set_health()
	update_health_hud()

/mob/living/silicon/robot/revive(full_heal = 0, admin_revive = 0)
	if(..()) //successfully ressuscitated from death
		if(camera && !wires.is_cut(WIRE_CAMERA))
			camera.toggle_cam(src,0)
		update_headlamp()
		if(admin_revive)
			locked = 1
		notify_ai(1)
		. = 1

/mob/living/silicon/robot/fully_replace_character_name(oldname, newname)
	..()
	if(oldname != real_name)
		notify_ai(3, oldname, newname)
	if(camera)
		camera.c_tag = real_name
	custom_name = newname


/mob/living/silicon/robot/proc/ResetModule()
	uneq_all()
	shown_robot_modules = FALSE
	if(hud_used)
		hud_used.update_robot_modules_display()
	module.transform_to(/obj/item/weapon/robot_module)

	// Remove upgrades.
	for(var/obj/item/I in upgrades)
		I.forceMove(get_turf(src))

	upgrades.Cut()

	speed = 0
	ionpulse = FALSE

	return 1

/mob/living/silicon/robot/proc/has_module()
	if(!module || module.type == /obj/item/weapon/robot_module)
		. = FALSE
	else
		. = TRUE

/mob/living/silicon/robot/proc/update_module_innate()
	designation = module.name
	if(hands)
		hands.icon_state = module.moduleselect_icon
	if(module.can_be_pushed)
		status_flags |= CANPUSH
	else
		status_flags &= ~CANPUSH

	hat_offset = module.hat_offset

	magpulse = module.magpulsing
	updatename()


/mob/living/silicon/robot/proc/place_on_head(obj/item/new_hat)
	if(hat)
		hat.forceMove(get_turf(src))
	hat = new_hat
	new_hat.forceMove(src)
	update_icons()

/mob/living/silicon/robot/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	if(!(M in buckled_mobs))
		buckle_mob(M)

/mob/living/silicon/robot/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!riding_datum)
		riding_datum = new /datum/riding/cyborg
		riding_datum.ridden = src
	if(buckled_mobs)
		if(buckled_mobs.len >= max_buckled_mobs)
			return
		if(M in buckled_mobs)
			return
	if(stat)
		return
	if(incapacitated())
		return
	if(M.restrained())
		return
	if(iscyborg(M))
		M.visible_message("<span class='warning'>[M] really can't seem to mount the [src]...</span>")
		return
	if(isbot(M))
		M.visible_message("<span class='boldwarning'>No. Just... no.</span>")
		return
	if(module)
		if(!module.allow_riding)
			M.visible_message("<span class='boldwarning'>Unfortunately, [M] just can't seem to hold onto [src]!</span>")
			return
	if(iscarbon(M))
		if(!equip_buckle_inhands(M))	//MAKE SURE THIS IS LAST!
			M.visible_message("<span class='boldwarning'>[M] can't climb onto [src] because his hands are full!</span>")
			return
	. = ..(M, force, check_loc)
	riding_datum.handle_vehicle_offsets()

/mob/living/silicon/robot/unbuckle_mob(mob/user)
	if(iscarbon(user))
		unequip_buckle_inhands(user)
	. = ..(user)
	riding_datum.restore_position(user)

/mob/living/silicon/robot/proc/unequip_buckle_inhands(mob/living/carbon/user)
	for(var/obj/item/cyborgride_offhand/O in user.contents)
		if(O.ridden != src)
			CRASH("RIDING OFFHAND ON WRONG MOB")
			continue
		if(O.selfdeleting)
			continue
		else
			qdel(O)
	return TRUE

/mob/living/silicon/robot/proc/equip_buckle_inhands(mob/living/carbon/user)
	var/obj/item/cyborgride_offhand/inhand = new /obj/item/cyborgride_offhand(user)
	inhand.rider = user
	inhand.ridden = src
	return user.put_in_hands(inhand, TRUE)

/obj/item/cyborgride_offhand
	name = "offhand"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	flags = ABSTRACT | DROPDEL | NOBLUDGEON
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/mob/living/carbon/rider
	var/mob/living/silicon/robot/ridden
	var/selfdeleting = FALSE

/obj/item/cyborgride_offhand/dropped()
	selfdeleting = TRUE
	. = ..()

/obj/item/cyborgride_offhand/equipped()
	if(loc != rider)
		selfdeleting = TRUE
		qdel(src)
	. = ..()

/obj/item/cyborgride_offhand/Destroy()
	if(selfdeleting)
		if(rider in ridden.buckled_mobs)
			ridden.unbuckle_mob(rider)
	. = ..()
