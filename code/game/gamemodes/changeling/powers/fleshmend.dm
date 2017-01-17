/obj/effect/proc_holder/changeling/fleshmend
	name = "Fleshmend"
	desc = "Our flesh rapidly regenerates, healing our burns, bruises and \
		shortness of breath. Effectiveness decreases with quick, \
		repeated use."
	helptext = "Heals a moderate amount of damage over a short period of \
		time. Can be used while unconscious. Does not regrow limbs or \
		restore lost blood."
	chemical_cost = 20
	dna_cost = 2
	req_stat = UNCONSCIOUS
	var/recent_uses = 1 //The factor of which the healing should be divided by
	var/healing_ticks = 10
	// The ideal total healing amount,
	// divided by healing_ticks to get heal/tick
	var/total_healing = 100

/obj/effect/proc_holder/changeling/fleshmend/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/effect/proc_holder/changeling/fleshmend/Destroy()
	STOP_PROCESSING(SSobj, src)
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

	recent_uses++
	addtimer(CALLBACK(src, .proc/fleshmend, user), 0)

	feedback_add_details("changeling_powers","RR")
	return 1

/obj/effect/proc_holder/changeling/fleshmend/proc/fleshmend(mob/living/user)

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
		else
			break
		sleep(10)
