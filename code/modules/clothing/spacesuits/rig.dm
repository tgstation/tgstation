/obj/item/clothing/head/helmet/space/rig
	name = "engineer RIG helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "rig-engineering"
	item_state = "rig_helm"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/device/flashlight)

/obj/item/clothing/head/helmet/space/rig/mining
	name = "mining RIG helmet"
	icon_state = "rig-mining"

/obj/item/clothing/head/helmet/space/rig/elite
	name = "advanced RIG helmet"
	icon_state = "rig-white"

/obj/item/clothing/head/helmet/space/rig/engspace_helmet
	name = "engineering space helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding and a visor that can be toggled on and off."
	icon_state = "engspace_helmet"
	item_state = "engspace_helmet"
	see_face = 0.0
	var/up = 0

/obj/item/clothing/head/helmet/space/rig/security
	name = "security RIG helmet"
	icon_state = "rig-security"
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)

/obj/item/clothing/suit/space/rig
	name = "engineer RIG suit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "rig-engineering"
	item_state = "rig_suit"
	protective_temperature = 5000 //For not dieing near a fire, but still not being great in a full inferno
	slowdown = 2
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 60)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/satchel,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/weapon/rcd)

/obj/item/clothing/suit/space/rig/mining
	icon_state = "rig-mining"
	name = "mining RIG suit"

/obj/item/clothing/suit/space/rig/elite
	icon_state = "rig-white"
	name = "advanced RIG suit"
	protective_temperature = 10000

/obj/item/clothing/suit/space/rig/engspace_suit
	name = "engineering space suit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "engspace_suit"
	item_state = "engspace_suit"

/obj/item/clothing/suit/space/rig/security
	name = "security RIG suit"
	desc = "A suit specially designed for security to offer minor protection from environmental hazards, and greater protection from human hazards"
	icon_state = "rig-security"
	item_state = "rig-security"
	protective_temperature = 3000
	slowdown = 1
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	allowed = list(/obj/item/weapon/gun/energy/laser, /obj/item/weapon/gun/energy/pulse_rifle, /obj/item/device/flashlight, /obj/item/weapon/tank/emergency_oxygen, /obj/item/weapon/gun/energy/taser, /obj/item/weapon/melee/baton)
