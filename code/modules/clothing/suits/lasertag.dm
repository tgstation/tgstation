/obj/item/clothing/suit/bluetag
	name = "blue laser tag armor"
	desc = "A piece of plastic armor. It has sensors that react to red light." //Lasers are concentrated light
	icon_state = "bluetag"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = null
	blood_overlay_type = "armor"
	body_parts_covered = CHEST
	allowed = list (/obj/item/gun/energy/laser/bluetag)
	resistance_flags = NONE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/bluetag/equipped(mob/equipper, slot)
	. = ..()
	if (slot != ITEM_SLOT_OCLOTHING)
		return
	equipper.AddComponentFrom(REF(src), /datum/component/lasertag, LASERTAG_TEAM_BLUE)


/obj/item/clothing/suit/bluetag/dropped(mob/living/user)
	. = ..()
	user.RemoveComponentSource(REF(src), /datum/component/lasertag)

/obj/item/clothing/suit/redtag
	name = "red laser tag armor"
	desc = "A piece of plastic armor. It has sensors that react to blue light."
	icon_state = "redtag"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = null
	blood_overlay_type = "armor"
	body_parts_covered = CHEST
	allowed = list (/obj/item/gun/energy/laser/redtag)
	resistance_flags = NONE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON


/obj/item/clothing/suit/redtag/equipped(mob/equipper, slot)
	. = ..()
	if (slot != ITEM_SLOT_OCLOTHING)
		return
	equipper.AddComponentFrom(REF(src), /datum/component/lasertag, LASERTAG_TEAM_RED)


/obj/item/clothing/suit/redtag/dropped(mob/living/user)
	. = ..()
	user.RemoveComponentSource(REF(src), /datum/component/lasertag)
