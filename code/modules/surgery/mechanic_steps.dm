//open shell
/datum/surgery_step/mechanic_incise
	name = "unscrew shell"
	implements = list(
		/obj/item/screwdriver	= 100,
		/obj/item/scalpel 		= 75, // med borgs could try to unskrew shell with scalpel
		/obj/item/kitchen/knife	= 50,
		/obj/item				= 10) // 10% success with any sharp item.
	time = 16

/datum/surgery_step/mechanic_incise/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
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
		/obj/item/screwdriver	= 100,
		/obj/item/scalpel 		= 75, // med borgs could try to unskrew shell with scalpel
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