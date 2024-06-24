/obj/item/reagent_containers/proc/reagent_processing()
	for(var/datum/reagent/listed_reagent in reagents.reagent_list)
		if(listed_reagent.requires_process)
			listed_reagent.reagent_fire(src)
