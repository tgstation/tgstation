/// Repairing specific organs
/datum/surgery_operation/organ_repair
	name = "repair organ"
	desc = "Repair a patient's damaged organ."
	/// What organ to repair
	var/obj/item/organ/target_type

	/// If TRUE
	var/flat_healing = FALSE
	/// What % damage do we heal the organ to on success
	/// Note that 0% damage = 100% health
	var/heal_to_percent = 0.6
	/// What % damage do we apply to the organ on failure
	var/failure_damage_percent = 0.2
	/// If TRUE, an organ can be repaired multiple times
	var/repeatable = FALSE

/datum/surgery_operation/organ_repair/New()
	. = ..()
	if(operation_flags & OPERATION_LOOPING)
		repeatable = TRUE // if it's looping it would necessitate being repeatable

/datum/surgery_operation/organ_repair/is_available(obj/item/bodypart/limb)
	var/obj/item/organ/to_repair = locate(target_type) in limb
	if(isnull(to_repair))
		return FALSE
	if(to_repair.damage < (to_repair.maxHealth * heal_to_percent) || (!repeatable && HAS_TRAIT(to_repair, TRAIT_ORGAN_OPERATED_ON)))
		return FALSE
	return TRUE

/datum/surgery_operation/organ_repair/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(limb.surgery_vessel_state != SURGERY_VESSELS_ORGANS_CUT)
		return FALSE
	if(limb.surgery_bone_state != SURGERY_BONE_SAWED)
		return FALSE
	return TRUE

/datum/surgery_operation/organ_repair/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/organ/to_repair = locate(target_type) in limb
	to_repair.set_organ_damage(to_repair.maxHealth * heal_to_percent)
	to_repair.organ_flags &= ~ORGAN_EMP
	ADD_TRAIT(to_repair, TRAIT_ORGAN_OPERATED_ON, TRAIT_GENERIC)

/datum/surgery_operation/organ_repair/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args, total_penalty_modifier)
	var/obj/item/organ/to_repair = locate(target_type) in limb
	to_repair.apply_organ_damage(to_repair.maxHealth * failure_damage_percent)

/datum/surgery_operation/organ_repair/lobectomy
	name = "excise damaged lung node"
	desc = "Perform repairs to a patient's damaged lung by excising the most damaged lobe."
	implements = list(
		TOOL_SCALPEL = 0.95,
		/obj/item/melee/energy/sword = 0.65,
		/obj/item/knife = 0.45,
		/obj/item/shard = 0.35,
	)
	time = 4.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	required_bodytype = BODYTYPE_ORGANIC
	target_type = /obj/item/organ/lungs
	failure_damage_percent = 0.1

/datum/surgery_operation/organ_repair/lobectomy/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to make an incision in [limb.owner]'s lungs..."),
		span_notice("[surgeon] begins to make an incision in [limb.owner]."),
		span_notice("[surgeon] begins to make an incision in [limb.owner]."),
	)
	display_pain(limb.owner, "You feel a stabbing pain in your chest!")

/datum/surgery_operation/organ_repair/lobectomy/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully excise [limb.owner]'s most damaged lobe."),
		span_notice("[surgeon] successfully excises [limb.owner]'s most damaged lobe."),
		span_notice("[surgeon] successfully excises [limb.owner]'s most damaged lobe."),
	)

/datum/surgery_operation/organ_repair/lobectomy/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args, total_penalty_modifier)
	. = ..()
	limb.owner.losebreath += 4
	display_results(
		surgeon,
		limb.owner,
		span_warning("You screw up, failing to excise [limb.owner]'s damaged lobe!"),
		span_warning("[surgeon] screws up!"),
		span_warning("[surgeon] screws up!"),
	)
	display_pain(limb.owner, "You feel a sharp stab in your chest; the wind is knocked out of you and it hurts to catch your breath!")

/datum/surgery_operation/organ_repair/lobectomy/mechanic
	name = "perform maintenance"
	implements = list(
		TOOL_SCALPEL = 0.95,
		TOOL_WRENCH = 0.95,
		/obj/item/melee/energy/sword = 0.65,
		/obj/item/knife = 0.45,
		/obj/item/shard = 0.35,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	required_bodytype = BODYTYPE_ROBOTIC

/datum/surgery_operation/organ_repair/hepatectomy
	name = "remove damaged liver section"
	desc = "Perform repairs to a patient's damaged liver by removing the most damaged section."
	implements = list(
		TOOL_SCALPEL = 0.95,
		/obj/item/melee/energy/sword = 0.65,
		/obj/item/knife = 0.45,
		/obj/item/shard = 0.35,
	)
	time = 5.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	required_bodytype = BODYTYPE_ORGANIC
	target_type = /obj/item/organ/liver
	heal_to_percent = 0.1
	failure_damage_percent = 0.15

/datum/surgery_operation/organ_repair/hepatectomy/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to cut out a damaged piece of [limb.owner]'s liver..."),
		span_notice("[surgeon] begins to make an incision in [limb.owner]."),
		span_notice("[surgeon] begins to make an incision in [limb.owner]."),
	)
	display_pain(limb.owner, "Your abdomen burns in horrific stabbing pain!")

/datum/surgery_operation/organ_repair/hepatectomy/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully remove the damaged part of [limb.owner]'s liver."),
		span_notice("[surgeon] successfully removes the damaged part of [limb.owner]'s liver."),
		span_notice("[surgeon] successfully removes the damaged part of [limb.owner]'s liver."),
	)
	display_pain(limb.owner, "The pain receeds slightly!")

/datum/surgery_operation/organ_repair/hepatectomy/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args, total_penalty_modifier)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_warning("You cut the wrong part of [limb.owner]'s liver!"),
		span_warning("[surgeon] cuts the wrong part of [limb.owner]'s liver!"),
		span_warning("[surgeon] cuts the wrong part of [limb.owner]'s liver!"),
	)
	display_pain(limb.owner, "The pain in your abdomen intensifies!")

/datum/surgery_operation/organ_repair/hepatectomy/mechanic
	name = "perform maintenance"
	implements = list(
		TOOL_SCALPEL = 0.95,
		TOOL_WRENCH = 0.95,
		/obj/item/melee/energy/sword = 0.65,
		/obj/item/knife = 0.45,
		/obj/item/shard = 0.35,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	required_bodytype = BODYTYPE_ROBOTIC

/datum/surgery_operation/organ_repair/coronary_bypass
	name = "graft coronary bypass"
	desc = "Graft a bypass onto a a patient's damaged heart to restore proper blood flow."
	implements = list(
		TOOL_HEMOSTAT = 0.95,
		TOOL_WIRECUTTER = 0.35,
		/obj/item/stack/package_wrap = 0.15,
		/obj/item/stack/cable_coil = 0.5,
	)
	time = 9 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	required_bodytype = BODYTYPE_ORGANIC
	target_type = /obj/item/organ/heart

/datum/surgery_operation/organ_repair/coronary_bypass/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to graft a bypass onto [limb.owner]'s heart..."),
		span_notice("[surgeon] begins to graft a bypass onto [limb.owner]'s heart."),
		span_notice("[surgeon] begins to graft a bypass onto [limb.owner]'s heart."),
	)
	display_pain(limb.owner, "The pain in your chest is unbearable! You can barely take it anymore!")

/datum/surgery_operation/organ_repair/coronary_bypass/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully graft a bypass onto [limb.owner]'s heart."),
		span_notice("[surgeon] successfully grafts a bypass onto [limb.owner]'s heart."),
		span_notice("[surgeon] successfully grafts a bypass onto [limb.owner]'s heart."),
	)
	display_pain(limb.owner, "The pain in your chest throbs, but your heart feels better than ever!")

/datum/surgery_operation/organ_repair/coronary_bypass/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args, total_penalty_modifier)
	. = ..()
	limb.adjustBleedStacks(30)
	var/blood_name = LOWER_TEXT(limb.owner.get_bloodtype()?.get_blood_name()) || "blood"
	display_results(
		surgeon,
		limb.owner,
		span_warning("You screw up in attaching the graft, and it tears off, tearing part of the heart!"),
		span_warning("[surgeon] screws up, causing [blood_name] to spurt out of [limb.owner]'s chest profusely!"),
		span_warning("[surgeon] screws up, causing [blood_name] to spurt out of [limb.owner]'s chest profusely!"),
	)
	display_pain(limb.owner, "Your chest burns; you feel like you're going insane!")

/datum/surgery_operation/organ_repair/coronary_bypass/mechanic
	name = "access engine internals"
	implements = list(
		TOOL_SCALPEL = 0.95,
		TOOL_CROWBAR = 0.95,
		/obj/item/melee/energy/sword = 0.65,
		/obj/item/knife = 0.45,
		/obj/item/shard = 0.35,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	required_bodytype = BODYTYPE_ROBOTIC

/datum/surgery_operation/organ_repair/gastrectomy
	name = "remove lower duodenum"
	desc = "Perform a patient's repairs to a damaged stomach by removing the lower duodenum."
	implements = list(
		TOOL_SCALPEL = 0.95,
		/obj/item/melee/energy/sword = 0.65,
		/obj/item/knife = 0.45,
		/obj/item/shard = 0.35,
		/obj/item = 0.25,
	)
	time = 5.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	required_bodytype = BODYTYPE_ORGANIC
	target_type = /obj/item/organ/stomach
	heal_to_percent = 0.2
	failure_damage_percent = 0.15

/datum/surgery_operation/organ_repair/gastrectomy/tool_check(obj/item/tool)
	// Require sharpness OR a tool behavior match
	return (tool.get_sharpness() || implements[tool.tool_behaviour])

/datum/surgery_operation/organ_repair/gastrectomy/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to cut out a damaged piece of [limb.owner]'s stomach..."),
		span_notice("[surgeon] begins to make an incision in [limb.owner]."),
		span_notice("[surgeon] begins to make an incision in [limb.owner]."),
	)
	display_pain(limb.owner, "You feel a horrible stab in your gut!")

/datum/surgery_operation/organ_repair/gastrectomy/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully remove the damaged part of [limb.owner]'s stomach."),
		span_notice("[surgeon] successfully removes the damaged part of [limb.owner]'s stomach."),
		span_notice("[surgeon] successfully removes the damaged part of [limb.owner]'s stomach."),
	)
	display_pain(limb.owner, "The pain in your gut receeds slightly!")

/datum/surgery_operation/organ_repair/gastrectomy/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args, total_penalty_modifier)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_warning("You cut the wrong part of [limb.owner]'s stomach!"),
		span_warning("[surgeon] cuts the wrong part of [limb.owner]'s stomach!"),
		span_warning("[surgeon] cuts the wrong part of [limb.owner]'s stomach!"),
	)
	display_pain(limb.owner, "The pain in your gut intensifies!")

/datum/surgery_operation/organ_repair/gastrectomy/mechanic
	name = "perform maintenance"
	implements = list(
		TOOL_SCALPEL = 0.95,
		TOOL_WRENCH = 0.95,
		/obj/item/melee/energy/sword = 0.65,
		/obj/item/knife = 0.45,
		/obj/item/shard = 0.35,
		/obj/item = 0.25,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	required_bodytype = BODYTYPE_ROBOTIC

/datum/surgery_operation/organ_repair/ears
	name = "ear surgery"
	desc = "Repair a patient's damaged ears to restore hearing."
	implements = list(
		TOOL_HEMOSTAT = 0.95,
		TOOL_SCREWDRIVER = 0.45,
		/obj/item/pen = 0.25,
	)
	target_type = /obj/item/organ/ears
	time = 6.4 SECONDS
	heal_to_percent = 0
	repeatable = TRUE

/datum/surgery_operation/organ_repair/ears/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(limb.surgery_vessel_state < SURGERY_VESSELS_CLAMPED)
		return FALSE
	if(limb.surgery_bone_state > SURGERY_BONE_DRILLED)
		return FALSE
	return TRUE

/datum/surgery_operation/organ_repair/ears/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to fix [limb.owner]'s ears..."),
		span_notice("[surgeon] begins to fix [limb.owner]'s ears."),
		span_notice("[surgeon] begins to perform surgery on [limb.owner]'s ears."),
	)
	display_pain(limb.owner, "You feel a dizzying pain in your head!")

/datum/surgery_operation/organ_repair/ears/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	var/obj/item/organ/ears/ears = locate() in limb
	ears.deaf = 20
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully fix [limb.owner]'s ears."),
		span_notice("[surgeon] successfully fixes [limb.owner]'s ears."),
		span_notice("[surgeon] successfully fixes [limb.owner]'s ears."),
	)
	display_pain(limb.owner, "Your head swims, but it seems like you can feel your hearing coming back!")

/datum/surgery_operation/organ_repair/ears/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args, total_penalty_modifier)
	var/obj/item/organ/brain/brain = locate() in limb
	if(brain)
		display_results(
			surgeon,
			limb.owner,
			span_warning("You accidentally stab [limb.owner] right in the brain!"),
			span_warning("[surgeon] accidentally stabs [limb.owner] right in the brain!"),
			span_warning("[surgeon] accidentally stabs [limb.owner] right in the brain!"),
		)
		display_pain(limb.owner, "You feel a visceral stabbing pain right through your head, into your brain!")
		limb.owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 70)
	else
		display_results(
			surgeon,
			limb.owner,
			span_warning("You accidentally stab [limb.owner] right in the brain! Or would have, if [limb.owner] had a brain."),
			span_warning("[surgeon] accidentally stabs [limb.owner] right in the brain! Or would have, if [limb.owner] had a brain."),
			span_warning("[surgeon] accidentally stabs [limb.owner] right in the brain!"),
		)

/datum/surgery_operation/organ_repair/eyes
	name = "eye surgery"
	desc = "Repair a patient's damaged eyes to restore vision."
	implements = list(
		TOOL_HEMOSTAT = 0.95,
		TOOL_SCREWDRIVER = 0.45,
		/obj/item/pen = 0.25,
	)
	time = 6.4 SECONDS
	target_type = /obj/item/organ/eyes
	heal_to_percent = 0
	repeatable = TRUE

/datum/surgery_operation/organ_repair/eyes/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(limb.surgery_vessel_state < SURGERY_VESSELS_CLAMPED)
		return FALSE
	if(limb.surgery_bone_state > SURGERY_BONE_DRILLED)
		return FALSE
	return TRUE

/datum/surgery_operation/organ_repair/eyes/get_default_radial_image(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool)
	return image(icon = 'icons/obj/medical/surgery_ui.dmi', icon_state = "surgery_eyes")

/datum/surgery_operation/organ_repair/eyes/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to fix [limb.owner]'s eyes..."),
		span_notice("[surgeon] begins to fix [limb.owner]'s eyes."),
		span_notice("[surgeon] begins to perform surgery on [limb.owner]'s eyes."),
	)
	display_pain(limb.owner, "You feel a stabbing pain in your eyes!")

/datum/surgery_operation/organ_repair/eyes/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.owner.remove_status_effect(/datum/status_effect/temporary_blindness)
	limb.owner.set_eye_blur_if_lower(70 SECONDS) //this will fix itself slowly.
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully fix [limb.owner]'s eyes."),
		span_notice("[surgeon] successfully fixes [limb.owner]'s eyes."),
		span_notice("[surgeon] successfully fixes [limb.owner]'s eyes."),
	)
	display_pain(limb.owner, "Your vision blurs, but it seems like you can see a little better now!")

/datum/surgery_operation/organ_repair/eyes/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args, total_penalty_modifier)
	var/obj/item/organ/brain/brain = locate() in limb
	if(brain)
		display_results(
			surgeon,
			limb.owner,
			span_warning("You accidentally stab [limb.owner] right in the brain!"),
			span_warning("[surgeon] accidentally stabs [limb.owner] right in the brain!"),
			span_warning("[surgeon] accidentally stabs [limb.owner] right in the brain!"),
		)
		display_pain(limb.owner, "You feel a visceral stabbing pain right through your head, into your brain!")
		limb.owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 70)

	else
		display_results(
			surgeon,
			limb.owner,
			span_warning("You accidentally stab [limb.owner] right in the brain! Or would have, if [limb.owner] had a brain."),
			span_warning("[surgeon] accidentally stabs [limb.owner] right in the brain! Or would have, if [limb.owner] had a brain."),
			span_warning("[surgeon] accidentally stabs [limb.owner] right in the brain!"),
		)

/datum/surgery_operation/organ_repair/brain
	name = "brain surgery"
	desc = "Repair a patient's damaged brain tissue to restore cognitive function."
	implements = list(
		TOOL_HEMOSTAT = 0.95,
		TOOL_SCREWDRIVER = 0.35,
		/obj/item/pen = 0.15,
	)
	time = 10 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_LOOPING
	required_bodytype = BODYTYPE_ORGANIC
	target_type = /obj/item/organ/brain
	heal_to_percent = 0.25
	failure_damage_percent = 0.3
	repeatable = TRUE

/datum/surgery_operation/organ_repair/brain/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(limb.surgery_vessel_state < SURGERY_VESSELS_CLAMPED)
		return FALSE
	if(limb.surgery_bone_state != SURGERY_BONE_SAWED)
		return FALSE
	return TRUE

/datum/surgery_operation/organ_repair/brain/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to fix [limb.owner]'s brain..."),
		span_notice("[surgeon] begins to fix [limb.owner]'s brain."),
		span_notice("[surgeon] begins to perform surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your head pounds with unimaginable pain!")

/datum/surgery_operation/organ_repair/brain/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/organ/to_repair = locate(target_type) in limb
	to_repair.apply_organ_damage(-to_repair.maxHealth * heal_to_percent) // no parent call, special healing for this one
	display_results(
		surgeon,
		limb.owner,
		span_notice("You succeed in fixing [limb.owner]'s brain."),
		span_notice("[surgeon] successfully fixes [limb.owner]'s brain!"),
		span_notice("[surgeon] completes the surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "The pain in your head receeds, thinking becomes a bit easier!")
	limb.owner.mind?.remove_antag_datum(/datum/antagonist/brainwashed)
	limb.owner.cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
	if(to_repair.damage > to_repair.maxHealth * 0.1)
		to_chat(surgeon, "[limb.owner]'s brain looks like it could be fixed further.")

/datum/surgery_operation/organ_repair/brain/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args, total_penalty_modifier)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_warning("You screw up, causing more damage!"),
		span_warning("[surgeon] screws up, causing brain damage!"),
		span_notice("[surgeon] completes the surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your head throbs with horrible pain; thinking hurts!")
	limb.owner.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/organ_repair/brain/mechanic
	name = "perform neural debugging"
	implements = list(
		TOOL_HEMOSTAT = 0.95,
		TOOL_MULTITOOL = 0.85,
		TOOL_SCREWDRIVER = 0.35,
		/obj/item/pen = 0.15,
	)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	required_bodytype = BODYTYPE_ROBOTIC
