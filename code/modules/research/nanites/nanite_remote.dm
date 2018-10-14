#define REMOTE_MODE_OFF "Off"
#define REMOTE_MODE_SELF "Local"
#define REMOTE_MODE_TARGET "Targeted"
#define REMOTE_MODE_AOE "Area"
#define REMOTE_MODE_RELAY "Relay"

/obj/item/nanite_remote
	name = "nanite remote control"
	desc = "A device that can remotely control active nanites through wireless signals."
	w_class = WEIGHT_CLASS_SMALL
	req_access = list(ACCESS_ROBOTICS)
	icon = 'icons/obj/device.dmi'
	icon_state = "nanite_remote"
	item_flags = NOBLUDGEON
	var/locked = FALSE //Can be locked, so it can be given to users with a set code and mode
	var/mode = REMOTE_MODE_OFF
	var/list/saved_settings = list()
	var/last_id = 0
	var/code = 0
	var/relay_code = 0

/obj/item/nanite_remote/examine(mob/user)
	. = ..()
	if(locked)
		to_chat(user, "<span class='notice'>Alt-click to unlock.</span>")

/obj/item/nanite_remote/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(locked)
		if(allowed(user))
			to_chat(user, "<span class='notice'>You unlock [src].</span>")
			locked = FALSE
			update_icon()
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/item/nanite_remote/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, "<span class='warning'>You override [src]'s ID lock.</span>")
	obj_flags |= EMAGGED
	if(locked)
		locked = FALSE
		update_icon()

/obj/item/nanite_remote/update_icon()
	. = ..()
	cut_overlays()
	if(obj_flags & EMAGGED)
		add_overlay("nanite_remote_emagged")
	if(locked)
		add_overlay("nanite_remote_locked")

/obj/item/nanite_remote/afterattack(atom/target, mob/user, etc)
	switch(mode)
		if(REMOTE_MODE_OFF)
			return
		if(REMOTE_MODE_SELF)
			to_chat(user, "<span class='notice'>You activate [src], signaling the nanites in your bloodstream.<span>")
			signal_mob(user, code, key_name(user))
		if(REMOTE_MODE_TARGET)
			if(isliving(target) && (get_dist(target, get_turf(src)) <= 7))
				to_chat(user, "<span class='notice'>You activate [src], signaling the nanites inside [target].<span>")
				signal_mob(target, code, key_name(user))
		if(REMOTE_MODE_AOE)
			to_chat(user, "<span class='notice'>You activate [src], signaling the nanites inside every host around you.<span>")
			for(var/mob/living/L in view(user, 7))
				signal_mob(L, code, key_name(user))
		if(REMOTE_MODE_RELAY)
			to_chat(user, "<span class='notice'>You activate [src], signaling all connected relay nanites.<span>")
			signal_relay(code, relay_code, key_name(user))

/obj/item/nanite_remote/proc/signal_mob(mob/living/M, code, source)
	SEND_SIGNAL(M, COMSIG_NANITE_SIGNAL, code, source)

/obj/item/nanite_remote/proc/signal_relay(code, relay_code, source)
	for(var/X in SSnanites.nanite_relays)
		var/datum/nanite_program/relay/N = X
		N.relay_signal(code, relay_code, source)

/obj/item/nanite_remote/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.hands_state)
	SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "nanite_remote", name, 420, 800, master_ui, state)
		ui.open()

/obj/item/nanite_remote/ui_data()
	var/list/data = list()
	data["code"] = code
	data["relay_code"] = relay_code
	data["mode"] = mode
	data["locked"] = locked
	data["saved_settings"] = saved_settings

	return data

/obj/item/nanite_remote/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("set_code")
			if(locked)
				return
			var/new_code = input("Set code (0000-9999):", name, code) as null|num
			if(!isnull(new_code))
				new_code = CLAMP(round(new_code, 1),0,9999)
				code = new_code
			. = TRUE
		if("set_relay_code")
			if(locked)
				return
			var/new_code = input("Set relay code (0000-9999):", name, code) as null|num
			if(!isnull(new_code))
				new_code = CLAMP(round(new_code, 1),0,9999)
				relay_code = new_code
			. = TRUE
		if("save")
			if(locked)
				return
			var/code_name = stripped_input(usr, "Set the setting name", "Set Name", null , 15)
			if(!code_name)
				return
			var/new_save = list()
			new_save["id"] = last_id + 1
			last_id++
			new_save["name"] = code_name
			new_save["code"] = code
			new_save["mode"] = mode
			new_save["relay_code"] = relay_code

			saved_settings += list(new_save)
			. = TRUE
		if("load")
			var/code_id = params["save_id"]
			var/list/setting
			for(var/list/X in saved_settings)
				if(X["id"] == text2num(code_id))
					setting = X
					break
			if(setting)
				code = setting["code"]
				mode = setting["mode"]
				relay_code = setting["relay_code"]
			. = TRUE
		if("remove_save")
			if(locked)
				return
			var/code_id = params["save_id"]
			for(var/list/setting in saved_settings)
				if(setting["id"] == text2num(code_id))
					saved_settings -= list(setting)
					break
			. = TRUE
		if("select_mode")
			if(locked)
				return
			mode = params["mode"]
			. = TRUE
		if("lock")
			if(!(obj_flags & EMAGGED))
				locked = TRUE
				update_icon()
			. = TRUE


#undef REMOTE_MODE_OFF
#undef REMOTE_MODE_SELF
#undef REMOTE_MODE_TARGET
#undef REMOTE_MODE_AOE
#undef REMOTE_MODE_RELAY