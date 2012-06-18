/obj/item/clothing/suit/fire
	name = "firesuit"
	desc = "A suit that protects against fire and heat."
	icon_state = "fire"
	item_state = "fire_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	heat_transfer_coefficient = 0.01
	protective_temperature = 10000
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/extinguisher)
	slowdown = 1.0
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/fire/firefighter
	icon_state = "firesuit"
	item_state = "firefighter"


/obj/item/clothing/suit/fire/heavy
	name = "firesuit"
	desc = "A suit that protects against extreme fire and heat."
	//icon_state = "thermal"
	item_state = "ro_suit"
	w_class = 4//bulky item
	protective_temperature = 10000
	slowdown = 1.5

/obj/item/clothing/head/helmet/space/fire_helmet
	name = "fire helmet"
	desc = "A helmet designed to protect against extreme temperature and pressure."
	flags = FPRINT | TABLEPASS | HEADSPACE | HEADCOVERSEYES | BLOCKHAIR
	see_face = 0.0
	permeability_coefficient = 0.01
	heat_transfer_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	icon_state = "hazmat_firered"
	item_state = "hazhat_firered"



/obj/item/clothing/head/radiation
	name = "radiation hood"
	icon_state = "rad"
	desc = "A hood that protects against radiation. Label: Made with lead, do not eat insulation."
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60, rad = 20)

/obj/item/clothing/suit/radiation
	name = "radiation suit"
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
