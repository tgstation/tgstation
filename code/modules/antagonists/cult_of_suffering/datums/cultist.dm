// // code/modules/antagonists/cult_of_suffering/datums/cult_of_suffering.dm
// /datum/antagonist/cult_of_suffering
// 	name = "Cult of Suffering"
// 	roundend_category = "cult of suffering"
// 	antagpanel_category = "Cult of Suffering"
// 	antag_hud_name = "cult_of_suffering"
// 	show_to_ghosts = TRUE
// 	banning_key = ROLE_CULT_OF_SUFFERING

// 	/// Ссылка на команду культа
// 	var/datum/team/cult_of_suffering/cult_team

// 	greet()
// 		to_chat(owner, span_cultlarge("СТРАДАНИЕ - ЭТО ИСТИНА!"))
// 		to_chat(owner, span_cult("Ты посвящён в Cult of Suffering. Строй структуры, проводи ритуалы."))
// 		owner.announce_objectives()

// 	on_gain()
// 		. = ..()
// 		// Добавляем цели команды
// 		objectives |= cult_team.objectives

// 		// Выдача способностей строительства
// 		var/datum/action/innate/cult_of_suffering/build/build_action = new(owner)
// 		build_action.Grant(owner.current)

// 		// Визуальные эффекты: штука на голове
// 		add_cultist_effects()

// 	on_removal()
// 		. = ..()
// 		remove_cultist_effects()

// 	/// Добавляет визуальные эффекты культиста
// 	proc/add_cultist_effects()
// 		var/mob/living/carbon/human/H = owner.current
// 		if(istype(H))
// 			// "Штука на голове" - overlay или предмет
// 			var/obj/item/clothing/head/cult_of_suffering/crown = new(H)
// 			H.equip_to_slot_if_possible(crown, ITEM_SLOT_HEAD, FALSE, TRUE)

// 	/// Удаляет эффекты культиста
// 	proc/remove_cultist_effects()
// 		var/mob/living/carbon/human/H = owner.current
// 		if(istype(H))
// 			// Удаляем корону если есть
// 			var/obj/item/clothing/head/cult_of_suffering/crown = H.get_item_by_slot(ITEM_SLOT_HEAD)
// 			if(istype(crown))
// 				H.dropItemToGround(crown)
// 				qdel(crown)
