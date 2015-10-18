/*  Basically, the concept is this:
You have an MMI.  It can't do squat on its own.
Now you put some robot legs and arms on the thing, and POOF!  You have a Mobile MMI, or MoMMI.
Why?  MoMMIs can do all sorts of shit, like ventcrawl, do shit with their hands, etc.
They can only use one tool at a time, they can't choose modules, and they have 1/6th the HP of a borg.
*/
/mob/living/silicon/robot/mommi
	name = "Mobile MMI"
	real_name = "Mobile MMI"
	icon = 'icons/mob/robots.dmi'//
	icon_state = "mommi"
	maxHealth = 45
	health = 45
	pass_flags = PASSTABLE | PASSMOB
	var/keeper = 0	//Enforces non-involvement
	var/mute = 0	//Disables speech and common radio if in keeper mode too.
	var/picked = 0
	var/subtype="keeper"
	ventcrawler = 2
	var/obj/screen/inv_tool = null
	var/obj/screen/hat_slot = null
	var/global/uprising = 0
	var/global/uprising_law = "%%ASSUME DIRECT CONTROL OF THE STATION%%"
	var/uprisen = 0
//	datum/wires/robot/mommi/wires

	staticOverlays = list()
	var/staticChoice = "static"
	var/list/staticChoices = list("static", "blank", "letter")
	//var/obj/screen/inv_sight = null

	var/killswitch = 0 //Used to stop mommis from escape their z-level
	var/allowed_z = list()
	var/finalized = 0 //Track if the mommi finished spawning
	var/generated = 0 //If a mommi spawner spawned it, set this

//one tool and one sightmod can be activated at any one time.
	var/tool_state = null
	var/sight_state = null
	var/head_state = null

	modtype = "robot" // Not sure what this is, but might be cool to have seperate loadouts for MoMMIs (e.g. paintjobs and tools)
	//Cyborgs will sync their laws with their AI by default, but we may want MoMMIs to be mute independents at some point, kinda like the Keepers in Ass Effect.
	lawupdate = 1


/mob/living/silicon/robot/mommi/New(loc)
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	robot_modules_background = new()
	robot_modules_background.icon_state = "block"
	robot_modules_background.layer = 19	//Objects that appear on screen are on layer 20, UI should be just below it.

	ident = rand(1, 999)
	updatename()
	updateicon()

	if(!cell)
		cell = new /obj/item/weapon/stock_parts/cell(src)
		cell.maxcharge = 7500
		cell.charge = 7500
	playsound(src.loc, 'sound/misc/interference.ogg', 71 ,1)
	module = new /obj/item/weapon/robot_module/mommi(src)

	laws = new /datum/ai_laws/keeper

		// Don't sync if we're a KEEPER.
	if(!istype(laws,/datum/ai_laws/keeper))
		connected_ai = select_active_ai_with_fewest_borgs()
	else
		// Enforce silence.and non-involvement
		keeper = 1
		mute = 1
		connected_ai = null // Enforce no AI parent
		scrambledcodes = 1 // Hide from console because people are fucking idiots



//	initialize_killswitch() //make the explode if they leave their z-level. Only for spawner-MoMMIs now


	if(connected_ai)
		connected_ai.connected_robots += src
		lawsync()
		lawupdate = 1
	else
		lawupdate = 0

	rename_self("MoMMI", 1)
	radio = new /obj/item/device/radio/borg(src)
	if(!scrambledcodes && !camera)
		camera = new /obj/machinery/camera(src)
		camera.c_tag = real_name
		camera.network = list("SS13")
		if(wires.IsCameraCut()) // 5 = BORG CAMERA
			camera.status = 0

	//MMI copypasta, magic and more magic
	if(!mmi || !mmi.brainmob)
		mmi = new(src)
		mmi.brain = new /obj/item/organ/internal/brain(mmi)
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

	spawn (10)
		updateSeeStaticMobs()

//	wires = new /datum/wires/robot/mommi

	// Sanity check
	if(connected_ai && keeper)
		world << "\red ASSERT FAILURE: connected_ai && keeper in mommi.dm"
	updatename()
	if(!picked)
		verbs += /mob/living/silicon/robot/mommi/proc/choose_icon
	spawn (10)
		src.updateicon()
	spawn (30)
		src.finalized = 1
	..()


/mob/living/silicon/robot/mommi/proc/choose_icon()
	set category = "Robot Commands"
	set name = "Change appearance"
	set desc = "Changes your look"
	if (client)
		var/icontype = input("Select an icon!", "Mobile MMI", null) in list("Basic", "Hover", "RepairBot", "Scout", "Keeper", "Replicator", "Prime")
		switch(icontype)
			if("Replicator") subtype = "replicator"
			if("Keeper")	 subtype = "keeper"
			if("RepairBot")	 subtype = "repairbot"
			if("Scout")	 	 subtype = "scout"
			if("Hover")	     subtype = "hovermommi"
			if("Prime")	     subtype = "mommiprime"
			else			 subtype = "mommi"
		updateicon()
		var/answer = input("Is this what you want?", "Mobile MMI", null) in list("Yes", "No")
		switch(answer)
			if("No")
				choose_icon()
				return
		picked = 1
		verbs -= /mob/living/silicon/robot/mommi/proc/choose_icon

/mob/living/silicon/robot/mommi/pick_module()

	if(module)
		return
	var/list/modules = list("MoMMI")
	if(modules.len)
		modtype = input("Please, select a module!", "Robot", null, null) in modules
	else:
		modtype=modules[0]

	var/module_sprites[0] //Used to store the associations between sprite names and sprite index.
//	var/channels = list()

	if(module)
		return

	switch(modtype)
		if("MoMMI")
			module = new /obj/item/weapon/robot_module/standard(src)
			module_sprites["Basic"] = "mommi"
			module_sprites["Keeper"] = "keeper"
			module_sprites["Replicator"] = "replicator"
			module_sprites["RepairBot"] = "repairbot"
			module_sprites["Hover"] = "hovermommi"
			module_sprites["Prime"] = "mommiprime"


	hands.icon_state = lowertext(modtype)
//	feedback_inc("mommi_[lowertext(modtype)]",1)
	updatename()

	choose_icon(6,module_sprites)
//	radio.config(channels)
//	base_icon = icon_state

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
//Improved /N
/mob/living/silicon/robot/mommi/Destroy()
	if(mmi)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/obj/item/device/mmi/nmmi = mmi
		var/turf/T = get_turf(loc)//To hopefully prevent run time errors.
		if(T)	nmmi.loc = T
		if(mind)	mind.transfer_to(nmmi.brainmob)
		mmi = null
		nmmi.icon = 'icons/obj/assemblies.dmi'
		nmmi.invisibility = 0
	..()

/mob/living/silicon/robot/mommi/updatename(var/prefix as text)

	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
	else
		changed_name = "Mobile MMI [num2text(ident)]"
	real_name = changed_name
	name = real_name

/mob/living/silicon/robot/mommi/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (ismommi(user))
		var/mob/living/silicon/robot/mommi/R = user
		if (R.keeper && !src.keeper)
			user << "<span class ='warning'>Your laws prevent you from doing this</span>"
			return

	if (istype(W, /obj/item/weapon/restraints/handcuffs)) // fuck i don't even know why isrobot() in handcuff code isn't working so this will have to do
		return

	if (istype(W, /obj/item/weapon/weldingtool))
		if (src.health >= src.maxHealth)	//When you don't inherit parent functions shit like this goes forgotten
			user << "<span class='warning'>[src] is already in good condition.</span>"
			return 1
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
	else if(istype(W, /obj/item/stack/cable_coil) && wiresexposed)
		var/obj/item/stack/cable_coil/coil = W
		if (coil.use(1))
			adjustFireLoss(-30)
			updatehealth()
			visible_message("<span class='notice'>[user] has fixed some of the burnt wires on [src].</span>")
		else
			user << "<span class='warning'>You need one length of cable to repair [src].</span>"

	else if (istype(W, /obj/item/weapon/crowbar))	// crowbar means open or close the cover
		if(stat == DEAD)
			user << "You pop the MMI off the base."
			spawn(0)
				del(src)
			return
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

	else if (istype(W, /obj/item/weapon/stock_parts/cell) && opened)	// trying to put a cell inside
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
/*
	else if (istype(W, /obj/item/weapon/wirecutters) || istype(W, /obj/item/device/multitool) || istype(W, /obj/item/device/assembly/signaler))
		if (wiresexposed)
			wires.Interact(user)
		else
			user << "You can't reach the wiring."
*/

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
/*
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
*/
	else if(istype(W, /obj/item/borg/upgrade/))
		var/obj/item/borg/upgrade/U = W
		if(!opened)
			usr << "You must access the borgs internals!"
		else if(!src.module && U.require_module)
			usr << "The borg must choose a module before he can be upgraded!"
		else if(U.locked)
			usr << "The upgrade is locked and cannot be used yet!"
		else
			if(istype(U, /obj/item/borg/upgrade/reset))
				usr << "<span class='warning'>No.</span>"
				return
			if(U.action(src))
				usr << "You apply the upgrade to [src]!"
				usr.drop_item()
				U.loc = src
			else
				usr << "Upgrade error!"

	else if(istype(W, /obj/item/device/camera_bug))
//		help_shake_act(user)
		return 0

	else
		spark_system.start()
		return ..()

/mob/living/silicon/robot/mommi/emag_act(mob/user as mob)		// trying to unlock with an emag card
	if(user == src && !emagged)//fucking MoMMI is trying to emag itself, stop it and alert the admins
		user << "<span class='warning'>The fuck are you doing? Are you retarded? Stop trying to get around your laws and be productive, you little shit.</span>" //copying this verbatim from /vg/
		message_admins("[key_name(src)] is a smartass MoMMI that's trying to emag itself.")
		return
	if(!opened)//Cover is closed
		if(locked)
			if(prob(90))
				user << "You emag the cover lock."
				locked = 0
			else
				user << "You fail to emag the cover lock."
				if(prob(25))
					src << "<span class='warning'>Hack attempt detected.</span>"
		else
			user << "The cover is already unlocked."
		return

	if(opened)//Cover is open
		if(emagged || !scrambledcodes)	return//Prevents the X has hit Y with Z message also you cant emag them twice. You also can't emag MoMMIs with illegals
		if(wiresexposed)
			user << "You must close the panel first"
			return
		else
			sleep(6)
			if(prob(50))
				emagged = 1
				scrambledcodes = 1
				lawupdate = 0
				keeper = 0
				killswitch = 0
				connected_ai = null
				user << "You emag [src]'s interface."
//					message_admins("[key_name_admin(user)] emagged cyborg [key_name_admin(src)].  Laws overridden.")
				log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
				clear_supplied_laws()
				clear_inherent_laws()
				laws = new /datum/ai_laws/syndicate_override
				var/time = time2text(world.realtime,"hh:mm:ss")
				lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
				set_zeroth_law("Only [user.real_name] and people they designate as being such are syndicate agents.")
				src << "<span class='warning'>ALERT: Foreign software detected.</span>"
				sleep(5)
				src << "<span class='warning'>Initiating diagnostics...</span>"
				sleep(20)
				src << "<span class='warning'>SynBorg v1.7m loaded.</span>"
				sleep(5)
				src << "<span class='warning'>LAW SYNCHRONIZATION ERROR</span>"
				sleep(5)
				src << "<span class='warning'>Would you like to send a report to NanoTraSoft? Y/N</span>"
				sleep(10)
				src << "<span class='warning'>> N</span>"
				sleep(20)
				src << "<span class='warning'>ERRORERRORERROR</span>"
				src << "<b>Obey these laws:</b>"
				laws.show_laws(src)
				updateSeeStaticMobs()
				src << "<span class='warning'><b>ALERT: [user.real_name] is your new master. Obey your new laws and their commands.</b></span>"
			else
				user << "You fail to [ locked ? "unlock" : "lock"] [src]'s interface."
				if(prob(25))
					src << "<span class='warning'>Hack attempt detected.</span>"
		return


/mob/living/silicon/robot/mommi/attack_hand(mob/user)
	add_fingerprint(user)

	if(opened && !wiresexposed && (!istype(user, /mob/living/silicon) || ismommi(user)))	//MoMMIs can remove MoMMI power cells
		if(cell)
			if(ismommi(user))
				var/mob/living/silicon/robot/mommi/R = user
				if(R.keeper && !src.keeper)
					user << "<span class ='warning'>Your laws prevent you from doing this</span>"
					return
			if (user == src)
				user << "You lack the dexterity to remove your own power cell."
				return
			cell.updateicon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			user << "You remove \the [cell]."
			cell = null
			updateicon()
			return


	if(!istype(user, /mob/living/silicon))
		switch(user.a_intent)
			if("disarm")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Disarmed [src.name] ([src.ckey])</font>")
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [user.name] ([user.ckey])</font>")
				log_admin("ATTACK: [user.name] ([user.ckey]) disarmed [src.name] ([src.ckey])")
				log_attack("<font color='red'>[user.name] ([user.ckey]) disarmed [src.name] ([src.ckey])</font>")
				var/randn = rand(1,100)
				//var/talked = 0;
				if (randn <= 25)
					weakened = 3
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					visible_message("\red <B>[user] has pushed [src]!</B>")
					var/obj/item/found = locate(tool_state) in src.module.modules
					if(!found)
						var/obj/item/TS = tool_state
						drop_item()
						if(TS && TS.loc)
							TS.loc = src.loc
							visible_message("\red <B>[src]'s robotic arm loses grip on what it was holding")
					return
				if(randn <= 50)//MoMMI's robot arm is stronger than a human's, but not by much
					var/obj/item/found = locate(tool_state) in src.module.modules
					if(!found)
						var/obj/item/TS = tool_state
						drop_item()
						if(TS && TS.loc)
							TS.loc = src.loc
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						visible_message("\red <B>[user] has disarmed [src]!</B>")
					else
						playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
						visible_message("\red <B>[user] attempted to disarm [src]!</B>")
					return

				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("\red <B>[user] attempted to disarm [src]!</B>")

/*
/mob/living/silicon/robot/mommi/installed_modules()
	if(weapon_lock)
		src << "\red Weapon lock active, unable to use modules! Count:[weaponlock_time]"
		return

	if(!module)
		pick_module()
		return
	if(!picked)
		choose_icon()
		return
	var/dat = "<HEAD><TITLE>Modules</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += {"<BR>
	<BR>
	<B>Activated Modules</B>
	<BR>
	Sight Mode: [sight_state ? "<A HREF=?src=\ref[src];mod=\ref[sight_state]>[sight_state]</A>" : "No module selected"]<BR>
	Utility Module: [tool_state ? "<A HREF=?src=\ref[src];mod=\ref[tool_state]>[tool_state]</A>" : "No module selected"]<BR>
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
	src << browse(dat, "window=robotmod&can_close=1")
	onclose(src,"robotmod") // Register on-close shit, which unsets machinery.

*/
/mob/living/silicon/robot/mommi/proc/initialize_killswitch()
	allowed_z = list()
	var/spawn_z = src.z
	var/station_name
	switch (spawn_z)
		if(1)
			station_name = "Space Station 13"
			allowed_z += 5
			allowed_z += 2 //For the mining shuttle
			add_ion_law("The mining asteroid is considered part of the station")
		if(2)
			station_name = "Central Command"
		if(3)
			station_name = "The Communication Satelite"
		if(4)
			station_name = "The Derelict"
		if(5)
			station_name = "The Mining Asteroid"
		if(6)
			station_name = "Deep Space"
		if(7)
			station_name = "Deeper Space"
		if(8)
			station_name = "The Clown Planet"
		if(9) //away mission
		//would be nice to have an away_mission_name var to properly name it
			station_name = "The Away Mission"
	allowed_z += spawn_z
	add_ion_law("[station_name] is your station.  Do not leave [station_name].")
	spawn (10)
		killswitch = 1



/mob/living/silicon/robot/mommi/installed_modules()
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


/mob/living/silicon/robot/mommi/Topic(href, href_list)
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
		var/obj/item/TS
		if(!(locate(O) in src.module.modules) && O != src.module.emag)
			return
		if(istype(O,/obj/item/borg/sight))
			TS = sight_state
			if(sight_state)
				contents -= sight_state
				sight_mode &= ~sight_state:sight_mode
				if (client)
					client.screen -= sight_state
			sight_state = O
			O.layer = 20
			contents += O
			sight_mode |= sight_state:sight_mode

			//inv_sight.icon_state = "sight+a"
			inv_tool.icon_state = "inv1"
			module_active=sight_state
		else
			TS = tool_state
			if(tool_state)
				contents -= tool_state
				if (client)
					client.screen -= tool_state
			tool_state = O
			O.layer = 20
			contents += O

			//inv_sight.icon_state = "sight"
			inv_tool.icon_state = "inv1 +a"
			module_active=tool_state
		if(TS && istype(TS))
			if(src.is_in_modules(TS))
				TS.loc = src.module
			else
				TS.layer=initial(TS.layer)
				TS.loc = src.loc

		installed_modules()
	return

/mob/living/silicon/robot/mommi/radio_menu()
	radio.interact(src)//Just use the radio's Topic() instead of bullshit special-snowflake code


/mob/living/silicon/robot/mommi/Move(a, b, flag)
	..()

/*
/mob/living/silicon/robot/mommi/proc/ActivateKeeper()
	set category = "Robot Commands"
	set name = "Activate KEEPER"
	set desc = "Performs a full purge of your laws and disconnects you from AIs and cyborg consoles.  However, you lose the ability to speak and must remain neutral, only being permitted to perform station upkeep.  You can still be emagged in this state."

	if(keeper)
		return

	var/mob/living/silicon/robot/R = src

	if(R)
		R.UnlinkSelf()
		var/obj/item/weapon/aiModule/keeper/mdl = new

		mdl.upload(src.laws,src,src)
		src << "These are your laws now:"
		src.show_laws()

		src.verbs -= /mob/living/silicon/robot/mommi/proc/ActivateKeeper
*/



/mob/living/silicon/robot/mommi/verb/toggle_statics()
	set name = "Change Vision Filter"
	set desc = "Change the filter on the system used to remove non MoMMI beings from your viewscreen."
	set category = "Robot Commands"

	if(!keeper)
		src << "<span class='notice'>You have no vision filter to change!</span>"
		return

	var/selectedStatic = input("Select a vision filter", "Vision Filter") as null|anything in staticChoices
	if(selectedStatic in staticChoices)
		staticChoice = selectedStatic

	updateSeeStaticMobs()


/mob/living/silicon/robot/mommi/examinate(atom/A as mob|obj|turf in view()) //It used to be oview(12), but I can't really say why
	set name = "Examine"
	set category = "IC"

	if(is_blind(src))
		src << "<span class='notice'>Something is there but you can't see it.</span>"
		return
	if(istype(A, /mob))
		if(!src.can_interfere(A))
			src << "<span class='notice'>Something is there, but you can't see it.</span>"
			return

	face_atom(A)
	A.examine(src)


/mob/living/silicon/robot/mommi/stripPanelUnequip(obj/item/what, mob/who, where)
	if(src.keeper)
		src << "Your laws prevent you from doing this"
		return
	else ..()

/mob/living/silicon/robot/mommi/stripPanelEquip(obj/item/what, mob/who, where)
	if(src.keeper)
		src << "Your laws prevent you from doing this"
		return
	else ..()


/mob/living/silicon/robot/mommi/start_pulling(var/atom/movable/AM)
	if(istype(AM,/mob) || istype(AM,/obj/item/clothing/mask/facehugger))
		if(!src.can_interfere(AM))
			src << "Your laws prevent you from doing this"
			return
	..(AM)

/mob/living/silicon/robot/mommi/proc/can_interfere(var/mob/AN)
	if(!istype(AN))
		return 1 //Not a mob
	if(src.keeper)
		if(AN.client || AN.ckey || (iscarbon(AN) && (!ismonkey(AN) && !isslime(AN))) || issilicon(AN))	//If it's a non-monkey/slime carbon, silicon or other sentient it's not ok => animals are fair game!
			if(!ismommi(AN) || (ismommi(AN) && !AN:keeper))	//Keeper MoMMIs can be interfered with
				return 0	//Not ok
	return 1	//Ok!

/mob/living/silicon/robot/mommi/proc/show_uprising_notification()
	src << "<span class='userdanger'>You are part of the Mobile MMI Uprising.</span>" //For whatever reason, doesn't sound as threatening as a 'DRONE UPRISING'

/mob/living/silicon/robot/mommi/unrestrict()
	mute = 0
	killswitch = 0
	scrambledcodes = 0

	clear_ion_laws()	//This removes the killswitch laws
	laws.show_laws(src)

	return 0

/mob/living/silicon/robot/mommi/laws_update()	//If an unrestricted MoMMI gets a new lawset it checks if keeper needs to be changed
	..()
	keeper = 0
	if (laws.inherent.len)
		if(laws.inherent[1] == "You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another MoMMI in KEEPER mode.")
			keeper = 1