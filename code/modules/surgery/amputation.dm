
/datum/surgery/amputation
	name = "Amputation"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_MORBID_CURIOSITY
	possible_locs = list(
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/sever_limb,
	)

/datum/surgery/amputation/mechanic
	name = "Disassemble"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/sever_limb/mechanic, //The benefit of being robotic; people can pull you apart in an instant! Wait, that's not a benefit...
	)

/datum/surgery/amputation/peg
	name = "Detach"
	requires_bodypart_type = BODYTYPE_PEG
	steps = list(
		/datum/surgery_step/sever_limb/peg,	//Easy come, easy go
	)

/datum/surgery/amputation/can_start(mob/user, mob/living/patient)
	if(HAS_TRAIT(patient, TRAIT_NODISMEMBER))
		return FALSE
	return ..()

/datum/surgery_step/sever_limb
	name = "sever limb (circular saw)"
	implements = list(
		/obj/item/shears = 300,
		TOOL_SCALPEL = 100,
		TOOL_SAW = 100,
		/obj/item/shovel/serrated = 75,
		/obj/item/melee/arm_blade = 80,
		/obj/item/fireaxe = 50,
		/obj/item/hatchet = 40,
		/obj/item/knife/butcher = 25,
	)
	time = 64
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	surgery_effects_mood = TRUE

/datum/surgery_step/sever_limb/mechanic
	name = "detach limb (wrench or crowbar)"
	implements = list(
		/obj/item/shovel/giant_wrench = 300,
		TOOL_WRENCH = 100,
		TOOL_CROWBAR = 100,
		TOOL_SCALPEL = 50,
		TOOL_SAW = 50,
	)
	time = 20 //WAIT I NEED THAT!!
	preop_sound = 'sound/items/tools/ratchet.ogg'
	preop_sound = 'sound/machines/airlock/doorclick.ogg'

/datum/surgery_step/sever_limb/peg
	name = "detach limb (circular saw)"
	implements = list(
		TOOL_SAW = 100,
		/obj/item/shovel/serrated = 100,
		/obj/item/fireaxe = 90,
		/obj/item/hatchet = 75,
		TOOL_SCALPEL = 25,
	)
	time = 30
	preop_sound = 'sound/items/handling/surgery/saw.ogg'
	success_sound = 'sound/items/handling/materials/wood_drop.ogg'

/datum/surgery_step/sever_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to sever [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
		span_notice("[user] begins to sever [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
		span_notice("[user] begins to sever [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
	)
	display_pain(target, "You feel a gruesome pain in your [parse_zone(target_zone)]'s joint!")


/datum/surgery_step/sever_limb/success(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(
		user,
		target,
		span_notice("You sever [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] severs [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
		span_notice("[user] severs [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
	)
	display_pain(target, "You can no longer feel your severed [target.parse_zone_with_bodypart(target_zone)]!")

	if(HAS_MIND_TRAIT(user, TRAIT_MORBID) && ishuman(user))
		var/mob/living/carbon/human/morbid_weirdo = user
		morbid_weirdo.add_mood_event("morbid_dismemberment", /datum/mood_event/morbid_dismemberment)

	if(surgery.operated_bodypart)
		var/obj/item/bodypart/target_limb = surgery.operated_bodypart
		target_limb.drop_limb()
	return ..()
