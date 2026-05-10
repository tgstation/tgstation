// code/modules/antagonists/cult_of_suffering/datums/lord.dm
/datum/antagonist/cult_of_suffering/lord
	name = "Lord of Suffering"
	roundend_category = "lords of suffering"
	antagpanel_category = "Cult of Suffering"
	antag_hud_name = "cult_of_suffering_lord"
	show_to_ghosts = TRUE
	banning_key = ROLE_CULT_OF_SUFFERING_LORD

	/// Мощные способности Лорда
	var/list/lord_abilities = list()

	greet()
		to_chat(owner, span_cultlarge("ТЫ - ЛОРД СТРАДАНИЯ!"))
		to_chat(owner, span_cult("Ты избран газом Адиум для руководства Cult of Suffering."))
		to_chat(owner, span_cult("Цели: Управляй культом, строй великие структуры, распространяй страдание."))
		owner.announce_objectives()

	on_gain()
		. = ..()
		// Устанавливаем как лидера команды
		if(cult_team)
			cult_team.lord = owner

		// Выдача мощных способностей Лорда
		grant_lord_abilities()

		// Визуальные эффекты Лорда
		add_lord_effects()

		// Спавн с особым снаряжением
		equip_lord()

	on_removal()
		. = ..()
		remove_lord_effects()
		if(cult_team && cult_team.lord == owner)
			cult_team.lord = null

	/// Выдаёт способности Лорда
	proc/grant_lord_abilities()
		// Способность призывать берсерков
		var/datum/action/innate/cult_of_suffering/lord/summon_berserkers/summon_action = new(owner)
		summon_action.Grant(owner.current)
		lord_abilities += summon_action

		// Способность создавать газ Адиум
		var/datum/action/innate/cult_of_suffering/lord/create_gas/gas_action = new(owner)
		gas_action.Grant(owner.current)
		lord_abilities += gas_action

		// Способность телепортации
		var/datum/action/innate/cult_of_suffering/lord/teleport/teleport_action = new(owner)
		teleport_action.Grant(owner.current)
		lord_abilities += teleport_action

	/// Добавляет визуальные эффекты Лорда
	proc/add_lord_effects()
		var/mob/living/carbon/human/H = owner.current
		if(istype(H))
			// Аура Лорда
			H.add_overlay(mutable_appearance('icons/effects/cult_of_suffering.dmi', "lord_aura"))
			// Глаза Лорда
			H.eye_color = "ff0000"
			H.update_body()

	/// Экипирует Лорда
	proc/equip_lord()
		var/mob/living/carbon/human/H = owner.current
		if(!istype(H))
			return

		// Роба Лорда
		var/obj/item/clothing/under/cult_of_suffering/lord/robes = new(H)
		H.equip_to_slot_if_possible(robes, ITEM_SLOT_ICLOTHING, FALSE, TRUE)

		// Плащ Лорда
		var/obj/item/clothing/suit/cult_of_suffering/lord/cloak = new(H)
		H.equip_to_slot_if_possible(cloak, ITEM_SLOT_OCLOTHING, FALSE, TRUE)

		// Посох Лорда
		var/obj/item/cult_of_suffering/lord_staff/staff = new(H)
		H.put_in_hands(staff)
