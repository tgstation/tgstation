/obj/effect/proc_holder/changeling/sting
	name = "Tiny Prick"
	desc = "Stabby stabby"
	var/sting_icon = null
	var/standing_req = 0 //If the target has to be standing
	var/conscious_req = 1 //If the sting can only be used on conscious targets

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
	user << "<span class='notice'>We prepare our sting, use alt+click or middle mouse button on target to sting them.</span>"
	user.mind.changeling.chosen_sting = src
	user.hud_used.lingstingdisplay.icon_state = sting_icon
	user.hud_used.lingstingdisplay.invisibility = 0

/obj/effect/proc_holder/changeling/sting/proc/unset_sting(mob/user)
	user << "<span class='warning'>We retract our sting, we can't sting anyone for now.</span>"
	user.mind.changeling.chosen_sting = null
	user.hud_used.lingstingdisplay.icon_state = null
	user.hud_used.lingstingdisplay.invisibility = 101

/mob/living/carbon/proc/unset_sting()
	if(mind && mind.changeling && mind.changeling.chosen_sting)
		src.mind.changeling.chosen_sting.unset_sting(src)

/obj/effect/proc_holder/changeling/sting/can_sting(mob/user, mob/target)
	if(!..())
		return
	if(!user.mind.changeling.chosen_sting)
		user << "<span class='warning'>We haven't prepared our sting yet!</span>"
		return
	if(!iscarbon(target))
		user << "<span class='warning'>We may only sting carbon-based lifeforms!</span>"
		return
	if(!isturf(user.loc))
		return
	if(!AStar(user.loc, target.loc, null, /turf/proc/Distance, user.mind.changeling.sting_range, simulated_only = 0))
		return
	if(standing_req && target.lying)
		user << "<span class='warning'>We can only use this sting on standing targets!</span>"
		return
	if(conscious_req && target.stat)
		user << "<span class='warning'>We can only use this sting on conscious targets!</span>"
		return
	if(target.stat == DEAD) //Dead, i.e. cannot metabolize chemicals!
		user << "<span class='warning'>[target] is dead!</span>"
		return
	if(target.mind && target.mind.changeling)
		sting_feedback(user,target)
		take_chemical_cost(user.mind.changeling)
		return
	return 1

/obj/effect/proc_holder/changeling/sting/sting_feedback(mob/user, mob/target)
	if(!target)
		return
	user << "<span class='notice'>We stealthily sting [target.name].</span>"
	if(target.mind && target.mind.changeling)
		target << "<span class='warning'>You feel a tiny prick.</span>"
	return 1

/obj/effect/proc_holder/changeling/sting/mute
	name = "Mute Sting"
	desc = "We silently sting a human, completely silencing them for a short time."
	helptext = "Our target will not be alerted to their silence until they attempt to speak and cannot."
	sting_icon = "sting_mute"
	chemical_cost = 20
	dna_cost = 3

/obj/effect/proc_holder/changeling/sting/mute/sting_action(mob/user, mob/living/carbon/target)
	add_logs(user, target, "stung", "mute sting")
	target.reagents.add_reagent("mutetoxin", 5)
	feedback_add_details("changeling_powers","MS")
	return 1

/obj/effect/proc_holder/changeling/sting/blind
	name = "Blind Sting"
	desc = "We inject a serum that attacks and damages the eyes."
	helptext = "The victim will immediately be blinded for a short time in addition to becoming permanently nearsighted."
	sting_icon = "sting_blind"
	chemical_cost = 25
	dna_cost = 2

/obj/effect/proc_holder/changeling/sting/blind/sting_action(mob/user, mob/target)
	add_logs(user, target, "stung", "blind sting")
	target << "<span class='userdanger'>Your eyes burn horrifically!</span>"
	target.disabilities |= NEARSIGHT
	target.eye_blind = 20
	target.eye_blurry = 40
	target.confused += 5 //Going instantaneously blind often makes one a little disoriented
	feedback_add_details("changeling_powers","BS")
	return 1

/obj/effect/proc_holder/changeling/sting/cryo
	name = "Cryogenic Sting"
	desc = "We silently sting a human with a cocktail of chemicals that freeze them."
	helptext = "This will provide an ambiguous warning to the victim after a short time."
	sting_icon = "sting_cryogenic"
	chemical_cost = 15
	dna_cost = 3
	conscious_req = 0 //Can be used on the unconscious

/obj/effect/proc_holder/changeling/sting/cryo/sting_action(mob/user, mob/target)
	add_logs(user, target, "stung", "cryo sting")
	if(target.reagents)
		target.reagents.add_reagent("frostoil", 30)
	spawn(50)
		if(target)
			if(!target.stat)
				target << "<span class='warning'>You feel strangely cold. Goosebumps break out across your skin.</span>"
			else
				target << "<span class='warning'><b>It's so cold.</b></span>" //Give a spookier message if they're unconscious
	feedback_add_details("changeling_powers","CS")
	return 1

/obj/effect/proc_holder/changeling/sting/paralysis
	name = "Paralysis Sting"
	desc = "We inject a human with a powerful muscular inhibitor, preventing their movement after a short time."
	helptext = "They will immediately be notified of their impending fate and will still be able to speak while paralyzed. The paralysis will last for around fifteen seconds."
	sting_icon = "sting_paralysis"
	chemical_cost = 30
	dna_cost = 5
	standing_req = 1

/obj/effect/proc_holder/changeling/sting/paralysis/sting_action(mob/user, mob/living/target)
	add_logs(user, target, "stung", "parasting")
	user << "<span class='notice'>The paralysis will take effect more quickly depending on their wounds.</span>"
	target << "<span class='warning'>Your body begins throbbing with a painful ache...</span>"
	var/time_to_wait = target.health
	time_to_wait += 50 //The target's health, plus five seconds - a fully healed human will take fifteen seconds to begin experiencing the effects
	time_to_wait = Clamp(time_to_wait, 0, INFINITY)
	spawn(time_to_wait)
		if(target && !target.lying) //So you can't spam parastings if they're already on the ground
			target << "<span class='userdanger'>Your muscles painfully seize up! You can't move!</span>"
			target.Weaken(15)
			target.Stun(15)
	feedback_add_details("changeling_powers", "PS")
	return 1

/obj/effect/proc_holder/changeling/sting/death
	name = "Death Sting"
	desc = "We inject a small amount of deadly poison that will kill the victim over a long period of time."
	helptext = "Our target will know immediately of their plight. The toxin will never metabolize, but there is very little and it can be easily removed."
	sting_icon = "sting_death"
	chemical_cost = 50 //A potential guaranteed death is nothing to laugh at
	dna_cost = 5

/obj/effect/proc_holder/changeling/sting/death/sting_action(mob/user, mob/target)
	add_logs(user, target, "stung", "death sting")
	if(target.reagents)
		target.reagents.add_reagent("wasting_toxin", 5)
	target << "<span class='userdanger'>Unbearable pain seeps into every fiber of your being.</span>"
	feedback_add_details("changeling_powers","DS")
	return 1
