/datum/surgery_operation/limb/bioware
	implements = list(
		IMPLEMENT_HAND = 1,
	)
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_MORBID
	time = 12.5 SECONDS
	/// What status effect is gained when the surgery is successful?
	/// Used to check against other bioware types to prevent stacking.
	var/status_effect_gained = /datum/status_effect/bioware
	/// Zone to operate on for this bioware
	var/required_zone = BODY_ZONE_CHEST

/datum/surgery_operation/limb/bioware/get_default_radial_image(obj/item/bodypart/limb, mob/living/surgeon, tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(image('icons/hud/implants.dmi', "lighting_bolt"))
	return base

/datum/surgery_operation/limb/bioware/state_check(obj/item/bodypart/limb)
	if(limb.surgery_bone_state < SURGERY_VESSELS_ORGANS_CUT)
		return FALSE
	if(limb.surgery_vessel_state < SURGERY_BONE_SAWED)
		return FALSE
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(limb.body_zone != required_zone)
		return FALSE
	if(limb.owner.has_status_effect(status_effect_gained))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/bioware/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	limb.owner.apply_status_effect(status_effect_gained)
	if(limb.owner.ckey)
		SSblackbox.record_feedback("tally", "bioware", 1, status_effect_gained)

/datum/surgery_operation/limb/bioware/thread_veins
	name = "thread veins"
	desc = "Weave the patient's veins into a reinforced mesh, reducing blood loss from injuries."
	status_effect_gained = /datum/status_effect/bioware/heart/threaded_veins

/datum/surgery_operation/limb/bioware/thread_veins/preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start weaving [limb.owner]'s circulatory system."),
		span_notice("[surgeon] starts weaving [limb.owner]'s circulatory system."),
		span_notice("[surgeon] starts manipulating [limb.owner]'s circulatory system."),
	)
	display_pain(limb.owner, "Your entire body burns in agony!")

/datum/surgery_operation/limb/bioware/thread_veins/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You weave [limb.owner]'s circulatory system into a resistant mesh!"),
		span_notice("[surgeon] weaves [limb.owner]'s circulatory system into a resistant mesh!"),
		span_notice("[surgeon] finishes manipulating [limb.owner]'s circulatory system."),
	)
	display_pain(limb.owner, "You can feel your blood pumping through reinforced veins!")

/datum/surgery_operation/limb/bioware/muscled_veins
	name = "muscled veins"
	desc = "Add a muscled membrane to the patient's veins, allowing them to pump blood without a heart."
	status_effect_gained = /datum/status_effect/bioware/heart/muscled_veins

/datum/surgery_operation/limb/bioware/muscled_veins/preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start wrapping muscles around [limb.owner]'s circulatory system."),
		span_notice("[surgeon] starts wrapping muscles around [limb.owner]'s circulatory system."),
		span_notice("[surgeon] starts manipulating [limb.owner]'s circulatory system."),
	)
	display_pain(limb.owner, "Your entire body burns in agony!")

/datum/surgery_operation/limb/bioware/muscled_veins/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You reshape [limb.owner]'s circulatory system, adding a muscled membrane!"),
		span_notice("[surgeon] reshapes [limb.owner]'s circulatory system, adding a muscled membrane!"),
		span_notice("[surgeon] finishes manipulating [limb.owner]'s circulatory system."),
	)
	display_pain(limb.owner, "You can feel your heartbeat's powerful pulses ripple through your body!")

/datum/surgery_operation/limb/bioware/splice_nerves
	name = "splice nerves"
	desc = "Splice the patient's nerves to make them more resistant to stuns."
	time = 15.5 SECONDS
	status_effect_gained = /datum/status_effect/bioware/nerves/spliced

/datum/surgery_operation/limb/bioware/splice_nerves/preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start splicing together [limb.owner]'s nerves."),
		span_notice("[surgeon] starts splicing together [limb.owner]'s nerves."),
		span_notice("[surgeon] starts manipulating [limb.owner]'s nervous system."),
	)
	display_pain(limb.owner, "Your entire body goes numb!")

/datum/surgery_operation/limb/bioware/splice_nerves/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully splice [limb.owner]'s nervous system!"),
		span_notice("[surgeon] successfully splices [limb.owner]'s nervous system!"),
		span_notice("[surgeon] finishes manipulating [limb.owner]'s nervous system."),
	)
	display_pain(limb.owner, "You regain feeling in your body; It feels like everything's happening around you in slow motion!")

/datum/surgery_operation/limb/bioware/ground_nerves
	name = "ground nerves"
	desc = "Reroute the patient's nerves to act as grounding rods, protecting them from electrical shocks."
	time = 15.5 SECONDS
	status_effect_gained = /datum/status_effect/bioware/nerves/grounded

/datum/surgery_operation/limb/bioware/ground_nerves/preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start rerouting [limb.owner]'s nerves."),
		span_notice("[surgeon] starts rerouting [limb.owner]'s nerves."),
		span_notice("[surgeon] starts manipulating [limb.owner]'s nervous system."),
	)
	display_pain(limb.owner, "Your entire body goes numb!")

/datum/surgery_operation/limb/bioware/ground_nerves/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully reroute [limb.owner]'s nervous system!"),
		span_notice("[surgeon] successfully reroutes [limb.owner]'s nervous system!"),
		span_notice("[surgeon] finishes manipulating [limb.owner]'s nervous system."),
	)
	display_pain(limb.owner, "You regain feeling in your body! You feel energzed!")

/datum/surgery_operation/limb/bioware/reshape_ligaments
	name = "reshape ligaments"
	desc = "Reshape the patient's ligaments to allow limbs to be manually reattached if severed, at the cost of making them easier to detach."
	status_effect_gained = /datum/status_effect/bioware/ligaments/hooked

/datum/surgery_operation/limb/bioware/reshape_ligaments/preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start reshaping [limb.owner]'s ligaments into a hook-like shape."),
		span_notice("[surgeon] starts reshaping [limb.owner]'s ligaments into a hook-like shape."),
		span_notice("[surgeon] starts manipulating [limb.owner]'s ligaments."),
	)
	display_pain(limb.owner, "Your limbs burn with severe pain!")

/datum/surgery_operation/limb/bioware/reshape_ligaments/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You reshape [limb.owner]'s ligaments into a connective hook!"),
		span_notice("[surgeon] reshapes [limb.owner]'s ligaments into a connective hook!"),
		span_notice("[surgeon] finishes manipulating [limb.owner]'s ligaments."),
	)
	display_pain(limb.owner, "Your limbs feel... strangely loose.")

/datum/surgery_operation/limb/bioware/strengthen_ligaments
	name = "strengthen ligaments"
	desc = "Strengthen the patient's ligaments to make dismemberment more difficult, at the cost of making nerve connections easier to interrupt."
	status_effect_gained = /datum/status_effect/bioware/ligaments/reinforced

/datum/surgery_operation/limb/bioware/strengthen_ligaments/preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start reinforcing [limb.owner]'s ligaments."),
		span_notice("[surgeon] starts reinforce [limb.owner]'s ligaments."),
		span_notice("[surgeon] starts manipulating [limb.owner]'s ligaments."),
	)
	display_pain(limb.owner, "Your limbs burn with severe pain!")

/datum/surgery_operation/limb/bioware/strengthen_ligaments/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You reinforce [limb.owner]'s ligaments!"),
		span_notice("[surgeon] reinforces [limb.owner]'s ligaments!"),
		span_notice("[surgeon] finishes manipulating [limb.owner]'s ligaments."),
	)
	display_pain(limb.owner, "Your limbs feel more secure, but also more frail.")

/datum/surgery_operation/limb/bioware/cortex_folding
	name = "cortex folding"
	desc = "A biological upgrade which folds the patient's cerebral cortex into a fractal pattern, increasing neural density and flexibility."
	status_effect_gained = /datum/status_effect/bioware/cortex/folded

/datum/surgery_operation/limb/bioware/cortex_folding/preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start folding [limb.owner]'s cerebral cortex."),
		span_notice("[surgeon] starts folding [limb.owner]'s cerebral cortex."),
		span_notice("[surgeon] starts performing surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your head throbs with gruesome pain, it's nearly too much to handle!")

/datum/surgery_operation/limb/bioware/cortex_folding/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You fold [limb.owner]'s cerebral cortex into a fractal pattern!"),
		span_notice("[surgeon] folds [limb.owner]'s cerebral cortex into a fractal pattern!"),
		span_notice("[surgeon] completes the surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your brain feels stronger... more flexible!")

/datum/surgery_operation/limb/bioware/cortex_folding/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool, total_penalty_modifier)
	if(!limb.owner.get_organ_slot(ORGAN_SLOT_BRAIN))
		return ..()
	display_results(
		surgeon,
		limb.owner,
		span_warning("You screw up, damaging the brain!"),
		span_warning("[surgeon] screws up, damaging the brain!"),
		span_notice("[surgeon] completes the surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your head throbs with excruciating pain!")
	limb.owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
	limb.owner.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/limb/bioware/cortex_imprint
	name = "cortex imprinting"
	desc = "A biological upgrade which carves the patient's cerebral cortex into a self-imprinting pattern, increasing neural density and resilience."
	status_effect_gained = /datum/status_effect/bioware/cortex/imprinted

/datum/surgery_operation/limb/bioware/cortex_imprint/preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start carving [limb.owner]'s outer cerebral cortex into a self-imprinting pattern."),
		span_notice("[surgeon] starts carving [limb.owner]'s outer cerebral cortex into a self-imprinting pattern."),
		span_notice("[surgeon] starts performing surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your head throbs with gruesome pain, it's nearly too much to handle!")

/datum/surgery_operation/limb/bioware/cortex_imprint/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You reshape [limb.owner]'s outer cerebral cortex into a self-imprinting pattern!"),
		span_notice("[surgeon] reshapes [limb.owner]'s outer cerebral cortex into a self-imprinting pattern!"),
		span_notice("[surgeon] completes the surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your brain feels stronger... more resillient!")

/datum/surgery_operation/limb/bioware/cortex_imprint/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool, total_penalty_modifier)
	if(!limb.owner.get_organ_slot(ORGAN_SLOT_BRAIN))
		return ..()
	display_results(
		surgeon,
		limb.owner,
		span_warning("You screw up, damaging the brain!"),
		span_warning("[surgeon] screws up, damaging the brain!"),
		span_notice("[surgeon] completes the surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your brain throbs with intense pain; Thinking hurts!")
	limb.owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
	limb.owner.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
