/*
 * Contains:
 * Fire protection
 * Bomb protection
 * Radiation protection
 */

/*
 * Fire protection
 */

/obj/item/clothing/suit/utility
	worn_icon = 'icons/mob/clothing/suits/utility.dmi'

/obj/item/clothing/suit/utility/fire
	name = "emergency firesuit"
	desc = "A suit that helps protect against fire and heat."
	icon_state = "fire"
	inhand_icon_state = "ro_suit"
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/extinguisher, /obj/item/crowbar)
	slowdown = 1
	armor = list(MELEE = 15, BULLET = 5, LASER = 20, ENERGY = 20, BOMB = 20, BIO = 50, FIRE = 100, ACID = 50)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	strip_delay = 60
	equip_delay_other = 60
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/utility/fire/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", alpha = src.alpha)

/obj/item/clothing/suit/utility/fire/firefighter
	icon_state = "firesuit"
	inhand_icon_state = "firefighter"

/obj/item/clothing/suit/utility/fire/heavy
	name = "heavy firesuit"
	desc = "An old, bulky thermal protection suit."
	icon_state = "thermal"
	inhand_icon_state = "ro_suit"
	slowdown = 1.5

/obj/item/clothing/suit/utility/fire/atmos
	name = "firesuit"
	desc = "An expensive firesuit that protects against even the most deadly of station fires. Designed to protect even if the wearer is set aflame."
	icon_state = "atmos_firesuit"
	inhand_icon_state = "firesuit_atmos"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/*
 * Bomb protection
 */
/obj/item/clothing/head/bomb_hood
	name = "bomb hood"
	desc = "Use in case of bomb."
	icon_state = "bombsuit"
	clothing_flags = THICKMATERIAL | SNUG_FIT
	armor = list(MELEE = 20, BULLET = 0, LASER = 20,ENERGY = 30, BOMB = 100, BIO = 0, FIRE = 80, ACID = 50)
	flags_inv = HIDEFACE|HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 70
	equip_delay_other = 70
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = NONE


/obj/item/clothing/suit/utility/bomb_suit
	name = "bomb suit"
	desc = "A suit designed for safety when handling explosives."
	icon_state = "bombsuit"
	inhand_icon_state = "bombsuit"
	w_class = WEIGHT_CLASS_BULKY
	clothing_flags = THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 2
	armor = list(MELEE = 20, BULLET = 0, LASER = 20,ENERGY = 30, BOMB = 100, BIO = 50, FIRE = 80, ACID = 50)
	flags_inv = HIDEJUMPSUIT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	strip_delay = 70
	equip_delay_other = 70
	resistance_flags = NONE


/obj/item/clothing/head/bomb_hood/security
	icon_state = "bombsuit_sec"
	inhand_icon_state = "bombsuit_sec"

/obj/item/clothing/suit/utility/bomb_suit/security
	icon_state = "bombsuit_sec"
	inhand_icon_state = "bombsuit_sec"
	allowed = list(/obj/item/gun/energy, /obj/item/melee/baton, /obj/item/restraints/handcuffs)


/obj/item/clothing/head/bomb_hood/white
	icon_state = "bombsuit_white"
	inhand_icon_state = "bombsuit_white"

/obj/item/clothing/suit/utility/bomb_suit/white
	icon_state = "bombsuit_white"
	inhand_icon_state = "bombsuit_white"

/*
* Radiation protection
*/

/obj/item/clothing/head/radiation
	name = "radiation hood"
	icon_state = "rad"
	desc = "A hood with radiation protective properties. The label reads, 'Made with lead. Please do not consume insulation.'"
	clothing_flags = THICKMATERIAL | SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEFACE|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 60, FIRE = 30, ACID = 30)
	strip_delay = 60
	equip_delay_other = 60
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = NONE

/obj/item/clothing/head/radiation/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/suit/utility/radiation
	name = "radiation suit"
	desc = "A suit that protects against radiation. The label reads, 'Made with lead. Please do not consume insulation.'"
	icon_state = "rad"
	inhand_icon_state = "rad_suit"
	w_class = WEIGHT_CLASS_BULKY
	clothing_flags = THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/geiger_counter)
	slowdown = 1.5
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 60, FIRE = 30, ACID = 30)
	strip_delay = 60
	equip_delay_other = 60
	flags_inv = HIDEJUMPSUIT
	resistance_flags = NONE

/obj/item/clothing/suit/utility/radiation/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/suit/utility/radiation/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", alpha = src.alpha)
