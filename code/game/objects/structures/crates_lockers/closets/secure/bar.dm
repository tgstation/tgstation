/obj/structure/closet/secure_closet/bar
	name = "booze storage"
	req_access = list(ACCESS_BAR)
	icon_state = "cabinet"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
	door_anim_time = 0 // no animation
	paint_jobs = null

/obj/structure/closet/secure_closet/bar/PopulateContents()
	..()
	for(var/i in 1 to 10)
		new /obj/item/reagent_containers/cup/glass/bottle/beer(src)
	new /obj/item/etherealballdeployer(src)
	new /obj/item/roulette_wheel_beacon(src)

/obj/structure/closet/secure_closet/bar/all_access
	req_access = null

/obj/structure/closet/secure_closet/bar/lavaland_bartender_booze/PopulateContents()
	new /obj/item/vending_refill/cigarette(src)
	new /obj/item/vending_refill/boozeomat(src)
	new /obj/item/storage/backpack/duffelbag(src)
	new /obj/item/etherealballdeployer(src)
	for(var/i in 1 to 14)
		new /obj/item/reagent_containers/cup/glass/bottle/beer/light(src)
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/cup/glass/colocup(src)

/obj/structure/closet/secure/closet/bar/lavaland_bartender_clothes
	name = "bartender's closet"

/obj/structure/closet/secure_closet/bar/lavaland_bartender_clothes/PopulateContents()
	new /obj/item/clothing/neck/beads(src)
	new /obj/item/clothing/glasses/sunglasses/reagent(src)
	new /obj/item/clothing/suit/costume/hawaiian(src)
	new /obj/item/clothing/shoes/sandal/beach(src)

