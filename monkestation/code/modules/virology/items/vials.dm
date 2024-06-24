/obj/item/storage/box/tube
	name = "box of test tubes"

/obj/item/storage/box/tube/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/cup/tube( src )
