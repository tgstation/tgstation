/obj/item/reagent_containers/applicator/pill/liquid_solder
	name = "liquid solder pill"
	desc = "Used to treat synthetic brain damage."
	icon_state = "pill21"
	list_reagents = list(/datum/reagent/medicine/liquid_solder = 10)
	rename_with_volume = TRUE

// Lower quantity solder pill.
// 50u pills heal 375 brain damage, 10u pills heal 75.
/obj/item/reagent_containers/applicator/pill/liquid_solder/braintumor
	desc = "Used to treat symptoms of synthetic brain damage."
	list_reagents = list(/datum/reagent/medicine/liquid_solder = 10)

/obj/item/reagent_containers/applicator/pill/nanite_slurry
	name = "nanite slurry pill"
	desc = "Used to repair robotic bodyparts."
	icon_state = "pill18"
	list_reagents = list(/datum/reagent/medicine/nanite_slurry = 15) // 20 is OD
	rename_with_volume = TRUE

/obj/item/reagent_containers/applicator/pill/system_cleaner
	name = "system cleaner pill"
	desc = "Used to detoxify synthetic bodies."
	icon_state = "pill7"
	list_reagents = list(/datum/reagent/medicine/system_cleaner = 10)
	rename_with_volume = TRUE
