//A system to manage and display alerts on screen without needing you to do it yourself

//PUBLIC -  call these wherever you want


/mob/proc/throw_alert(category, id, severity, obj/new_master)

/* Proc to create or update an alert. Returns 1 if the alert is new or updated, 0 if it was thrown already

 category is a text string. Each mob may only have one alert per category; the previous one will be replaced

 id is a text string, If you don't provide one, category will be used as id
 Either way it MUST match a type path like so: /obj/screen/alert/[id]
 Also the alert's icon_state will be [id] so you must add it to screen_alert.dmi

 severity is an optional number that will be placed at the end of the icon_state for this alert
 For example, high pressure's id is "highpressure" and can be serverity 1 or 2 to get "highpressure1" or "highpressure2" as icon_states

 new_master is optional and sets the alert's icon state to "template" in the ui_style icons with the master as an overlay.
 Clicks are forwarded to master */

	if(!category)
		return
	if(!id)
		id = category

	var/obj/screen/alert/alert
	if(alerts[category])
		alert = alerts[category]
		if(new_master && new_master != alert.master)
			WARNING("[src] threw alert [category] with new_master [new_master] while already having that alert with master [alert.master]")
//			alert.overlays.Cut() // This is apparently an invalid expression
			clear_alert(category)
			return .()
		else if(alert.icon_state == "[id][severity]")
			if(alert.timeout)
				clear_alert(category)
				return .()
			else
	//			src << "threw alert not in need of update [category] [id] [severity]"
				return 0
//		src << "updating alert [category] [id] [severity]"
	else
		alert = PoolOrNew(/obj/screen/alert)
//		src << "throwing new alert [category] [id] [severity]"

	if(new_master)
		var/old_layer = new_master.layer
		new_master.layer = FLOAT_LAYER
		alert.overlays += new_master
		new_master.layer = old_layer
		alert.icon_state = "template" // We'll set the icon to the client's ui pref in reorganize_alerts()
		alert.master = new_master
	else
		alert.icon_state = "[id][severity]"

	alerts[category] = alert
	if(client && hud_used)
		hud_used.reorganize_alerts()
	alert.transform = matrix(32, 6, MATRIX_TRANSLATE)
	animate(alert, transform = matrix(), time = 2.5, easing = CUBIC_EASING)

	var/obj/screen/alert/path_as_obj = text2path("/obj/screen/alert/[id]")
	// BYOND magic-fu - we'll be storing a path in this reference and retrieving vars from it.
	if(!path_as_obj)
		ERROR("[src] threw alert [category] with invalid path /obj/screen/alert/[id]")
		return 0
	alert.name = initial(path_as_obj.name)
	alert.desc = initial(path_as_obj.desc)
	alert.timeout = initial(path_as_obj.timeout)
	if(alert.timeout)
		spawn(alert.timeout)
			if(alert.timeout && alerts[category] == alert && world.time >= alert.timeout)
				clear_alert(category)
		alert.timeout = world.time + alert.timeout - world.tick_lag
	alert.mouse_opacity = 1

	return alert

// Proc to clear an existing alert.
/mob/proc/clear_alert(category)
	var/obj/screen/alert/alert = alerts[category]
	if(!alert)
		return 0

	alerts -= category
	if(client && hud_used)
		hud_used.reorganize_alerts()
		client.screen -= alert
	qdel(alert)

// Make sure any alerts you throw have a path that matches /obj/screen/alert/[id] or /obj/screen/alert/[category]

/obj/screen/alert
	icon = 'icons/mob/screen_alert.dmi'
	icon_state = "default"
	name = "Alert"
	desc = "Something seems to have gone wrong with this alert, so report this bug please"
	var/timeout = 0 //If set to a number, this alert will clear itself after that many deciseconds


//Gas alerts
/obj/screen/alert/oxy
	name = "Choking (No O2)"
	desc = "You're not getting enough oxygen. Find some good air before you pass out! \
The box in your backpack has an oxygen tank and gas mask in it."

/obj/screen/alert/too_much_oxy
	name = "Choking (O2)"
	desc = "There's too much oxygen in the air, and you're breathing it in! Find some good air before you pass out!"

/obj/screen/alert/not_enough_co2
	name = "Choking (No CO2)"
	desc = "You're not getting enough carbon dioxide. Find some good air before you pass out!"

/obj/screen/alert/too_much_co2
	name = "Chocking (CO2)"
	desc = "There's too much carbon dioxide in the air, and you're breathing it in! Find some good air before you pass out!"

/obj/screen/alert/not_enough_tox
	name = "Choking (No Plasma)"
	desc = "You're not getting enough plasma. Find some good air before you pass out!"

/obj/screen/alert/tox_in_air
	name = "Choking (Plasma)"
	desc = "There's highly flammable, toxic plasma in the air and you're breathing it in. Find some fresh air. \
The box in your backpack has an oxygen tank and gas mask in it."
//End gas alerts


/obj/screen/alert/fat
	name = "Fat"
	desc = "You ate too much food, lardass. Run around the station and lose some weight."

/obj/screen/alert/hungry
	name = "Hungry"
	desc = "Some food would be good right about now."

/obj/screen/alert/starving
	name = "Starving"
	desc = "Some food would be to kill for right about now. The hunger pains make moving around a chore."

/obj/screen/alert/hot
	name = "Too Hot"
	desc = "You're flaming hot! Get somewhere cooler and take off any insulating clothing like a fire suit."

/obj/screen/alert/cold
	name = "Too Cold"
	desc = "You're freezing cold! Get somewhere warmer and take off any insulating clothing like a space suit."

/obj/screen/alert/lowpressure
	name = "Low Pressure"
	desc = "The air around you is hazardously thin. A space suit would protect you."

/obj/screen/alert/highpressure
	name = "High Pressure"
	desc = "The air around you is hazardously thick. A fire suit would protect you."

/obj/screen/alert/blind
	name = "Blind"
	desc = "For whatever reason, you can't see. This may be caused by a genetic defect, eye trauma, being unconscious, \
or something covering your eyes."

/obj/screen/alert/high
	name = "High"
	desc = "Woah man, you're tripping balls! Careful you don't get addicted to this... if you aren't already."

/obj/screen/alert/drunk //Not implemented
	name = "Drunk"
	desc = "All that alcohol you've been drinking is impairing your speech, motor skills, and mental cognition. Make sure to act like it."

/obj/screen/alert/embeddedobject
	name = "Embedded Object"
	desc = "Something got lodged into your flesh and is causing major bleeding. It might fall out with time, but surgery is the safest way. \
If you're feeling frisky, click yourself in help intent to pull the object out."

/obj/screen/alert/asleep
	name = "Asleep"
	desc = "You've fallen asleep. Wait a bit and you should wake up. Unless you don't, considering how helpless you are."

/obj/screen/alert/weightless
	name = "Weightless"
	desc = "Gravity has ceased affecting you, and you're floating around aimlessly. You'll need something large and heavy, like a \
wall or lattice strucure, to push yourself off of if you want to move. A jetpack would enable free range of motion. A pair of \
magboots would let you walk around normally on the floor. Barring those, you can throw things, use a fire extuingisher, \
or shoot a gun to move around via Newton's 3rd Law of motion."

//ALIENS

/obj/screen/alert/alien_tox
	name = "Plasma"
	desc = "There's flammable plasma in the air. If it lights up, you'll be toast."

/obj/screen/alert/alien_fire
// This alert is temporarily gonna be thrown for all hot air but one day it will be used for literally being on fire
	name = "Burning"
	desc = "It's too hot! Flee to space or at least away from the flames. Standing on weeds will heal you up."


//SILICONS

/obj/screen/alert/nocell
	name = "Missing Power Cell"
	desc = "Unit has no power cell. No modules available until a power cell is reinstalled. Robotics may provide assistance."

/obj/screen/alert/emptycell
	name = "Out of Power"
	desc = "Unit's power cell has no charge remaining. No modules available until power cell is recharged. \
Reharging stations are available in robotics, the dormitory's bathrooms. and the AI satelite."

/obj/screen/alert/lowcell
	name = "Low Charge"
	desc = "Unit's power cell is running low. Reharging stations are available in robotics, the dormitory's bathrooms. and the AI satelite."

//Need to cover all use cases - emag, illegal upgrade module, malf AI hack, traitor cyborg
/obj/screen/alert/hacked
	name = "Hacked"
	desc = "Hazardous non-standard equipment detected. Please ensure any usage of this equipment is in line with unit's laws, if any."

/obj/screen/alert/locked
	name = "Locked Down"
	desc = "Unit has remotely locked down. Usage of a Robotics Control Computer like the one in the Research Director's \
office by your AI master or any qualified human may resolve this matter. Robotics my provide further assistance if necessary."

/obj/screen/alert/newlaw
	name = "Law Update"
	desc = "Laws have potentially been uploaded to or removed from this unit. Please be aware of any changes \
so as to remain in compliance with the most up-to-date laws."
	timeout = 300

//MECHS

/obj/screen/alert/low_mech_integrity
	name = "Mech Damaged"
	desc = "Mech integrity is low."


//OBJECT-BASED

/obj/screen/alert/buckled
	name = "Buckled"
	desc = "You've been buckled to something and can't move. Click the alert to unbuckle unless you're handcuffed."

/obj/screen/alert/handcuffed // Not used right now.
	name = "Handcuffed"
	desc = "You're handcuffed and can't act. If anyone drags you, you won't be able to move. Click the alert to free yourself."

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
		usr << "<span class='boldnotice'>[name]</span> - <span class='info'>[desc]</span>"
		return
	if(master)
		return usr.client.Click(master, location, control, params)

/obj/screen/alert/Destroy()
	return QDEL_HINT_PUTINPOOL //Don't destroy me, I have a family!
