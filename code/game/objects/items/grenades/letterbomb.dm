/obj/item/mail/explosive/attack_self(mob/user, modifiers)
	var/mail_type = tgui_alert(user, "Make it look like an envelope or like normal mail?", "Mail Counterfeiting", list("Mail", "Envelope"))
	if(isnull(mail_type))
		return FALSE
	if(loc != user)
		return FALSE
	mail_type = lowertext(mail_type)

	var/list/mail_recipients = list("Anyone")
	var/list/mail_recipients_for_input = list("Anyone")
	var/list/used_names = list()
	for(var/datum/record/locked/person in sort_record(GLOB.manifest.locked))
		var/datum/mind/locked_mind = person.mind_ref.resolve()
		if(isnull(locked_mind))
			continue
		mail_recipients += locked_mind
		mail_recipients_for_input += avoid_assoc_duplicate_keys(person.name, used_names)

	var/recipient = tgui_input_list(user, "Choose a recipient", "Mail Counterfeiting", mail_recipients_for_input)
	if(isnull(recipient))
		return FALSE
	if(!(src in user.contents))
		return FALSE

	var/index = mail_recipients_for_input.Find(recipient)

	var/obj/item/mail/primedexplosive/explosiveletter
	if(mail_type == "mail")
		explosiveletter = new /obj/item/mail/primedexplosive
	else
		explosiveletter = new /obj/item/mail/primedexplosive/envelope

	if(index == 1)
		var/mail_name = tgui_input_text(user, "Enter mail title, or leave it blank", "Mail Counterfeiting")
		if(!(src in user.contents))
			return FALSE
		if(reject_bad_text(mail_name, ascii_only = FALSE))
			explosiveletter.name = mail_name
		else
			explosiveletter.name = mail_type
	else
		explosiveletter.initialize_for_recipient(mail_recipients[index])

	user.temporarilyRemoveItemFromInventory(src, force = TRUE)
	user.put_in_hands(explosiveletter)
	qdel(src)

/obj/item/mail/primedexplosive/after_unwrap(mob/user)
	user.temporarilyRemoveItemFromInventory(src, force = TRUE)
	for(var/obj/stuff as anything in contents) // Mail and envelope actually can have more than 1 item.
		if(isitem(stuff))
			user.put_in_hands(stuff)
		else
			stuff.forceMove(drop_location())
	playsound(loc, 'sound/items/poster_ripped.ogg', vol = 50, vary = TRUE)
	explosion(loc,0,1,2, flame_range = 3)
	qdel(src)
	return TRUE

/obj/item/mail/primedexplosive/envelope
	name = "envelope"
	icon_state = "mail_large"
