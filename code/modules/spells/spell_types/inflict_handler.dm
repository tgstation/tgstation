/obj/effect/proc_holder/spell/targeted/inflict_handler
	name = "Inflict Handler"
	desc = "This spell blinds and/or destroys/damages/heals and/or knockdowns/paralyses the target."

	var/amt_knockdowned = 0
	var/amt_unconscious = 0
	var/amt_paralysis = 0

	//set to negatives for healing
	var/amt_dam_fire = 0
	var/amt_dam_brute = 0
	var/amt_dam_oxy = 0
	var/amt_dam_tox = 0

	var/amt_eye_blind = 0
	var/amt_eye_blurry = 0

	var/destroys = "none" //can be "none", "gib" or "disintegrate"

	var/summon_type = null //this will put an obj at the target's location

/obj/effect/proc_holder/spell/targeted/inflict_handler/cast(list/targets,mob/user = usr)

	for(var/mob/living/target in targets)
		playsound(target,sound, 50,1)
		switch(destroys)
			if("gib")
				target.gib()
			if("disintegrate")
				target.dust()

		if(!target)
			continue
		//damage/healing
		target.adjustBruteLoss(amt_dam_brute)
		target.adjustFireLoss(amt_dam_fire)
		target.adjustToxLoss(amt_dam_tox)
		target.adjustOxyLoss(amt_dam_oxy)
		//disabling
		target.Knockdown(amt_knockdowned)
		target.Unconscious(amt_unconscious)
		target.Paralyse(amt_paralysis)

		target.blind_eyes(amt_eye_blind)
		target.blur_eyes(amt_eye_blurry)
		//summoning
		if(summon_type)
			new summon_type(target.loc, target)