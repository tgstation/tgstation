//open shell
/datum/surgery_step/mechanic_open
	name = "unscrew shell (screwdriver)"
	implements = list(
		TOOL_SCREWDRIVER = 100,
		TOOL_SCALPEL = 75, // med borgs could try to unscrew shell with scalpel
		/obj/item/knife = 50,
		/obj/item = 10) // 10% success with any sharp item.
	time = 24
	preop_sound = 'sound/items/screwdriver.ogg'
	success_sound = 'sound/items/screwdriver2.ogg'

/datum/surgery_step/mechanic_open/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to unscrew the shell of [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to unscrew the shell of [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to unscrew the shell of [target]'s [parse_zone(target_zone)]."),
	)
	display_pain(target, "You can feel your [parse_zone(target_zone)] grow numb as the sensory panel is unscrewed.", TRUE)

/datum/surgery_step/mechanic_open/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.get_sharpness())
		return FALSE
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//close shell
/datum/surgery_step/mechanic_close
	name = "screw shell (screwdriver)"
	implements = list(
		TOOL_SCREWDRIVER = 100,
		TOOL_SCALPEL = 75,
		/obj/item/knife = 50,
		/obj/item = 10) // 10% success with any sharp item.
	time = 24
	preop_sound = 'sound/items/screwdriver.ogg'
	success_sound = 'sound/items/screwdriver2.ogg'

/datum/surgery_step/mechanic_close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to screw the shell of [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to screw the shell of [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to screw the shell of [target]'s [parse_zone(target_zone)]."),
	)
	display_pain(target, "You feel the faint pricks of sensation return as your [parse_zone(target_zone)]'s panel is screwed in.", TRUE)

/datum/surgery_step/mechanic_close/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.get_sharpness())
		return FALSE
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//prepare electronics
/datum/surgery_step/prepare_electronics
	name = "prepare electronics (multitool)"
	implements = list(
		TOOL_MULTITOOL = 100,
		TOOL_HEMOSTAT = 10) // try to reboot internal controllers via short circuit with some conductor
	time = 24
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

/datum/surgery_step/prepare_electronics/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to prepare electronics in [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to prepare electronics in [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to prepare electronics in [target]'s [parse_zone(target_zone)]."),
	)
	display_pain(target, "You can feel a faint buzz in your [parse_zone(target_zone)] as the electronics reboot.", TRUE)

//unwrench
/datum/surgery_step/mechanic_unwrench
	name = "unwrench bolts (wrench)"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_RETRACTOR = 10)
	time = 24
	preop_sound = 'sound/items/ratchet.ogg'

/datum/surgery_step/mechanic_unwrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to unwrench some bolts in [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to unwrench some bolts in [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to unwrench some bolts in [target]'s [parse_zone(target_zone)]."),
	)
	display_pain(target, "You feel a jostle in your [parse_zone(target_zone)] as the bolts begin to loosen.", TRUE)

/datum/surgery_step/mechanic_unwrench/tool_check(mob/user, obj/item/tool)
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//wrench
/datum/surgery_step/mechanic_wrench
	name = "wrench bolts (wrench)"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_RETRACTOR = 10)
	time = 24
	preop_sound = 'sound/items/ratchet.ogg'

/datum/surgery_step/mechanic_wrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to wrench some bolts in [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to wrench some bolts in [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to wrench some bolts in [target]'s [parse_zone(target_zone)]."),
	)
	display_pain(target, "You feel a jostle in your [parse_zone(target_zone)] as the bolts begin to tighten.", TRUE)

/datum/surgery_step/mechanic_wrench/tool_check(mob/user, obj/item/tool)
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//open hatch
/datum/surgery_step/open_hatch
	name = "open the hatch (hand)"
	accept_hand = TRUE
	time = 10
	preop_sound = 'sound/items/ratchet.ogg'
	preop_sound = 'sound/machines/doorclick.ogg'

/datum/surgery_step/open_hatch/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to open the hatch holders in [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to open the hatch holders in [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to open the hatch holders in [target]'s [parse_zone(target_zone)]."),
	)
	display_pain(target, "The last faint pricks of tactile sensation fade from your [parse_zone(target_zone)] as the hatch is opened.", TRUE)

/datum/surgery_step/open_hatch/tool_check(mob/user, obj/item/tool)
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE
