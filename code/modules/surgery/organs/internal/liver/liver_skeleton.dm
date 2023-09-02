/**
 * Bone liver
 * Gives the owner liverless metabolism, makes them vulnerable to bone hurting juice and
 * makes milk heal them through meme magic.
 **/
/obj/item/organ/internal/liver/bone
	name = "mass of bones"
	desc = "You have no idea what this strange ball of bones does."
	icon_state = "liver-bone"
	organ_traits = list(TRAIT_STABLELIVER)
	///Var for brute healing via milk
	var/milk_brute_healing = 2.5
	///Var for burn healing via milk
	var/milk_burn_healing = 2.5

/obj/item/organ/internal/liver/bone/handle_chemical(mob/living/carbon/organ_owner, datum/reagent/chem, seconds_per_tick, times_fired)
	. = ..()
	// parent returned COMSIG_MOB_STOP_REAGENT_CHECK or we are failing
	if((. & COMSIG_MOB_STOP_REAGENT_CHECK) || (organ_flags & ORGAN_FAILING))
		return
	if(istype(chem, /datum/reagent/toxin/bonehurtingjuice))
		organ_owner.adjustStaminaLoss(7.5 * REM * seconds_per_tick, 0)
		organ_owner.adjustBruteLoss(0.5 * REM * seconds_per_tick, 0)
		if(SPT_PROB(10, seconds_per_tick))
			switch(rand(1, 3))
				if(1)
					INVOKE_ASYNC(organ_owner, TYPE_PROC_REF(/atom/movable, say), pick("oof.", "ouch.", "my bones.", "oof ouch.", "oof ouch my bones."), forced = chem.type)
				if(2)
					organ_owner.manual_emote(pick("oofs silently.", "looks like [organ_owner.p_their()] bones hurt.", "grimaces, as though [organ_owner.p_their()] bones hurt."))
				if(3)
					to_chat(organ_owner, span_warning("Your bones hurt!"))
		if(chem.overdosed)
			if(SPT_PROB(2, seconds_per_tick)) //big oof
				var/selected_part = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG) //God help you if the same limb gets picked twice quickly...
				var/obj/item/bodypart/bodypart = organ_owner.get_bodypart(selected_part) //We're so sorry skeletons, you're so misunderstood
				if(bodypart)
					playsound(organ_owner, SFX_DESECRATION, 50, vary = TRUE) //You just want to socialize
					organ_owner.visible_message(span_warning("[organ_owner] rattles loudly and flails around!!"), span_danger("Your bones hurt so much that your missing muscles spasm!!"))
					INVOKE_ASYNC(organ_owner, TYPE_PROC_REF(/atom/movable, say), "OOF!!", forced = chem.type)
					bodypart.receive_damage(brute = 200) //But I don't think we should
				else
					to_chat(organ_owner, span_warning("Your missing [parse_zone(selected_part)] aches from wherever you left it."))
					INVOKE_ASYNC(organ_owner, TYPE_PROC_REF(/mob, emote), "sigh")
		organ_owner.reagents.remove_reagent(chem.type, chem.metabolization_rate * seconds_per_tick)
		return COMSIG_MOB_STOP_REAGENT_CHECK // Stop metabolism
	if(chem.type == /datum/reagent/consumable/milk)
		if(chem.volume > 50)
			organ_owner.reagents.remove_reagent(chem.type, (chem.volume - 50))
			to_chat(organ_owner, span_warning("The excess milk is dripping off your bones!"))
		organ_owner.heal_bodypart_damage(milk_brute_healing * REM * seconds_per_tick, milk_burn_healing * REM * seconds_per_tick)
		for(var/datum/wound/iter_wound as anything in organ_owner.all_wounds)
			iter_wound.on_xadone(1 * REM * seconds_per_tick)
		return // Do normal metabolism
