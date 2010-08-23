/obj/closet/emcloset/New()
	..()

	if (prob(40))
		new /obj/item/weapon/storage/toolbox/emergency(src)

	switch (pickweight(list("small" = 20, "mask" = 5, "tank" = 4, "both" = 2, "nothing" = 1, "delete" = 1)))
		if ("small")
			new /obj/item/weapon/tank/emergency_oxygen(src)
			new /obj/item/weapon/tank/emergency_oxygen(src)

		if ("mask")
			new /obj/item/clothing/mask/breath(src)

		if ("tank")
			new /obj/item/weapon/tank/air(src)

		if ("both")
			new /obj/item/weapon/tank/emergency_oxygen(src)
			new /obj/item/clothing/mask/breath(src)

		if ("nothing")
			// doot

		// teehee
		if ("delete")
			del(src)
