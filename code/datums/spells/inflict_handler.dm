/obj/effect/proc_holder/spell/targeted/inflict_handler
	name = "Inflict Handler"
	desc = "This spell blinds and/or destroys/damages/heals and/or weakens/stuns the target."

	var/amt_weakened = 0
	var/amt_paralysis = 0
	var/amt_stunned = 0

	var/amt_dizziness = 0
	var/amt_confused = 0
	var/amt_stuttering = 0

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
					var/mob/living/carbon/C = target
					if(C.brain_op_stage != 4) // Their brain is already taken out
						var/obj/item/brain/B = new(C.loc)
						B.transfer_identity(C)
				target.gib()
			if("disintegrate")
				target.dust()
				
			if("butt")
				if(ishuman(target) || ismonkey(target))
					var/mob/living/carbon/C = target
					if(C.op_stage.butt != 4) // does the target have an ass
						playsound(get_turf(src), 'sound/effects/superfart.ogg', 50, 1)
						var/obj/item/clothing/head/butt/B = new(C.loc)
						B.transfer_buttdentity(C)
						C.op_stage.butt = 4 //No having two butts.
						C.apply_damage(40, BRUTE, "groin")
						C.apply_damage(10, BURN, "groin")
						C.Stun(8)
						C.Weaken(8)
						C << "\red Your ass just blew up!"
					else
						playsound(get_turf(src), 'sound/effects/superfart.ogg', 50, 1)
						C.apply_damage(40, BRUTE, "groin")
						C.apply_damage(10, BURN, "groin")
						C.Stun(8)
						C.Weaken(8)


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
		if(amt_weakened || amt_paralysis || amt_stunned)
			if(target.buckled)
				target.buckled.unbuckle()
		target.eye_blind += amt_eye_blind
		target.eye_blurry += amt_eye_blurry
		target.dizziness += amt_dizziness
		target.confused += amt_confused
		target.stuttering += amt_stuttering
		//summoning
		if(summon_type)
			new summon_type(target.loc, target)
