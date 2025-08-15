///This station traits gives 5 bananium sheets to the clown (and every dead clown out there in deep space or lavaland).
/datum/station_trait/bananium_shipment
	name = "Bananium Shipment"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	report_message = "Rumors has it that the clown planet has been sending support packages to clowns in this system."
	trait_to_give = STATION_TRAIT_BANANIUM_SHIPMENTS

/datum/station_trait/bananium_shipment/get_pulsar_message()
	var/advisory_string = "Advisory Level: <b>Clown Planet</b></center><BR>"
	advisory_string += "Your sector's advisory level is Clown Planet! Our bike horns have picked up on a large bananium stash. Clowns show a large influx of clowns on your station. We highly advise you to slip any threats to keep Honkotrasen assets within the Banana Sector. The Department of Intelligence advises defending chemistry from any clowns that are trying to make baldium or space lube."
	return advisory_string

/datum/station_trait/unnatural_atmosphere
	name = "Unnatural atmospherical properties"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE
	report_message = "System's local planet has irregular atmospherical properties."
	trait_to_give = STATION_TRAIT_UNNATURAL_ATMOSPHERE

	// This station trait modifies the atmosphere, which is too far past the time admins are able to revert it
	can_revert = FALSE

/datum/station_trait/spider_infestation
	name = "Spider Infestation"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	report_message = "We have introduced a natural countermeasure to reduce the number of rodents on board your station."
	trait_to_give = STATION_TRAIT_SPIDER_INFESTATION

/datum/station_trait/unique_ai
	name = "Unique AI"
	trait_type = STATION_TRAIT_NEUTRAL
	trait_flags = parent_type::trait_flags | STATION_TRAIT_REQUIRES_AI
	weight = 5
	show_in_report = TRUE
	report_message = "For experimental purposes, this station AI might show divergence from default lawset. Do not meddle with this experiment, we've removed \
		access to your set of alternative upload modules because we know you're already thinking about meddling with this experiment."
	trait_to_give = STATION_TRAIT_UNIQUE_AI

/datum/station_trait/unique_ai/on_round_start()
	. = ..()
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		ai.show_laws()

/datum/station_trait/ian_adventure
	name = "Ian's Adventure"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = FALSE
	cost = STATION_TRAIT_COST_LOW
	report_message = "Ian has gone exploring somewhere in the station."

/datum/station_trait/ian_adventure/on_round_start()
	for(var/mob/living/basic/pet/dog/corgi/dog in GLOB.mob_list)
		if(!(istype(dog, /mob/living/basic/pet/dog/corgi/ian) || istype(dog, /mob/living/basic/pet/dog/corgi/puppy/ian)))
			continue

		// Makes this station trait more interesting. Ian probably won't go anywhere without a little external help.
		// Also gives him a couple extra lives to survive eventual tiders.
		dog.deadchat_plays(DEMOCRACY_MODE|MUTE_DEMOCRACY_MESSAGES, 3 SECONDS)
		dog.AddComponent(/datum/component/multiple_lives, 2)
		RegisterSignal(dog, COMSIG_ON_MULTIPLE_LIVES_RESPAWN, PROC_REF(do_corgi_respawn))

		// The extended safety checks at time of writing are about chasms and lava
		// if there are any chasms and lava on stations in the future, woah
		var/turf/current_turf = get_turf(dog)
		var/turf/adventure_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

		// Poof!
		do_smoke(location=current_turf)
		dog.forceMove(adventure_turf)
		do_smoke(location=adventure_turf)

/// Moves the new dog somewhere safe, equips it with the old one's inventory and makes it deadchat_playable.
/datum/station_trait/ian_adventure/proc/do_corgi_respawn(mob/living/basic/pet/dog/corgi/old_dog, mob/living/basic/pet/dog/corgi/new_dog, gibbed, lives_left)
	SIGNAL_HANDLER

	var/turf/current_turf = get_turf(new_dog)
	var/turf/adventure_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

	do_smoke(location=current_turf)
	new_dog.forceMove(adventure_turf)
	do_smoke(location=adventure_turf)

	if(old_dog.inventory_back)
		var/obj/item/old_dog_back = old_dog.inventory_back
		old_dog.inventory_back = null
		old_dog_back.forceMove(new_dog)
		new_dog.inventory_back = old_dog_back

	if(old_dog.inventory_head)
		var/obj/item/old_dog_hat = old_dog.inventory_head
		old_dog.inventory_head = null
		new_dog.place_on_head(old_dog_hat)

	new_dog.update_corgi_fluff()
	new_dog.regenerate_icons()
	new_dog.deadchat_plays(DEMOCRACY_MODE|MUTE_DEMOCRACY_MESSAGES, 3 SECONDS)
	if(lives_left)
		RegisterSignal(new_dog, COMSIG_ON_MULTIPLE_LIVES_RESPAWN, PROC_REF(do_corgi_respawn))

	if(!gibbed) //The old dog will now disappear so we won't have more than one Ian at a time.
		qdel(old_dog)

/datum/station_trait/glitched_pdas
	name = "PDA glitch"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	cost = STATION_TRAIT_COST_MINIMAL
	report_message = "Something seems to be wrong with the PDAs issued to you all this shift. Nothing too bad though."
	trait_to_give = STATION_TRAIT_PDA_GLITCHED

/datum/station_trait/announcement_intern
	name = "Announcement Intern"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	report_message = "Please be nice to him."
	blacklist = list(/datum/station_trait/announcement_medbot, /datum/station_trait/birthday)

/datum/station_trait/announcement_intern/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/intern

/datum/station_trait/announcement_intern/get_pulsar_message()
	var/advisory_string = "Advisory Level: <b>(TITLE HERE)</b></center><BR>"
	advisory_string += "(Copy/Paste the summary provided by the Threat Intelligence Office in this field. You shouldn't have any trouble with this just make sure to replace this message before hitting the send button. Also, make sure there's coffee ready for the meeting at 06:00 when you're done.)"
	return advisory_string

/datum/station_trait/announcement_medbot
	name = "Announcement \"System\""
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	report_message = "Our announcement system is under scheduled maintanance at the moment. Thankfully, we have a backup."
	blacklist = list(/datum/station_trait/announcement_intern, /datum/station_trait/birthday)

/datum/station_trait/announcement_medbot/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/medbot

/datum/station_trait/colored_assistants
	name = "Colored Assistants"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 10
	show_in_report = TRUE
	cost = STATION_TRAIT_COST_MINIMAL
	report_message = "Due to a shortage in standard issue jumpsuits, we have provided your assistants with one of our backup supplies."
	blacklist = list(/datum/station_trait/assistant_gimmicks)

/datum/station_trait/colored_assistants/New()
	. = ..()

	var/new_colored_assistant_type = pick(subtypesof(/datum/colored_assistant) - get_configured_colored_assistant_type())
	GLOB.colored_assistant = new new_colored_assistant_type

/datum/station_trait/birthday
	name = "Employee Birthday"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 2
	show_in_report = TRUE
	report_message = "We here at Nanotrasen would all like to wish Employee Name a very happy birthday"
	trait_to_give = STATION_TRAIT_BIRTHDAY
	blacklist = list(/datum/station_trait/announcement_intern, /datum/station_trait/announcement_medbot) //Overiding the annoucer hides the birthday person in the annoucement message.
	///Variable that stores a reference to the person selected to have their birthday celebrated.
	var/mob/living/carbon/human/birthday_person
	///Variable that holds the real name of the birthday person once selected, just incase the birthday person's real_name changes.
	var/birthday_person_name = ""
	///Variable that admins can override with a player's ckey in order to set them as the birthday person when the round starts.
	var/birthday_override_ckey

/datum/station_trait/birthday/New()
	. = ..()
	RegisterSignals(SSdcs, list(COMSIG_GLOB_JOB_AFTER_SPAWN), PROC_REF(on_job_after_spawn))

/datum/station_trait/birthday/revert()
	for (var/obj/effect/landmark/start/hangover/party_spot in GLOB.start_landmarks_list)
		QDEL_LIST(party_spot.party_debris)
	return ..()

/datum/station_trait/birthday/on_round_start()
	. = ..()
	if(birthday_override_ckey)
		if(!check_valid_override())
			message_admins("Attempted to make [birthday_override_ckey] the birthday person but they are not a valid station role. A random birthday person has be selected instead.")

	if(!birthday_person)
		var/list/birthday_options = list()
		for(var/mob/living/carbon/human/human in GLOB.human_list)
			if(human.mind?.assigned_role.job_flags & JOB_CREW_MEMBER)
				birthday_options += human
		if(length(birthday_options))
			birthday_person = pick(birthday_options)
			birthday_person_name = birthday_person.real_name
			ADD_TRAIT(birthday_person, TRAIT_BIRTHDAY_BOY, REF(src))
	addtimer(CALLBACK(src, PROC_REF(announce_birthday)), 10 SECONDS)

/datum/station_trait/birthday/proc/check_valid_override()

	var/mob/living/carbon/human/birthday_override_mob = get_mob_by_ckey(birthday_override_ckey)

	if(isnull(birthday_override_mob))
		return FALSE

	if(birthday_override_mob.mind?.assigned_role.job_flags & JOB_CREW_MEMBER)
		birthday_person = birthday_override_mob
		birthday_person_name = birthday_person.real_name
		return TRUE
	else
		return FALSE


/datum/station_trait/birthday/proc/announce_birthday()
	report_message = "We here at Nanotrasen would all like to wish [birthday_person ? birthday_person_name : "Employee Name"] a very happy birthday."
	priority_announce("Happy birthday to [birthday_person ? birthday_person_name : "Employee Name"]! Nanotrasen wishes you a very happy [birthday_person ? thtotext(birthday_person.age + 1) : "255th"] birthday.")
	if(birthday_person)
		playsound(birthday_person, 'sound/items/party_horn.ogg', 50)
		birthday_person.add_mood_event("birthday", /datum/mood_event/birthday)
		birthday_person = null

/datum/station_trait/birthday/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned_mob)
	SIGNAL_HANDLER

	var/obj/item/hat = pick_weight(list(
		/obj/item/clothing/head/costume/party/festive = 12,
		/obj/item/clothing/head/costume/party = 12,
		/obj/item/clothing/head/costume/festive = 2,
		/obj/item/clothing/head/utility/hardhat/cakehat = 1,
	))
	hat = new hat(spawned_mob)
	if(!spawned_mob.equip_to_slot_if_possible(hat, ITEM_SLOT_HEAD, disable_warning = TRUE))
		spawned_mob.equip_to_storage(hat, ITEM_SLOT_BACK, indirect_action = TRUE)
	var/obj/item/toy = pick_weight(list(
		/obj/item/reagent_containers/spray/chemsprayer/party = 4,
		/obj/item/toy/balloon = 2,
		/obj/item/sparkler = 2,
		/obj/item/clothing/mask/party_horn = 2,
		/obj/item/storage/box/tail_pin = 1,
	))
	toy = new toy(spawned_mob)
	if(istype(toy, /obj/item/toy/balloon))
		spawned_mob.equip_to_slot_or_del(toy, ITEM_SLOT_HANDS) //Balloons do not fit inside of backpacks.
	else
		spawned_mob.equip_to_storage(toy, ITEM_SLOT_BACK, indirect_action = TRUE)
	if(birthday_person_name) //Anyone who joins after the annoucement gets one of these.
		var/obj/item/birthday_invite/birthday_invite = new(spawned_mob)
		birthday_invite.setup_card(birthday_person_name)
		if(!spawned_mob.equip_to_slot_if_possible(birthday_invite, ITEM_SLOT_HANDS, disable_warning = TRUE))
			spawned_mob.equip_to_storage(birthday_invite, ITEM_SLOT_BACK, indirect_action = TRUE) //Just incase someone spawns with both hands full.

/obj/item/birthday_invite
	name = "birthday invitation"
	desc = "A card stating that it's someone's birthday today."
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY

/obj/item/birthday_invite/proc/setup_card(birthday_name)
	desc = "A card stating that its [birthday_name]'s birthday today."
	icon_state = "paperslip_words"
	icon = 'icons/obj/service/bureaucracy.dmi'

/obj/item/clothing/head/costume/party
	name = "party hat"
	desc = "A crappy paper hat that you are REQUIRED to wear."
	icon_state = "party_hat"
	greyscale_config =  /datum/greyscale_config/party_hat
	greyscale_config_worn = /datum/greyscale_config/party_hat/worn
	flags_inv = 0
	armor_type = /datum/armor/none
	var/static/list/hat_colors = list(
		COLOR_PRIDE_RED,
		COLOR_PRIDE_ORANGE,
		COLOR_PRIDE_YELLOW,
		COLOR_PRIDE_GREEN,
		COLOR_PRIDE_BLUE,
		COLOR_PRIDE_PURPLE,
	)

/obj/item/clothing/head/costume/party/Initialize(mapload)
	set_greyscale(colors = list(pick(hat_colors)))
	return ..()

/obj/item/clothing/head/costume/party/festive
	name = "festive paper hat"
	icon_state = "xmashat_grey"
	greyscale_config = /datum/greyscale_config/festive_hat
	greyscale_config_worn = /datum/greyscale_config/festive_hat/worn

/datum/station_trait/scryers
	name = "Scryers"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 2
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE
	report_message = "Nanotrasen has chosen your station for an experiment - everyone has free scryers! Use these to talk to other people easily and privately."

/datum/station_trait/scryers/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/scryers/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	if(!ishuman(spawned))
		return
	var/mob/living/carbon/human/humanspawned = spawned
	// Put their silly little scarf or necktie somewhere else
	var/obj/item/silly_little_scarf = humanspawned.wear_neck
	if(silly_little_scarf)
		var/list/backup_slots = list(LOCATION_LPOCKET, LOCATION_RPOCKET, LOCATION_BACKPACK)
		humanspawned.temporarilyRemoveItemFromInventory(silly_little_scarf)
		silly_little_scarf.forceMove(get_turf(humanspawned))
		humanspawned.equip_in_one_of_slots(silly_little_scarf, backup_slots, qdel_on_fail = FALSE)

	var/obj/item/clothing/neck/link_scryer/loaded/new_scryer = new(spawned)
	new_scryer.label = spawned.name
	new_scryer.update_name()

	spawned.equip_to_slot_or_del(new_scryer, ITEM_SLOT_NECK, initial = FALSE)

/datum/station_trait/wallets
	name = "Wallets!"
	trait_type = STATION_TRAIT_NEUTRAL
	show_in_report = TRUE
	weight = 5
	cost = STATION_TRAIT_COST_MINIMAL
	report_message = "It has become temporarily fashionable to use a wallet, so everyone on the station has been issued one."

/datum/station_trait/wallets/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/wallets/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/living_mob, mob/M, joined_late)
	SIGNAL_HANDLER

	var/obj/item/card/id/advanced/id_card = living_mob.get_item_by_slot(ITEM_SLOT_ID)
	if(!istype(id_card))
		return

	living_mob.temporarilyRemoveItemFromInventory(id_card, force=TRUE)

	// "Doc, what's wrong with me?"
	var/obj/item/storage/wallet/wallet = new(src)
	// "You've got a wallet embedded in your chest."
	wallet.add_fingerprint(living_mob, ignoregloves = TRUE)

	living_mob.equip_to_slot_if_possible(wallet, ITEM_SLOT_ID, initial=TRUE)

	id_card.forceMove(wallet)

	var/holochip_amount = id_card.registered_account.account_balance
	new /obj/item/holochip(wallet, holochip_amount)
	id_card.registered_account.adjust_money(-holochip_amount, "System: Withdrawal")

	new /obj/effect/spawner/random/entertainment/wallet_storage(wallet)

	// Put our filthy fingerprints all over the contents
	for(var/obj/item/item in wallet)
		item.add_fingerprint(living_mob, ignoregloves = TRUE)

/// Tells the area map generator to ADD MORE TREEEES
/datum/station_trait/forested
	name = "Forested"
	trait_type = STATION_TRAIT_NEUTRAL
	trait_to_give = STATION_TRAIT_FORESTED
	trait_flags = STATION_TRAIT_PLANETARY
	weight = 10
	show_in_report = TRUE
	report_message = "There sure are a lot of trees out there."

/datum/station_trait/linked_closets
	name = "Closet Anomaly"
	trait_type = STATION_TRAIT_NEUTRAL
	show_in_report = TRUE
	weight = 1
	report_message = "We've reports of high amount of trace eigenstasium on your station. Ensure that your closets are working correctly."

/datum/station_trait/linked_closets/on_round_start()
	. = ..()
	var/list/roundstart_closets = GLOB.roundstart_station_closets.Copy()

	/**
	 * The number of links to perform. the chance of a closet being linked are about 1 in 10
	 * There are more than 220 roundstart closets on meta, so, about 22 closets will be affected on average.
	 */
	var/number_of_links = round(length(roundstart_closets) * (rand(400, 430)*0.0001), 1)
	for(var/repetition in 1 to number_of_links)
		var/list/targets = list()
		for(var/how_many in 1 to rand(2,3))
			targets += pick_n_take(roundstart_closets)
		GLOB.eigenstate_manager.create_new_link(targets)


#define PRO_SKUB "pro-skub"
#define ANTI_SKUB "anti-skub"
#define SKUB_IDFC "i don't frikkin' care"
#define RANDOM_SKUB null //This means that if you forgot to opt in/against/out, there's a 50/50 chance to be pro or anti

/// A trait that lets players choose whether they want pro-skub or anti-skub (or neither), and receive the appropriate equipment.
/datum/station_trait/skub
	name = "The Great Skub Contention"
	trait_type = STATION_TRAIT_NEUTRAL
	show_in_report = FALSE
	weight = 2
	sign_up_button = TRUE
	/// List of people signed up to be either pro_skub or anti_skub
	var/list/skubbers = list()

/datum/station_trait/skub/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/skub/setup_lobby_button(atom/movable/screen/lobby/button/sign_up/lobby_button)
	RegisterSignal(lobby_button, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_lobby_button_update_overlays))
	lobby_button.desc = "Are you pro-skub or anti-skub? Click to cycle through pro-skub, anti-skub, random and neutral."
	return ..()

/// Let late-joiners jump on this gimmick too.
/datum/station_trait/skub/can_display_lobby_button(client/player)
	return sign_up_button

/// We don't destroy buttons on round start for those who are still in the lobby.
/datum/station_trait/skub/on_round_start()
	return

/datum/station_trait/skub/on_lobby_button_update_icon(atom/movable/screen/lobby/button/sign_up/lobby_button, location, control, params, mob/dead/new_player/user)
	var/mob/player = lobby_button.get_mob()
	var/skub_stance = skubbers[player.ckey]
	switch(skub_stance)
		if(PRO_SKUB)
			lobby_button.base_icon_state = "signup_on"
		if(ANTI_SKUB)
			lobby_button.base_icon_state = "signup"
		else
			lobby_button.base_icon_state = "signup_neutral"

/datum/station_trait/skub/on_lobby_button_click(atom/movable/screen/lobby/button/sign_up/lobby_button, updates)
	var/mob/player = lobby_button.get_mob()
	var/skub_stance = skubbers[player.ckey]
	switch(skub_stance)
		if(PRO_SKUB)
			skubbers[player.ckey] = ANTI_SKUB
			lobby_button.balloon_alert(player, "anti-skub")
		if(ANTI_SKUB)
			skubbers[player.ckey] = SKUB_IDFC
			lobby_button.balloon_alert(player, "don't care")
		if(SKUB_IDFC)
			skubbers[player.ckey] = RANDOM_SKUB
			lobby_button.balloon_alert(player, "on the best side")
		if(RANDOM_SKUB)
			skubbers[player.ckey] = PRO_SKUB
			lobby_button.balloon_alert(player, "pro-skub")

/datum/station_trait/skub/proc/on_lobby_button_update_overlays(atom/movable/screen/lobby/button/sign_up/lobby_button, list/overlays)
	SIGNAL_HANDLER
	var/mob/player = lobby_button.get_mob()
	var/skub_stance = skubbers[player.ckey]
	switch(skub_stance)
		if(PRO_SKUB)
			overlays += "pro_skub"
		if(ANTI_SKUB)
			overlays += "anti_skub"
		if(SKUB_IDFC)
			overlays += "neutral_skub"
		if(RANDOM_SKUB)
			overlays += "random_skub"

/datum/station_trait/skub/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/skub_stance = skubbers[player_client.ckey]
	if(skub_stance == SKUB_IDFC)
		return

	if((skub_stance == RANDOM_SKUB && prob(50)) || skub_stance == PRO_SKUB)
		var/obj/item/storage/box/stickers/skub/boxie = new(spawned.loc)
		spawned.equip_to_storage(boxie, ITEM_SLOT_BACK, indirect_action = TRUE)
		if(ishuman(spawned))
			var/obj/item/clothing/suit/costume/wellworn_shirt/skub/shirt = new(spawned.loc)
			if(!spawned.equip_to_slot_if_possible(shirt, ITEM_SLOT_OCLOTHING, indirect_action = TRUE))
				shirt.forceMove(boxie)
		return

	var/obj/item/storage/box/stickers/anti_skub/boxie = new(spawned.loc)
	spawned.equip_to_storage(boxie, ITEM_SLOT_BACK, indirect_action = TRUE)
	if(!ishuman(spawned))
		return
	var/obj/item/clothing/suit/costume/wellworn_shirt/skub/anti/shirt = new(spawned.loc)
	if(!spawned.equip_to_slot_if_possible(shirt, ITEM_SLOT_OCLOTHING, indirect_action = TRUE))
		shirt.forceMove(boxie)

#undef PRO_SKUB
#undef ANTI_SKUB
#undef SKUB_IDFC
#undef RANDOM_SKUB

/// Crew don't ever spawn as enemies of the station. Obsesseds, blob infection, space changelings etc can still happen though
/datum/station_trait/background_checks
	name = "Station-Wide Background Checks"
	report_message = "We replaced the intern doing your crew's background checks with a trained screener for this shift! \
		That said, our enemies may just find another way to infiltrate the station, so be careful."
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	can_revert = FALSE

	dynamic_threat_id = "Background Checks"

/datum/station_trait/background_checks/New()
	. = ..()
	RegisterSignal(SSdynamic, COMSIG_DYNAMIC_PRE_ROUNDSTART, PROC_REF(modify_config))

/datum/station_trait/background_checks/proc/modify_config(datum/source, list/dynamic_config)
	SIGNAL_HANDLER

	for(var/datum/dynamic_ruleset/ruleset as anything in subtypesof(/datum/dynamic_ruleset))
		if(ruleset.ruleset_flags & RULESET_INVADER)
			continue
		dynamic_config[initial(ruleset.config_tag)] ||= list()
		dynamic_config[initial(ruleset.config_tag)][NAMEOF(ruleset, weight)] = 0

/datum/station_trait/pet_day
	name = "Bring Your Pet To Work Day"
	trait_type = STATION_TRAIT_NEUTRAL
	show_in_report = FALSE
	weight = 2
	sign_up_button = TRUE

/datum/station_trait/pet_day/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/pet_day/setup_lobby_button(atom/movable/screen/lobby/button/sign_up/lobby_button)
	lobby_button.desc = "Want to bring your innocent pet to a giant metal deathtrap? Click here to customize it!"
	RegisterSignal(lobby_button, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_lobby_button_update_overlays))
	return ..()

/datum/station_trait/pet_day/can_display_lobby_button(client/player)
	return sign_up_button

/datum/station_trait/pet_day/on_round_start()
	return

/datum/station_trait/pet_day/on_lobby_button_click(atom/movable/screen/lobby/button/sign_up/lobby_button, updates)
	var/mob/our_player = lobby_button.get_mob()
	var/client/player_client = our_player.client
	if(isnull(player_client))
		return
	var/datum/pet_customization/customization = GLOB.customized_pets[REF(player_client)]
	if(isnull(customization))
		customization = new(player_client)
	INVOKE_ASYNC(customization, TYPE_PROC_REF(/datum, ui_interact), our_player)

/datum/station_trait/pet_day/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/datum/pet_customization/customization = GLOB.customized_pets[REF(player_client)]
	if(isnull(customization))
		return
	INVOKE_ASYNC(customization, TYPE_PROC_REF(/datum/pet_customization, create_pet), spawned, player_client)

/datum/station_trait/pet_day/proc/on_lobby_button_update_overlays(atom/movable/screen/lobby/button/sign_up/lobby_button, list/overlays)
	overlays += "select_pet"

/// We're pulling a Jim Kramer with this one boys
/datum/station_trait/gmm_spotlight
	name = "GMM Economic Spotlight"
	report_message = "This shift, the Galactic Mineral Market is doing a showcase on your crew's affulence! Every paycheck, the station newscasters will alert the crew who has the most credits."
	trait_type = STATION_TRAIT_NEUTRAL
	trait_to_give = STATION_TRAIT_ECONOMY_ALERTS
	weight = 2
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE

	dynamic_threat_id = "GMM Econ Spotlight"
