/obj/item/clothing/suit/armor/secduster
	name = "security duster"
	desc = "A standard-issue armored duster that keeps a security officer protected and fashionable."
	worn_icon = 'monkestation/icons/mob/suit.dmi'
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	icon_state = "cowboy_sec_default"
	item_state = "cowboy_sec_default"
	var/obj/item/clothing/mask/breath/sec_bandana/mask
	var/obj/item/clothing/suit/armor/secduster/suit
	var/mask_adjusted = 0
	var/adjusted_flags = null
	var/masktype = /obj/item/clothing/mask/breath/sec_bandana
	actions_types = list(/datum/action/item_action/toggle_mask)

/obj/item/clothing/suit/armor/secduster/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()

/obj/item/clothing/suit/armor/secduster/Destroy()
	if(!QDELETED(suit))
		qdel(suit)
	suit = null
	return ..()

/obj/item/clothing/suit/armor/secduster/attack_self(mob/user)
	user.update_inv_wear_mask()	//so our mob-overlays update
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/suit/armor/secduster/dropped(mob/user)
	..()
	if(suit)
		suit.RemoveMask()

/obj/item/clothing/suit/armor/secduster/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_OCLOTHING)
		return 1

//departmental sec colors
/obj/item/clothing/suit/armor/secduster/medical
	name = "medical security duster"
	icon_state = "cowboy_sec_medical"
	item_state = "cowboy_sec_medical"
	masktype = /obj/item/clothing/mask/breath/sec_bandana/medical

/obj/item/clothing/suit/armor/secduster/engineering
	name = "engineering security duster"
	icon_state = "cowboy_sec_engi"
	item_state = "cowboy_sec_engi"
	masktype = /obj/item/clothing/mask/breath/sec_bandana/engineering

/obj/item/clothing/suit/armor/secduster/cargo
	name = "cargo security duster"
	icon_state = "cowboy_sec_cargo"
	item_state = "cowboy_sec_cargo"
	masktype = /obj/item/clothing/mask/breath/sec_bandana/cargo

/obj/item/clothing/suit/armor/secduster/science
	name = "science security duster"
	icon_state = "cowboy_sec_science"
	item_state = "cowboy_sec_science"
	masktype = /obj/item/clothing/mask/breath/sec_bandana/science
