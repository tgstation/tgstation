
/////BURN FIXING SURGERIES//////

///// Debride burnt flesh
/datum/surgery/debride
	name = "Debride burnt flesh"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	targetable_wound = /datum/wound/burn/flesh
	possible_locs = list(
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_LEG,
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/debride,
		/datum/surgery_step/dress,
	)

/datum/surgery/debride/can_start(mob/living/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return .

	var/datum/wound/burn/flesh/burn_wound = target.get_bodypart(user.zone_selected).get_wound_type(targetable_wound)
	// Should be guaranteed to have the wound by this point
	ASSERT(burn_wound, "[type] on [target] has no burn wound when it should have been guaranteed to have one by can_start")
	return burn_wound.infestation > 0

//SURGERY STEPS

///// Debride
/datum/surgery_step/debride
	name = "excise infection (hemostat)"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_SCALPEL = 85,
		TOOL_SAW = 60,
		TOOL_WIRECUTTER = 40)
	time = 30
	repeatable = TRUE
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'
	failure_sound = 'sound/items/handling/surgery/organ1.ogg'
	surgery_effects_mood = TRUE
	/// How much sanitization is added per step
	var/sanitization_added = 0.5
	/// How much infestation is removed per step (positive number)
	var/infestation_removed = 4

/// To give the surgeon a heads up how much work they have ahead of them
/datum/surgery_step/debride/proc/get_progress(mob/user, mob/living/carbon/target, datum/wound/burn/flesh/burn_wound)
	if(!burn_wound?.infestation || !infestation_removed)
		return
	var/estimated_remaining_steps = burn_wound.infestation / infestation_removed
	var/progress_text

	switch(estimated_remaining_steps)
		if(-INFINITY to 1)
			return
		if(1 to 2)
			progress_text = ", preparing to remove the last remaining bits of infection"
		if(2 to 4)
			progress_text = ", steadily narrowing the remaining bits of infection"
		if(5 to INFINITY)
			progress_text = ", though there's still quite a lot to excise"

	return progress_text

/datum/surgery_step/debride/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		var/datum/wound/burn/flesh/burn_wound = surgery.operated_wound
		if(burn_wound.infestation <= 0)
			to_chat(user, span_notice("[target]'s [target.parse_zone_with_bodypart(user.zone_selected)] has no infected flesh to remove!"))
			surgery.status++
			repeatable = FALSE
			return
		display_results(
			user,
			target,
			span_notice("You begin to excise infected flesh from [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]..."),
			span_notice("[user] begins to excise infected flesh from [target]'s [target.parse_zone_with_bodypart(user.zone_selected)] with [tool]."),
			span_notice("[user] begins to excise infected flesh from [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]."),
		)
		display_pain(target, "The infection in your [target.parse_zone_with_bodypart(user.zone_selected)] stings like hell! It feels like you're being stabbed!")
	else
		user.visible_message(span_notice("[user] looks for [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]."), span_notice("You look for [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]..."))

/datum/surgery_step/debride/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/datum/wound/burn/flesh/burn_wound = surgery.operated_wound
	if(burn_wound)
		var/progress_text = get_progress(user, target, burn_wound)
		display_results(
			user,
			target,
			span_notice("You successfully excise some of the infected flesh from [target]'s [target.parse_zone_with_bodypart(target_zone)][progress_text]."),
			span_notice("[user] successfully excises some of the infected flesh from [target]'s [target.parse_zone_with_bodypart(target_zone)] with [tool]!"),
			span_notice("[user] successfully excises some of the infected flesh from  [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
		)
		log_combat(user, target, "excised infected flesh in", addition="COMBAT MODE: [uppertext(user.combat_mode)]")
		surgery.operated_bodypart.receive_damage(brute=3, wound_bonus=CANT_WOUND)
		burn_wound.infestation -= infestation_removed
		burn_wound.sanitization += sanitization_added
		if(burn_wound.infestation <= 0)
			repeatable = FALSE
	else
		to_chat(user, span_warning("[target] has no infected flesh there!"))
	return ..()

/datum/surgery_step/debride/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	..()
	display_results(
		user,
		target,
		span_notice("You carve away some of the healthy flesh from [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] carves away some of the healthy flesh from [target]'s [target.parse_zone_with_bodypart(target_zone)] with [tool]!"),
		span_notice("[user] carves away some of the healthy flesh from  [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
	)
	surgery.operated_bodypart.receive_damage(brute=rand(4,8), sharpness=TRUE)

/datum/surgery_step/debride/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	if(!..())
		return
	var/datum/wound/burn/flesh/burn_wound = surgery.operated_wound
	while(burn_wound && burn_wound.infestation > 0.25)
		if(!..())
			break

///// Dressing burns
/datum/surgery_step/dress
	name = "bandage burns (gauze/tape)"
	implements = list(
		/obj/item/stack/medical/gauze = 100,
		/obj/item/stack/sticky_tape/surgical = 100)
	time = 40
	/// How much sanitization is added
	var/sanitization_added = 3
	/// How much flesh healing is added
	var/flesh_healing_added = 5


/datum/surgery_step/dress/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/datum/wound/burn/flesh/burn_wound = surgery.operated_wound
	if(burn_wound)
		display_results(
			user,
			target,
			span_notice("You begin to dress the burns on [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]..."),
			span_notice("[user] begins to dress the burns on [target]'s [target.parse_zone_with_bodypart(user.zone_selected)] with [tool]."),
			span_notice("[user] begins to dress the burns on [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]."),
		)
		display_pain(target, "The burns on your [target.parse_zone_with_bodypart(user.zone_selected)] sting like hell!")
	else
		user.visible_message(span_notice("[user] looks for [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]."), span_notice("You look for [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]..."))

/datum/surgery_step/dress/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/datum/wound/burn/flesh/burn_wound = surgery.operated_wound
	if(burn_wound)
		display_results(
			user,
			target,
			span_notice("You successfully wrap [target]'s [target.parse_zone_with_bodypart(target_zone)] with [tool]."),
			span_notice("[user] successfully wraps [target]'s [target.parse_zone_with_bodypart(target_zone)] with [tool]!"),
			span_notice("[user] successfully wraps [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
		)
		log_combat(user, target, "dressed burns in", addition="COMBAT MODE: [uppertext(user.combat_mode)]")
		burn_wound.sanitization += sanitization_added
		burn_wound.flesh_healing += flesh_healing_added
		var/obj/item/bodypart/the_part = target.get_bodypart(target_zone)
		the_part.apply_gauze(tool)
	else
		to_chat(user, span_warning("[target] has no burns there!"))
	return ..()

/datum/surgery_step/dress/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	..()
	if(isstack(tool))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)
