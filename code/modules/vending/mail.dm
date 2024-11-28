/obj/machinery/mailsorter
	name = "mail sorter"
	desc = "A large mail sorting unit. Sorting mail since 1987!"
	icon = 'icons/obj/machines/mailsorter.dmi'
	icon_state = "mailsorter"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	max_integrity = 300
	integrity_failure = 0.33
	var/light_mask = "mailsorter-light-mask"
	var/panel_type = "panel"

	circuit = /obj/item/circuitboard/machine/mailsorter

	/// Bool that returns if the machine is already sorting mail.
	var/now_sorting = FALSE
	/// What the machine is currently doing. Can be "sorting", "idle", "yes", "no".
	var/currentstate = "idle"
	/// List of all mail that's inside the mailbox.
	var/list/mail_list = list()
	/// The direction in which the mail will be unloaded.
	var/output_dir = SOUTH
	/// The turf to unload mail at.
	var/turf/unload_turf = null
	/// List of the departments to sort the mail for.
	var/list/datum/sorting_departments = list(
		DEPARTMENT_ENGINEERING,
		DEPARTMENT_SECURITY,
		DEPARTMENT_MEDICAL,
		DEPARTMENT_SCIENCE,
		DEPARTMENT_CARGO,
		DEPARTMENT_SERVICE,
		DEPARTMENT_COMMAND
		)

	req_access = list(ACCESS_CARGO)

/obj/machinery/mailsorter/screwdriver_act(mob/living/user, obj/item/tool)
	default_deconstruction_screwdriver(user, "mailsorter-off", "mailsorter", tool)
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/mailsorter/crowbar_act(mob/living/user, obj/item/tool)
	default_deconstruction_crowbar(tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/mailsorter/Initialize(mapload)
	. = ..()
	unload_turf = get_step(src, output_dir)

/obj/machinery/mailsorter/examine(mob/user)
	. = ..()
	. += span_notice("There [length(mail_list) >= 2 ? "are" : "is"] <b>[length(mail_list) ? length(mail_list) : "no"]</b> [length(mail_list) == 1 ? "envelope" : "envelopes"] inside.")
	if(panel_open)
		. += span_notice("Alt-click to rotate the output direction.")

// /obj/machinery/mailsorter/obj_break(damage_flag)
// 	. = ..()
// 	if(!.)
// 		return
// 	drop_all_mail()

/obj/machinery/mailsorter/Destroy()
	drop_all_mail()
	. = ..()

/obj/machinery/mailsorter/proc/drop_all_mail(damage_flag)
	if(!isturf(get_turf(src)))
		for(var/obj/item/mail in mail_list)
			qdel(mail)
		return
	var/turf/dropturf = unload_turf
	for(var/obj/item/mail in mail_list)
		mail.forceMove(dropturf)
		mail_list -= mail

/obj/machinery/mailsorter/proc/dump_all_mail(damage_flag)
	if(!isturf(get_turf(src)))
		for(var/obj/item/mail in mail_list)
			qdel(mail)
		return
	var/turf/dropturf = unload_turf
	for(var/obj/item/mail in mail_list)
		mail.forceMove(dropturf)
		mail.throw_at(unload_turf, 2, 3)
		mail_list -= mail

/obj/machinery/mailsorter/proc/accept_check(obj/item/weapon)
	var/static/list/accepted_items = list(
		/obj/item/mail,
		/obj/item/mail/envelope,
		/obj/item/mail/junkmail,
		/obj/item/mail/mail_strike,
		/obj/item/mail/traitor,
		/obj/item/paper
	)
	return is_type_in_list(weapon, accepted_items)

/obj/machinery/mailsorter/proc/sort_delay()
	playsound(src, 'sound/machines/mail/mail_sort1.ogg', 20, TRUE)
	sleep(50)
	return TRUE

/obj/machinery/mailsorter/interact(mob/user)
	if (!allowed(user))
		to_chat(user, span_warning("Access denied."))
		return
	if (currentstate != "idle" && powered())
		return
	var/list/choices = list()
	if (length(mail_list) > 0)
		choices["Eject"] = icon('icons/hud/radial.dmi', "radial_eject")
		choices["Dump"] = icon('icons/hud/radial.dmi', "mail_dump")
		choices["Sort"] = icon('icons/hud/radial.dmi', "mail_sort")

	var/choice = show_radial_menu(
		user,
		src,
		choices,
		require_near = !HAS_SILICON_ACCESS(user),
		autopick_single_option = FALSE
	)

	if (!choice)
		return
	switch (choice)
		if ("Eject")
			pick_mail(usr)
		if ("Dump")
			playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
			to_chat(usr, span_notice("[src] dumps [length(mail_list)] envelope\s on the floor."))
			dump_all_mail()
		if ("Sort")
			sort_mail(usr)

/obj/machinery/mailsorter/proc/sort_mail(usr)
	var/list/sorted_mail = list()
	var/sorted = 0
	var/unable_to_sort = 0
	var/sorting_dept = tgui_input_list(usr, "Choose the department to sort mail for","Mail Sorting", sorting_departments)
	if (!sorting_dept)
		return
	currentstate = "sorting"
	update_appearance()
	if (!sort_delay())
		return
	for (var/obj/item/mail/M in mail_list)
		if (!M.recipient_ref)
			unable_to_sort ++
			continue
		var/datum/mind/L = M.recipient_ref.resolve()
		if (L)
			var/datum/job/J = L.assigned_role
			var/departmentname = J.departments_list?[1]?.department_name
			if (departmentname == sorting_dept)
				sorted_mail.Add(M)
				sorted ++
		else
			unable_to_sort ++
	if (length(sorted_mail) == 0)
		currentstate = "no"
		update_appearance()
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
		say("No mail for the following department: [sorting_dept].")
	else
		currentstate = "yes"
		update_appearance()
		say("[sorted] envelope\s sorted successfully.")
		playsound(src, 'sound/machines/ping.ogg', 20, TRUE)
		to_chat(usr, span_notice("[src] ejects [length(sorted_mail)] envelope\s."))
		for (var/obj/item/mail/mail_in_list in sorted_mail)
			mail_in_list.forceMove(unload_turf)
			sorted_mail -= mail_in_list
			mail_list -= mail_in_list
	sleep(10)
	playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
	say("Couldn't sort [unable_to_sort] envelope\s.")
	sleep(10)
	currentstate = "idle"
	update_appearance()

/obj/machinery/mailsorter/attackby(obj/item/I, /mob/user, params)
	var/mob/user = usr

	if (istype(I, /obj/item/storage/bag/mail))
		if (length(I.contents) < 1)
			to_chat(user, span_warning("The [I] is empty!"))
			return
		var/loaded = 0
		for (var/obj/item/mail in I.contents)
			if (!(mail.item_flags & ABSTRACT) && \
				!(mail.flags_1 & HOLOGRAM_1) && \
				accept_check(mail) \
			)
				load(mail, usr)
				loaded++

		if(loaded)
			user.visible_message(span_notice("[user] loads \the [src] with \the [I]."), \
			span_notice("You load \the [src] with \the [I]."))
			if(length(I.contents))
				to_chat(user, span_warning("Some items are refused."))
			return TRUE
		else
			to_chat(user, span_warning("There is nothing in \the [I] to put in the [src]!"))
			return FALSE
	else if (istype(I, /obj/item/mail))
		I.forceMove(src)
		mail_list += I
		to_chat(user, span_notice("The [src] whizzles as it accepts the [I]."))
	. = ..()

/obj/machinery/mailsorter/proc/pick_mail(usr)
	if(!length(mail_list))
		return
	var/obj/item/mail/mail_throw = tgui_input_list(usr, "Choose the envelope to eject","Mail Sorting", mail_list)
	if(!mail_throw)
		return
	currentstate = "sorting"
	update_appearance()
	if (!sort_delay())
		return
	to_chat(usr, span_notice("[src] reluctantly spits out [mail_throw]."))
	mail_throw.forceMove(unload_turf)
	mail_throw.throw_at(unload_turf, 2, 3)
	mail_list -= mail_throw
	currentstate = "idle"
	update_appearance()

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
	unload_turf = get_step(src, output_dir)
	update_appearance(UPDATE_OVERLAYS)
	return CLICK_ACTION_SUCCESS


/obj/machinery/mailsorter/update_overlays()
	. = ..()
	if((machine_stat & NOPOWER))
		return
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

	mail_output.color = COLOR_MODERATE_BLUE
	var/mutable_appearance/light_out = emissive_appearance(mail_output.icon, mail_output.icon_state, offset_spokesman = src, alpha = mail_output.alpha)
	light_out.pixel_y = mail_output.pixel_y
	light_out.pixel_x = mail_output.pixel_x
	. += mail_output
	. += light_out

	var/init_icon = initial(icon)
	if(!init_icon)
		return

	if(!(machine_stat & BROKEN) && powered())
		. += mutable_appearance(init_icon, currentstate)
	if(panel_open)
		. += panel_type
	if(light_mask && !(machine_stat & BROKEN) && powered())
		. += emissive_appearance(icon, light_mask, src)

/obj/machinery/mailsorter/update_icon_state()
	icon_state = "[initial(icon_state)][powered() ? null : "-off"]"
	if(machine_stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	return ..()

