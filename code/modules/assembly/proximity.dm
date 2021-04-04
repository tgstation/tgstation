/obj/item/assembly/prox_sensor
	name = "proximity sensor"
	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon_state = "prox"
	custom_materials = list(/datum/material/iron=800, /datum/material/glass=200)
	attachable = TRUE
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound =  'sound/items/handling/component_pickup.ogg'
	var/scanning = FALSE
	var/timing = FALSE
	var/time = 20
	var/sensitivity = 1
	var/hearing_range = 3

/obj/item/assembly/prox_sensor/Initialize()
	. = ..()
	proximity_monitor = new(src, 0)
	START_PROCESSING(SSobj, src)

/obj/item/assembly/prox_sensor/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/assembly/prox_sensor/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The proximity sensor is [timing ? "arming" : (scanning ? "armed" : "disarmed")].</span>"

/obj/item/assembly/prox_sensor/activate()
	if(!..())
		return FALSE //Cooldown check
	if(!scanning)
		timing = !timing
	else
		scanning = FALSE
	update_appearance()
	return TRUE

/obj/item/assembly/prox_sensor/on_detach()
	. = ..()
	if(!.)
		return
	else
		proximity_monitor.SetHost(src,src)

/obj/item/assembly/prox_sensor/toggle_secure()
	secured = !secured
	if(!secured)
		if(scanning)
			toggle_scan()
			proximity_monitor.SetHost(src,src)
		timing = FALSE
		STOP_PROCESSING(SSobj, src)
	else
		START_PROCESSING(SSobj, src)
		proximity_monitor.SetHost(loc,src)
	update_appearance()
	return secured

/obj/item/assembly/prox_sensor/HasProximity(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/effect/beam))
		return
	sense()

/obj/item/assembly/prox_sensor/proc/sense()
	if(!scanning || !secured || next_activate > world.time)
		return FALSE
	pulse(FALSE)
	audible_message("[icon2html(src, hearers(src))] *beep* *beep* *beep*", null, hearing_range)
	for(var/CHM in get_hearers_in_view(hearing_range, src))
		if(ismob(CHM))
			var/mob/LM = CHM
			LM.playsound_local(get_turf(src), 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	next_activate = world.time + 30
	return TRUE

/obj/item/assembly/prox_sensor/process(delta_time)
	if(!timing)
		return
	time -= delta_time
	if(time <= 0)
		timing = FALSE
		toggle_scan(TRUE)
		time = initial(time)

/obj/item/assembly/prox_sensor/proc/toggle_scan(scan)
	if(!secured)
		return FALSE
	scanning = scan
	proximity_monitor.SetRange(scanning ? sensitivity : 0)
	update_appearance()

/obj/item/assembly/prox_sensor/proc/sensitivity_change(value)
	var/sense = min(max(sensitivity + value, 0), 5)
	sensitivity = sense
	if(scanning && proximity_monitor.SetRange(sense))
		sense()

/obj/item/assembly/prox_sensor/update_appearance()
	. = ..()
	holder?.update_appearance()

/obj/item/assembly/prox_sensor/update_overlays()
	. = ..()
	attached_overlays = list()
	if(timing)
		. += "prox_timing"
		attached_overlays += "prox_timing"
	if(scanning)
		. += "prox_scanning"
		attached_overlays += "prox_scanning"

/obj/item/assembly/prox_sensor/ui_status(mob/user)
	if(is_secured(user))
		return ..()
	return UI_CLOSE

/obj/item/assembly/prox_sensor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ProximitySensor", name)
		ui.open()

/obj/item/assembly/prox_sensor/ui_data(mob/user)
	var/list/data = list()
	data["seconds"] = round(time % 60)
	data["minutes"] = round((time - data["seconds"]) / 60)
	data["timing"] = timing
	data["scanning"] = scanning
	data["sensitivity"] = sensitivity
	return data

/obj/item/assembly/prox_sensor/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("scanning")
			toggle_scan(!scanning)
			. = TRUE
		if("sense")
			var/value = text2num(params["range"])
			if(value)
				sensitivity_change(value)
				. = TRUE
		if("time")
			timing = !timing
			update_appearance()
			. = TRUE
		if("input")
			var/value = text2num(params["adjust"])
			if(value)
				value = round(time + value)
				time = clamp(value, 0, 600)
				. = TRUE
