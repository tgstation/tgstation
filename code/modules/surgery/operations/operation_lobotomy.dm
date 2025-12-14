/datum/surgery_operation/organ/lobotomy
	name = "lobotomize"
	rnd_name = "Lobotomy (Lobotomy)"
	desc = "Repair most of a patient's brain traumas, with the risk of causing new permanent traumas."
	rnd_desc = "An invasive surgical procedure which guarantees removal of almost all brain traumas, but might cause another permanent trauma in return."
	operation_flags = OPERATION_MORBID | OPERATION_AFFECTS_MOOD | OPERATION_LOCKED | OPERATION_NOTABLE
	implements = list(
		TOOL_SCALPEL = 1.15,
		/obj/item/melee/energy/sword = 0.55,
		/obj/item/knife = 2.85,
		/obj/item/shard = 4,
		/obj/item = 5,
	)
	target_type = /obj/item/organ/brain
	required_organ_flag = ORGAN_TYPE_FLAGS & ~ORGAN_ROBOTIC
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	failure_sound = 'sound/items/handling/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED|SURGERY_BONE_SAWED

/datum/surgery_operation/organ/lobotomy/get_any_tool()
	return "Any sharp edged item"

/datum/surgery_operation/organ/lobotomy/tool_check(obj/item/tool)
	// Require edged sharpness OR a tool behavior match
	return ((tool.get_sharpness() & SHARP_EDGED) || implements[tool.tool_behaviour])

/datum/surgery_operation/organ/lobotomy/on_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You begin to perform a lobotomy on [organ.owner]'s brain..."),
		span_notice("[surgeon] begins to perform a lobotomy on [organ.owner]'s brain."),
		span_notice("[surgeon] begins to perform surgery on [organ.owner]'s brain."),
	)
	display_pain(organ.owner, "Your head pounds with unimaginable pain!")

/datum/surgery_operation/organ/lobotomy/on_success(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("You successfully perform a lobotomy on [organ.owner]!"),
		span_notice("[surgeon] successfully lobotomizes [organ.owner]!"),
		span_notice("[surgeon] finishes performing surgery on [organ.owner]'s brain."),
	)
	display_pain(organ.owner, "Your head goes totally numb for a moment, the pain is overwhelming!")

	organ.cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)
	organ.owner.mind?.remove_antag_datum(/datum/antagonist/brainwashed)
	if(!prob(75))
		return
	switch(rand(1, 3))//Now let's see what hopefully-not-important part of the brain we cut off
		if(1)
			organ.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_MAGIC)
		if(2)
			if(HAS_TRAIT(organ.owner, TRAIT_SPECIAL_TRAUMA_BOOST) && prob(50))
				organ.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)
			else
				organ.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_MAGIC)
		if(3)
			organ.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)

/datum/surgery_operation/organ/lobotomy/on_failure(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_warning("You remove the wrong part, causing more damage!"),
		span_notice("[surgeon] unsuccessfully attempts to lobotomize [organ.owner]!"),
		span_notice("[surgeon] completes the surgery on [organ.owner]'s brain."),
	)
	display_pain(organ.owner, "The pain in your head only seems to get worse!")
	organ.apply_organ_damage(80)
	switch(rand(1, 3))
		if(1)
			organ.owner.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_MAGIC)
		if(2)
			if(HAS_TRAIT(organ.owner, TRAIT_SPECIAL_TRAUMA_BOOST) && prob(50))
				organ.owner.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)
			else
				organ.owner.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_MAGIC)
		if(3)
			organ.owner.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)

/datum/surgery_operation/organ/lobotomy/mechanic
	name = "execute neural defragging"
	rnd_name = "Wetware OS Destructive Defragmentation (Lobotomy)"
	implements = list(
		TOOL_MULTITOOL = 1.15,
		/obj/item/melee/energy/sword = 1.85,
		/obj/item/knife = 2.85,
		/obj/item/shard = 4,
		/obj/item = 5,
	)
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC
