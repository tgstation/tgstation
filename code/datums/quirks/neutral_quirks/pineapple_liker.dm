/datum/quirk/pineapple_liker
	name = "Ananas Affinity"
	desc = "Вам очень нравятся ананасы. Кажется, вы никогда не сможете насытиться их великолепием!"
	icon = FA_ICON_THUMBS_UP
	value = 0
	gain_text = span_notice("Вы чувствуете сильную тягу к ананасам.")
	lose_text = span_notice("Ваше отношение к ананасам, похоже, вернулось к нейтральному состоянию.")
	medical_record_text = "Пациент демонстрирует патологическую любовь к ананасам."
	mail_goodies = list(/obj/item/food/pizzaslice/pineapple)

/datum/quirk/pineapple_liker/add(client/client_source)
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return
	tongue.liked_foodtypes |= PINEAPPLE

/datum/quirk/pineapple_liker/remove()
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return
	tongue.liked_foodtypes = initial(tongue.liked_foodtypes)
