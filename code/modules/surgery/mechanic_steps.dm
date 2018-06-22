//open shell
/datum/surgery_step/mechanic_open
	name = "unscrew shell"
	implements = list(
		TOOL_SCREWDRIVER		= 100,
		/obj/item/scalpel 		= 75, // med borgs could try to unskrew shell with scalpel
		/obj/item/kitchen/knife	= 50,
		/obj/item				= 10) // 10% success with any sharp item.
	time = 24

/datum/surgery_step/mechanic_open/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to unscrew the shell of [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to unscrew the shell of [target]'s [parse_zone(target_zone)]...</span>")

/datum/surgery_step/mechanic_incise/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.is_sharp())
		return FALSE

	return TRUE

//close shell
/datum/surgery_step/mechanic_close
	name = "screw shell"
	implements = list(
		TOOL_SCREWDRIVER		= 100,
		/obj/item/scalpel 		= 75,
		/obj/item/kitchen/knife	= 50,
		/obj/item				= 10) // 10% success with any sharp item.
	time = 24

/datum/surgery_step/mechanic_close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to screw the shell of [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to screw the shell of [target]'s [parse_zone(target_zone)]...</span>")

/datum/surgery_step/mechanic_close/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.is_sharp())
		return FALSE

	return TRUE

//prepare electronics
/datum/surgery_step/prepare_electronics
	name = "prepare electronics"
	implements = list(
		TOOL_MULTITOOL = 100,
		/obj/item/hemostat = 10) // try to reboot internal controllers via short circuit with some conductor
	time = 24

/datum/surgery_step/prepare_electronics/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to prepare electronics in [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to prepare electronics in [target]'s [parse_zone(target_zone)]...</span>")

//unwrench
/datum/surgery_step/mechanic_unwrench
	name = "unwrench bolts"
	implements = list(
		TOOL_WRENCH = 100,
		/obj/item/retractor = 10)
	time = 24

/datum/surgery_step/mechanic_unwrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to unwrench some bolts in [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to unwrench some bolts in [target]'s [parse_zone(target_zone)]...</span>")

//wrench
/datum/surgery_step/mechanic_wrench
	name = "wrench bolts"
	implements = list(
		TOOL_WRENCH = 100,
		/obj/item/retractor = 10)
	time = 24

/datum/surgery_step/mechanic_wrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to wrench some bolts in [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to wrench some bolts in [target]'s [parse_zone(target_zone)]...</span>")

//open hatch
/datum/surgery_step/open_hatch
	name = "open the hatch"
	accept_hand = 1
	time = 10

/datum/surgery_step/open_hatch/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to open the hatch holders in [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to open the hatch holders in [target]'s [parse_zone(target_zone)]...</span>")