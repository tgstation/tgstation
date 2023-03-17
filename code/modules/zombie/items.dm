/obj/item/mutant_hand/zombie
	name = "zombie claw"
	desc = "A zombie's claw is its primary tool, capable of infecting \
		humans, butchering all other living things to \
		sustain the zombie, smashing open airlock doors and opening \
		child-safe caps on bottles."

	hitsound = 'sound/hallucinations/growl1.ogg'
	force = 21 // Just enough to break airlocks with melee attacks
	wound_bonus = -30
	bare_wound_bonus = 15
	sharpness = SHARP_EDGED

/obj/item/mutant_hand/zombie/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
	else if(isliving(target))
		if(ishuman(target))
			try_to_zombie_infect(target)
		else
			. |= AFTERATTACK_PROCESSED_ITEM
			check_feast(target, user)

/proc/try_to_zombie_infect(mob/living/carbon/human/target)
	CHECK_DNA_AND_SPECIES(target)

	if(NOZOMBIE in target.dna.species.species_traits)
		// cannot infect any NOZOMBIE subspecies (such as high functioning
		// zombies)
		return

	// spaceacillin has a 75% chance to block infection
	if(istype(target) && target.reagents.has_reagent(/datum/reagent/medicine/spaceacillin) && prob(75))
		return

	var/obj/item/organ/internal/zombie_infection/infection
	infection = target.getorganslot(ORGAN_SLOT_ZOMBIE)
	if(!infection)
		infection = new()
		infection.Insert(target)

/obj/item/mutant_hand/zombie/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is ripping [user.p_their()] brains out! It looks like [user.p_theyre()] trying to commit suicide!"))
	var/obj/item/bodypart/head = user.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.dismember()
	return BRUTELOSS

/obj/item/mutant_hand/zombie/proc/check_feast(mob/living/target, mob/living/user)
	if(target.stat == DEAD)
		var/hp_gained = target.maxHealth
		target.investigate_log("has been devoured by a zombie.", INVESTIGATE_DEATHS)
		target.gib()
		// zero as argument for no instant health update
		user.adjustBruteLoss(-hp_gained, 0)
		user.adjustToxLoss(-hp_gained, 0)
		user.adjustFireLoss(-hp_gained, 0)
		user.adjustCloneLoss(-hp_gained, 0)
		user.updatehealth()
		user.adjustOrganLoss(ORGAN_SLOT_BRAIN, -hp_gained) // Zom Bee gibbers "BRAAAAISNSs!1!"
		user.set_nutrition(min(user.nutrition + hp_gained, NUTRITION_LEVEL_FULL))
