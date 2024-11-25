/obj/machinery/mailbox
	name = "mail sorter"
	desc = "A large mail sorting unit. Sorting mail since 1987!"
	icon = 'icons/obj/vending.dmi'
	icon_state = "mail"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	max_integrity = 400
	integrity_failure = 0.33
	armor = list(MELEE = 20, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 70)
	light_power = 0.5
	light_range = MINIMUM_USEFUL_LIGHT_RANGE

	/// List of all mail that's inside the mailbox.
	var/list/mail_list = list()

	req_access = list(ACCESS_COMMAND)

/obj/machinery/mailbox/Destroy()
	drop_all_mail()
	. = ..()

/obj/machinery/mailbox/proc/get_mail(usr)
	var/list/mail_to_get = list()
	for (var/obj/item/mail/M in mail_list)
		if(M.recipient_ref)
			mail_to_get.Add(M)

	if (length(mail_to_get) == 0)
		to_chat(user, span_notice("The [src] chimes, indicating there is no mail for you."))
		return

	to_chat(user, span_notice("The [src] reluctantly spits out [length(mail_to_get)] envelope\s."))
	for (var/mail_in_list in mail_to_get)
		mail_in_list.forceMove(get_turf(src))

/obj/machinery/mailbox/examine(mob/user)
	. = ..()
	. += span_notice("There [length(mail_list) >= 2 ? "are" : "is"] <b>[length(mail_list) ? length(mail_list) : "no"]</b> [length(mail_list) >= 2 ? "envelopes" : "envelope"] inside.")

/obj/machinery/mailbox/attackby(obj/item/I, /mob/user, params)
	var/mob/user = usr

	if (istype(I, /obj/item/storage/bag/mail))
		var/obj/item/storage/bag/mail/mailbag = I
		var/datum/component/storage/STR = mailbag.GetComponent(/datum/component/storage)
		if (I.contents.len)
			to_chat(user, span_notice("You start loading the mail into the [src]..."))
			if (!do_after(user, 2 SECONDS, src))
				return
			for (var/obj/item/mail/M in mailbag.contents)
				STR.remove_from_storage(M, src)
				mails += M
			mailbag.do_squish()
			return
		else
			to_chat(user, span_warning("The [mailbag] is empty!"))
			return
	else if (istype(I, /obj/item/mail))
		I.forceMove(src)
		mails += I
		to_chat(user, span_notice("The [src] whizzles as it accepts the [I]."))
	else if (!isnull((id = weapon.GetID())))
		if (!allowed(usr))
			to_chat(usr, span_warning("Access denied."))
			return FALSE

			var/list/choices = list()
			if (length(mail_list) > 0)
				choices["eject_one"] = icon('icons/hud/radial.dmi', "radial_eject")
				choices["eject_all"] = icon('icons/hud/radial.dmi', "radial_drop")
			var/choice = show_radial_menu(
				usr,
				src,
				choices,
				custom_check = CALLBACK(src, PROC_REF(check_interactable), usr),
				require_near = !HAS_SILICON_ACCESS(usr),
				autopick_single_option = FALSE
			)

			if (!choice)
				return
			switch (choice)
				if ("eject_one")
					pick_mail()
				if ("eject_all")
					drop_all_mail()
	. = ..()

/obj/machinery/mailbox/proc/drop_all_mail(damage_flag)
	if(!isturf(get_turf(src)))
		for(var/obj/item/mail in mail_list)
			qdel(mail)
		return
	var/turf/dropturf = get_turf(src)
	for(var/obj/item/mail in mail_list)
		mail.forceMove(dropturf)

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
