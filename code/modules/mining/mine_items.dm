/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "Light emitter"
	anchored = 1
	invisibility = 101
	var/set_luminosity = 8
	var/set_cap = 0

/obj/effect/light_emitter/New()
	..()
	set_light(set_luminosity, set_cap)

/**********************Miner Lockers**************************/

/obj/structure/closet/wardrobe/miner
	name = "mining wardrobe"
	icon_door = "mixed"

/obj/structure/closet/wardrobe/miner/PopulateContents()
	new /obj/item/weapon/storage/backpack/duffelbag(src)
	new /obj/item/weapon/storage/backpack/explorer(src)
	new /obj/item/weapon/storage/backpack/satchel/explorer(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "mining"
	req_access = list(GLOB.access_mining)

/obj/structure/closet/secure_closet/miner/PopulateContents()
	..()
	new /obj/item/stack/sheet/mineral/sandbags(src, 5)
	new /obj/item/weapon/storage/box/emptysandbags(src)
	new /obj/item/weapon/shovel(src)
	new /obj/item/weapon/pickaxe/mini(src)
	new /obj/item/device/radio/headset/headset_cargo/mining(src)
	new /obj/item/device/flashlight/seclite(src)
	new /obj/item/weapon/storage/bag/plants(src)
	new /obj/item/weapon/storage/bag/ore(src)
	new /obj/item/device/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/weapon/gun/energy/kinetic_accelerator(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/weapon/survivalcapsule(src)
	new /obj/item/device/assault_pod/mining(src)


/**********************Shuttle Computer**************************/

/obj/machinery/computer/shuttle/mining
	name = "Mining Shuttle Console"
	desc = "Used to call and send the mining shuttle."
	circuit = /obj/item/weapon/circuitboard/computer/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away;landing_zone_dock;mining_public"
	no_destination_swap = 1
	var/global/list/dumb_rev_heads = list()

/obj/machinery/computer/shuttle/mining/attack_hand(mob/user)
	if(user.z == ZLEVEL_STATION && user.mind && (user.mind in SSticker.mode.head_revolutionaries) && !(user.mind in dumb_rev_heads))
		to_chat(user, "<span class='warning'>You get a feeling that leaving the station might be a REALLY dumb idea...</span>")
		dumb_rev_heads += user.mind
		return
	..()

/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "Mining car (not for rails)"
	icon_state = "miningcar"
