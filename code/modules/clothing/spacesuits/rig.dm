/obj/item/clothing/head/helmet/space/rig
	name = "Rig helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "rig-engineering"
	item_state = "rig_helm"
	armor = list(melee = 40, bullet = 5, laser = 20, taser = 5, bomb = 35, bio = 50, rad = 50)
	allowed = list(/obj/item/device/flashlight)

/obj/item/clothing/head/helmet/space/rig/mining
	icon_state = "rig-mining"
	item_state = "rig_helm"

/obj/item/clothing/suit/space/rig
	name = "Rig suit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "rig-engineering"
	item_state = "rig_suit"
	radiation_protection = 0.50
	slowdown = 2
	armor = list(melee = 40, bullet = 5, laser = 20, taser = 5, bomb = 35, bio = 50, rad = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/satchel,/obj/item/device/t_scanner)

/obj/item/clothing/suit/space/rig/mining
	icon_state = "rig-mining"
	item_state = "rig_suit"