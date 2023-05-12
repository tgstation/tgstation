/// Mail is tamper-evident and unresealable, postmarked by CentCom for an individual recepient.
/obj/item/mail
	name = "mail"
	gender = NEUTER
	desc = "An officially postmarked, tamper-evident parcel regulated by CentCom and made of high-quality materials."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "mail_small"
	inhand_icon_state = "paper"
	worn_icon_state = "paper"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	/// Destination tagging for the mail sorter.
	var/sort_tag = 0
	/// Weak reference to who this mail is for and who can open it.
	var/datum/weakref/recipient_ref
	/// How many goodies this mail contains.
	var/goodie_count = 1
	/// Goodies which can be given to anyone. The base weight is 50. For there to be a 50/50 chance of getting a department item, they need 50 weight as well.
	var/list/generic_goodies = list(
		/obj/effect/spawner/random/entertainment/money_medium = 25,
		/obj/effect/spawner/random/food_or_drink/refreshing_beverage = 10,
		/obj/effect/spawner/random/food_or_drink/snack = 5,
		/obj/effect/spawner/random/food_or_drink/donkpockets_single = 5,
		/obj/effect/spawner/random/entertainment/toy = 3,
		/obj/effect/spawner/random/entertainment/coin = 2,
	)
	// Overlays (pure fluff)
	/// Does the letter have the postmark overlay?
	var/postmarked = TRUE
	/// Does the letter have a stamp overlay?
	var/stamped = TRUE
	/// List of all stamp overlays on the letter.
	var/list/stamps = list()
	/// Maximum number of stamps on the letter.
	var/stamp_max = 1
	/// Physical offset of stamps on the object. X direction.
	var/stamp_offset_x = 0
	/// Physical offset of stamps on the object. Y direction.
	var/stamp_offset_y = 2

	///mail will have the color of the department the recipient is in.
	var/static/list/department_colors

/obj/item/mail/envelope
	name = "envelope"
	icon_state = "mail_large"
	goodie_count = 2
	stamp_max = 2
	stamp_offset_y = 5

/obj/item/mail/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposal_handling))
	AddElement(/datum/element/item_scaling, 0.75, 1)
	if(isnull(department_colors))
		department_colors = list(
			ACCOUNT_CIV = COLOR_WHITE,
			ACCOUNT_ENG = COLOR_PALE_ORANGE,
			ACCOUNT_SCI = COLOR_PALE_PURPLE_GRAY,
			ACCOUNT_MED = COLOR_PALE_BLUE_GRAY,
			ACCOUNT_SRV = COLOR_PALE_GREEN_GRAY,
			ACCOUNT_CAR = COLOR_BEIGE,
			ACCOUNT_SEC = COLOR_PALE_RED_GRAY,
		)

	// Icons
	// Add some random stamps.
	if(stamped == TRUE)
		var/stamp_count = rand(1, stamp_max)
		for(var/i in 1 to stamp_count)
			stamps += list("stamp_[rand(2, 6)]")
	update_icon()

/obj/item/mail/update_overlays()
	. = ..()
	var/bonus_stamp_offset = 0
	for(var/stamp in stamps)
		var/image/stamp_image = image(
			icon = icon,
			icon_state = stamp,
			pixel_x = stamp_offset_x,
			pixel_y = stamp_offset_y + bonus_stamp_offset
		)
		stamp_image.appearance_flags |= RESET_COLOR
		add_overlay(stamp_image)
		bonus_stamp_offset -= 5

	if(postmarked == TRUE)
		var/image/postmark_image = image(
			icon = icon,
			icon_state = "postmark",
			pixel_x = stamp_offset_x + rand(-3, 1),
			pixel_y = stamp_offset_y + rand(bonus_stamp_offset + 3, 1)
		)
		postmark_image.appearance_flags |= RESET_COLOR
		add_overlay(postmark_image)

/obj/item/mail/attackby(obj/item/W, mob/user, params)
	// Destination tagging
	if(istype(W, /obj/item/dest_tagger))
		var/obj/item/dest_tagger/destination_tag = W

		if(sort_tag != destination_tag.currTag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[destination_tag.currTag])
			to_chat(user, span_notice("*[tag]*"))
			sort_tag = destination_tag.currTag
			playsound(loc, 'sound/machines/twobeep_high.ogg', 100, TRUE)

/obj/item/mail/attack_self(mob/user)
	if(recipient_ref)
		var/datum/mind/recipient = recipient_ref.resolve()
		// If the recipient's mind has gone, then anyone can open their mail
		// whether a mind can actually be qdel'd is an exercise for the reader
		if(recipient && recipient != user?.mind)
			to_chat(user, span_notice("You can't open somebody else's mail! That's <em>illegal</em>!"))
			return

	to_chat(user, span_notice("You start to unwrap the package..."))
	if(!do_after(user, 1.5 SECONDS, target = user))
		return
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	for(var/obj/item/stuff in contents) // Mail and envelope actually can have more than 1 item.
		user.put_in_hands(stuff)
	playsound(loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
	qdel(src)

/obj/item/mail/examine_more(mob/user)
	. = ..()
	var/list/msg = list(span_notice("<i>You notice the postmarking on the front of the mail...</i>"))
	var/datum/mind/recipient = recipient_ref.resolve()
	if(recipient)
		msg += "\t[span_info("Certified NT mail for [recipient].")]"
	else
		msg += "\t[span_info("Certified mail for [GLOB.station_name].")]"
	msg += "\t[span_info("Distribute by hand or via destination tagger using the certified NT disposal system.")]"
	return msg

/// Accepts a mind to initialize goodies for a piece of mail.
/obj/item/mail/proc/initialize_for_recipient(datum/mind/recipient)
	// PLEASE, IF YOU GONNA CHANGE HERE SOMETHING, CHECK FOR BUGS WITH TRAITOR MAILS!!

	name = "[initial(name)] for [recipient.name] ([recipient.assigned_role.title])"
	recipient_ref = WEAKREF(recipient)

	var/mob/living/body = recipient.current
	var/list/goodies = generic_goodies

	var/datum/job/this_job = recipient.assigned_role
	var/is_mail_restricted = FALSE // certain roles and jobs (prisoner) do not receive generic gifts

	if(this_job)
		if(this_job.paycheck_department && department_colors[this_job.paycheck_department])
			color = department_colors[this_job.paycheck_department]

		var/list/job_goodies = this_job.get_mail_goodies()
		is_mail_restricted = this_job.exclusive_mail_goodies
		if(LAZYLEN(job_goodies))
			if(is_mail_restricted)
				goodies = job_goodies
			else
				goodies += job_goodies

	if(!is_mail_restricted)
		// the weighted list is 50 (generic items) + 50 (job items)
		// every quirk adds 5 to the final weighted list (regardless the number of items or weights in the quirk list)
		// 5% is not too high or low so that stacking multiple quirks doesn't tilt the weighted list too much
		for(var/datum/quirk/quirk as anything in body.quirks)
			if(LAZYLEN(quirk.mail_goodies))
				var/quirk_goodie = pick(quirk.mail_goodies)
				goodies[quirk_goodie] = 5

	for(var/iterator in 1 to goodie_count)
		var/target_good = pick_weight(goodies)
		var/atom/movable/target_atom = new target_good(src)
		body.log_message("received [target_atom.name] in the mail ([target_good])", LOG_GAME)

	return TRUE

/// Alternate setup, just complete garbage inside and anyone can open
/obj/item/mail/proc/junk_mail()

	var/obj/junk = /obj/item/paper/fluff/junkmail_generic
	var/special_name = FALSE

	if(prob(25))
		special_name = TRUE
		junk = pick(list(/obj/item/paper/pamphlet/gateway, /obj/item/paper/pamphlet/violent_video_games, /obj/item/paper/fluff/junkmail_redpill, /obj/effect/decal/cleanable/ash))

	var/list/junk_names = list(
		/obj/item/paper/pamphlet/gateway = "[initial(name)] for [pick(GLOB.adjectives)] adventurers",
		/obj/item/paper/pamphlet/violent_video_games = "[initial(name)] for the truth about the arcade centcom doesn't want to hear",
		/obj/item/paper/fluff/junkmail_redpill = "[initial(name)] for those feeling [pick(GLOB.adjectives)] working at Nanotrasen",
		/obj/effect/decal/cleanable/ash = "[initial(name)] with INCREDIBLY IMPORTANT ARTIFACT- DELIVER TO SCIENCE DIVISION. HANDLE WITH CARE.",
	)

	color = pick(department_colors) //eh, who gives a shit.
	name = special_name ? junk_names[junk] : "important [initial(name)]"

	junk = new junk(src)
	return TRUE

/obj/item/mail/proc/disposal_handling(disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER
	if(!hasmob)
		disposal_holder.destinationTag = sort_tag

/// Subtype that's always junkmail
/obj/item/mail/junkmail/Initialize(mapload)
	. = ..()
	junk_mail()

/// Crate for mail from CentCom.
/obj/structure/closet/crate/mail
	name = "mail crate"
	desc = "A certified post crate from CentCom."
	icon_state = "mail"
	base_icon_state = "mail"
	can_install_electronics = FALSE
	lid_icon_state = "maillid"
	lid_x = -26
	lid_y = 2
	paint_jobs = null

/obj/structure/closet/crate/mail/update_icon_state()
	. = ..()
	if(opened)
		icon_state = "[base_icon_state]open"
		if(locate(/obj/item/mail) in src)
			icon_state = base_icon_state
	else
		icon_state = "[base_icon_state]sealed"

/// Fills this mail crate with N pieces of mail, where N is the lower of the amount var passed, and the maximum capacity of this crate. If N is larger than the number of alive human players, the excess will be junkmail.
/obj/structure/closet/crate/mail/proc/populate(amount)
	var/mail_count = min(amount, storage_capacity)
	// Fills the
	var/list/mail_recipients = list()

	for(var/mob/living/carbon/human/human in GLOB.player_list)
		if(human.stat == DEAD || !human.mind)
			continue
		// Skip wizards, nuke ops, cyborgs; Centcom does not send them mail
		if(!(human.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			continue

		mail_recipients += human.mind

	for(var/i in 1 to mail_count)
		var/obj/item/mail/new_mail
		if(prob(FULL_CRATE_LETTER_ODDS))
			new_mail = new /obj/item/mail(src)
		else
			new_mail = new /obj/item/mail/envelope(src)

		var/datum/mind/recipient = pick_n_take(mail_recipients)
		if(recipient)
			new_mail.initialize_for_recipient(recipient)
		else
			new_mail.junk_mail()

	update_icon()

/// Crate for mail that automatically depletes the economy subsystem's pending mail counter.
/obj/structure/closet/crate/mail/economy/Initialize(mapload)
	. = ..()
	populate(SSeconomy.mail_waiting)
	SSeconomy.mail_waiting = 0

/// Crate for mail that automatically generates a lot of mail. Usually only normal mail, but on lowpop it may end up just being junk.
/obj/structure/closet/crate/mail/full
	name = "brimming mail crate"
	desc = "A certified post crate from CentCom. Looks stuffed to the gills."

/obj/structure/closet/crate/mail/full/Initialize(mapload)
	. = ..()
	populate(INFINITY)


/// Opened mail crate
/obj/structure/closet/crate/mail/preopen
	opened = TRUE
	icon_state = "mailopen"

/// Mailbag.
/obj/item/storage/bag/mail
	name = "mail bag"
	desc = "A bag for letters, envelopes, and other postage."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "mailbag"
	worn_icon_state = "mailbag"
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/mail/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 42
	atom_storage.max_slots = 21
	atom_storage.numerical_stacking = FALSE
	atom_storage.set_holdable(list(
		/obj/item/mail,
		/obj/item/delivery/small,
		/obj/item/paper
	))

/obj/item/paper/fluff/junkmail_redpill
	name = "smudged paper"
	icon_state = "scrap"
	show_written_words = FALSE
	var/nuclear_option_odds = 0.1

/obj/item/paper/fluff/junkmail_redpill/Initialize(mapload)
	var/obj/machinery/nuclearbomb/selfdestruct/self_destruct = locate() in GLOB.nuke_list
	if(!self_destruct || !prob(nuclear_option_odds)) // 1 in 1000 chance of getting 2 random nuke code characters.
		add_raw_text("<i>You need to escape the simulation. Don't forget the numbers, they help you remember:</i> '[rand(0,9)][rand(0,9)][rand(0,9)]...'")
		return ..()

	if(self_destruct.r_code == NUKE_CODE_UNSET)
		self_destruct.r_code = random_nukecode()
		message_admins("Through junkmail, the self-destruct code was set to \"[self_destruct.r_code]\".")
	add_raw_text("<i>You need to escape the simulation. Don't forget the numbers, they help you remember:</i> '[self_destruct.r_code[rand(1,5)]][self_destruct.r_code[rand(1,5)]]...'")
	return ..()

/obj/item/paper/fluff/junkmail_redpill/true //admin letter enabling players to brute force their way through the nuke code if they're so inclined.
	nuclear_option_odds = 100

/obj/item/paper/fluff/junkmail_generic
	name = "important document"
	icon_state = "paper_words"
	show_written_words = FALSE

/obj/item/paper/fluff/junkmail_generic/Initialize(mapload)
	default_raw_text = pick(GLOB.junkmail_messages)
	return ..()

// =====================
// Antag stuff down here
// =====================

/obj/item/mail/traitor
	var/armed = FALSE
	var/mob/madeby
	goodie_count = 0

/obj/item/mail/traitor/envelope
	name = "envelope"
	icon_state = "mail_large"
	stamp_max = 2
	stamp_offset_y = 5

/obj/item/mail/traitor/attack_self(mob/user)
	if(recipient_ref)
		var/datum/mind/recipient = recipient_ref.resolve()
		// If the recipient's mind has gone, then anyone can open their mail
		// whether a mind can actually be qdel'd is an exercise for the reader
		if(recipient && recipient != user?.mind)
			to_chat(user, span_notice("You can't open somebody else's mail! That's <em>illegal</em>!"))
			return

	to_chat(user, span_notice("You start to unwrap the package..."))
	if(!do_after(user, 1.5 SECONDS, target = user))
		return
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	playsound(loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
	for(var/obj/item/stuff in contents) // Mail and envelope actually can have more than 1 item.
		if(user.put_in_hands(stuff) && armed)
			log_bomber(user, "opened armed mail made by [madeby] ([madeby.ckey]), activating", stuff)
			stuff.attack_self(user)
	qdel(src)

/obj/item/mail/traitor/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(armed)
		if(W.tool_behaviour == TOOL_MULTITOOL)
			to_chat(user, span_notice("You start to disable something..."))
			
			if(do_after(user, 2 SECONDS, target = src))
				to_chat(user, span_notice("You have disarmed some kind of device..."))
				playsound(src, 'sound/machines/defib_ready.ogg', 50, TRUE)
				armed = FALSE

/obj/item/storage/mail_counterfeit_device
	name = "mail counterfeit device"
	desc = "Device that actually able to counterfeit NT's mail. This device also able to place a trap inside of mail for malicious actions. Trap will \"activate\" any item inside of mail. Also it might be used for contraband purposes. Integrated micro-computer will give you great configuration optionality for your needs."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/device_syndie.dmi'
	icon_state = "mail_counterfeit_device" // placeholder for now

/obj/item/storage/mail_counterfeit_device/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 1
	atom_storage.allow_big_nesting = TRUE
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL

/obj/item/storage/mail_counterfeit_device/attack_self(mob/user, modifiers)
	var/mail_type = tgui_alert(user, "Is it gonna be an envelope or a normal mail?", "Mail Counterfeiting", list("Mail", "Envelope"))
	if(isnull(mail_type))
		return FALSE
	if(!(src in user.contents))
		return FALSE
	mail_type = lowertext(mail_type)

	var/mail_armed = tgui_alert(user, "Is it gonna be armed?", "Mail Counterfeiting", list("Yes", "No"))
	if(isnull(mail_armed))
		return FALSE
	if(!(src in user.contents))
		return FALSE

	if(mail_armed == "Yes")
		mail_armed = TRUE
	else
		mail_armed = FALSE

	var/list/mail_recipients = list()
	var/list/mail_recipients_input_list = list("0# Anyone")
	var/iterator = 1
	for(var/mob/living/carbon/human/human in GLOB.human_list)
		// Skip everyone who is not part of the crew...
		if(isnull(human.mind))
			continue
		if(!(human.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			continue
		mail_recipients += human.mind
		mail_recipients_input_list += "[iterator]# [human.name]"
		iterator++
	
	var/recipient = tgui_input_list(user, "Choose a recipient", "Mail Counterfeiting", mail_recipients_input_list)
	if(isnull(recipient))
		return FALSE
	if(!(src in user.contents))
		return FALSE
	
	
	var/index = text2num(copytext(recipient, 1, findtext(recipient, "#")))
	if(index == 0)
		var/mail_name = tgui_input_text(user, "Enter mail title or leave it blank to get a default one.", "Mail Counterfeiting")
		if(!reject_bad_text(mail_name, ascii_only = FALSE))
			mail_name = mail_type
		if(!(src in user.contents))
			return FALSE
		
		
		var/obj/item/mail/traitor/shady_mail
		if(mail_type == "mail")
			shady_mail = new /obj/item/mail/traitor()
		else
			shady_mail = new /obj/item/mail/traitor/envelope()
		
		atom_storage.hide_contents(user)
		user.temporarilyRemoveItemFromInventory(src, TRUE)
		shady_mail.contents += contents
		shady_mail.name = mail_name
		shady_mail.armed = mail_armed
		shady_mail.madeby = user
		user.put_in_hands(shady_mail)
	else
		if(!(src in user.contents))
			return FALSE

		var/obj/item/mail/traitor/shady_mail
		if(mail_type == "mail")
			shady_mail = new /obj/item/mail/traitor()
		else
			shady_mail = new /obj/item/mail/traitor/envelope()
		
		atom_storage.hide_contents(user)
		user.temporarilyRemoveItemFromInventory(src, TRUE)
		shady_mail.contents += contents
		shady_mail.armed = mail_armed
		shady_mail.madeby = user
		shady_mail.initialize_for_recipient(mail_recipients[index])
		user.put_in_hands(shady_mail)
	qdel(src)

// =======================
// Admin stuff down here
// for events or shitspawn
// purposes.
// =======================

/obj/item/storage/mail_counterfeit_device/advanced
	name = "advanced mail counterfeit device"

/obj/item/storage/mail_counterfeit_device/advanced/Initialize(mapload)
	. = ..()
	desc += " This model is highly advanced and capable of compressing items, making mail's storage space comparable to standart backpack."
	create_storage(max_slots = 21, max_total_storage = 21)
	atom_storage.allow_big_nesting = TRUE

/obj/item/storage/mail_counterfeit_device/bluespace
	name = "bluespace mail counterfeit device"

/obj/item/storage/mail_counterfeit_device/bluespace/Initialize(mapload)
	. = ..()
	desc += " This model is the most advanced and capable of performing crazy bluespace compressions, making mail's storage space comparable to bluespace backpack."
	create_storage(max_specific_storage = WEIGHT_CLASS_GIGANTIC, max_total_storage = 35, max_slots = 30)
	atom_storage.allow_big_nesting = TRUE
