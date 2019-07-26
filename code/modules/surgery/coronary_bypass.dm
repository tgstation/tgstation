/datum/surgery/coronary_bypass
	name = "Coronary Bypass"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/clamp_bleeders,
				 /datum/surgery_step/incise_heart, /datum/surgery_step/coronary_bypass, /datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery/coronary_bypass/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/heart/H = target.getorganslot(ORGAN_SLOT_HEART)
	if(H)
		if(H.damage > 60 && !H.operated)
			return TRUE
	return FALSE


//an incision but with greater bleed, and a 90% base success chance
/datum/surgery_step/incise_heart
	name = "incise heart"
	implements = list(/obj/item/scalpel = 90, /obj/item/melee/transforming/energy/sword = 45, /obj/item/kitchen/knife = 45,
		/obj/item/shard = 25)
	time = 16

/datum/surgery_step/incise_heart/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to make an incision in [target]'s heart...</span>",
		"[user] begins to make an incision in [target]'s heart.",
		"[user] begins to make an incision in [target]'s heart.")

/datum/surgery_step/incise_heart/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if (!(NOBLOOD in H.dna.species.species_traits))
			display_results(user, target, "<span class='notice'>Blood pools around the incision in [H]'s heart.</span>",
				"Blood pools around the incision in [H]'s heart.",
				"")
			H.bleed_rate += 10
			H.adjustBruteLoss(10)
	return TRUE

/datum/surgery_step/incise_heart/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		display_results(user, target, "<span class='warning'>You screw up, cutting too deeply into the heart!</span>",
			"<span class='warning'>[user] screws up, causing blood to spurt out of [H]'s chest!</span>",
			"<span class='warning'>[user] screws up, causing blood to spurt out of [H]'s chest!</span>")
		H.bleed_rate += 20
		H.adjustOrganLoss(ORGAN_SLOT_HEART, 10)
		H.adjustBruteLoss(10)

//grafts a coronary bypass onto the individual's heart, success chance is 90% base again
/datum/surgery_step/coronary_bypass
	name = "graft coronary bypass"
	implements = list(/obj/item/hemostat = 90, TOOL_WIRECUTTER = 35, /obj/item/stack/packageWrap = 15, /obj/item/stack/cable_coil = 5)
	time = 90

/datum/surgery_step/coronary_bypass/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to graft a bypass onto [target]'s heart...</span>",
			"[user] begins to graft something onto [target]'s heart!",
			"[user] begins to graft something onto [target]'s heart!")

/datum/surgery_step/coronary_bypass/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.setOrganLoss(ORGAN_SLOT_HEART, 60)
	var/obj/item/organ/heart/heart = target.getorganslot(ORGAN_SLOT_HEART)
	if(heart)	//slightly worrying if we lost our heart mid-operation, but that's life
		heart.operated = TRUE
	display_results(user, target, "<span class='notice'>You successfully graft a bypass onto [target]'s heart.</span>",
			"[user] finishes grafting something onto [target]'s heart.",
			"[user] finishes grafting something onto [target]'s heart.")
	return TRUE

/datum/surgery_step/coronary_bypass/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		display_results(user, target, "<span class='warning'>You screw up in attaching the graft, and it tears off, tearing part of the heart!</span>",
			"<span class='warning'>[user] screws up, causing blood to spurt out of [H]'s chest profusely!</span>",
			"<span class='warning'>[user] screws up, causing blood to spurt out of [H]'s chest profusely!</span>")
		H.adjustOrganLoss(ORGAN_SLOT_HEART, 20)
		H.bleed_rate += 30
	return FALSE
