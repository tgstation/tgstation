/obj/item/storage/pill_bottle/charcoal
	name = "bottle of charcoal pills"
	desc = "Contains pills used to counter toxins."

/obj/item/storage/pill_bottle/charcoal/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/charcoal(src)

/obj/item/storage/pill_bottle/charcoal/less

/obj/item/storage/pill_bottle/charcoal/less/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/charcoal(src)
