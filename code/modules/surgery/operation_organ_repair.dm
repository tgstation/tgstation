/// Repairing specific organs
/datum/surgery_operation/organ/repair
	name = "repair organ"
	desc = "Repair a patient's damaged organ."
	required_biotype = ORGAN_ORGANIC
	/// What % damage do we heal the organ to on success
	/// Note that 0% damage = 100% health
	var/heal_to_percent = 0.6
	/// What % damage do we apply to the organ on failure
	var/failure_damage_percent = 0.2
	/// If TRUE, an organ can be repaired multiple times
	var/repeatable = FALSE

/datum/surgery_operation/organ/repair/New()
	. = ..()
	if(operation_flags & OPERATION_LOOPING)
		repeatable = TRUE // if it's looping it would necessitate being repeatable

/datum/surgery_operation/organ/repair/organ_check(obj/item/organ/organ)
	return HAS_SURGERY_STATE(organ.bodypart_owner, SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_BONE_SAWED)

/datum/surgery_operation/organ/repair/is_available(obj/item/organ/organ, mob/living/surgeon, obj/item/tool)
	if(organ.damage < (organ.maxHealth * heal_to_percent) || (!repeatable && HAS_TRAIT(organ, TRAIT_ORGAN_OPERATED_ON)))
		return FALSE
	return TRUE

/datum/surgery_operation/organ/repair/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	organ.set_organ_damage(organ.maxHealth * heal_to_percent)
	organ.organ_flags &= ~ORGAN_EMP
	ADD_TRAIT(organ, TRAIT_ORGAN_OPERATED_ON, TRAIT_GENERIC)

/datum/surgery_operation/organ/repair/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	organ.apply_organ_damage(organ.maxHealth * failure_damage_percent)

/datum/surgery_operation/organ/repair/lobectomy
	name = "excise damaged lung node"
	desc = "Perform repairs to a patient's damaged lung by excising the most damaged lobe."
	implements = list(
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/energy/sword = 1.5,
		/obj/item/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	time = 4.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	target_type = /obj/item/organ/lungs
	failure_damage_percent = 0.1

/datum/surgery_operation/organ/repair/lobectomy/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You begin to make an incision in [organ.owner]'s lungs..."),
		span_notice("[surgeon] begins to make an incision in [organ.owner]."),
		span_notice("[surgeon] begins to make an incision in [organ.owner]."),
	)
	display_pain(organ.owner, "You feel a stabbing pain in your chest!")

/datum/surgery_operation/organ/repair/lobectomy/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_notice("You successfully excise [organ.owner]'s most damaged lobe."),
		span_notice("[surgeon] successfully excises [organ.owner]'s most damaged lobe."),
		span_notice("[surgeon] successfully excises [organ.owner]'s most damaged lobe."),
	)

/datum/surgery_operation/organ/repair/lobectomy/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	organ.owner.losebreath += 4
	display_results(
		surgeon,
		organ.owner,
		span_warning("You screw up, failing to excise [organ.owner]'s damaged lobe!"),
		span_warning("[surgeon] screws up!"),
		span_warning("[surgeon] screws up!"),
	)
	display_pain(organ.owner, "You feel a sharp stab in your chest; the wind is knocked out of you and it hurts to catch your breath!")

/datum/surgery_operation/organ/repair/lobectomy/mechanic
	name = "perform maintenance"
	implements = list(
		TOOL_SCALPEL = 1.05,
		TOOL_WRENCH = 1.05,
		/obj/item/melee/energy/sword = 1.5,
		/obj/item/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	required_biotype = ORGAN_ROBOTIC

/datum/surgery_operation/organ/repair/hepatectomy
	name = "remove damaged liver section"
	desc = "Perform repairs to a patient's damaged liver by removing the most damaged section."
	implements = list(
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/energy/sword = 1.5,
		/obj/item/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	time = 5.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	target_type = /obj/item/organ/liver
	heal_to_percent = 0.1
	failure_damage_percent = 0.15

/datum/surgery_operation/organ/repair/hepatectomy/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You begin to cut out a damaged piece of [organ.owner]'s liver..."),
		span_notice("[surgeon] begins to make an incision in [organ.owner]."),
		span_notice("[surgeon] begins to make an incision in [organ.owner]."),
	)
	display_pain(organ.owner, "Your abdomen burns in horrific stabbing pain!")

/datum/surgery_operation/organ/repair/hepatectomy/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_notice("You successfully remove the damaged part of [organ.owner]'s liver."),
		span_notice("[surgeon] successfully removes the damaged part of [organ.owner]'s liver."),
		span_notice("[surgeon] successfully removes the damaged part of [organ.owner]'s liver."),
	)
	display_pain(organ.owner, "The pain receeds slightly!")

/datum/surgery_operation/organ/repair/hepatectomy/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_warning("You cut the wrong part of [organ.owner]'s liver!"),
		span_warning("[surgeon] cuts the wrong part of [organ.owner]'s liver!"),
		span_warning("[surgeon] cuts the wrong part of [organ.owner]'s liver!"),
	)
	display_pain(organ.owner, "The pain in your abdomen intensifies!")

/datum/surgery_operation/organ/repair/hepatectomy/mechanic
	name = "perform maintenance"
	implements = list(
		TOOL_SCALPEL = 1.05,
		TOOL_WRENCH = 1.05,
		/obj/item/melee/energy/sword = 1.5,
		/obj/item/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	required_biotype = ORGAN_ROBOTIC

/datum/surgery_operation/organ/repair/coronary_bypass
	name = "graft coronary bypass"
	desc = "Graft a bypass onto a a patient's damaged heart to restore proper blood flow."
	implements = list(
		TOOL_HEMOSTAT = 1.05,
		TOOL_WIRECUTTER = 2.85,
		/obj/item/stack/package_wrap = 6.67,
		/obj/item/stack/cable_coil = 2,
	)
	time = 9 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	target_type = /obj/item/organ/heart

/datum/surgery_operation/organ/repair/coronary_bypass/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You begin to graft a bypass onto [organ.owner]'s heart..."),
		span_notice("[surgeon] begins to graft a bypass onto [organ.owner]'s heart."),
		span_notice("[surgeon] begins to graft a bypass onto [organ.owner]'s heart."),
	)
	display_pain(organ.owner, "The pain in your chest is unbearable! You can barely take it anymore!")

/datum/surgery_operation/organ/repair/coronary_bypass/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_notice("You successfully graft a bypass onto [organ.owner]'s heart."),
		span_notice("[surgeon] successfully grafts a bypass onto [organ.owner]'s heart."),
		span_notice("[surgeon] successfully grafts a bypass onto [organ.owner]'s heart."),
	)
	display_pain(organ.owner, "The pain in your chest throbs, but your heart feels better than ever!")

/datum/surgery_operation/organ/repair/coronary_bypass/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	organ.bodypart_owner.adjustBleedStacks(30)
	var/blood_name = LOWER_TEXT(organ.owner.get_bloodtype()?.get_blood_name()) || "blood"
	display_results(
		surgeon,
		organ.owner,
		span_warning("You screw up in attaching the graft, and it tears off, tearing part of the heart!"),
		span_warning("[surgeon] screws up, causing [blood_name] to spurt out of [organ.owner]'s chest profusely!"),
		span_warning("[surgeon] screws up, causing [blood_name] to spurt out of [organ.owner]'s chest profusely!"),
	)
	display_pain(organ.owner, "Your chest burns; you feel like you're going insane!")

/datum/surgery_operation/organ/repair/coronary_bypass/mechanic
	name = "access engine internals"
	implements = list(
		TOOL_SCALPEL = 1.05,
		TOOL_CROWBAR = 1.05,
		/obj/item/melee/energy/sword = 1.5,
		/obj/item/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	required_biotype = ORGAN_ROBOTIC

/datum/surgery_operation/organ/repair/gastrectomy
	name = "remove lower duodenum"
	desc = "Perform a patient's repairs to a damaged stomach by removing the lower duodenum."
	implements = list(
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/energy/sword = 1.5,
		/obj/item/knife = 2.25,
		/obj/item/shard = 2.85,
		/obj/item = 4,
	)
	time = 5.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	target_type = /obj/item/organ/stomach
	heal_to_percent = 0.2
	failure_damage_percent = 0.15

/datum/surgery_operation/organ/repair/gastrectomy/tool_check(obj/item/tool)
	// Require sharpness OR a tool behavior match
	return (tool.get_sharpness() || implements[tool.tool_behaviour])

/datum/surgery_operation/organ/repair/gastrectomy/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You begin to cut out a damaged piece of [organ.owner]'s stomach..."),
		span_notice("[surgeon] begins to make an incision in [organ.owner]."),
		span_notice("[surgeon] begins to make an incision in [organ.owner]."),
	)
	display_pain(organ.owner, "You feel a horrible stab in your gut!")

/datum/surgery_operation/organ/repair/gastrectomy/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_notice("You successfully remove the damaged part of [organ.owner]'s stomach."),
		span_notice("[surgeon] successfully removes the damaged part of [organ.owner]'s stomach."),
		span_notice("[surgeon] successfully removes the damaged part of [organ.owner]'s stomach."),
	)
	display_pain(organ.owner, "The pain in your gut receeds slightly!")

/datum/surgery_operation/organ/repair/gastrectomy/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_warning("You cut the wrong part of [organ.owner]'s stomach!"),
		span_warning("[surgeon] cuts the wrong part of [organ.owner]'s stomach!"),
		span_warning("[surgeon] cuts the wrong part of [organ.owner]'s stomach!"),
	)
	display_pain(organ.owner, "The pain in your gut intensifies!")

/datum/surgery_operation/organ/repair/gastrectomy/mechanic
	name = "perform maintenance"
	implements = list(
		TOOL_SCALPEL = 1.05,
		TOOL_WRENCH = 1.05,
		/obj/item/melee/energy/sword = 1.5,
		/obj/item/knife = 2.25,
		/obj/item/shard = 2.85,
		/obj/item = 4,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	required_biotype = ORGAN_ROBOTIC

/datum/surgery_operation/organ/repair/ears
	name = "ear surgery"
	desc = "Repair a patient's damaged ears to restore hearing."
	implements = list(
		TOOL_HEMOSTAT = 1.05,
		TOOL_SCREWDRIVER = 2.25,
		/obj/item/pen = 4,
	)
	target_type = /obj/item/organ/ears
	time = 6.4 SECONDS
	heal_to_percent = 0
	repeatable = TRUE

/datum/surgery_operation/organ/repair/ears/state_check(obj/item/organ/ears/organ)
	if(!HAS_SURGERY_STATE(organ.bodypart_owner, SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED))
		return FALSE
	if(HAS_ANY_SURGERY_STATE(organ.bodypart_owner, SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED) && !INNATELY_LACKING_BONES(organ.bodypart_owner))
		return FALSE
	return TRUE

/datum/surgery_operation/organ/repair/ears/on_preop(obj/item/organ/ears/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You begin to fix [organ.owner]'s ears..."),
		span_notice("[surgeon] begins to fix [organ.owner]'s ears."),
		span_notice("[surgeon] begins to perform surgery on [organ.owner]'s ears."),
	)
	display_pain(organ.owner, "You feel a dizzying pain in your head!")

/datum/surgery_operation/organ/repair/ears/on_success(obj/item/organ/ears/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	organ.deaf = 20
	display_results(
		surgeon,
		organ.owner,
		span_notice("You successfully fix [organ.owner]'s ears."),
		span_notice("[surgeon] successfully fixes [organ.owner]'s ears."),
		span_notice("[surgeon] successfully fixes [organ.owner]'s ears."),
	)
	display_pain(organ.owner, "Your head swims, but it seems like you can feel your hearing coming back!")

/datum/surgery_operation/organ/repair/ears/on_failure(obj/item/organ/ears/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/organ/brain/brain = locate() in organ.bodypart_owner
	if(brain)
		display_results(
			surgeon,
			organ.owner,
			span_warning("You accidentally stab [organ.owner] right in the brain!"),
			span_warning("[surgeon] accidentally stabs [organ.owner] right in the brain!"),
			span_warning("[surgeon] accidentally stabs [organ.owner] right in the brain!"),
		)
		display_pain(organ.owner, "You feel a visceral stabbing pain right through your head, into your brain!")
		organ.owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 70)
	else
		display_results(
			surgeon,
			organ.owner,
			span_warning("You accidentally stab [organ.owner] right in the brain! Or would have, if [organ.owner] had a brain."),
			span_warning("[surgeon] accidentally stabs [organ.owner] right in the brain! Or would have, if [organ.owner] had a brain."),
			span_warning("[surgeon] accidentally stabs [organ.owner] right in the brain!"),
		)

/datum/surgery_operation/organ/repair/eyes
	name = "eye surgery"
	desc = "Repair a patient's damaged eyes to restore vision."
	implements = list(
		TOOL_HEMOSTAT = 1.05,
		TOOL_SCREWDRIVER = 2.25,
		/obj/item/pen = 4,
	)
	time = 6.4 SECONDS
	target_type = /obj/item/organ/eyes
	heal_to_percent = 0
	repeatable = TRUE

/datum/surgery_operation/organ/repair/eyes/organ_check(obj/item/organ/organ)
	if(!HAS_SURGERY_STATE(organ.bodypart_owner, SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED))
		return FALSE
	if(HAS_ANY_SURGERY_STATE(organ.bodypart_owner, SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED) && !INNATELY_LACKING_BONES(organ.bodypart_owner))
		return FALSE
	return TRUE

/datum/surgery_operation/organ/repair/eyes/get_default_radial_image(obj/item/organ/organ, mob/living/surgeon, obj/item/tool)
	return image(icon = 'icons/obj/medical/surgery_ui.dmi', icon_state = "surgery_eyes")

/datum/surgery_operation/organ/repair/eyes/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You begin to fix [organ.owner]'s eyes..."),
		span_notice("[surgeon] begins to fix [organ.owner]'s eyes."),
		span_notice("[surgeon] begins to perform surgery on [organ.owner]'s eyes."),
	)
	display_pain(organ.owner, "You feel a stabbing pain in your eyes!")

/datum/surgery_operation/organ/repair/eyes/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	organ.owner.remove_status_effect(/datum/status_effect/temporary_blindness)
	organ.owner.set_eye_blur_if_lower(70 SECONDS) //this will fix itself slowly.
	display_results(
		surgeon,
		organ.owner,
		span_notice("You successfully fix [organ.owner]'s eyes."),
		span_notice("[surgeon] successfully fixes [organ.owner]'s eyes."),
		span_notice("[surgeon] successfully fixes [organ.owner]'s eyes."),
	)
	display_pain(organ.owner, "Your vision blurs, but it seems like you can see a little better now!")

/datum/surgery_operation/organ/repair/eyes/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/organ/brain/brain = locate() in organ.bodypart_owner
	if(brain)
		display_results(
			surgeon,
			organ.owner,
			span_warning("You accidentally stab [organ.owner] right in the brain!"),
			span_warning("[surgeon] accidentally stabs [organ.owner] right in the brain!"),
			span_warning("[surgeon] accidentally stabs [organ.owner] right in the brain!"),
		)
		display_pain(organ.owner, "You feel a visceral stabbing pain right through your head, into your brain!")
		organ.owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 70)

	else
		display_results(
			surgeon,
			organ.owner,
			span_warning("You accidentally stab [organ.owner] right in the brain! Or would have, if [organ.owner] had a brain."),
			span_warning("[surgeon] accidentally stabs [organ.owner] right in the brain! Or would have, if [organ.owner] had a brain."),
			span_warning("[surgeon] accidentally stabs [organ.owner] right in the brain!"),
		)

/datum/surgery_operation/organ/repair/brain
	name = "brain surgery"
	desc = "Repair a patient's damaged brain tissue to restore cognitive function."
	implements = list(
		TOOL_HEMOSTAT = 1.05,
		TOOL_SCREWDRIVER = 2.85,
		/obj/item/pen = 6.67,
	)
	time = 10 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_LOOPING
	target_type = /obj/item/organ/brain
	heal_to_percent = 0.25
	failure_damage_percent = 0.3
	repeatable = TRUE

/datum/surgery_operation/organ/repair/brain/organ_check(obj/item/organ/brain/organ)
	return HAS_SURGERY_STATE(organ.bodypart_owner, SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED|SURGERY_VESSELS_CLAMPED)

/datum/surgery_operation/organ/repair/brain/on_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You begin to fix [organ.owner]'s brain..."),
		span_notice("[surgeon] begins to fix [organ.owner]'s brain."),
		span_notice("[surgeon] begins to perform surgery on [organ.owner]'s brain."),
	)
	display_pain(organ.owner, "Your head pounds with unimaginable pain!")

/datum/surgery_operation/organ/repair/brain/on_success(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	organ.apply_organ_damage(-organ.maxHealth * heal_to_percent) // no parent call, special healing for this one
	display_results(
		surgeon,
		organ.owner,
		span_notice("You succeed in fixing [organ.owner]'s brain."),
		span_notice("[surgeon] successfully fixes [organ.owner]'s brain!"),
		span_notice("[surgeon] completes the surgery on [organ.owner]'s brain."),
	)
	display_pain(organ.owner, "The pain in your head receeds, thinking becomes a bit easier!")
	organ.owner.mind?.remove_antag_datum(/datum/antagonist/brainwashed)
	organ.cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
	if(organ.damage > organ.maxHealth * 0.1)
		to_chat(surgeon, "[organ.owner]'s brain looks like it could be fixed further.")

/datum/surgery_operation/organ/repair/brain/on_failure(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_warning("You screw up, causing more damage!"),
		span_warning("[surgeon] screws up, causing brain damage!"),
		span_notice("[surgeon] completes the surgery on [organ.owner]'s brain."),
	)
	display_pain(organ.owner, "Your head throbs with horrible pain; thinking hurts!")
	organ.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/organ/repair/brain/mechanic
	name = "perform neural debugging"
	implements = list(
		TOOL_HEMOSTAT = 1.05,
		TOOL_MULTITOOL = 1.15,
		TOOL_SCREWDRIVER = 2.85,
		/obj/item/pen = 6.67,
	)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	required_biotype = ORGAN_ROBOTIC
