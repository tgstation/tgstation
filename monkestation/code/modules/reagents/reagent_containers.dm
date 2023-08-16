/obj/item/reagent_containers/extrapolator_act(mob/user, obj/item/extrapolator/E, scan = FALSE)
	var/datum/reagent/blood/B = locate() in reagents.reagent_list
	if(!B)
		return FALSE
	if(scan)
		E.scan(src, B.get_diseases(), user)
		return TRUE
	else
		E.extrapolate(src, B.get_diseases(), user, TRUE)
		return TRUE
