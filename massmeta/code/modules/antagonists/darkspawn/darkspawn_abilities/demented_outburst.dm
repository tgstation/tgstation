//Emits a shockwave that blasts everyone and everything nearby far away. People close to the user are deafened and stunned.
/datum/action/innate/darkspawn/demented_outburst
	name = "Demented Outburst"
	id = "demented_outburst"
	desc = "Deafens and confuses listeners after a five-second charge period, knocking away everyone nearby. Costs 50 Psi."
	button_icon_state = "demented_outburst"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 50 //big boom = big cost
	lucidity_price = 2

/datum/action/innate/darkspawn/demented_outburst/Activate()
	in_use = TRUE
	owner.visible_message(span_boldwarning("[owner] begins to growl as their chitin hardens..."), "<span class='velvet bold'>cap...</span><br>\
	[span_danger("You begin harnessing your power...")]")
	playsound(owner, 'massmeta/sounds/magic/demented_outburst_charge.ogg', 50, 0)
	addtimer(CALLBACK(src, .proc/outburst, owner), 50)
	addtimer(CALLBACK(src, .proc/reset), 50)
	return TRUE

/datum/action/innate/darkspawn/demented_outburst/IsAvailable(feedback = FALSE)
	if(istype(owner, /mob/living/simple_animal/hostile/crawling_shadows))
		return
	return ..()

/datum/action/innate/darkspawn/demented_outburst/proc/outburst()
	in_use = FALSE
	if(!owner || owner.stat)
		return
	owner.visible_message(span_userdanger("[owner] lets out a deafening scream!"), "<span class='velvet bold italics'>WSWU!</span><br>\
	[span_danger("You let out a deafening outburst!")]")
	playsound(owner, 'massmeta/sounds/magic/demented_outburst_scream.ogg', 75, 0)
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
		AM.throw_at(target, ((clamp((5 - (clamp(distance - 2, 0, distance))), 3, 5))), 1, owner)
		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			if(distance <= 1) //you done fucked up now
				C.visible_message(span_warning("The blast sends [C] flying!"), span_userdanger("The force sends you flying!"))
				C.Paralyze(50)
				C.Knockdown(50)
				C.adjustBruteLoss(10)
				C.soundbang_act(1, 5, 15, 5)
			else if(distance <= 3)
				C.visible_message(span_warning("The blast knocks [C] off their feet!"), span_userdanger("The force bowls you over!"))
				C.Paralyze(25)
				C.Knockdown(30)
				C.soundbang_act(1, 3, 5, 0)
		if(iscyborg(AM))
			var/mob/living/silicon/robot/R = AM
			R.visible_message(span_warning("The blast sends [R] flying!"), span_userdanger("The force sends you flying!"))
			R.Paralyze(100) //fuck borgs
			R.soundbang_act(1, 5, 15, 5)
	return TRUE
