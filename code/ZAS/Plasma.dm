pl_control/var
	PLASMA_DMG = 3
	PLASMA_DMG_NAME = "Plasma Damage Multiplier"
	PLASMA_DMG_DESC = "Multiplier on how much damage inhaling plasma can do."

	CLOTH_CONTAMINATION = 0 //If this is on, plasma does damage by getting into cloth.
	CLOTH_CONTAMINATION_NAME = "Plasma - Cloth Contamination"
	CLOTH_CONTAMINATION_RANDOM = 60
	CLOTH_CONTAMINATION_METHOD = "Toggle"
	CLOTH_CONTAMINATION_DESC = "If set to nonzero, plasma will contaminate cloth items (uniforms, backpacks, etc.)\
	and cause a small amount of damage over time to anyone carrying or wearing them. Contamination can be washed off in the washer."

	ALL_ITEM_CONTAMINATION = 0 //If this is on, any item can be contaminated, so suits and tools must be discarded or
										  //decontaminated.
	ALL_ITEM_CONTAMINATION_NAME = "Plasma - Full Contamination"
	ALL_ITEM_CONTAMINATION_RANDOM = 10
	ALL_ITEM_CONTAMINATION_METHOD = "Toggle"
	ALL_ITEM_CONTAMINATION_DESC = "Like Cloth Contamination, but all item types are susceptible."

	PLASMAGUARD_ONLY = 0
	PLASMAGUARD_ONLY_NAME = "Plasma - Biosuits/Spacesuits Only"
	PLASMAGUARD_ONLY_RANDOM = 20
	PLASMAGUARD_ONLY_METHOD = "Toggle"
	PLASMAGUARD_ONLY_DESC = "If on, any suits that are not biosuits or space suits will not protect against contamination."

	//CANISTER_CORROSION = 0         //If this is on, plasma must be stored in orange tanks and canisters,
	//CANISTER_CORROSION_RANDOM = 20 //or it will corrode the tank.
	//CANISTER_CORROSION_METHOD = "Toggle"

	GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 10,000.
	GENETIC_CORRUPTION_NAME = "Plasma - Genetic Corruption"
	GENETIC_CORRUPTION_RANDOM = "PROB10/3d6"
	GENETIC_CORRUPTION_METHOD = "Numeric"
	GENETIC_CORRUPTION_DESC = "When set to a probability in 1000, any humans in plasma will have this chance to develop a random mutation."

	SKIN_BURNS = 1       //Plasma has an effect similar to mustard gas on the un-suited.
	SKIN_BURNS_NAME = "Plasma - Skin Burns"
	SKIN_BURNS_RANDOM = 10
	SKIN_BURNS_METHOD = "Toggle"
	SKIN_BURNS_DESC = "When toggled, humans with exposed skin will suffer burns (similar to mustard gas) in plasma."

	//PLASMA_INJECTS_TOXINS = 0         //Plasma damage injects the toxins chemical to do damage over time.
	//PLASMA_INJECTS_TOXINS_RANDOM = 30
	//PLASMA_INJECTS_TOXINS_METHOD = "Toggle"

	EYE_BURNS = 1 //Plasma burns the eyes of anyone not wearing eye protection.
	EYE_BURNS_NAME = "Plasma - Eye Burns"
	EYE_BURNS_RANDOM = 30
	EYE_BURNS_METHOD = "Toggle"
	EYE_BURNS_DESC = "When toggled, humans without masks that cover the eyes will suffer temporary blurriness and sight loss,\
	and may need glasses to see again if exposed for long durations."

	//N2O_REACTION = 0 //Plasma can react with N2O, making sparks and starting a fire if levels are high.
	//N2O_REACTION_RANDOM = 5

	//PLASMA_COLOR = "onturf" //Plasma can change colors yaaaay!
	//PLASMA_COLOR_RANDOM = "PICKonturf,onturf"

	//PLASMA_DMG_OFFSET = 1
	//PLASMA_DMG_OFFSET_RANDOM = "1d5"
	//PLASMA_DMG_QUOTIENT = 10
	//PLASMA_DMG_QUOTIENT_RANDOM = "1d10+4"

	CONTAMINATION_LOSS = 0.01
	CONTAMINATION_LOSS_NAME = "Plasma - Contamination Damage"
	CONTAMINATION_LOSS_DESC = "A number representing the damage done per life cycle by contaminated items."

	PLASMA_HALLUCINATION = 1
	PLASMA_HALLUCINATION_NAME = "Plasma - Hallucination"
	PLASMA_HALLUCINATION_METHOD = "Toggle"
	PLASMA_HALLUCINATION_DESC = "If toggled, uses the remnants of the hallucination code to induce visions in those\
	who breathe plasma."
	N2O_HALLUCINATION = 1
	N2O_HALLUCINATION_NAME = "Nitrous Oxide - Hallucination"
	N2O_HALLUCINATION_METHOD = "Toggle"
	N2O_HALLUCINATION_DESC = "If toggled, uses the remnants of the hallucination code to induce visions in those\
	who breathe N2O."
	//CONTAMINATION_LOSS_RANDOM = "5d5"
//Plasma has a chance to be a different color.

obj/var/contaminated = 0

obj/item/proc
	can_contaminate()
		if(flags & PLASMAGUARD) return 0
		if((flags & SUITSPACE) && !vsc.plc.PLASMAGUARD_ONLY) return 1
		if(vsc.plc.ALL_ITEM_CONTAMINATION) return 1
		else if(istype(src,/obj/item/clothing)) return 1
		else if(istype(src,/obj/item/weapon/storage/backpack)) return 1

	contaminate()
		if(!contaminated)
			contaminated = 1
			overlays += 'icons/effects/contamination.dmi'

	decontaminate()
		contaminated = 0
		overlays -= 'icons/effects/contamination.dmi'

/mob/proc/contaminate()

/mob/living/carbon/human/contaminate()
	if(!pl_suit_protected())
		suit_contamination()

	if(!pl_head_protected())
		if(prob(1)) suit_contamination() //Plasma can sometimes get through such an open suit.

	if(istype(back,/obj/item/weapon/storage/backpack))
		back.contaminate()

	/*if(l_hand)
		if(l_hand.can_contaminate()) l_hand.contaminate()
	if(r_hand)
		if(r_hand.can_contaminate()) r_hand.contaminate()
	if(belt)
		if(belt.can_contaminate()) belt.contaminate()*/

/mob/proc/pl_effects()

/mob/living/carbon/human/pl_effects()
	if(vsc.plc.CLOTH_CONTAMINATION) contaminate()
	if(stat >= 2)
		return
	if(vsc.plc.SKIN_BURNS)
		if(!pl_head_protected() || !pl_suit_protected())
			burn_skin(0.75)
			if(prob(20)) src << "\red Your skin burns!"
			updatehealth()

	if(vsc.plc.EYE_BURNS)
		if(!head)
			if(!wear_mask)
				burn_eyes()
			else
				if(!(wear_mask.flags & MASKCOVERSEYES))
					burn_eyes()
		else
			if(!(head.flags & MASKCOVERSEYES))
				if(!wear_mask)
					burn_eyes()
				else
					if(!(wear_mask.flags & MASKCOVERSEYES))
						burn_eyes()

	if(vsc.plc.GENETIC_CORRUPTION)
		if(rand(1,10000) < vsc.plc.GENETIC_CORRUPTION)
			randmutb(src)
			src << "\red High levels of toxins cause you to spontaneously mutate."
			domutcheck(src,null)

/mob/living/carbon/human/proc/burn_eyes()
	if(prob(20)) src << "\red Your eyes burn!"
	eye_stat += 2.5
	eye_blurry = min(eye_blurry+1.5,50)
	if (prob(max(0,eye_stat - 20) + 1) &&!eye_blind)
		src << "\red You are blinded!"
		eye_blind += 20
		eye_stat = 0

/mob/living/carbon/human/proc/pl_head_protected()
	if(head)
		if(vsc.plc.PLASMAGUARD_ONLY)
			if(head.flags & PLASMAGUARD || head.flags & HEADSPACE) return 1
		else
			if(head.flags & HEADCOVERSEYES) return 1
	return 0

/mob/living/carbon/human/proc/pl_suit_protected()
	if(wear_suit)
		if(vsc.plc.PLASMAGUARD_ONLY)
			if(wear_suit.flags & PLASMAGUARD || wear_suit.flags & SUITSPACE) return 1
		else
			if(wear_suit.flags_inv & HIDEJUMPSUIT) return 1
	return 0

/mob/living/carbon/human/proc/suit_contamination()
	if(w_uniform) w_uniform.contaminate()
	if(shoes) shoes.contaminate()
	if(gloves) gloves.contaminate()


turf/Entered(obj/item/I)
	. = ..()
	if(istype(I) && vsc.plc.CLOTH_CONTAMINATION)
		var/datum/gas_mixture/env = return_air(1)
		if(env.toxins > MOLES_PLASMA_VISIBLE + 1)
			if(I.can_contaminate())
				I.contaminate()