/obj/item/reagent_containers/blood/slime
	blood_type = "OOZE"
	unique_blood = /datum/reagent/toxin/slimeooze

/obj/item/reagent_containers/blood/slime/examine()
	.= ..()
	. += span_notice("This appears to be oozeling blood.")
//while this is the modular folder for monkestation specific blood packs, you will still need to modify one section of code on the original blood pack file for updating them
