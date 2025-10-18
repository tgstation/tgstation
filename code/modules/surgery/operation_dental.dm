/datum/surgery_operation/add_dental_implant
	name = "add dental implant"
	implements = list(
		/obj/item/reagent_containers/applicator/pill = 1,
	)
	time = 1.6 SECONDS

/datum/surgery_operation/add_dental_implant/state_check(obj/item/bodypart/limb)
	if(limb.surgery_bone_state != SURGERY_BONE_DRILLED)
		return FALSE
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(limb.surgery_vessel_state < SURGERY_VESSELS_CLAMPED)
		return FALSE
	return TRUE

/datum/surgery_operation/add_dental_implant/is_available(obj/item/bodypart/limb)
	if(!istype(limb, /obj/item/bodypart/head))
		return FALSE

	var/obj/item/bodypart/head/teeth_receptangle = limb
	if(teeth_receptangle.teeth_count <= 0)
		return FALSE

	var/count = 0
	for(var/obj/item/reagent_containers/applicator/pill/dental in teeth_receptangle)
		count++

	if(count >= teeth_receptangle.teeth_count)
		return FALSE

	return TRUE

/datum/surgery_operation/add_dental_implant/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to wedge [tool] in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to wedge \the [tool] in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to wedge something in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "Something's being jammed into your [limb.plaintext_zone]!")

/datum/surgery_operation/add_dental_implant/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	// Pills go into head
	surgeon.transferItemToLoc(tool, limb, TRUE)

	var/datum/action/item_action/activate_pill/pill_action = new(tool)
	pill_action.name = "Activate [tool.name]"
	pill_action.build_all_button_icons()
	pill_action.Grant(limb.owner) //The pill never actually goes in an inventory slot, so the owner doesn't inherit actions from it

	display_results(
		surgeon,
		limb.owner,
		span_notice("You wedge [tool] into [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] wedges \the [tool] into [limb.owner]'s [limb.plaintext_zone]!"),
		span_notice("[surgeon] wedges something into [limb.owner]'s [limb.plaintext_zone]!"),
	)

/datum/surgery_operation/remove_dental_implant
	name = "remove dental implant"
	implements = list(
		TOOL_HEMOSTAT = 1,
		HAND_IMPLEMENT = 1,
	)

/datum/surgery_operation/remove_dental_implant/state_check(obj/item/bodypart/limb)
	if(limb.surgery_bone_state != SURGERY_BONE_DRILLED)
		return FALSE
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(limb.surgery_vessel_state < SURGERY_VESSELS_CLAMPED)
		return FALSE
	return TRUE

/datum/surgery_operation/remove_dental_implant/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin looking in [limb.owner]'s mouth for dental implants..."),
		span_notice("[surgeon] begins to look in [limb.owner]'s mouth."),
		span_notice("[surgeon] begins to examine [limb.owner]'s teeth."),
	)
	display_pain(limb.owner, "You feel fingers poke around at your teeth.")

/datum/surgery_operation/remove_dental_implant/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	pass()
	// melbert todo


// Teeth pill code
/datum/action/item_action/activate_pill
	name = "Activate Pill"
	check_flags = NONE

/datum/action/item_action/activate_pill/IsAvailable(feedback)
	if(owner.stat > SOFT_CRIT)
		return FALSE
	return ..()

/datum/action/item_action/activate_pill/do_effect(trigger_flags)
	owner.balloon_alert_to_viewers("[owner] grinds their teeth!", "you grit your teeth")
	if(!do_after(owner, owner.stat * (2.5 SECONDS), owner,  IGNORE_USER_LOC_CHANGE | IGNORE_INCAPACITATED))
		return FALSE
	var/obj/item/pill = target
	to_chat(owner, span_notice("You grit your teeth and burst the implanted [pill.name]!"))
	owner.log_message("swallowed an implanted pill, [pill]", LOG_ATTACK)
	pill.reagents.trans_to(owner, pill.reagents.total_volume, transferred_by = owner, methods = INGEST)
	qdel(pill)
	return TRUE
