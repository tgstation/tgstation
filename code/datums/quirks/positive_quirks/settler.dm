/datum/quirk/settler
	name = "Settler"
	desc = "Вы принадлежите к роду первых космических поселенцев! Несмотря на то, что в вашей семье многие поколения подвергались воздействию различной гравитации, \
		ваш рост... меньше, чем типичный для вашего вида, вы компенсируете это тем, что гораздо лучше умеете работать на природе и \
		переносить тяжелое оборудование. Вы также прекрасно ладите с животными. Однако вы немного медлительны из-за своих маленьких ног."
	gain_text = span_bold("Вы чувствуете, что весь мир принадлежит вам!")
	lose_text = span_danger("Сегодня вы думаете, что останетесь дома.")
	icon = FA_ICON_HOUSE
	value = 4
	mob_trait = TRAIT_SETTLER
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	medical_record_text = "Пациент длительное время находился в планетарных условиях, из-за чего обладает чрезвычайно крепким телосложением."
	mail_goodies = list(
		/obj/item/clothing/shoes/workboots/mining,
		/obj/item/gps,
	)
	/// Most of the behavior of settler is from these traits, rather than exclusively the quirk
	var/list/settler_traits = list(
		TRAIT_EXPERT_FISHER,
		TRAIT_ROUGHRIDER,
		TRAIT_STUBBY_BODY,
		TRAIT_BEAST_EMPATHY,
		TRAIT_STURDY_FRAME,
	)

/datum/quirk/settler/add(client/client_source)
	var/mob/living/carbon/human/human_quirkholder = quirk_holder
	human_quirkholder.set_mob_height(HUMAN_HEIGHT_SHORTEST)
	human_quirkholder.add_movespeed_modifier(/datum/movespeed_modifier/settler)
	human_quirkholder.add_traits(settler_traits, QUIRK_TRAIT)

/datum/quirk/settler/remove()
	if(QDELING(quirk_holder))
		return
	var/mob/living/carbon/human/human_quirkholder = quirk_holder
	human_quirkholder.set_mob_height(HUMAN_HEIGHT_MEDIUM)
	human_quirkholder.remove_movespeed_modifier(/datum/movespeed_modifier/settler)
	human_quirkholder.remove_traits(settler_traits, QUIRK_TRAIT)
