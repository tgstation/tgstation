// Some operations that mirror basic carbon state-moving operations but for basic mobs
/// Incision of skin for basic mobs
/datum/surgery_operation/basic/incise_skin
	name = "make incision"
	// rnd_name = "Laparotomy / Craniotomy / Myotomy (Make Incision)" // Maybe we keep this one simple
	desc = "Make an incision in the patient's skin to access internals. \
		Causes \"cut skin\" surgical state."
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/melee/energy/sword = 1.33,
		/obj/item/knife = 1.5,
		/obj/item/shard = 2.25,
		/obj/item/screwdriver = 5,
		/obj/item/pen = 5,
		/obj/item = 3.33,
	)
	time = 1.6 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD
	any_surgery_states_blocked = ALL_SURGERY_SKIN_STATES
	target_zone = null

/datum/surgery_operation/basic/incise_skin/get_any_tool()
	return "Any sharp edged item"

/datum/surgery_operation/basic/incise_skin/all_blocked_strings()
	return ..() + list("The patient must not have complex anatomy")

/datum/surgery_operation/basic/incise_skin/get_default_radial_image()
	return image(/obj/item/scalpel)

/datum/surgery_operation/basic/incise_skin/state_check(mob/living/patient)
	return !patient.has_limbs // Only for limbless mobs

/datum/surgery_operation/basic/incise_skin/tool_check(obj/item/tool)
	// Require edged sharpness OR a tool behavior match
	if((tool.get_sharpness() & SHARP_EDGED) || implements[tool.tool_behaviour])
		return TRUE
	// these are here by popular demand, even though they don't fit the above criteria
	if(istype(tool, /obj/item/pen) || istype(tool, /obj/item/screwdriver))
		return TRUE
	return FALSE

/datum/surgery_operation/basic/incise_skin/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("You begin to make an incision in [patient]..."),
		span_notice("[surgeon] begins to make an incision in [patient]."),
		span_notice("[surgeon] begins to make an incision in [patient]."),
	)
	display_pain(patient, "You feel a sharp stabbing sensation!")

/datum/surgery_operation/basic/incise_skin/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	patient.apply_status_effect(/datum/status_effect/basic_surgery_state, SURGERY_SKIN_OPEN)

/datum/surgery_operation/basic/saw_bone
	name = "saw bone"
	desc = "Saw through the patient's bones to access their internal organs. \
		Causes \"bone sawed\" surgical state."
	implements = list(
		TOOL_SAW = 1,
		/obj/item/shovel/serrated = 1.33,
		/obj/item/melee/arm_blade = 1.33,
		/obj/item/fireaxe = 2,
		/obj/item/hatchet = 2.85,
		/obj/item/knife/butcher = 2.85,
		/obj/item = 4,
	)
	time = 5.4 SECONDS
	preop_sound = list(
		/obj/item/circular_saw = 'sound/items/handling/surgery/saw.ogg',
		/obj/item/melee/arm_blade = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/fireaxe = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/hatchet = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/knife/butcher = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item = 'sound/items/handling/surgery/scalpel1.ogg',
	)
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED
	target_zone = null

/datum/surgery_operation/basic/saw_bone/get_any_tool()
	return "Any sharp edged item with decent force"

/datum/surgery_operation/basic/saw_bone/all_blocked_strings()
	return ..() + list("The patient must not have complex anatomy")

/datum/surgery_operation/basic/saw_bone/get_default_radial_image()
	return image(/obj/item/circular_saw)

/datum/surgery_operation/basic/saw_bone/state_check(mob/living/patient)
	return !patient.has_limbs // Only for limbless mobs

/datum/surgery_operation/basic/saw_bone/tool_check(obj/item/tool)
	// Require edged sharpness and sufficient force OR a tool behavior match
	return (((tool.get_sharpness() & SHARP_EDGED) && tool.force >= 10) || implements[tool.tool_behaviour])

/datum/surgery_operation/basic/saw_bone/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("You begin to saw through [patient]'s bones..."),
		span_notice("[surgeon] begins to saw through [patient]'s bones."),
		span_notice("[surgeon] begins to saw through [patient]'s bones."),
	)
	display_pain(patient, "You feel a horrid ache spread through your insides!")

/datum/surgery_operation/basic/saw_bone/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	patient.apply_status_effect(/datum/status_effect/basic_surgery_state, SURGERY_BONE_SAWED)
	patient.apply_damage(patient.maxHealth * 0.5, sharpness = tool.get_sharpness(), wound_bonus = CANT_WOUND, attacking_item = tool)
	display_results(
		surgeon,
		patient,
		span_notice("You saw [patient] open."),
		span_notice("[surgeon] saws [patient] open!"),
		span_notice("[surgeon] saws [patient] open!"),
	)
	display_pain(patient, "It feels like something just broke!")

// Closing of skin for basic mobs
/datum/surgery_operation/basic/close_skin
	name = "mend incision"
	desc = "Mend the incision in the patient's skin, closing it up. \
		Clears most surgical states."
	implements = list(
		TOOL_CAUTERY = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/gun/energy/laser = 1.15,
		TOOL_WELDER = 1.5,
		/obj/item = 3.33,
	)
	time = 2.4 SECONDS
	preop_sound = list(
		/obj/item/stack/medical/suture = SFX_SUTURE_BEGIN,
		/obj/item = 'sound/items/handling/surgery/cautery1.ogg',
	)
	success_sound = list(
		/obj/item/stack/medical/suture = SFX_SUTURE_END,
		/obj/item = 'sound/items/handling/surgery/cautery2.ogg',
	)
	any_surgery_states_required = ALL_SURGERY_STATES_UNSET_ON_CLOSE // we're not picky
	target_zone = null

/datum/surgery_operation/basic/close_skin/get_any_tool()
	return "Any heat source"

/datum/surgery_operation/basic/close_skin/all_blocked_strings()
	return ..() + list("The patient must not have complex anatomy")

/datum/surgery_operation/basic/close_skin/get_default_radial_image()
	return image(/obj/item/cautery)

/datum/surgery_operation/basic/close_skin/state_check(mob/living/patient)
	return !patient.has_limbs // Only for limbless mobs

/datum/surgery_operation/basic/close_skin/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/stack/medical/suture))
		return TRUE

	if(istype(tool, /obj/item/gun/energy/laser))
		var/obj/item/gun/energy/laser/lasergun = tool
		return lasergun.cell?.charge > 0

	return tool.get_temperature() > 0

/datum/surgery_operation/basic/close_skin/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("You begin to mend the incision in [patient]..."),
		span_notice("[surgeon] begins to mend the incision in [patient]."),
		span_notice("[surgeon] begins to mend the incision in [patient]."),
	)
	display_pain(patient, "You are being [istype(tool, /obj/item/stack/medical/suture) ? "pinched" : "burned"]!")

/datum/surgery_operation/basic/close_skin/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	// Just nuke the status effect, wipe the slate clean
	patient.remove_status_effect(/datum/status_effect/basic_surgery_state)
