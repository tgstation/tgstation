/obj/item/weapon/melee/cultblade
	name = "Cult Blade"
	desc = "An arcane weapon wielded by the followers of Nar-Sie"
	icon_state = "cultblade"
	item_state = "cultblade"
	flags = FPRINT | ONBELT | TABLEPASS
	force = 40
	throwforce = 10



/obj/item/clothing/head/culthood
	name = "cult hood"
	icon_state = "culthood"
	desc = "A hood worn by the followers of Nar-Sie."
	see_face = 0
	flags = FPRINT|TABLEPASS|HEADSPACE|HEADCOVERSEYES
	armor = list(melee = 30, bullet = 10, laser = 5, taser = 5, bomb = 0, bio = 0, rad = 0)



/obj/item/clothing/suit/cultrobes
	name = "cult robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie"
	icon_state = "cultrobes"
	item_state = "cultrobes"
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50, taser = 20, bomb = 25, bio = 10, rad = 0)
