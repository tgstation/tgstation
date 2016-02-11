/obj/effect/proc_holder/changeling/revive
	name = "Regenerate"
	desc = "We regenerate, healing all damage from our form."
	req_stat = DEAD

//Revive from revival stasis
/obj/effect/proc_holder/changeling/revive/sting_action(mob/living/carbon/user)
	if(user.stat == DEAD)
		dead_mob_list -= user
		living_mob_list += user
	user.status_flags &= ~(FAKEDEATH)
	user.stat = UNCONSCIOUS
	user.tod = null
	user.toxloss = 0
	user.oxyloss = 0
	user.cloneloss = 0
	user.paralysis = 0
	user.stunned = 0
	user.weakened = 0
	user.radiation = 0
	user.sleeping = 0
	user.clear_alert("asleep")
	user.heal_overall_damage(user.getBruteLoss(), user.getFireLoss(), 0) //not updating health & stat
	user.reagents.clear_reagents()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.restore_blood()
		H.remove_all_embedded_objects()
	user << "<span class='notice'>We have regenerated.</span>"
	user.mind.changeling.purchasedpowers -= src
	feedback_add_details("changeling_powers","CR")
	user.updatehealth()
	return 1

/obj/effect/proc_holder/changeling/revive/can_be_used_by(mob/user)
	if((user.stat != DEAD) && !(user.status_flags & FAKEDEATH))
		user.mind.changeling.purchasedpowers -= src
		return 0
	. = ..()
