/obj/structure/closet/secure_closet/bar
	name = "booze storage"
	req_access = list(access_bar)
	icon_state = "cabinet"
	burn_state = FLAMMABLE
	burntime = 20

/obj/structure/closet/secure_closet/bar/New()
	..()
	for(var/i in 1 to 10)
		new /obj/item/weapon/reagent_containers/food/drinks/beer( src )
