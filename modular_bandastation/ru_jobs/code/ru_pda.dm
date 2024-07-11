// Update PDA name
/datum/outfit/job/post_equip(mob/living/carbon/human/equipped, visualsOnly)
	. = ..()
	var/obj/item/modular_computer/pda/pda = equipped.get_item_by_slot(pda_slot)
	if(!istype(pda))
		return
	var/obj/item/card/id/card = equipped.wear_id
	if(!istype(card))
		return
	pda.imprint_id(equipped.real_name, card.get_trim_assignment())
