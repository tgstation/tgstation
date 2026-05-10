// // code/modules/antagonists/cult_of_suffering/datums/hunter.dm
// /datum/antagonist/cult_of_suffering_hunter
// 	name = "Cult of Suffering Hunter"
// 	roundend_category = "cult hunters"
// 	antagpanel_category = "Cult of Suffering"
// 	antag_hud_name = "cult_of_suffering_hunter"
// 	show_to_ghosts = TRUE
// 	banning_key = ROLE_CULT_HUNTER

// 	/// Иммунитет к газу Адиум
// 	var/immune_to_adium = TRUE

// 	greet()
// 		to_chat(owner, span_danger("ТЫ - ОХОТНИК НА КУЛЬТ!"))
// 		to_chat(owner, span_danger("ЦентКом выбрал тебя для борьбы с Cult of Suffering."))
// 		to_chat(owner, span_danger("Цель: Уничтожить всех культистов, Лорда и структуры культа."))
// 		owner.announce_objectives()

// 	on_gain()
// 		. = ..()
// 		// Добавляем цели охотника
// 		var/datum/objective/hunter/destroy_cult/destroy_objective = new
// 		destroy_objective.owner = owner
// 		objectives += destroy_objective

// 		// Выдача снаряжения охотника
// 		equip_hunter()

// 		// Выдача способностей охотника
// 		grant_hunter_abilities()

// 		// Иммунитет к газу
// 		add_immunity()

// 	on_removal()
// 		. = ..()
// 		remove_immunity()

// 	/// Экипирует охотника
// 	proc/equip_hunter()
// 		var/mob/living/carbon/human/H = owner.current
// 		if(!istype(H))
// 			return

// 		// Особый костюм охотника
// 		var/obj/item/clothing/under/cult_hunter/uniform = new(H)
// 		H.equip_to_slot_if_possible(uniform, ITEM_SLOT_ICLOTHING, FALSE, TRUE)

// 		var/obj/item/clothing/suit/cult_hunter/armor = new(H)
// 		H.equip_to_slot_if_possible(armor, ITEM_SLOT_OCLOTHING, FALSE, TRUE)

// 		var/obj/item/clothing/head/cult_hunter/helmet = new(H)
// 		H.equip_to_slot_if_possible(helmet, ITEM_SLOT_HEAD, FALSE, TRUE)

// 		// Оружие против культа
// 		var/obj/item/gun/energy/cult_hunter/rifle = new(H)
// 		H.put_in_hands(rifle)

// 		var/obj/item/cult_hunter_scanner/scanner = new(H)
// 		H.equip_to_slot_if_possible(scanner, ITEM_SLOT_BELT, FALSE, TRUE)

// 	/// Выдаёт способности охотника
// 	proc/grant_hunter_abilities()
// 		var/datum/action/innate/cult_hunter/detect_cult/detect_action = new(owner)
// 		detect_action.Grant(owner.current)

// 		var/datum/action/innate/cult_hunter/dispel_structures/dispel_action = new(owner)
// 		dispel_action.Grant(owner.current)

// 		var/datum/action/innate/cult_hunter/purge_gas/purge_action = new(owner)
// 		purge_action.Grant(owner.current)

// 	/// Добавляет иммунитет к газу
// 	proc/add_immunity()
// 		var/mob/living/carbon/H = owner.current
// 		if(istype(H))
// 			H.add_trait(TRAIT_ADIUM_IMMUNE, CULT_HUNTER_TRAIT)

// 	/// Удаляет иммунитет
// 	proc/remove_immunity()
// 		var/mob/living/carbon/H = owner.current
// 		if(istype(H))
// 			H.remove_trait(TRAIT_ADIUM_IMMUNE, CULT_HUNTER_TRAIT)
