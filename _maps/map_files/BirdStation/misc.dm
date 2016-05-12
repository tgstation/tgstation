//special birdstation survival boxes

/obj/item/weapon/storage/box/birdsurv/New()
	..()
	contents = list()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen(src)
	new /obj/item/device/radio/off(src)
	return

/obj/item/weapon/storage/box/birdeng/New()
	..()
	contents = list()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen(src)
	new /obj/item/device/radio/off(src)
	return

/obj/item/weapon/storage/box/birdsec/New()
	..()
	contents = list()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen(src)
	new /obj/item/device/radio/off(src)
	return
