/obj/effect/proc_holder/changeling/revive
	name = "Regenerate"
	desc = "We regenerate, healing all damage from our form."
	req_stat = DEAD

//Revive from revival stasis
/obj/effect/proc_holder/changeling/revive/sting_action(var/mob/living/carbon/user)
	if(user.stat == DEAD)
		dead_mob_list -= user
		living_mob_list += user
	user.tod = null
	user.setToxLoss(0)
	user.setOxyLoss(0)
	user.setCloneLoss(0)
	user.SetParalysis(0)
	user.SetStunned(0)
	user.SetWeakened(0)
	user.radiation = 0
	user.heal_overall_damage(user.getBruteLoss(), user.getFireLoss())
	user.reagents.clear_reagents()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.restore_blood()
		H.remove_all_embedded_objects()
	user << "<span class='notice'>We have regenerated.</span>"
	user.status_flags &= ~(FAKEDEATH)
	user.update_canmove()
	user.mind.changeling.purchasedpowers -= src
	user.med_hud_set_status()
	user.med_hud_set_health()
	feedback_add_details("changeling_powers","CR")
	user.stat = CONSCIOUS
	return 1
