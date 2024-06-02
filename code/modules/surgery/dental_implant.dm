/datum/surgery/dental_implant
	name = "Dental implant"
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)
	steps = list(
		/datum/surgery_step/drill,
		/datum/surgery_step/insert_pill,
	)

/datum/surgery_step/insert_pill
	name = "insert pill"
	implements = list(/obj/item/reagent_containers/pill = 100)
	time = 16

/datum/surgery_step/insert_pill/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to wedge [tool] in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to wedge \the [tool] in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to wedge something in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "Something's being jammed into your [target.parse_zone_with_bodypart(target_zone)]!")

/datum/surgery_step/insert_pill/success(mob/user, mob/living/carbon/target, target_zone, obj/item/reagent_containers/pill/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(!istype(tool))
		return FALSE

	user.transferItemToLoc(tool, target, TRUE)

	var/datum/action/item_action/hands_free/activate_pill/pill_action = new(tool)
	pill_action.name = "Activate [tool.name]"
	pill_action.build_all_button_icons()
	pill_action.target = tool
	pill_action.Grant(target) //The pill never actually goes in an inventory slot, so the owner doesn't inherit actions from it

	display_results(
		user,
		target,
		span_notice("You wedge [tool] into [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] wedges \the [tool] into [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
		span_notice("[user] wedges something into [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
	)
	return ..()

/datum/action/item_action/hands_free/activate_pill
	name = "Activate Pill"

/datum/action/item_action/hands_free/activate_pill/Trigger(trigger_flags)
	if(!..())
		return FALSE
	var/obj/item/item_target = target
	to_chat(owner, span_notice("You grit your teeth and burst the implanted [item_target.name]!"))
	owner.log_message("swallowed an implanted pill, [target]", LOG_ATTACK)
	if(item_target.reagents.total_volume)
		item_target.reagents.trans_to(owner, item_target.reagents.total_volume, transferred_by = owner, methods = INGEST)
	qdel(target)
	return TRUE
