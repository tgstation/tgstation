/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 300
	health = 300
	universal_speak = 1

	var/sight_mode = 0
	var/custom_name = ""
	var/base_icon
	var/custom_sprite = 0 //Due to all the sprites involved, a var for our custom borgs may be best
	//var/crisis //Admin-settable for combat module use.

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

	// Components are basically robot organs.
	var/list/components = list()

	var/obj/item/device/mmi/mmi = null

	var/obj/item/device/pda/ai/rbPDA = null

	var/datum/wires/robot/wires = null

	var/opened = 0
	var/emagged = 0
	var/wiresexposed = 0
	var/locked = 1
	var/list/req_access = list(access_robotics)
	var/ident = 0
	var/hasbutt = 1
	//var/list/laws = list()
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list())
	var/viewalerts = 0
	var/modtype = "Default"
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
	var/lockcharge //Used when locking down a borg to preserve cell charge
	var/speed = 0 //Cause sec borgs gotta go fast //No they dont!
	var/scrambledcodes = 0 // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.
	var/braintype = "Cyborg"
	var/pose
	var/lawcheck[1]
	var/ioncheck[1]


/mob/living/silicon/robot/New(loc,var/syndie = 0,var/unfinished = 0,var/startup_sound='sound/voice/liveagain.ogg')
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	if(isMoMMI(src))
		wires = new /datum/wires/robot/mommi(src)
	else
		wires = new(src)

	ident = rand(1, 999)
	updatename("Default")
	updateicon()

	if(syndie)
		if(!cell)
			cell = new /obj/item/weapon/cell(src)

		laws = new /datum/ai_laws/antimov()
		lawupdate = 0
		scrambledcodes = 1
		cell.maxcharge = 25000
		cell.charge = 25000
		module = new /obj/item/weapon/robot_module/syndicate(src)
		hands.icon_state = "standard"
		icon_state = "secborg"
		modtype = "Security"
	else
		src.laws = getLawset(src)
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
		camera.network = list("SS13","Robots")
		if(wires.IsCameraCut()) // 5 = BORG CAMERA
			camera.status = 0

	initialize_components()
	//if(!unfinished)
	// Create all the robot parts.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.installed = 1
		C.wrapped = new C.external_type

	if(!cell)
		cell = new /obj/item/weapon/cell(src)
		cell.maxcharge = 7500
		cell.charge = 7500

	..()

	if(cell)
		var/datum/robot_component/cell_component = components["power cell"]
		cell_component.wrapped = cell
		cell_component.installed = 1

	playsound(loc, startup_sound, 75, 1)

// setup the PDA and its name
/mob/living/silicon/robot/proc/setup_PDA()
	if (!rbPDA)
		rbPDA = new/obj/item/device/pda/ai(src)
	rbPDA.set_name_and_job(custom_name,braintype)

/mob/living/silicon/robot/debug_droideka
	New()
		..()
		module = new /obj/item/weapon/robot_module/combat(src)
		radio.config(list("Security" = 1))
		base_icon = icon_state
		icon_state = "droid-combat"
		overlays -= "eyes"
		base_icon = icon_state
		updateicon()

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
//Improved /N
/mob/living/silicon/robot/Destroy()
	if(mmi)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/T = get_turf(loc)//To hopefully prevent run time errors.
		if(T)	mmi.loc = T
		if(mind)	mind.transfer_to(mmi.brainmob)
		if(mmi.brainmob)
			mmi.brainmob.locked_to_z = locked_to_z
		mmi = null
	..()

/proc/getAvailableRobotModules()
	var/list/modules = list("Standard", "Engineering", "Medical", "Miner", "Janitor", "Service", "Security")
	if(security_level == SEC_LEVEL_RED) //Add crisis to this check if you want to make it available at an admin's whim
		modules+="Combat"
	return modules

// /vg/: Enable forcing module type
/mob/living/silicon/robot/proc/pick_module(var/forced_module=null)
	if(module)
		return
	var/list/modules = getAvailableRobotModules()
	if(forced_module)
		modtype = forced_module
	else
		modtype = input("Please, select a module!", "Robot", null, null) in modules
	// END forced modules.

	var/module_sprites[0] //Used to store the associations between sprite names and sprite index.
	var/channels = list()

	if(module)
		return

	switch(modtype)
		if("Standard")
			module = new /obj/item/weapon/robot_module/standard(src)
			module_sprites["Basic"] = "robot_old"
			module_sprites["Android"] = "droid"
			module_sprites["Default"] = "robot"

		if("Service")
			module = new /obj/item/weapon/robot_module/butler(src)
			module_sprites["Waitress"] = "Service"
			module_sprites["Kent"] = "toiletbot"
			module_sprites["Bro"] = "Brobot"
			module_sprites["Rich"] = "maximillion"
			module_sprites["Default"] = "Service2"
			module_sprites["R2-D2"] = "r2d2"
			module_sprites["Marina-SV"] = "marinaSV"

		if("Miner")
			module = new /obj/item/weapon/robot_module/miner(src)
			channels = list("Supply" = 1)
			if(camera && "Robots" in camera.network)
				camera.network.Add("MINE")
			module_sprites["Basic"] = "Miner_old"
			module_sprites["Advanced Droid"] = "droid-miner"
			module_sprites["Treadhead"] = "Miner"
			module_sprites["Wall-A"] = "wall-a"
			module_sprites["Marina-MN"] = "marinaMN"

		if("Medical")
			module = new /obj/item/weapon/robot_module/medical(src)
			channels = list("Medical" = 1)
			if(camera && "Robots" in camera.network)
				camera.network.Add("Medical")
			module_sprites["Basic"] = "Medbot"
			module_sprites["Advanced Droid"] = "droid-medical"
			module_sprites["Needles"] = "medicalrobot"
			module_sprites["Standard"] = "surgeon"
			module_sprites["Marina"] = "marina"
			module_sprites["Eve"] = "eve"

		if("Security")
			module = new /obj/item/weapon/robot_module/security(src)
			channels = list("Security" = 1)
			module_sprites["Basic"] = "secborg"
			module_sprites["Red Knight"] = "Security"
			module_sprites["Black Knight"] = "securityrobot"
			module_sprites["Bloodhound"] = "bloodhound"
			module_sprites["Securitron"] = "securitron"
			module_sprites["Marina-SC"] = "marinaSC"
			src << "<span class='warning'><big><b>Just a reminder, by default you do not follow space law, you follow your lawset</b></big></span>"

		if("Engineering")
			module = new /obj/item/weapon/robot_module/engineering(src)
			channels = list("Engineering" = 1)
			if(camera && "Robots" in camera.network)
				camera.network.Add("Engineering")
			module_sprites["Basic"] = "Engineering"
			module_sprites["Antique"] = "engineerrobot"
			module_sprites["Engiseer"] = "Engiseer"
			module_sprites["Landmate"] = "landmate"
			module_sprites["Wall-E"] = "wall-e"
			module_sprites["Marina-EN"] = "marinaEN"

		if("Janitor")
			module = new /obj/item/weapon/robot_module/janitor(src)
			module_sprites["Basic"] = "JanBot2"
			module_sprites["Mopbot"]  = "janitorrobot"
			module_sprites["Mop Gear Rex"] = "mopgearrex"
			module_sprites["Mechaduster"] = "mechaduster"
			module_sprites["HAN-D"] = "han-d"
			module_sprites["Marina-JN"] = "marinaJN"

		if("Combat")
			module = new /obj/item/weapon/robot_module/combat(src)
			module_sprites["Combat Android"] = "droid-combat"
			module_sprites["Bladewolf"] = "bladewolf"
			module_sprites["Mr. Gutsy"] = "mrgutsy"
			channels = list("Security" = 1)

	//Custom_sprite check and entry
	if (custom_sprite == 1)
		module_sprites["Custom"] = "[src.ckey]-[modtype]"

	hands.icon_state = lowertext(modtype)
	feedback_inc("cyborg_[lowertext(modtype)]",1)
	updatename()

	if(modtype == "Medical" || modtype == "Security" || modtype == "Combat")
		status_flags &= ~CANPUSH

	if(!forced_module)
		choose_icon(6, module_sprites)
	else
		var/picked  = pick(module_sprites)
		icon_state = module_sprites[picked]
	radio.config(channels)
	base_icon = icon_state

/mob/living/silicon/robot/proc/updatename(var/prefix as text)
	if(prefix)
		modtype = prefix
	if(istype(mmi, /obj/item/device/mmi/posibrain))
		braintype = "Android"
	else
		braintype = "Cyborg"

	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
	else
		changed_name = "[modtype] [braintype]-[num2text(ident)]"
	real_name = changed_name
	name = real_name

	// if we've changed our name, we also need to update the display name for our PDA
	setup_PDA()

	//We also need to update name of internal camera.
	if (camera)
		camera.c_tag = changed_name

	/* Oh jesus fucking christ bay
	if(!custom_sprite) //Check for custom sprite
		var/file = file2text("config/custom_sprites.txt")
		var/lines = text2list(file, "\n")

		for(var/line in lines)
		// split & clean up
			var/list/Entry = text2list(line, "-")
			for(var/i = 1 to Entry.len)
				Entry[i] = trim(Entry[i])

			if(Entry.len < 2)
				continue;

			if(Entry[1] == src.ckey && Entry[2] == src.real_name) //They're in the list? Custom sprite time, var and icon change required
				custom_sprite = 1
				icon = 'icons/mob/custom-synthetic.dmi'
	*/

/mob/living/silicon/robot/verb/Namepick()
	set category = "Robot Commands"
	if(custom_name)
		return 0

	spawn(0)
		var/newname
		newname = copytext(sanitize(input(src,"You are a robot. Enter a name, or leave blank for the default name.", "Name change","") as text),1,MAX_NAME_LEN)
		if (newname != "")
			custom_name = newname

		updatename()
		updateicon()

/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"
	robot_alerts()

// this verb lets cyborgs see the stations manifest
/mob/living/silicon/robot/verb/cmd_station_manifest()
	set category = "Robot Commands"
	set name = "Show Station Manifest"
	show_station_manifest()


/mob/living/silicon/robot/proc/robot_alerts()

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\living\silicon\robot\robot.dm:322: var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	var/dat = {"<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n
<A HREF='?src=\ref[src];mach_close=robotalerts'>Close</A><BR><BR>"}
	// END AUTOFIX
	for (var/cat in alarms)
		dat += text("<B>[cat]</B><BR>\n")
		var/list/L = alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/list/sources = alm[3]
				dat += "<NOBR>" // wat
				dat += text("-- [A.name]")
				if (sources.len > 1)
					dat += text("- [sources.len] sources")
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	viewalerts = 1
	src << browse(dat, "window=robotalerts&can_close=0")

/mob/living/silicon/robot/proc/self_diagnosis()
	if(!is_component_functioning("diagnosis unit"))
		return null

	var/dat = "<HEAD><TITLE>[src.name] Self-Diagnosis Report</TITLE></HEAD><BODY>\n"
	for (var/V in components)
		var/datum/robot_component/C = components[V]
		dat += "<b>[C.name]</b><br><table><tr><td>Power consumption</td><td>[C.energy_consumption]</td></tr><tr><td>Brute Damage:</td><td>[C.brute_damage]</td></tr><tr><td>Electronics Damage:</td><td>[C.electronics_damage]</td></tr><tr><td>Powered:</td><td>[(!C.energy_consumption || C.is_powered()) ? "Yes" : "No"]</td></tr><tr><td>Toggled:</td><td>[ C.toggled ? "Yes" : "No"]</td></table><br>"

	return dat


/mob/living/silicon/robot/verb/self_diagnosis_verb()
	set category = "Robot Commands"
	set name = "Self Diagnosis"

	if(!is_component_functioning("diagnosis unit"))
		src << "\red Your self-diagnosis component isn't functioning."

	var/dat = self_diagnosis()
	src << browse(dat, "window=robotdiagnosis")


/mob/living/silicon/robot/verb/toggle_component()
	set category = "Robot Commands"
	set name = "Toggle Component"
	set desc = "Toggle a component, conserving power."

	var/list/installed_components = list()
	for(var/V in components)
		if(V == "power cell") continue
		var/datum/robot_component/C = components[V]
		if(C.installed)
			installed_components += V

	var/toggle = input(src, "Which component do you want to toggle?", "Toggle Component") as null|anything in installed_components
	if(!toggle)
		return

	var/datum/robot_component/C = components[toggle]
	if(C.toggled)
		C.toggled = 0
		src << "\red You disable [C.name]."
	else
		C.toggled = 1
		src << "\red You enable [C.name]."

/mob/living/silicon/robot/blob_act()
	if(flags & INVULNERABLE)
		return
	if (stat != 2)
		adjustBruteLoss(60)
		updatehealth()
		return 1
	else
		gib()
		return 1
	return 0

// this function shows information about the malf_ai gameplay type in the status screen
/mob/living/silicon/robot/show_malf_ai()
	..()
	if(ticker.mode.name == "AI malfunction")
		var/datum/game_mode/malfunction/malf = ticker.mode
		for (var/datum/mind/malfai in malf.malf_ai)
			if(connected_ai)
				if(connected_ai.mind == malfai)
					if(malf.apcs >= 3)
						stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/(malf.apcs/3), 0)] seconds")
			else if(ticker.mode:malf_mode_declared)
				stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")
	return 0


// this function displays jetpack pressure in the stat panel
/mob/living/silicon/robot/proc/show_jetpack_pressure()
	// if you have a jetpack, show the internal tank pressure
	var/obj/item/weapon/tank/jetpack/current_jetpack = installed_jetpack()
	if (current_jetpack)
		stat("Internal Atmosphere Info", current_jetpack.name)
		stat("Tank Pressure", current_jetpack.air_contents.return_pressure())


// this function returns the robots jetpack, if one is installed
/mob/living/silicon/robot/proc/installed_jetpack()
	if(module)
		return (locate(/obj/item/weapon/tank/jetpack) in module.modules)
	return 0
/mob/living/silicon/robot/proc/installed_module(var/typepath)
	if(module)
		return (locate(typepath) in module.modules)
	return 0


// this function displays the cyborgs current cell charge in the stat panel
/mob/living/silicon/robot/proc/show_cell_power()
	if(cell)
		stat(null, text("Charge Left: [cell.charge]/[cell.maxcharge]"))
	else
		stat(null, text("No Cell Inserted!"))


/mob/living/silicon/robot/proc/show_cable_lengths()
	var/obj/item/weapon/cable_coil/coil = installed_module(/obj/item/weapon/cable_coil)
	if(coil)
		stat(null, text("Cable Lengths: [coil.amount]/[coil.max_amount]"))

/mob/living/silicon/robot/proc/show_welder_fuel()
	var/obj/item/weapon/weldingtool/WT = installed_module(/obj/item/weapon/weldingtool)
	if(WT)
		stat(null, text("Welder Fuel: [WT.get_fuel()]/[WT.max_fuel]"))

/mob/living/silicon/robot/proc/show_metal_sheets()
	var/obj/item/stack/sheet/metal/cyborg/M = installed_module(/obj/item/stack/sheet/metal/cyborg)
	if(M)
		stat(null, text("Metal Sheets: [M.amount]/50"))

/mob/living/silicon/robot/proc/show_glass_sheets()
	var/obj/item/stack/sheet/glass/G = installed_module(/obj/item/stack/sheet/glass)
	if(G)
		stat(null, text("Glass Sheets: [G.amount]/50"))

/mob/living/silicon/robot/proc/show_rglass_sheets()
	var/obj/item/stack/sheet/rglass/G = installed_module(/obj/item/stack/sheet/rglass)
	if(G)
		stat(null, text("Reinforced Glass Sheets: [G.amount]/50"))


// update the status screen display
/mob/living/silicon/robot/Stat()
	..()
	statpanel("Status")
	if (client.statpanel == "Status")
		show_cell_power()
		show_jetpack_pressure()
		show_cable_lengths()
		show_welder_fuel()
		show_metal_sheets()
		show_glass_sheets()
		show_rglass_sheets()

/mob/living/silicon/robot/restrained()
	return 0


/mob/living/silicon/robot/ex_act(severity)
	if(flags & INVULNERABLE)
		src << "The bus' robustness protects you from the explosion."
		return

	if(!blinded)
		flick("flash", flash)

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
	if(flags & INVULNERABLE)
		return
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


/mob/living/silicon/robot/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && (M_FAT in tmob.mutations))
				if(prob(20))
					usr << "\red <B>You fail to push [tmob]'s fat ass out of the way.</B>"
					now_pushing = 0
					return
			if(!(tmob.status_flags & CANPUSH))
				now_pushing = 0
				return
		now_pushing = 0
		..()
		if (istype(AM, /obj/machinery/recharge_station))
			var/obj/machinery/recharge_station/F = AM
			F.move_inside()
		if (!istype(AM, /atom/movable))
			return
		if (!now_pushing)
			now_pushing = 1
			if (!AM.anchored)
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/structure/window/full))
					for(var/obj/structure/window/win in get_step(AM,t))
						now_pushing = 0
						return
				step(AM, t)
			now_pushing = null
		return
	return


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

	if(opened) // Are they trying to insert something?
		for(var/V in components)
			var/datum/robot_component/C = components[V]
			if(!C.installed && istype(W, C.external_type))
				C.installed = 1
				C.wrapped = W
				C.install()
				user.drop_item()
				W.loc = null

				usr << "\blue You install the [W.name]."

				return

	if (istype(W, /obj/item/weapon/weldingtool))
		if (!getBruteLoss())
			user << "Nothing to fix here!"
			return
		var/obj/item/weapon/weldingtool/WT = W
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
		if (!getFireLoss())
			user << "Nothing to fix here!"
			return
		var/obj/item/weapon/cable_coil/coil = W
		adjustFireLoss(-30)
		updatehealth()
		coil.use(1)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [user] has fixed some of the burnt wires on [src]!"), 1)

	else if (istype(W, /obj/item/weapon/crowbar))	// crowbar means open or close the cover
		if(opened)
			if(cell)
				user << "You close the cover."
				opened = 0
				updateicon()
			else if(mmi && wiresexposed && wires.IsAllCut())
				//Cell is out, wires are exposed, remove MMI, produce damaged chassis, baleet original mob.
				user << "You jam the crowbar into the robot and begin levering [mmi]."
				if (do_after(user,3))
					user << "You damage some parts of the chassis, but eventually manage to rip out [mmi]!"
					var/obj/item/robot_parts/robot_suit/C = new/obj/item/robot_parts/robot_suit(loc)
					C.l_leg = new/obj/item/robot_parts/l_leg(C)
					C.r_leg = new/obj/item/robot_parts/r_leg(C)
					C.l_arm = new/obj/item/robot_parts/l_arm(C)
					C.r_arm = new/obj/item/robot_parts/r_arm(C)
					C.updateicon()
					new/obj/item/robot_parts/chest(loc)
					// This doesn't work.  Don't use it.
					//src.Destroy()
					// del() because it's infrequent and mobs act weird in qdel.
					del(src)
			else
				// Okay we're not removing the cell or an MMI, but maybe something else?
				var/list/removable_components = list()
				for(var/V in components)
					if(V == "power cell") continue
					var/datum/robot_component/C = components[V]
					if(C.installed == 1 || C.installed == -1)
						removable_components += V

				var/remove = input(user, "Which component do you want to pry out?", "Remove Component") as null|anything in removable_components
				if(!remove)
					return
				var/datum/robot_component/C = components[remove]
				var/obj/item/I = C.wrapped
				user << "You remove \the [I]."
				I.loc = src.loc

				if(C.installed == 1)
					C.uninstall()
				C.installed = 0

		else
			if(locked)
				user << "The cover is locked and cannot be opened."
			else
				user << "You open the cover."
				opened = 1
				updateicon()

	else if (istype(W, /obj/item/weapon/cell) && opened)	// trying to put a cell inside
		var/datum/robot_component/C = components["power cell"]
		if(wiresexposed)
			user << "Close the panel first."
		else if(cell)
			user << "There is a power cell already installed."
		else
			user.drop_item()
			W.loc = src
			cell = W
			user << "You insert the power cell."

			C.installed = 1
			C.wrapped = W
			C.install()

	else if (istype(W, /obj/item/weapon/wirecutters) || istype(W, /obj/item/device/multitool))
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
				user << "You [ locked ? "lock" : "unlock"] [src]'s interface."
				updateicon()
			else
				user << "\red Access denied."

	else if(istype(W, /obj/item/weapon/card/emag))		// trying to unlock with an emag card
		if(src == user || isMoMMI(user))
			user << "<span class='warning'>Your utility claw can't maneuver \the [W] into the slot!</span>"
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
				user << "You must close the panel first"
				return
			else
				sleep(6)
				if(prob(50))
					emagged = 1
					lawupdate = 0
					connected_ai = null
					user << "You emag [src]'s interface."
//					message_admins("[key_name_admin(user)] emagged cyborg [key_name_admin(src)].  Laws overridden.")
					log_game("[key_name(user)] emagged [isMoMMI(src) ? "MoMMI" : "cyborg"] [key_name(src)].  Laws overridden.")
					clear_supplied_laws()
					clear_inherent_laws()
					laws = new /datum/ai_laws/syndicate_override
					var/time = time2text(world.realtime,"hh:mm:ss")
					lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
					set_zeroth_law("Only [user.real_name] and people they designate as being such are syndicate agents.")
					src << "\red ALERT: Foreign software detected."
					sleep(5)
					src << "\red Initiating diagnostics..."
					sleep(20)
					src << "\red SynBorg v1.7 loaded."
					sleep(5)
					src << "\red LAW SYNCHRONIZATION ERROR"
					sleep(5)
					src << "\red Would you like to send a report to NanoTraSoft? Y/N"
					sleep(10)
					src << "\red > N"
					sleep(20)
					src << "\red ERRORERRORERROR"
					src << "<b>Obey these laws:</b>"
					laws.show_laws(src)
					src << "\red \b ALERT: [user.real_name] is your new master. Obey your new laws and their commands."
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
			if (M == src)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M, src )

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
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
		var/datum/robot_component/cell_component = components["power cell"]
		if(cell)
			cell.updateicon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			user << "You remove \the [cell]."
			cell = null
			cell_component.wrapped = null
			cell_component.installed = 0
			updateicon()
		else if(cell_component.installed == -1)
			cell_component.installed = 0
			var/obj/item/broken_device = cell_component.wrapped
			user << "You remove \the [broken_device]."
			user.put_in_active_hand(broken_device)

	if(ishuman(user))
		if(istype(user:gloves, /obj/item/clothing/gloves/space_ninja)&&user:gloves:candrain&&!user:gloves:draining)
			call(/obj/item/clothing/gloves/space_ninja/proc/drain)("CYBORG",src,user:wear_suit)
			return
		if(user.a_intent == "help")
			user.visible_message("\blue [user.name] pats [src.name] on the head.")
			return

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
		overlays += image(icon,"eyes-[icon_state]",LIGHTING_LAYER+1)

	if(opened)
		if(custom_sprite)//Custom borgs also have custom panels, heh
			if(wiresexposed)
				overlays += "[src.ckey]-openpanel +w"
			else if(cell)
				overlays += "[src.ckey]-openpanel +c"
			else
				overlays += "[src.ckey]-openpanel -c"
		else
			if(wiresexposed)
				overlays += "ov-openpanel +w"
			else if(cell)
				overlays += "ov-openpanel +c"
			else
				overlays += "ov-openpanel -c"

	// WHY THE FUCK DOES IT HAVE A SHIELD, ARE YOU STUPID
	if(module_active && istype(module_active,/obj/item/borg/combat/shield))
		overlays += "[icon_state]-shield"

	if(base_icon)
		// no no no no
		if(module_active && istype(module_active,/obj/item/borg/combat/mobility))
			icon_state = "[base_icon]-roll"
		else
			icon_state = base_icon
		return

//Call when target overlay should be added/removed
/mob/living/silicon/robot/update_targeted()
	if(!targeted_by && target_locked)
		del(target_locked)
	updateicon()
	if (targeted_by && target_locked)
		overlays += target_locked

/mob/living/silicon/robot/proc/installed_modules()
	if(weapon_lock)
		src << "\red Weapon lock active, unable to use modules! Count:[weaponlock_time]"
		return

	if(!module)
		pick_module()
		return
	var/dat = {"
	<HEAD>
		<TITLE>Modules</TITLE>
		<META HTTP-EQUIV='Refresh' CONTENT='10'>
	</HEAD>
	<BODY>
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}


	for (var/obj in module.modules)
		if (!obj)
			dat += text("<B>Resource depleted</B><BR>")
		else if(activated(obj))
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
	src << browse(dat, "window=robotmod&can_close=1")
	onclose(src,"robotmod") // Register on-close shit, which unsets machinery.


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
		if(isMoMMI(src))
			return
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

/mob/living/silicon/robot/sensor_mode() //Medical/Security HUD controller for borgs
	set category = "Robot Commands"
	set desc = "Augment visual feed with internal sensor overlays."
	..()
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
		//del(src.camera)
		//src.camera = null
		// I'm trying to get the Cyborg to not be listed in the camera list
		// Instead of being listed as "deactivated". The downside is that I'm going
		// to have to check if every camera is null or not before doing anything, to prevent runtime errors.
		// I could change the network to null but I don't know what would happen, and it seems too hacky for me.

		// bay's solution
		src.camera.network = list()
		cameranet.removeCamera(src.camera)


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

/mob/living/silicon/robot/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose =  copytext(sanitize(input(usr, "This is [src]. It is...", "Pose", null)  as text), 1, MAX_MESSAGE_LEN)

/mob/living/silicon/robot/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	flavor_text =  copytext(sanitize(input(usr, "Please enter your new flavour text.", "Flavour text", null)  as text), 1)

/mob/living/silicon/robot/proc/choose_icon(var/triesleft, var/list/module_sprites)
	if(triesleft == 0 || !module_sprites.len)
		return
	else
		triesleft--

	lockcharge = 1  //Locks borg until it select an icon to avoid secborgs running around with a standard sprite

	var/icontype = input("Select an icon! [triesleft>0 ? "You have [triesleft] more chances." : "This is your last try."]", "Robot", null, null) in module_sprites

	if(icontype)
		icon_state = module_sprites[icontype]
		lockcharge = null
	else
		src << "Something is badly wrong with the sprite selection. Harass a coder."
		icon_state = module_sprites[1]
		base_icon = icon_state
		lockcharge = null
		return

	overlays -= "eyes"
	base_icon = icon_state
	updateicon()

	if (triesleft >= 1)
		var/choice = input("Look at your icon - is this what you want?") in list("Yes","No")
		if(choice=="No")
			choose_icon(triesleft, module_sprites)
		else
			triesleft = 0
			return
	else
		src << "Your icon has been set. You now require a module reset to change it."

/mob/living/silicon/robot/rejuvenate()
	..()
	for(var/datum/robot_component/component in components)
		component.electronics_damage = 0
		component.brute_damage = 0
		component.installed = 1


/mob/living/silicon/robot/Process_Spaceslipping(var/prob_slip=5)
	//Engineering borgs have the magic of magnets.
	if(istype(module, /obj/item/weapon/robot_module/engineering))
		return 0
	..()

/mob/living/silicon/robot/put_in_inactive_hand(var/obj/item/W)
	return 0

/mob/living/silicon/robot/get_inactive_hand(var/obj/item/W)
	return 0
