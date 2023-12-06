/datum/action/chameleon_outfit/select_outfit(mob/user)
	if(!user || !IsAvailable(feedback = TRUE))
		return FALSE
	var/selected = tgui_input_list(user, "Select outfit to change into", "Chameleon Outfit", outfit_options)
	if(isnull(selected))
		return FALSE
	if(!IsAvailable(feedback = TRUE) || QDELETED(src) || QDELETED(user))
		return FALSE
	if(isnull(outfit_options[selected]))
		return FALSE
	var/outfit_type = outfit_options[selected]
	var/datum/outfit/job/O = new outfit_type()
	var/list/outfit_types = O.get_chameleon_disguise_info()
	var/datum/job/job_datum = SSjob.GetJobType(O.jobtype)
	for(var/V in user.chameleon_item_actions)
		var/datum/action/item_action/chameleon/change/A = V
		var/done = FALSE
		for(var/T in outfit_types)
			for(var/name in A.chameleon_list)
				if(A.chameleon_list[name] == T)
					A.apply_job_data(job_datum)
					A.update_look(user, T)
					outfit_types -= T
					done = TRUE
					break
			if(done)
				break
	//suit hoods
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		//make sure they are actually wearing the suit, not just holding it, and that they have a chameleon hat
		if(istype(H.wear_suit, /obj/item/clothing/suit/chameleon) && istype(H.head, /obj/item/clothing/head/chameleon))
			var/helmet_type
			if(ispath(O.suit, /obj/item/clothing/suit/space/hardsuit))
				var/obj/item/clothing/suit/space/hardsuit/hardsuit = O.suit
				helmet_type = initial(hardsuit.helmettype)
			if(ispath(O.suit, /obj/item/clothing/suit/hooded))
				var/obj/item/clothing/suit/hooded/hooded = O.suit
				helmet_type = initial(hooded.hoodtype)
			if(helmet_type)
				var/obj/item/clothing/head/chameleon/hat = H.head
				hat.chameleon_action.update_look(user, helmet_type)
	qdel(O)
	return TRUE
