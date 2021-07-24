/datum/outfit/traitor
	name = "Traitor"

	uniform = /obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/hooded/ablative
	gloves = /obj/item/clothing/gloves/color/yellow
	mask = /obj/item/clothing/mask/gas
	l_hand = /obj/item/melee/transforming/energy/sword
	r_hand = /obj/item/gun/energy/kinetic_accelerator/crossbow

/datum/outfit/traitor/post_equip(mob/living/carbon/human/H, visualsOnly)
	var/obj/item/melee/transforming/energy/sword/sword = locate() in H.held_items
	sword.icon_state = "swordred"
	sword.worn_icon_state = "swordred"

	H.update_inv_hands()
