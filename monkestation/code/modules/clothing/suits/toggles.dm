//for making masks
/obj/item/clothing/suit/armor/secduster/Initialize()
	MakeMask()
	. = ..()

/obj/item/clothing/suit/armor/secduster/Destroy()
	if(!QDELETED(mask))
		mask.suit = null
		mask = null
	return ..()

/obj/item/clothing/mask/breath/sec_bandana/Destroy()
	if(suit)
		suit.mask = null
		usr.update_action_buttons_icon()
	return ..()

/obj/item/clothing/suit/armor/secduster/proc/MakeMask()
	if(!masktype)
		return
	if(!mask)
		var/obj/item/clothing/mask/breath/sec_bandana/W = new masktype(src)
		W.suit = src
		mask = W

/obj/item/clothing/suit/armor/secduster/ui_action_click()
	..()
	ToggleMask()

/obj/item/clothing/suit/armor/secduster/equipped(mob/user, slot)
	if(!masktype)
		return
	if(slot != ITEM_SLOT_OCLOTHING)
		RemoveMask()
	..()

/obj/item/clothing/suit/armor/secduster/proc/RemoveMask()
	if(!mask)
		return
	suittoggled = FALSE
	if(ishuman(mask.loc))
		var/mob/living/carbon/H = mask.loc
		H.transferItemToLoc(mask, src, TRUE)
		H.update_inv_wear_suit()
		to_chat(H, "<span class='notice'>You pull down the bandana.</span>")
		playsound(src.loc, 'sound/items/handling/cloth_drop.ogg', 50, 1)
		usr.update_action_buttons_icon()
	else
		mask.forceMove(src)

/obj/item/clothing/suit/armor/secduster/dropped()
	..()
	RemoveMask()

/obj/item/clothing/suit/armor/secduster/proc/ToggleMask()
	var/mob/living/carbon/human/H = src.loc
	if(!masktype)
		return
	if(!mask)
		return
	if(!suittoggled)
		if(ishuman(src.loc))
			if(H.wear_suit != src)
				to_chat(H, "<span class='warning'>You must be wearing [src] to toggle the bandana!</span>")
				return
			if(H.wear_mask)
				to_chat(H, "<span class='warning'>You're already wearing something on your face!</span>")
				return
			else if(H.equip_to_slot_if_possible(mask,ITEM_SLOT_MASK,0,0,1))
				to_chat(H, "<span class='notice'>You pull up the bandana over your face.</span>")
				suittoggled = TRUE
				H.update_inv_wear_suit()
				playsound(src.loc, 'sound/items/handling/cloth_drop.ogg', 50, 1)
	else
		RemoveMask()
