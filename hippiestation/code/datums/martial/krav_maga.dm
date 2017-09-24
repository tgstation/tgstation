/datum/martial_art/krav_maga/leg_sweep(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(D.stat || D.IsKnockdown())
		return FALSE
	D.visible_message("<span class='warning'>[A] leg sweeps [D]!</span>", \
					  	"<span class='userdanger'>[A] leg sweeps you!</span>")
	playsound(A, 'sound/effects/hit_kick.ogg', 50, 1, -1)
	D.apply_damage(5, BRUTE)
	D.Knockdown(20)
	add_logs(A, D, "leg sweeped")
	return TRUE

/datum/martial_art/krav_maga/quick_choke(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)//is actually lung punch
	D.visible_message("<span class='warning'>[A] pounds [D] on the chest!</span>", \
				  	"<span class='userdanger'>[A] slams your chest! You can't breathe!</span>")
	playsound(A, 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.losebreath = Clamp(D.losebreath + 2, 0, 10)
	D.adjustOxyLoss(5)
	add_logs(A, D, "quickchoked")
	return TRUE
