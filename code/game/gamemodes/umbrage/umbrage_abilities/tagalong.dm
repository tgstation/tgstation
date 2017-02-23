//Melds with a mob's shadow, allowing the caster to "shadow" (HA) them while they're not in darkness.
/datum/action/innate/umbrage/tagalong
	name = "Tagalong"
	id = "tagalong"
	desc = "Melds with a target's shadow, allowing you to accompany them into lit areas. Only works on targets not in darkness."
	button_icon_state = "umbrage_tagalong"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 50
	lucidity_cost = 2
	blacklisted = 0
	var/mob/living/tagging_along

/datum/action/innate/umbrage/tagalong/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/action/innate/umbrage/tagalong/process()
	if(!tagging_along)
		return STOP_PROCESSING(SSprocessing, src)
	var/turf/T = get_turf(tagging_along)
	if(T.get_lumcount() < 2)
		owner.forceMove(get_turf(tagging_along))
		owner.visible_message("<span class='warning'>[owner] suddenly manifests from the dark!</span>", "<span class='warning'>You are forcibly ejected from [tagging_along]'s shadow!</span>")
		owner.Weaken(2)
		STOP_PROCESSING(SSprocessing, src)
		tagging_along = null
		return TRUE

/datum/action/innate/umbrage/tagalong/Activate()
	if(tagging_along)
		owner.visible_message("<span class='warning'>[tagging_along]'s shadow suddenly breaks away from their body!</span>", "<span class='notice'>You break away from [tagging_along].</span>")
		owner.forceMove(get_turf(tagging_along))
		tagging_along = null
		STOP_PROCESSING(SSprocessing, src)
		addtimer(CALLBACK(src, .proc/swap_psi_costs), 1)
		return TRUE
	else
		var/list/targets = list()
		var/mob/living/target
		for(var/mob/living/L in view(7, owner))
			var/turf/T = get_turf(L)
			if(L == owner || T.get_lumcount() <= 2)
				continue
			targets += L
		if(!targets.len)
			owner << "<span class='warning'>There are no nearby targets in lit areas!</span>"
			return
		if(targets.len == 1)
			target = targets[1] //To prevent the prompt from appearing with just one person
		else
			target = input(owner, "Select a target to tag along with.", name) as null|anything in targets
			if(!target)
				return
		owner << "<span class='velvet bold'>iahz</span><br><span class='notice'>You meld with [target]'s shadow.</span>"
		owner.forceMove(target)
		tagging_along = target
		START_PROCESSING(SSprocessing, src)
		addtimer(CALLBACK(src, .proc/swap_psi_costs), 1)
		return TRUE

/datum/action/innate/umbrage/tagalong/proc/swap_psi_costs() //Psi costs change for jumping in and out, so umbrages can disengage freely
	if(psi_cost)
		psi_cost = 0
	else
		psi_cost = initial(psi_cost)
	return TRUE
