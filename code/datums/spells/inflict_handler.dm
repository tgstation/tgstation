/obj/effect/proc_holder/spell/targeted/inflict_handler
	name = "Inflict Handler"
	desc = "This spell blinds and/or destroys/damages/heals and/or weakens/stuns the target."

	var/amt_weakened = 0
	var/amt_paralysis = 0
	var/amt_stunned = 0

	//set to negatives for healing
	var/amt_dam_fire = 0
	var/amt_dam_brute = 0
	var/amt_dam_oxy = 0
	var/amt_dam_tox = 0

	var/amt_eye_blind = 0
	var/amt_eye_blurry = 0

	var/destroys = "none" //can be "none", "gib" or "disintegrate"

	var/summon_type = null //this will put an obj at the target's location

/obj/effect/proc_holder/spell/targeted/inflict_handler/cast(list/targets)

	for(var/mob/living/target in targets)
		switch(destroys)
			if("gib")
				target.gib()
			if("gib_brain")
				if(ishuman(target) || ismonkey(target))
					var/mob/living/carbon/C_target = target
					var/obj/item/organ/brain/B = C_target.getorgan(/obj/item/organ/brain)
					if(B)
						B.loc = get_turf(C_target)
						B.transfer_identity(C_target)
						C_target.internal_organs -= B
				target.gib()
			if("disintegrate")
				target.dust()

		if(!target)
			continue
		//damage
		if(amt_dam_brute > 0)
			if(amt_dam_fire >= 0)
				target.take_overall_damage(amt_dam_brute,amt_dam_fire)
			else if (amt_dam_fire < 0)
				target.take_overall_damage(amt_dam_brute,0)
				target.heal_overall_damage(0,amt_dam_fire)
		else if(amt_dam_brute < 0)
			if(amt_dam_fire > 0)
				target.take_overall_damage(0,amt_dam_fire)
				target.heal_overall_damage(amt_dam_brute,0)
			else if (amt_dam_fire <= 0)
				target.heal_overall_damage(amt_dam_brute,amt_dam_fire)
		target.adjustToxLoss(amt_dam_tox)
		target.oxyloss += amt_dam_oxy
		//disabling
		target.Weaken(amt_weakened)
		target.Paralyse(amt_paralysis)
		target.Stun(amt_stunned)

		target.eye_blind += amt_eye_blind
		target.eye_blurry += amt_eye_blurry
		//summoning
		if(summon_type)
			new summon_type(target.loc, target)