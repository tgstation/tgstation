/obj/item/clothing/gloves/radio
	name = "translation gloves"
	desc = "A pair of electronic gloves which connect to the user's worn headset wirelessly. Allows for sign language users to 'speak' over comms."
	icon_state = "green"
	inhand_icon_state = "greengloves"

/*

/obj/item/clothing/gloves/radio/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
			if(HAS_TRAIT(user, TRAIT_SIGN_LANG))

/obj/item/clothing/gloves/radio/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		qdel(radio)
	if(HAS_TRAIT(user, TRAIT_SIGN_LANG))

*/

