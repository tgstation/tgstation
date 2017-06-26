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

/obj/effect/proc_holder/changeling/sting/proc/set_sting(mob/user)
	to_chat(user, "<span class='notice'>We prepare our sting, use alt+click or middle mouse button on target to sting them.</span>")
	user.mind.changeling.chosen_sting = src
	user.hud_used.lingstingdisplay.icon_state = sting_icon
	user.hud_used.lingstingdisplay.invisibility = 0

/obj/effect/proc_holder/changeling/sting/proc/unset_sting(mob/user)
	to_chat(user, "<span class='warning'>We retract our sting, we can't sting anyone for now.</span>")
	user.mind.changeling.chosen_sting = null
	user.hud_used.lingstingdisplay.icon_state = null
	user.hud_used.lingstingdisplay.invisibility = INVISIBILITY_ABSTRACT

/mob/living/carbon/proc/unset_sting()
	if(mind && mind.changeling && mind.changeling.chosen_sting)
		src.mind.changeling.chosen_sting.unset_sting(src)

/obj/effect/proc_holder/changeling/sting/can_sting(mob/user, mob/target)
	if(!..())
		return
	if(!user.mind.changeling.chosen_sting)
		to_chat(user, "We haven't prepared our sting yet!")
	if(!iscarbon(target))
		return
	if(!isturf(user.loc))
		return
	if(!AStar(user, target.loc, /turf/proc/Distance, user.mind.changeling.sting_range, simulated_only = 0))
		return
	if(target.mind && target.mind.changeling)
		sting_feedback(user, target)
		user.mind.changeling.chem_charges -= chemical_cost
	return 1

/obj/effect/proc_holder/changeling/sting/sting_feedback(mob/user, mob/target)
	if(!target)
		return
	to_chat(user, "<span class='notice'>We stealthily sting [target.name].</span>")
	if(target.mind && target.mind.changeling)
		to_chat(target, "<span class='warning'>You feel a tiny prick.</span>")
	return 1


/obj/effect/proc_holder/changeling/sting/transformation
	name = "Transformation Sting"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform."
	helptext = "The victim will transform much like a changeling would. Does not provide a warning to others. Mutations will not be transferred, and monkeys will become human."
	sting_icon = "sting_transform"
	chemical_cost = 50
	dna_cost = 5 //Just so we don't have 50 of a single person until a ling gets at least a few absorbs...
	var/datum/changelingprofile/selected_dna = null

/obj/effect/proc_holder/changeling/sting/transformation/Click()
	var/mob/user = usr
	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.chosen_sting)
		unset_sting(user)
		return
	selected_dna = changeling.select_dna("Select the target DNA: ", "Target DNA")
	if(!selected_dna)
		return
	if(NOTRANSSTING in selected_dna.dna.species.species_traits)
		to_chat(user, "<span class = 'notice'>That DNA is not compatible with changeling retrovirus!")
		return
	..()

/obj/effect/proc_holder/changeling/sting/transformation/can_sting(mob/user, mob/target)
	if(!..())
		return
	if((target.disabilities & HUSK) || !target.has_dna())
		to_chat(user, "<span class='warning'>Our sting appears ineffective against its DNA.</span>")
		return 0
	return 1

/obj/effect/proc_holder/changeling/sting/transformation/sting_action(mob/user, mob/target)
	add_logs(user, target, "stung", "transformation sting", " new identity is [selected_dna.dna.real_name]")
	var/datum/dna/NewDNA = selected_dna.dna
	if(ismonkey(target))
		to_chat(user, "<span class='notice'>Our genes cry out as we sting [target.name]!</span>")

	var/mob/living/carbon/C = target
	. = TRUE
	if(istype(C))
		C.real_name = NewDNA.real_name
		NewDNA.transfer_identity(C)
		if(ismonkey(C))
			C.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_DEFAULTMSG)
		C.updateappearance(mutcolor_update=1)

/obj/effect/proc_holder/changeling/sting/extract_dna
	name = "Extract DNA Sting"
	desc = "We stealthily sting a target and extract their DNA. This will count towards your objective, but will not grant evo points!"
	helptext = "Will give you the DNA of your target, allowing you to transform into them."
	sting_icon = "sting_extract"
	chemical_cost = 25
	dna_cost = 1

/obj/effect/proc_holder/changeling/sting/extract_dna/can_sting(mob/user, mob/target)
	if(..())
		return user.mind.changeling.can_absorb_dna(user, target)

/obj/effect/proc_holder/changeling/sting/extract_dna/sting_action(mob/user, mob/living/carbon/human/target)
	add_logs(user, target, "stung", "extraction sting")
	if(!(user.mind.changeling.has_dna(target.dna)))
		user.mind.changeling.add_new_profile(target, user)
	return TRUE

/obj/effect/proc_holder/changeling/sting/mute
	name = "Mute Sting"
	desc = "We silently sting a human, completely silencing them for a short time."
	helptext = "Does not provide a warning to the victim that they have been stung, until they try to speak and cannot."
	sting_icon = "sting_mute"
	chemical_cost = 20
	dna_cost = 2

/obj/effect/proc_holder/changeling/sting/mute/sting_action(mob/user, mob/living/carbon/target)
	add_logs(user, target, "stung", "mute sting")
	target.silent += 30
	return TRUE

/obj/effect/proc_holder/changeling/sting/para
	name = "Tiring Sting"
	desc = "We silently sting a human, causing them to slowly lose energy and become tired."
	helptext = "The victim will slowly lose energy and eventually become tired"
	sting_icon = "sting_mute"
	chemical_cost = 30
	dna_cost = 2

/obj/effect/proc_holder/changeling/sting/para/sting_action(mob/user, mob/living/carbon/target)
	add_logs(user, target, "stung", "tiring sting")
	to_chat(target, "<span class='userdanger'>You feel tired... Maybe it's nap time...</span>")
	if(target.reagents)
		target.reagents.add_reagent("dizzysolution", 20)
		target.reagents.add_reagent("tiresolution", 20)
		target.reagents.add_reagent("morphine", 10) //A noticeable knockout that gives plenty of warning before
	return TRUE


/obj/effect/proc_holder/changeling/sting/LSD
	name = "Hallucination Sting"
	desc = "Causes terror in the target."
	helptext = "We evolve the ability to sting a target with a powerful hallucinogenic chemical. The target does not notice they have been stung, and the effect occurs after 30 to 60 seconds."
	sting_icon = "sting_lsd"
	chemical_cost = 10
	dna_cost = 2

/obj/effect/proc_holder/changeling/sting/LSD/sting_action(mob/user, mob/living/carbon/target)
	add_logs(user, target, "stung", "LSD sting")
	addtimer(CALLBACK(src, .proc/hallucination_time, target), rand(300,600))
	return TRUE

/obj/effect/proc_holder/changeling/sting/LSD/proc/hallucination_time(mob/living/carbon/target)
	if(target)
		target.hallucination = max(400, target.hallucination)

/obj/effect/proc_holder/changeling/sting/cryo
	name = "Cryogenic Sting"
	desc = "We silently sting a human with a cocktail of chemicals that freeze them."
	helptext = "Does not provide a warning to the victim, though they will likely realize they are suddenly freezing."
	sting_icon = "sting_cryo"
	chemical_cost = 15
	dna_cost = 3

/obj/effect/proc_holder/changeling/sting/cryo/sting_action(mob/user, mob/target)
	add_logs(user, target, "stung", "cryo sting")
	if(target.reagents)
		target.reagents.add_reagent("frostoil", 30)
	return TRUE
