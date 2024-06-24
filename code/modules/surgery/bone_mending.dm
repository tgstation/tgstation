
/////BONE FIXING SURGERIES//////

///// Repair Hairline Fracture (Severe)
/datum/surgery/repair_bone_hairline
	name = "Repair bone fracture (hairline)"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	targetable_wound = /datum/wound/blunt/bone/severe
	possible_locs = list(
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_LEG,
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/repair_bone_hairline,
		/datum/surgery_step/close,
	)

///// Repair Compound Fracture (Critical)
/datum/surgery/repair_bone_compound
	name = "Repair Compound Fracture"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	targetable_wound = /datum/wound/blunt/bone/critical
	possible_locs = list(
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_LEG,
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/reset_compound_fracture,
		/datum/surgery_step/repair_bone_compound,
		/datum/surgery_step/close,
	)

//SURGERY STEPS

///// Repair Hairline Fracture (Severe)
/datum/surgery_step/repair_bone_hairline
	name = "repair hairline fracture (bonesetter/bone gel/tape)"
	implements = list(
		TOOL_BONESET = 100,
		/obj/item/stack/medical/bone_gel = 100,
		/obj/item/stack/sticky_tape/surgical = 100,
		/obj/item/stack/sticky_tape/super = 50,
		/obj/item/stack/sticky_tape = 30)
	time = 40

/datum/surgery_step/repair_bone_hairline/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		display_results(
			user,
			target,
			span_notice("You begin to repair the fracture in [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]..."),
			span_notice("[user] begins to repair the fracture in [target]'s [target.parse_zone_with_bodypart(user.zone_selected)] with [tool]."),
			span_notice("[user] begins to repair the fracture in [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]."),
		)
		display_pain(target, "Your [target.parse_zone_with_bodypart(user.zone_selected)] aches with pain!")
	else
		user.visible_message(span_notice("[user] looks for [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]."), span_notice("You look for [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]..."))

/datum/surgery_step/repair_bone_hairline/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(surgery.operated_wound)
		if(isstack(tool))
			var/obj/item/stack/used_stack = tool
			used_stack.use(1)
		display_results(
			user,
			target,
			span_notice("You successfully repair the fracture in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
			span_notice("[user] successfully repairs the fracture in [target]'s [target.parse_zone_with_bodypart(target_zone)] with [tool]!"),
			span_notice("[user] successfully repairs the fracture in [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
		)
		log_combat(user, target, "repaired a hairline fracture in", addition="COMBAT_MODE: [uppertext(user.combat_mode)]")
		qdel(surgery.operated_wound)
	else
		to_chat(user, span_warning("[target] has no hairline fracture there!"))
	return ..()

/datum/surgery_step/repair_bone_hairline/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	..()
	if(isstack(tool))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)



///// Reset Compound Fracture (Crticial)
/datum/surgery_step/reset_compound_fracture
	name = "reset bone (bonesetter)"
	implements = list(
		TOOL_BONESET = 100,
		/obj/item/stack/sticky_tape/surgical = 60,
		/obj/item/stack/sticky_tape/super = 40,
		/obj/item/stack/sticky_tape = 20)
	time = 40

/datum/surgery_step/reset_compound_fracture/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		display_results(
			user,
			target,
			span_notice("You begin to reset the bone in [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]..."),
			span_notice("[user] begins to reset the bone in [target]'s [target.parse_zone_with_bodypart(user.zone_selected)] with [tool]."),
			span_notice("[user] begins to reset the bone in [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]."),
		)
		display_pain(target, "The aching pain in your [target.parse_zone_with_bodypart(user.zone_selected)] is overwhelming!")
	else
		user.visible_message(span_notice("[user] looks for [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]."), span_notice("You look for [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]..."))

/datum/surgery_step/reset_compound_fracture/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(surgery.operated_wound)
		if(isstack(tool))
			var/obj/item/stack/used_stack = tool
			used_stack.use(1)
		display_results(
			user,
			target,
			span_notice("You successfully reset the bone in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
			span_notice("[user] successfully resets the bone in [target]'s [target.parse_zone_with_bodypart(target_zone)] with [tool]!"),
			span_notice("[user] successfully resets the bone in [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
		)
		log_combat(user, target, "reset a compound fracture in", addition="COMBAT MODE: [uppertext(user.combat_mode)]")
	else
		to_chat(user, span_warning("[target] has no compound fracture there!"))
	return ..()

/datum/surgery_step/reset_compound_fracture/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	..()
	if(isstack(tool))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)

#define IMPLEMENTS_THAT_FIX_BONES list( \
	/obj/item/stack/medical/bone_gel = 100, \
	/obj/item/stack/sticky_tape/surgical = 100, \
	/obj/item/stack/sticky_tape/super = 50, \
	/obj/item/stack/sticky_tape = 30, \
)


///// Repair Compound Fracture (Crticial)
/datum/surgery_step/repair_bone_compound
	name = "repair compound fracture (bone gel/tape)"
	implements = IMPLEMENTS_THAT_FIX_BONES
	time = 40

/datum/surgery_step/repair_bone_compound/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(surgery.operated_wound)
		display_results(
			user,
			target,
			span_notice("You begin to repair the fracture in [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]..."),
			span_notice("[user] begins to repair the fracture in [target]'s [target.parse_zone_with_bodypart(user.zone_selected)] with [tool]."),
			span_notice("[user] begins to repair the fracture in [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]."),
		)
		display_pain(target, "The aching pain in your [target.parse_zone_with_bodypart(user.zone_selected)] is overwhelming!")
	else
		user.visible_message(span_notice("[user] looks for [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]."), span_notice("You look for [target]'s [target.parse_zone_with_bodypart(user.zone_selected)]..."))

/datum/surgery_step/repair_bone_compound/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(surgery.operated_wound)
		if(isstack(tool))
			var/obj/item/stack/used_stack = tool
			used_stack.use(1)
		display_results(
			user,
			target,
			span_notice("You successfully repair the fracture in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
			span_notice("[user] successfully repairs the fracture in [target]'s [target.parse_zone_with_bodypart(target_zone)] with [tool]!"),
			span_notice("[user] successfully repairs the fracture in [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
		)
		log_combat(user, target, "repaired a compound fracture in", addition="COMBAT MODE: [uppertext(user.combat_mode)]")
		qdel(surgery.operated_wound)
	else
		to_chat(user, span_warning("[target] has no compound fracture there!"))
	return ..()

/datum/surgery_step/repair_bone_compound/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	..()
	if(isstack(tool))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)

/// Surgery to repair cranial fissures
/datum/surgery/cranial_reconstruction
	name = "Cranial reconstruction"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	targetable_wound = /datum/wound/cranial_fissure
	possible_locs = list(
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/clamp_bleeders/discard_skull_debris,
		/datum/surgery_step/repair_skull
	)

/datum/surgery_step/clamp_bleeders/discard_skull_debris
	name = "discard skull debris (hemostat)"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_WIRECUTTER = 40,
		TOOL_SCREWDRIVER = 40,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/surgery/hemostat1.ogg'

/datum/surgery_step/clamp_bleeders/discard_skull_debris/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to discard the smaller skull debris in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to discard the smaller skull debris in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to poke around in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
	)

	display_pain(target, "Your brain feels like it's getting stabbed by little shards of glass!")

/datum/surgery_step/repair_skull
	name = "repair skull (bone gel/tape)"
	implements = IMPLEMENTS_THAT_FIX_BONES
	time = 4 SECONDS

/datum/surgery_step/repair_skull/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	ASSERT(surgery.operated_wound, "Repairing skull without a wound")

	display_results(
		user,
		target,
		span_notice("You begin to repair [target]'s skull as best you can..."),
		span_notice("[user] begins to repair [target]'s skull with [tool]."),
		span_notice("[user] begins to repair [target]'s skull."),
	)

	display_pain(target, "You can feel pieces of your skull rubbing against your brain!")

/datum/surgery_step/repair_skull/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	if (isnull(surgery.operated_wound))
		to_chat(user, span_warning("[target]'s skull is fine!"))
		return ..()


	if (isstack(tool))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)

	display_results(
		user,
		target,
		span_notice("You successfully repair [target]'s skull."),
		span_notice("[user] successfully repairs [target]'s skull with [tool]."),
		span_notice("[user] successfully repairs [target]'s skull.")
	)

	qdel(surgery.operated_wound)

	return ..()

#undef IMPLEMENTS_THAT_FIX_BONES
