/obj/item/assembly/timer
	name = "timer"
	desc = "Used to time things. Works well with contraptions which has to count down. Tick tock."
	icon_state = "timer"
	custom_materials = list(/datum/material/iron=500, /datum/material/glass=50)
	attachable = TRUE
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound =  'sound/items/handling/component_pickup.ogg'
	var/ui_x = 275
	var/ui_y = 115
	var/timing = FALSE
	var/time = 5
	var/saved_time = 5
	var/loop = FALSE
	var/hearing_range = 3

/obj/item/assembly/timer/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] looks at the timer and decides [user.p_their()] fate! It looks like [user.p_theyre()] going to commit suicide!</span>")
	activate()//doesnt rely on timer_end to prevent weird metas where one person can control the timer and therefore someone's life. (maybe that should be how it works...)
	addtimer(CALLBACK(src, .proc/manual_suicide, user), time*10)//kill yourself once the time runs out
	return MANUAL_SUICIDE

/obj/item/assembly/timer/proc/manual_suicide(mob/living/user)
	user.visible_message("<span class='suicide'>[user]'s time is up!</span>")
	user.adjustOxyLoss(200)
	user.death(0)

/obj/item/assembly/timer/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/assembly/timer/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/assembly/timer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The timer is [timing ? "counting down from [time]":"set for [time] seconds"].</span>"

/obj/item/assembly/timer/activate()
	if(!..())
		return FALSE//Cooldown check
	timing = !timing
	update_icon()
	return TRUE

/obj/item/assembly/timer/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSobj, src)
	else
		timing = FALSE
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured

/obj/item/assembly/timer/proc/timer_end()
	if(!secured || next_activate > world.time)
		return FALSE
	pulse(FALSE)
	audible_message("[icon2html(src, hearers(src))] *beep* *beep* *beep*", null, hearing_range)
	for(var/CHM in get_hearers_in_view(hearing_range, src))
		if(ismob(CHM))
			var/mob/LM = CHM
			LM.playsound_local(get_turf(src), 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	if(loop)
		timing = TRUE
	update_icon()

/obj/item/assembly/timer/process()
	if(!timing)
		return
	time--
	if(time <= 0)
		timing = FALSE
		timer_end()
		time = saved_time

/obj/item/assembly/timer/update_icon()
	cut_overlays()
	attached_overlays = list()
	if(timing)
		add_overlay("timer_timing")
		attached_overlays += "timer_timing"
	if(holder)
		holder.update_icon()

/obj/item/assembly/timer/ui_status(mob/user)
	if(is_secured(user))
		return ..()
	return UI_CLOSE

/obj/item/assembly/timer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.hands_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "timer", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/item/assembly/timer/ui_data(mob/user)
	var/list/data = list()
	data["seconds"] = round(time % 60)
	data["minutes"] = round((time - data["seconds"]) / 60)
	data["timing"] = timing
	data["loop"] = loop
	return data

/obj/item/assembly/timer/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("time")
			timing = !timing
			if(timing && istype(holder, /obj/item/transfer_valve))
				log_bomber(usr, "activated a", src, "attachment on [holder]")
			update_icon()
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
