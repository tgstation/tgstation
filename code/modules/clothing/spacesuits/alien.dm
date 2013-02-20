/obj/item/clothing/head/helmet/space/helmet_soghun_cheap
	name = "NT breacher helmet"
	desc = "Hey! Watch it with that thing! It's a knock-off of a soghun battle-helm, and that spike could put someone's eye out."
	icon_state = "sog_helm_cheap"
	item_state = "sog_helm_cheap"
	color = "sog_helm_cheap"
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 50)
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECITON_TEMPERATURE

/obj/item/clothing/suit/space/rig_soghun_cheap
	name = "NT breacher chassis"
	desc = "A cheap NT knock-off of a soghun battle-rig. Looks like a fish, moves like a fish, steers like a cow."
	icon_state = "rig-soghun-cheap"
	item_state = "rig-soghun-cheap"
	slowdown = 2
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/weapon/rcd)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECITON_TEMPERATURE