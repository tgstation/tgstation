/obj/structure/closet/emcloset/New()
	..()

	if (prob(40))
		new /obj/item/weapon/storage/toolbox/emergency(src)

	switch (pickweight(list("small" = 40, "aid" = 25, "tank" = 20, "both" = 10, "nothing" = 4, "delete" = 1)))
		if ("small")
			new /obj/item/weapon/tank/emergency_oxygen(src)
			new /obj/item/weapon/tank/emergency_oxygen(src)

		if ("aid")
			new /obj/item/weapon/tank/emergency_oxygen(src)
			new /obj/item/weapon/storage/firstaid/o2(src)

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

		//If you want to re-add fire, just add "fire" = 15 to the pick list.
		/*if ("fire")
			new /obj/structure/closet/firecloset(src.loc)
			del(src)*/

/obj/structure/closet/emcloset/legacy/New()
	new /obj/item/weapon/tank/oxygen(src)
	new /obj/item/clothing/mask/gas(src)