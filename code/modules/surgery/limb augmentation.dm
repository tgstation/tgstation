
/////AUGMENTATION SURGERIES//////


//SURGERY STEPS

/datum/surgery_step/replace
	name = "sever muscles"
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 32


/datum/surgery_step/replace/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to sever the muscles on [target]'s [parse_zone(user.zone_selected)].", "<span class ='notice'>You begin to sever the muscles on [target]'s [parse_zone(user.zone_selected)]...</span>")


/datum/surgery_step/add_limb
	name = "replace limb"
	implements = list(/obj/item/robot_parts = 100)
	time = 32
	var/obj/item/organ/limb/L = null // L because "limb"



/datum/surgery_step/add_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = surgery.organ
	if(L)
		user.visible_message("[user] begins to augment [target]'s [parse_zone(user.zone_selected)].", "<span class ='notice'>You begin to augment [target]'s [parse_zone(user.zone_selected)]...</span>")
	else
		user.visible_message("[user] looks for [target]'s [parse_zone(user.zone_selected)].", "<span class ='notice'>You look for [target]'s [parse_zone(user.zone_selected)]...</span>")



//ACTUAL SURGERIES

/datum/surgery/augmentation
	name = "augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/saw, /datum/surgery_step/add_limb)
	species = list(/mob/living/carbon/human)
	possible_locs = list("r_arm","l_arm","r_leg","l_leg","chest","head")


//SURGERY STEP SUCCESSES

/datum/surgery_step/add_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.visible_message("[user] successfully augments [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You successfully augment [target]'s [parse_zone(target_zone)].</span>")
			L.loc = get_turf(target)
			H.organs -= L
			switch(target_zone)
				if("r_leg")
					H.organs += new /obj/item/organ/limb/robot/r_leg(src)
				if("l_leg")
					H.organs += new /obj/item/organ/limb/robot/l_leg(src)
				if("r_arm")
					H.organs += new /obj/item/organ/limb/robot/r_arm(src)
				if("l_arm")
					H.organs += new /obj/item/organ/limb/robot/l_arm(src)
				if("head")
					H.organs += new /obj/item/organ/limb/robot/head(src)
				if("chest")
					H.organs += new /obj/item/organ/limb/robot/chest(src)
			user.drop_item()
			qdel(tool)
			H.update_damage_overlays(0)
			H.update_augments() //Gives them the Cyber limb overlay
			H.updatehealth()
			add_logs(user, target, "augmented", addition="by giving him new [parse_zone(target_zone)] INTENT: [uppertext(user.a_intent)]")
	else
		user << "<span class='warning'>[target] has no organic [parse_zone(target_zone)] there!</span>"
	return 1


/datum/surgery/chainsaw
	name = "chainsaw augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/incise, /datum/surgery_step/chainsaw)
	species = list(/mob/living/carbon/human)
	possible_locs = list("r_arm", "l_arm")
	requires_organic_bodypart = 0


/datum/surgery_step/chainsaw
	time = 64
	name = "insert chainsaw"
	implements = list(/obj/item/weapon/twohanded/required/chainsaw = 100)

/datum/surgery_step/chainsaw/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to install the chainsaw onto [target].", "<span class='notice'>You begin to install the chainsaw onto [target]...</span>")

/datum/surgery_step/chainsaw/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.l_hand && target.r_hand)
		user << "<span class='warning'>You can't fit the chainsaw in while [target]'s hands are full!</span>"
		return 0
	else
		user.visible_message("[user] finishes installing the chainsaw!", "<span class='notice'>You install the chainsaw.</span>")
		user.unEquip(tool)
		qdel(tool)
		var/obj/item/weapon/mounted_chainsaw/sawarms = new(target)
		target.put_in_hands(sawarms)

		return 1

/datum/surgery/chainsaw_removal
	name = "chainsaw removal"
	steps = list(/datum/surgery_step/chainsaw_removal)
	species = list(/mob/living/carbon/human)
	possible_locs = list("r_arm", "l_arm")
	requires_organic_bodypart = 0

/datum/surgery/chainsaw_removal/can_start(mob/user, mob/living/carbon/target)
	var/list/hands = get_both_hands(target)
	var/M = locate(/obj/item/weapon/mounted_chainsaw) in hands
	if(M)
		return 1//can continue surgery
	else
		return 0//surgery will never be available

/datum/surgery_step/chainsaw_removal
	time = 128
	name = "saw off chainsaw"
	implements = list(/obj/item/weapon/circular_saw = 100, /obj/item/weapon/melee/energy/sword/cyborg/saw = 100, /obj/item/weapon/melee/arm_blade = 75, /obj/item/weapon/mounted_chainsaw = 65, /obj/item/weapon/twohanded/fireaxe = 50, /obj/item/weapon/twohanded/required/chainsaw = 50, /obj/item/weapon/hatchet = 35, /obj/item/weapon/kitchen/knife/butcher = 25)

/datum/surgery_step/chainsaw_removal/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins sawing the chainsaw off of [target]'s arms.", "<span class='notice'>You begin removing [target]'s chainsaw...</span>")

/datum/surgery_step/chainsaw_removal/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/list/hands = get_both_hands(target)
	for(var/obj/item/weapon/mounted_chainsaw/V in hands)
		qdel(V)
		new /obj/item/weapon/twohanded/required/chainsaw(get_turf(target))
		user.visible_message("[user] carefully saws [target]'s arm free of the chainsaw.", "<span class='notice'>You remove the chainsaw.</span>")
		return 1
