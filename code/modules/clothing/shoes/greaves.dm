/obj/item/clothing/shoes/greaves
	name = "greaves"
	desc = "These tactical greaves offer protection to the knees and feet. Keeps you an adventurer for longer."
	icon_state = "jackboots"
	inhand_icon_state = "jackboots"
	strip_delay = 80
	equip_delay_other = 50
	resistance_flags = NONE
	armor_type = /datum/armor/greaves_combat
	can_be_tied = FALSE
	body_parts_covered = LEGS|FEET

/datum/armor/greaves_combat
	bio = 90
	fire = 80
	acid = 50

/obj/item/clothing/shoes/greaves/bulletproof
	name = "bulletproof greaves"
	desc = "Type III heavy bulletproof greaves that excels in protecting the wearer against traditional projectile weaponry to the knees. Keeps you an adventurer for longer."
	icon_state = "bulletproof"
	inhand_icon_state = "jackboots"
	strip_delay = 80
	equip_delay_other = 50
	resistance_flags = NONE
	armor_type = /datum/armor/armor_bulletproof
	can_be_tied = FALSE
	body_parts_covered = LEGS|FEET

/obj/item/clothing/shoes/greaves/riot
	name = "riot greaves"
	desc = "Riot greaves."
	icon_state = "riot"
	inhand_icon_state = "jackboots"
	strip_delay = 80
	equip_delay_other = 50
	resistance_flags = NONE
	armor_type = /datum/armor/armor_riot
	can_be_tied = FALSE
	body_parts_covered = LEGS|FEET
