/datum/surgery_operation/limb/debride
	name = "debride infected flesh"
	rnd_name = "Debridement"
	desc = "Remove infected or necrotic flesh from a patient's wound to promote healing."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_SCALPEL = 1.25,
		TOOL_SAW = 1.66,
		TOOL_WIRECUTTER = 2.5,
	)
	time = 3 SECONDS
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_LOOPING | OPERATION_PRIORITY_NEXT_STEP
	preop_sound = list(
		TOOL_SCALPEL = 'sound/items/handling/surgery/scalpel1.ogg',
		TOOL_HEMOSTAT = 'sound/items/handling/surgery/hemostat1.ogg',
	)
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'
	failure_sound = 'sound/items/handling/surgery/organ1.ogg'

	/// How much infestation is removed per step (positive number)
	var/infestation_removed = 4
	/// How much sanitization is added per step
	var/sanitization_added = 0.5 // just enough to stop infestation from worsening

/datum/surgery_operation/limb/debride/get_default_radial_image()
	return image(/obj/item/reagent_containers/applicator/patch/aiuri)

/datum/surgery_operation/limb/debride/all_required_strings()
	return list("the limb must have a second degree or worse burn") + ..()

/datum/surgery_operation/limb/debride/state_check(obj/item/bodypart/limb)
	var/datum/wound/burn/flesh/wound = locate() in limb.wounds
	return wound?.infection > 0

/// To give the surgeon a heads up how much work they have ahead of them
/datum/surgery_operation/limb/debride/proc/get_progress(datum/wound/burn/flesh/wound)
	if(wound?.infection <= 0)
		return null

	var/estimated_remaining_steps = wound.infection / infestation_removed
	var/progress_text

	switch(estimated_remaining_steps)
		if(-INFINITY to 1)
			return null
		if(1 to 2)
			progress_text = ", preparing to remove the last remaining bits of infection"
		if(2 to 4)
			progress_text = ", steadily narrowing the remaining bits of infection"
		if(5 to INFINITY)
			progress_text = ", though there's still quite a lot to excise"

	return progress_text

/datum/surgery_operation/limb/debride/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to excise infected flesh from [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to excise infected flesh from [limb.owner]'s [limb.plaintext_zone] with [tool]."),
		span_notice("[surgeon] begins to excise infected flesh from [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "The infection in your [limb.plaintext_zone] stings like hell! It feels like you're being stabbed!")

/datum/surgery_operation/limb/debride/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args, default_display_results = FALSE)
	limb.receive_damage(3, wound_bonus = CANT_WOUND, sharpness = tool.get_sharpness(), damage_source = tool)
	var/datum/wound/burn/flesh/wound = locate() in limb.wounds
	wound?.infection -= infestation_removed
	wound?.sanitization += sanitization_added
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully excise some of the infected flesh from [limb.owner]'s [limb.plaintext_zone][get_progress(wound)]."),
		span_notice("[surgeon] successfully excises some of the infected flesh from [limb.owner]'s [limb.plaintext_zone] with [tool]!"),
		span_notice("[surgeon] successfully excises some of the infected flesh from  [limb.owner]'s [limb.plaintext_zone]!"),
	)

/datum/surgery_operation/limb/debride/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You carve away some of the healthy flesh from [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] carves away some of the healthy flesh from [limb.owner]'s [limb.plaintext_zone] with [tool]!"),
		span_notice("[surgeon] carves away some of the healthy flesh from  [limb.owner]'s [limb.plaintext_zone]!"),
	)
	limb.receive_damage(rand(4, 8), wound_bonus = CANT_WOUND, sharpness = tool.get_sharpness(), damage_source = tool)
