/datum/surgery_operation/basic/incise_skin
	name = "make incision"
	desc = "Make an incision in the patient's skin to access internals."
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/melee/energy/sword = 0.75,
		/obj/item/knife = 0.65,
		/obj/item/shard = 0.45,
		/obj/item = 0.3,
	)
	time = 1.6 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD

/datum/surgery_operation/basic/incise_skin/get_default_radial_image(mob/living/patient, mob/living/surgeon, obj/item/tool)
	return image(/obj/item/scalpel)

/datum/surgery_operation/basic/incise_skin/is_available(mob/living/patient, mob/living/surgeon, obj/item/tool)
	if(iscarbon(patient))
		return FALSE // use the limb one for carbons
	if(get_skin_state(patient) >= SURGERY_SKIN_CUT)
		return FALSE
	return TRUE

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
	set_skin_state(patient, SURGERY_SKIN_OPEN)

/datum/surgery_operation/basic/close_skin
	name = "mend incision"
	desc = "Mend the incision in the patient's skin, closing it up."
	implements = list(
		TOOL_CAUTERY = 1,
		/obj/item/gun/energy/laser = 0.9,
		TOOL_WELDER = 0.7,
		/obj/item = 0.3,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/cautery1.ogg'
	success_sound = 'sound/items/handling/surgery/cautery2.ogg'

/datum/surgery_operation/basic/close_skin/get_default_radial_image(mob/living/patient, mob/living/surgeon, obj/item/tool)
	return image(/obj/item/cautery)

/datum/surgery_operation/basic/close_skin/is_available(mob/living/patient, mob/living/surgeon, obj/item/tool)
	if(iscarbon(patient))
		return FALSE // use the limb one for carbons
	if(get_skin_state(patient) >= SURGERY_SKIN_CUT)
		return FALSE
	return TRUE

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
	set_skin_state(patient, SURGERY_SKIN_CLOSED)
	set_vessel_state(patient, SURGERY_VESSELS_NORMAL)
