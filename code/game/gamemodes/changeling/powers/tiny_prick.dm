/obj/effect/proc_holder/changeling/sting
	name = "Tiny Prick"
	desc = "Stabby stabby"
	var/sting_icon = null

/obj/effect/proc_holder/changeling/sting/Click()
	var/mob/user = usr
	if(!user || !user.mind || !user.mind.changeling)
		return
	if(!(user.mind.changeling.chosen_sting))
		set_sting(user)
	else
		unset_sting(user)
	return

/obj/effect/proc_holder/changeling/sting/proc/set_sting(var/mob/user)
	user << "<span class='notice'>We prepare our sting, use alt+click or middle mouse button on target to sting them.</span>"
	user.mind.changeling.chosen_sting = src
	user.hud_used.lingstingdisplay.icon_state = sting_icon
	user.hud_used.lingstingdisplay.invisibility = 0

/obj/effect/proc_holder/changeling/sting/proc/unset_sting(var/mob/user)
	user << "<span class='warning'>We retract our sting, we can't sting anyone for now.</span>"
	user.mind.changeling.chosen_sting = null
	user.hud_used.lingstingdisplay.icon_state = null
	user.hud_used.lingstingdisplay.invisibility = 101

/mob/living/carbon/proc/unset_sting()
	if(mind && mind.changeling && mind.changeling.chosen_sting)
		src.mind.changeling.chosen_sting.unset_sting(src)

/obj/effect/proc_holder/changeling/sting/can_sting(var/mob/user, var/mob/target)
	if(!..())
		return
	if(!user.mind.changeling.chosen_sting)
		user << "We haven't prepared our sting yet!"
	if(!iscarbon(target))
		return
	if(!isturf(user.loc))
		return
	if(get_dist(user, target) > (user.mind.changeling.sting_range))
		return //sanity check as AStar is still throwing insane stunts
	if(!AStar(user.loc, target.loc, null, /turf/proc/Distance, user.mind.changeling.sting_range))
		return //hope this ancient magic still works
	if(target.mind && target.mind.changeling)
		sting_feedback(user,target)
		take_chemical_cost(user.mind.changeling)
		return
	return 1

/obj/effect/proc_holder/changeling/sting/sting_feedback(var/mob/user, var/mob/target)
	if(!target)
		return
	user << "<span class='notice'>We stealthily sting [target.name].</span>"
	if(target.mind && target.mind.changeling)
		target << "<span class='warning'>You feel a tiny prick.</span>"
		add_logs(user, target, "unsuccessfully stung")
	return 1


/obj/effect/proc_holder/changeling/sting/transformation
	name = "Transformation Sting"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform."
	helptext = "Does not provide a warning to others. The victim will transform much like a changeling would."
	sting_icon = "sting_transform"
	chemical_cost = 40
	dna_cost = 2
	var/datum/dna/selected_dna = null

/obj/effect/proc_holder/changeling/sting/transformation/Click()
	var/mob/user = usr
	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.chosen_sting)
		unset_sting(user)
		return
	selected_dna = changeling.select_dna("Select the target DNA: ", "Target DNA")
	if(!selected_dna)
		return
	..()

/obj/effect/proc_holder/changeling/sting/transformation/can_sting(var/mob/user, var/mob/target)
	if(!..())
		return
	if((target.disabilities & HUSK) || !check_dna_integrity(target))
		user << "<span class='warning'>Our sting appears ineffective against its DNA.</span>"
		return 0
	return 1

/obj/effect/proc_holder/changeling/sting/transformation/sting_action(var/mob/user, var/mob/target)
	add_logs(user, target, "stung", object="transformation sting", addition=" new identity is [selected_dna.real_name]")
	var/datum/dna/NewDNA = selected_dna
	if(ismonkey(target))
		user << "<span class='notice'>We stealthily sting [target.name].</span>"
	hardset_dna(target, NewDNA.uni_identity, NewDNA.struc_enzymes, NewDNA.real_name, NewDNA.blood_type, NewDNA.species.type, NewDNA.features)
	updateappearance(target)
	feedback_add_details("changeling_powers","TS")
	return 1

/obj/effect/proc_holder/changeling/sting/extract_dna
	name = "Extract DNA Sting"
	desc = "We stealthily sting a target and extract their DNA."
	helptext = "Will give you the DNA of your target, allowing you to transform into them."
	sting_icon = "sting_extract"
	chemical_cost = 25
	dna_cost = 0

/obj/effect/proc_holder/changeling/sting/extract_dna/can_sting(var/mob/user, var/mob/target)
	if(..())
		return user.mind.changeling.can_absorb_dna(user, target)

/obj/effect/proc_holder/changeling/sting/extract_dna/sting_action(var/mob/user, var/mob/living/carbon/human/target)
	add_logs(user, target, "stung", object="extraction sting")
	if(!(user.mind.changeling.has_dna(target.dna)))
		user.mind.changeling.absorb_dna(target, user)
	feedback_add_details("changeling_powers","ED")
	return 1

/obj/effect/proc_holder/changeling/sting/mute
	name = "Mute Sting"
	desc = "We silently sting a human, completely silencing them for a short time."
	helptext = "Does not provide a warning to the victim that they have been stung, until they try to speak and cannot."
	sting_icon = "sting_mute"
	chemical_cost = 20
	dna_cost = 2

/obj/effect/proc_holder/changeling/sting/mute/sting_action(var/mob/user, var/mob/living/carbon/target)
	add_logs(user, target, "stung", object="mute sting")
	target.silent += 30
	feedback_add_details("changeling_powers","MS")
	return 1

/obj/effect/proc_holder/changeling/sting/blind
	name = "Blind Sting"
	desc = "Temporarily blinds the target."
	helptext = "This sting completely blinds a target for a short time."
	sting_icon = "sting_blind"
	chemical_cost = 25
	dna_cost = 1

/obj/effect/proc_holder/changeling/sting/blind/sting_action(var/mob/user, var/mob/target)
	add_logs(user, target, "stung", object="blind sting")
	target << "<span class='danger'>Your eyes burn horrifically!</span>"
	target.disabilities |= NEARSIGHT
	target.eye_blind = 20
	target.eye_blurry = 40
	feedback_add_details("changeling_powers","BS")
	return 1

/obj/effect/proc_holder/changeling/sting/LSD
	name = "Hallucination Sting"
	desc = "Causes terror in the target."
	helptext = "We evolve the ability to sting a target with a powerful hallucinogenic chemical. The target does not notice they have been stung, and the effect occurs after 30 to 60 seconds."
	sting_icon = "sting_lsd"
	chemical_cost = 10
	dna_cost = 1

/obj/effect/proc_holder/changeling/sting/LSD/sting_action(var/mob/user, var/mob/living/carbon/target)
	add_logs(user, target, "stung", object="LSD sting")
	spawn(rand(300,600))
		if(target)
			target.hallucination = max(400, target.hallucination)
	feedback_add_details("changeling_powers","HS")
	return 1

/obj/effect/proc_holder/changeling/sting/cryo
	name = "Cryogenic Sting"
	desc = "We silently sting a human with a cocktail of chemicals that freeze them."
	helptext = "Does not provide a warning to the victim, though they will likely realize they are suddenly freezing."
	sting_icon = "sting_cryo"
	chemical_cost = 15
	dna_cost = 2

/obj/effect/proc_holder/changeling/sting/cryo/sting_action(var/mob/user, var/mob/target)
	add_logs(user, target, "stung", object="cryo sting")
	if(target.reagents)
		target.reagents.add_reagent("frostoil", 30)
	feedback_add_details("changeling_powers","CS")
	return 1