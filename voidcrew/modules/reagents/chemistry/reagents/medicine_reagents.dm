/datum/reagent/medicine/trophazole
	name = "Trophazole"
	description = "Orginally developed as fitness supplement, this chemical accelerates wound healing and if ingested turns nutriment into healing peptides"
	reagent_state = LIQUID
	color = "#FFFF6B"
	overdose_threshold = 20

/datum/reagent/medicine/trophazole/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-1.5*REM, 0.) // heals 3 brute & 0.5 burn if taken with food. compared to 2.5 brute from bicard + nutriment
	..()
	. = 1

/datum/reagent/medicine/trophazole/overdose_process(mob/living/M)
	M.adjustBruteLoss(3*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/trophazole/on_transfer(atom/A, method=INGEST, trans_volume)
	if(method != INGEST || !iscarbon(A))
		return

	A.reagents.remove_reagent(/datum/reagent/medicine/trophazole, trans_volume * 0.05)
	A.reagents.add_reagent(/datum/reagent/medicine/metafactor, trans_volume * 0.25)

	..()


/datum/reagent/medicine/rhigoxane
	name = "Rhigoxane"
	description = "A second generation burn treatment agent exhibiting a cooling effect that is especially pronounced when deployed as a spray. Its high halogen content helps extinguish fires."
	reagent_state = LIQUID
	color = "#F7FFA5"
	overdose_threshold = 25
	reagent_weight = 0.6

/datum/reagent/medicine/rhigoxane/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-2*REM, 0.)
	M.adjust_bodytemperature(-20 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = 1

/datum/reagent/medicine/rhigoxane/expose_mob(mob/living/carbon/M, method=VAPOR, reac_volume)
	if(method != VAPOR)
		return

	M.adjust_bodytemperature(-reac_volume * TEMPERATURE_DAMAGE_COEFFICIENT * 20, 200)
	M.adjust_fire_stacks(-reac_volume / 2)
	if(reac_volume >= metabolization_rate)
		M.extinguish_mob()

	..()

/datum/reagent/medicine/rhigoxane/overdose_process(mob/living/carbon/M)
	M.adjustFireLoss(3*REM, 0.)
	M.adjust_bodytemperature(-35 * TEMPERATURE_DAMAGE_COEFFICIENT, 50)
	..()


/datum/reagent/medicine/thializid
	name = "Thializid"
	description = "A potent antidote for intravenous use with a narrow therapeutic index, it is considered an active prodrug of oxalizid."
	reagent_state = LIQUID
	color = "#8CDF24" // heavy saturation to make the color blend better
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	overdose_threshold = 6
	var/conversion_amount
/*
/datum/reagent/medicine/thializid/on_transfer(atom/A, method=INJECT, trans_volume)
	if(method != INJECT || !iscarbon(A))
		return
	var/mob/living/carbon/C = A
	if(trans_volume >= 0.6) //prevents cheesing with ultralow doses.
		C.adjustToxLoss(-1.5 * min(2, trans_volume) * REM, 0)	  //This is to promote iv pole use for that chemotherapy feel.
	var/obj/item/organ/internal/liver/L = C.internal_organs_slot[ORGAN_SLOT_LIVER]
	if((L.organ_flags & ORGAN_FAILING) || !L)
		return
	conversion_amount = trans_volume * (min(100 -C.getOrganLoss(ORGAN_SLOT_LIVER), 80) / 100) //the more damaged the liver the worse we metabolize.
	C.reagents.remove_reagent(/datum/reagent/medicine/thializid, conversion_amount)
	C.reagents.add_reagent(/datum/reagent/medicine/oxalizid, conversion_amount)
	..()
*/
/datum/reagent/medicine/thializid/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.8)
	M.adjustToxLoss(-1*REM, 0)
	for(var/datum/reagent/toxin/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.type,1)

	..()
	. = 1

/datum/reagent/medicine/thializid/overdose_process(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 1.5)
	M.adjust_disgust(3)
	M.reagents.add_reagent(/datum/reagent/medicine/oxalizid, 0.225 * REM)
	..()
	. = 1

/datum/reagent/medicine/oxalizid
	name = "Oxalizid"
	description = "The active metabolite of thializid. Causes muscle weakness on overdose"
	reagent_state = LIQUID
	color = "#DFD54E"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 25
	var/datum/brain_trauma/mild/muscle_weakness/U

/datum/reagent/medicine/oxalizid/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.1)
	M.adjustToxLoss(-1*REM, 0)
	for(var/datum/reagent/toxin/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.type,1)
	..()
	. = 1

/datum/reagent/medicine/oxalizid/overdose_start(mob/living/carbon/M)
	U = new()
	M.gain_trauma(U, TRAUMA_RESILIENCE_ABSOLUTE)
	..()

/datum/reagent/medicine/oxalizid/on_mob_delete(mob/living/carbon/M)
	if(U)
		QDEL_NULL(U)
	return ..()

/datum/reagent/medicine/oxalizid/overdose_process(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 1.5)
	M.adjust_disgust(3)
	..()
	. = 1

/datum/reagent/medicine/soulus
	name = "Soulus Dust"
	description = "Ground legion cores. The dust quickly seals wounds yet slowly causes the tissue to undergo necrosis."
	reagent_state = SOLID
	color = "#302f20"
	metabolization_rate = REAGENTS_METABOLISM * 0.8
	overdose_threshold = 100
	var/clone_dam = 0.25
/*
/datum/reagent/medicine/soulus/expose_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		if(method in list(INGEST, INJECT))
			M.jitteriness += reac_volume
			if(M.getFireLoss())
				M.adjustFireLoss(-reac_volume*1.2)
			if(M.getBruteLoss())
				M.adjustBruteLoss(-reac_volume*1.2)
	if(prob(50))
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "legion", /datum/mood_event/legion_good, name)
	else
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "legion", /datum/mood_event/legion_bad, name)
	..()

/datum/reagent/medicine/soulus/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-0.1*REM, 0)
	M.adjustBruteLoss(-0.1*REM, 0)
	M.adjustCloneLoss(clone_dam *REM, 0)
	..()

/datum/reagent/medicine/soulus/overdose_process(mob/living/M)
	M.ForceContractDisease(new /datum/disease/transformation/legionvirus(), FALSE, TRUE)
	..()

/datum/reagent/medicine/soulus/on_mob_end_metabolize(mob/living/M)
	SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "legion")
	..()
*/
/datum/reagent/medicine/soulus/pure
	name = "Purified Soulus Dust"
	description = "Ground legion cores."
	reagent_state = SOLID
	color = "#302f20"
	metabolization_rate = REAGENTS_METABOLISM
	overdose_threshold = 100
	clone_dam = 0

/datum/reagent/medicine/puce_essence		// P U C E
	name = "Pucetylline Essence"
	description = "Ground essence of puce crystals."
	reagent_state = SOLID
	color = "#CC8899"
	metabolization_rate = 2.5 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/puce_essence/on_mob_life(mob/living/carbon/M)
	if(prob(80))
		M.adjustToxLoss(-1*REM, 0)
	else
		M.adjustCloneLoss(-1*REM, 0)
	for(var/datum/reagent/toxin/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.type, 0.25)
	if(holder.has_reagent(/datum/reagent/medicine/soulus))				// No, you can't chemstack with soulus dust
		holder.remove_reagent(/datum/reagent/medicine/soulus, 5)
	M.add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY)		// Changes color to puce
	..()

/datum/reagent/medicine/puce_essence/expose_atom(atom/A, volume)
	if(!iscarbon(A))
		A.add_atom_colour(color, WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/medicine/puce_essence/on_mob_end_metabolize(mob/living/M)
	M.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, color)		// Removes temporary (not permanent) puce

/datum/reagent/medicine/puce_essence/overdose_process(mob/living/M)
	M.add_atom_colour(color, FIXED_COLOUR_PRIORITY)		// Eternal puce

/datum/reagent/medicine/chartreuse		// C H A R T R E U S E
	name = "Chartreuse Solution"
	description = "Refined essence of puce crystals."
	reagent_state = SOLID
	color = "#DFFF00"
	metabolization_rate = 2.5 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/chartreuse/on_mob_life(mob/living/carbon/M)		// Yes, you can chemstack with soulus dust
	if(prob(80))
		M.adjustToxLoss(-2*REM, 0)
		M.adjustCloneLoss(-1*REM, 0)
	for(var/datum/reagent/toxin/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.type, 1)
	M.add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY)		// Changes color to chartreuse
	..()

/datum/reagent/medicine/chartreuse/expose_atom(atom/A, volume)
	if(!iscarbon(A))
		A.add_atom_colour(color, WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/medicine/chartreuse/on_mob_end_metabolize(mob/living/M)
	M.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, color)		// Removes temporary (not permanent) chartreuse

/datum/reagent/medicine/chartreuse/overdose_process(mob/living/M)
	M.add_atom_colour(color, FIXED_COLOUR_PRIORITY)		// Eternal chartreuse
	M.set_drugginess(15)		// Also druggy
	..()

/datum/reagent/medicine/lavaland_extract
	name = "Lavaland Extract"
	description = "An extract of lavaland atmospheric and mineral elements. Heals the user in small doses, but is extremely toxic otherwise."
	color = "#6B372E" //dark and red like lavaland
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	overdose_threshold = 10

/datum/reagent/medicine/lavaland_extract/expose_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	ADD_TRAIT(M, TRAIT_NOLIMBDISABLE, TRAIT_GENERIC)
	..()

/datum/reagent/medicine/lavaland_extract/on_mob_end_metabolize(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_NOLIMBDISABLE, TRAIT_GENERIC)
	..()

/datum/reagent/medicine/lavaland_extract/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-1*REM, 0)
	M.adjustBruteLoss(-1*REM, 0)
	M.adjustToxLoss(-1*REM, 0)
	if(M.health <= M.crit_threshold)
		M.adjustOxyLoss(-1*REM, 0)
	..()
	return TRUE

/datum/reagent/medicine/lavaland_extract/overdose_process(mob/living/M)		// Thanks to actioninja
	if(prob(2) && iscarbon(M))
		var/selected_part = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/obj/item/bodypart/bp = M.get_bodypart(selected_part)
		if(bp)
			M.visible_message("<span class='warning'>[M] feels a spike of pain!!</span>", "<span class='danger'>You feel a spike of pain!!</span>")
			bp.receive_damage(0, 0, 200)
		else	//SUCH A LUST FOR REVENGE!!!
			to_chat(M, "<span class='warning'>A phantom limb hurts!</span>")
			M.say("Why are we still here, just to suffer?", forced = /datum/reagent/medicine/lavaland_extract)
	return ..()

/datum/reagent/medicine/skeletons_boon
	name = "Skeleton’s Boon"
	description = "A robust solution of minerals that greatly strengthens the bones."
	color = "#dbdfa2"
	metabolization_rate = REAGENTS_METABOLISM * 0.125
	overdose_threshold = 50
	var/plasma_armor = 33
	var/skele_armor = 20
	var/added_armor = 0

/datum/reagent/medicine/skeletons_boon/expose_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	ADD_TRAIT(M, TRAIT_NEVER_WOUNDED, TRAIT_GENERIC)
	if(isplasmaman(M))
		var/mob/living/carbon/human/H = M
		H.physiology.armor = H.physiology.armor.generate_new_with_modifiers(list(MELEE = plasma_armor))
		H.physiology.armor = H.physiology.armor.generate_new_with_modifiers(list(BULLET = plasma_armor))
		added_armor = plasma_armor
	if(isskeleton(M))
		var/mob/living/carbon/human/H = M
		H.physiology.armor = H.physiology.armor.generate_new_with_modifiers(list(MELEE = skele_armor))
		H.physiology.armor = H.physiology.armor.generate_new_with_modifiers(list(BULLET = skele_armor))
		added_armor = skele_armor
	..()

/datum/reagent/medicine/skeletons_boon/on_mob_end_metabolize(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_NEVER_WOUNDED, TRAIT_GENERIC)
	REMOVE_TRAIT(M, TRAIT_EASILY_WOUNDED, TRAIT_GENERIC)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.physiology.armor = H.physiology.armor.generate_new_with_modifiers(list(MELEE = -added_armor))
		H.physiology.armor = H.physiology.armor.generate_new_with_modifiers(list(BULLET = -added_armor))		// No, you can't change species to get a permanant brute resist
	..()

/datum/reagent/medicine/skeletons_boon/overdose_process(mob/living/M)
	ADD_TRAIT(M, TRAIT_EASILY_WOUNDED, TRAIT_GENERIC)
	REMOVE_TRAIT(M, TRAIT_NEVER_WOUNDED, TRAIT_GENERIC)
	..()

/datum/reagent/medicine/molten_bubbles
	name = "Molten Bubbles"
	description = "Refreshing softdrink made for the desert."
	color = "#3d1916"
	metabolization_rate = REAGENTS_METABOLISM
	taste_description = "boiling sugar"

/datum/reagent/medicine/molten_bubbles/on_mob_life(mob/living/carbon/M)
	M.heal_bodypart_damage(1,1,0)
	if(M.bodytemperature > M.get_body_temp_normal(apply_change=FALSE))
		M.adjust_bodytemperature(-10 * TEMPERATURE_DAMAGE_COEFFICIENT, M.get_body_temp_normal(apply_change=FALSE))
	else if(M.bodytemperature < (M.get_body_temp_normal(apply_change=FALSE) + 1))
		M.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, M.get_body_temp_normal(apply_change=FALSE))
	..()

/datum/reagent/medicine/molten_bubbles/plasma
	name = "Plasma Bubbles"
	description = "Molten Bubbles with the refreshing taste of plasma."
	color = "#852e63"
	taste_description = "grape flavored cleaning solution"

/datum/reagent/medicine/molten_bubbles/sand
	name = "Sandblast Sarsaparilla"
	description = "Extra refreshing for those long desert days."
	color = "#af9938"
	taste_description = "root-beer and asbestos"
