/obj/item/clothing/mask/fakemoustache
	name = "накладные усы"
	desc = "Осторожно: усы накладные."

/obj/item/clothing/mask/fakemoustache/italian
	name = "итальянские усы"
	desc = "Изготовлен из настоящих итальянских волосков для усов. Дает владельцу непреодолимое желание дико жестикулировать."

/obj/item/clothing/mask/fakemoustache/italian/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/speechmod,\
		replacements = strings("italian_replacement_ru.json", "italian"),\
		end_string = list(" Равиоли, равиоли, подскажи мне формуоли!"," Мамма-мия!"," Мамма-мия! Какая острая фрикаделька!", " Ла ла ла ла ла фуникули+ фуникуля+!"),\
		end_string_chance = 3,\
		slots = ITEM_SLOT_MASK\
	)
