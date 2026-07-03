/datum/quirk/evil
	name = "Fundamentally Evil"
	desc = "Там, где должна быть душа, зияет черная пустота. Хотя вы стремитесь сохранить свое положение в обществе, \
		всякий, кто заглянет в ваши холодные равнодушные глаза, поймет правду. Вы действительно зло. С вами абсолютно все в порядке. \
		Вы сознательно выбрали путь зла и преданы этому выбору. Ваши амбиции стоят превыше всего."
	icon = FA_ICON_HAND_MIDDLE_FINGER
	value = 0
	mob_trait = TRAIT_EVIL
	gain_text = span_notice("Вы теряете то немногое, что осталось от вашей человечности. У вас есть работа, которую нужно сделать.")
	lose_text = span_notice("Вы вдруг стали больше заботиться о других и их потребностях.")
	medical_record_text = "Пациент успешно прошел все наши тесты социальной приспособленности, но испытывал трудности с тестами на эмпатию."
	mail_goodies = list(/obj/item/food/grown/citrus/lemon)

/datum/quirk/evil/post_add()
	var/evil_policy = get_policy("[type]") || "Обратите внимание, что несмотря на то, что вы можете быть [LOWER_TEXT(name)], это НЕ даёт вам никаких дополнительных прав нападать на людей или сеять хаос."
	// We shouldn't need this, but it prevents people using it as a dumb excuse in ahelps.
	to_chat(quirk_holder, span_big(span_info(evil_policy)))
