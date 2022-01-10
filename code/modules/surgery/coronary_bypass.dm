/datum/surgery/coronary_bypass
	name = "Coronary Bypass"
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise_heart,
		/datum/surgery_step/coronary_bypass,
		/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	organ_to_manipulate = ORGAN_SLOT_HEART

/datum/surgery/coronary_bypass/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/heart/target_heart = target.getorganslot(ORGAN_SLOT_HEART)
	if(target_heart)
		if(target_heart.damage > 60 && !target_heart.operated)
			return TRUE
	return FALSE


//an incision but with greater bleed, and a 90% base success chance
/datum/surgery_step/incise_heart
	name = "incise heart"
	implements = list(
		TOOL_SCALPEL = 90,
		/obj/item/melee/energy/sword = 45,
		/obj/item/knife = 45,
		/obj/item/shard = 25)
	time = 16

/datum/surgery_step/incise_heart/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to make an incision in [target]'s heart..."),
		span_notice("[user] begins to make an incision in [target]'s heart."),
		span_notice("[user] begins to make an incision in [target]'s heart."))
	display_pain(target, "You feel a horrendous pain in your heart, it's almost enough to make you pass out!")

/datum/surgery_step/incise_heart/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		if (!(NOBLOOD in target_human.dna.species.species_traits))
			display_results(user, target, span_notice("Blood pools around the incision in [target_human]'s heart."),
				span_notice("Blood pools around the incision in [target_human]'s heart."),
				"")
			var/obj/item/bodypart/target_bodypart = target_human.get_bodypart(target_zone)
			target_bodypart.generic_bleedstacks += 10
			target_human.adjustBruteLoss(10)
	return ..()

/datum/surgery_step/incise_heart/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		display_results(user, target, span_warning("You screw up, cutting too deeply into the heart!"),
			span_warning("[user] screws up, causing blood to spurt out of [target_human]'s chest!"),
			span_warning("[user] screws up, causing blood to spurt out of [target_human]'s chest!"))
		var/obj/item/bodypart/target_bodypart = target_human.get_bodypart(target_zone)
		target_bodypart.generic_bleedstacks += 10
		target_human.adjustOrganLoss(ORGAN_SLOT_HEART, 10)
		target_human.adjustBruteLoss(10)

//grafts a coronary bypass onto the individual's heart, success chance is 90% base again
/datum/surgery_step/coronary_bypass
	name = "graft coronary bypass"
	implements = list(
		TOOL_HEMOSTAT = 90,
		TOOL_WIRECUTTER = 35,
		/obj/item/stack/package_wrap = 15,
		/obj/item/stack/cable_coil = 5)
	time = 90

/datum/surgery_step/coronary_bypass/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to graft a bypass onto [target]'s heart..."),
			span_notice("[user] begins to graft something onto [target]'s heart!"),
			span_notice("[user] begins to graft something onto [target]'s heart!"))
	display_pain(target, "The pain in your chest is unbearable! You can barely take it anymore!")

/datum/surgery_step/coronary_bypass/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	target.setOrganLoss(ORGAN_SLOT_HEART, 60)
	var/obj/item/organ/heart/target_heart = target.getorganslot(ORGAN_SLOT_HEART)
	if(target_heart) //slightly worrying if we lost our heart mid-operation, but that's life
		target_heart.operated = TRUE
	display_results(user, target, span_notice("You successfully graft a bypass onto [target]'s heart."),
			span_notice("[user] finishes grafting something onto [target]'s heart."),
			span_notice("[user] finishes grafting something onto [target]'s heart."))
	display_pain(target, "The pain in your chest throbs, but your heart feels better than ever!")
	return ..()

/datum/surgery_step/coronary_bypass/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		display_results(user, target, span_warning("You screw up in attaching the graft, and it tears off, tearing part of the heart!"),
			span_warning("[user] screws up, causing blood to spurt out of [target_human]'s chest profusely!"),
			span_warning("[user] screws up, causing blood to spurt out of [target_human]'s chest profusely!"))
		display_pain(target, "Your chest burns; you feel like you're going insane!")
		target_human.adjustOrganLoss(ORGAN_SLOT_HEART, 20)
		var/obj/item/bodypart/target_bodypart = target_human.get_bodypart(target_zone)
		target_bodypart.generic_bleedstacks += 30
	return FALSE
