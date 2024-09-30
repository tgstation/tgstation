/obj/item/assembly/timer
	name = "timer"
	desc = "Used to time things. Works well with contraptions which has to count down. Tick tock."
	icon_state = "timer"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*5, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.5)
	attachable = TRUE
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'

	var/timing = FALSE
	var/time = 10
	var/saved_time = 10
	var/loop = FALSE
	var/hearing_range = 3

/obj/item/assembly/timer/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] looks at the timer and decides [user.p_their()] fate! It looks like [user.p_theyre()] going to commit suicide!"))
	activate()//doesnt rely on timer_end to prevent weird metas where one person can control the timer and therefore someone's life. (maybe that should be how it works...)
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), time SECONDS)//kill yourself once the time runs out
	return MANUAL_SUICIDE

/obj/item/assembly/timer/proc/manual_suicide(mob/living/user)
	user.visible_message(span_suicide("[user]'s time is up!"))
	user.adjustOxyLoss(200)
	user.death(FALSE)

/obj/item/assembly/timer/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/assembly/timer/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/assembly/timer/examine(mob/user)
	. = ..()
	. += span_notice("The timer is [timing ? "counting down from [time]":"set for [time] seconds"].")

/obj/item/assembly/timer/activate()
	if(!..())
		return FALSE//Cooldown check
	timing = !timing
	update_appearance()
	return TRUE

/obj/item/assembly/timer/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSobj, src)
	else
		timing = FALSE
		STOP_PROCESSING(SSobj, src)
	update_appearance()
	return secured

/obj/item/assembly/timer/proc/timer_end()
	if(secured && next_activate <= world.time)
		pulse()
		audible_message(span_infoplain("[icon2html(src, hearers(src))] *beep* *beep* *beep*"), null, hearing_range)
		for(var/mob/hearing_mob in get_hearers_in_view(hearing_range, src))
			hearing_mob.playsound_local(get_turf(src), 'sound/machines/beep/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	if(loop)
		timing = TRUE
	update_appearance()

/obj/item/assembly/timer/process(seconds_per_tick)
	if(!timing)
		return
	time -= seconds_per_tick
	if (time ==	9 || time == 19 || time == 29)
		update_appearance()

	if(time <= 0)
		timing = FALSE
		timer_end()
		time = saved_time

/obj/item/assembly/timer/update_appearance()
	. = ..()
	holder?.update_appearance()

/obj/item/assembly/timer/update_overlays()
	. = ..()
	attached_overlays = list()
	if(!timing)
		return

	attached_overlays += "timer_timing"
	for (var/i in 1 to clamp(ceil(time / 10), 1, 3))
		var/mutable_appearance/timer_light = mutable_appearance(icon, "timer_light", layer, src)
		timer_light.pixel_x = (i - 1) * 2
		. += timer_light

/obj/item/assembly/timer/ui_status(mob/user, datum/ui_state/state)
	if(is_secured(user))
		return ..()
	return UI_CLOSE

/obj/item/assembly/timer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Timer", name)
		ui.open()

/obj/item/assembly/timer/ui_data(mob/user)
	var/list/data = list()
	data["seconds"] = round(time % 60)
	data["minutes"] = round((time - data["seconds"]) / 60)
	data["timing"] = timing
	data["loop"] = loop
	return data

/obj/item/assembly/timer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("time")
			timing = !timing
			if(timing && istype(holder, /obj/item/transfer_valve))
				log_bomber(usr, "activated a", src, "attachment on [holder]")
			update_appearance()
			. = TRUE
		if("repeat")
			loop = !loop
			. = TRUE
		if("input")
			var/value = text2num(params["adjust"])
			if(value)
				value = round(time + value)
				time = clamp(value, 1, 600)
				saved_time = time
				. = TRUE
