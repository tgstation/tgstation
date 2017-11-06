/obj/effect/proc_holder/changeling/horror_form //Horror Form: turns the changeling into a terrifying abomination
	name = "Horror Form"
	desc = "We tear apart our human disguise, revealing our true form."
	helptext = "We will become an unstoppable force of destruction. We will turn back into a human after some time."
	chemical_cost = 75
	dna_cost = 3
	req_human = 1

/obj/effect/proc_holder/changeling/horror_form/sting_action(mob/living/carbon/human/user)
	if(!user || user.notransform)
		return 0
	user.visible_message("<span class='warning'>[user] writhes and contorts, their body expanding to inhuman proportions!</span>", \
						"<span class='userdanger'>We cast off our petty shell and enter our true form!</span>")
	playsound(src, 'sound/creatures/horror_form.ogg', 100, 1, 1, 1)
	var/mob/living/simple_animal/hostile/true_changeling/new_mob = new(get_turf(user))
	new_mob.real_name = user.mind.changeling.changelingID
	new_mob.name = new_mob.real_name
	new_mob.stored_changeling = user
	user.loc = new_mob
	user.status_flags |= GODMODE
	user.mind.transfer_to(new_mob)
	return 1