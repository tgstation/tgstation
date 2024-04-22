//cut wires
/datum/surgery_step/cut_wires
	name = "cut wires"
	implements = list(
		TOOL_WIRECUTTER = 100,
		TOOL_SCALPEL = 75,
		/obj/item/knife	= 50,
		/obj/item = 10,
	) // 10% success with any sharp item.
	time = 2.4 SECONDS

/datum/surgery_step/cut_wires/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to cut loose wires in [target]'s [parse_zone(target_zone)]..."),
		"[user] begins to cut loose wires in [target]'s [parse_zone(target_zone)].",
		"[user] begins to cut loose wires in [target]'s [parse_zone(target_zone)].",
	)

/datum/surgery_step/cut_wires/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.get_sharpness())
		return FALSE
	return TRUE

//pry off plating
/datum/surgery_step/pry_off_plating
	name = "pry off plating"
	implements = list(
		TOOL_CROWBAR = 100,
		TOOL_HEMOSTAT = 10,
	)
	time = 2.4 SECONDS

/datum/surgery_step/pry_off_plating/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	do_sparks(rand(5, 9), FALSE, target.loc)
	return TRUE

/datum/surgery_step/pry_off_plating/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to pry off [target]'s [parse_zone(target_zone)] plating..."),
		"[user] begins to pry off [target]'s [parse_zone(target_zone)] plating.",
		"[user] begins to pry off [target]'s [parse_zone(target_zone)] plating.",
	)

//weld plating
/datum/surgery_step/weld_plating
	name = "weld plating"
	implements = list(
		TOOL_WELDER = 100,
	)
	time = 2.4 SECONDS

/datum/surgery_step/weld_plating/tool_check(mob/user, obj/item/tool)
	if(implement_type == TOOL_WELDER && !tool.use_tool(user, user, 0, volume=50, amount=1))
		return FALSE
	return TRUE

/datum/surgery_step/weld_plating/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to weld [target]'s [parse_zone(target_zone)] plating..."),
		"[user] begins to weld [target]'s [parse_zone(target_zone)] plating.",
		"[user] begins to weld [target]'s [parse_zone(target_zone)] plating.",
	)

//replace wires
/datum/surgery_step/replace_wires
	name = "replace wires"
	implements = list(/obj/item/stack/cable_coil = 100)
	time = 2.4 SECONDS
	var/cableamount = 5

/datum/surgery_step/replace_wires/tool_check(mob/user, obj/item/tool)
	var/obj/item/stack/cable_coil/coil = tool
	if(coil.get_amount() < cableamount)
		to_chat(user, span_warning("Not enough cable!"))
		return FALSE
	return TRUE

/datum/surgery_step/replace_wires/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/stack/cable_coil/coil = tool
	if(coil && !(coil.get_amount() < cableamount)) //failproof
		coil.use(cableamount)
	return TRUE

/datum/surgery_step/replace_wires/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to replace [target]'s [parse_zone(target_zone)] wiring..."),
		"[user] begins to replace [target]'s [parse_zone(target_zone)] wiring.",
		"[user] begins to replace [target]'s [parse_zone(target_zone)] wiring.",
	)

//add plating
/datum/surgery_step/add_plating
	name = "add plating"
	implements = list(/obj/item/stack/sheet/iron = 100)
	time = 2.4 SECONDS
	var/ironamount = 5

/datum/surgery_step/add_plating/tool_check(mob/user, obj/item/tool)
	var/obj/item/stack/sheet/iron/plat = tool
	if(plat.get_amount() < ironamount)
		to_chat(user, span_warning("Not enough iron!"))
		return FALSE
	return TRUE

/datum/surgery_step/add_plating/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/stack/sheet/iron/plat = tool
	return plat?.use(ironamount)

/datum/surgery_step/add_plating/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to add plating to [target]'s [parse_zone(target_zone)]..."),
		"[user] begins to add plating to [target]'s [parse_zone(target_zone)].",
		"[user] begins to add plating to [target]'s [parse_zone(target_zone)].",
	)
