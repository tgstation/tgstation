/obj/item/clothing/suit/hooded/explorer/survivor
	name = "survivor suit"
	desc = "A ragged makeshift suit resembling the explorer suit, covered with the emblems of a failed revolution. It's been repaired so many times it's hard to tell if it's more suit or patch. The joints have been redesigned for quicker movement."
	lefthand_file = 'voidcrew/icons/mob/inhands/clothing/lefthand.dmi'
	righthand_file = 'voidcrew/icons/mob/inhands/clothing/righthand.dmi'
	icon = 'voidcrew/icons/obj/clothing/suits.dmi'
	worn_icon = 'voidcrew/icons/mob/clothing/suits.dmi'
	icon_state = "survivor"
	inhand_icon_state = "survivor"
	hoodtype = /obj/item/clothing/head/hooded/explorer/survivor
	armor_type = /datum/armor/hooded_survivor
	resistance_flags = FIRE_PROOF
	slowdown = -0.3 //finally, a reason for shiptesters to steal this

/datum/armor/hooded_survivor
	melee = 15
	bullet = 10
	laser = 10
	energy = 15
	bomb = 20
	fire = 50
	acid = 30

/obj/item/clothing/head/hooded/explorer/survivor
	name = "survivor hood"
	desc = "A loose-fitting hood, patched up with sealant and adhesive. Somewhat protects the head from the environment, but gets the job done."
	icon = 'voidcrew/icons/obj/clothing/hats.dmi'
	worn_icon = 'voidcrew/icons/mob/clothing/head.dmi'
	icon_state = "survivor"
	suit = /obj/item/clothing/suit/hooded/explorer/survivor
	armor_type = /datum/armor/hooded_survivor
	resistance_flags = FIRE_PROOF
