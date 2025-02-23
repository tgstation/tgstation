#define STATE_SORTING "sorting"
#define STATE_IDLE "idle"
#define STATE_YES "yes"
#define STATE_NO "no"
#define MAIL_CAPACITY 100

/obj/machinery/mailsorter
	name = "mail sorter"
	desc = "A large mail sorting unit. Sorting mail since 1987!"
	icon = 'icons/obj/machines/mailsorter.dmi'
	icon_state = "mailsorter"
	base_icon_state = "mailsorter"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	max_integrity = 300
	integrity_failure = 0.33
	req_access = list(ACCESS_CARGO)
	circuit = /obj/item/circuitboard/machine/mailsorter

	var/light_mask = "mailsorter-light-mask"
	var/panel_type = "panel"

	/// What the machine is currently doing. Can be "sorting", "idle", "yes", "no".
	var/currentstate = STATE_IDLE
	/// List of all mail that's inside the mailbox.
	var/list/mail_list = list()
	/// The direction in which the mail will be unloaded.
	var/output_dir = SOUTH
	/// List of the departments to sort the mail for.
	var/static/list/sorting_departments = list(
		DEPARTMENT_ENGINEERING,
		DEPARTMENT_SECURITY,
		DEPARTMENT_MEDICAL,
		DEPARTMENT_SCIENCE,
		DEPARTMENT_CARGO,
		DEPARTMENT_SERVICE,
		DEPARTMENT_COMMAND,
	)
	var/static/list/choices = list(
		"Eject" = icon('icons/hud/radial.dmi', "radial_eject"),
		"Dump" = icon('icons/hud/radial.dmi', "mail_dump"),
		"Sort" = icon('icons/hud/radial.dmi', "mail_sort"),
	)

/// Steps one tile in the `output_dir`. Returns `turf`.
/obj/machinery/mailsorter/proc/get_unload_turf()
	return get_step(src, output_dir)

/// Opening the maintenance panel.
/obj/machinery/mailsorter/screwdriver_act(mob/living/user, obj/item/tool)
	default_deconstruction_screwdriver(user, "[base_icon_state]-off", base_icon_state, tool)
	update_appearance(UPDATE_OVERLAYS)
	return ITEM_INTERACT_SUCCESS

/// Deconstructing the mail sorter.
/obj/machinery/mailsorter/crowbar_act(mob/living/user, obj/item/tool)
	default_deconstruction_crowbar(tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/mailsorter/examine(mob/user)
	. = ..()
	. += span_notice("There is[length(mail_list) < 100 ? " " : " no more "]space for <b>[length(mail_list) < 100 ? "[100 - length(mail_list)] " : ""]</b>envelope\s inside.")
	. += span_notice("There [length(mail_list) >= 2 ? "are" : "is"] <b>[length(mail_list) ? length(mail_list) : "no"]</b> envelope\s inside.")
	if(panel_open)
		. += span_notice("Alt-click to rotate the output direction.")

/obj/machinery/mailsorter/Destroy()
	QDEL_LIST(mail_list)
	. = ..()

/obj/machinery/mailsorter/on_deconstruction(disassembled)
	drop_all_mail()
	. = ..()

/// Drops all enevlopes on the machine turf.
/obj/machinery/mailsorter/proc/drop_all_mail()
	if(!isturf(get_turf(src)))
		QDEL_LIST(mail_list)
		return
	for(var/obj/item/mail in mail_list)
		mail.forceMove(src)
		mail_list -= mail

/// Dumps all envelopes on the `unload_turf`.
/obj/machinery/mailsorter/proc/dump_all_mail()
	if(!isturf(get_turf(src)))
		QDEL_LIST(mail_list)
		return
	var/turf/unload_turf = get_unload_turf()
	for(var/obj/item/mail in mail_list)
		mail.forceMove(unload_turf)
		mail.throw_at(unload_turf, 2, 3)
		mail_list -= mail

/// Validates whether the inserted item is acceptable.
/obj/machinery/mailsorter/proc/accept_check(obj/item/weapon)
	var/static/list/accepted_items = list(
		/obj/item/mail,
		/obj/item/paper,
	)
	return is_type_in_list(weapon, accepted_items)

/obj/machinery/mailsorter/interact(mob/user)
	if (!allowed(user))
		to_chat(user, span_warning("Access denied."))
		return
	if (currentstate != STATE_IDLE)
		return
	if (length(mail_list) == 0)
		to_chat(user, span_warning("There's no mail inside!"))
		return
	var/choice = show_radial_menu(
		user,
		src,
		choices,
		require_near = !HAS_SILICON_ACCESS(user),
		autopick_single_option = FALSE,
	)
	if (!choice)
		return
	switch (choice)
		if ("Eject")
			pick_mail(user)
		if ("Dump")
			playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
			to_chat(user, span_notice("[src] dumps [length(mail_list)] envelope\s on the floor."))
			dump_all_mail()
		if ("Sort")
			sort_mail(user)

/// Prompts the player to select a department to sort the mail for. Returns if `null`.
/obj/machinery/mailsorter/proc/sort_mail(mob/user)
	var/sorting_dept = tgui_input_list(user, "Choose the department to sort mail for","Mail Sorting", sorting_departments)
	if (!sorting_dept)
		return
	currentstate = STATE_SORTING
	update_appearance(UPDATE_OVERLAYS)
	playsound(src, 'sound/machines/mail_sort.ogg', 20, TRUE)
	addtimer(CALLBACK(src, PROC_REF(continue_sort), user, sorting_dept), 5 SECONDS)

/// Sorts the mail based on the picked department. Ejects the sorted envelopes onto the `unload_turf`.
/obj/machinery/mailsorter/proc/continue_sort(mob/user, sorting_dept)
	var/list/sorted_mail = list()
	var/total_to_sort = length(mail_list)
	var/sorted = 0
	var/unable_to_sort = 0

	for (var/obj/item/mail/some_mail in mail_list)
		if (!some_mail.recipient_ref)
			unable_to_sort ++
			continue
		var/datum/mind/some_recipient = some_mail.recipient_ref.resolve()
		if (some_recipient)
			var/datum/job/recipient_job = some_recipient.assigned_role
			var/datum/job_department/primary_department = recipient_job.departments_list?[1]
			if (primary_department == null)	// permabrig is temporary, tide is forever
				unable_to_sort ++
			else
				var/datum/job_department/main_department = primary_department.department_name
				if (main_department == sorting_dept)
					sorted_mail.Add(some_mail)
					sorted ++
		else
			unable_to_sort ++
	if (length(sorted_mail) == 0)
		currentstate = STATE_NO
		update_appearance(UPDATE_OVERLAYS)
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
		say("No mail for the following department: [sorting_dept].")
	else
		currentstate = STATE_YES
		update_appearance(UPDATE_OVERLAYS)
		say("[sorted] envelope\s sorted successfully.")
		playsound(src, 'sound/machines/ping.ogg', 20, TRUE)
		to_chat(user, span_notice("[src] ejects [length(sorted_mail)] envelope\s."))
		var/turf/unload_turf = get_unload_turf()
		for (var/obj/item/mail/mail_in_list in sorted_mail)
			mail_in_list.forceMove(unload_turf)
			sorted_mail -= mail_in_list
			mail_list -= mail_in_list
	addtimer(CALLBACK(src, PROC_REF(check_sorted), unable_to_sort, total_to_sort), 1 SECONDS)

/// Informs the player of the amount of processed envelopes.
/obj/machinery/mailsorter/proc/check_sorted(mob/user, unable_to_sort, total_to_sort)
	if (unable_to_sort > 0)
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
		say("Couldn't sort [unable_to_sort] envelope\s.")
	else
		playsound(src, 'sound/machines/ping.ogg', 20, TRUE)
		say("[total_to_sort] envelope\s processed.")
	addtimer(CALLBACK(src, PROC_REF(update_state_after_sorting)), 1 SECONDS)

/obj/machinery/mailsorter/proc/update_state_after_sorting()
	currentstate = STATE_IDLE
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/mailsorter/item_interaction(mob/user, obj/item/thingy, params)
	if (istype(thingy, /obj/item/storage/bag/mail))
		if (length(thingy.contents) < 1)
			to_chat(user, span_warning("The [thingy] is empty!"))
			return
		var/loaded = 0
		for (var/obj/item/mail in thingy.contents)
			if (!(mail.item_flags & ABSTRACT) && \
				!(mail.flags_1 & HOLOGRAM_1) && \
				accept_check(mail) \
			)
				if (length(mail_list) + 1 > MAIL_CAPACITY )
					to_chat(user, span_warning("There is no space for more mail in [src]!"))
					return FALSE
				else if (load(mail, user))
					loaded++
					mail_list += mail
		if(loaded)
			user.visible_message(span_notice("[user] loads \the [src] with \the [thingy]."), \
			span_notice("You load \the [src] with \the [thingy]."))
			if(length(thingy.contents))
				to_chat(user, span_warning("Some items are refused."))
			return TRUE
		else
			to_chat(user, span_warning("There is nothing in \the [thingy] to put in the [src]!"))
			return FALSE
	else if (istype(thingy, /obj/item/mail))
		if (length(mail_list) + 1 > MAIL_CAPACITY )
			to_chat(user, span_warning("There is no space for more mail in [src]!"))
		else
			thingy.forceMove(src)
			mail_list += thingy
			to_chat(user, span_notice("The [src] whizzles as it accepts the [thingy]."))

/// Prompts the user to select an anvelope from the list of all the envelopes inside.
/obj/machinery/mailsorter/proc/pick_mail(mob/user)
	if(!length(mail_list))
		return
	var/obj/item/mail/mail_throw = tgui_input_list(user, "Choose the envelope to eject","Mail Sorting", mail_list)
	if(!mail_throw)
		return
	currentstate = STATE_SORTING
	update_appearance(UPDATE_OVERLAYS)
	playsound(src, 'sound/machines/mail_sort.ogg', 20, TRUE)
	addtimer(CALLBACK(src, PROC_REF(pick_envelope), user, mail_throw), 50)

/// Ejects a single envelope the player has picked onto the `unload_turf`.
/obj/machinery/mailsorter/proc/pick_envelope(mob/user, obj/item/mail/mail_throw)
	to_chat(user, span_notice("[src] reluctantly spits out [mail_throw]."))
	var/turf/unload_turf = get_unload_turf()
	mail_throw.forceMove(unload_turf)
	mail_throw.throw_at(unload_turf, 2, 3)
	mail_list -= mail_throw
	currentstate = STATE_IDLE
	update_appearance(UPDATE_OVERLAYS)

/// Tries to load something into the machine.
/obj/machinery/mailsorter/proc/load(obj/item/thingy, mob/user)
	if(ismob(thingy.loc))
		var/mob/owner = thingy.loc
		if(!owner.transferItemToLoc(thingy, src))
			to_chat(owner, span_warning("\the [thingy] is stuck to your hand, you cannot put it in \the [src]!"))
			return FALSE
		return TRUE
	else
		if(thingy.loc.atom_storage)
			return thingy.loc.atom_storage.attempt_remove(thingy, src, silent = TRUE)
		else
			thingy.forceMove(src)
			return TRUE

/obj/machinery/mailsorter/click_alt(mob/living/user)
	if(!panel_open)
		return CLICK_ACTION_BLOCKING
	output_dir = turn(output_dir, -90)
	to_chat(user, span_notice("You change [src]'s I/O settings, setting the output to [dir2text(output_dir)]."))
	update_appearance(UPDATE_OVERLAYS)
	return CLICK_ACTION_SUCCESS


/obj/machinery/mailsorter/update_overlays()
	. = ..()
	if(!powered())
		return
	if(!(machine_stat & BROKEN))
		var/image/mail_output = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_[output_dir]")
		switch(output_dir)
			if(NORTH)
				mail_output.pixel_y = 32
			if(SOUTH)
				mail_output.pixel_y = -32
			if(EAST)
				mail_output.pixel_x = 32
			if(WEST)
				mail_output.pixel_x = -32
		mail_output.color = COLOR_CRAYON_ORANGE
		var/mutable_appearance/light_out = emissive_appearance(mail_output.icon, mail_output.icon_state, offset_spokesman = src, alpha = mail_output.alpha)
		light_out.pixel_y = mail_output.pixel_y
		light_out.pixel_x = mail_output.pixel_x
		. += mail_output
		. += light_out
		. += mutable_appearance(base_icon_state, currentstate)
	if(panel_open)
		. += panel_type
	if(light_mask && !(machine_stat & BROKEN))
		. += emissive_appearance(icon, light_mask, src)

/obj/machinery/mailsorter/update_icon_state()
	icon_state = "[base_icon_state][powered() ? null : "-off"]"
	if(machine_stat & BROKEN)
		icon_state = "[base_icon_state]-broken"
	return ..()

#undef STATE_SORTING
#undef STATE_IDLE
#undef STATE_YES
#undef STATE_NO
#undef MAIL_CAPACITY
