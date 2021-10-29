///////////////////
//    Clothing   //
///////////////////

/obj/item/clothing/under/rank/civilian/linen
	name = "linen shirt"
	desc = "A plain generic-looking linen shirt and trousers."
	icon = 'modular_skyrat/modules/modular_items/icons/obj/modular_clothing.dmi'
	worn_icon = 'modular_skyrat/modules/modular_items/icons/mob/modular_clothing.dmi'
	icon_state = "burlap"
	alt_covers_chest = FALSE

/obj/item/clothing/under/rank/civilian/linen/slave
	name = "slave shirt"
	desc = "Something to cover up the body of a slave. It has irremovable sensors chips locked on tracking mode."
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	strip_delay = 50
// Prison clothing, but with slave flavour. Think 1800s colonial America. Drab-coloured flimsy clothing.

/obj/item/clothing/under/rank/security/bdu
	name = "battle dress uniform"
	desc = "An unassuming green shirt and tan trousers. Inside is a thin kevlar lining, it's marked as slash-resistant. Another tag says machine wash at 40C, 800RPM."
	icon = 'modular_skyrat/modules/modular_items/icons/obj/modular_clothing.dmi'
	worn_icon = 'modular_skyrat/modules/modular_items/icons/mob/modular_clothing.dmi'
	icon_state = "fatigues"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 30, ACID = 30, WOUND = 10)
	strip_delay = 50
	alt_covers_chest = FALSE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
// This is equivalent to a security jumpsuit, it has a generic military colour scheme.

/obj/item/clothing/under/rank/civilian/skirt
	name = "fashionable skirt"
	desc = "A black skirt with a fashionable gold-ish yellow trim. It's tied up at the side. It doesn't cover up the chest..."
	icon = 'modular_skyrat/modules/modular_items/icons/obj/modular_clothing.dmi'
	worn_icon = 'modular_skyrat/modules/modular_items/icons/mob/modular_clothing.dmi'
	worn_icon_digi = 'modular_skyrat/modules/modular_items/icons/mob/modular_clothing.dmi'
	icon_state = "skirt"
	can_adjust = FALSE
	body_parts_covered = GROIN|LEGS
	fitted = FEMALE_UNIFORM_TOP

