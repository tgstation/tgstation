/obj/effect/proc_holder/spell/targeted/inflict_handler
	name = "Inflict Handler"
	desc = "This spell blinds and/or destroys/damages/heals and/or knockdowns/stuns the target."

	var/amt_paralyze = ZERO
	var/amt_unconscious = ZERO
	var/amt_stun = ZERO

	var/inflict_status
	var/list/status_params = list()

	//set to negatives for healing
	var/amt_dam_fire = ZERO
	var/amt_dam_brute = ZERO
	var/amt_dam_oxy = ZERO
	var/amt_dam_tox = ZERO

	var/amt_eye_blind = ZERO
	var/amt_eye_blurry = ZERO

	var/destroys = "none" //can be "none", "gib" or "disintegrate"

	var/summon_type = null //this will put an obj at the target's location

	var/check_anti_magic = TRUE
	var/check_holy = FALSE

/obj/effect/proc_holder/spell/targeted/inflict_handler/cast(list/targets,mob/user = usr)
	for(var/mob/living/target in targets)
		playsound(target,sound, 50,TRUE)
		if(target.anti_magic_check(check_anti_magic, check_holy))
			return
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
		target.Paralyze(amt_paralyze)
		target.Unconscious(amt_unconscious)
		target.Stun(amt_stun)

		target.blind_eyes(amt_eye_blind)
		target.blur_eyes(amt_eye_blurry)
		//summoning
		if(summon_type)
			new summon_type(target.loc, target)

		if(inflict_status)
			var/list/stat_args = status_params.Copy()
			stat_args.Insert(1,inflict_status)
			target.apply_status_effect(arglist(stat_args))
