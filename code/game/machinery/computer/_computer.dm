/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = TRUE
	max_integrity = 200
	integrity_failure = 0.5
	armor_type = /datum/armor/machinery_computer
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_SET_MACHINE|INTERACT_MACHINE_REQUIRES_LITERACY
	/// How bright we are when turned on.
	var/brightness_on = 1
	/// Icon_state of the keyboard overlay.
	var/icon_keyboard = "generic_key"
	/// Should we render an unique icon for the keyboard when off?
	var/keyboard_change_icon = TRUE
	/// Icon_state of the emissive screen overlay.
	var/icon_screen = "generic"
	/// Time it takes to deconstruct with a screwdriver.
	var/time_to_unscrew = 2 SECONDS
	/// Are we authenticated to use this? Used by things like comms console, security and medical data, and apc controller.
	var/authenticated = FALSE
	/// The character preview view for the UI.
	var/atom/movable/screen/map_view/char_preview/character_preview_view

/datum/armor/machinery_computer
	fire = 40
	acid = 20

/obj/machinery/computer/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()

	power_change()

/obj/machinery/computer/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE
	return TRUE

/obj/machinery/computer/update_overlays()
	. = ..()
	if(icon_keyboard)
		if(keyboard_change_icon && (machine_stat & NOPOWER))
			. += "[icon_keyboard]_off"
		else
			. += icon_keyboard

	if(machine_stat & BROKEN)
		. += mutable_appearance(icon, "[icon_state]_broken")
		return // If we don't do this broken computers glow in the dark.

	if(machine_stat & NOPOWER) // Your screen can't be on if you've got no damn charge
		return

	// This lets screens ignore lighting and be visible even in the darkest room
	if(icon_screen)
		. += mutable_appearance(icon, icon_screen)
		. += emissive_appearance(icon, icon_screen, src)

/obj/machinery/computer/power_change()
	. = ..()
	if(machine_stat & NOPOWER)
		set_light(0)
	else
		set_light(brightness_on)

/obj/machinery/computer/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(circuit && !(flags_1&NODECONSTRUCT_1))
		to_chat(user, span_notice("You start to disconnect the monitor..."))
		if(I.use_tool(src, user, time_to_unscrew, volume=50))
			deconstruct(TRUE, user)
	return TRUE

/obj/machinery/computer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
			else
				playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/computer/atom_break(damage_flag)
	if(!circuit) //no circuit, no breaking
		return
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
		set_light(0)

/obj/machinery/computer/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF))
		switch(severity)
			if(1)
				if(prob(50))
					atom_break(ENERGY)
			if(2)
				if(prob(10))
					atom_break(ENERGY)

/obj/machinery/computer/deconstruct(disassembled = TRUE, mob/user)
	on_deconstruction()
	if(!(flags_1 & NODECONSTRUCT_1))
		if(circuit) //no circuit, no computer frame
			var/obj/structure/frame/computer/A = new /obj/structure/frame/computer(src.loc)
			A.setDir(dir)
			A.circuit = circuit
			// Circuit removal code is handled in /obj/machinery/Exited()
			circuit.forceMove(A)
			A.set_anchored(TRUE)
			if(machine_stat & BROKEN)
				if(user)
					to_chat(user, span_notice("The broken glass falls out."))
				else
					playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
				new /obj/item/shard(drop_location())
				new /obj/item/shard(drop_location())
				A.state = 3
				A.icon_state = "3"
			else
				if(user)
					to_chat(user, span_notice("You disconnect the monitor."))
				A.state = 4
				A.icon_state = "4"
		for(var/obj/C in src)
			C.forceMove(loc)
	qdel(src)

/obj/machinery/computer/AltClick(mob/user)
	. = ..()
	if(!can_interact(user))
		return
	if(!user.canUseTopic(src, be_close = !issilicon(user)) || !is_operational)
		return

/obj/machinery/computer/ui_interact(mob/user, datum/tgui/ui)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	update_use_power(ACTIVE_POWER_USE)

/obj/machinery/computer/ui_close(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	update_use_power(IDLE_POWER_USE)

/obj/machinery/computer/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/datum/record/crew/target
	if(params["crew_ref"])
		target = locate(params["crew_ref"]) in GLOB.manifest.general

	switch(action)
		if("edit_field")
			target = locate(params["ref"]) in GLOB.manifest.general
			var/field = params["field"]
			if(!field || !target?.vars[field])
				return FALSE

			var/value = trim(params["value"], MAX_BROADCAST_LEN)
			target.vars[field] = value || "Unknown"

			return TRUE

		if("expunge_record")
			if(!target)
				return FALSE

			expunge_record_info(target)
			balloon_alert(usr, "record expunged")
			playsound(src, 'sound/machines/terminal_eject.ogg', 70, TRUE)

			return TRUE

		if("login")
			authenticated = secure_login(usr)
			return TRUE

		if("logout")
			balloon_alert(usr, "logged out")
			playsound(src, 'sound/machines/terminal_off.ogg', 70, TRUE)
			authenticated = FALSE

			return TRUE

		if("purge_records")
			ui.close()
			balloon_alert(usr, "purging records")
			playsound(src, 'sound/machines/terminal_alert.ogg', 70, TRUE)

			if(do_after(usr, 5 SECONDS))
				for(var/datum/record/crew/entry in GLOB.manifest.general)
					expunge_record_info(entry)

				balloon_alert(usr, "records purged")
				playsound(src, 'sound/machines/terminal_off.ogg', 70, TRUE)

			return TRUE

		if("view_record")
			if(!target)
				return FALSE

			playsound(src, "sound/machines/terminal_button0[rand(1, 8)].ogg", 50, TRUE)
			update_preview(usr, params["assigned_view"], target)
			return TRUE

	return FALSE

/// Creates a character preview view for the UI.
/obj/machinery/computer/proc/create_character_preview_view(mob/user)
	var/assigned_view = "preview_[user.ckey]_[REF(src)]_records"
	if(user.client?.screen_maps[assigned_view])
		return

	var/atom/movable/screen/map_view/char_preview/new_view = new(null, src)
	new_view.generate_view(assigned_view)
	new_view.display_to(user)

/// Takes a record and updates the character preview view to match it.
/obj/machinery/computer/proc/update_preview(mob/user, assigned_view, datum/record/crew/target)
	var/mutable_appearance/preview = new(target.character_appearance)
	preview.underlays += mutable_appearance('icons/effects/effects.dmi', "static_base", alpha = 20)
	preview.add_overlay(mutable_appearance(generate_icon_alpha_mask('icons/effects/effects.dmi', "scanline"), alpha = 20))

	var/atom/movable/screen/map_view/char_preview/old_view = user.client?.screen_maps[assigned_view]?[1]
	if(!old_view)
		return

	old_view.appearance = preview.appearance

/// Expunges info from a record.
/obj/machinery/computer/proc/expunge_record_info(datum/record/crew/target)
	return

/// Detects whether a user can use buttons on the machine
/obj/machinery/computer/proc/has_auth(mob/user)
	if(!isliving(user))
		return FALSE
	var/mob/living/player = user

	if(issilicon(player)) // Silicons don't need to authenticate
		return TRUE

	var/obj/item/card/auth = player.get_idcard(TRUE)
	if(!auth)
		return FALSE
	var/list/access = auth.GetAccess()
	if(!check_access_list(access))
		return FALSE

	return TRUE

/// Inserts a new record into GLOB.manifest.general. Requires a photo to be taken.
/obj/machinery/computer/proc/insert_new_record(mob/user, obj/item/photo/mugshot)
	if(!mugshot || !is_operational || !user.canUseTopic(src, be_close = !issilicon(user)))
		return FALSE

	if(!authenticated && !has_auth(user))
		balloon_alert(user, "access denied")
		playsound(src, 'sound/machines/terminal_error.ogg', 70, TRUE)
		return FALSE

	var/trimmed = copytext(mugshot.name, 9, MAX_NAME_LEN) // Remove "photo - "
	var/name = tgui_input_text(user, "Enter the name of the new record.", "New Record", trimmed, MAX_NAME_LEN)
	if(!name || !is_operational || !user.canUseTopic(src, be_close = !issilicon(user)) || !mugshot || QDELETED(mugshot) || QDELETED(src))
		return FALSE

	new /datum/record/crew(name = name, character_appearance = mugshot.picture.picture_image)

	balloon_alert(user, "record created")
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 70, TRUE)

	qdel(mugshot)

	return TRUE

/// Secure login
/obj/machinery/computer/proc/secure_login(mob/user)
	if(!user.canUseTopic(src, be_close = !issilicon(user)) || !is_operational)
		return FALSE

	if(!has_auth(user))
		balloon_alert(user, "access denied")
		playsound(src, 'sound/machines/terminal_error.ogg', 70, TRUE)
		return FALSE

	balloon_alert(user, "logged in")
	playsound(src, 'sound/machines/terminal_on.ogg', 70, TRUE)

	return TRUE


