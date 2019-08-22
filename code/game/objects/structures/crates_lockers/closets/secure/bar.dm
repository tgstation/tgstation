/obj/structure/closet/secure_closet/bar
	name = "booze storage"
	req_access = list(ACCESS_BAR)
	icon_state = "cabinet"
	resistance_flags = FLAMMABLE
	max_integrity = 70

/obj/structure/closet/secure_closet/bar/PopulateContents()
	..()
	for(var/i in 1 to 10)
		new /obj/item/reagent_containers/food/drinks/beer( src )
		new /obj/item/reagent_containers/food/drinks/soda_cans/space_bitters( src ) // austation -- Adds space bitters beer to the bartender's locker
	new /obj/item/etherealballdeployer(src)
