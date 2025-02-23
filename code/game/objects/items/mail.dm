/// Mail is tamper-evident and unresealable, postmarked by CentCom for an individual recepient.
/obj/item/mail
	name = "mail"
	gender = NEUTER
	desc = "An officially postmarked, tamper-evident parcel regulated by CentCom and made of high-quality materials."
	icon = 'icons/obj/service/bureaucracy.dmi'
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
		bonus_stamp_offset -= 5
		. += stamp_image

	if(postmarked == TRUE)
		var/image/postmark_image = image(
			icon = icon,
			icon_state = "postmark",
			pixel_x = stamp_offset_x + rand(-3, 1),
			pixel_y = stamp_offset_y + rand(bonus_stamp_offset + 3, 1)
		)
		postmark_image.appearance_flags |= RESET_COLOR
		. += postmark_image

/obj/item/mail/attackby(obj/item/W, mob/user, params)
	// Destination tagging
	if(istype(W, /obj/item/dest_tagger))
		var/obj/item/dest_tagger/destination_tag = W

		if(sort_tag != destination_tag.currTag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[destination_tag.currTag])
			to_chat(user, span_notice("*[tag]*"))
			sort_tag = destination_tag.currTag
			playsound(loc, 'sound/machines/beep/twobeep_high.ogg', vol = 100, vary = TRUE)

/obj/item/mail/multitool_act(mob/living/user, obj/item/tool)
	if(user.get_inactive_held_item() == src)
		balloon_alert(user, "nothing to disable!")
		return TRUE
	balloon_alert(user, "hold it!")
	return FALSE


/obj/item/mail/attack_self(mob/user)
	if(!unwrap(user))
		return FALSE
	return after_unwrap(user)

/// proc for unwrapping a mail. Goes just for an unwrapping procces, returns FALSE if it fails.
/obj/item/mail/proc/unwrap(mob/user)
	if(recipient_ref)
		var/datum/mind/recipient = recipient_ref.resolve()
		// If the recipient's mind has gone, then anyone can open their mail
		// whether a mind can actually be qdel'd is an exercise for the reader
		if(recipient && recipient != user?.mind)
			to_chat(user, span_notice("You can't open somebody else's mail! That's <em>illegal</em>!"))
			return FALSE

	balloon_alert(user, "unwrapping...")
	if(!do_after(user, 1.5 SECONDS, target = user))
		return FALSE
	return TRUE

// proc that goes after unwrapping a mail.
/obj/item/mail/proc/after_unwrap(mob/user)
	user.temporarilyRemoveItemFromInventory(src, force = TRUE)
	for(var/obj/stuff as anything in contents) // Mail and envelope actually can have more than 1 item.
		if(isitem(stuff))
			user.put_in_hands(stuff)
		else
			stuff.forceMove(drop_location())
	playsound(loc, 'sound/items/poster/poster_ripped.ogg', vol = 50, vary = TRUE)
	qdel(src)
	return TRUE


/obj/item/mail/examine_more(mob/user)
	. = ..()
	if(!postmarked)
		. += span_info("This mail has no postmarking of any sort...")
	else
		. += span_notice("<i>You notice the postmarking on the front of the mail...</i>")
	var/datum/mind/recipient = recipient_ref.resolve()
	if(recipient)
		. += span_info("[postmarked ? "Certified NT" : "Uncertfieid"] mail for [recipient].")
	else if(postmarked)
		. += span_info("Certified mail for [GLOB.station_name].")
	else
		. += span_info("This is a dead letter mail with no recipient.")
	. += span_info("Distribute by hand or via destination tagger using the certified NT disposal system.")

/// Accepts a mind to initialize goodies for a piece of mail.
/obj/item/mail/proc/initialize_for_recipient(datum/mind/recipient)
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
		junk = pick(list(
			/obj/item/paper/pamphlet/gateway,
			/obj/item/paper/pamphlet/violent_video_games,
			/obj/item/paper/fluff/junkmail_redpill,
			/obj/effect/decal/cleanable/ash,
		))

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
	///if it'll show the nt mark on the crate
	var/postmarked = TRUE

/obj/structure/closet/crate/mail/update_icon_state()
	. = ..()
	if(opened)
		icon_state = "[base_icon_state]open"
		if(locate(/obj/item/mail) in src)
			icon_state = base_icon_state
	else
		icon_state = "[base_icon_state]sealed"

/obj/structure/closet/crate/mail/update_overlays()
	. = ..()
	if(postmarked)
		. += "mail_nt"

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

///Used in the mail strike shuttle loan event
/obj/structure/closet/crate/mail/full/mail_strike
	desc = "A post crate from somewhere else. It has no NT logo on it."
	postmarked = FALSE

/obj/structure/closet/crate/mail/full/mail_strike/populate(amount)
	var/strike_mail_to_spawn = rand(1, storage_capacity-1)
	for(var/i in 1 to strike_mail_to_spawn)
		if(prob(95))
			new /obj/item/mail/mail_strike(src)
		else
			new /obj/item/mail/traitor/mail_strike(src)
	return ..(storage_capacity - strike_mail_to_spawn)

/// Opened mail crate
/obj/structure/closet/crate/mail/preopen
	opened = TRUE
	icon_state = "mailopen"

/// Mailbag.
/obj/item/storage/bag/mail
	name = "mail bag"
	desc = "A bag for letters, envelopes, and other postage."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "mailbag"
	worn_icon_state = "mailbag"
	resistance_flags = FLAMMABLE
	custom_premium_price = PAYCHECK_LOWER

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
	var/obj/machinery/nuclearbomb/selfdestruct/self_destruct = locate() in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb/selfdestruct)
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

/obj/item/mail/traitor
	var/armed = FALSE
	var/datum/weakref/made_by_ref
	/// Cached information about who made it for logging purposes
	var/made_by_cached_name
	/// Cached information about who made it for logging purposes
	var/made_by_cached_ckey
	goodie_count = 0

/obj/item/mail/traitor/envelope
	name = "envelope"
	icon_state = "mail_large"
	stamp_max = 2
	stamp_offset_y = 5

/obj/item/mail/traitor/after_unwrap(mob/user)
	user.temporarilyRemoveItemFromInventory(src, force = TRUE)
	playsound(loc, 'sound/items/poster/poster_ripped.ogg', vol = 50, vary = TRUE)
	for(var/obj/item/stuff as anything in contents) // Mail and envelope actually can have more than 1 item.
		if(user.put_in_hands(stuff) && armed)
			var/whomst = made_by_cached_name ? "[made_by_cached_name] ([made_by_cached_ckey])" : "no one in particular"
			log_bomber(user, "opened armed mail made by [whomst], activating", stuff)
			INVOKE_ASYNC(stuff, TYPE_PROC_REF(/obj/item, attack_self), user)
	qdel(src)
	return TRUE

/obj/item/mail/traitor/multitool_act(mob/living/user, obj/item/tool)
	if(armed == FALSE || user.get_inactive_held_item() != src)
		return ..()
	if(IS_WEAKREF_OF(user.mind, made_by_ref))
		balloon_alert(user, "disarming trap...")
		if(!do_after(user, 2 SECONDS, target = src))
			return FALSE
		balloon_alert(user, "disarmed")
		playsound(src, 'sound/machines/defib/defib_ready.ogg', vol = 100, vary = TRUE)
		armed = FALSE
		return TRUE
	else
		balloon_alert(user, "tinkering with something...")

		if(!do_after(user, 2 SECONDS, target = src))
			after_unwrap(user)
			return FALSE
		if(prob(50))
			balloon_alert(user, "disarmed something...?")
			playsound(src, 'sound/machines/defib/defib_ready.ogg', vol = 100, vary = TRUE)
			armed = FALSE
			return TRUE
		else
			after_unwrap(user)
			return TRUE

///Generic mail used in the mail strike shuttle loan event
/obj/item/mail/mail_strike
	name = "dead mail"
	desc = "An unmarked parcel of unknown origins, effectively undeliverable."
	postmarked = FALSE
	generic_goodies = list(
		/obj/effect/spawner/random/entertainment/money_medium = 2,
		/obj/effect/spawner/random/contraband = 2,
		/obj/effect/spawner/random/entertainment/money_large = 1,
		/obj/effect/spawner/random/entertainment/coin = 1,
		/obj/effect/spawner/random/food_or_drink/any_snack_or_beverage = 1,
		/obj/effect/spawner/random/entertainment/drugs = 1,
		/obj/effect/spawner/random/contraband/grenades = 1,
	)

/obj/item/mail/mail_strike/Initialize(mapload)
	if(prob(35))
		stamped = FALSE
	if(prob(35))
		name = "dead envelope"
		icon_state = "mail_large"
		goodie_count = 2
		stamp_max = 2
		stamp_offset_y = 5
	. = ..()
	color = pick(COLOR_SILVER, COLOR_DARK, COLOR_DRIED_TAN, COLOR_ORANGE_BROWN, COLOR_BROWN, COLOR_SYNDIE_RED)
	for(var/goodie in 1 to goodie_count)
		var/target_good = pick_weight(generic_goodies)
		new target_good(src)

///Also found in the mail strike shuttle loan. It contains a random grenade that'll be triggered when unwrapped
/obj/item/mail/traitor/mail_strike
	name = "dead mail"
	desc = "An unmarked parcel of unknown origins, effectively undeliverable."
	postmarked = FALSE

/obj/item/mail/traitor/mail_strike/Initialize(mapload)
	if(prob(35))
		stamped = FALSE
	if(prob(35))
		name = "dead envelope"
		icon_state = "mail_large"
		goodie_count = 2
		stamp_max = 2
		stamp_offset_y = 5
	. = ..()
	color = pick(COLOR_SILVER, COLOR_DARK, COLOR_DRIED_TAN, COLOR_ORANGE_BROWN, COLOR_BROWN, COLOR_SYNDIE_RED)
	new /obj/effect/spawner/random/contraband/grenades/dangerous(src)

/obj/item/storage/mail_counterfeit_device
	name = "GLA-2 mail counterfeit device"
	desc = "A single-use device for spoofing official NT envelopes. Can hold one normal sized object, and can be programmed to arm its contents when opened."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "mail_counterfeit_device"

/obj/item/storage/mail_counterfeit_device/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 1
	atom_storage.allow_big_nesting = TRUE
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL

/obj/item/storage/mail_counterfeit_device/examine_more(mob/user)
	. = ..()
	. += span_notice("<i>You notice the manufacturer information on the side of the device...</i>")
	. += "\t[span_info("Guerilla Letter Assembler")]"
	. += "\t[span_info("GLA Postal Service, right on schedule.")]"
	return .

/obj/item/storage/mail_counterfeit_device/attack_self(mob/user, modifiers)
	var/mail_type = tgui_alert(user, "Make it look like an envelope or like normal mail?", "Mail Counterfeiting", list("Mail", "Envelope"))
	if(isnull(mail_type))
		return FALSE
	if(loc != user)
		return FALSE
	mail_type = LOWER_TEXT(mail_type)

	var/mail_armed = tgui_alert(user, "Arm it?", "Mail Counterfeiting", list("Yes", "No")) == "Yes"
	if(isnull(mail_armed))
		return FALSE
	if(loc != user)
		return FALSE

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

	var/obj/item/mail/traitor/shady_mail
	if(mail_type == "mail")
		shady_mail = new /obj/item/mail/traitor
	else
		shady_mail = new /obj/item/mail/traitor/envelope

	shady_mail.made_by_cached_ckey = user.ckey
	shady_mail.made_by_cached_name = user.mind.name

	if(index == 1)
		var/mail_name = tgui_input_text(user, "Enter mail title, or leave it blank", "Mail Counterfeiting", max_length = MAX_LABEL_LEN)
		if(!(src in user.contents))
			return FALSE
		if(reject_bad_text(mail_name, max_length = MAX_LABEL_LEN, ascii_only = FALSE))
			shady_mail.name = mail_name
		else
			shady_mail.name = mail_type
	else
		shady_mail.initialize_for_recipient(mail_recipients[index])

	atom_storage.hide_contents(user)
	user.temporarilyRemoveItemFromInventory(src, force = TRUE)
	shady_mail.contents += contents
	shady_mail.armed = mail_armed
	shady_mail.made_by_ref = WEAKREF(user.mind)
	user.put_in_hands(shady_mail)
	qdel(src)

/// Unobtainable item mostly for (b)admin purposes.
/obj/item/storage/mail_counterfeit_device/advanced
	name = "GLA-MACRO mail counterfeit device"

/obj/item/storage/mail_counterfeit_device/advanced/Initialize(mapload)
	. = ..()
	desc += " This model is highly advanced and capable of compressing items, making mail's storage space comparable to standard backpack."
	create_storage(max_slots = 21, max_total_storage = 21)
	atom_storage.allow_big_nesting = TRUE

/// Unobtainable item mostly for (b)admin purposes.
/obj/item/storage/mail_counterfeit_device/bluespace
	name = "GLA-ULTRA mail counterfeit device"

/obj/item/storage/mail_counterfeit_device/bluespace/Initialize(mapload)
	. = ..()
	desc += " This model is the most advanced and capable of performing crazy bluespace compressions, making mail's storage space comparable to bluespace backpack."
	create_storage(max_specific_storage = WEIGHT_CLASS_GIGANTIC, max_total_storage = 35, max_slots = 30)
	atom_storage.allow_big_nesting = TRUE
