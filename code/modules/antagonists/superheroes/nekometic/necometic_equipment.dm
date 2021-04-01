/obj/item/clothing/gloves/combat/nekometic
	name = "advanced combat gloves"
	desc = "A pair of advanced combat gloves that teach their user NekoBrawl using nanotechnologies."
	icon_state = "really_black"
	var/datum/martial_art/cqc/nekobrawl/style = new

/obj/item/clothing/gloves/combat/nekometic/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		style.teach(user, TRUE)

/obj/item/clothing/gloves/combat/nekometic/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		style.remove(user)
