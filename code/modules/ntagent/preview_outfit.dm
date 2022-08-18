/datum/outfit/ntagent_preview
	name = "Nanotrasen Agent (Preview Only)"

	back = /obj/item/mod/control/pre_equipped/empty/ntagentmod
	l_hand = /obj/item/gun/energy/e_gun/advtaser
	r_hand = /obj/item/melee/energy/sword/saber/blue

/datum/outfit/ntagent_preview/post_equip(mob/living/carbon/human/H, visualsOnly)
	var/obj/item/mod/module/armor_booster/booster = locate() in H.back
	booster.active = TRUE
	H.update_worn_back()
	var/obj/item/melee/energy/sword/sword = locate() in H.held_items
	sword.icon_state = "e_sword_on_blue"
	sword.worn_icon_state = "e_sword_on_blue"

	H.update_held_items()
