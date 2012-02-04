/obj/item/clothing/head/det_hat
	name = "hat"
	desc = "Someone who wears this will look very smart."
	icon_state = "detective"
	allowed = list(/obj/item/weapon/reagent_containers/food/snacks/candy_corn, /obj/item/weapon/pen)
	armor = list(melee = 50, bullet = 5, laser = 25,energy = 10, bomb = 0, bio = 0, rad = 0)


/obj/item/clothing/suit/det_suit
	name = "coat"
	desc = "An 18th-century multi-purpose trenchcoat. Someone who wears this means serious business."
	icon_state = "detective"
	item_state = "det_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight,/obj/item/weapon/gun/energy,/obj/item/weapon/gun/projectile,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/cigpacket,/obj/item/weapon/lighter,/obj/item/device/detective_scanner,/obj/item/device/taperecorder)
	armor = list(melee = 50, bullet = 10, laser = 25, energy = 10, bomb = 0, bio = 0, rad = 0)


/obj/item/clothing/suit/det_suit/armor
	name = "armor"
	desc = "An armored vest with a detective's badge on it."
	icon_state = "detective-armor"
	item_state = "armor"
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/gun/projectile,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs)
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
