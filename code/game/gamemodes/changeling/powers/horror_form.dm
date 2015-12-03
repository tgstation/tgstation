/obj/effect/proc_holder/changeling/horror_form //Horror Form: turns the changeling into a terrifying abomination
	name = "Horror Form"
	desc = "We tear apart our human disguise, revealing our true form."
	helptext = "We will become an unstoppable force of destruction. We will be able to turn back into a human after some time."
	chemical_cost = 75
	dna_cost = 20 //Requires a massive amount of absorptions
	req_human = 1

/obj/effect/proc_holder/changeling/horror_form/sting_action(mob/living/carbon/human/user)
	if(!user || user.notransform)
		return 0
	user.visible_message("<span class='warning'>[user] writhes and contorts, their body expanding to inhuman proportions!</span>", \
						"<span class='danger'>We begin our transformation to our true form!</span>")
	if(!do_after(user, 30, target = user))
		user.visible_message("<span class='warning'>[user]'s transformation abruptly reverts itself!</span>", \
							"<span class='warning'>Our transformation has been interrupted!</span>")
		return 0
	user.visible_message("<span class='warning'>[user] grows into an abomination and lets out an awful scream!</span>", \
						"<span class='userdanger'>We cast off our petty shell and enter our true form!</span>")
	var/mob/living/simple_animal/hostile/true_changeling/new_mob = new(get_turf(user))
	new_mob.real_name = user.mind.changeling.changelingID
	new_mob.name = new_mob.real_name
	new_mob.stored_changeling = user
	user.loc = new_mob
	user.status_flags |= GODMODE
	user.mind.transfer_to(new_mob)
	feedback_add_details("changeling_powers","HF")
	return 1
