/// Allows an item to  be used to initiate surgeries.
/datum/element/surgery_initiator
	element_flags = ELEMENT_DETACH

/datum/element/surgery_initiator/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_ATTACK, .proc/on_item_attack)

/datum/element/surgery_initiator/Detach(datum/target)
	UnregisterSignal(target, COMSIG_ITEM_ATTACK)
	return ..()

/// Does the surgery initiation.
/datum/element/surgery_initiator/proc/on_item_attack(datum/target, atom/attack_target, mob/living/surgeon)
	SIGNAL_HANDLER
	if(!iscarbon(attack_target))
		return
	INVOKE_ASYNC(src, .proc/try_starting_surgery, target, target, surgeon)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/element/surgery_initiator/proc/try_starting_surgery(obj/item/surgery_tool, mob/living/carbon/patient, mob/living/surgeon)
	var/selected_zone = surgeon.zone_selected
	var/obj/item/bodypart/target_bodypart = patient.get_bodypart(check_zone(selected_zone))

	if(SEND_SIGNAL(patient, COMSIG_SURGERY_INITIATED, selected_zone, surgery_tool, patient, surgeon, try_cancellation = TRUE) & CANCEL_INITIATION)
		return

	var/list/available_surgeries = list()

	for(var/surgery_name in GLOB.surgeries_list)
		var/datum/component/surgery/surgery_instance = GLOB.surgeries_list[surgery_name]
		if(!valid_surgery(surgery_instance, selected_zone, target_bodypart, patient, surgeon))
			continue
		available_surgeries[surgery_instance.name] = surgery_instance

	if(!available_surgeries.len)
		return

	var/pick_your_surgery = input("Begin which procedure?", "Surgery", null, null) as null|anything in sortList(available_surgeries)
	if(!pick_your_surgery || !surgeon?.Adjacent(patient) || !(surgery_tool in surgeon))
		return

	var/datum/component/surgery/chosen_surgery_instance = available_surgeries[pick_your_surgery]

	if(SEND_SIGNAL(patient, COMSIG_SURGERY_INITIATED, selected_zone, surgery_tool, patient, surgeon, try_cancellation = FALSE) & CANCEL_INITIATION)
		return

	//we check that the surgery is still doable after the input() wait.
	if(!valid_surgery(chosen_surgery_instance, selected_zone, target_bodypart, patient, surgeon))
		return

	if(!chosen_surgery_instance.ignore_clothes && !get_location_accessible(patient, selected_zone))
		surgeon.balloon_alert(surgeon, "expose their [parse_zone(selected_zone)] first!")
		return
	var/datum/component/surgery/initiated_surgery = patient.AddComponent(chosen_surgery_instance.type, selected_zone, target_bodypart)
	surgeon.visible_message(
		span_notice("[surgeon] drapes [surgery_tool] over [patient]'s [parse_zone(selected_zone)] to prepare for surgery."), \
		span_notice("You drape [surgery_tool] over [patient]'s [parse_zone(selected_zone)] to prepare for \an [initiated_surgery].") \
	)
	log_combat(surgeon, patient, "operated on", null, "(OPERATION TYPE: [initiated_surgery]) (TARGET AREA: [selected_zone])")

///small helper returning TRUE if a surgery can still be performed (from a global SSdcs instance of a surgery component)
/datum/element/surgery_initiator/proc/valid_surgery(datum/component/surgery/global_surgery_instance, selected_zone, obj/item/bodypart/target_bodypart, mob/living/carbon/patient, mob/living/surgeon)
	. = FALSE
	if(!global_surgery_instance.possible_locs.Find(selected_zone))
		return
	if(target_bodypart)
		if(!global_surgery_instance.requires_bodypart)
			return
		if(global_surgery_instance.requires_bodypart_type && target_bodypart.status != global_surgery_instance.requires_bodypart_type)
			return
		if(global_surgery_instance.requires_real_bodypart && target_bodypart.is_pseudopart)
			return
	else if(patient && global_surgery_instance.requires_bodypart) //mob with no limb in surgery zone when we need a limb
		return
	if(global_surgery_instance.lying_required && patient.body_position != LYING_DOWN)
		return
	if(!global_surgery_instance.can_start(surgeon, patient))
		return
	if(global_surgery_instance.target_mobtypes)
		for(var/path in global_surgery_instance.target_mobtypes)
			if(istype(patient, path))
				return TRUE
