/obj/effect/proc_holder/changeling/revive
	name = "Regenerate"
	desc = "We regenerate, healing all damage from our form."
	req_stat = DEAD

//Revive from revival stasis
/obj/effect/proc_holder/changeling/revive/sting_action(mob/living/carbon/user)
	user.status_flags &= ~(FAKEDEATH)
	user.tod = null
	user.revive(full_heal = 1)
	user << "<span class='notice'>We have regenerated.</span>"
	user.mind.changeling.purchasedpowers -= src
	feedback_add_details("changeling_powers","CR")
	return 1

/obj/effect/proc_holder/changeling/revive/can_be_used_by(mob/user)
	if((user.stat != DEAD) && !(user.status_flags & FAKEDEATH))
		user.mind.changeling.purchasedpowers -= src
		return 0
	. = ..()
