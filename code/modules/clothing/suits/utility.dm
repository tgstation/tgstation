/*
 * Contains:
 *		Fire protection
 *		Bomb protection
 *		Radiation protection
 */

/*
 * Fire protection
 */

/obj/item/clothing/suit/fire
	name = "firesuit"
	desc = "A suit that protects against fire and heat."
	icon_state = "fire"
	item_state = "fire_suit"
	w_class = 4
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/extinguisher)
	slowdown = 1.0
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL | STOPSPRESSUREDMAGE
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT


/obj/item/clothing/suit/fire/firefighter
	icon_state = "firesuit"
	item_state = "firefighter"


/obj/item/clothing/suit/fire/heavy
	name = "heavy firesuit"
	desc = "An old, bulky thermal protection suit."
	icon_state = "thermal"
	item_state = "ro_suit"
	slowdown = 1.5

/*
 * Bomb protection
 */
/obj/item/clothing/head/bomb_hood
	name = "bomb hood"
	desc = "Use in case of bomb."
	icon_state = "bombsuit"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	armor = list(melee = 40, bullet = 0, laser = 20,energy = 10, bomb = 100, bio = 0, rad = 0)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT


/obj/item/clothing/suit/bomb_suit
	name = "bomb suit"
	desc = "A suit designed for safety when handling explosives."
	icon_state = "bombsuit"
	item_state = "bombsuit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags = FPRINT | TABLEPASS
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 2
	armor = list(melee = 40, bullet = 0, laser = 20,energy = 10, bomb = 100, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT



/obj/item/clothing/head/bomb_hood/security
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"


/obj/item/clothing/suit/bomb_suit/security
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs)

/*
 * Radiation protection
 */
/obj/item/clothing/head/radiation
	name = "radiation hood"
	icon_state = "rad"
	desc = "A hood with radiation protective properties. Label: Made with lead, do not eat insulation"
	flags = FPRINT|TABLEPASS|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60, rad = 100)


/obj/item/clothing/suit/radiation
	name = "radiation suit"
	desc = "A suit that protects against radiation. Label: Made with lead, do not eat insulation."
	icon_state = "rad"
	item_state = "rad_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1.5
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60, rad = 100)
	flags_inv = HIDEJUMPSUIT
