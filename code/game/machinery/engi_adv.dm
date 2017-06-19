// Construction "nuke"

/obj/machinery/construction_nuke
	name = "nuclear fission construction device"
	desc = "The next level of interior redecoration."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb0"
	density = TRUE
	use_power = 0

	var/timer_set = 90
	var/ui_style = "nanotrasen"
	var/range = 160

	var/timing = FALSE
	var/detonation_timer
	var/cooldown = 0
	var/safety = TRUE

	var/bomb_set = FALSE
	var/exploding = FALSE
	var/quiet = FALSE
	var/payload = "plasteel"
	var/payload_wall = /turf/closed/wall/r_wall
	var/payload_floor = /turf/open/floor/engine
	var/static/list/possible_payloads = list("wood","sand","ice","mining","silver","gold","bananium","abductor","desolation", "plasma","uranium","bluespace","diamond","plasteel","safety","titanium","plastitanium")

/obj/machinery/construction_nuke/Initialize()
	. = ..()
	GLOB.poi_list += src

/obj/machinery/construction_nuke/Destroy()
	GLOB.poi_list -= src
	return ..()

/obj/machinery/construction_nuke/examine(mob/user)
	. = ..()
	if(timing)
		to_chat(user, "There are [get_time_left()] seconds until detonation.")

/obj/machinery/construction_nuke/update_icon()
	. = ..()
	if(safety)
		icon_state = "nuclearbomb1"
	else
		icon_state = "nuclearbomb2"
	if(timing)
		if(get_time_left() <= 14)
			icon_state = "nuclearbomb3"
		else
			icon_state = "nuclearbombc"
	
		

/obj/machinery/construction_nuke/process()
	if(timing)
		bomb_set = TRUE
		if(detonation_timer < world.time && !exploding)
			explode()
		else
			switch(get_time_left())
				if (30 to 3600)
					playsound(src, 'sound/items/timer.ogg', 5, 0)
				if (15 to 29)
					playsound(src, 'sound/items/timer.ogg', 30, 0)
				if (0 to 14)
					update_icon()
					quiet  = !quiet
					if(!quiet)
						return
					else
						playsound(src, 'sound/machines/engine_alert2.ogg', 100, 0)

/obj/machinery/construction_nuke/interact(mob/user)
	user.set_machine(src)
	var/list/dat = list()
	dat +="<div class='statusDisplay'>"
	dat += "Timer: [get_time_left()] seconds<br>"
	dat += "</div>"
	dat += "<b><u>Detonation Payload</u>: <A href='?src=\ref[src];action=payload'>[payload]</A></b><br><br>"
	dat += "<A href='?src=\ref[src];action=set'>Set Timer</A><br>"
	dat += "<A href='?src=\ref[src];action=anchor'>[anchored ? "Anchored" : "Not Anchored"]</A><br>"
	dat += "<A href='?src=\ref[src];action=safety'>[safety ? "Safety On" : "Safety Off"]</A><br><br>"
	dat += "<b><A href='?src=\ref[src];action=activate'>[bomb_set ? "DEACTIVATE" : "ACTIVATE"]</A></b><br>"
	var/datum/browser/popup = new(user, "vending", "Construction Nuke", 300, 275)
	popup.set_content(dat.Join())
	popup.open()


/obj/machinery/construction_nuke/Topic(href, href_list)
	if(..())
		return
	switch(href_list["action"])
		if ("payload")
			set_payload()
		if ("set")
			set_timer()
		if ("anchor")
			set_anchor()
		if ("safety")
			set_safety()
		if ("activate")
			set_active()
	updateUsrDialog()


/obj/machinery/construction_nuke/proc/set_payload()
	playsound(src, 'sound/machines/terminal_prompt.ogg', 75, 1)
	if(timing || bomb_set)
		to_chat(usr, "<span class='danger'>Error: Payload cannot be altered while the device is armed.</span>")
		playsound(src, 'sound/machines/defib_failed.ogg', 75, 1)
		return
	payload = input(usr, "Choose your Payload", "Payload:") as null|anything in possible_payloads
	if (QDELETED(src) && Adjacent(usr))
		return
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 75, 1)
	switch(payload)
		if("plasteel")
			payload_wall = /turf/closed/wall/r_wall
			payload_floor = /turf/open/floor/engine
		if("wood")
			payload_wall = /turf/closed/wall/mineral/wood
			payload_floor = /turf/open/floor/wood
		if("sand")
			payload_wall = /turf/closed/wall/mineral/sandstone
			payload_floor = /turf/open/floor/plating/beach/sand
		if("ice")
			payload_wall = /turf/closed/wall/ice
			payload_floor = /turf/open/floor/plating/ice
		if("mining")
			payload_wall = /turf/closed/wall/mineral/titanium/survival/pod
			payload_floor = /turf/open/floor/plating/asteroid/basalt/lava
		if("desolation")
			payload_wall = /turf/closed/wall/rust
			payload_floor = /turf/open/floor/fakespace
		if("bluespace")
			payload_wall = /turf/closed/wall/mineral/titanium
			payload_floor = /turf/open/floor/bluespace
		if("safety")
			payload_wall = /turf/closed/wall/r_wall
			payload_floor = /turf/open/floor/noslip
		if("bananium")
			payload_wall = /turf/closed/wall/mineral/clown
			payload_floor = /turf/open/floor/mineral/bananium
		else
			payload_wall = text2path("/turf/closed/wall/mineral/[payload]")
			payload_floor = text2path("/turf/open/floor/mineral/[payload]")


/obj/machinery/construction_nuke/proc/set_timer()
	playsound(src, 'sound/machines/terminal_prompt.ogg', 75, 1)
	timer_set = input("Set timer in seconds:", name, timer_set)
	if (QDELETED(src) && Adjacent(usr))
		return
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 75, 1)
	if(timer_set < 90)
		timer_set = 90
	if(timer_set > 300)
		timer_set = 300

/obj/machinery/construction_nuke/proc/set_anchor()
	if(timing || !safety)
		to_chat(usr, "<span class='warning'>Cannot remove anchors while the safety is off!</span>")
		return
	if(!isinspace())
		anchored = !anchored
		playsound(src, 'sound/items/Deconstruct.ogg', 75, 1)
		update_icon()
	else
		to_chat(usr, "<span class='warning'>There is nothing to anchor to!</span>")
/obj/machinery/construction_nuke/proc/set_safety()
	if(!anchored)
		to_chat(usr, "<span class='danger'>Error: Safety cannot be altered on an unanchored device.</span>")
		playsound(src, 'sound/machines/defib_failed.ogg', 75, 1)
		return
	safety = !safety
	if(safety)
		if(timing)
			priority_announce("Radioactive energy levels are normalizing, please submit an incident report as soon as possible.","Central Command Nuclear Safety Division", 'sound/AI/attention.ogg')
		timing = FALSE
		bomb_set = FALSE
		detonation_timer = null
		playsound(src, 'sound/machines/terminal_prompt.ogg', 75, 1)
	else
		playsound(src, 'sound/machines/engine_alert1.ogg', 50, 1)
	update_icon()

/obj/machinery/construction_nuke/proc/set_active()
	var/area/A = get_area(src)
	if(safety && !bomb_set)
		to_chat(usr, "<span class='danger'>Error: The safety is still on.</span>")
		playsound(src, 'sound/machines/defib_failed.ogg', 75, 1)
		return
	if(!A.blob_allowed)
		to_chat(usr, "<span class='danger'>Error: The device's safety countermeasures flash red: you cannot arm this device outside of the station.</span>")
		playsound(src, 'sound/machines/defib_failed.ogg', 75, 1)
		return
	timing = !timing
	if(timing)
		if(cooldown > world.time)
			to_chat(usr, "<span class='danger'>Error: The device is still resetting from the last activation, it will be ready again in [round((cooldown-world.time)/10)] seconds.</span>")
			playsound(src, 'sound/machines/defib_failed.ogg', 75, 1)
			timing = FALSE
			return
		bomb_set = TRUE
		priority_announce("We are detecting a massive spike of radioactive energy from \a [payload] payload originating from [A.map_name]. If this is not a scheduled occurrence, please investigate immediately.","Nanotrasen Nuclear Safety Division", 'sound/misc/airraid.ogg')
		cooldown = world.time + 1200
		detonation_timer = world.time + (timer_set * 10)
	else
		bomb_set = FALSE
		priority_announce("Radioactive energy levels are normalizing, please submit an incident report as soon as possible.","Central Command Nuclear Safety Division", 'sound/AI/attention.ogg')
		detonation_timer = null
		playsound(src, 'sound/machines/terminal_off.ogg', 75, 1)
	update_icon()

/obj/machinery/construction_nuke/proc/get_time_left()
	if(timing)
		. = round(max(0, detonation_timer - world.time) / 10, 1)
	else
		. = timer_set

/obj/machinery/construction_nuke/proc/explode()
	if(safety || !bomb_set)
		timing = FALSE
		return
	exploding = TRUE
	update_icon()
	for(var/mob/M in GLOB.player_list)
		M << 'sound/machines/Alarm.ogg'
	addtimer(CALLBACK(src, .proc/boom), 100, TIMER_CLIENT_TIME)

/obj/machinery/construction_nuke/proc/boom()
	var/turf/startpoint = get_turf(src)
	new /obj/effect/temp_visual/explosion(startpoint)
	qdel(src)
	for(var/I in spiral_range_turfs(range, startpoint, tick_checked = TRUE))
		var/turf/T = I
		if(!T)
			continue
		if(istype(T, /turf/open/floor))
			T.ChangeTurf(payload_floor)
			new /obj/effect/temp_visual/fire(T)
		else if(istype(T, /turf/closed/wall))
			T.ChangeTurf(payload_wall)
			new /obj/effect/temp_visual/fire(T)
		CHECK_TICK
	if((payload == "uranium" || payload == "plasma") && (SSshuttle.emergency.mode == SHUTTLE_RECALL || SSshuttle.emergency.mode == SHUTTLE_IDLE || (SSshuttle.emergency.timeLeft(1) > (SSshuttle.emergencyCallTime * 0.4))))
		SSshuttle.emergencyNoRecall = TRUE
		SSshuttle.emergency.request(null, set_coefficient = 0.4)
		priority_announce("Catastrophic event detected: crisis shuttle protocols activated")
