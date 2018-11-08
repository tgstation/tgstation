
//make incision
/datum/surgery_step/incise
	name = "make incision"
	implements = list(/obj/item/scalpel = 100, /obj/item/melee/transforming/energy/sword = 75, /obj/item/kitchen/knife = 65,
		/obj/item/shard = 45, /obj/item = 30) // 30% success with any sharp item.
	time = 16

/datum/surgery_step/incise/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to make an incision in [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to make an incision in [target]'s [parse_zone(target_zone)]...</span>")

/datum/surgery_step/incise/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.is_sharp())
		return FALSE

	return TRUE

//clamp bleeders
/datum/surgery_step/clamp_bleeders
	name = "clamp bleeders"
	implements = list(/obj/item/hemostat = 100, TOOL_WIRECUTTER = 60, /obj/item/stack/packageWrap = 35, /obj/item/stack/cable_coil = 15)
	time = 24

/datum/surgery_step/clamp_bleeders/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to clamp bleeders in [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to clamp bleeders in [target]'s [parse_zone(target_zone)]...</span>")

/datum/surgery_step/clamp_bleeders/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(locate(/datum/surgery_step/saw) in surgery.steps)
		target.heal_bodypart_damage(20,0)
	return ..()


//retract skin
/datum/surgery_step/retract_skin
	name = "retract skin"
	implements = list(/obj/item/retractor = 100, TOOL_SCREWDRIVER = 45, TOOL_WIRECUTTER = 35)
	time = 24

/datum/surgery_step/retract_skin/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to retract the skin in [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to retract the skin in [target]'s [parse_zone(target_zone)]...</span>")



//close incision
/datum/surgery_step/close
	name = "mend incision"
	implements = list(/obj/item/cautery = 100, /obj/item/gun/energy/laser = 90, TOOL_WELDER = 70,
		/obj/item = 30) // 30% success with any hot item.
	time = 24

/datum/surgery_step/close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to mend the incision in [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to mend the incision in [target]'s [parse_zone(target_zone)]...</span>")

/datum/surgery_step/close/tool_check(mob/user, obj/item/tool)
	if(implement_type == TOOL_WELDER || implement_type == /obj/item)
		return tool.is_hot()

	return TRUE

/datum/surgery_step/close/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(locate(/datum/surgery_step/saw) in surgery.steps)
		target.heal_bodypart_damage(45,0)
	return ..()



//saw bone
/datum/surgery_step/saw
	name = "saw bone"
	implements = list(/obj/item/circular_saw = 100, /obj/item/melee/transforming/energy/sword/cyborg/saw = 100,
		/obj/item/melee/arm_blade = 75, /obj/item/mounted_chainsaw = 65, /obj/item/twohanded/required/chainsaw = 50,
		/obj/item/twohanded/fireaxe = 50, /obj/item/hatchet = 35, /obj/item/kitchen/knife/butcher = 25)
	time = 54

/datum/surgery_step/saw/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to saw through the bone in [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to saw through the bone in [target]'s [parse_zone(target_zone)]...</span>")

/datum/surgery_step/saw/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.apply_damage(50, BRUTE, "[target_zone]")

	user.visible_message("[user] saws [target]'s [parse_zone(target_zone)] open!", "<span class='notice'>You saw [target]'s [parse_zone(target_zone)] open.</span>")
	return 1

//drill bone
/datum/surgery_step/drill
	name = "drill bone"
	implements = list(/obj/item/surgicaldrill = 100, /obj/item/screwdriver/power = 80, /obj/item/pickaxe/drill = 60, /obj/item/mecha_parts/mecha_equipment/drill = 60, TOOL_SCREWDRIVER = 20)
	time = 30

/datum/surgery_step/drill/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to drill into the bone in [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to drill into the bone in [target]'s [parse_zone(target_zone)]...</span>")

/datum/surgery_step/drill/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] drills into [target]'s [parse_zone(target_zone)]!",
		"<span class='notice'>You drill into [target]'s [parse_zone(target_zone)].</span>")
	return 1
