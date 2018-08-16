/datum/species/proc/alt_spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	if(!istype(M))
		return TRUE
	CHECK_DNA_AND_SPECIES(M)
	CHECK_DNA_AND_SPECIES(H)

	if(!istype(M)) //sanity check for drones.
		return TRUE
	if(M.mind)
		attacker_style = M.mind.martial_art
	if((M != H) && M.a_intent != INTENT_HELP && H.check_shields(M, 0, M.name, attack_type = UNARMED_ATTACK))
		add_logs(M, H, "attempted to touch")
		H.visible_message("<span class='warning'>[M] attempted to touch [H]!</span>")
		return TRUE
	switch(M.a_intent)
		if("disarm")
			altdisarm(M, H, attacker_style)
			return TRUE
	return FALSE

/datum/species/proc/altdisarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(user.getStaminaLoss() >= STAMINA_SOFTCRIT)
		to_chat(user, "<span class='warning'>You're too exhausted.</span>")
		return FALSE
	else if(target.check_block())
		target.visible_message("<span class='warning'>[target] blocks [user]'s disarm attempt!</span>")
		return 0
	if(attacker_style && attacker_style.disarm_act(user,target))
		return 1
	else
		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)

		user.adjustStaminaLossBuffered(4) //CITADEL CHANGE - makes disarmspam cause staminaloss

		if(target.w_uniform)
			target.w_uniform.add_fingerprint(user)
		var/randomized_zone = ran_zone(user.zone_selected)
		SEND_SIGNAL(target, COMSIG_HUMAN_DISARM_HIT, user, user.zone_selected)
		var/obj/item/bodypart/affecting = target.get_bodypart(randomized_zone)
		var/randn = rand(1, 100)
		if(user.resting)
			randn += 20 //Makes it plausible, but unlikely, to push someone over while resting
		if(!user.combatmode)
			randn += 25 //Makes it impossible to push actually push someone outside of combat mode

		if(randn <= 25)
			playsound(target, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			target.visible_message("<span class='danger'>[user] has pushed [target]!</span>",
				"<span class='userdanger'>[user] has pushed [target]!</span>", null, COMBAT_MESSAGE_RANGE)
			target.apply_effect(40, EFFECT_KNOCKDOWN, target.run_armor_check(affecting, "melee", "Your armor prevents your fall!", "Your armor softens your fall!"))
			target.forcesay(GLOB.hit_appends)
			add_logs(user, target, "disarmed", " pushing them to the ground")
			return

		playsound(target, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		target.visible_message("<span class='danger'>[user] attempted to push [target]!</span>", \
						"<span class='userdanger'>[user] attemped to push [target]!</span>", null, COMBAT_MESSAGE_RANGE)

////////////////////
/////BODYPARTS/////
////////////////////


/obj/item/bodypart/var/should_draw_citadel = FALSE

/mob/living/carbon/proc/draw_citadel_parts(undo = FALSE)
	if(!undo)
		for(var/O in bodyparts)
			var/obj/item/bodypart/B = O
			B.should_draw_citadel = TRUE
	else
		for(var/O in bodyparts)
			var/obj/item/bodypart/B = O
			B.should_draw_citadel = FALSE

/datum/species/proc/citadel_mutant_bodyparts(bodypart, mob/living/carbon/human/H)
	switch(bodypart)
		if("ipc_screen")
			return GLOB.ipc_screens_list[H.dna.features["ipc_screen"]]
		if("ipc_antenna")
			return GLOB.ipc_antennas_list[H.dna.features["ipc_antenna"]]
		if("mam_tail")
			return GLOB.mam_tails_list[H.dna.features["mam_tail"]]
		if("mam_waggingtail")
			return GLOB.mam_tails_animated_list[H.dna.features["mam_tail"]]
		if("mam_body_markings")
			return GLOB.mam_body_markings_list[H.dna.features["mam_body_markings"]]
		if("mam_ears")
			return GLOB.mam_ears_list[H.dna.features["mam_ears"]]
		if("taur")
			return GLOB.taur_list[H.dna.features["taur"]]
		if("xenodorsal")
			return GLOB.xeno_dorsal_list[H.dna.features["xenodorsal"]]
		if("xenohead")
			return GLOB.xeno_head_list[H.dna.features["xenohead"]]
		if("xenotail")
			return GLOB.xeno_tail_list[H.dna.features["xenotail"]]
