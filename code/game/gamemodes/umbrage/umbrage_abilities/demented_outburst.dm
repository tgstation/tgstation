//Emits a shockwave that blasts everyone and everything nearby far away. People close to the user are deafened and stunned.
/datum/action/innate/umbrage/demented_outburst
	name = "Demented Outburst"
	id = "demented_outburst"
	desc = "Deafens and confuses listeners, and knocks away everyone nearby. Very loud."
	fluff_text = "There's nothing special or psi-related about this. You just scream really loud."
	button_icon_state = "umbrage_demented_outburst"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 60 //big boom = big cost
	lucidity_cost = 2
	blacklisted = 0

/datum/action/innate/umbrage/demented_outburst/Activate()
	in_use = TRUE
	owner.visible_message("<span class='warning'>[owner] begins to growl!</span>", "<span class='velvet bold'>cap...</span><br>\
	<span class='danger'>You begin harnessing every ounce of your power...</span>")
	playsound(owner, 'sound/magic/demented_outburst_charge.ogg', 100, 0)
	addtimer(CALLBACK(src, .proc/outburst, owner), 50)
	return TRUE

/datum/action/innate/umbrage/demented_outburst/proc/outburst()
	in_use = FALSE
	if(!owner || owner.stat)
		return
	owner.visible_message("<span class='boldwarning'>[owner] lets out a deafening scream!</span>", "<span class='velvet bold italics'>WSWU!</span><br>\
	<span class='danger'>You let out a deafening outburst!</span>")
	playsound(owner, 'sound/magic/demented_outburst_scream.ogg', 150, 0)
	var/list/thrown_atoms = list()
	for(var/turf/T in view(5, owner))
		for(var/atom/movable/AM in T)
			thrown_atoms += AM
	for(var/V in thrown_atoms)
		var/atom/movable/AM = V
		if(AM == owner || AM.anchored)
			continue
		var/distance = get_dist(owner, AM)
		var/turf/target = get_edge_target_turf(owner, get_dir(owner, get_step_away(AM, owner)))
		AM.throw_at(target, ((Clamp((5 - (Clamp(distance - 2, 0, distance))), 3, 5))), 1, owner)
		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			if(distance <= 1) //you done fucked up now
				C.visible_message("<span class='warning'>The blast sends [C] flying!</span>", "<span class='ownerdanger'>The force sends you flying!</span>")
				C.Weaken(5)
				C.adjustBruteLoss(10)
				C.soundbang_act(1, 5, 15, 5)
			else if(distance <= 3)
				C.visible_message("<span class='warning'>The blast knocks [C] off their feet!</span>", "<span class='ownerdanger'>The force bowls you over!</span>")
				C.Weaken(3)
				C.soundbang_act(1, 3, 5, 0)
	return TRUE
