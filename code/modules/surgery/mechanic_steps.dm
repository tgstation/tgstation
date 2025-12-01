//open shell
/datum/surgery_step/mechanic_open
	name = "unscrew shell (screwdriver or scalpel)"
	implements = list(
		TOOL_SCREWDRIVER = 100,
		TOOL_SCALPEL = 75, // med borgs could try to unscrew shell with scalpel
		/obj/item/knife = 50,
		/obj/item = 10) // 10% success with any sharp item.
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'

/datum/surgery_step/mechanic_open/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to unscrew the shell of [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to unscrew the shell of [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to unscrew the shell of [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "You can feel your [target.parse_zone_with_bodypart(target_zone)] grow numb as the sensory panel is unscrewed.", TRUE)

/datum/surgery_step/mechanic_open/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.get_sharpness())
		return FALSE
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//close shell
/datum/surgery_step/mechanic_close
	name = "screw shell (screwdriver or scalpel)"
	implements = list(
		TOOL_SCREWDRIVER = 100,
		TOOL_SCALPEL = 75,
		/obj/item/knife = 50,
		/obj/item = 10) // 10% success with any sharp item.
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'

/datum/surgery_step/mechanic_close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to screw the shell of [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to screw the shell of [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to screw the shell of [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "You feel the faint pricks of sensation return as your [target.parse_zone_with_bodypart(target_zone)]'s panel is screwed in.", TRUE)

/datum/surgery_step/mechanic_close/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.get_sharpness())
		return FALSE
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//prepare electronics
/datum/surgery_step/prepare_electronics
	name = "prepare electronics (multitool or hemostat)"
	implements = list(
		TOOL_MULTITOOL = 100,
		TOOL_HEMOSTAT = 75)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

/datum/surgery_step/prepare_electronics/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to prepare electronics in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to prepare electronics in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to prepare electronics in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "You can feel a faint buzz in your [target.parse_zone_with_bodypart(target_zone)] as the electronics reboot.", TRUE)

//unwrench
/datum/surgery_step/mechanic_unwrench
	name = "unwrench bolts (wrench or retractor)"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_RETRACTOR = 75)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'

/datum/surgery_step/mechanic_unwrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to unwrench some bolts in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to unwrench some bolts in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to unwrench some bolts in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "You feel a jostle in your [target.parse_zone_with_bodypart(target_zone)] as the bolts begin to loosen.", TRUE)

/datum/surgery_step/mechanic_unwrench/tool_check(mob/user, obj/item/tool)
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//wrench
/datum/surgery_step/mechanic_wrench
	name = "wrench bolts (wrench or retractor)"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_RETRACTOR = 75)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'

/datum/surgery_step/mechanic_wrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to wrench some bolts in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to wrench some bolts in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to wrench some bolts in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "You feel a jostle in your [target.parse_zone_with_bodypart(target_zone)] as the bolts begin to tighten.", TRUE)

/datum/surgery_step/mechanic_wrench/tool_check(mob/user, obj/item/tool)
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//open hatch
/datum/surgery_step/open_hatch
	name = "open the hatch (hand)"
	accept_hand = TRUE
	time = 1 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'
	preop_sound = 'sound/machines/airlock/doorclick.ogg'

/datum/surgery_step/open_hatch/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to open the hatch holders in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to open the hatch holders in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to open the hatch holders in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "The last faint pricks of tactile sensation fade from your [target.parse_zone_with_bodypart(target_zone)] as the hatch is opened.", TRUE)

/datum/surgery_step/open_hatch/tool_check(mob/user, obj/item/tool)
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE
