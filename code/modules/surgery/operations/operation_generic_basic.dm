// Some operations that mirror basic carbon state-moving operations but for basic mobs
/// Incision of skin for basic mobs
/datum/surgery_operation/basic/incise_skin
	name = "make incision"
	// rnd_name = "Laparotomy / Craniotomy / Myotomy" // Maybe we keep this one simple
	desc = "Make an incision in the patient's skin to access internals."
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/melee/energy/sword = 1.33,
		/obj/item/knife = 1.5,
		/obj/item/shard = 2.25,
		/obj/item = 3.33,
	)
	time = 1.6 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD

/datum/surgery_operation/basic/incise_skin/get_default_radial_image()
	return image(/obj/item/scalpel)

/datum/surgery_operation/basic/incise_skin/state_check(mob/living/patient)
	// Only for limbless mobs
	return !patient.has_limbs && has_any_surgery_state(patient, SURGERY_SKIN_OPEN|SURGERY_SKIN_CUT)

/datum/surgery_operation/basic/incise_skin/tool_check(obj/item/tool)
	// Require sharpness OR a tool behavior match
	return (tool.get_sharpness() || implements[tool.tool_behaviour])

/datum/surgery_operation/basic/incise_skin/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("You begin to make an incision in [patient]..."),
		span_notice("[surgeon] begins to make an incision in [patient]."),
		span_notice("[surgeon] begins to make an incision in [patient]."),
	)
	display_pain(patient, "You feel a stabbing feeling!")

/datum/surgery_operation/basic/incise_skin/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	// Skip straight to open, basic mobs don't have vessels to bleed from
	patient.apply_status_effect(/datum/status_effect/basic_surgery_state, SURGERY_SKIN_OPEN)

// Closing of skin for basic mobs
/datum/surgery_operation/basic/close_skin
	name = "mend incision"
	desc = "Mend the incision in the patient's skin, closing it up."
	implements = list(
		TOOL_CAUTERY = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/gun/energy/laser = 1.15,
		TOOL_WELDER = 1.5,
		/obj/item = 3.33,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/cautery1.ogg'
	success_sound = 'sound/items/handling/surgery/cautery2.ogg'

/datum/surgery_operation/basic/close_skin/get_default_radial_image()
	return image(/obj/item/cautery)

/datum/surgery_operation/basic/close_skin/state_check(mob/living/patient)
	// Only for limbless mobs. Also we're not picky and allow this if any surgical state is detected
	return !patient.has_limbs && has_any_surgery_state(patient)

/datum/surgery_operation/basic/close_skin/tool_check(obj/item/tool)
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
	display_pain(patient, "You are being burned!")

/datum/surgery_operation/basic/close_skin/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	// Just nuke the status effect, wipe the slate clean
	patient.remove_status_effect(/datum/status_effect/basic_surgery_state)
