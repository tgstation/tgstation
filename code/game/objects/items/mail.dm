
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
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	/// destination tagging for the mail sorter
	var/sortTag = 0
	/// who this mail is for and who can open it
	var/mob/recipient
	/// how many goodies this mail contains
	var/goodie_count = 1
	/// Goodies which can be given to anyone. The base weight for cash is 56. for there to be a 50/50 chance of getting a department item, they need 56 weight as well.
	var/list/generic_goodies = list(
		/obj/item/stack/spacecash/c50 = 10
		/obj/item/stack/spacecash/c100 = 25,
		/obj/item/stack/spacecash/c200 = 15,
		/obj/item/stack/spacecash/c500 = 5,
		/obj/item/stack/spacecash/c1000 = 1,
	)
	// Overlays (pure fluff)
	var/postmarked = TRUE
	var/stamped = TRUE
	var/list/stamps = list()
	var/stamp_max = 1
	var/stamp_offset_x = 0
	var/stamp_offset_y = 2

	///mail will have the color of the department the recipient is in.
	var/static/list/department_colors

/obj/item/mail/envelope
	name = "envelope"
	icon_state = "mail_large"
	goodie_count = 2
	stamp_max = 2
	stamp_offset_y = 5

/obj/item/mail/Initialize()
	. = ..()
	AddElement(/datum/element/item_scaling, 0.5, 1)
	if(!department_colors.len)
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
		var/N = rand(1, stamp_max)
		for(var/i = 1, i <= N, i++)
			var/X = rand(2, 6)
			stamps += list("stamp_[X]")
	update_icon()

/obj/item/mail/update_icon()
	. = ..()
	cut_overlays()

	var/bonus_stamp_offset = 0
	for(var/S in stamps)
		var/image/SI = image(
			icon = icon,
			icon_state = S,
			pixel_x = stamp_offset_x,
			pixel_y = stamp_offset_y + bonus_stamp_offset
		)
		// Stops postmarks from inheriting letter color.
		// http://www.byond.com/docs/ref/#/atom/var/appearance_flags
		SI.appearance_flags |= RESET_COLOR
		add_overlay(SI)
		bonus_stamp_offset -= 5

	if(postmarked == TRUE)
		var/image/PMI = image(
			icon = icon,
			icon_state = "postmark",
			pixel_x = stamp_offset_x + rand(-3, 1),
			pixel_y = stamp_offset_y + rand(bonus_stamp_offset + 3, 1)
		)
		PMI.appearance_flags |= RESET_COLOR
		add_overlay(PMI)

/obj/item/mail/attackby(obj/item/W, mob/user, params)
	// Destination tagging
	if(istype(W, /obj/item/dest_tagger))
		var/obj/item/dest_tagger/O = W

		if(sortTag != O.currTag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[O.currTag])
			to_chat(user, "<span class='notice'>*[tag]*</span>")
			sortTag = O.currTag
			playsound(loc, 'sound/machines/twobeep_high.ogg', 100, TRUE)

/obj/item/mail/attack_self(mob/user)
	if(recipient && user != recipient)
		to_chat(user, "<span class='notice'>You can't open somebody else's mail! That's <em>illegal</em>!</span>")
		return

	to_chat(user, "<span class='notice'>You start to unwrap the package...</span>")
	if(!do_after(user, 15, target = user))
		return
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	unwrap_contents()
	for(var/X in contents)
		var/atom/movable/AM = X
		user.put_in_hands(AM)
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
	qdel(src)

/obj/item/mail/proc/unwrap_contents()
	for(var/obj/I in src.GetAllContents())
		SEND_SIGNAL(I, COMSIG_STRUCTURE_UNWRAPPED)

/// Accepts a mob to initialize goodies for a piece of mail.
/obj/item/mail/proc/initialize_for_recipient(mob/new_recipient)
	recipient = new_recipient
	name = "[initial(name)] for [recipient.real_name] ([recipient.job])"
	var/list/goodies = generic_goodies

	var/datum/job/this_job = SSjob.name_occupations[recipient.job]
	if(this_job)
		if(this_job.paycheck_department && department_colors[this_job.paycheck_department])
			color = department_colors[this_job.paycheck_department]
		var/list/job_goodies = this_job.get_mail_goodies()
		if(LAZYLEN(job_goodies))
			// certain roles and jobs (prisoner) do not receive generic gifts.
			if(this_job.exclusive_mail_goodies)
				goodies = job_goodies
			else
				goodies += job_goodies

	for(var/i = 0, i < goodie_count, i++)
		var/T = pickweight(goodies)
		if(ispath(T, /datum/reagent))
			var/obj/item/reagent_containers/TI = new /obj/item/reagent_containers/glass/bottle(src)
			TI.reagents.add_reagent(T, TI.volume)
			TI.name = "[TI.reagents.reagent_list[1].name] bottle"
			new_recipient.log_message("[key_name(new_recipient)] received reagent container [TI.name] in the mail ([T])", LOG_GAME)
		else
			var/atom/movable/TI = new T(src)
			new_recipient.log_message("[key_name(new_recipient)] received [TI.name] in the mail ([T])", LOG_GAME)

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
		/obj/item/paper/fluff/junkmail_redpill = "[initial(name)] for those feeling [pick(GLOB.adjectives)] working at nanotrasen",
		/obj/effect/decal/cleanable/ash = "[initial(name)] with INCREDIBLY IMPORTANT ARTIFACT- DELIVER TO SCIENCE DIVISION",
	)

	color = pick(department_colors) //eh, who gives a shit.
	name = special_name ? junk_names[junk] : "important [initial(name)]"

	junk = new junk(src)
	return TRUE

/// Subtype that's always junkmail
/obj/item/mail/junkmail/Initialize()
	..()
	junk_mail()

/// Crate for mail from CentCom.
/obj/structure/closet/crate/mail
	name = "mail crate"
	desc = "A certified post crate from CentCom."
	icon_state = "mail"

/// Crate for mail that automatically generates a lot of mail. Usually only normal mail, but on lowpop it may end up just being junk.
/obj/structure/closet/crate/mail/full
	name = "mail crate"
	desc = "A certified post crate from CentCom."
	icon_state = "mail"

/obj/structure/closet/crate/mail/update_icon_state()
	. = ..()
	if(opened)
		icon_state = "[initial(icon_state)]open"
	else
		icon_state = "[initial(icon_state)]sealed"
		for(var/obj/item/mail/M in src)
			icon_state = initial(icon_state)
			break

/obj/structure/closet/crate/mail/full/Initialize()
	. = ..()
	var/list/mail_recipients = list()
	for(var/mob/living/carbon/human/alive in GLOB.player_list)
		if(alive.stat != DEAD)
			mail_recipients += alive
	for(var/i in 1 to 22)
		var/obj/item/mail/NM
		if(prob(70))
			NM = new /obj/item/mail(src)
		else
			NM = new /obj/item/mail/envelope(src)
		var/mob/living/carbon/human/mail_to
		if(mail_recipients.len)
			mail_to = pick(mail_recipients)
		if(prob(50)) //so after 21 passes if everyone's at least gotten something we'll junkmail it up
			mail_recipients -= mail_to
		if(mail_to)
			NM.initialize_for_recipient(mail_to)
		else
			NM.junk_mail()

/// Mailbag.
/obj/item/storage/bag/mail
	name = "mail bag"
	desc = "A bag for letters, envelopes, and other postage."
	icon = 'icons/obj/library.dmi'
	icon_state = "bookbag"
	worn_icon_state = "bookbag"
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/mail/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 42
	STR.max_items = 21
	STR.display_numerical_stacking = FALSE
	STR.set_holdable(list(
		/obj/item/mail
	))

/obj/item/paper/fluff/junkmail_redpill
	name = "smudged paper"
	icon_state = "scrap"

/obj/item/paper/fluff/junkmail_redpill/Initialize()
	. = ..()
	info = "<i>You need to escape the simulation. Don't forget the numbers, they help you remember:</i> '[rand(0,9)][rand(0,9)][rand(0,9)]'"

/obj/item/paper/fluff/junkmail_generic
	name = "important document"
	icon_state = "paper_words"

/obj/item/paper/fluff/junkmail_generic/Initialize()
	. = ..()
	info = pick(GLOB.junkmail_messages)
