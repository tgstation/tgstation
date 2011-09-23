/obj/item/clothing/head/helmet/space/rig
	name = "engineer RIG helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "rig-engineering"
	item_state = "rig_helm"
	radiation_protection = 0.25
	armor = list(melee = 40, bullet = 5, laser = 20, taser = 5, bomb = 35, bio = 50, rad = 50)
	allowed = list(/obj/item/device/flashlight)

/obj/item/clothing/head/helmet/space/rig/mining
	name = "mining RIG helmet"
	icon_state = "rig-mining"
	item_state = "rig_helm"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has extra protection against common mining hazards."
	armor = list(melee = 45, bullet = 10, laser = 20, taser = 5, bomb = 35, bio = 50, rad = 25) //Slightly more robust since it doesn't have extra radiation shielding.

/obj/item/clothing/head/helmet/space/rig/elite
	name = "Elite RIG helmet"
	icon_state = "whiterig"
	item_state = "whiterig"
	desc = "A special armored helmet designed for work in space battlefield conditions."
	armor = list(melee = 60, bullet = 50, laser = 30, taser = 15, bomb = 40, bio = 50, rad = 30)

/obj/item/clothing/suit/space/rig
	name = "engineer RIG suit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "rig-engineering"
	item_state = "rig_suit"
	radiation_protection = 0.50
	protective_temperature = 5000 //For not dieing near a fire, but still not being great in a full inferno
	slowdown = 2
	armor = list(melee = 40, bullet = 5, laser = 20, taser = 5, bomb = 35, bio = 50, rad = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/satchel,/obj/item/device/t_scanner)

/obj/item/clothing/suit/space/rig/mining
	icon_state = "rig-mining"
	item_state = "rig_suit"
	name = "mining RIG suit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has extra protection against common mining hazards."
	armor = list(melee = 45, bullet = 10, laser = 20, taser = 5, bomb = 35, bio = 50, rad = 25) //Slightly more robust since it doesn't have extra radiation shielding.

/obj/item/clothing/suit/space/rig/elite
	icon_state = "whiterig"
	item_state = "whiterig"
	name = "Elite RIG suit"
	desc = "A special suit that protects against hazardous, low pressure battlefield enviroments. Designed to hold larger oxygen tanks and advanced Nanotrasen tools."
	protective_temperature = 10000
	armor = list(melee = 60, bullet = 50, laser = 30, taser = 15, bomb = 40, bio = 50, rad = 30)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/satchel,/obj/item/device/t_scanner,/obj/item/weapon/satchel/pickaxe, /obj/item/weapon/rcd)