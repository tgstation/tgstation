/obj/structure/closet/wardrobe/black/PopulateContents()
	. = ..()
	
	if(prob(40))
		new /obj/item/clothing/neck/cloak/black(src)

/obj/structure/closet/wardrobe/green/PopulateContents()
	. = ..()

	if(prob(40))
		new /obj/item/clothing/neck/cloak/green(src)

/obj/structure/closet/wardrobe/mixed/PopulateContents()
	. = ..()

	if(prob(40))
		new /obj/item/clothing/neck/cloak/black(src)
	if(prob(40))
		new /obj/item/clothing/neck/cloak/green(src)
