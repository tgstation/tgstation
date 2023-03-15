/obj/item/clothing/mask/breath/sec_bandana
	desc = "An incredibly dense synthetic thread bandana that can be used as an internals mask."
	name = "sec bandana"
	worn_icon = 'monkestation/icons/mob/mask.dmi'
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	icon_state = "sec_bandana_default"
	item_state = "sec_bandana_default"
	var/obj/item/clothing/suit/armor/secduster/suit
	actions_types = null
	gas_transfer_coefficient = null
	permeability_coefficient = null

/obj/item/clothing/mask/breath/sec_bandana/equipped(mob/user, slot)
	..()
	if(slot != ITEM_SLOT_MASK)
		if(suit)
			suit.RemoveMask()
		else
			qdel(src)

/obj/item/clothing/mask/breath/sec_bandana/AltClick(mob/user)
	suit.RemoveMask()
	return

/obj/item/clothing/mask/breath/sec_bandana/medical
	icon_state = "sec_bandana_medical"
	item_state = "sec_bandana_medical"

/obj/item/clothing/mask/breath/sec_bandana/engineering
	icon_state = "sec_bandana_engi"
	item_state = "sec_bandana_engi"

/obj/item/clothing/mask/breath/sec_bandana/cargo
	icon_state = "sec_bandana_medical"
	item_state = "sec_bandana_medical"

/obj/item/clothing/mask/breath/sec_bandana/science
	icon_state = "sec_bandana_science"
	item_state = "sec_bandana_science"
