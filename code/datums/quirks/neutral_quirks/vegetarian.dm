/datum/quirk/vegetarian
	name = "Vegetarian"
	desc = "Вы считаете идею употребления мяса аморальной и физически отвратительной."
	icon = FA_ICON_CARROT
	value = 0
	gain_text = span_notice("Вы испытываете отвращение к идее есть мясо.")
	lose_text = span_notice("Вам кажется, что есть мясо не так уж и плохо.")
	medical_record_text = "Пациент соблюдает вегетарианскую диету."
	mail_goodies = list(/obj/effect/spawner/random/food_or_drink/salad)
	mob_trait = TRAIT_VEGETARIAN
