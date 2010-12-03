/obj/closet/firecloset/New()
	..()

	if (prob (1))
		del(src)
		return

	switch (pickweight(list("extinguisher" = 50, "toolbox" = 30, "nothing" = 20)))
		if ("extinguisher")
			new /obj/item/weapon/extinguisher(src)
		if ("toolbox")
			new /obj/item/weapon/storage/toolbox/emergency(src)

	if (prob (30))
		new /obj/item/clothing/mask/breath(src)

	if (prob (30))
		new /obj/item/weapon/tank/emergency_oxygen(src)

	if (prob (10))
		new /obj/item/clothing/suit/fire(src)