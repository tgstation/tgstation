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
		user << "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>"
		return
	if(G.state <= GRAB_NECK)
		user << "<span class='warning'>We must have a tighter grip to absorb this creature.</span>"
		return

	var/mob/living/carbon/target = G.affecting
	return changeling.can_absorb_dna(user,target)



/obj/effect/proc_holder/changeling/absorbDNA/sting_action(var/mob/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/obj/item/weapon/grab/G = user.get_active_hand()
	var/mob/living/carbon/human/target = G.affecting
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				user << "<span class='notice'>This creature is compatible. We must hold still...</span>"
			if(2)
				user << "<span class='notice'>We extend a proboscis.</span>"
				user.visible_message("<span class='warning'>[user] extends a proboscis!</span>")
			if(3)
				user << "<span class='notice'>We stab [target] with the proboscis.</span>"
				user.visible_message("<span class='danger'>[user] stabs [target] with the proboscis!</span>")
				target << "<span class='danger'>You feel a sharp stabbing pain!</span>"
				target.take_overall_damage(40)

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(user, target, 150))
			user << "<span class='warning'>Our absorption of [target] has been interrupted!</span>"
			changeling.isabsorbing = 0
			return

	user << "<span class='notice'>We have absorbed [target]!</span>"
	user.visible_message("<span class='danger'>[user] sucks the fluids from [target]!</span>")
	target << "<span class='danger'>You have been absorbed by the changeling!</span>"

	changeling.absorb_dna(target)

	if(user.nutrition < 400) user.nutrition = min((user.nutrition + target.nutrition), 400)

	if(target.mind)//if the victim has got a mind

		target.mind.show_memory(src, 0) //I can read your mind, kekeke. Output all their notes.

		if(target.mind.changeling)//If the target was a changeling, suck out their extra juice and objective points!
			changeling.chem_charges += min(target.mind.changeling.chem_charges, changeling.chem_storage)
			changeling.absorbedcount += target.mind.changeling.absorbedcount

			target.mind.changeling.absorbed_dna.len = 1
			target.mind.changeling.absorbedcount = 0
	else
		changeling.chem_charges += 10

	changeling.isabsorbing = 0
	changeling.canrespec = 1

	target.death(0)
	target.Drain()
	return 1



//Absorbs the target DNA.
/datum/changeling/proc/absorb_dna(mob/living/carbon/T)
	if(absorbed_dna.len)
		absorbed_dna.Cut(1,2)
	T.dna.real_name = T.real_name //Set this again, just to be sure that it's properly set.
	var/datum/dna/new_dna = new T.dna.type
	new_dna.uni_identity = T.dna.uni_identity
	new_dna.struc_enzymes = T.dna.struc_enzymes
	new_dna.real_name = T.dna.real_name
	new_dna.mutantrace = T.dna.mutantrace
	new_dna.blood_type = T.dna.blood_type
	absorbed_dna |= new_dna //And add the target DNA to our absorbed list.
	absorbedcount++ //all that done, let's increment the objective counter.