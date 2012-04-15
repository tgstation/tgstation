/obj/structure/closet/emcloset/New()
	..()

	if (prob(40))
		new /obj/item/weapon/storage/toolbox/emergency(src)

	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/emergency_oxygen(src)
	var/counter = 0
	while(prob(60) && counter < 3)
		new /obj/item/weapon/tank/emergency_oxygen(src)
		counter++
	counter = 0
	while(prob(60) && counter < 3)
		new /obj/item/clothing/mask/breath(src)
		counter++

/obj/structure/closet/emcloset/legacy/New()
	new /obj/item/weapon/tank/oxygen(src)
	new /obj/item/clothing/mask/gas(src)