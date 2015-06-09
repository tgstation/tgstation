/obj/effect/proc_holder/changeling/absorbDNA
	name = "Absorb DNA"
	desc = "Absorb the DNA of our victim."
	chemical_cost = 0
	dna_cost = 0
	req_human = 1
	max_genetic_damage = 100

/obj/effect/proc_holder/changeling/absorbDNA/can_sting(var/mob/living/carbon/user)
	if(!..())
		return

	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.isabsorbing)
		user << "<span class='warning'>We are already absorbing!</span>"
		return

	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(!istype(G))
		user << "<span class='warning'>We must be grabbing a creature in our active hand to absorb them!</span>"
		return
	if(G.state <= GRAB_NECK)
		user << "<span class='warning'>We must have a tighter grip to absorb this creature!</span>"
		return

	var/mob/living/carbon/target = G.affecting
	return changeling.can_absorb_dna(user,target)



/obj/effect/proc_holder/changeling/absorbDNA/sting_action(var/mob/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/obj/item/weapon/grab/G = user.get_active_hand()
	var/mob/living/carbon/human/target = G.affecting
	changeling.isabsorbing = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				user << "<span class='notice'>This creature is compatible. We must hold still...</span>"
			if(2)
				user.visible_message("<span class='warning'>[user] extends a proboscis!</span>", "<span class='notice'>We extend a proboscis.</span>")
			if(3)
				user.visible_message("<span class='danger'>[user] stabs [target] with the proboscis!</span>", "<span class='notice'>We stab [target] with the proboscis.</span>")
				target << "<span class='userdanger'>You feel a sharp stabbing pain!</span>"
				target.take_overall_damage(40)

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(user, target, 150))
			user << "<span class='warning'>Our absorption of [target] has been interrupted!</span>"
			changeling.isabsorbing = 0
			return

	user.visible_message("<span class='danger'>[user] sucks the fluids from [target]!</span>", "<span class='notice'>We have absorbed [target].</span>")
	target << "<span class='userdanger'>You are absorbed by the changeling!</span>"

	if(!changeling.has_dna(target.dna))
		changeling.absorb_dna(target, user)

	if(user.nutrition < NUTRITION_LEVEL_WELL_FED)
		user.nutrition = min((user.nutrition + target.nutrition), NUTRITION_LEVEL_WELL_FED)

	if(target.mind)//if the victim has got a mind

		target.mind.show_memory(src, 0) //I can read your mind, kekeke. Output all their notes.

		if(target.mind.changeling)//If the target was a changeling, suck out their extra juice and objective points!
			changeling.chem_charges += min(target.mind.changeling.chem_charges, changeling.chem_storage)
			changeling.absorbedcount += (target.mind.changeling.absorbedcount)

			target.mind.changeling.absorbed_dna.len = 1
			target.mind.changeling.absorbedcount = 0


	changeling.chem_charges=min(changeling.chem_charges+10, changeling.chem_storage)

	changeling.isabsorbing = 0
	changeling.canrespec = 1

	target.death(0)
	target.Drain()
	return 1



//Absorbs the target DNA.
/datum/changeling/proc/absorb_dna(mob/living/carbon/T, var/mob/user)
	if(absorbed_dna.len)
		absorbed_dna.Cut(1,2)
	T.dna.real_name = T.real_name //Set this again, just to be sure that it's properly set.
	var/datum/dna/new_dna = new T.dna.type
	new_dna.uni_identity = T.dna.uni_identity
	new_dna.struc_enzymes = T.dna.struc_enzymes
	new_dna.real_name = T.dna.real_name
	new_dna.species = T.dna.species
	new_dna.mutant_color = T.dna.mutant_color
	new_dna.blood_type = T.dna.blood_type
	absorbedcount++
	store_dna(new_dna, user)

/datum/changeling/proc/store_dna(var/datum/dna/new_dna, var/mob/user)
	for(var/datum/objective/escape/escape_with_identity/E in user.mind.objectives)
		if(E.target_real_name == new_dna.real_name)
			protected_dna |= new_dna
			return
	absorbed_dna |= new_dna
