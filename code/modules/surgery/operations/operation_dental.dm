/datum/surgery_operation/limb/add_dental_implant
	name = "add dental implant"
	desc = "Implant a pill into a patient's teeth."
	implements = list(
		/obj/item/reagent_containers/applicator/pill = 1,
	)
	time = 1.6 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED|SURGERY_BONE_DRILLED

/datum/surgery_operation/limb/add_dental_implant/all_required_strings()
	. = list()
	. += "operate on mouth (target mouth)"
	. += ..()
	. += "the mouth must have teeth"

/datum/surgery_operation/limb/add_dental_implant/get_default_radial_image()
	return image('icons/hud/implants.dmi', "reagents")

/datum/surgery_operation/limb/add_dental_implant/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	return ..() && surgeon.canUnEquip(tool) && operated_zone == BODY_ZONE_PRECISE_MOUTH

/datum/surgery_operation/limb/add_dental_implant/state_check(obj/item/bodypart/head/limb)
	var/obj/item/bodypart/head/teeth_receptangle = limb
	if(!istype(teeth_receptangle))
		return FALSE
	if(teeth_receptangle.teeth_count <= 0)
		return FALSE
	var/count = 0
	for(var/obj/item/reagent_containers/applicator/pill/dental in limb)
		count++
	if(count >= teeth_receptangle.teeth_count)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/add_dental_implant/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to wedge [tool] in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to wedge \the [tool] in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to wedge something in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "Something's being jammed into your [limb.plaintext_zone]!")

/datum/surgery_operation/limb/add_dental_implant/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
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
		span_notice("[surgeon] wedges [tool] into [limb.owner]'s [limb.plaintext_zone]!"),
		span_notice("[surgeon] wedges something into [limb.owner]'s [limb.plaintext_zone]!"),
	)

/datum/surgery_operation/limb/remove_dental_implant
	name = "remove dental implant"
	desc = "Remove a dental implant from a patient's teeth."
	implements = list(
		TOOL_HEMOSTAT = 1,
		IMPLEMENT_HAND = 1,
	)
	time = 3.2 SECONDS
	all_surgery_states_required = SURGERY_BONE_DRILLED|SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED

/datum/surgery_operation/limb/remove_dental_implant/get_default_radial_image()
	return image(/obj/item/reagent_containers/applicator/pill)

/datum/surgery_operation/limb/remove_dental_implant/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	return ..() && operated_zone == BODY_ZONE_PRECISE_MOUTH

/datum/surgery_operation/limb/remove_dental_implant/get_time_modifiers(atom/movable/operating_on, mob/living/surgeon, tool)
	. = ..()
	for(var/obj/item/flashlight/light in surgeon)
		if(light.light_on) // Hey I can see a better!
			. *= 0.8

/datum/surgery_operation/limb/remove_dental_implant/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin looking in [limb.owner]'s mouth for dental implants..."),
		span_notice("[surgeon] begins to look in [limb.owner]'s mouth."),
		span_notice("[surgeon] begins to examine [limb.owner]'s teeth."),
	)
	display_pain(limb.owner, "You feel fingers poke around at your teeth.")

/datum/surgery_operation/limb/remove_dental_implant/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/list/pills = list()
	for(var/obj/item/reagent_containers/applicator/pill/dental in limb)
		pills += dental
	if(!length(pills))
		display_results(
			surgeon,
			limb.owner,
			span_notice("You don't find any dental implants in [limb.owner]'s [limb.plaintext_zone]."),
			span_notice("[surgeon] doesn't find any dental implants in [limb.owner]'s [limb.plaintext_zone]."),
			span_notice("[surgeon] finishes examining [limb.owner]'s [limb.plaintext_zone]."),
		)
		return

	var/obj/item/reagent_containers/applicator/pill/yoinked = pick(pills)
	for(var/datum/action/item_action/activate_pill/associated_action in limb.owner.actions)
		if(associated_action.target == yoinked)
			qdel(associated_action)

	surgeon.put_in_hands(yoinked)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You carefully remove [yoinked] from [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] carefully removes [yoinked] from [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] carefully removes something from [limb.owner]'s [limb.plaintext_zone]."),
	)

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
