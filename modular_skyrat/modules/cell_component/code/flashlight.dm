/obj/item/flashlight
	/// Does this flashlight utilize batteries?
	var/uses_battery = TRUE
	/// Does this flashlight have a cell override?
	var/cell_override
	/// How much power(per process) does this flashlight use? If any.
	power_use_amount = POWER_CELL_USE_MINIMUM
	/// Flashlight mode, 0 = low, 1 = med, 2 = high
	var/flashlight_mode = 0
	///Does this flashlight have modes?
	var/has_modes = TRUE

/obj/item/flashlight/Initialize(mapload)
	. = ..()
	if(icon_state == "[initial(icon_state)]-on")
		turn_on()

/obj/item/flashlight/ComponentInitialize()
	. = ..()
	if(uses_battery)
		AddComponent(/datum/component/cell, cell_override, CALLBACK(src, .proc/turn_off))

/obj/item/flashlight/proc/update_brightness()
	set_light_on(on)
	if(light_system == STATIC_LIGHT)
		update_light()
	update_appearance()

/obj/item/flashlight/examine(mob/user)
	. = ..()
	if(has_modes)
		. += "<span class='notice'>This flashlight has modes! Ctrl+click it to change the mode.</span>"

/obj/item/flashlight/CtrlClick(mob/user)
	. = ..()
	if(has_modes)
		switch(flashlight_mode)
			if(0)
				power_use_amount = POWER_CELL_USE_MINIMUM
				light_range = initial(light_range)
				light_power = initial(light_power)
				set_light_on(on)
				flashlight_mode = 1
				to_chat(user, "<span class='notice'>You set [src] to low.</span>")
			if(1)
				power_use_amount = POWER_CELL_USE_VERY_LOW
				light_range = initial(light_range) + 2
				light_power = initial(light_power) + 1
				set_light_on(on)
				flashlight_mode = 2
				to_chat(user, "<span class='notice'>You set [src] to medium.</span>")
			if(2)
				power_use_amount = POWER_CELL_USE_LOW
				light_range = initial(light_range) + 4
				light_power = initial(light_power) + 2
				set_light_on(on)
				flashlight_mode = 0
				to_chat(user, "<span class='notice'>You set [src] to high.</span>")

/obj/item/flashlight/attack_self(mob/user)
	. = ..()
	if(on)
		on = FALSE
		turn_off(user)
	else
		if(uses_battery && !(item_use_power(power_use_amount, user, TRUE) & COMPONENT_POWER_SUCCESS))
			return
		on = TRUE
		turn_on(user)
	playsound(user, on ? 'sound/weapons/magin.ogg' : 'sound/weapons/magout.ogg', 40, TRUE)
	return TRUE

/obj/item/flashlight/proc/turn_off()
	on = FALSE
	update_brightness()
	update_action_buttons()

/obj/item/flashlight/proc/turn_on(mob/user)
	if (uses_battery)
		START_PROCESSING(SSobj, src)
	update_brightness()
	playsound(src, 'modular_skyrat/master_files/sound/effects/flashlight.ogg', 40, TRUE) //Credits to ERIS for the sound
	update_action_buttons()

/obj/item/flashlight/process(delta_time)
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return
	if(uses_battery && !(item_use_power(power_use_amount) & COMPONENT_POWER_SUCCESS))
		turn_off()

/obj/item/flashlight/update_icon_state()
	. = ..()
	if(on)
		icon_state = "[initial(icon_state)]-on"
	else
		icon_state = initial(icon_state)

/obj/item/flashlight/seclite
	cell_override = /obj/item/stock_parts/cell/upgraded

/obj/item/flashlight/lamp
	uses_battery = FALSE
	has_modes = FALSE

/obj/item/flashlight/flare
	uses_battery = FALSE
	has_modes = FALSE

/obj/item/flashlight/emp/debug
	uses_battery = FALSE

/obj/item/flashlight/glowstick
	uses_battery = FALSE

/obj/item/flashlight/spotlight
	uses_battery = FALSE
	has_modes = FALSE

/obj/item/flashlight/eyelight
	uses_battery = FALSE
	has_modes = FALSE

/obj/item/flashlight/pen
	cell_override = /obj/item/stock_parts/cell/potato
	has_modes = FALSE
