///This station traits gives 5 bananium sheets to the clown (and every dead clown out there in deep space or lavaland).
/datum/station_trait/bananium_shipment
	name = "Поставка бананиума"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	report_message = "Ходят слухи, что планета клоунов отправляет посылки для поддержки клоунов в этой системе."
	trait_to_give = STATION_TRAIT_BANANIUM_SHIPMENTS

/datum/station_trait/bananium_shipment/get_pulsar_message()
	var/advisory_string = "Уровень предупреждения: <b>Планета клоунов</b></center><BR>"
	advisory_string += "Уровень предупреждения в вашем секторе — планета клоунов! Наши гудки засекли большой запас бананиума. Клоуны сообщают о большом наплыве клоунов на вашу станцию. Мы настоятельно рекомендуем вам избегать любых угроз, чтобы активы Хонкотрейзен оставались в Банановом секторе. Отдел разведки рекомендует защищать химию от любых клоунов, пытающихся производить лысиум или космическую смазку."
	return advisory_string

/datum/station_trait/unnatural_atmosphere
	name = "Неестественные атмосферные свойства"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE
	report_message = "Местная планета обладает необычными атмосферными свойствами."
	trait_to_give = STATION_TRAIT_UNNATURAL_ATMOSPHERE

	// This station trait modifies the atmosphere, which is too far past the time admins are able to revert it
	can_revert = FALSE

/datum/station_trait/spider_infestation
	name = "Нашествие пауков"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	report_message = "Мы ввели естественную контрмеру для сокращения количества грызунов на борту вашей станции."
	trait_to_give = STATION_TRAIT_SPIDER_INFESTATION

/datum/station_trait/unique_ai
	name = "Уникальный ИИ"
	trait_type = STATION_TRAIT_NEUTRAL
	trait_flags = parent_type::trait_flags | STATION_TRAIT_REQUIRES_AI
	weight = 15 /// BANDASTION EDIT - AI laws overhaul
	show_in_report = TRUE
	report_message = "В экспериментальных целях набор законов ИИ станции может отличаться от установленного по умолчанию набора законов. Не вмешивайтесь в этот эксперимент: \
		мы закрыли доступ к вашему набору альтернативных модулей загрузки, поскольку знаем, что вы уже подумываете о вмешательстве в этот эксперимент."
	trait_to_give = STATION_TRAIT_UNIQUE_AI

/datum/station_trait/unique_ai/on_round_start()
	. = ..()
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		ai.show_laws()

/datum/station_trait/ian_adventure
	name = "Приключение Ина"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = FALSE
	cost = STATION_TRAIT_COST_LOW
	report_message = "Иан отправился исследовать что-то на станции."

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
	name = "Сбой в работе КПК"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	cost = STATION_TRAIT_COST_MINIMAL
	report_message = "Похоже, что-то не так с КПК, которые вам выдали на эту смену. Впрочем, ничего серьёзного."
	trait_to_give = STATION_TRAIT_PDA_GLITCHED

/datum/station_trait/announcement_intern
	name = "Объявления от интерна"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	report_message = "Пожалуйста, будьте с ним поласковее."
	blacklist = list(/datum/station_trait/announcement_medbot, /datum/station_trait/birthday)

/datum/station_trait/announcement_intern/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/intern

/datum/station_trait/announcement_intern/get_pulsar_message()
	var/advisory_string = "Уровень предупреждения: <b>(НАЗВАНИЕ ЗДЕСЬ)</b></center><BR>"
	advisory_string += "(Скопируйте и вставьте в это поле сводку, предоставленную Управлением по анализу угроз. С этим у вас не должно возникнуть проблем, просто замените это сообщение, прежде чем нажимать кнопку отправки. Кроме того, убедитесь, что кофе готов к встрече в 06:00, когда закончите.)"
	return advisory_string

/datum/station_trait/announcement_medbot
	name = "Система \"оповещения\""
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	report_message = "В настоящее время наша система оповещения находится на плановом обслуживании. К счастью, у нас есть резервная система."
	blacklist = list(/datum/station_trait/announcement_intern, /datum/station_trait/birthday)

/datum/station_trait/announcement_medbot/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/medbot

/datum/station_trait/colored_assistants
	name = "Цветные ассистенты"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 10
	show_in_report = TRUE
	cost = STATION_TRAIT_COST_MINIMAL
	report_message = "В связи с нехваткой стандартных комбинезонов мы предоставили вашим ассистентам один из наших резервных комплектов."
	blacklist = list(/datum/station_trait/assistant_gimmicks)

/datum/station_trait/colored_assistants/New()
	. = ..()

	var/new_colored_assistant_type = pick(subtypesof(/datum/colored_assistant) - get_configured_colored_assistant_type())
	GLOB.colored_assistant = new new_colored_assistant_type

/datum/station_trait/birthday
	name = "День рождения сотрудника"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 2
	show_in_report = TRUE
	report_message = "Компания Нанотрейзен хотела бы поздравить сотрудника с днём ​​рождения."
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
	report_message = "Компания Нанотрейзен хотела бы поздравить [birthday_person ? birthday_person_name : "Employee Name"] с днём ​рождения."
	priority_announce("Поздравляем с днём рождения [birthday_person ? birthday_person_name : "Employee Name"]! Нанотрейзен желает счастливого [birthday_person ? "[birthday_person.age + 1]-го" : "255-го"] Дня Рождения.")
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
	desc = "Открытка с сообщением о том, что у кого-то сегодня день рождения."
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY

/obj/item/birthday_invite/proc/setup_card(birthday_name)
	desc = "Открытка с сообщением о том, что у [birthday_name] сегодня день рождения."
	icon_state = "paperslip_words"
	icon = 'icons/obj/service/bureaucracy.dmi'

/obj/item/clothing/head/costume/party
	name = "party hat"
	desc = "Дурацкий бумажный колпак, который вы ОБЯЗАНЫ носить."
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
	name = "Предсказатели"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 2
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE
	report_message = "Нанотрейзен выбрали вашу станцию ​​для эксперимента — у всех есть бесплатные предсказатели! Используйте их, чтобы легко и конфиденциально общаться с другими людьми."

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
	name = "Кошельки!"
	trait_type = STATION_TRAIT_NEUTRAL
	show_in_report = TRUE
	weight = 5
	cost = STATION_TRAIT_COST_MINIMAL
	report_message = "Сейчас стало модно пользоваться кошельками, поэтому каждому сотруднику станции выдали по одному."

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
	id_card.registered_account.adjust_money(-holochip_amount, "Система: Вывод средств")

	new /obj/effect/spawner/random/entertainment/wallet_storage(wallet)

	// Put our filthy fingerprints all over the contents
	for(var/obj/item/item in wallet)
		item.add_fingerprint(living_mob, ignoregloves = TRUE)

/// Tells the area map generator to ADD MORE TREEEES
/datum/station_trait/forested
	name = "Покрытый лесом"
	trait_type = STATION_TRAIT_NEUTRAL
	trait_to_give = STATION_TRAIT_FORESTED
	trait_flags = STATION_TRAIT_PLANETARY
	weight = 10
	show_in_report = TRUE
	report_message = "Тут действительно много деревьев."

/datum/station_trait/linked_closets
	name = "Аномалия в шкафу"
	trait_type = STATION_TRAIT_NEUTRAL
	show_in_report = TRUE
	weight = 1
	report_message = "Мы получили сообщения свободных потоках блюспейса, влияющих на станционные шкафчики и ящики. \
		Вы можете заметить отсутствие некоторых личных вещей… или обзавестись новыми!"

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
		GLOB.closet_teleport_controller.create_new_link(targets)


#define PRO_SKUB "pro-skub"
#define ANTI_SKUB "anti-skub"
#define SKUB_IDFC "i don't frikkin' care"
#define RANDOM_SKUB null //This means that if you forgot to opt in/against/out, there's a 50/50 chance to be pro or anti

/// A trait that lets players choose whether they want pro-skub or anti-skub (or neither), and receive the appropriate equipment.
/datum/station_trait/skub
	name = "Великий Скуб раздор"
	trait_type = STATION_TRAIT_NEUTRAL
	show_in_report = FALSE
	weight = 2
	sign_up_button = TRUE
	/// List of people signed up to be either pro_skub or anti_skub
	var/list/skubbers = list()

/datum/station_trait/skub/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/* BANDASTATION REMOVAL - HTML Title Screen
/datum/station_trait/skub/setup_lobby_button(atom/movable/screen/lobby/button/sign_up/lobby_button)
	RegisterSignal(lobby_button, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_lobby_button_update_overlays))
	lobby_button.desc = "Are you pro-skub or anti-skub? Click to cycle through pro-skub, anti-skub, random and neutral."
	return ..()
*/

/// Let late-joiners jump on this gimmick too.
/datum/station_trait/skub/can_display_lobby_button(client/player)
	return sign_up_button

/// We don't destroy buttons on round start for those who are still in the lobby.
/datum/station_trait/skub/on_round_start()
	return

/* BANDASTATION REMOVAL - HTML Title Screen
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
*/

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
	name = "Проверка биографических данных по всей станции"
	report_message = "На эту смену мы заменили интерна, который проверял биографию вашей команды, квалифицированным специалистом по проверке! \
		Тем не менее, наши враги могут найти другой способ проникнуть на станцию, так что будьте осторожны."
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
	name = "Приведите своего питомца на работу"
	trait_type = STATION_TRAIT_NEUTRAL
	show_in_report = FALSE
	weight = 2
	sign_up_button = TRUE

/datum/station_trait/pet_day/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/* BANDASTATION REMOVAL - HTML Title Screen
/datum/station_trait/pet_day/setup_lobby_button(atom/movable/screen/lobby/button/sign_up/lobby_button)
	lobby_button.desc = "Want to bring your innocent pet to a giant metal deathtrap? Click here to customize it!"
	RegisterSignal(lobby_button, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_lobby_button_update_overlays))
	return ..()
*/

/datum/station_trait/pet_day/can_display_lobby_button(client/player)
	return sign_up_button

/datum/station_trait/pet_day/on_round_start()
	return

/* BANDASTATION REMOVAL - HTML Title Screen
/datum/station_trait/pet_day/on_lobby_button_click(atom/movable/screen/lobby/button/sign_up/lobby_button, updates)
	var/mob/our_player = lobby_button.get_mob()
	var/client/player_client = our_player.client
	if(isnull(player_client))
		return
	var/datum/pet_customization/customization = GLOB.customized_pets[REF(player_client)]
	if(isnull(customization))
		customization = new(player_client)
	INVOKE_ASYNC(customization, TYPE_PROC_REF(/datum, ui_interact), our_player)
*/

/datum/station_trait/pet_day/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/datum/pet_customization/customization = GLOB.customized_pets[REF(player_client)]
	if(isnull(customization))
		return
	INVOKE_ASYNC(customization, TYPE_PROC_REF(/datum/pet_customization, create_pet), spawned, player_client)

/* BANDASTATION REMOVAL - HTML Title Screen
/datum/station_trait/pet_day/proc/on_lobby_button_update_overlays(atom/movable/screen/lobby/button/sign_up/lobby_button, list/overlays)
	overlays += "select_pet"
*/

/// We're pulling a Jim Kramer with this one boys
/datum/station_trait/gmm_spotlight
	name = "Экономическое обозрение ГРМ"
	report_message = "В течение этой смены Галактический рынок минералов проводит выставку богатства вашего экипажа! Каждый раз, когда выплачивается зарплата, ведущие новостей станции будут объявлять, у кого больше всего кредитов."
	trait_type = STATION_TRAIT_NEUTRAL
	trait_to_give = STATION_TRAIT_ECONOMY_ALERTS
	weight = 2
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE

	dynamic_threat_id = "GMM Econ Spotlight"
