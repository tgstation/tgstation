//Captain's Spacesuit
/obj/item/clothing/head/helmet/space/capspace
	name = "space helmet"
	icon_state = "capspace"
	item_state = "capspacehelmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Only for the most fashionable of military figureheads."
	body_parts_covered = HEAD|EARS|EYES
	permeability_coefficient = 0.01
	pressure_resistance = 200 * ONE_ATMOSPHERE
	armor = list(melee = 65, bullet = 50, laser = 50,energy = 25, bomb = 50, bio = 100, rad = 50)
	species_fit = list(VOX_SHAPED)

//Captain's space suit This is not the proper path but I don't currently know enough about how this all works to mess with it.
/obj/item/clothing/suit/armor/captain
	name = "Captain's armor"
	desc = "A bulky, heavy-duty piece of exclusive Nanotrasen armor. YOU are in charge!"
	icon_state = "caparmor"
	item_state = "capspacesuit"
	species_fit = list(VOX_SHAPED)
	w_class = W_CLASS_LARGE
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags = FPRINT
	pressure_resistance = 200 * ONE_ATMOSPHERE
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET
	allowed = list(/obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight,/obj/item/weapon/gun/energy, /obj/item/weapon/gun/projectile, /obj/item/ammo_storage, /obj/item/ammo_casing, /obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_nitrogen)
	slowdown = 1.5
	armor = list(melee = 65, bullet = 50, laser = 50, energy = 25, bomb = 50, bio = 100, rad = 50)
	siemens_coefficient = 0.7
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY