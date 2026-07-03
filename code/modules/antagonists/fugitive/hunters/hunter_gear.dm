//works similar to the experiment machine (experiment.dm) except it just holds more and more prisoners

/obj/machinery/fugitive_capture
	name = "bluespace capture machine"
	desc = "Внутри она гораздо, ГОРАЗДО больше, чтобы безопасно перевозить заключённых."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "bluespace-prison"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //ha ha no getting out!!
	interaction_flags_mouse_drop = NEED_DEXTERITY

/obj/machinery/fugitive_capture/examine(mob/user)
	. = ..()
	. += span_notice("Добавьте заключённого, перетащив его в машину.")

/obj/machinery/fugitive_capture/mouse_drop_receive(mob/target, mob/user, params)
	var/mob/living/fugitive_hunter = user
	if(!isliving(fugitive_hunter) || !ishuman(target))
		return
	var/mob/living/carbon/human/fugitive = target
	var/datum/antagonist/fugitive/fug_antag = fugitive.mind.has_antag_datum(/datum/antagonist/fugitive)
	if(!fug_antag)
		to_chat(fugitive_hunter, span_warning("This is not a wanted fugitive!"))
		return
	if(do_after(fugitive_hunter, 5 SECONDS, target = fugitive))
		add_prisoner(fugitive, fug_antag)

/obj/machinery/fugitive_capture/proc/add_prisoner(mob/living/carbon/human/fugitive, datum/antagonist/fugitive/antag)
	fugitive.forceMove(src)
	antag.is_captured = TRUE
	to_chat(fugitive, span_userdanger("Вас выбрасывает в бескрайнюю пустоту блюспейса, и по мере того, как вы погружаетесь все глубже в забвение, сравнительно небольшой проход в реальность становится все меньше и меньше, пока вы не перестаёте его видеть. Вам не удалось избежать поимки."))
	fugitive.ghostize(TRUE) //so they cannot suicide, round end stuff.
	use_energy(active_power_usage)

/obj/machinery/computer/shuttle/hunter
	name = "shuttle console"
	shuttleId = "huntership"
	possible_destinations = "huntership_home;huntership_custom;whiteship_home;syndicate_nw"
	req_access = list(ACCESS_HUNTER)

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/hunter
	name = "shuttle navigation computer"
	desc = "Используется для определения точного транзитного местоположения, в который следует отправиться."
	shuttleId = "huntership"
	lock_override = CAMERA_LOCK_STATION
	shuttlePortId = "huntership_custom"
	see_hidden = FALSE
	jump_to_ports = list("huntership_home" = 1, "whiteship_home" = 1, "syndicate_nw" = 1)
	view_range = 4.5

/obj/structure/closet/crate/eva
	name = "EVA crate"
	icon_state = "o2crate"
	base_icon_state = "o2crate"

/obj/structure/closet/crate/eva/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/clothing/suit/space/eva(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/helmet/space/eva(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/mask/breath(src)
	for(var/i in 1 to 3)
		new /obj/item/tank/internals/oxygen(src)

///Psyker-friendly shuttle gear!

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/hunter/psyker
	name = "psyker navigation warper"
	desc = "Использует усиленные мозговые волны, чтобы определить и нанести на карту точное местоположение шаттла псайкеров."
	icon_screen = "recharge_comp_on"
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON //blind friendly
	x_offset = 0
	y_offset = 11

/obj/machinery/fugitive_capture/psyker
	name = "psyker recreation cell"
	desc = "Перепрофилированная рекреационная камера, часто используемая псайкерами, которая успокаивает пользователя, подвергая его воздействию громких звуков и болезненных стимулов. Переоборудована для содержания заключённых и не должна оказывать (длительных) побочных эффектов на не-псайкеров, помещённых в неё принудительно."

/obj/machinery/fugitive_capture/psyker/process() //I have no fucking idea how to make click-dragging work for psykers so this one just sucks them in.
	for(var/mob/living/carbon/human/potential_victim in range(1, get_turf(src)))
		var/datum/antagonist/fugitive/fug_antag = potential_victim.mind.has_antag_datum(/datum/antagonist/fugitive)
		if(fug_antag)
			potential_victim.visible_message(span_alert("[potential_victim] is violently sucked into the [src]!"))
			add_prisoner(potential_victim, fug_antag)

/// Psyker gear
/obj/item/reagent_containers/hypospray/medipen/gore
	name = "gore autoinjector"
	desc = "Автоинъектор сомнительного вида, наполненный гором, он же грязный кронкейн. Вероятно, не стоит принимать его во время работы, но это суперстимулятор. Не принимайте сразу две дозы."
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/drug/kronkaine/gore = 15)
	icon_state = "maintenance"
	base_icon_state = "maintenance"
	label_examine = FALSE

//Captain's special mental recharge gear

/obj/item/clothing/suit/armor/reactive/psykerboost
	name = "reactive psykerboost armor"
	desc = "Экспериментальная броня, которую псайкеры используют, чтобы расширить возможности своего разума. Реагирует на врагов, усиливая психические способности носителя."
	cooldown_message = span_danger("Ментальные катушки брони усиления псиоников всё ещё остывают!")
	emp_message = span_danger("Ментальные катушки брони усиления псиоников на мгновение перекалибровываются с тихим жалобным звуком.")
	color = "#d6ad8b"

/obj/item/clothing/suit/armor/reactive/psykerboost/cooldown_activation(mob/living/carbon/human/owner)
	do_sparks(1, TRUE, src)
	return ..()

/obj/item/clothing/suit/armor/reactive/psykerboost/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src.declent_ru(NOMINATIVE)] блокирует [attack_text], усиливая психическую силу [owner]!"))
	for(var/datum/action/cooldown/spell/psychic_ability in owner.actions)
		if(psychic_ability.school == SCHOOL_PSYCHIC)
			psychic_ability.reset_spell_cooldown()
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/item/clothing/suit/armor/reactive/psykerboost/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src.declent_ru(NOMINATIVE)] блокирует [attack_text], истощая психическую силу [owner]!"))
	for(var/datum/action/cooldown/spell/psychic_ability in owner.actions)
		if(psychic_ability.school == SCHOOL_PSYCHIC)
			psychic_ability.StartCooldown()
	reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
	return TRUE

/obj/structure/bouncy_castle
	name = "bouncy castle"
	desc = "Если вы принимаете наркотики, то перед смертью попадёте в ад. Пожалуйста."
	icon = 'icons/obj/toys/bouncy_castle.dmi'
	icon_state = "bouncy_castle"
	anchored = TRUE
	density = TRUE
	layer = OBJ_LAYER

/obj/structure/bouncy_castle/Initialize(mapload, mob/gored)
	. = ..()
	if(gored)
		name = gored.real_name

	AddComponent(
		/datum/component/blood_walk,\
		blood_type = /obj/effect/decal/cleanable/blood,\
		blood_spawn_chance = 66.6,\
		max_blood = INFINITY,\
	)

	AddComponent(/datum/component/bloody_spreader)

/obj/structure/bouncy_castle/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/blob/attackblob.ogg', 50, TRUE)
			else
				playsound(src, 'sound/items/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/tools/welder.ogg', 100, TRUE)

/obj/item/paper/crumpled/fluff/fortune_teller
	name = "scribbled note"
	default_raw_text = "<b>Помните!</b> Клиентам нравится, что у нас есть жевательная резинка в виде хрустального шара. \
		Даже если это совершенно бесполезно для нас, не поддавайтесь желанию пожевать его."

/**
 * # Bounty Locator
 *
 * Locates a random, living fugitive and reports their name/location on a 40 second cooldown.
 *
 * Locates a random fugitive antagonist via the GLOB.antagonists list, and reads out their real name and area name.
 * Captured or dead fugitives are not reported.
 */
/obj/machinery/fugitive_locator
	name = "Bounty Locator"
	desc = "Отслеживает сигнатуры целей за награду в вашем секторе. Никто на самом деле не знает, какой механизм использует эта штука для отслеживания целей. \
		Будь то блюспейс запутанность или простой RFID-имплант, эта машина найдёт того, кого вы ищете, где бы он ни скрывался."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator-Purple"
	density = TRUE
	/// Cooldown on locating a fugitive.
	COOLDOWN_DECLARE(locate_cooldown)

/obj/machinery/fugitive_locator/interact(mob/user)
	if(!COOLDOWN_FINISHED(src, locate_cooldown))
		balloon_alert_to_viewers("locator recharging!", vision_distance = 3)
		return
	var/mob/living/bounty = locate_fugitive()
	if(!bounty)
		say("Не обнаружено никаких целей за вознаграждение.")
	else
		say("Обнаружена цель для получения награды. Имя на карте цели: [bounty.real_name]. Местоположение: [get_area_name(bounty)]")

	COOLDOWN_START(src, locate_cooldown, 40 SECONDS)

///Locates a random fugitive via their antag datum and returns them.
/obj/machinery/fugitive_locator/proc/locate_fugitive()
	var/list/datum_list = shuffle(GLOB.antagonists)
	for(var/datum/antagonist/fugitive/fugitive_datum in datum_list)
		if(!fugitive_datum.owner)
			stack_trace("Fugitive locator tried to locate a fugitive antag datum with no owner.")
			continue
		if(fugitive_datum.is_captured)
			continue
		var/mob/living/found_fugitive = fugitive_datum.owner.current
		if(found_fugitive.stat == DEAD)
			continue

		return found_fugitive

/obj/item/radio/headset/psyker
	name = "psychic headset"
	desc = "Гарнитура, предназначенная для усиления психических волн. Защищает уши от светошумовых гранат."
	icon_state = "psyker_headset"
	worn_icon_state = "syndie_headset"
	freerange = TRUE

/obj/item/radio/headset/psyker/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection)
	set_frequency(FREQ_FUGITIVE_HUNTER)

/obj/item/radio/headset/psyker/equipped(mob/user, slot, initial)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_ECHOLOCATOR))
		ADD_TRAIT(user, TRAIT_SIGHT_BYPASS, REF(src))
	else
		REMOVE_TRAIT(user, TRAIT_SIGHT_BYPASS, REF(src))

/obj/item/radio/headset/psyker/dropped(mob/user, silent)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_SIGHT_BYPASS, REF(src))

/obj/item/radio/headset/psyker_seer
	name = "psychic seer headset"
	desc = "A psychic headset designed for the elite psyker seers."
	icon_state = "med_headset_alt"
	worn_icon_state = "med_headset_alt"
	freerange = TRUE

/obj/item/radio/headset/psyker_seer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection)
	set_frequency(FREQ_FUGITIVE_HUNTER)

/obj/item/storage/belt/holster/psyker

/obj/item/storage/belt/holster/psyker/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 5
	atom_storage.max_total_storage = /obj/item/gun/ballistic/revolver/c38::w_class + (4 * /obj/item/ammo_box/speedloader/c38::w_class)
