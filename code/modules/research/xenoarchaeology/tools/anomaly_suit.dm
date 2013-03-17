
//changes: rad protection up to 100 from 20/50 respectively
/obj/item/clothing/suit/bio_suit/anomaly
	name = "Anomaly suit"
	desc = "A sealed bio suit capable of insulating against exotic alien energies"
	icon_state = "engspace_suit"
	item_state = "engspace_suit"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)

/obj/item/clothing/head/bio_hood/anomaly
	name = "Anomaly hood"
	desc = "A sealed bio hood capable of insulating against exotic alien energies."
	icon_state = "engspace_helmet"
	item_state = "engspace_helmet"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)

/obj/item/clothing/suit/space/anomaly
	name = "Excavation suit"
	desc = "A pressure resistant excavation suit partially capable of insulating against exotic alien energies."
	icon_state = "cespace_suit"
	item_state = "cespace_suit"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank)

/obj/item/clothing/head/helmet/space/anomaly
	name = "Excavation hood"
	desc = "A pressure resistant excavation hood partially capable of insulating against exotic alien energies."
	icon_state = "cespace_helmet"
	item_state = "cespace_helmet"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)
