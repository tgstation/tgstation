// Pill bottles for synthetic healing medications
/obj/item/storage/pill_bottle/liquid_solder
	name = "bottle of liquid solder pills"
	desc = "Contains pills used to treat synthetic brain damage."

/obj/item/storage/pill_bottle/liquid_solder/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/liquid_solder(src)

// Contains 4 liquid_solder pills instead of 7, and 10u pills instead of 50u.
// 50u pills heal 375 brain damage, 10u pills heal 75.
/obj/item/storage/pill_bottle/liquid_solder/braintumor
	desc = "Contains diluted pills used to treat synthetic brain damage symptoms. Take one when feeling lightheaded."

/obj/item/storage/pill_bottle/liquid_solder/braintumor/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/pill/liquid_solder/braintumor(src)

/obj/item/storage/pill_bottle/nanite_slurry
	name = "bottle of nanite slurry pills"
	desc = "Contains pills used to treat robotic bodyparts."

/obj/item/storage/pill_bottle/nanite_slurry/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/nanite_slurry(src)

/obj/item/storage/pill_bottle/system_cleaner
	name = "bottle of system cleaner pills"
	desc = "Contains pills used to detoxify synthetic bodies."

/obj/item/storage/pill_bottle/system_cleaner/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/system_cleaner(src)
