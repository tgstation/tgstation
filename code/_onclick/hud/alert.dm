//A system to manage and display alerts on screen without needing you to do it yourself

//PUBLIC -  call these wherever you want


/mob/proc/throw_alert(category, type, severity, obj/new_master, override = FALSE)

/* Proc to create or update an alert. Returns the alert if the alert is new or updated, 0 if it was thrown already
 category is a text string. Each mob may only have one alert per category; the previous one will be replaced
 path is a type path of the actual alert type to throw
 severity is an optional number that will be placed at the end of the icon_state for this alert
 For example, high pressure's icon_state is "highpressure" and can be serverity 1 or 2 to get "highpressure1" or "highpressure2"
 new_master is optional and sets the alert's icon state to "template" in the ui_style icons with the master as an overlay.
 Clicks are forwarded to master
 Override makes it so the alert is not replaced until cleared by a clear_alert with clear_override, and it's used for hallucinations.
 */

	if(!category)
		return

	var/obj/screen/alert/thealert
	if(alerts[category])
		thealert = alerts[category]
		if(thealert.override_alerts)
			return 0
		if(new_master && new_master != thealert.master)
			WARNING("[src] threw alert [category] with new_master [new_master] while already having that alert with master [thealert.master]")

			clear_alert(category)
			return .()
		else if(thealert.type != type)
			clear_alert(category)
			return .()
		else if(!severity || severity == thealert.severity)
			if(thealert.timeout)
				clear_alert(category)
				return .()
			else //no need to update
				return 0
	else
		thealert = new type()
		thealert.override_alerts = override
		if(override)
			thealert.timeout = null
	thealert.mob_viewer = src

	if(new_master)
		var/old_layer = new_master.layer
		var/old_plane = new_master.plane
		new_master.layer = FLOAT_LAYER
		new_master.plane = FLOAT_PLANE
		thealert.add_overlay(new_master)
		new_master.layer = old_layer
		new_master.plane = old_plane
		thealert.icon_state = "template" // We'll set the icon to the client's ui pref in reorganize_alerts()
		thealert.master = new_master
	else
		thealert.icon_state = "[initial(thealert.icon_state)][severity]"
		thealert.severity = severity

	alerts[category] = thealert
	if(client && hud_used)
		hud_used.reorganize_alerts()
	thealert.transform = matrix(32, 6, MATRIX_TRANSLATE)
	animate(thealert, transform = matrix(), time = 2.5, easing = CUBIC_EASING)

	if(thealert.timeout)
		addtimer(CALLBACK(src, .proc/alert_timeout, thealert, category), thealert.timeout)
		thealert.timeout = world.time + thealert.timeout - world.tick_lag
	return thealert

/mob/proc/alert_timeout(obj/screen/alert/alert, category)
	if(alert.timeout && alerts[category] == alert && world.time >= alert.timeout)
		clear_alert(category)

// Proc to clear an existing alert.
/mob/proc/clear_alert(category, clear_override = FALSE)
	var/obj/screen/alert/alert = alerts[category]
	if(!alert)
		return 0
	if(alert.override_alerts && !clear_override)
		return 0

	alerts -= category
	if(client && hud_used)
		hud_used.reorganize_alerts()
		client.screen -= alert
	qdel(alert)

/obj/screen/alert
	icon = 'icons/mob/screen_alert.dmi'
	icon_state = "default"
	name = "Alert"
	desc = "Something seems to have gone wrong with this alert, so report this bug please"
	mouse_opacity = 1
	var/timeout = 0 //If set to a number, this alert will clear itself after that many deciseconds
	var/severity = 0
	var/alerttooltipstyle = ""
	var/override_alerts = FALSE //If it is overriding other alerts of the same type
	var/mob/mob_viewer //the mob viewing this alert


/obj/screen/alert/MouseEntered(location,control,params)
	openToolTip(usr,src,params,title = name,content = desc,theme = alerttooltipstyle)


/obj/screen/alert/MouseExited()
	closeToolTip(usr)


//Gas alerts
/obj/screen/alert/oxy
	name = "Choking (No O2)"
	desc = "You're not getting enough oxygen. Find some good air before you pass out! \
The box in your backpack has an oxygen tank and breath mask in it."
	icon_state = "oxy"

/obj/screen/alert/too_much_oxy
	name = "Choking (O2)"
	desc = "There's too much oxygen in the air, and you're breathing it in! Find some good air before you pass out!"
	icon_state = "too_much_oxy"

/obj/screen/alert/not_enough_co2
	name = "Choking (No CO2)"
	desc = "You're not getting enough carbon dioxide. Find some good air before you pass out!"
	icon_state = "not_enough_co2"

/obj/screen/alert/too_much_co2
	name = "Choking (CO2)"
	desc = "There's too much carbon dioxide in the air, and you're breathing it in! Find some good air before you pass out!"
	icon_state = "too_much_co2"

/obj/screen/alert/not_enough_tox
	name = "Choking (No Plasma)"
	desc = "You're not getting enough plasma. Find some good air before you pass out!"
	icon_state = "not_enough_tox"

/obj/screen/alert/tox_in_air
	name = "Choking (Plasma)"
	desc = "There's highly flammable, toxic plasma in the air and you're breathing it in. Find some fresh air. \
The box in your backpack has an oxygen tank and gas mask in it."
	icon_state = "tox_in_air"
//End gas alerts


/obj/screen/alert/fat
	name = "Fat"
	desc = "You ate too much food, lardass. Run around the station and lose some weight."
	icon_state = "fat"

/obj/screen/alert/hungry
	name = "Hungry"
	desc = "Some food would be good right about now."
	icon_state = "hungry"

/obj/screen/alert/starving
	name = "Starving"
	desc = "You're severely malnourished. The hunger pains make moving around a chore."
	icon_state = "starving"

/obj/screen/alert/hot
	name = "Too Hot"
	desc = "You're flaming hot! Get somewhere cooler and take off any insulating clothing like a fire suit."
	icon_state = "hot"

/obj/screen/alert/cold
	name = "Too Cold"
	desc = "You're freezing cold! Get somewhere warmer and take off any insulating clothing like a space suit."
	icon_state = "cold"

/obj/screen/alert/lowpressure
	name = "Low Pressure"
	desc = "The air around you is hazardously thin. A space suit would protect you."
	icon_state = "lowpressure"

/obj/screen/alert/highpressure
	name = "High Pressure"
	desc = "The air around you is hazardously thick. A fire suit would protect you."
	icon_state = "highpressure"

/obj/screen/alert/blind
	name = "Blind"
	desc = "You can't see! This may be caused by a genetic defect, eye trauma, being unconscious, \
or something covering your eyes."
	icon_state = "blind"

/obj/screen/alert/high
	name = "High"
	desc = "Whoa man, you're tripping balls! Careful you don't get addicted... if you aren't already."
	icon_state = "high"

/obj/screen/alert/drunk //Not implemented
	name = "Drunk"
	desc = "All that alcohol you've been drinking is impairing your speech, motor skills, and mental cognition. Make sure to act like it."
	icon_state = "drunk"

/obj/screen/alert/embeddedobject
	name = "Embedded Object"
	desc = "Something got lodged into your flesh and is causing major bleeding. It might fall out with time, but surgery is the safest way. \
If you're feeling frisky, click yourself in help intent to pull the object out."
	icon_state = "embeddedobject"

/obj/screen/alert/embeddedobject/Click()
	if(isliving(usr))
		var/mob/living/carbon/human/M = usr
		return M.help_shake_act(M)

/obj/screen/alert/weightless
	name = "Weightless"
	desc = "Gravity has ceased affecting you, and you're floating around aimlessly. You'll need something large and heavy, like a \
wall or lattice, to push yourself off if you want to move. A jetpack would enable free range of motion. A pair of \
magboots would let you walk around normally on the floor. Barring those, you can throw things, use a fire extinguisher, \
or shoot a gun to move around via Newton's 3rd Law of Motion."
	icon_state = "weightless"

/obj/screen/alert/fire
	name = "On Fire"
	desc = "You're on fire. Stop, drop and roll to put the fire out or move to a vacuum area."
	icon_state = "fire"

/obj/screen/alert/fire/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		return L.resist()


//ALIENS

/obj/screen/alert/alien_tox
	name = "Plasma"
	desc = "There's flammable plasma in the air. If it lights up, you'll be toast."
	icon_state = "alien_tox"
	alerttooltipstyle = "alien"

/obj/screen/alert/alien_fire
// This alert is temporarily gonna be thrown for all hot air but one day it will be used for literally being on fire
	name = "Too Hot"
	desc = "It's too hot! Flee to space or at least away from the flames. Standing on weeds will heal you."
	icon_state = "alien_fire"
	alerttooltipstyle = "alien"

/obj/screen/alert/alien_vulnerable
	name = "Severed Matriarchy"
	desc = "Your queen has been killed, you will suffer movement penalties and loss of hivemind. A new queen cannot be made until you recover."
	icon_state = "alien_noqueen"
	alerttooltipstyle = "alien"

//BLOBS

/obj/screen/alert/nofactory
	name = "No Factory"
	desc = "You have no factory, and are slowly dying!"
	icon_state = "blobbernaut_nofactory"
	alerttooltipstyle = "blob"

// BLOODCULT

/obj/screen/alert/bloodsense
	name = "Blood Sense"
	desc = "Allows you to sense blood that is manipulated by dark magicks."
	icon_state = "cult_sense"
	alerttooltipstyle = "cult"
	var/static/image/narnar
	var/angle = 0
	var/mob/living/simple_animal/hostile/construct/Cviewer = null

/obj/screen/alert/bloodsense/Initialize()
	. = ..()
	narnar = new('icons/mob/screen_alert.dmi', "mini_nar")
	START_PROCESSING(SSprocessing, src)

/obj/screen/alert/bloodsense/Destroy()
	Cviewer = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/screen/alert/bloodsense/process()
	var/atom/blood_target
	if(GLOB.blood_target)
		if(!get_turf(GLOB.blood_target))
			GLOB.blood_target = null
		else
			blood_target = GLOB.blood_target
	if(Cviewer && Cviewer.seeking && Cviewer.master)
		blood_target = Cviewer.master
		desc = "Your blood sense is leading you to [Cviewer.master]"
	if(!blood_target)
		if(!GLOB.sac_complete)
			if(icon_state == "runed_sense0")
				return
			animate(src, transform = null, time = 1, loop = 0)
			angle = 0
			cut_overlays()
			icon_state = "runed_sense0"
			desc = "Nar-Sie demands that [GLOB.sac_mind] be sacrificed before the summoning ritual can begin."
			add_overlay(GLOB.sac_image)
		else
			if(icon_state == "runed_sense1")
				return
			animate(src, transform = null, time = 1, loop = 0)
			angle = 0
			cut_overlays()
			icon_state = "runed_sense1"
			desc = "The sacrifice is complete, summon Nar-Sie! The summoning can only take place in [english_list(GLOB.summon_spots)]!"
			add_overlay(narnar)
		return
	var/turf/P = get_turf(blood_target)
	var/turf/Q = get_turf(mob_viewer)
	var/area/A = get_area(P)
	if(P.z != Q.z) //The target is on a different Z level, we cannot sense that far.
		icon_state = "runed_sense2"
		desc = "[blood_target] is no longer in your sector, you cannot sense its presence here."
		return
	desc = "You are currently tracking [blood_target] in [A.name]."
	var/target_angle = Get_Angle(Q, P)
	var/target_dist = get_dist(P, Q)
	cut_overlays()
	switch(target_dist)
		if(0 to 1)
			icon_state = "runed_sense2"
		if(2 to 8)
			icon_state = "arrow8"
		if(9 to 15)
			icon_state = "arrow7"
		if(16 to 22)
			icon_state = "arrow6"
		if(23 to 29)
			icon_state = "arrow5"
		if(30 to 36)
			icon_state = "arrow4"
		if(37 to 43)
			icon_state = "arrow3"
		if(44 to 50)
			icon_state = "arrow2"
		if(51 to 57)
			icon_state = "arrow1"
		if(58 to 64)
			icon_state = "arrow0"
		if(65 to 400)
			icon_state = "arrow"
	var/difference = target_angle - angle
	angle = target_angle
	if(!difference)
		return
	var/matrix/final = matrix(transform)
	final.Turn(difference)
	animate(src, transform = final, time = 5, loop = 0)



// CLOCKCULT
/obj/screen/alert/clockwork
	alerttooltipstyle = "clockcult"

/obj/screen/alert/clockwork/scripture_reqs
	name = "Next Tier Requirements"
	desc = "You shouldn't be seeing this description unless you're very fast. If you're very fast, good job!"
	icon_state = "no-servants-caches"

/obj/screen/alert/clockwork/scripture_reqs/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)
	process()

/obj/screen/alert/clockwork/scripture_reqs/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/screen/alert/clockwork/scripture_reqs/process()
	if(GLOB.clockwork_gateway_activated)
		mob_viewer.clear_alert("scripturereq")
		return
	var/current_state
	for(var/i in SSticker.scripture_states)
		if(!SSticker.scripture_states[i])
			current_state = i
			break
	icon_state = "no"
	if(!current_state)
		name = "Current Objective"
		for(var/obj/structure/destructible/clockwork/massive/celestial_gateway/G in GLOB.all_clockwork_objects)
			var/area/gate_area = get_area(G)
			desc = "<b>Protect the Ark at [gate_area.map_name]!</b>"
			return
		desc = "<b>All tiers of Scripture are unlocked.<br>\
		Acquire components and summon the Ark.</b>"
	else
		name = "Next Tier Requirements"
		var/validservants = 0
		var/unconverted_ais_exist = get_unconverted_ais()
		for(var/mob/living/L in GLOB.living_mob_list)
			if(is_servant_of_ratvar(L) && (ishuman(L) || issilicon(L)))
				validservants++
		var/req_servants = 0
		var/req_caches = 0
		var/req_cv = 0
		var/req_ai = FALSE
		var/list/textlist = list("Requirements for <b>[current_state] Scripture:</b>")
		switch(current_state) //get our requirements based on the tier
			if(SCRIPTURE_SCRIPT)
				req_servants = SCRIPT_SERVANT_REQ
				req_caches = SCRIPT_CACHE_REQ
			if(SCRIPTURE_APPLICATION)
				req_servants = APPLICATION_SERVANT_REQ
				req_caches = APPLICATION_CACHE_REQ
				req_cv = APPLICATION_CV_REQ
			if(SCRIPTURE_JUDGEMENT)
				req_servants = JUDGEMENT_SERVANT_REQ
				req_caches = JUDGEMENT_CACHE_REQ
				req_cv = JUDGEMENT_CV_REQ
				req_ai = TRUE
		textlist += "<br><b>[validservants]/[req_servants]</b> Servants"
		if(validservants < req_servants)
			icon_state += "-servants" //in this manner, generate an icon key based on what we're missing
		else
			textlist += ": <b><font color=#5A6068>\[CHECK\]</font></b>"
		textlist += "<br><b>[GLOB.clockwork_caches]/[req_caches]</b> Tinkerer's Caches"
		if(GLOB.clockwork_caches < req_caches)
			icon_state += "-caches"
		else
			textlist += ": <b><font color=#5A6068>\[CHECK\]</font></b>"
		if(req_cv) //cv only shows up if the tier requires it
			textlist += "<br><b>[GLOB.clockwork_construction_value]/[req_cv]</b> Construction Value"
			if(GLOB.clockwork_construction_value < req_cv)
				icon_state += "-cv"
			else
				textlist += ": <b><font color=#5A6068>\[CHECK\]</font></b>"
		if(req_ai) //same for ai
			if(unconverted_ais_exist)
				if(unconverted_ais_exist > 1)
					textlist += "<br><b>[unconverted_ais_exist] unconverted AIs exist!</b><br>"
				else
					textlist += "<br><b>An unconverted AI exists!</b>"
				icon_state += "-ai"
			else
				textlist += "<br>No unconverted AIs exist: <b><font color=#5A6068>\[CHECK\]</font></b>"
		desc = textlist.Join()

/obj/screen/alert/clockwork/infodump
	name = "Global Records"
	desc = "You shouldn't be seeing this description, because it should be dynamically generated."
	icon_state = "clockinfo"

/obj/screen/alert/clockwork/infodump/MouseEntered(location,control,params)
	if(GLOB.ratvar_awakens)
		desc = "<font size=3><b>CHETR<br>NYY<br>HAGEHUGF-NAQ-UBABE<br>RATVAR.</b></font>"
	else
		var/servants = 0
		var/validservants = 0
		var/unconverted_ais_exist = get_unconverted_ais()
		var/list/textlist
		for(var/mob/living/L in GLOB.living_mob_list)
			if(is_servant_of_ratvar(L))
				servants++
				if(ishuman(L) || issilicon(L))
					validservants++
		if(servants > 1)
			if(validservants > 1)
				textlist = list("<b>[servants]</b> Servants, <b>[validservants]</b> of which count towards scripture.<br>")
			else
				textlist = list("<b>[servants]</b> Servants, [validservants ? "<b>[validservants]</b> of which counts":"none of which count"] towards scripture.<br>")
		else
			textlist = list("<b>[servants]</b> Servant, who [validservants ? "counts":"does not count"] towards scripture.<br>")
		textlist += "<b>[GLOB.clockwork_caches ? "[GLOB.clockwork_caches]</b> Tinkerer's Caches.":"No Tinkerer's Caches, construct one!</b>"]<br>\
		<b>[GLOB.clockwork_construction_value]</b> Construction Value.<br>"
		textlist += "<b>[Floor(servants * 0.2)]</b> Tinkerer's Daemons can be active at once. <b>[LAZYLEN(GLOB.active_daemons)]</b> are active.<br>"
		for(var/obj/structure/destructible/clockwork/massive/celestial_gateway/G in GLOB.all_clockwork_objects)
			var/area/gate_area = get_area(G)
			textlist += "Ark Location: <b>[uppertext(gate_area.map_name)]</b><br>"
			if(G.still_needs_components())
				textlist += "Ark Components required: "
				for(var/i in G.required_components)
					if(G.required_components[i])
						textlist += "<b><font color=[get_component_color_bright(i)]>[G.required_components[i]]</font></b> "
				textlist += "<br>"
			else
				textlist += "Seconds until Ratvar's arrival: <b>[G.get_arrival_text(TRUE)]</b><br>"
			break
		if(unconverted_ais_exist)
			if(unconverted_ais_exist > 1)
				textlist += "<b>[unconverted_ais_exist] unconverted AIs exist!</b><br>"
			else
				textlist += "<b>An unconverted AI exists!</b><br>"
		for(var/i in SSticker.scripture_states)
			if(i != SCRIPTURE_DRIVER) //ignore the always-unlocked stuff
				textlist += "[i] Scripture: <b>[SSticker.scripture_states[i] ? "UNLOCKED":"LOCKED"]</b><br>"
		desc = textlist.Join()
	..()

//GUARDIANS

/obj/screen/alert/cancharge
	name = "Charge Ready"
	desc = "You are ready to charge at a location!"
	icon_state = "guardian_charge"
	alerttooltipstyle = "parasite"

/obj/screen/alert/canstealth
	name = "Stealth Ready"
	desc = "You are ready to enter stealth!"
	icon_state = "guardian_canstealth"
	alerttooltipstyle = "parasite"

/obj/screen/alert/instealth
	name = "In Stealth"
	desc = "You are in stealth and your next attack will do bonus damage!"
	icon_state = "guardian_instealth"
	alerttooltipstyle = "parasite"

//SILICONS

/obj/screen/alert/nocell
	name = "Missing Power Cell"
	desc = "Unit has no power cell. No modules available until a power cell is reinstalled. Robotics may provide assistance."
	icon_state = "nocell"

/obj/screen/alert/emptycell
	name = "Out of Power"
	desc = "Unit's power cell has no charge remaining. No modules available until power cell is recharged. \
Recharging stations are available in robotics, the dormitory bathrooms, and the AI satellite."
	icon_state = "emptycell"

/obj/screen/alert/lowcell
	name = "Low Charge"
	desc = "Unit's power cell is running low. Recharging stations are available in robotics, the dormitory bathrooms, and the AI satellite."
	icon_state = "lowcell"

//Need to cover all use cases - emag, illegal upgrade module, malf AI hack, traitor cyborg
/obj/screen/alert/hacked
	name = "Hacked"
	desc = "Hazardous non-standard equipment detected. Please ensure any usage of this equipment is in line with unit's laws, if any."
	icon_state = "hacked"

/obj/screen/alert/locked
	name = "Locked Down"
	desc = "Unit has been remotely locked down. Usage of a Robotics Control Console like the one in the Research Director's \
office by your AI master or any qualified human may resolve this matter. Robotics may provide further assistance if necessary."
	icon_state = "locked"

/obj/screen/alert/newlaw
	name = "Law Update"
	desc = "Laws have potentially been uploaded to or removed from this unit. Please be aware of any changes \
so as to remain in compliance with the most up-to-date laws."
	icon_state = "newlaw"
	timeout = 300

/obj/screen/alert/hackingapc
	name = "Hacking APC"
	desc = "An Area Power Controller is being hacked. When the process is \
		complete, you will have exclusive control of it, and you will gain \
		additional processing time to unlock more malfunction abilities."
	icon_state = "hackingapc"
	timeout = 600
	var/atom/target = null

/obj/screen/alert/hackingapc/Click()
	if(!usr || !usr.client) return
	if(!target) return
	var/mob/living/silicon/ai/AI = usr
	var/turf/T = get_turf(target)
	if(T)
		AI.eyeobj.setLoc(T)

//MECHS

/obj/screen/alert/low_mech_integrity
	name = "Mech Damaged"
	desc = "Mech integrity is low."
	icon_state = "low_mech_integrity"


//GHOSTS
//TODO: expand this system to replace the pollCandidates/CheckAntagonist/"choose quickly"/etc Yes/No messages
/obj/screen/alert/notify_cloning
	name = "Revival"
	desc = "Someone is trying to revive you. Re-enter your corpse if you want to be revived!"
	icon_state = "template"
	timeout = 300

/obj/screen/alert/notify_cloning/Click()
	if(!usr || !usr.client) return
	var/mob/dead/observer/G = usr
	G.reenter_corpse()

/obj/screen/alert/notify_action
	name = "Body created"
	desc = "A body was created. You can enter it."
	icon_state = "template"
	timeout = 300
	var/atom/target = null
	var/action = NOTIFY_JUMP

/obj/screen/alert/notify_action/Click()
	if(!usr || !usr.client) return
	if(!target) return
	var/mob/dead/observer/G = usr
	if(!istype(G)) return
	switch(action)
		if(NOTIFY_ATTACK)
			target.attack_ghost(G)
		if(NOTIFY_JUMP)
			var/turf/T = get_turf(target)
			if(T && isturf(T))
				G.loc = T
		if(NOTIFY_ORBIT)
			G.ManualFollow(target)

//OBJECT-BASED

/obj/screen/alert/restrained/buckled
	name = "Buckled"
	desc = "You've been buckled to something. Click the alert to unbuckle unless you're handcuffed."

/obj/screen/alert/restrained/handcuffed
	name = "Handcuffed"
	desc = "You're handcuffed and can't act. If anyone drags you, you won't be able to move. Click the alert to free yourself."

/obj/screen/alert/restrained/legcuffed
	name = "Legcuffed"
	desc = "You're legcuffed, which slows you down considerably. Click the alert to free yourself."

/obj/screen/alert/restrained/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		return L.resist()

// PRIVATE = only edit, use, or override these if you're editing the system as a whole

// Re-render all alerts - also called in /datum/hud/show_hud() because it's needed there
/datum/hud/proc/reorganize_alerts()
	var/list/alerts = mymob.alerts
	var/icon_pref
	if(!hud_shown)
		for(var/i = 1, i <= alerts.len, i++)
			mymob.client.screen -= alerts[alerts[i]]
		return 1
	for(var/i = 1, i <= alerts.len, i++)
		var/obj/screen/alert/alert = alerts[alerts[i]]
		if(alert.icon_state == "template")
			if(!icon_pref)
				icon_pref = ui_style2icon(mymob.client.prefs.UI_style)
			alert.icon = icon_pref
		switch(i)
			if(1)
				. = ui_alert1
			if(2)
				. = ui_alert2
			if(3)
				. = ui_alert3
			if(4)
				. = ui_alert4
			if(5)
				. = ui_alert5 // Right now there's 5 slots
			else
				. = ""
		alert.screen_loc = .
		mymob.client.screen |= alert
	return 1

/mob
	var/list/alerts = list() // contains /obj/screen/alert only // On /mob so clientless mobs will throw alerts properly

/obj/screen/alert/Click(location, control, params)
	if(!usr || !usr.client)
		return
	var/paramslist = params2list(params)
	if(paramslist["shift"]) // screen objects don't do the normal Click() stuff so we'll cheat
		to_chat(usr, "<span class='boldnotice'>[name]</span> - <span class='info'>[desc]</span>")
		return
	if(master)
		return usr.client.Click(master, location, control, params)

/obj/screen/alert/Destroy()
	. = ..()
	severity = 0
	master = null
	screen_loc = ""

