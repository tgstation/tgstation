/**
 * HERMES (Ratwood code/modules/roguetown/roguemachine/mail.dm): the realm's hydropneumatic post. A coin buys parchment (a zenny)
 * or a quill (a ziliqua); a written page put in is sent, free, to another HERMES by its number (#N) or to a person by name. A
 * letter to a person waits in the MASTER OF MAILS until its addressee takes it from any HERMES with an empty hand. An empty hand
 * also takes a care package or the Guild's daily delivery (parcels.dm); a mercenary posts a signed writ of commendation here;
 * an adherent of the Inquisition loads Otavan marques and opens the MARQUETTE (marquette.dm). Ratwood's inquisition slips,
 * confessions and black mirrors that earn marques, and the daily bomb of the explosive supply, are not ported.
 */
/obj/structure/roguemachine/mail
	/// Number of the box in the directory (Ratwood ournum).
	var/box_number

/// Every HERMES box in order of its number (Ratwood SSroguemachine.hermailers).
GLOBAL_LIST_EMPTY(rogue_mailboxes)
/// The MASTER OF MAILS that keeps letters to persons (Ratwood SSroguemachine.hermailermaster).
GLOBAL_DATUM(rogue_mail_master, /obj/item/roguemachine/mastermail)

/obj/item/paper
	/// Who the letter is from and to, written on the envelope by a HERMES (Ratwood mailer, mailedto).
	var/rogue_mail_from
	var/rogue_mail_to

/obj/structure/roguemachine/mail/Initialize(mapload)
	. = ..()
	GLOB.rogue_mailboxes += src
	box_number = length(GLOB.rogue_mailboxes)
	name = "[initial(name)] #[box_number]"
	update_appearance()

/obj/structure/roguemachine/mail/Destroy()
	GLOB.rogue_mailboxes -= src
	return ..()

/obj/structure/roguemachine/mail/update_overlays()
	. = ..()
	if(marques > 0)
		set_light(1, 1, "#ffffff")
		. += mutable_appearance(icon, "mail-i")
		return
	set_light(1, 1, "#1b7bf1")
	. += mutable_appearance(icon, "mail-f")

/obj/structure/roguemachine/mail/examine(mob/user)
	. = ..()
	. += span_info("Insert a zenny for parchment or a ziliqua for a quill. Put a written page in to send it, free, to a person or to a box by its number (#[box_number] is this one).")
	. += span_info("Touch it with an empty hand to take letters and parcels addressed to you, or to read the directory of boxes.")
	if(HAS_TRAIT(user, TRAIT_INQUISITION))
		. += span_info("The MARQUETTE can be accessed via a secret compartment fitted within the HERMES. Load a Marque to access it.")

/**
 * An empty hand (Ratwood attack_hand()): a care package first, then the next letter addressed to the subject and the Guild's
 * delivery; an adherent of the Inquisition with marques loaded opens the MARQUETTE; with nothing to take, the directory.
 */
/obj/structure/roguemachine/mail/interact(mob/user)
	if(!ishuman(user))
		return TRUE
	var/mob/living/carbon/human/subject = user
	if(retrieve_carebox(subject))
		return TRUE
	var/took = FALSE
	var/obj/item/roguemachine/mastermail/master = GLOB.rogue_mail_master
	var/list/letters = master?.letters_for(subject.real_name)
	if(length(letters))
		var/obj/item/letter = letters[1]
		letter.forceMove(drop_location())
		subject.put_in_hands(letter)
		master.update_appearance()
		playsound(src, ROGUE_SOUND_HISS, 100, FALSE, -1)
		if(length(letters) > 1)
			say("You have additional mail available.")
		took = TRUE
	if(deliver_drugs(subject))
		took = TRUE
	if(HAS_TRAIT(subject, TRAIT_INQUISITION) && marques > 0)
		ui_interact(subject)
		return TRUE
	if(!took)
		show_directory(subject)
	return TRUE

/obj/structure/roguemachine/mail/proc/show_directory(mob/user)
	var/list/lines = list()
	for(var/obj/structure/roguemachine/mail/box as anything in GLOB.rogue_mailboxes)
		lines += "#[box.box_number] [capitalize(get_area_name(box))]"
	var/datum/browser/popup = new(user, "rogue_hermes_directory", "HERMES DIRECTORY", 387, 420, src)
	popup.set_content(jointext(lines, "<br>"))
	popup.open()

/obj/structure/roguemachine/mail/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(istype(tool, /obj/item/merctoken))
		if(ishuman(user))
			post_writ(tool, user)
		return ITEM_INTERACT_SUCCESS
	if(tool.type == rogue_marque_type())
		load_marques(tool, user)
		return ITEM_INTERACT_SUCCESS
	if((istype(tool, /obj/item/roguekey) || istype(tool, /obj/item/storage/keyring)) && HAS_TRAIT(user, TRAIT_INQUISITION))
		if(!rockhill_key_fits(tool, "puritan"))
			to_chat(user, span_warning("Wrong key."))
			return ITEM_INTERACT_BLOCKING
		playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)
		rogue_toggle_puritan_lock(user)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/roguecoin))
		sell_stationery(tool, user)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/paper))
		send_letter(tool, user)
		return ITEM_INTERACT_SUCCESS
	return NONE

/// A zenny buys parchment, a ziliqua a quill (Ratwood: the exact coin value picks the ware).
/obj/structure/roguemachine/mail/proc/sell_stationery(obj/item/roguecoin/coin, mob/living/user)
	var/value = coin.get_real_price()
	var/ware_type
	if(value == rogue_value("trade_mail_paper_price"))
		ware_type = /obj/item/paper
	else if(value == rogue_value("trade_mail_quill_price"))
		ware_type = /obj/item/natural/feather
	if(!ware_type || !rogue_coin_accepted(coin))
		to_chat(user, span_warning("Not a valid denomination! Insert [rogue_value("trade_mail_paper_price")] mammon for paper, [rogue_value("trade_mail_quill_price")] mammon for a quill."))
		return
	qdel(coin)
	user.put_in_hands(new ware_type(drop_location()))
	playsound(src, ROGUE_SOUND_COIN_INSERT, 100, FALSE, -1)

/// Sends a page to a box by its number or to a person by name (Ratwood attackby() with paper).
/obj/structure/roguemachine/mail/proc/send_letter(obj/item/paper/letter, mob/living/user)
	if(tgui_alert(user, "Send Mail?", name, list("Yes", "No")) != "Yes")
		return
	var/address = tgui_input_text(user, "Where to? (Person or #number)", name, max_length = MAX_NAME_LEN)
	if(!address)
		return
	var/sender = tgui_input_text(user, "Who is this from? (Leave blank to send anonymously)", name, max_length = MAX_NAME_LEN) || "Anonymous"
	if(QDELETED(src) || QDELETED(letter) || !user.Adjacent(src) || !user.is_holding(letter))
		return
	if(findtext(address, "#"))
		var/number = text2num(copytext(address, findtext(address, "#") + 1))
		var/obj/structure/roguemachine/mail/box = (number >= 1 && number <= length(GLOB.rogue_mailboxes)) ? GLOB.rogue_mailboxes[number] : null
		if(!box)
			to_chat(user, span_warning("Cannot send it. Bad number?"))
			return
		address_letter(letter, sender, address)
		letter.forceMove(box.drop_location())
		box.say("New mail!")
		playsound(box, ROGUE_SOUND_HISS, 100, FALSE, -1)
		sent_off(user)
		return
	var/obj/item/roguemachine/mastermail/master = GLOB.rogue_mail_master
	if(!master)
		to_chat(user, span_warning("The master of mails has perished?"))
		return
	var/mob/living/carbon/human/recipient
	for(var/mob/living/carbon/human/person as anything in GLOB.human_list)
		if(person.real_name == address)
			recipient = person
			break
	if(!recipient && tgui_alert(user, "Could not find recipient [address]. Still send the letter?", name, list("Yes", "No")) != "Yes")
		return
	if(QDELETED(letter) || !user.is_holding(letter) || QDELETED(master))
		return
	address_letter(letter, sender, address)
	master.receive(letter)
	sent_off(user)
	if(recipient)
		to_chat(recipient, span_boldnotice("New letter from [sender]."))
		recipient.playsound_local(recipient, ROGUE_SOUND_MAIL, 100, FALSE)

/obj/structure/roguemachine/mail/proc/address_letter(obj/item/paper/letter, sender, address)
	letter.rogue_mail_from = sender
	letter.rogue_mail_to = address
	letter.name = "letter to [address]"

/obj/structure/roguemachine/mail/proc/sent_off(mob/living/user)
	visible_message(span_warning("[user] sends something."))
	playsound(src, ROGUE_SOUND_FLUSH, 100, FALSE, -1)

/obj/item/paper/examine(mob/user)
	. = ..()
	if(rogue_mail_to)
		. += span_info("The envelope reads: to [rogue_mail_to], from [rogue_mail_from].")

/**
 * MASTER OF MAILS (Ratwood mastermail): the post office where letters to persons wait. Anyone at it may look through them and
 * take one out; a letter put back goes on waiting for its addressee.
 */
/obj/item/roguemachine/mastermail
	anchored = TRUE

/obj/item/roguemachine/mastermail/Initialize(mapload)
	. = ..()
	GLOB.rogue_mail_master = src
	update_appearance()

/obj/item/roguemachine/mastermail/Destroy()
	if(GLOB.rogue_mail_master == src)
		GLOB.rogue_mail_master = null
	var/turf/spot = drop_location()
	for(var/obj/item/letter in src)
		letter.forceMove(spot)
	return ..()

/obj/item/roguemachine/mastermail/update_icon_state()
	icon_state = length(contents) ? "mailspecial-get" : "mailspecial"
	return ..()

/obj/item/roguemachine/mastermail/proc/receive(obj/item/paper/letter)
	letter.forceMove(src)
	update_appearance()

/obj/item/roguemachine/mastermail/proc/letters_for(addressee)
	. = list()
	for(var/obj/item/paper/letter in src)
		if(letter.rogue_mail_to == addressee)
			. += letter

/// Looks through the waiting letters and takes one out (Ratwood: the master's storage opened by hand).
/obj/item/roguemachine/mastermail/attack_hand(mob/user, list/modifiers)
	if(!isliving(user))
		return ..()
	var/list/letters = list()
	for(var/obj/item/paper/letter in src)
		letters["[letter.rogue_mail_to] (from [letter.rogue_mail_from]) [REF(letter)]"] = letter
	if(!length(letters))
		to_chat(user, span_notice("No letters wait in [src]."))
		return TRUE
	var/choice = tgui_input_list(user, "Take out which letter?", name, letters)
	var/obj/item/paper/letter = letters[choice]
	if(!letter || letter.loc != src || !user.Adjacent(src))
		return TRUE
	user.put_in_hands(letter)
	update_appearance()
	return TRUE

/// A letter put back waits for its addressee again (Ratwood attackby()).
/obj/item/roguemachine/mastermail/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/paper))
		return NONE
	var/obj/item/paper/letter = tool
	if(!letter.rogue_mail_to)
		to_chat(user, span_warning("[letter] has no address."))
		return ITEM_INTERACT_BLOCKING
	receive(letter)
	return ITEM_INTERACT_SUCCESS
