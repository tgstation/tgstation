<<<<<<< HEAD
var/list/ai_list = list()

//Not sure why this is necessary...
/proc/AutoUpdateAI(obj/subject)
	var/is_in_use = 0
	if (subject!=null)
		for(var/A in ai_list)
			var/mob/living/silicon/ai/M = A
			if ((M.client && M.machine == subject))
				is_in_use = 1
				subject.attack_ai(M)
	return is_in_use


/mob/living/silicon/ai
	name = "AI"
	icon = 'icons/mob/AI.dmi'//
	icon_state = "ai"
	anchored = 1
	density = 1
	status_flags = CANSTUN|CANPUSH
	force_compose = 1 //This ensures that the AI always composes it's own hear message. Needed for hrefs and job display.
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	see_in_dark = 8
	med_hud = DATA_HUD_MEDICAL_BASIC
	sec_hud = DATA_HUD_SECURITY_BASIC
	mob_size = MOB_SIZE_LARGE
	var/list/network = list("SS13")
	var/obj/machinery/camera/current = null
	var/list/connected_robots = list()
	var/aiRestorePowerRoutine = 0
	//var/list/laws = list()
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list(), "Burglar"=list())
	var/viewalerts = 0
	var/icon/holo_icon//Default is assigned when AI is created.
	var/obj/mecha/controlled_mech //For controlled_mech a mech, to determine whether to relaymove or use the AI eye.
	var/radio_enabled = 1 //Determins if a carded AI can speak with its built in radio or not.
	radiomod = ";" //AIs will, by default, state their laws on the internal radio.
	var/obj/item/device/pda/ai/aiPDA = null
	var/obj/item/device/multitool/aiMulti = null
	var/mob/living/simple_animal/bot/Bot
	var/tracking = 0 //this is 1 if the AI is currently tracking somebody, but the track has not yet been completed.
	var/datum/effect_system/spark_spread/spark_system//So they can initialize sparks whenever/N

	//MALFUNCTION
	var/datum/module_picker/malf_picker
	var/list/datum/AI_Module/current_modules = list()
	var/can_dominate_mechs = 0
	var/shunted = 0 //1 if the AI is currently shunted. Used to differentiate between shunted and ghosted/braindead

	var/control_disabled = 0 // Set to 1 to stop AI from interacting via Click()
	var/malfhacking = 0 // More or less a copy of the above var, so that malf AIs can hack and still get new cyborgs -- NeoFite
	var/malf_cooldown = 0 //Cooldown var for malf modules

	var/obj/machinery/power/apc/malfhack = null
	var/explosive = 0 //does the AI explode when it dies?

	var/mob/living/silicon/ai/parent = null
	var/camera_light_on = 0
	var/list/obj/machinery/camera/lit_cameras = list()

	var/datum/trackable/track = new()

	var/last_paper_seen = null
	var/can_shunt = 1
	var/last_announcement = "" // For AI VOX, if enabled
	var/turf/waypoint //Holds the turf of the currently selected waypoint.
	var/waypoint_mode = 0 //Waypoint mode is for selecting a turf via clicking.
	var/apc_override = 0 //hack for letting the AI use its APC even when visionless
	var/nuking = FALSE
	var/obj/machinery/doomsday_device/doomsday_device

	var/mob/camera/aiEye/eyeobj = new()
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1

	var/obj/machinery/camera/portable/builtInCamera

/mob/living/silicon/ai/New(loc, var/datum/ai_laws/L, var/obj/item/device/mmi/B, var/safety = 0)
	..()
	rename_self("ai")
	name = real_name
	anchored = 1
	canmove = 0
	density = 1
	loc = loc

	holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))

	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	if(L)
		if (istype(L, /datum/ai_laws))
			laws = L
	else
		make_laws()

	verbs += /mob/living/silicon/ai/proc/show_laws_verb

	aiPDA = new/obj/item/device/pda/ai(src)
	aiPDA.owner = name
	aiPDA.ownjob = "AI"
	aiPDA.name = name + " (" + aiPDA.ownjob + ")"

	aiMulti = new(src)
	radio = new /obj/item/device/radio/headset/ai(src)
	aicamera = new/obj/item/device/camera/siliconcam/ai_camera(src)

	if (istype(loc, /turf))
		verbs.Add(/mob/living/silicon/ai/proc/ai_network_change, \
		/mob/living/silicon/ai/proc/ai_statuschange, /mob/living/silicon/ai/proc/ai_hologram_change, \
		/mob/living/silicon/ai/proc/toggle_camera_light, /mob/living/silicon/ai/proc/botcall,\
		/mob/living/silicon/ai/proc/control_integrated_radio, /mob/living/silicon/ai/proc/set_automatic_say_channel)

	if(!safety)//Only used by AIize() to successfully spawn an AI.
		if (!B)//If there is no player/brain inside.
			new/obj/structure/AIcore/deactivated(loc)//New empty terminal.
			qdel(src)//Delete AI.
			return
		else
			if (B.brainmob.mind)
				B.brainmob.mind.transfer_to(src)
				rename_self("ai")
				if(mind.special_role)
					mind.store_memory("As an AI, you must obey your silicon laws above all else. Your objectives will consider you to be dead.")
					src << "<span class='userdanger'>You have been installed as an AI! </span>"
					src << "<span class='danger'>You must obey your silicon laws above all else. Your objectives will consider you to be dead.</span>"

			src << "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>"
			src << "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>"
			src << "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>"
			src << "To use something, simply click on it."
			src << "Use say :b to speak to your cyborgs through binary."
			src << "For department channels, use the following say commands:"
			src << ":o - AI Private, :c - Command, :s - Security, :e - Engineering, :u - Supply, :v - Service, :m - Medical, :n - Science."
			show_laws()
			src << "<b>These laws may be changed by other players, or by you being the traitor.</b>"

			job = "AI"
	ai_list += src
	shuttle_caller_list += src

	eyeobj.ai = src
	eyeobj.name = "[src.name] (AI Eye)" // Give it a name
	eyeobj.loc = src.loc

	builtInCamera = new /obj/machinery/camera/portable(src)
	builtInCamera.network = list("SS13")


/mob/living/silicon/ai/Destroy()
	ai_list -= src
	shuttle_caller_list -= src
	SSshuttle.autoEvac()
	qdel(eyeobj) // No AI, no Eye
	malfhack = null

	. = ..()


/mob/living/silicon/ai/verb/pick_icon()
	set category = "AI Commands"
	set name = "Set AI Core Display"
	if(stat || aiRestorePowerRoutine)
		return

		//if(icon_state == initial(icon_state))
	var/icontype = input("Please, select a display!", "AI", null/*, null*/) in list("Clown", "Monochrome", "Blue", "Inverted", "Firewall", "Green", "Red", "Static", "Red October", "House", "Heartline", "Hades", "Helios", "President", "Syndicat Meow", "Alien", "Too Deep", "Triumvirate", "Triumvirate-M", "Text", "Matrix", "Dorf", "Bliss", "Not Malf", "Fuzzy", "Goon", "Database", "Glitchman", "Murica", "Nanotrasen", "Gentoo", "Angel")
	if(icontype == "Clown")
		icon_state = "ai-clown2"
	else if(icontype == "Monochrome")
		icon_state = "ai-mono"
	else if(icontype == "Blue")
		icon_state = "ai"
	else if(icontype == "Inverted")
		icon_state = "ai-u"
	else if(icontype == "Firewall")
		icon_state = "ai-magma"
	else if(icontype == "Green")
		icon_state = "ai-wierd"
	else if(icontype == "Red")
		icon_state = "ai-malf"
	else if(icontype == "Static")
		icon_state = "ai-static"
	else if(icontype == "Red October")
		icon_state = "ai-redoctober"
	else if(icontype == "House")
		icon_state = "ai-house"
	else if(icontype == "Heartline")
		icon_state = "ai-heartline"
	else if(icontype == "Hades")
		icon_state = "ai-hades"
	else if(icontype == "Helios")
		icon_state = "ai-helios"
	else if(icontype == "President")
		icon_state = "ai-pres"
	else if(icontype == "Syndicat Meow")
		icon_state = "ai-syndicatmeow"
	else if(icontype == "Alien")
		icon_state = "ai-alien"
	else if(icontype == "Too Deep")
		icon_state = "ai-toodeep"
	else if(icontype == "Triumvirate")
		icon_state = "ai-triumvirate"
	else if(icontype == "Triumvirate-M")
		icon_state = "ai-triumvirate-malf"
	else if(icontype == "Text")
		icon_state = "ai-text"
	else if(icontype == "Matrix")
		icon_state = "ai-matrix"
	else if(icontype == "Dorf")
		icon_state = "ai-dorf"
	else if(icontype == "Bliss")
		icon_state = "ai-bliss"
	else if(icontype == "Not Malf")
		icon_state = "ai-notmalf"
	else if(icontype == "Fuzzy")
		icon_state = "ai-fuzz"
	else if(icontype == "Goon")
		icon_state = "ai-goon"
	else if(icontype == "Database")
		icon_state = "ai-database"
	else if(icontype == "Glitchman")
		icon_state = "ai-glitchman"
	else if(icontype == "Murica")
		icon_state = "ai-murica"
	else if(icontype == "Nanotrasen")
		icon_state = "ai-nanotrasen"
	else if(icontype == "Gentoo")
		icon_state = "ai-gentoo"
	else if(icontype == "Angel")
		icon_state = "ai-angel"
	//else
			//usr <<"You can only change your display once!"
			//return

/mob/living/silicon/ai/Stat()
	..()
	if(statpanel("Status"))
		if(!stat)
			stat(null, text("System integrity: [(health+100)/2]%"))
			stat(null, "Station Time: [worldtime2text()]")
			stat(null, text("Connected cyborgs: [connected_robots.len]"))
			var/area/borg_area
			for(var/mob/living/silicon/robot/R in connected_robots)
				borg_area = get_area(R)
				var/robot_status = "Nominal"
				if(R.stat || !R.client)
					robot_status = "OFFLINE"
				else if(!R.cell || R.cell.charge <= 0)
					robot_status = "DEPOWERED"
				//Name, Health, Battery, Module, Area, and Status! Everything an AI wants to know about its borgies!
				stat(null, text("[R.name] | S.Integrity: [R.health]% | Cell: [R.cell ? "[R.cell.charge]/[R.cell.maxcharge]" : "Empty"] | \
 				Module: [R.designation] | Loc: [borg_area.name] | Status: [robot_status]"))
		else
			stat(null, text("Systems nonfunctional"))

/mob/living/silicon/ai/proc/ai_alerts()
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
	var/dat = "<html><head><title>Crew Roster</title></head><body><b>Crew Roster:</b><br><br>"

	for(var/datum/data/record/t in sortRecord(data_core.general))
		dat += t.fields["name"] + " - " + t.fields["rank"] + "<br>"
	dat += "</body></html>"

	src << browse(dat, "window=airoster")
	onclose(src, "airoster")

/mob/living/silicon/ai/proc/ai_call_shuttle()
	if(stat == DEAD)
		return //won't work if dead
	if(istype(usr,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = src
		if(AI.control_disabled)
			usr << "Wireless control is disabled!"
			return

	var/reason = input(src, "What is the nature of your emergency? ([CALL_SHUTTLE_REASON_LENGTH] characters required.)", "Confirm Shuttle Call") as null|text

	if(trim(reason))
		SSshuttle.requestEvac(src, reason)

	// hack to display shuttle timer
	if(!EMERGENCY_IDLE_OR_RECALLED)
		var/obj/machinery/computer/communications/C = locate() in machines
		if(C)
			C.post_status("shuttle")

/mob/living/silicon/ai/cancel_camera()
	view_core()

/mob/living/silicon/ai/verb/toggle_anchor()
	set category = "AI Commands"
	set name = "Toggle Floor Bolts"
	if(!isturf(loc)) // if their location isn't a turf
		return // stop
	if(stat == DEAD)
		return //won't work if dead
	anchored = !anchored // Toggles the anchor

	src << "[anchored ? "<b>You are now anchored.</b>" : "<b>You are now unanchored.</b>"]"
	// the message in the [] will change depending whether or not the AI is anchored

/mob/living/silicon/ai/update_canmove() //If the AI dies, mobs won't go through it anymore
	return 0

/mob/living/silicon/ai/proc/ai_cancel_call()
	set category = "Malfunction"
	if(stat == DEAD)
		return //won't work if dead
	if(istype(usr,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = src
		if(AI.control_disabled)
			src	 << "Wireless control is disabled!"
			return
	SSshuttle.cancelEvac(src)
	return

/mob/living/silicon/ai/blob_act(obj/effect/blob/B)
	if (stat != DEAD)
		adjustBruteLoss(60)
		updatehealth()
		return 1
	return 0

/mob/living/silicon/ai/restrained(ignore_grab)
	. = 0

/mob/living/silicon/ai/emp_act(severity)
	if (prob(30))
		switch(pick(1,2))
			if(1)
				view_core()
			if(2)
				SSshuttle.requestEvac(src,"ALERT: Energy surge detected in AI core! Station integrity may be compromised! Initiati--%m091#ar-BZZT")
	..()

/mob/living/silicon/ai/ex_act(severity, target)
	..()

	switch(severity)
		if(1)
			gib()
		if(2)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3)
			if (stat != DEAD)
				adjustBruteLoss(30)

/mob/living/silicon/ai/Topic(href, href_list)
	if(usr != src)
		return
	..()
	if (href_list["mach_close"])
		if (href_list["mach_close"] == "aialerts")
			viewalerts = 0
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)
	if (href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"])) in cameranet.cameras
	if (href_list["showalerts"])
		ai_alerts()
#ifdef AI_VOX
	if(href_list["say_word"])
		play_vox_word(href_list["say_word"], null, src)
		return
#endif
	if(href_list["show_paper"])
		if(last_paper_seen)
			src << browse(last_paper_seen, "window=show_paper")
	//Carn: holopad requests
	if(href_list["jumptoholopad"])
		var/obj/machinery/hologram/holopad/H = locate(href_list["jumptoholopad"])
		if(stat == CONSCIOUS)
			if(H)
				H.attack_ai(src) //may as well recycle
			else
				src << "<span class='notice'>Unable to locate the holopad.</span>"
	if(href_list["track"])
		var/string = href_list["track"]
		trackable_mobs()
		var/list/trackeable = list()
		trackeable += track.humans + track.others
		var/list/target = list()
		for(var/I in trackeable)
			var/mob/M = trackeable[I]
			if(M.name == string)
				target += M
		if(name == string)
			target += src
		if(target.len)
			ai_actual_track(pick(target))
		else
			src << "Target is not on or near any active cameras on the station."
		return
	if(href_list["callbot"]) //Command a bot to move to a selected location.
		Bot = locate(href_list["callbot"]) in living_mob_list
		if(!Bot || Bot.remote_disabled || src.control_disabled)
			return //True if there is no bot found, the bot is manually emagged, or the AI is carded with wireless off.
		waypoint_mode = 1
		src << "<span class='notice'>Set your waypoint by clicking on a valid location free of obstructions.</span>"
		return
	if(href_list["interface"]) //Remotely connect to a bot!
		Bot = locate(href_list["interface"]) in living_mob_list
		if(!Bot || Bot.remote_disabled || src.control_disabled)
			return
		Bot.attack_ai(src)
	if(href_list["botrefresh"]) //Refreshes the bot control panel.
		botcall()
		return

	if (href_list["ai_take_control"]) //Mech domination
		var/obj/mecha/M = locate(href_list["ai_take_control"])
		if(controlled_mech)
			src << "You are already loaded into an onboard computer!"
			return
		if(M)
			M.transfer_ai(AI_MECH_HACK,src, usr) //Called om the mech itself.

/mob/living/silicon/ai/bullet_act(obj/item/projectile/Proj)
	..(Proj)
	updatehealth()
	return 2


/mob/living/silicon/ai/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(!ticker || !ticker.mode)
		M << "You cannot attack people before the game has started."
		return

	..()

/mob/living/silicon/ai/proc/switchCamera(obj/machinery/camera/C)

	if(!tracking)
		cameraFollow = null

	if (!C || stat == DEAD) //C.can_use())
		return 0

	if(!src.eyeobj)
		view_core()
		return
	// ok, we're alive, camera is good and in our network...
	eyeobj.setLoc(get_turf(C))
	//machine = src

	return 1

/mob/living/silicon/ai/proc/botcall()
	set category = "AI Commands"
	set name = "Access Robot Control"
	set desc = "Wirelessly control various automatic robots."
	if(stat == 2)
		return //won't work if dead

	if(control_disabled)
		src << "Wireless communication is disabled."
		return
	var/turf/ai_current_turf = get_turf(src)
	var/ai_Zlevel = ai_current_turf.z
	var/d
	var/area/bot_area
	d += "<A HREF=?src=\ref[src];botrefresh=1>Query network status</A><br>"
	d += "<table width='100%'><tr><td width='40%'><h3>Name</h3></td><td width='30%'><h3>Status</h3></td><td width='30%'><h3>Location</h3></td><td width='10%'><h3>Control</h3></td></tr>"

	for (Bot in living_mob_list)
		if(Bot.z == ai_Zlevel && !Bot.remote_disabled) //Only non-emagged bots on the same Z-level are detected!
			bot_area = get_area(Bot)
			var/bot_mode = Bot.get_mode()
			d += "<tr><td width='30%'>[Bot.hacked ? "<span class='bad'>(!)</span>" : ""] [Bot.name]</A> ([Bot.model])</td>"
			//If the bot is on, it will display the bot's current mode status. If the bot is not mode, it will just report "Idle". "Inactive if it is not on at all.
			d += "<td width='30%'>[bot_mode]</td>"
			d += "<td width='30%'>[bot_area.name]</td>"
			d += "<td width='10%'><A HREF=?src=\ref[src];interface=\ref[Bot]>Interface</A></td>"
			d += "<td width='10%'><A HREF=?src=\ref[src];callbot=\ref[Bot]>Call</A></td>"
			d += "</tr>"
			d = format_text(d)

	var/datum/browser/popup = new(src, "botcall", "Remote Robot Control", 700, 400)
	popup.set_content(d)
	popup.open()

/mob/living/silicon/ai/proc/set_waypoint(atom/A)
	var/turf/turf_check = get_turf(A)
		//The target must be in view of a camera or near the core.
	if(turf_check in range(get_turf(src)))
		call_bot(turf_check)
	else if(cameranet && cameranet.checkTurfVis(turf_check))
		call_bot(turf_check)
	else
		src << "<span class='danger'>Selected location is not visible.</span>"

/mob/living/silicon/ai/proc/call_bot(turf/waypoint)

	if(!Bot)
		return

	if(Bot.calling_ai && Bot.calling_ai != src) //Prevents an override if another AI is controlling this bot.
		src << "<span class='danger'>Interface error. Unit is already in use.</span>"
		return

	Bot.call_bot(src, waypoint)

/mob/living/silicon/ai/triggerAlarm(class, area/A, O, obj/alarmsource)
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
	if (O)
		if (C && C.can_use())
			queueAlarm("--- [class] alarm detected in [A.name]! (<A HREF=?src=\ref[src];switchcamera=\ref[C]>[C.c_tag]</A>)", class)
		else if (CL && CL.len)
			var/foo = 0
			var/dat2 = ""
			for (var/obj/machinery/camera/I in CL)
				dat2 += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (!foo) ? "" : " | ", src, I, I.c_tag)	//I'm not fixing this shit...
				foo = 1
			queueAlarm(text ("--- [] alarm detected in []! ([])", class, A.name, dat2), class)
		else
			queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, A.name), class)
	else
		queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, A.name), class)
	if (viewalerts) ai_alerts()
	return 1

/mob/living/silicon/ai/cancelAlarm(class, area/A, obj/origin)
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
		if (viewalerts) ai_alerts()
	return !cleared

//Replaces /mob/living/silicon/ai/verb/change_network() in ai.dm & camera.dm
//Adds in /mob/living/silicon/ai/proc/ai_network_change() instead
//Addition by Mord_Sith to define AI's network change ability
/mob/living/silicon/ai/proc/ai_network_change()
	set category = "AI Commands"
	set name = "Jump To Network"
	unset_machine()
	cameraFollow = null
	var/cameralist[0]

	if(stat == 2)
		return //won't work if dead

	var/mob/living/silicon/ai/U = usr

	for (var/obj/machinery/camera/C in cameranet.cameras)
		if(!C.can_use())
			continue

		var/list/tempnetwork = C.network
		tempnetwork.Remove("CREED", "thunder", "RD", "toxins", "Prison")
		if(tempnetwork.len)
			for(var/i in C.network)
				cameralist[i] = i
	var/old_network = network
	network = input(U, "Which network would you like to view?") as null|anything in cameralist

	if(!U.eyeobj)
		U.view_core()
		return

	if(isnull(network))
		network = old_network // If nothing is selected
	else
		for(var/obj/machinery/camera/C in cameranet.cameras)
			if(!C.can_use())
				continue
			if(network in C.network)
				U.eyeobj.setLoc(get_turf(C))
				break
	src << "<span class='notice'>Switched to [network] camera network.</span>"
//End of code by Mord_Sith


/mob/living/silicon/ai/proc/choose_modules()
	set category = "Malfunction"
	set name = "Choose Module"

	malf_picker.use(src)

/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI Status"

	if(stat == 2)
		return //won't work if dead
	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "BSOD", "Blank", "Problems?", "Awesome", "Facepalm", "Friend Computer", "Dorfy", "Blue Glow", "Red Glow")
	var/emote = input("Please, select a status!", "AI Status", null, null) in ai_emotions
	for (var/obj/machinery/M in machines) //change status
		if(istype(M, /obj/machinery/ai_status_display))
			var/obj/machinery/ai_status_display/AISD = M
			AISD.emotion = emote
		//if Friend Computer, change ALL displays
		else if(istype(M, /obj/machinery/status_display))

			var/obj/machinery/status_display/SD = M
			if(emote=="Friend Computer")
				SD.friendc = 1
			else
				SD.friendc = 0
	return

//I am the icon meister. Bow fefore me.	//>fefore
/mob/living/silicon/ai/proc/ai_hologram_change()
	set name = "Change Hologram"
	set desc = "Change the default hologram available to AI to something else."
	set category = "AI Commands"

	if(stat == 2)
		return //won't work if dead
	var/input
	if(alert("Would you like to select a hologram based on a crew member or switch to unique avatar?",,"Crew Member","Unique")=="Crew Member")

		var/personnel_list[] = list()

		for(var/datum/data/record/t in data_core.locked)//Look in data core locked.
			personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["image"]//Pull names, rank, and image.

		if(personnel_list.len)
			input = input("Select a crew member:") as null|anything in personnel_list
			var/icon/character_icon = personnel_list[input]
			if(character_icon)
				qdel(holo_icon)//Clear old icon so we're not storing it in memory.
				holo_icon = getHologramIcon(icon(character_icon))
		else
			alert("No suitable records found. Aborting.")

	else
		var/icon_list[] = list(
		"default",
		"floating face",
		"xeno queen",
		"space carp"
		)
		input = input("Please select a hologram:") as null|anything in icon_list
		if(input)
			qdel(holo_icon)
			switch(input)
				if("default")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))
				if("floating face")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo2"))
				if("xeno queen")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo3"))
				if("space carp")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo4"))
	return

/mob/living/silicon/ai/proc/corereturn()
	set category = "Malfunction"
	set name = "Return to Main Core"

	var/obj/machinery/power/apc/apc = src.loc
	if(!istype(apc))
		src << "<span class='notice'>You are already in your Main Core.</span>"
		return
	apc.malfvacate()

/mob/living/silicon/ai/proc/toggle_camera_light()
	if(stat != CONSCIOUS)
		return

	camera_light_on = !camera_light_on

	if (!camera_light_on)
		src << "Camera lights deactivated."

		for (var/obj/machinery/camera/C in lit_cameras)
			C.SetLuminosity(0)
			lit_cameras = list()

		return

	light_cameras()

	src << "Camera lights activated."

//AI_CAMERA_LUMINOSITY

/mob/living/silicon/ai/proc/light_cameras()
	var/list/obj/machinery/camera/add = list()
	var/list/obj/machinery/camera/remove = list()
	var/list/obj/machinery/camera/visible = list()
	for (var/datum/camerachunk/CC in eyeobj.visibleCameraChunks)
		for (var/obj/machinery/camera/C in CC.cameras)
			if (!C.can_use() || get_dist(C, eyeobj) > 7)
				continue
			visible |= C

	add = visible - lit_cameras
	remove = lit_cameras - visible

	for (var/obj/machinery/camera/C in remove)
		lit_cameras -= C //Removed from list before turning off the light so that it doesn't check the AI looking away.
		C.Togglelight(0)
	for (var/obj/machinery/camera/C in add)
		C.Togglelight(1)
		lit_cameras |= C

/mob/living/silicon/ai/proc/control_integrated_radio()
	set name = "Transceiver Settings"
	set desc = "Allows you to change settings of your radio."
	set category = "AI Commands"

	if(stat == 2)
		return //won't work if dead

	src << "Accessing Subspace Transceiver control..."
	if (radio)
		radio.interact(src)

/mob/living/silicon/ai/proc/set_syndie_radio()
	if(radio)
		radio.make_syndie()

/mob/living/silicon/ai/proc/set_automatic_say_channel()
	set name = "Set Auto Announce Mode"
	set desc = "Modify the default radio setting for your automatic announcements."
	set category = "AI Commands"

	if(stat == 2)
		return //won't work if dead
	set_autosay()

/mob/living/silicon/ai/attack_slime(mob/living/simple_animal/slime/user)
	return

/mob/living/silicon/ai/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/device/aicard/card)
	if(!..())
		return
	if(interaction == AI_TRANS_TO_CARD)//The only possible interaction. Upload AI mob to a card.
		if(!mind)
			user << "<span class='warning'>No intelligence patterns detected.</span>"    //No more magical carding of empty cores, AI RETURN TO BODY!!!11
			return
		new /obj/structure/AIcore/deactivated(loc)//Spawns a deactivated terminal at AI location.
		ai_restore_power()//So the AI initially has power.
		control_disabled = 1//Can't control things remotely if you're stuck in a card!
		radio_enabled = 0 	//No talking on the built-in radio for you either!
		loc = card//Throw AI into the card.
		card.AI = src
		src << "You have been downloaded to a mobile storage device. Remote device connection severed."
		user << "<span class='boldnotice'>Transfer successful</span>: [name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory."

/mob/living/silicon/ai/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0)
	return // no eyes, no flashing

/mob/living/silicon/ai/attackby(obj/item/weapon/W, mob/user, params)
	if(W.force && W.damtype != STAMINA && src.stat != DEAD) //only sparks if real damage is dealt.
		spark_system.start()
	return ..()

/mob/living/silicon/ai/can_buckle()
	return 0

/mob/living/silicon/ai/canUseTopic(atom/movable/M, be_close = 0)
	if(stat)
		return
	if(be_close && !in_range(M, src))
		return
	//stop AIs from leaving windows open and using then after they lose vision
	//apc_override is needed here because AIs use their own APC when powerless
	//get_turf_pixel() is because APCs in maint aren't actually in view of the inner camera
	if(M && cameranet && !cameranet.checkTurfVis(get_turf_pixel(M)) && !apc_override)
		return
	return 1

/mob/living/silicon/ai/proc/relay_speech(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	raw_message = lang_treat(speaker, message_langs, raw_message, spans)
	var/name_used = speaker.GetVoice()
	var/rendered = "<i><span class='game say'>Relayed Speech: <span class='name'>[name_used]</span> <span class='message'>[raw_message]</span></span></i>"
	show_message(rendered, 2)

/mob/living/silicon/ai/fully_replace_character_name(oldname,newname)
	..()
	if(oldname != real_name)
		if(eyeobj)
			eyeobj.name = "[newname] (AI Eye)"

		// Notify Cyborgs
		for(var/mob/living/silicon/robot/Slave in connected_robots)
			Slave.show_laws()

/mob/living/silicon/ai/replace_identification_name(oldname,newname)
	if(aiPDA)
		aiPDA.owner = newname
		aiPDA.name = newname + " (" + aiPDA.ownjob + ")"


/mob/living/silicon/ai/proc/add_malf_picker()
	src << "In the top right corner of the screen you will find the Malfunctions tab, where you can purchase various abilities, from upgraded surveillance to station ending doomsday devices."
	src << "You are also capable of hacking APCs, which grants you more points to spend on your Malfunction powers. The drawback is that a hacked APC will give you away if spotted by the crew. Hacking an APC takes 60 seconds."
	view_core() //A BYOND bug requires you to be viewing your core before your verbs update
	verbs += /mob/living/silicon/ai/proc/choose_modules
	malf_picker = new /datum/module_picker


/mob/living/silicon/ai/reset_perspective(atom/A)
	if(camera_light_on)
		light_cameras()
	if(istype(A,/obj/machinery/camera))
		current = A
	if(client)
		if(istype(A, /atom/movable))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			if(isturf(loc))
				if(eyeobj)
					client.eye = eyeobj
					client.perspective = MOB_PERSPECTIVE
				else
					client.eye = client.mob
					client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
		update_sight()
		if(client.eye != src)
			var/atom/AT = client.eye
			AT.get_remote_view_fullscreens(src)
		else
			clear_fullscreen("remote_view", 0)

/mob/living/silicon/ai/revive(full_heal = 0, admin_revive = 0)
	if(..()) //successfully ressuscitated from death
		icon_state = "ai"
		. = 1

/mob/living/silicon/ai/proc/malfhacked(obj/machinery/power/apc/apc)
	malfhack = null
	malfhacking = 0
	clear_alert("hackingapc")

	if(!istype(apc) || qdeleted(apc) || apc.stat & BROKEN)
		src << "<span class='danger'>Hack aborted. The designated APC no \
			longer exists on the power network.</span>"
		playsound(get_turf(src), 'sound/machines/buzz-two.ogg', 50, 1)
	else if(apc.aidisabled)
		src << "<span class='danger'>Hack aborted. \The [apc] is no \
			longer responding to our systems.</span>"
		playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1)
	else
		malf_picker.processing_time += 10

		apc.malfai = parent || src
		apc.malfhack = TRUE
		apc.locked = TRUE

		playsound(get_turf(src), 'sound/machines/ding.ogg', 50, 1)
		src << "Hack complete. \The [apc] is now under your \
			exclusive control."
		apc.update_icon()
=======
var/list/ai_list = list()

//Not sure why this is necessary...
/proc/AutoUpdateAI(obj/subject)
	var/is_in_use = 0
	if (subject!=null)
		for(var/A in ai_list)
			var/mob/living/silicon/ai/M = A
			if ((M.client && M.machine == subject))
				is_in_use = 1
				subject.attack_ai(M)
	return is_in_use


/mob/living/silicon/ai
	name = "AI"
	icon = 'icons/mob/AI.dmi'//
	icon_state = "ai"
	anchored = 1 // -- TLE
	density = 1
	status_flags = CANSTUN|CANPARALYSE
	force_compose = 1
	size = SIZE_BIG

	var/list/network = list("SS13")
	var/obj/machinery/camera/current = null
	var/list/connected_robots = list()
	var/aiRestorePowerRoutine = 0
	//var/list/laws = list()
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list())
	var/viewalerts = 0
	var/lawcheck[1]
	var/ioncheck[1]
	var/icon/holo_icon//Default is assigned when AI is created.
	var/obj/item/device/pda/ai/aiPDA = null
	var/obj/item/device/multitool/aiMulti = null
	var/custom_sprite = 0 //For our custom sprites
	var/obj/item/device/camera/ai_camera/aicamera = null
//Hud stuff

	//MALFUNCTION
	var/datum/module_picker/malf_picker
	var/processing_time = 100
	var/list/datum/AI_Module/current_modules = list()
	var/ai_flags = 0

	var/control_disabled = 0 // Set to 1 to stop AI from interacting via Click() -- TLE
	var/malfhacking = 0 // More or less a copy of the above var, so that malf AIs can hack and still get new cyborgs -- NeoFite

	var/obj/machinery/power/apc/malfhack = null
	var/explosive = 0 //does the AI explode when it dies?

	var/mob/living/silicon/ai/parent = null
	var/camera_light_on = 0
	var/list/obj/machinery/camera/lit_cameras = list()

	var/datum/trackable/track = new()

	var/last_paper_seen = null
	var/can_shunt = 1
	var/last_announcement = ""

/mob/living/silicon/ai/New(loc, var/datum/ai_laws/L, var/obj/item/device/mmi/B, var/safety = 0)
	var/list/possibleNames = ai_names

	var/pickedName = null
	while(!pickedName)
		pickedName = pick(ai_names)
		for (var/mob/living/silicon/ai/A in mob_list)
			if (A.real_name == pickedName && possibleNames.len > 1) //fixing the theoretically possible infinite loop
				possibleNames -= pickedName
				pickedName = null
	add_language(LANGUAGE_GALACTIC_COMMON, 1)
	add_language(LANGUAGE_UNATHI, 1)
	add_language(LANGUAGE_SIIK_TAJR, 1)
	add_language(LANGUAGE_SKRELLIAN, 1)
	add_language(LANGUAGE_ROOTSPEAK, 1)
	add_language(LANGUAGE_GUTTER, 1)
	add_language(LANGUAGE_CLATTER, 1)
	add_language(LANGUAGE_GREY, 1)
	add_language(LANGUAGE_MONKEY, 1)
	add_language(LANGUAGE_VOX, 1)
	add_language(LANGUAGE_TRADEBAND, 1)
	add_language(LANGUAGE_MOUSE, 1)
	add_language(LANGUAGE_HUMAN, 1)
	default_language = all_languages[LANGUAGE_GALACTIC_COMMON]
	real_name = pickedName
	name = real_name
	anchored = 1
	canmove = 0
	density = 1
	loc = loc

	radio = new /obj/item/device/radio/borg/ai(src)
	radio.recalculateChannels()

	holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))

	proc_holder_list = new()

	//Determine the AI's lawset
	if(L && istype(L,/datum/ai_laws)) src.laws = L
	else src.laws = getLawset(src)

	verbs += /mob/living/silicon/ai/proc/show_laws_verb

	aiPDA = new/obj/item/device/pda/ai(src)
	aiPDA.owner = name
	aiPDA.ownjob = "AI"
	aiPDA.name = name + " (" + aiPDA.ownjob + ")"

	aiMulti = new(src)
	aicamera = new/obj/item/device/camera/ai_camera(src)

	if (istype(loc, /turf))
		verbs.Add(/mob/living/silicon/ai/proc/ai_network_change, \
		/mob/living/silicon/ai/proc/ai_statuschange, \
		/mob/living/silicon/ai/proc/ai_hologram_change)

	if(!safety)//Only used by AIize() to successfully spawn an AI.
		if (!B)//If there is no player/brain inside.
			new/obj/structure/AIcore/deactivated(loc)//New empty terminal.
			qdel(src)//Delete AI.
			return
		else
			if (B.brainmob.mind)
				B.brainmob.mind.transfer_to(src)

			to_chat(src, "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>")
			to_chat(src, "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>")
			to_chat(src, "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>")
			to_chat(src, "To use something, simply click on it.")
			to_chat(src, "Use say :b to speak to your cyborgs through binary.")
			if (!(ticker && ticker.mode && (mind in ticker.mode.malf_ai)))
				show_laws()
				to_chat(src, "<b>These laws may be changed by other players, or by you being the traitor.</b>")

			job = "AI"
	ai_list += src
	..()
	return

/mob/living/silicon/ai/verb/radio_interact()
	set category = "AI Commands"
	set name = "Radio Configuration"
	if(stat || aiRestorePowerRoutine) return
	radio.recalculateChannels()
	radio.attack_self(usr)

/mob/living/silicon/ai/verb/rename_photo() //This is horrible but will do for now
	set category = "AI Commands"
	set name = "Modify Photo Files"
	if(stat || aiRestorePowerRoutine)
		return

	var/list/nametemp = list()
	var/find
	var/datum/picture/selection
	if(aicamera.aipictures.len == 0)
		to_chat(usr, "<font color=red><B>No images saved<B></font>")
		return
	for(var/datum/picture/t in aicamera.aipictures)
		nametemp += t.fields["name"]
	find = input("Select image to delete or rename.", "Photo Modification") in nametemp
	for(var/datum/picture/q in aicamera.aipictures)
		if(q.fields["name"] == find)
			selection = q
			break

	if(!selection) return
	var/choice = input(usr, "Would you like to rename or delete [selection.fields["name"]]?", "Photo Modification") in list("Rename","Delete","Cancel")
	switch(choice)
		if("Cancel")
			return
		if ("Delete")
			aicamera.aipictures.Remove(selection)
			qdel(selection)
		if("Rename")
			var/new_name = sanitize(input(usr, "Write a new name for [selection.fields["name"]]:","Photo Modification"))
			if(length(new_name) > 0)
				selection.fields["name"] = new_name
			else
				to_chat(usr, "You must write a name.")

/mob/living/silicon/ai/verb/pick_icon()
	set category = "AI Commands"
	set name = "Set AI Core Display"
	if(stat || aiRestorePowerRoutine)
		return
	/* Jesus christ, more of this shit?
	if(!custom_sprite) //Check to see if custom sprite time, checking the appopriate file to change a var
		var/file = file2text("config/custom_sprites.txt")
		var/lines = splittext(file, "\n")

		for(var/line in lines)
		// split & clean up
			var/list/Entry = splittext(line, "-")
			for(var/i = 1 to Entry.len)
				Entry[i] = trim(Entry[i])

			if(Entry.len < 2)
				continue;

			if(Entry[1] == src.ckey && Entry[2] == src.real_name)
				custom_sprite = 1 //They're in the list? Custom sprite time
				icon = 'icons/mob/custom-synthetic.dmi'
	*/
		//if(icon_state == initial(icon_state))
	var/icontype = ""
	/* Nuked your hidden shit.*/
	if (custom_sprite == 1) icontype = ("Custom")//automagically selects custom sprite if one is available
	else icontype = input("Select an icon!", "AI", null, null) as null|anything in list("Monochrome", "Blue", "Inverted", "Text", "Smiley", "Angry", "Dorf", "Matrix", "Bliss", "Firewall", "Green", "Red", "Broken Output", "Triumvirate", "Triumvirate Static", "Searif", "Ravensdale", "Serithi", "Static", "Wasp", "Robert House", "Red October", "Fabulous", "Girl", "Girl Malf", "Boy", "Boy Malf", "Four-Leaf", "Yes Man", "Hourglass", "Patriot", "Pirate", "Royal")
	switch(icontype)
		if("Custom") icon_state = "[src.ckey]-ai"
		if("Clown") icon_state = "ai-clown2"
		if("Monochrome") icon_state = "ai-mono"
		if("Inverted") icon_state = "ai-u"
		if("Firewall") icon_state = "ai-magma"
		if("Green") icon_state = "ai-wierd"
		if("Red") icon_state = "ai-malf"
		if("Broken Output") icon_state = "ai-static"
		if("Text") icon_state = "ai-text"
		if("Smiley") icon_state = "ai-smiley"
		if("Matrix") icon_state = "ai-matrix"
		if("Angry") icon_state = "ai-angryface"
		if("Dorf") icon_state = "ai-dorf"
		if("Bliss") icon_state = "ai-bliss"
		if("Triumvirate") icon_state = "ai-triumvirate"
		if("Triumvirate Static") icon_state = "ai-triumvirate-malf"
		if("Searif") icon_state = "ai-searif"
		if("Ravensdale") icon_state = "ai-ravensdale"
		if("Serithi") icon_state = "ai-serithi"
		if("Static") icon_state = "ai-fuzz"
		if("Wasp") icon_state = "ai-wasp"
		if("Robert House") icon_state = "ai-president"
		if("Red October") icon_state = "ai-soviet"
		if("Girl") icon_state = "ai-girl"
		if("Girl Malf") icon_state = "ai-girl-malf"
		if("Boy") icon_state = "ai-boy"
		if("Boy Malf") icon_state = "ai-boy-malf"
		if("Fabulous") icon_state = "ai-fabulous"
		if("Four-Leaf") icon_state = "ai-4chan"
		if("Yes Man") icon_state = "yes-man"
		if("Hourglass") icon_state = "ai-hourglass"
		if("Patriot") icon_state = "ai-patriot"
		if("Pirate") icon_state = "ai-pirate"
		if("Royal") icon_state = "ai-royal"
		else icon_state = "ai"
	//else
//			to_chat(usr, "You can only change your display once!")
			//return


// displays the malf_ai information if the AI is the malf
/mob/living/silicon/ai/show_malf_ai()
	if(ticker.mode.name == "AI malfunction")
		var/datum/game_mode/malfunction/malf = ticker.mode
		for (var/datum/mind/malfai in malf.malf_ai)
			if (mind == malfai) // are we the evil one?
				if (malf.apcs >= 3)
					stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/(malf.apcs/3), 0)] seconds")


/mob/living/silicon/ai/proc/ai_alerts()


	var/dat = {"<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n
<A HREF='?src=\ref[src];mach_close=aialerts'>Close</A><BR><BR>"}
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

// this verb lets the ai see the stations manifest
/mob/living/silicon/ai/proc/ai_roster()
	show_station_manifest()

/mob/living/silicon/ai/proc/ai_call_shuttle()
	if(src.stat == 2)
		to_chat(src, "You can't call the shuttle because you are dead!")
		return
	if(istype(usr,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = src
		if(AI.control_disabled)
			to_chat(usr, "Wireless control is disabled!")
			return

	var/justification = stripped_input(usr, "Please input a concise justification for the shuttle call. Note that failure to properly justify a shuttle call may lead to recall or termination.", "Nanotrasen Anti-Comdom Systems")
	var/confirm = alert("Are you sure you want to call the shuttle?", "Confirm Shuttle Call", "Yes", "Cancel")
	if(confirm == "Yes")
		call_shuttle_proc(src, justification)

	// hack to display shuttle timer
	if(emergency_shuttle.online)
		var/obj/machinery/computer/communications/C = locate() in machines
		if(C)
			C.post_status("shuttle")

	return

/mob/living/silicon/ai/proc/ai_cancel_call()
	set category = "AI Commands"

	if(src.stat == 2)
		to_chat(src, "You can't send the shuttle back because you are dead!")
		return
	if(istype(usr,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = src
		if(AI.control_disabled)
			to_chat(src, "Wireless control is disabled!")
			return
	recall_shuttle(src)

/mob/living/silicon/ai/check_eye(var/mob/user as mob)
	if (!current)
		return null
	user.reset_view(current)
	return 1

/mob/living/silicon/ai/blob_act()
	if(flags & INVULNERABLE)
		return
	if (stat != DEAD)
		..()
		playsound(loc, 'sound/effects/blobattack.ogg',50,1)
		adjustBruteLoss(60)
		updatehealth()
		return 1
	return 0

/mob/living/silicon/ai/restrained()
	if(timestopped) return 1 //under effects of time magick
	return 0

/mob/living/silicon/ai/emp_act(severity)
	if(flags & INVULNERABLE)
		return

	if (prob(30))
		switch(pick(1,2))
			if(1)
				view_core()
			if(2)
				ai_call_shuttle()
	..()

/mob/living/silicon/ai/ex_act(severity)
	if(flags & INVULNERABLE)
		return

	// if(!blinded) (this is now in flash_eyes)
	flash_eyes(visual = 1, affect_silicon = 1)

	switch(severity)
		if(1.0)
			if (stat != 2)
				adjustBruteLoss(100)
				adjustFireLoss(100)
		if(2.0)
			if (stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if (stat != 2)
				adjustBruteLoss(30)

	updatehealth()

/mob/living/silicon/ai/put_in_hands(var/obj/item/W)
	return 0

/mob/living/silicon/ai/Topic(href, href_list)
	if(usr != src)
		return
	..()
	if (href_list["mach_close"])
		if (href_list["mach_close"] == "aialerts")
			viewalerts = 0
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)
	if (href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"])) in cameranet.cameras
	if (href_list["showalerts"])
		ai_alerts()

	if(href_list["show_paper"])
		if(last_paper_seen)
			src << browse(last_paper_seen, "window=show_paper")
	//Carn: holopad requests
	if (href_list["jumptoholopad"])
		var/obj/machinery/hologram/holopad/H = locate(href_list["jumptoholopad"])
		if(stat == CONSCIOUS)
			if(H)
				H.attack_ai(src) //may as well recycle
			else
				to_chat(src, "<span class='notice'>Unable to locate the holopad.</span>")

	if(href_list["say_word"])
		play_vox_word(href_list["say_word"], null, src)
		return

	if (href_list["lawc"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawc"])
		switch(lawcheck[L+1])
			if ("Yes") lawcheck[L+1] = "No"
			if ("No") lawcheck[L+1] = "Yes"
//		to_chat(src, text ("Switching Law [L]'s report status to []", lawcheck[L+1]))
		checklaws()

	if (href_list["lawi"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawi"])
		switch(ioncheck[L])
			if ("Yes") ioncheck[L] = "No"
			if ("No") ioncheck[L] = "Yes"
//		to_chat(src, text ("Switching Law [L]'s report status to []", lawcheck[L+1]))
		checklaws()

	if (href_list["laws"]) // With how my law selection code works, I changed statelaws from a verb to a proc, and call it through my law selection panel. --NeoFite
		statelaws()

	if (href_list["track"])
		var/mob/target = locate(href_list["track"]) in mob_list
		var/mob/living/silicon/ai/A = locate(href_list["track2"]) in mob_list
		if(A && target)
			A.ai_actual_track(target)
		return

	else if (href_list["faketrack"])
		var/mob/target = locate(href_list["track"]) in mob_list
		var/mob/living/silicon/ai/A = locate(href_list["track2"]) in mob_list
		if(A && target)

			A.cameraFollow = target
			to_chat(A, text("Now tracking [] on camera.", target.name))
			if (usr.machine == null)
				usr.machine = usr

			while (src.cameraFollow == target)
				to_chat(usr, "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb).")
				sleep(40)
				continue

		return

	if (href_list["open"])
		var/mob/target = locate(href_list["open"])
		var/mob/living/silicon/ai/A = locate(href_list["open2"])
		if(A && target)
			A.open_nearest_door(target)
		return

	return

/mob/living/silicon/ai/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	updatehealth()
	return 2

/mob/living/silicon/ai/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	switch(M.a_intent)

		if (I_HELP)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("<span class='notice'>[M] caresses [src]'s plating with its scythe like arm.</span>"), 1)

		else //harm
			var/damage = rand(10, 20)
			if (prob(90))
				playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("<span class='danger'>[] has slashed at []!</span>", M, src), 1)
				if(prob(8))
					flash_eyes(visual = 1, type = /obj/screen/fullscreen/flash/noise)
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("<span class='danger'>[] took a swipe at []!</span>", M, src), 1)
	return

/mob/living/silicon/ai/attack_animal(mob/living/simple_animal/M as mob)
	if(!istype(M))
		return
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("<span class='warning'><B>[M]</B> [M.attacktext] [src]!</span>", 1)
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/silicon/ai/reset_view(atom/A)
	if (camera_light_on)
		light_cameras()
	if(istype(A,/obj/machinery/camera))
		current = A
	..()


/mob/living/silicon/ai/proc/switchCamera(var/obj/machinery/camera/C)


	src.cameraFollow = null

	if (!C || stat == 2) //C.can_use())
		return 0

	if(!src.eyeobj)
		view_core()
		return
	// ok, we're alive, camera is good and in our network...
	eyeobj.forceMove(get_turf(C))
	//machine = src

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
		if (C && C.can_use())
			queueAlarm("--- [class] alarm detected in [A.name]! (<A HREF=?src=\ref[src];switchcamera=\ref[C]>[C.c_tag]</A>)", class)
		else if (CL && CL.len)
			var/foo = 0
			var/dat2 = ""
			for (var/obj/machinery/camera/I in CL)
				dat2 += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (!foo) ? "" : " | ", src, I, I.c_tag)	//I'm not fixing this shit...
				foo = 1
			queueAlarm(text ("--- [] alarm detected in []! ([])", class, A.name, dat2), class)
		else
			queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, A.name), class)
	else
		queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, A.name), class)
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
		queueAlarm(text("--- [] alarm in [] has been cleared.", class, A.name), class, 0)
		if (viewalerts) ai_alerts()
	return !cleared

/mob/living/silicon/ai/cancel_camera()
	src.view_core()


//Replaces /mob/living/silicon/ai/verb/change_network() in ai.dm & camera.dm
//Adds in /mob/living/silicon/ai/proc/ai_network_change() instead
//Addition by Mord_Sith to define AI's network change ability
/mob/living/silicon/ai/proc/ai_network_change()
	set category = "AI Commands"
	set name = "Jump To Network"
	unset_machine()
	src.cameraFollow = null
	var/cameralist[0]

	if(usr.isDead())
		to_chat(usr, "You can't change your camera network because you are dead!")
		return

	var/mob/living/silicon/ai/U = usr

	for (var/obj/machinery/camera/C in cameranet.cameras)
		if(!C.can_use())
			continue

		var/list/tempnetwork = difflist(C.network,RESTRICTED_CAMERA_NETWORKS,1)
		if(tempnetwork.len)
			for(var/i in tempnetwork)
				cameralist[i] = i
	var/old_network = network
	network = input(U, "Which network would you like to view?") as null|anything in cameralist

	if(!U.eyeobj)
		U.view_core()
		return

	if(isnull(network))
		network = old_network // If nothing is selected
	else
		for(var/obj/machinery/camera/C in cameranet.cameras)
			if(!C.can_use())
				continue
			if(network in C.network)
				U.eyeobj.forceMove(get_turf(C))
				break
		to_chat(src, "<span class='notice'>Switched to [network] camera network.</span>")
//End of code by Mord_Sith


/mob/living/silicon/ai/proc/choose_modules()
	set category = "Malfunction"
	set name = "Choose Module"

	malf_picker.use(src)

/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI Status"

	if(usr.isDead())
		to_chat(usr, "You cannot change your emotional status because you are dead!")
		return

	var/emote = input("Please, select a status!", "AI Status", null, null) in ai_emotions //ai_emotions can be found in code/game/machinery/status_display.dm @ 213 (above the AI status display)

	for (var/obj/machinery/M in status_displays) //change status
		if(istype(M, /obj/machinery/ai_status_display))
			var/obj/machinery/ai_status_display/AISD = M
			AISD.emotion = emote
		//if Friend Computer, change ALL displays
		else if(istype(M, /obj/machinery/status_display))

			var/obj/machinery/status_display/SD = M
			if(emote=="Friend Computer")
				SD.friendc = 1
			else
				SD.friendc = 0
	return

//I am the icon meister. Bow fefore me.	//>fefore
/mob/living/silicon/ai/proc/ai_hologram_change()
	set name = "Change Hologram"
	set desc = "Change the default hologram available to AI to something else."
	set category = "AI Commands"

	var/input
	if(alert("Would you like to select a hologram based on a crew member or switch to unique avatar?",,"Crew Member","Unique")=="Crew Member")

		var/personnel_list[] = list()

		for(var/datum/data/record/t in data_core.locked)//Look in data core locked.
			personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["image"]//Pull names, rank, and image.

		if(personnel_list.len)
			input = input("Select a crew member:") as null|anything in personnel_list
			var/icon/character_icon = personnel_list[input]
			if(character_icon)
				qdel(holo_icon)//Clear old icon so we're not storing it in memory.
				holo_icon = getHologramIcon(icon(character_icon))
		else
			alert("No suitable records found. Aborting.")

	else
		var/icon_list[] = list(
		"Default",
		"Floating face",
		"Cortano",
		"Spoopy",
		"343",
		"Auto",
		"Four-Leaf",
		"Yotsuba",
		"Girl",
		"Boy",
		"SHODAN"
		)
		input = input("Please select a hologram:") as null|anything in icon_list
		if(input)
			qdel(holo_icon)
			holo_icon = null
			switch(input)
				if("Default")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))
				if("Floating face")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo2"))
				if("Cortano")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo3"))
				if("Spoopy")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo4"))
				if("343")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo5"))
				if("Auto")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo6"))
				if("Four-Leaf")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo7"))
				if("Yotsuba")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo8"))
				if("Girl")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo9"))
				if("Boy")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo10"))
				if("SHODAN")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo11"))

	return

/mob/living/silicon/ai/proc/corereturn()
	set category = "Malfunction"
	set name = "Return to Main Core"

	var/obj/machinery/power/apc/apc = src.loc
	if(!istype(apc))
		to_chat(src, "<span class='notice'>You are already in your Main Core.</span>")
		return
	apc.malfvacate()

//Toggles the luminosity and applies it by re-entereing the camera.
/mob/living/silicon/ai/verb/toggle_camera_light()
	set name = "Toggle Camera Light"
	set desc = "Toggle internal infrared camera light"
	set category = "AI Commands"
	if(stat != CONSCIOUS)
		return

	camera_light_on = !camera_light_on

	if (!camera_light_on)
		to_chat(src, "Camera lights deactivated.")

		for (var/obj/machinery/camera/C in lit_cameras)
			C.set_light(0)
			lit_cameras = list()

		return

	light_cameras()

	to_chat(src, "Camera lights activated.")
	return

//AI_CAMERA_LUMINOSITY

/mob/living/silicon/ai/proc/light_cameras()
	var/list/obj/machinery/camera/add = list()
	var/list/obj/machinery/camera/remove = list()
	var/list/obj/machinery/camera/visible = list()
	for (var/datum/camerachunk/CC in eyeobj.visibleCameraChunks)
		for (var/obj/machinery/camera/C in CC.cameras)
			if (!C.can_use() || C.light_disabled || get_dist(C, eyeobj) > 7)
				continue
			visible |= C

	add = visible - lit_cameras
	remove = lit_cameras - visible

	for (var/obj/machinery/camera/C in remove)
		C.set_light(0)
		lit_cameras -= C
	for (var/obj/machinery/camera/C in add)
		C.set_light(AI_CAMERA_LUMINOSITY)
		lit_cameras |= C


/mob/living/silicon/ai/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswrench(W))
		if(anchored)
			user.visible_message("<span class='notice'>\The [user] starts to unbolt \the [src] from the plating...</span>")
			if(!do_after(user, src,40))
				user.visible_message("<span class='notice'>\The [user] decides not to unbolt \the [src].</span>")
				return
			user.visible_message("<span class='notice'>\The [user] finishes unfastening \the [src]!</span>")
			anchored = 0
			return
		else
			user.visible_message("<span class='notice'>\The [user] starts to bolt \the [src] to the plating...</span>")
			if(!do_after(user, src,40))
				user.visible_message("<span class='notice'>\The [user] decides not to bolt \the [src].</span>")
				return
			user.visible_message("<span class='notice'>\The [user] finishes fastening down \the [src]!</span>")
			anchored = 1
			return
	else
		return ..()


/mob/living/silicon/ai/get_multitool(var/active_only=0)
	return aiMulti

// An AI doesn't become inoperable until -100% (or whatever config.health_threshold_dead is set to)
/mob/living/silicon/ai/system_integrity()
	return (health - config.health_threshold_dead) / 2

/mob/living/silicon/ai/html_mob_check()
	return 1

/mob/living/silicon/ai/isTeleViewing(var/client_eye)
	return 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
