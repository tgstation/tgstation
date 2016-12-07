
/datum/surgery/amputation
	name = "amputation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/sever_limb)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list("r_arm", "l_arm", "l_leg", "r_leg", "head")
	requires_organic_bodypart = 0


/datum/surgery_step/sever_limb
	name = "sever limb"
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/circular_saw = 100, /obj/item/weapon/melee/energy/sword/cyborg/saw = 100, /obj/item/weapon/melee/arm_blade = 80, /obj/item/weapon/twohanded/required/chainsaw = 80, /obj/item/weapon/mounted_chainsaw = 80, /obj/item/weapon/twohanded/fireaxe = 50, /obj/item/weapon/hatchet = 40, /obj/item/weapon/kitchen/knife/butcher = 25)
	time = 64

/datum/surgery_step/sever_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to sever [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You begin to sever [target]'s [parse_zone(target_zone)]...</span>")

/datum/surgery_step/sever_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/L = target
	user.visible_message("[user] severs [L]'s [parse_zone(target_zone)]!", "<span class='notice'>You sever [L]'s [parse_zone(target_zone)].</span>")
	if(surgery.operated_bodypart)
		surgery.operated_bodypart.drop_limb()
	return 1