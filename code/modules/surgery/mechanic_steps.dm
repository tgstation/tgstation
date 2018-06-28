//open cover
/datum/surgery_step/unscrew
	name = "unscrew cover"
	implements = list(
		TOOL_SCREWDRIVER		= 100,
		/obj/item/scalpel 		= 75, // med borgs could try to unskrew shell with scalpel
		/obj/item/kitchen/knife	= 50,
		/obj/item/coin			= 30,
		/obj/item				= 10) // 10% success with any sharp item.
	time = 24

/datum/surgery_step/unscrew/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to unscrew the cover panel on [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to unscrew the cover panel on [target]'s [parse_zone(target_zone)]...</span>")

/datum/surgery_step/unscrew/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.is_sharp())
		return FALSE

	return TRUE

//close cover
/datum/surgery_step/screw_cover
	name = "screw cover"
	implements = list(
		TOOL_SCREWDRIVER		= 100,
		/obj/item/scalpel 		= 75,
		/obj/item/kitchen/knife	= 50,
		/obj/item/coin			= 30,
		/obj/item				= 10) // 10% success with any sharp item.
	time = 24

/datum/surgery_step/screw_cover/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to screw the cover panel on [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to screw the cover panel on [target]'s [parse_zone(target_zone)]...</span>")

/datum/surgery_step/screw_cover/tool_check(mob/user, obj/item/tool)
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
/datum/surgery_step/unwrench
	name = "unwrench bolts"
	implements = list(
		TOOL_WRENCH = 100,
		/obj/item/retractor = 10)
	time = 24

/datum/surgery_step/unwrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to unwrench some bolts in [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to unwrench some bolts in [target]'s [parse_zone(target_zone)]...</span>")

//wrench
/datum/surgery_step/wrench
	name = "wrench bolts"
	implements = list(
		TOOL_WRENCH = 100,
		/obj/item/retractor = 10)
	time = 24

/datum/surgery_step/wrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to wrench some bolts in [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to wrench some bolts in [target]'s [parse_zone(target_zone)]...</span>")

//open hatch
/datum/surgery_step/pry_off
	name = "pry off cover"
	implements = list(
		TOOL_CROWBAR = 100)
	time = 30

/datum/surgery_step/pry_off/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to pry open the cover panel on [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to pry open the cover panel on [target]'s [parse_zone(target_zone)]...</span>")

/datum/surgery_step/close_cover
	name = "close cover"
	implements = list(
		TOOL_CROWBAR = 100)
	time = 30

/datum/surgery_step/close_cover/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to put the cover panel on [target]'s [parse_zone(target_zone)] back in place.</span>",
		"<span class='notice'>You begin to put the cover panel on [target]'s [parse_zone(target_zone)] back in place...</span>")

/datum/surgery_step/robotic_amputation
	name = "disconnect limb"
	implements = list(
		TOOL_MULTITOOL = 100,
		TOOL_WIRECUTTERS = 10)
	time = 64

/datum/surgery_step/robotic_amputation/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!istype(tool, TOOL_MULTITOOL))
		user.visible_message("<span class='notice'>[user] begins to cut through the circuitry in [target]'s [parse_zone(target_zone)]!</span>", "<span class='notice'>You begin to cut through the circuitry in [target]'s [parse_zone(target_zone)]...</span>")
	else
		var/pro = pick("neatly", "calmly", "professionally", "carefully", "swiftly", "proficiently")
		user.visible_message("[user] begins to [pro] disconnect [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You begin to [pro] disconnect [target]'s [parse_zone(target_zone)]...</span>")

/datum/surgery_step/robotic_amputation/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/L = target
	user.visible_message("<span class='notice'>[user] removes [L]'s [parse_zone(target_zone)]!</span>", "<span class='notice'>You remove [L]'s [parse_zone(target_zone)].</span>")
	if(surgery.operated_bodypart)
		var/obj/item/bodypart/target_limb = surgery.operated_bodypart
		target_limb.drop_limb()