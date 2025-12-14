
//make incision
/datum/surgery_step/incise
	name = "make incision (scalpel)"
	implements = list(
		TOOL_SCALPEL = 100,
		/obj/item/melee/energy/sword = 75,
		/obj/item/knife = 65,
		/obj/item/shard = 45,
		/obj/item = 30) // 30% success with any sharp item.
	time = 1.6 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	surgery_effects_mood = TRUE

/datum/surgery_step/incise/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to make an incision in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to make an incision in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to make an incision in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "You feel a stabbing in your [target.parse_zone_with_bodypart(target_zone)].")

/datum/surgery_step/incise/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.get_sharpness())
		return FALSE

	return TRUE

/datum/surgery_step/incise/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if ishuman(target)
		var/mob/living/carbon/human/human_target = target
		if (human_target.can_bleed())
			var/blood_name = human_target.get_bloodtype()?.get_blood_name() || "Blood"
			display_results(
				user,
				target,
				span_notice("[blood_name] pools around the incision in [human_target]'s [target.parse_zone_with_bodypart(target_zone)]."),
				span_notice("[blood_name] pools around the incision in [human_target]'s [target.parse_zone_with_bodypart(target_zone)]."),
				span_notice("[blood_name] pools around the incision in [human_target]'s [target.parse_zone_with_bodypart(target_zone)]."),
			)
			var/obj/item/bodypart/target_bodypart = target.get_bodypart(target_zone)
			if(target_bodypart)
				target_bodypart.adjustBleedStacks(10)
	return ..()

/datum/surgery_step/incise/nobleed/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to <i>carefully</i> make an incision in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to <i>carefully</i> make an incision in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to <i>carefully</i> make an incision in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "You feel a <i>careful</i> stabbing in your [target.parse_zone_with_bodypart(target_zone)].")

//clamp bleeders
/datum/surgery_step/clamp_bleeders
	name = "clamp bleeders (hemostat)"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_WIRECUTTER = 60,
		/obj/item/stack/package_wrap = 35,
		/obj/item/stack/cable_coil = 15)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'

/datum/surgery_step/clamp_bleeders/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to clamp bleeders in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to clamp bleeders in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to clamp bleeders in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "You feel a pinch as the bleeding in your [target.parse_zone_with_bodypart(target_zone)] is slowed.")

/datum/surgery_step/clamp_bleeders/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	if(locate(/datum/surgery_step/saw) in surgery.steps)
		target.heal_bodypart_damage(20, 0, target_zone = target_zone)
	if (ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/obj/item/bodypart/target_bodypart = human_target.get_bodypart(target_zone)
		if(target_bodypart)
			target_bodypart.adjustBleedStacks(-3)
	return ..()

//retract skin
/datum/surgery_step/retract_skin
	name = "retract skin (retractor)"
	implements = list(
		TOOL_RETRACTOR = 100,
		TOOL_SCREWDRIVER = 45,
		TOOL_WIRECUTTER = 35,
		/obj/item/stack/rods = 35)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/retractor1.ogg'
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'

/datum/surgery_step/retract_skin/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to retract the skin in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to retract the skin in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to retract the skin in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "You feel a severe stinging pain spreading across your [target.parse_zone_with_bodypart(target_zone)] as the skin is pulled back!")

//close incision
/datum/surgery_step/close
	name = "mend incision (cautery)"
	implements = list(
		TOOL_CAUTERY = 100,
		/obj/item/gun/energy/laser = 90,
		TOOL_WELDER = 70,
		/obj/item = 30) // 30% success with any hot item.
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/cautery1.ogg'
	success_sound = 'sound/items/handling/surgery/cautery2.ogg'

/datum/surgery_step/close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to mend the incision in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to mend the incision in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to mend the incision in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "Your [target.parse_zone_with_bodypart(target_zone)] is being burned!")

/datum/surgery_step/close/tool_check(mob/user, obj/item/tool)
	if(implement_type == TOOL_WELDER || implement_type == /obj/item)
		return tool.get_temperature()

	return TRUE

/datum/surgery_step/close/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	if(locate(/datum/surgery_step/saw) in surgery.steps)
		target.heal_bodypart_damage(45, 0, target_zone = target_zone)
	if (ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/obj/item/bodypart/target_bodypart = human_target.get_bodypart(target_zone)
		if(target_bodypart)
			target_bodypart.adjustBleedStacks(-3)
	return ..()



//saw bone
/datum/surgery_step/saw
	name = "saw bone (circular saw)"
	implements = list(
		TOOL_SAW = 100,
		/obj/item/shovel/serrated = 75,
		/obj/item/melee/arm_blade = 75,
		/obj/item/fireaxe = 50,
		/obj/item/hatchet = 35,
		/obj/item/knife/butcher = 35,
		/obj/item = 25) //20% success (sort of) with any sharp item with a force >= 10
	time = 5.4 SECONDS
	preop_sound = list(
		/obj/item/circular_saw = 'sound/items/handling/surgery/saw.ogg',
		/obj/item/melee/arm_blade = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/fireaxe = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/hatchet = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/knife/butcher = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item = 'sound/items/handling/surgery/scalpel1.ogg',
	)
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	surgery_effects_mood = TRUE

/datum/surgery_step/saw/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to saw through the bone in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to saw through the bone in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to saw through the bone in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "You feel a horrid ache spread through the inside of your [target.parse_zone_with_bodypart(target_zone)]!")

/datum/surgery_step/saw/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !(tool.get_sharpness() && (tool.force >= 10)))
		return FALSE
	return TRUE

/datum/surgery_step/saw/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	target.apply_damage(50, BRUTE, "[target_zone]", wound_bonus=CANT_WOUND)
	display_results(
		user,
		target,
		span_notice("You saw [target]'s [target.parse_zone_with_bodypart(target_zone)] open."),
		span_notice("[user] saws [target]'s [target.parse_zone_with_bodypart(target_zone)] open!"),
		span_notice("[user] saws [target]'s [target.parse_zone_with_bodypart(target_zone)] open!"),
	)
	display_pain(target, "It feels like something just broke in your [target.parse_zone_with_bodypart(target_zone)]!")
	return ..()

//drill bone
/datum/surgery_step/drill
	name = "drill bone (surgical drill)"
	implements = list(
		TOOL_DRILL = 100,
		/obj/item/screwdriver/power = 80,
		/obj/item/pickaxe/drill = 60,
		TOOL_SCREWDRIVER = 25,
		/obj/item/kitchen/spoon = 20)
	time = 3 SECONDS

/datum/surgery_step/drill/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to drill into the bone in [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to drill into the bone in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] begins to drill into the bone in [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
	)
	display_pain(target, "You feel a horrible piercing pain in your [target.parse_zone_with_bodypart(target_zone)]!")

/datum/surgery_step/drill/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(
		user,
		target,
		span_notice("You drill into [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] drills into [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
		span_notice("[user] drills into [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
	)
	return ..()
