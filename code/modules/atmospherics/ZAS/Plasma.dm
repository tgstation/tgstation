GLOBAL_DATUM_INIT(contamination_overlay, /image, image('icons/effects/contamination.dmi'))

/pl_control
	var/plasma_dmg = 3
	var/plasma_dmg_name = "Plasma Damage Amount"
	var/plasma_dmg_desc = "Self Descriptive"

	var/cloth_contamination = TRUE
	var/cloth_contamination_name = "Cloth Contamination"
	var/cloth_contamination_desc = "If this is on, phoron does damage by getting into cloth."

	var/plasmaguard_only = FALSE
	var/plamaguard_only_name = "\"PlasmaGuard Only\""
	var/plasmaguard_only_desc = "If this is on, only biosuits and spacesuits protect against contamination and ill effects."

	var/genetic_corruption = FALSE
	var/genetic_corruption_name = "Genetic Corruption Chance"
	var/genetic_corruption_desc = "Chance of genetic corruption as well as toxic damage, X in 10,000."

	var/skin_burns = TRUE
	var/skin_burns_name = "Skin Burns"
	var/skin_burns_desc = "Phoron has an effect similar to mustard gas on the un-suited."

	var/eye_burns = TRUE
	var/eye_burns_name = "Eye Burns"
	var/eye_burns_desc = "Phoron burns the eyes of anyone not wearing eye protection."

	var/contamination_loss = 0.02
	var/contamination_loss_name = "Contamination Loss"
	var/contamination_loss_desc = "How much toxin damage is dealt from contaminated clothing" //Per tick?  ASK ARYN

	var/phoron_hallucination = 0
	var/phoron_hallucination_name = "Phoron Hallucination"
	var/phoron_hallucination_desc = "Does being in phoron cause you to hallucinate?"


/atom/proc/can_contaminate()
	return

/atom/proc/contaminate()
	return

/atom/proc/decontaminate()
	return

/obj/item/can_contaminate()
	//Clothing can be contaminated, with exceptions for certain items which cannot be washed in washing_machine.dm
	if(obj_flags & PLASMAGUARD)
		return FALSE
	return TRUE

/obj/item/contaminate()
	//Do a contamination overlay? Temporary measure to keep contamination less deadly than it was.
	if(!(flags_1 & CONTAMINATED_1))
		flags_1 |= CONTAMINATED_1
		add_overlay(GLOB.contamination_overlay)

/obj/item/decontaminate()
	flags_1 ~= CONTAMINATED_1
	cut_overlay(GLOB.contamination_overlay)


/mob/living/carbon/human/contaminate()
	//See if anything can be contaminated.

	if(!pl_suit_protected())
		suit_contamination()

	if(!pl_head_protected())
		if(prob(1))
			suit_contamination() //Phoron can sometimes get through such an open suit.

//Cannot wash backpacks currently.
//	if(istype(back,/obj/item/storage/backpack))
//		back.contaminate()

/atom/proc/expose_plasma()
	return

/mob/living/carbon/human/expose_plasma()
	//Handles all the bad things phoron can do.

	//Contamination
	if(SSzas.settings.plc.cloth_contamination)
		contaminate()

	//Anything else requires them to not be dead.
	if(stat >= 2)
		return

	//Burn skin if exposed.
	if(SSzas.settings.plc.skin_burns)
		if(!pl_head_protected() || !pl_suit_protected())
			burn_skin(0.75)
			if(prob(20))
				to_chat(src, "<span class='danger'>Your skin burns!</span>")
			updatehealth()

	//Burn eyes if exposed.
	if(SSzas.settings.plc.eye_burns)
		if(!is_eyes_covered())
			burn_eyes()

	//Genetic Corruption
	if(SSzas.settings.plc.genetic_corruption)
		if(rand(1,10000) < SSzas.settings.plc.genetic_corruption)
			easy_random_mutate(NEGATIVE)
			to_chat(src, "<span class='danger'>High levels of toxins cause you to spontaneously mutate!</span>")
			domutcheck(src, null)

/mob/proc/burn_eyes()
	return

/mob/living/carbon/human/burn_eyes()
	var/obj/item/organ/eyes/E = getorganslot(ORGAN_SLOT_EYES)
	if(E && !E.status == ORGAN_ROBOTIC)
		if(prob(20))
			to_chat(src, "<span class='danger'>Your eyes burn!</span>")
			E.applyOrganDamage(2.5)
		eye_blurry = min(eye_blurry+1.5,50)
		if (prob(max(0, E.damage - 15) + 1) &&!eye_blind)
			to_chat(src, "<span class='danger'>You are blinded!</span>")
			eye_blind += 20

/mob/living/carbon/human/proc/pl_head_protected()
	//Checks if the head is adequately sealed.
	if(head)
		if(SSzas.settings.plc.plasmaguard_only)
			if(head.item_flags & PLASMAGUARD)
				return TRUE
		else if(is_eyes_covered())
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/pl_suit_protected()
	//Checks if the suit is adequately sealed.
	var/coverage = NONE
	for(var/obj/item/protection in list(wear_suit, gloves, shoes))
		if(!protection)
			continue
		if(istype(protection, /obj/item/clothing))
			var/obj/item/clothing/clothing_item = protection
			if(SSzas.settings.plc.plasmaguard_only && !((clothing_item.clothing_flags & THICKMATERIAL) || (clothing_item.clothing_flags & GAS_FILTERING) || (clothing_item.obj_flags & PLASMAGUARD)))
				return FALSE

		else if(SSzas.settings.plc.plasmaguard_only && !(protection.obj_flags & PLASMAGUARD))
			return FALSE

		coverage |= protection.body_parts_covered

	if(SSzas.settings.plc.plasmaguard_only)
		return TRUE

	return (~(coverage) & (CHEST|LEGS|FEET|ARMS|HANDS) == 0)

/mob/living/carbon/human/proc/suit_contamination()
	//Runs over the things that can be contaminated and does so.
	if (w_uniform && w_uniform.can_contaminate())
		w_uniform.contaminate()
	if (shoes && shoes.can_contaminate())
		shoes.contaminate()
	if (gloves && gloves.can_contaminate())
		gloves.contaminate()


/turf/Entered(obj/item/I)
	. = ..()
	//Items that are in plasma, but not on a mob, can still be contaminated.
	if(istype(I) && SSzas && SSzas.settings.plc.cloth_contamination && I.can_contaminate())
		var/datum/gas_mixture/env = return_air(1)
		if(!env)
			return
		for(var/g in env.gas)
			if(SSzas.gas_data.flags[g] & XGM_GAS_CONTAMINANT && env.gas[g] > SSzas.gas_data.overlay_limit[g] + 1)
				I.contaminate()
				break
