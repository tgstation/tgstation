/datum/changeling/proc/purchasePower(mob/living/carbon/user, sting_name)

	var/obj/effect/proc_holder/changeling/thepower = null

	for(var/path in subtypesof(/obj/effect/proc_holder/changeling))
		var/obj/effect/proc_holder/changeling/S = path
		if(initial(S.name) == sting_name)
			thepower = new path()
			break

	if(!thepower)
		to_chat(user, "This is awkward. Changeling power purchase failed, please report this bug to a coder!")
		return

	if(absorbedcount < thepower.req_dna)
		to_chat(user, "We lack the energy to evolve this ability!")
		return

	if(has_sting(thepower))
		to_chat(user, "We have already evolved this ability!")
		return

	if(thepower.dna_cost < 0)
		to_chat(user, "We cannot evolve this ability.")
		return

	if(geneticpoints < thepower.dna_cost)
		to_chat(user, "We have reached our capacity for abilities.")
		return

	if(user.status_flags & FAKEDEATH)//To avoid potential exploits by buying new powers while in stasis, which clears your verblist.
		to_chat(user, "We lack the energy to evolve new abilities right now.")
		return

	geneticpoints -= thepower.dna_cost
	purchasedpowers += thepower
	thepower.on_purchase(user)


/mob/proc/make_changeling(is_respec)
	if(!mind)
		return
	if(!ishuman(src) && !ismonkey(src))
		return
	if(!mind.changeling)
		mind.changeling = new /datum/changeling(gender)
	if(mind.changeling.purchasedpowers)
		remove_changeling_powers(1)
	// purchase free powers.
	for(var/path in subtypesof(/obj/effect/proc_holder/changeling))
		var/obj/effect/proc_holder/changeling/S = new path()
		if(!S.dna_cost)
			if(!mind.changeling.has_sting(S))
				mind.changeling.purchasedpowers+=S
			S.on_purchase(src, is_respec)

	var/mob/living/carbon/C = src	//only carbons have dna now, so we have to typecaste


	C.verbs += /mob/cling/proc/hivemind_chat

	if(ishuman(C))
		var/datum/changelingprofile/prof = mind.changeling.add_new_profile(C, src)
		mind.changeling.first_prof = prof

		var/obj/item/organ/brain/B = C.getorganslot("brain")
		if(B)
			B.vital = FALSE
			B.decoy_override = TRUE
	return 1

/datum/changeling/proc/reset()
	chosen_sting = null
	geneticpoints = initial(geneticpoints)
	sting_range = initial(sting_range)
	chem_storage = initial(chem_storage)
	chem_recharge_rate = initial(chem_recharge_rate)
	chem_charges = min(chem_charges, chem_storage)
	chem_recharge_slowdown = initial(chem_recharge_slowdown)
	mimicing = ""

/mob/proc/remove_changeling_powers(keep_free_powers=0)
	if(ishuman(src) || ismonkey(src))
		if(mind && mind.changeling)
			mind.changeling.changeling_speak = 0
			mind.changeling.reset()
			for(var/obj/effect/proc_holder/changeling/p in mind.changeling.purchasedpowers)
				if((p.dna_cost == 0 && keep_free_powers) || p.always_keep)
					continue
				mind.changeling.purchasedpowers -= p
				p.on_refund(src)
		if(hud_used)
			hud_used.lingstingdisplay.icon_state = null
			hud_used.lingstingdisplay.invisibility = INVISIBILITY_ABSTRACT

/datum/changeling/proc/has_sting(obj/effect/proc_holder/changeling/power)
	for(var/obj/effect/proc_holder/changeling/P in purchasedpowers)
		if(initial(power.name) == P.name)
			return 1
	return 0
