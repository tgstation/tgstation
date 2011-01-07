/obj/closet/firecloset/New()
	..()
	sleep(2)
	if (prob (1))
		del(src)
		return

	new /obj/item/weapon/extinguisher(src)

	new /obj/item/clothing/mask/gas(src)

	new /obj/item/weapon/tank/emergency_oxygen(src)

	new /obj/item/clothing/suit/fire/firefighter(src)