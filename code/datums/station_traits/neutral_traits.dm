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
		spawned_mob.equip_to_slot_or_del(hat, ITEM_SLOT_BACKPACK, indirect_action = TRUE)
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
		spawned_mob.equip_to_slot_or_del(toy, ITEM_SLOT_BACKPACK, indirect_action = TRUE)
	if(birthday_person_name) //Anyone who joins after the annoucement gets one of these.
		var/obj/item/birthday_invite/birthday_invite = new(spawned_mob)
		birthday_invite.setup_card(birthday_person_name)
		if(!spawned_mob.equip_to_slot_if_possible(birthday_invite, ITEM_SLOT_HANDS, disable_warning = TRUE))
			spawned_mob.equip_to_slot_or_del(birthday_invite, ITEM_SLOT_BACKPACK) //Just incase someone spawns with both hands full.

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

/datum/station_trait/scarves
	name = "Scarves"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	cost = STATION_TRAIT_COST_MINIMAL
	show_in_report = TRUE
	var/list/scarves

/datum/station_trait/scarves/New()
	. = ..()
	report_message = pick(
		"Nanotrasen is experimenting with seeing if neck warmth improves employee morale.",
		"After Space Fashion Week, scarves are the hot new accessory.",
		"Everyone was simultaneously a little bit cold when they packed to go to the station.",
		"The station is definitely not under attack by neck grappling aliens masquerading as wool. Definitely not.",
		"You all get free scarves. Don't ask why.",
		"A shipment of scarves was delivered to the station.",
	)
	scarves = typesof(/obj/item/clothing/neck/scarf) + list(
		/obj/item/clothing/neck/large_scarf/red,
		/obj/item/clothing/neck/large_scarf/green,
		/obj/item/clothing/neck/large_scarf/blue,
	)

	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))


/datum/station_trait/scarves/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	var/scarf_type = pick(scarves)

	spawned.equip_to_slot_or_del(new scarf_type(spawned), ITEM_SLOT_NECK, initial = FALSE)

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
	var/list/roundstart_non_secure_closets = GLOB.roundstart_station_closets.Copy()
	for(var/obj/structure/closet/closet in roundstart_non_secure_closets)
		if(closet.secure)
			roundstart_non_secure_closets -= closet

	/**
	 * The number of links to perform.
	 * Combined with 50/50 the probability of the link being triangular, the boundaries of any given
	 * on-station, non-secure closet being linked are as high as 1 in 7/8 and as low as 1 in 16-17,
	 * nearing an a mean of 1 in 9 to 11/12 the more repetitions are done.
	 *
	 * There are more than 220 roundstart closets on meta, around 150 of which aren't secure,
	 * so, about 13 to 17 closets will be affected by this most of the times.
	 */
	var/number_of_links = round(length(roundstart_non_secure_closets) * (rand(350, 450)*0.0001), 1)
	for(var/repetition in 1 to number_of_links)
		var/closets_left = length(roundstart_non_secure_closets)
		if(closets_left < 2)
			return
		var/list/targets = list()
		for(var/how_many in 1 to min(closets_left, rand(2,3)))
			targets += pick_n_take(roundstart_non_secure_closets)
		if(closets_left == 1) //there's only one closet left. Let's not leave it alone.
			targets += roundstart_non_secure_closets[1]
		GLOB.eigenstate_manager.create_new_link(targets)

/datum/station_trait/triple_ai
	name = "AI Triumvirate"
	trait_type = STATION_TRAIT_NEUTRAL
	trait_flags = parent_type::trait_flags | STATION_TRAIT_REQUIRES_AI
	show_in_report = TRUE
	weight = 1
	report_message = "Your station has been instated with three Nanotrasen Artificial Intelligence models."

/datum/station_trait/triple_ai/New()
	. = ..()
	RegisterSignal(SSjob, COMSIG_OCCUPATIONS_SETUP, PROC_REF(on_occupations_setup))

/datum/station_trait/triple_ai/revert()
	UnregisterSignal(SSjob, COMSIG_OCCUPATIONS_SETUP)
	return ..()

/datum/station_trait/triple_ai/proc/on_occupations_setup(datum/controller/subsystem/job/source)
	SIGNAL_HANDLER

	//allows for latejoining AIs
	for(var/obj/effect/landmark/start/ai/secondary/secondary_ai_spawn in GLOB.start_landmarks_list)
		secondary_ai_spawn.latejoin_active = TRUE

	var/datum/station_trait/job/human_ai/ai_trait = locate() in SSstation.station_traits
	//human AI quirk will handle adding its own job positions, but for now don't allow more AI slots.
	if(ai_trait)
		return
	for(var/datum/job/ai/ai_datum in SSjob.joinable_occupations)
		ai_datum.spawn_positions = 3
		ai_datum.total_positions = 3


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
		var/obj/item/storage/box/skub/boxie = new(spawned.loc)
		spawned.equip_to_slot_if_possible(boxie, ITEM_SLOT_BACKPACK, indirect_action = TRUE)
		if(ishuman(spawned))
			var/obj/item/clothing/suit/costume/wellworn_shirt/skub/shirt = new(spawned.loc)
			if(!spawned.equip_to_slot_if_possible(shirt, ITEM_SLOT_OCLOTHING, indirect_action = TRUE))
				shirt.forceMove(boxie)
		return

	var/obj/item/storage/box/stickers/anti_skub/boxie = new(spawned.loc)
	spawned.equip_to_slot_if_possible(boxie, ITEM_SLOT_BACKPACK, indirect_action = TRUE)
	if(!ishuman(spawned))
		return
	var/obj/item/clothing/suit/costume/wellworn_shirt/skub/anti/shirt = new(spawned.loc)
	if(!spawned.equip_to_slot_if_possible(shirt, ITEM_SLOT_OCLOTHING, indirect_action = TRUE))
		shirt.forceMove(boxie)

/// A box containing a skub, for easier carry because skub is a bulky item.
/obj/item/storage/box/skub
	name = "skub box"
	desc = "A box to store your skub and pro-skub shirt in. A label on the back reads: \"Skubtide, Stationwide\"."
	icon_state = "hugbox"
	illustration = "skub"

/obj/item/storage/box/skub/Initialize(mapload)
	. = ..()
	atom_storage.exception_hold = typecacheof(list(/obj/item/skub, /obj/item/clothing/suit/costume/wellworn_shirt/skub))

/obj/item/storage/box/skub/PopulateContents()
	new /obj/item/skub(src)
	new /obj/item/sticker/skub(src)
	new /obj/item/sticker/skub(src)

/obj/item/storage/box/stickers/anti_skub
	name = "anti-skub stickers box"
	desc = "The enemy may have been given a skub and a shirt, but I've more stickers! Plus the box can hold my anti-skub shirt."

/obj/item/storage/box/stickers/anti_skub/Initialize(mapload)
	. = ..()
	atom_storage.exception_hold = typecacheof(list(/obj/item/clothing/suit/costume/wellworn_shirt/skub))

/obj/item/storage/box/stickers/anti_skub/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/sticker/anti_skub(src)

#undef PRO_SKUB
#undef ANTI_SKUB
#undef SKUB_IDFC
#undef RANDOM_SKUB

/// Crew don't ever spawn as enemies of the station. Obsesseds, blob infection, space changelings etc can still happen though
/datum/station_trait/background_checks
	name = "Station-Wide Background Checks"
	report_message = "We replaced the intern doing your crew's background checks with a trained screener for this shift! That said, our enemies may just find another way to infiltrate the station, so be careful."
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	can_revert = FALSE

	dynamic_category = RULESET_CATEGORY_NO_WITTING_CREW_ANTAGONISTS
	threat_reduction = 15
	dynamic_threat_id = "Background Checks"
