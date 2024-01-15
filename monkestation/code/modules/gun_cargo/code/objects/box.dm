/obj/item/storage/box/syringes/piercing
	name = "piercing syringe box"
	desc = "A five-pack of piercing syringes."

/obj/item/storage/box/syringes/piercing/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/syringe/piercing(src)

/obj/item/storage/box/syringes/bluespace
	name = "bluespace syringe box"
	desc = "A three-pack of piercing syringes."

/obj/item/storage/box/syringes/piercing/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/syringe/bluespace(src)
