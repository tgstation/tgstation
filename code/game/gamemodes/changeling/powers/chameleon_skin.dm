/obj/effect/proc_holder/changeling/chameleon_skin
	name = "Chameleon Skin"
	desc = "Our skin pigmentation rapidly changes to suit our current environment."
	helptext = "Allows us to become invisible after a few seconds of standing still. Can be toggled on and off."
	dna_cost = 2
	chemical_cost = 25
	req_human = 1
	genetic_damage = 10
	max_genetic_damage = 50


/obj/effect/proc_holder/changeling/chameleon_skin/sting_action(mob/user)
	var/mob/living/carbon/human/H = user //SHOULD always be human, because req_human = 1
	if(!istype(H)) // req_human could be done in can_sting stuff.
		return
	var/datum/mutation/human/HM = mutations_list[CHAMELEON]
	if(HM in H.dna.mutations)
		HM.force_lose(H)
	else
		HM.force_give(H)

	feedback_add_details("changeling_powers","CS")
	return 1

/obj/effect/proc_holder/changeling/chameleon_skin/on_refund(mob/user)
	if(user.has_dna())
		var/mob/living/carbon/C = user
		var/datum/mutation/human/HM = mutations_list[CHAMELEON]
		if(HM in C.dna.mutations)
			HM.force_lose(C)