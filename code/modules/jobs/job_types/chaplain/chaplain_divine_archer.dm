
// this costume has so many fugging parts 😭. fuck it, it's a file.
//in fact, we should strive to make the chaplain kits of this quality, moreso than the other way around.

/// undersuit
/obj/item/clothing/under/rank/civilian/chaplain/divine_archer
	name = "divine archer's garb"
	desc = "Inner garb for divine archers."
	icon_state = "archergarb"
	inhand_icon_state = "archergarb"
	can_adjust = TRUE

/// suit
/obj/item/clothing/suit/hooded/chaplain_hoodie/divine_archer
	name = "divine archer coat"
	desc = "Outer coat for divine archers. Offers some protection."
	icon_state = "archercoat"
	inhand_icon_state = "archercoat"
	body_parts_covered = CHEST|GROIN|LEGS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor_type = /datum/armor/chaplainsuit_armor_weaker
	strip_delay = 80
	equip_delay_other = 60
	hoodtype = /obj/item/clothing/head/hooded/chaplain_hood/divine_archer
	hood_up_affix = ""

/datum/armor/chaplainsuit_armor_weaker
	melee = 40
	bullet = 5
	laser = 5
	energy = 5
	fire = 60
	acid = 60
	wound = 10

/// hood
/obj/item/clothing/head/hooded/chaplain_hood/divine_archer
	name = "divine archer hood"
	desc = "A divine hood included, because have you ever got the sun in your eyes during archery? Oh, it's just the worst."
	icon_state = "archerhood"
	armor_type = /datum/armor/chaplainsuit_armor_weaker

/// gloves
/obj/item/clothing/gloves/divine_archer
	name = "divine archer bracers"
	desc = "Bracers, a wise choice for archers who do not want their outfit to get in the way of drawing and firing their weapon."
	icon_state = "archerbracers"
	inhand_icon_state = "archerbracers"
	body_parts_covered = ARMS|HANDS
	strip_delay = 40
	equip_delay_other = 20
	resistance_flags = NONE
	armor_type = /datum/armor/chaplainsuit_armor_weaker

/// boots
/obj/item/clothing/shoes/divine_archer
	name = "divine archer boots"
	desc = "Boots, For steady footing while aiming."
	icon_state = "archerboots"
	inhand_icon_state = "archerboots"
	body_parts_covered = LEGS|FEET
	strip_delay = 30
	equip_delay_other = 50
	resistance_flags = NONE
	fastening_type = SHOES_SLIPON
	armor_type = /datum/armor/shoes_divine_archer

/datum/armor/shoes_divine_archer
	melee = 10
	bullet = 5
	laser = 5
	energy = 5
	fire = 60
	acid = 60
	wound = 10
