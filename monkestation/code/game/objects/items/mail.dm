/// Mail is tamper-evident and unresealable, postmarked by CentCom for an individual recepient.
/obj/item/mail
	name = "mail"
	gender = NEUTER
	desc = "An officially postmarked, tamper-evident parcel regulated by CentCom and made of high-quality materials."
	icon = 'monkestation/icons/obj/mail.dmi'
	icon_state = "mail_small"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	/// Destination tagging for the mail sorter.
	var/sort_tag = 0
	/// Weak reference to who this mail is for and who can open it.
	var/datum/weakref/recipient_ref
	/// How many goodies this mail contains.
	var/goodie_count = 1
	// Goodies which can be given to anyone.
	// For there to be a 50/50 chance of getting a department item, both this and a job list need equal weight
	var/list/generic_goodies = list(
		/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game = 10,
		/obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy = 10,
		/obj/item/food/cheesiehonkers = 10,
		/obj/item/food/candy = 10,
		/obj/item/food/chips = 10,
		/obj/item/stack/spacecash/c50 = 10,
		/obj/item/stack/spacecash/c100 = 5,
		/obj/item/stack/spacecash/c200 = 1

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

/obj/item/mail/examine(mob/user)
	. = ..()

	var/datum/mind/recipient
	if(recipient_ref)
		recipient = recipient_ref.resolve()
	var/msg = "<span class='notice'><i>You notice the postmarking on the front of the mail...</i></span>"
	if(recipient)
		msg += "\n<span class='info'>Certified NT mail for [recipient].</span>"
	else
		msg += "\n<span class='info'>Certified mail for [GLOB.station_name].</span>"
	. += "\n[msg]"


/obj/item/mail/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_DISPOSING, .proc/disposal_handling)
	transform = transform.Scale(((rand(50) / 100) + 0.5), ((rand(50) / 100) + 0.5)) //Between 1.0 and 0.5 scale
	if(isnull(department_colors))
		department_colors = list(
			ACCOUNT_CIV = COLOR_WHITE,
			ACCOUNT_ENG = COLOR_ORANGE,
			ACCOUNT_SCI = COLOR_STRONG_VIOLET,
			ACCOUNT_MED = COLOR_BLUE_LIGHT,
			ACCOUNT_SRV = COLOR_DARK_MODERATE_LIME_GREEN,
			ACCOUNT_CAR = COLOR_BEIGE,
			ACCOUNT_SEC = COLOR_DARK_RED,
		)

	// Icons
	// Add some random stamps.
	if(stamped == TRUE)
		var/stamp_count = rand(1, stamp_max)
		for(var/i = 1, i <= stamp_count, i++)
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
	if(istype(W, /obj/item/destTagger))
		var/obj/item/destTagger/destination_tag = W

		if(sort_tag != destination_tag.currTag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[destination_tag.currTag])
			to_chat(user, "<span class='notice'>*[tag]*</span>")
			sort_tag = destination_tag.currTag
			playsound(loc, 'sound/machines/twobeep_high.ogg', 100, TRUE)

/obj/item/mail/attack_self(mob/user)
	if(recipient_ref)
		var/datum/mind/recipient = recipient_ref.resolve()
		// If the recipient's mind has gone, then anyone can open their mail
		// whether a mind can actually be qdel'd is an exercise for the reader
		if(recipient && recipient != user?.mind)
			to_chat(user, "<span class='notice'>You can't open somebody else's mail! That's <em>illegal</em>!</span>")
			return

	user.visible_message("<span class='notice'>[user] starts to unwrap a package.</span>","<span class='notice'>You start to unwrap the package...</span>")
	if(!do_after(user, 1.5 SECONDS, target = user))
		return
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	if(contents.len)
		user.put_in_hands(contents[1])
	playsound(loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
	qdel(src)

/// Accepts a mind to initialize goodies for a piece of mail.
/obj/item/mail/proc/initialize_for_recipient(datum/mind/recipient)
	switch(rand(1,5))
		if(1,2)
			name = "[initial(name)] for [recipient.name] ([recipient.assigned_role])"
		if(3,4)
			name = "[initial(name)] for [recipient.name]"
		if(5)
			name = "[initial(name)] critical to [recipient.name]"
	recipient_ref = WEAKREF(recipient)

	var/mob/living/body = recipient.current
	var/list/goodies = generic_goodies

	var/datum/job/this_job = SSjob.name_occupations[recipient.assigned_role]
	if(this_job)
		goodies += this_job.mail_goodies
		if(this_job.paycheck_department && department_colors[this_job.paycheck_department])
			color = department_colors[this_job.paycheck_department]

	for(var/iterator = 0, iterator < goodie_count, iterator++)
		var/target_good = pickweight(goodies)
		var/atom/movable/target_atom = new target_good(src)
		body.log_message("[key_name(body)] received [target_atom.name] in the mail ([target_good])", LOG_GAME)

	return TRUE

/// Alternate setup, just complete garbage inside and anyone can open
/obj/item/mail/proc/junk_mail()
	var/list/junk_names

	var/obj/junk = /obj/item/paper/fluff/junkmail_generic
	var/special_name = FALSE

	if(prob(25))
		special_name = TRUE
		junk = pick(list(/obj/item/paper/pamphlet/gateway, /obj/item/paper/pamphlet/violent_video_games, /obj/item/paper/fluff/junkmail_redpill))
		junk_names = list(
		/obj/item/paper/pamphlet/gateway = pick("[initial(name)] for [pick(GLOB.adjectives)] adventurers", "An important [initial(name)] for [pick(GLOB.adjectives)] spacers", "Exploration [initial(name)]"),
		/obj/item/paper/pamphlet/violent_video_games = pick("[initial(name)] for the truth about the arcade centcom doesn't want to hear","[initial(name)] full of studies", "IMPORTANT: READ THIS BEFORE GAMING TONIGHT"),
		/obj/item/paper/fluff/junkmail_redpill = pick("[initial(name)] for those feeling [pick(GLOB.adjectives)] working at Nanotrasen","\[REDACTED\] [initial(name)]", "[initial(name)] postmarked from the future"),
	)

	color = "#[pick(random_color())]" //eh, who gives a shit.
	switch(rand(1,10))
		if(1,2,3)
			name = special_name ? junk_names[junk] : "[pick("important","critical", "crucial", "serious", "vital")] [initial(name)]"
		if(4,5)
			name = special_name ? junk_names[junk] : "[initial(name)] for [pick(GLOB.alive_mob_list)]" //LETTER FOR IAN / BUBBLEGUM / MONKEY(420)
		if(6,7) //False Flag, generates a random super antagonist name to scare the crew and make metagaming far harder
			switch(pick("nuke", "ninja", "wizard", "nightmare", "ert", "clown", "devil", "xeno", "blob"))
				if("nuke")
					name = special_name ? junk_names[junk] : "[initial(name)] for [pick(GLOB.first_names)] [syndicate_name()]"
				if("ninja")
					name = special_name ? junk_names[junk] : "[initial(name)] for [pick(GLOB.ninja_titles)] [pick(GLOB.ninja_names)]"
				if("wizard")
					name = special_name ? junk_names[junk] : "[initial(name)] for [pick(GLOB.wizard_first)] [pick(GLOB.wizard_second)]"
				if("nightmare")
					name = special_name ? junk_names[junk] : "[initial(name)] for [pick(GLOB.nightmare_names)]"
				if("ert") //Death Squad too!
					name = special_name ? junk_names[junk] : "[initial(name)] for [pick("Security Officer", "Engineer", "Medical Officer", "Commander", "Trooper", "Chaplain", "Heavy Duty Janitor", "Intern", "Deathsquad Officer")] [pick(pick(GLOB.last_names), pick(GLOB.commando_names))]"
				if("clown")
					name = special_name ? junk_names[junk] : "[initial(name)] for [pick(GLOB.clown_names)]"
				if("devil")
					name = special_name ? junk_names[junk] : "[initial(name)] for [randomDevilName()]"
				if("xeno")
					name = special_name ? junk_names[junk] : "[initial(name)] for [pick("alien princess","alien hunter")] ([rand(1, 999)])"
				if("blob")
					name = special_name ? junk_names[junk] : "[initial(name)] for Blob Overmind ([rand(1, 999)])"
		if(8)
			name = special_name ? junk_names[junk] : "[initial(name)] for [pick(GLOB.player_list)]" //Letter for ANYONE, even that wizard rampaging through the station.
		if(9)
			name = special_name ? junk_names[junk] : "DO NOT OPEN"
		if(10)
			name = special_name ? junk_names[junk] : "[pick("important","critical", "crucial", "serious", "vital")] [initial(name)]" // ONE IN TEN TO GET STUFF FROM JUNK
			if(!special_name)
				junk = pick(generic_goodies)


	junk = new junk(src)
	return TRUE

/obj/item/mail/proc/disposal_handling(disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER
	if(!hasmob)
		disposal_holder.destinationTag = sort_tag

/// Subtype that's always junkmail
/obj/item/mail/junkmail/Initialize()
	. = ..()
	junk_mail()

/// Crate for mail from CentCom.
/obj/structure/closet/crate/mail
	name = "mail crate"
	desc = "A certified post crate from CentCom."
	icon = 'monkestation/icons/obj/mail_crates.dmi'
	icon_state = "mail"

/// Fills this mail crate with N pieces of mail, where N is the lower of the amount var passed, and the maximum capacity of this crate. If N is larger than the number of alive human players, the excess will be junkmail.
/obj/structure/closet/crate/mail/proc/populate(amount)
	var/mail_count = min(amount, storage_capacity)
	// Fills the
	var/list/mail_recipients = list()

	for(var/mob/living/carbon/human/human in GLOB.player_list)
		if(human.stat == DEAD || !human.mind)
			continue
		// Skip wizards, nuke ops, cyborgs; Centcom does not send them ACTUAL mail
		// They 'get' junk mail rarely.
		if(!SSjob.GetJob(human.mind.assigned_role) || (human.mind.assigned_role in GLOB.nonhuman_positions))
			continue

		mail_recipients += human.mind

	if(mail_count < 15)
		for(var/i in 1 to rand(1,3))
			var/obj/item/mail/new_mail
			if(prob(FULL_CRATE_LETTER_ODDS))
				new_mail = new /obj/item/mail(src)
			else
				new_mail = new /obj/item/mail/envelope(src)
			new_mail.junk_mail()

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
/obj/structure/closet/crate/mail/economy/Initialize()
	. = ..()
	populate(SSeconomy.mail_waiting)
	SSeconomy.mail_waiting = 0

/// Crate for mail that automatically generates a lot of mail. Usually only normal mail, but on lowpop it may end up just being junk.
/obj/structure/closet/crate/mail/full
	name = "brimming mail crate"
	desc = "A certified post crate from CentCom. Looks stuffed to the gills."

/obj/structure/closet/crate/mail/full/Initialize()
	. = ..()
	populate(INFINITY)

/obj/structure/closet/crate/mail/attack_hand(mob/user)
	. = ..()
	if(opened)
		icon_state = "mailopen"
		if(locate(/obj/item/mail) in src.contents)
			icon_state = "mail"
	else
		icon_state = "mailsealed"

/obj/structure/closet/crate/mail/verb_toggleopen()
	return attack_hand(usr)

/// Mailbag.
/obj/item/storage/bag/mail
	name = "mail bag"
	desc = "A banana themed mail bag. \"Banana Mail, we slip your mail faster than a meth addicted monkey.\" "
	icon = 'monkestation/icons/obj/mail.dmi'
	icon_state = "mailbag"
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/mail/ComponentInitialize()
	. = ..()
	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	storage.max_w_class = WEIGHT_CLASS_SMALL
	storage.max_combined_w_class = 30
	storage.max_items = 30
	storage.display_numerical_stacking = FALSE
	storage.can_hold = typecacheof(list(/obj/item/mail, /obj/item/smallDelivery, /obj/item/paper))

/obj/item/paper/fluff/junkmail_redpill
	name = "smudged paper"
	icon_state = "paper"
	var/nuclear_option_odds = 0.1

/obj/item/paper/fluff/junkmail_redpill/Initialize()
	. = ..()
	if(!prob(nuclear_option_odds)) // 1 in 1000 chance of getting 2 random nuke code characters.
		info = "<i>You need to escape the simulation. Don't forget the numbers, they help you remember:</i> '[rand(0,9)][rand(0,9)][rand(0,9)]...'"
		return
	var/code = random_nukecode()
	for(var/obj/machinery/nuclearbomb/selfdestruct/self_destruct in GLOB.nuke_list)
		self_destruct.r_code = code
		message_admins("Through junkmail, the self-destruct code was set to \"[code]\".")
	info = "<i>You need to escape the simulation. Don't forget the numbers, they help you remember:</i> '[code[rand(1,5)]][code[rand(1,5)]]...'"

/obj/item/paper/fluff/junkmail_redpill/true //admin letter enabling players to brute force their way through the nuke code if they're so inclined.
	nuclear_option_odds = 100

/obj/item/paper/fluff/junkmail_generic
	name = "important document"
	icon_state = "paper"

/obj/item/paper/fluff/junkmail_generic/Initialize()
	. = ..()
	info = pick(GLOB.junkmail_messages)
