/obj/item/storage/box/buckshotroulette
	name = "box of spent shotgun shells"
	desc = "A box full of lethal shotgun shells, well they would be lethal if they were full, these ones are spent."
	icon_state = "lethalshot_box"
	illustration = null

/obj/item/storage/box/buckshotroulette/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/buckshot/spent(src)
