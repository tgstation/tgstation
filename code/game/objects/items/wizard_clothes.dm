/obj/item/clothing/head/wizard/magus
	name = "magus helm"
	icon_state = "magus"
	inhand_icon_state = null
	desc = "A helm worn by the followers of Nar'Sie."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEARS|HIDEEYES|HIDESNOUT
	armor_type = /datum/armor/wizard_magus
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/datum/armor/wizard_magus
	melee = 50
	bullet = 30
	laser = 50
	energy = 50
	bomb = 25
	bio = 10
	fire = 10
	acid = 10

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar'Sie."
	icon_state = "magusred"
	icon = 'icons/obj/clothing/suits/wizard.dmi'
	worn_icon = 'icons/mob/clothing/suits/wizard.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor_type = /obj/item/clothing/head/wizard/magus::armor_type
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
