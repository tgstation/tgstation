/datum/quirk/pineapple_hater
	name = "Ananas Aversion"
	desc = "Вы испытываете сильное отвращение к ананасам. Серьезно, как, черт возьми, кто-то может говорить, что они вкусные? И какой безумец вообще осмелится положить их на пиццу!?"
	icon = FA_ICON_THUMBS_DOWN
	value = 0
	gain_text = span_notice("Вы размышляете о том, каким извращенцам нравятся ананасы...")
	lose_text = span_notice("Ваше отношение к ананасам, похоже, вернулось к нейтральному состоянию.")
	medical_record_text = "Пациент считает, что ананасы отвратительны."
	mail_goodies = list( // basic pizza slices
		/obj/item/food/pizzaslice/margherita,
		/obj/item/food/pizzaslice/meat,
		/obj/item/food/pizzaslice/mushroom,
		/obj/item/food/pizzaslice/vegetable,
		/obj/item/food/pizzaslice/sassysage,
	)

/datum/quirk/pineapple_hater/add(client/client_source)
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return
	tongue.disliked_foodtypes |= PINEAPPLE

/datum/quirk/pineapple_hater/remove()
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return
	tongue.disliked_foodtypes = initial(tongue.disliked_foodtypes)
