/obj/effect/proc_holder/changeling/fleshmend
	name = "Fleshmend"
	desc = "Our flesh rapidly regenerates, healing our wounds, and growing \
		back missing limbs. Effectiveness decreases with quick, repeated use."
	helptext = "Heals a moderate amount of damage over a short period of \
		time. Can be used while unconscious. Will alert nearby crew if \
		any limbs are regenerated."
	chemical_cost = 25
	dna_cost = 2
	req_stat = UNCONSCIOUS
	var/recent_uses = 1 //The factor of which the healing should be divided by
	var/healing_ticks = 10
	// The ideal total healing amount,
	// divided by healing_ticks to get heal/tick
	var/total_healing = 100

/obj/effect/proc_holder/changeling/fleshmend/New()
	..()
	SSobj.processing.Add(src)

/obj/effect/proc_holder/changeling/fleshmend/Destroy()
	SSobj.processing.Remove(src)
	..()

/obj/effect/proc_holder/changeling/fleshmend/process()
	if(recent_uses > 1)
		recent_uses = max(1, recent_uses - (1 / healing_ticks))

//Starts healing you every second for 10 seconds.
//Can be used whilst unconscious.
/obj/effect/proc_holder/changeling/fleshmend/sting_action(mob/living/user)
	user << "<span class='notice'>We begin to heal rapidly.</span>"
	if(recent_uses > 1)
		user << "<span class='warning'>Our healing's effectiveness is reduced \
			by quick repeated use!</span>"
	spawn(0)
		recent_uses++
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.restore_blood()
			H.remove_all_embedded_objects()
			var/list/missing = H.get_missing_limbs()
			if(missing.len)
				playsound(user, 'sound/magic/Demon_consume.ogg', 50, 1)
				H.visible_message("<span class='warning'>[user]'s missing limbs reform, making a loud, grotesque sound!</span>", "<span class='userdanger'>Your limbs regrow, making a loud, crunchy sound and giving you great pain!</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")
				H.emote("scream")
				H.regenerate_limbs(1)

		// The healing itself - doesn't heal toxin damage
		// (that's anatomic panacea) and the effectiveness decreases with
		// each use in a short timespan
		for(var/i in 1 to healing_ticks)
			if(user)
				var/healpertick = -(total_healing / healing_ticks)
				user.adjustBruteLoss(healpertick / recent_uses, 0)
				user.adjustOxyLoss(healpertick / recent_uses, 0)
				user.adjustFireLoss(healpertick / recent_uses, 0)
				user.updatehealth()
			sleep(10)

	feedback_add_details("changeling_powers","RR")
	return 1
