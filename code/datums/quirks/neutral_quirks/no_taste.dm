/datum/quirk/no_taste
	name = "Ageusia"
	desc = "Вы не сможете ничего попробовать на вкус! Токсичная пища всё еще может отравить вас."
	icon = FA_ICON_MEH_BLANK
	value = 0
	mob_trait = TRAIT_AGEUSIA
	gain_text = span_notice("Кажется, вы больше не чувствуете каких-либо вкусов при приеме пищи!")
	lose_text = span_notice("У вас снова появилось ощущение вкуса во рту!")
	medical_record_text = "Пациент страдает агевзией и не способен чувствовать вкус пищи или реагентов."
	mail_goodies = list(/obj/effect/spawner/random/food_or_drink/condiment) // but can you taste the salt? CAN YOU?!
