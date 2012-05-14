/obj/item/clothing/head/bomb_hood
	name = "bomb hood"
	desc = "A hood that protect from explosions. Also provides moderate protection."
	icon_state = "bombsuit"
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 10, bomb = 100, bio = 0, rad = 0)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES

/obj/item/clothing/suit/bomb_suit
	name = "bomb suit"
	desc = "A suit used for safely disposing explosives. Also provides moderate protection."
	icon_state = "bombsuit"
	item_state = "bombsuit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	heat_transfer_coefficient = 0.30
	flags = FPRINT | TABLEPASS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 3.5 //To compensate for the extra armour.
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 10, bomb = 100, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT


/obj/item/clothing/head/bomb_hood/security
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"

/obj/item/clothing/suit/bomb_suit/security
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs)
