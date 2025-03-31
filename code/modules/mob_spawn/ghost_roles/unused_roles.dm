
//i couldn't find any map that uses these, so they're delegated to admin events for now.

/obj/effect/mob_spawn/ghost_role/human/prisoner_transport
	name = "prisoner containment sleeper"
	desc = "A sleeper designed to put its occupant into a deep coma, unbreakable until the sleeper turns off. This one's glass is cracked and you can see a pale, sleeping face staring out."
	prompt_name = "an escaped prisoner"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	outfit = /datum/outfit/lavalandprisoner
	you_are_text = "You're a prisoner, sentenced to hard work in one of Nanotrasen's labor camps, but it seems as \
	though fate has other plans for you."
	flavour_text = "Good. It seems as though your ship crashed. You remember that you were convicted of "
	spawner_job_path = /datum/job/escaped_prisoner

/obj/effect/mob_spawn/ghost_role/human/prisoner_transport/Initialize(mapload)
	. = ..()
	var/list/crimes = list("murder", "larceny", "embezzlement", "unionization", "dereliction of duty", "kidnapping", "gross incompetence", "grand theft", "collaboration with the Syndicate", \
	"worship of a forbidden deity", "interspecies relations", "mutiny")
	flavour_text += "[pick(crimes)]. but regardless of that, it seems like your crime doesn't matter now. You don't know where you are, but you know that it's out to kill you, and you're not going \
	to lose this opportunity. Find a way to get out of this mess and back to where you rightfully belong - your [pick("house", "apartment", "spaceship", "station")]."

/obj/effect/mob_spawn/ghost_role/human/prisoner_transport/Destroy()
	new /obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	return ..()

/obj/effect/mob_spawn/ghost_role/human/prisoner_transport/special(mob/living/carbon/human/spawned_human)
	. = ..()
	spawned_human.fully_replace_character_name(null, "NTP #LL-0[rand(111,999)]") //Nanotrasen Prisoner #Lavaland-(numbers)

/datum/outfit/lavalandprisoner
	name = "Lavaland Prisoner"
	uniform = /obj/item/clothing/under/rank/prisoner
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/sneakers/orange
	r_pocket = /obj/item/tank/internals/emergency_oxygen


//spawners for the space hotel, which isn't currently in the code but heyoo secret away missions or something

//Space Hotel Staff
/obj/effect/mob_spawn/ghost_role/human/hotel_staff //not free antag u little shits
	name = "staff sleeper"
	desc = "A sleeper designed for long-term stasis between guest visits."
	prompt_name = "a hotel staff member"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	outfit = /datum/outfit/hotelstaff
	you_are_text = "You are a staff member of a top-of-the-line space hotel!"
	flavour_text = "Cater to visiting guests with your fellow staff, advertise the hotel, and make sure the manager doesn't fire you. Remember, the customer is always right!"
	important_text = "Do NOT leave the hotel, as that is grounds for contract termination."
	spawner_job_path = /datum/job/hotel_staff

/datum/outfit/hotelstaff
	name = "Hotel Staff"
	uniform = /obj/item/clothing/under/misc/assistantformal
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/radio/off

	implants = list(
		/obj/item/implant/exile/noteleport,
		/obj/item/implant/mindshield,
	)

/obj/effect/mob_spawn/ghost_role/human/hotel_staff/security
	name = "hotel security sleeper"
	prompt_name = "a hotel security member"
	outfit = /datum/outfit/hotelstaff/security
	you_are_text = "You are a peacekeeper."
	flavour_text = "You have been assigned to this hotel to protect the interests of the company while keeping the peace between \
		guests and the staff."
	important_text = "Do NOT leave the hotel, as that is grounds for contract termination."

/datum/outfit/hotelstaff/security
	name = "Hotel Security"
	uniform = /obj/item/clothing/under/rank/security/officer/blueshirt
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security/full
	head = /obj/item/clothing/head/helmet/blueshirt
	shoes = /obj/item/clothing/shoes/jackboots

/obj/effect/mob_spawn/ghost_role/human/hotel_staff/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	return ..()

/obj/effect/mob_spawn/ghost_role/human/syndicate
	name = "Syndicate Operative"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	prompt_name = "a syndicate operative"
	you_are_text = "You are a syndicate operative."
	flavour_text = "You have awoken, without instruction. Death to Nanotrasen! If there are some clues around as to what you're supposed to be doing, you best follow those."
	outfit = /datum/outfit/syndicate_empty
	spawner_job_path = /datum/job/space_syndicate

/datum/outfit/syndicate_empty
	name = "Syndicate Operative Empty"
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative
	uniform = /obj/item/clothing/under/syndicate
	back = /obj/item/storage/backpack
	ears = /obj/item/radio/headset/syndicate/alt
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	shoes = /obj/item/clothing/shoes/combat

	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/syndicate_empty/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_SYNDICATE

//For ghost bar.
/obj/effect/mob_spawn/ghost_role/human/space_bar_patron
	name = "bar cryogenics"
	uses = INFINITY
	prompt_name = "a space bar patron"
	you_are_text = "You're a patron!"
	flavour_text = "Hang out at the bar and chat with your buddies. Feel free to hop back in the cryogenics when you're done chatting."
	outfit = /datum/outfit/cryobartender
	spawner_job_path = /datum/job/space_bar_patron

/obj/effect/mob_spawn/ghost_role/human/space_bar_patron/attack_hand(mob/user, list/modifiers)
	var/despawn = tgui_alert(usr, "Return to cryosleep? (Warning, Your mob will be deleted!)", null, list("Yes", "No"))
	if(despawn == "No" || !loc || !Adjacent(user))
		return
	user.visible_message(span_notice("[user.name] climbs back into cryosleep..."))
	qdel(user)

/datum/outfit/cryobartender
	name = "Cryogenic Bartender"
	neck = /obj/item/clothing/neck/bowtie
	uniform = /obj/item/clothing/under/costume/buttondown/slacks/service
	suit = /obj/item/clothing/suit/armor/vest
	back = /obj/item/storage/backpack
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	shoes = /obj/item/clothing/shoes/sneakers/black

//Timeless prisons: Spawns in Wish Granter prisons in lavaland. Ghosts become age-old users of the Wish Granter and are advised to seek repentance for their past.
/obj/effect/mob_spawn/ghost_role/human/exile
	name = "timeless prison"
	desc = "Although this stasis pod looks medicinal, it seems as though it's meant to preserve something for a very long time."
	prompt_name = "a penitent exile"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_species = /datum/species/shadow
	you_are_text = "You are cursed."
	flavour_text = "Years ago, you sacrificed the lives of your trusted friends and the humanity of yourself to reach the Wish Granter. Though you \
	did so, it has come at a cost: your very body rejects the light, dooming you to wander endlessly in this horrible wasteland."
	spawner_job_path = /datum/job/exile

/obj/effect/mob_spawn/ghost_role/human/exile/Destroy()
	new/obj/structure/fluff/empty_sleeper(get_turf(src))
	return ..()

/obj/effect/mob_spawn/ghost_role/human/exile/special(mob/living/new_spawn)
	. = ..()
	new_spawn.fully_replace_character_name(null,"Wish Granter's Victim ([rand(1,999)])")
	var/wish = rand(1,4)
	var/message = ""
	switch(wish)
		if(1)
			message = "<b>You wished to kill, and kill you did. You've lost track of how many, but the spark of excitement that murder once held has winked out. You feel only regret.</b>"
		if(2)
			message = "<b>You wished for unending wealth, but no amount of money was worth this existence. Maybe charity might redeem your soul?</b>"
		if(3)
			message = "<b>You wished for power. Little good it did you, cast out of the light. You are the [gender == MALE ? "king" : "queen"] of a hell that holds no subjects. You feel only remorse.</b>"
		if(4)
			message = "<b>You wished for immortality, even as your friends lay dying behind you. No matter how many times you cast yourself into the lava, you awaken in this room again within a few days. There is no escape.</b>"
	to_chat(new_spawn, span_infoplain("[message]"))

/obj/effect/mob_spawn/ghost_role/human/nanotrasensoldier
	name = "sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	faction = list(FACTION_NANOTRASEN_PRIVATE)
	prompt_name = "a private security officer"
	you_are_text = "You are a Nanotrasen Private Security Officer!"
	flavour_text = "If higher command has an assignment for you, it's best you follow that. Otherwise, death to The Syndicate."
	outfit = /datum/outfit/nanotrasensoldier

/obj/effect/mob_spawn/ghost_role/human/commander
	name = "sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "a nanotrasen commander"
	you_are_text = "You are a Nanotrasen Commander!"
	flavour_text = "Upper-crusty of Nanotrasen. You should be given the respect you're owed."
	outfit = /datum/outfit/nanotrasencommander

//space doctor, a rat with cancer, and bessie from an old removed lavaland ruin.

/obj/effect/mob_spawn/ghost_role/human/doctor
	name = "sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "a space doctor"
	you_are_text = "You are a space doctor!"
	flavour_text = "It's your job- no, your duty as a doctor, to care and heal those in need."
	outfit = /datum/outfit/job/doctor
	spawner_job_path = /datum/job/space_doctor

/obj/effect/mob_spawn/ghost_role/human/doctor/alive/equip(mob/living/carbon/human/doctor)
	. = ..()
	// Remove radio and PDA so they wouldn't annoy station crew.
	var/list/del_types = list(/obj/item/modular_computer/pda, /obj/item/radio/headset)
	for(var/del_type in del_types)
		var/obj/item/unwanted_item = locate(del_type) in doctor
		qdel(unwanted_item)

/obj/effect/mob_spawn/ghost_role/mouse
	name = "sleeper"
	mob_type = /mob/living/basic/mouse
	prompt_name = "a mouse"
	you_are_text = "You're a mouse!"
	flavour_text = "Uh... yep! Squeak squeak, motherfucker."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/ghost_role/cow
	name = "sleeper"
	mob_name = "Bessie"
	mob_type = /mob/living/basic/cow
	prompt_name = "a cow"
	you_are_text = "You're a cow!"
	flavour_text = "Go graze some grass, stinky."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/cow/special(mob/living/spawned_mob)
	. = ..()
	gender = FEMALE

// snow operatives on snowdin - unfortunately seemingly removed in a map remake womp womp

/obj/effect/mob_spawn/ghost_role/human/snow_operative
	name = "sleeper"
	prompt_name = "a snow operative"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	faction = list(ROLE_SYNDICATE)
	outfit = /datum/outfit/snowsyndie
	you_are_text = "You are a syndicate operative recently awoken from cryostasis in an underground outpost."
	flavour_text = "Monitor Nanotrasen communications and record information. All intruders should be disposed of \
	swiftly to assure no gathered information is stolen or lost. Try not to wander too far from the outpost as the \
	caves can be a deadly place even for a trained operative such as yourself."

/datum/outfit/snowsyndie
	name = "Syndicate Snow Operative"
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative
	uniform = /obj/item/clothing/under/syndicate/coldres
	ears = /obj/item/radio/headset/syndicate/alt
	shoes = /obj/item/clothing/shoes/combat/coldres
	r_pocket = /obj/item/gun/ballistic/automatic/pistol

	implants = list(/obj/item/implant/exile)

//Forgotten syndicate ship

/obj/effect/mob_spawn/ghost_role/human/syndicatespace
	name = "Syndicate Ship Crew Member"
	show_flavor = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	prompt_name = "cybersun crew"
	you_are_text = "You are a syndicate operative on old ship, stuck in hostile space."
	flavour_text = "Your ship docks after a long time somewhere in hostile space, reporting a malfunction. You are stuck here, with Nanotrasen station nearby. Fix the ship, find a way to power it and follow your captain's orders."
	important_text = "Obey orders given by your captain. DO NOT let the ship fall into enemy hands."
	outfit = /datum/outfit/syndicatespace/syndicrew
	spawner_job_path = /datum/job/syndicate_cybersun

/obj/effect/mob_spawn/ghost_role/human/syndicatespace/special(mob/living/new_spawn)
	. = ..()
	new_spawn.grant_language(/datum/language/codespeak, source = LANGUAGE_MIND)
	var/datum/job/spawn_job = SSjob.get_job_type(spawner_job_path)
	var/policy = get_policy(spawn_job.policy_index)
	if(policy)
		to_chat(new_spawn, span_bold("[policy]"))

/obj/effect/mob_spawn/ghost_role/human/syndicatespace/captain
	name = "Syndicate Ship Captain"
	prompt_name = "a cybersun captain"
	you_are_text = "You are the captain of an old ship, stuck in hostile space."
	flavour_text = "Your ship docks after a long time somewhere in hostile space, reporting a malfunction. You are stuck here, with Nanotrasen station nearby. Command your crew and turn your ship into the most protected fortress."
	important_text = "Protect the ship and secret documents in your backpack with your own life."
	outfit = /datum/outfit/syndicatespace/syndicaptain
	spawner_job_path = /datum/job/syndicate_cybersun_captain

/obj/effect/mob_spawn/ghost_role/human/syndicatespace/captain/Destroy()
	new /obj/structure/fluff/empty_sleeper/syndicate/captain(get_turf(src))
	return ..()

/datum/outfit/syndicatespace
	name = "Syndicate Ship Base"
	id = /obj/item/card/id/advanced/black/syndicate_command/crew_id
	uniform = /obj/item/clothing/under/syndicate/combat
	back = /obj/item/storage/backpack
	belt = /obj/item/storage/belt/military/assault
	ears = /obj/item/radio/headset/syndicate/alt
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat

	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/syndicatespace/post_equip(mob/living/carbon/human/syndie_scum)
	syndie_scum.faction |= ROLE_SYNDICATE

/datum/outfit/syndicatespace/syndicrew
	name = "Syndicate Ship Crew Member"
	glasses = /obj/item/clothing/glasses/night/colorless
	mask = /obj/item/clothing/mask/gas/syndicate
	l_pocket = /obj/item/gun/ballistic/automatic/pistol
	r_pocket = /obj/item/knife/combat/survival

/datum/outfit/syndicatespace/syndicaptain
	name = "Syndicate Ship Captain"
	id = /obj/item/card/id/advanced/black/syndicate_command/captain_id
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	ears = /obj/item/radio/headset/syndicate/alt/leader
	head = /obj/item/clothing/head/hats/hos/beret/syndicate
	r_pocket = /obj/item/knife/combat/survival
	backpack_contents = list(
		/obj/item/documents/syndicate/red,
		/obj/item/gun/ballistic/automatic/pistol/aps,
		/obj/item/paper/fluff/ruins/forgottenship/password,
	)

/obj/effect/mob_spawn/ghost_role/human/mail_ghoul
	name = "ominous package"
	icon = 'icons/obj/storage/wrapping.dmi'
	icon_state = "deliverypackage5"
	prompt_name = "a mail ghoul"
	you_are_text = "You are the mail ghoul!"
	flavour_text = "You are the mail ghoul, a former mail carrier who fell into the depths of central command's mailroom. \
		You have escaped, and now - corrupted by the endless waves of paper, stamps, and spam - you seek to deliver people... to the afterlife!... \
		If they neglect the four digit code on the destination address or forget to sign for their package. Otherwise you just wanna get back to work."
	outfit = /datum/outfit/mail_ghoul
	mob_species = /datum/species/zombie
	hairstyle = /datum/sprite_accessory/hair/bald::name
	facial_hairstyle = /datum/sprite_accessory/facial_hair/shaved::name
	var/polling = FALSE

/obj/effect/mob_spawn/ghost_role/human/mail_ghoul/attack_ghost(mob/dead/observer/user)
	if(!polling)
		return ..()
	to_chat(user, span_warning("The mail ghoul is being polled for."))

/obj/effect/mob_spawn/ghost_role/human/mail_ghoul/proc/do_poll()
	set waitfor = FALSE

	if(polling)
		return

	polling = TRUE
	notify_ghosts(
		"A mail ghoul has arrived!",
		source = src,
		header = "Delivery",
	)
	var/mob/ghost = SSpolling.poll_ghosts_for_target(
		question = "Do you want to play as the mail ghoul?",
		check_jobban = ROLE_SYNDICATE,
		poll_time = 20 SECONDS,
		checked_target = src,
		alert_pic = src,
		role_name_text = "mail ghoul",
	)
	if(isnull(ghost))
		polling = FALSE
		if(iscloset(loc))
			RegisterSignal(loc, COMSIG_CLOSET_POST_OPEN, PROC_REF(del_package))
		return
	create_from_ghost(ghost)

/obj/effect/mob_spawn/ghost_role/human/mail_ghoul/proc/del_package(datum/source, mob/user)
	SIGNAL_HANDLER
	to_chat(user, span_warning("You feel an ominous aura from [source], but there's nothing out of the ordinary inside."))
	qdel(src)

/obj/effect/mob_spawn/ghost_role/human/mail_ghoul/create(mob/mob_possessor, newname)
	var/mob/living/spawned_mob = ..()
	for(var/obj/structure/closet/box in spawned_mob.loc)
		spawned_mob.set_resting(TRUE, instant = TRUE)
		spawned_mob.forceMove(box)
		spawned_mob.AddComponent(/datum/component/block_walking_out_early, box)
		spawned_mob.set_resting(FALSE, silent = FALSE)
		var/obj/item/satchel = spawned_mob.get_item_by_slot(ITEM_SLOT_BELT)
		for(var/obj/item/mail/mail in box)
			if(prob(50) && length(satchel?.contents) < 7)
				mail.forceMove(satchel)
		break
	return spawned_mob

/obj/effect/mob_spawn/ghost_role/human/mail_ghoul/equip(mob/living/spawned_mob)
	. = ..()
	for(var/obj/item/equipment in spawned_mob.get_equipped_items())
		ADD_TRAIT(equipment, TRAIT_NODROP, INNATE_TRAIT)
	var/obj/item/clothing/under/mailsuit = spawned_mob.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	if(istype(mailsuit))
		mailsuit.has_sensor = BROKEN_SENSORS
		mailsuit.sensor_mode = SENSOR_OFF
		mailsuit.update_wearer_status()

/obj/effect/mob_spawn/ghost_role/human/mail_ghoul/special(mob/living/carbon/human/spawned_mob, mob/mob_possessor)
	. = ..()
	var/datum/antagonist/ghoul = new()
	ghoul.silent = TRUE
	ghoul.name = "Mail Ghoul"
	var/datum/objective/rip = new()
	rip.no_failure = TRUE
	rip.explanation_text = "Maul whoever opens your crate."
	ghoul.objectives += rip
	var/datum/objective/tear = new()
	tear.no_failure = TRUE
	tear.explanation_text = "Deliver the former mail carrier's body to someone. \
		Good choices include the coroner, the detective, the quartermaster, or the chaplain."
	ghoul.objectives += tear
	var/datum/objective/until_it_is_done = new()
	until_it_is_done.no_failure = TRUE
	until_it_is_done.explanation_text = "Take over as the station's new mail carrier. \
		If anyone forgets to pick up their package, remind them... With force if necessary. But try words first."
	ghoul.objectives += until_it_is_done

	ADD_TRAIT(spawned_mob, TRAIT_HULK, INNATE_TRAIT)
	ADD_TRAIT(spawned_mob, TRAIT_STRONG_GRABBER, INNATE_TRAIT)
	ADD_TRAIT(spawned_mob, TRAIT_CHUNKYFINGERS, INNATE_TRAIT)
	spawned_mob.add_movespeed_mod_immunities(INNATE_TRAIT, /datum/movespeed_modifier/damage_slowdown)
	spawned_mob.mind.add_antag_datum(ghoul)
	spawned_mob.AddComponent(/datum/component/strong_pull)
	spawned_mob.AddComponent( \
		/datum/component/mutant_hands, \
		mutant_hand_path = /obj/item/mutant_hand/mailghoul, \
		ignored = LEFT_HANDS, \
	)
	spawned_mob.AddComponent( \
		/datum/component/regenerator, \
		regeneration_delay = 4 SECONDS, \
		brute_per_second = 0.25, \
		burn_per_second = 0.25, \
		tox_per_second = 0.1, \
		oxy_per_second = 0.5, \
		heals_wounds = TRUE, \
	)
	for(var/obj/item/bodypart/leg in spawned_mob.bodyparts)
		leg.speed_modifier = 0.95
	spawned_mob.update_bodypart_speed_modifier()
	// my antag will have stun immunity and god mode and
	spawned_mob.physiology.stun_mod *= 0.25
	spawned_mob.physiology.stamina_mod *= 0.25
	spawned_mob.physiology.knockdown_mod *= (1.5 * (1 / spawned_mob.physiology.stun_mod)) // stunmod applies to knockdowns
	spawned_mob.physiology.damage_resistance = 33
	spawned_mob.set_combat_mode(TRUE)

	var/obj/item/organ/tongue/ghoul/tongue = new()
	tongue.Insert(spawned_mob, movement_flags = DELETE_IF_REPLACED)

	spawned_mob.grant_language(/datum/language/uncommon, source = LANGUAGE_MIND)
	spawned_mob.grant_language(/datum/language/common, source = LANGUAGE_MIND)

/datum/outfit/mail_ghoul
	name = "Mail Ghoul"
	id = /obj/item/card/id/advanced/mailman
	uniform = /obj/item/clothing/under/misc/mailman
	head = /obj/item/clothing/head/costume/mailman
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	ears = /obj/item/radio/headset
	belt = /obj/item/storage/bag/mail
	back = /obj/item/storage/backpack/satchel/leather

/obj/item/card/id/advanced/mailman
	name = "mail carrier ID"
	desc = "An ID card for a mail carrier. Looks quite dated."
	trim = /datum/id_trim/job/cargo_technician

/obj/item/card/id/advanced/mailman/Initialize(mapload)
	. = ..()
	registered_age = rand(40, 80)
	assignment = "Mail Carrier"
	update_label()

/obj/item/mutant_hand/mailghoul
	name = "mail ghoul claw"
	desc = "A clawed hand, once capable of delivering mail, now capable of delivering death... AND mail."
	hitsound = 'sound/effects/hallucinations/growl1.ogg'
	force = 16
	demolition_mod = 1.5
	wound_bonus = -30
	bare_wound_bonus = 30
	sharpness = SHARP_EDGED
	obj_flags = CONDUCTS_ELECTRICITY

/obj/item/organ/tongue/ghoul
	name = "ghoul tongue"
	desc = "I'm here to pick up an order. Two large pepperoni and a calzone. Name is \"Fuck you.\""
	icon_state = "tonguezombie"
	say_mod = "moans"
	modifies_speech = TRUE
	taste_sensitivity = 32
	liked_foodtypes = MEAT | GRAIN | VEGETABLES | DAIRY
	disliked_foodtypes = NONE

/obj/item/organ/tongue/ghoul/modify_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	var/list/words = splittext(message, " ")
	var/list/new_sentence = list()
	for(var/word in words)
		switch(copytext_char(word, -1))
			if("!", ".", "?")
				word += ".."
			else
				if(word == words[length(words)])
					word += "..."

		new_sentence += word
	speech_args[SPEECH_MESSAGE] = jointext(new_sentence, " ")

/datum/component/block_walking_out_early
	COOLDOWN_DECLARE(spam_cd)
	VAR_PRIVATE/obj/structure/closet/box

/datum/component/block_walking_out_early/Initialize(obj/structure/closet/box)
	. = ..()
	src.box = box
	RegisterSignal(box, COMSIG_CLOSET_PRE_OPEN, PROC_REF(block_walk))
	RegisterSignal(box, COMSIG_ATOM_EXITED, PROC_REF(someone_left))
	RegisterSignal(box, COMSIG_QDELETING, PROC_REF(qdel_us))
	addtimer(CALLBACK(src, PROC_REF(timeout)), 5 MINUTES, TIMER_DELETE_ME)

/datum/component/block_walking_out_early/Destroy()
	UnregisterSignal(box, list(
		COMSIG_CLOSET_PRE_OPEN,
		COMSIG_ATOM_EXITED,
		COMSIG_QDELETING,
	))
	box = null
	return ..()

/datum/component/block_walking_out_early/proc/block_walk(datum/source, mob/user)
	SIGNAL_HANDLER
	if(user != parent)
		return NONE
	if(COOLDOWN_FINISHED(src, spam_cd))
		to_chat(user, span_warning("I don't want to get up yet. It's comfy in here. 5 more minutes..."))
		COOLDOWN_START(src, spam_cd, 5 SECONDS)
	return BLOCK_OPEN

/datum/component/block_walking_out_early/proc/someone_left(datum/source, atom/gone)
	SIGNAL_HANDLER
	if(gone != parent)
		return
	qdel(src)

/datum/component/block_walking_out_early/proc/qdel_us(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/block_walking_out_early/proc/timeout()
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	to_chat(parent, span_red("Okay, is seriously NO ONE coming in to pick up the mail? Fine, I guess I'll go deliver it myself."))
	qdel(src)
