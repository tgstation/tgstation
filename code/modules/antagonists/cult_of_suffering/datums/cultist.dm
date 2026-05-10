// // code/modules/antagonists/cult_of_suffering/datums/cult_of_suffering.dm
/datum/antagonist/cult_of_suffering/cultist
	name = "Cultist of Suffering"
	roundend_category = "cult of suffering"
	antagpanel_category = "Cult of Suffering"
	antag_hud_name = "cult_of_suffering"
	show_to_ghosts = TRUE
	// banning_key = ROLE_CULT_OF_SUFFERING

// 	/// Ссылка на команду культа
// 	var/datum/team/cult_of_suffering/cult_team

/datum/antagonist/cult_of_suffering/cultist/greet()
		to_chat(owner, span_cult("СТРАДАНИЕ - ЭТО ИСТИНА!"))
		to_chat(owner, span_cult("Ты посвящён в Cult of Suffering. Строй структуры, проводи ритуалы."))
		owner.announce_objectives()

/datum/antagonist/cult_of_suffering/cultist/on_gain()
		. = ..()
		var/mob/living/current_mob = owner.current
		if(current_mob)
				owner.current.AddElement(/datum/element/cult_of_suffering_crown)
		// Добавляем цели команды
		// objectives |= cult_team.objectives

		// Выдача способностей строительства
		// var/datum/action/innate/cult_of_suffering/build/build_action = new(owner)
		// build_action.Grant(owner.current)

		// Визуальные эффекты: штука на голове
		// add_cultist_effects()

/datum/antagonist/cult_of_suffering/cultist/on_removal()
	. = ..()
	var/mob/living/current_mob = owner.current
	if(current_mob)
		owner.current.RemoveElement(/datum/element/cult_of_suffering_crown)

// 	/// Добавляет визуальные эффекты культиста
// /datum/antagonist/cult_of_suffering/cultist/proc/add_cultist_effects()
// 		var/mob/living/carbon/human/H = owner.current
// 		if(istype(H))
// 			// "Штука на голове" - overlay или предмет
// 			var/obj/item/clothing/head/cult_of_suffering/crown = new(H)
// 			H.equip_to_slot_if_possible(crown, ITEM_SLOT_HEAD, FALSE, TRUE)

// 	/// Удаляет эффекты культиста
// /datum/antagonist/cult_of_suffering/cultist/proc/remove_cultist_effects()
// 		var/mob/living/carbon/human/H = owner.current
// 		if(istype(H))
// 			// Удаляем корону если есть
// 			var/obj/item/clothing/head/cult_of_suffering/crown = H.get_item_by_slot(ITEM_SLOT_HEAD)
// 			if(istype(crown))
// 				H.dropItemToGround(crown)
// 				qdel(crown)
