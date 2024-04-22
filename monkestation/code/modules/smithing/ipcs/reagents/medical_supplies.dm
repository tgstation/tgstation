// I cannot wait to get rid of this. This is so many levels of awful wrapped into one.
/obj/item/reagent_containers/blood/oil
	blood_type = "Oil"
	unique_blood = /datum/reagent/fuel/oil

/obj/item/reagent_containers/pill/liquid_solder
	name = "liquid solder pill"
	desc = "Used to treat synthetic brain damage."
	icon_state = "pill21"
	list_reagents = list(/datum/reagent/medicine/liquid_solder = 10)
	rename_with_volume = TRUE

// Lower quantity solder pill.
// 50u pills heal 375 brain damage, 10u pills heal 75.
/obj/item/reagent_containers/pill/liquid_solder/braintumor
	desc = "Used to treat symptoms of synthetic brain damage."
	list_reagents = list(/datum/reagent/medicine/liquid_solder = 10)

/obj/item/reagent_containers/pill/nanite_slurry
	name = "nanite slurry pill"
	desc = "Used to to induce an overdose for synthetic organ repair."
	icon_state = "pill18"
	list_reagents = list(/datum/reagent/medicine/nanite_slurry = 30) // 10 is OD
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/system_cleaner
	name = "system cleaner pill"
	desc = "Used to detoxify synthetic bodies."
	icon_state = "pill7"
	list_reagents = list(/datum/reagent/medicine/system_cleaner = 10)
	rename_with_volume = TRUE

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
	name = "bottle of concentrated nanite slurry pills"
	desc = "Contains nanite slurry pills used for <b>critical system repair</b> to induce an overdose in a synthetic to repair organs."

/obj/item/storage/pill_bottle/nanite_slurry/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/nanite_slurry(src)

/obj/item/storage/pill_bottle/system_cleaner
	name = "bottle of system cleaner pills"
	desc = "Contains pills used to detoxify synthetic bodies."

/obj/item/storage/pill_bottle/system_cleaner/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/system_cleaner(src)
