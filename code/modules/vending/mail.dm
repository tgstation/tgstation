/obj/machinery/mailbox
	name = "mail sorter"
	desc = "A large mail sorting unit. Sorting mail since 1987!"
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "engi"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	max_integrity = 400
	integrity_failure = 0.33
	light_power = 0.5
	light_range = MINIMUM_USEFUL_LIGHT_RANGE

	/// List of all mail that's inside the mailbox.
	var/list/mail_list = list()
	/// List of the departments to sort the mail for.
	var/list/sorting_departments = list(
		"Engineering" =  DEPARTMENT_ENGINEERING,
		"Security" =     DEPARTMENT_SECURITY,
		"Medical" =      DEPARTMENT_MEDICAL,
		"Science" =      DEPARTMENT_SCIENCE,
		"Supply" =       DEPARTMENT_CARGO,
		"Service" =      DEPARTMENT_SERVICE,
		"Command" =      DEPARTMENT_COMMAND
		)

	req_access = list(ACCESS_CARGO)

/obj/machinery/mailbox/proc/accept_check(obj/item/weapon)
	var/static/list/accepted_items = list(
		/obj/item/mail,
		/obj/item/mail/envelope,
		/obj/item/mail/junkmail,
		/obj/item/mail/mail_strike,
		/obj/item/mail/traitor,
		/obj/item/paper
	)
	return is_type_in_list(weapon, accepted_items)

/obj/machinery/mailbox/Destroy()
	drop_all_mail()
	. = ..()

/obj/machinery/mailbox/interact(mob/user)
	if (!allowed(user))
		to_chat(user, span_warning("Access denied."))
		return FALSE

	var/list/choices = list()
	if (length(mail_list) > 0)
		choices["eject_one"] = icon('icons/hud/radial.dmi', "radial_eject")
		choices["eject_all"] = icon('icons/hud/radial.dmi', "radial_drop")
		choices["sort"] = icon('icons/hud/radial.dmi', "radial_shuffle")
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
		if ("eject_one")
			pick_mail(usr)
		if ("eject_all")
			playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
			to_chat(usr, span_notice("[src] dumps [length(mail_list)] envelope\s on the floor."))
			drop_all_mail()
		if ("sort")
			sort_mail(usr)

/obj/machinery/mailbox/proc/sort_mail(usr)
	var/list/sorted_mail = list()
	var/sorted = 0
	var/unable_to_sort = 0
	var/sorting_dept = input(usr, "Choose the department to sort mail for","Mail Sorting", sorting_departments[1]) as null|anything in sorting_departments
	if(!sorting_dept)
		return
	for (var/obj/item/mail/M in mail_list)
		if (!M.recipient_ref)
			unable_to_sort ++
			continue
		var/datum/mind/L = M.recipient_ref.resolve()
		if (L)
			var/datum/job/J = L.assigned_role
			var/department = J.departments_list?[1]?.department_name
			if (department == sorting_dept)
				sorted_mail.Add(M)
				sorted ++
		else
			unable_to_sort ++
	if (length(sorted_mail) == 0)
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
		say("No mail for the following department: [sorting_dept].")
		sleep(10)
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
		say("Couldn't sort [unable_to_sort] envelope\s.")
		return

	say("[sorted] envelope\s sorted successfully.")
	playsound(src, 'sound/machines/ping.ogg', 20, TRUE)
	for (var/obj/item/mail/mail_in_list in sorted_mail)
		mail_in_list.forceMove(get_turf(src))
		sorted_mail -= mail_in_list
		mail_list -= mail_in_list
	to_chat(usr, span_notice("[src] reluctantly spits out [length(sorted_mail)] envelope\s."))
	sleep(10)
	playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
	say("Couldn't sort [unable_to_sort] envelope\s.")


/obj/machinery/mailbox/examine(mob/user)
	. = ..()
	. += span_notice("There [length(mail_list) >= 2 ? "are" : "is"] <b>[length(mail_list) ? length(mail_list) : "no"]</b> [length(mail_list) == 1 ? "envelope" : "envelopes"] inside.")

/obj/machinery/mailbox/attackby(obj/item/I, /mob/user, params)
	var/mob/user = usr

	if (istype(I, /obj/item/storage/bag/mail))
		if (length(I) < 1)
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
	else
		sort_mail(usr)
	. = ..()

/obj/machinery/mailbox/proc/drop_all_mail(damage_flag)
	if(!isturf(get_turf(src)))
		for(var/obj/item/mail in mail_list)
			qdel(mail)
		return
	var/turf/dropturf = get_turf(src)
	for(var/obj/item/mail in mail_list)
		mail.forceMove(dropturf)
		mail_list -= mail

/obj/machinery/mailbox/proc/pick_mail(usr)
	if(!length(mail_list))
		return
	var/mail_throw = input(usr, "Choose the envelope to eject","Mail Sorting", mail_list) as null|anything in mail_list
	if(!mail_throw)
		return
	// throw_item.throw_at(target, 16, 3)

/obj/machinery/mailbox/proc/load(obj/item/weapon, mob/user)
	if(ismob(weapon.loc))
		var/mob/owner = weapon.loc
		if(!owner.transferItemToLoc(weapon, src))
			to_chat(owner, span_warning("\the [weapon] is stuck to your hand, you cannot put it in \the [src]!"))
			return FALSE
		return TRUE
	else
		if(weapon.loc.atom_storage)
			return weapon.loc.atom_storage.attempt_remove(weapon, src, silent = TRUE)
		else
			weapon.forceMove(src)
			return TRUE

// /obj/machinery/mailmat/update_appearance(updates=ALL)
// 	. = ..()
// 	if(machine_stat & BROKEN)
// 		set_light(0)
// 		return
// 	set_light(powered() ? MINIMUM_USEFUL_LIGHT_RANGE : 0)

// /obj/machinery/mailmat/update_icon_state()
// 	if(machine_stat & BROKEN)
// 		icon_state = "[initial(icon_state)]-broken"
// 		return ..()
// 	icon_state = "[initial(icon_state)][powered() ? null : "-off"]"
// 	return ..()

// /obj/machinery/mailmat/obj_break(damage_flag)
// 	. = ..()
// 	if(!.)
// 		return
// 	drop_all_mails()
