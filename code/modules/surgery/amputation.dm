
/datum/surgery/amputation
	name = "amputation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/sever_limb)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_HEAD)
	requires_bodypart_type = 0


/datum/surgery_step/sever_limb
	name = "sever limb"
	implements = list(/obj/item/scalpel = 100, /obj/item/circular_saw = 100, /obj/item/melee/transforming/energy/sword/cyborg/saw = 100, /obj/item/melee/arm_blade = 80, /obj/item/twohanded/required/chainsaw = 80, /obj/item/mounted_chainsaw = 80, /obj/item/twohanded/fireaxe = 50, /obj/item/hatchet = 40, /obj/item/kitchen/knife/butcher = 25)
	time = 64

/datum/surgery_step/sever_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to sever [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You begin to sever [target]'s [parse_zone(target_zone)]...</span>")

/datum/surgery_step/sever_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/L = target
	user.visible_message("[user] severs [L]'s [parse_zone(target_zone)]!", "<span class='notice'>You sever [L]'s [parse_zone(target_zone)].</span>")
	if(surgery.operated_bodypart)
		var/obj/item/bodypart/target_limb = surgery.operated_bodypart
		target_limb.drop_limb()

	return 1