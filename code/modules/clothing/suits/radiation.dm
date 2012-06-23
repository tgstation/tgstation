/obj/item/clothing/head/radiation
	name = "Radiation Hood"
	icon_state = "rad"
	desc = "A hood with radiation protective properties. Label: Made with lead, do not eat insulation"
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60, rad = 100)

/obj/item/clothing/suit/radiation
	name = "Radiation suit"
	desc = "A suit that protects against radiation. Label: Made with lead, do not eat insulation."
	icon_state = "rad"
	item_state = "rad_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	heat_transfer_coefficient = 0.30
	protective_temperature = 1000
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1.5
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60, rad = 100)
	flags_inv = HIDEJUMPSUIT
