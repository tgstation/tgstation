
/////AUGMENTATION SURGERIES//////

//try to keep this up to date for sanity's sake.

//File last updated:
// 05/10/2013 - By RobRichards


//SURGERY STEPS

/datum/surgery_step/replace
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 32

/datum/surgery_step/replace/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class ='notice'>[user] begins to sever the muscles on [target]'s [target_zone]!</span>")

//LEG STEPS

/datum/surgery_step/add_leg_r
	implements = list(/obj/item/robot_parts/r_leg = 100) //This is so you can't add a left leg where a right leg should go, it's fluff.
	time = 32
	var/obj/item/organ/limb/r_leg/L = null // L because "limb"

/datum/surgery_step/add_leg_r/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = target.getlimb(/obj/item/organ/limb/r_leg)
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to augment [target]'s right leg.</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s right leg.</span>")

/datum/surgery_step/add_leg_l
	implements = list(/obj/item/robot_parts/l_leg = 100) //This is so you can't add a left leg where a right leg should go, it's fluff.
	time = 32
	var/obj/item/organ/limb/l_leg/L = null // L because "limb"

/datum/surgery_step/add_leg_l/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = target.getlimb(/obj/item/organ/limb/l_leg)
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to augment [target]'s left leg.</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s left leg.</span>")

//ARM STEPS

/datum/surgery_step/add_arm_r
	implements = list(/obj/item/robot_parts/r_arm = 100) //This is so you can't add a left leg where a right leg should go, it's fluff.
	time = 32
	var/obj/item/organ/limb/r_arm/L = null // L because "limb"

/datum/surgery_step/add_arm_r/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = target.getlimb(/obj/item/organ/limb/r_arm)
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to augment [target]'s right arm.</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s right arm.</span>")

/datum/surgery_step/add_arm_l
	implements = list(/obj/item/robot_parts/l_arm = 100) //This is so you can't add a left leg where a right leg should go, it's fluff.
	time = 32
	var/obj/item/organ/limb/l_arm/L = null // L because "limb"

/datum/surgery_step/add_arm_l/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = target.getlimb(/obj/item/organ/limb/l_arm)
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to augment [target]'s left arm.</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s left arm.</span>")

//OTHER STEPS - Head, Chest

/datum/surgery_step/add_chest
	implements = list(/obj/item/robot_parts/chest = 100)
	time = 32
	var/obj/item/organ/limb/chest/L = null // L because "limb"

/datum/surgery_step/add_chest/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = target.getlimb(/obj/item/organ/limb/chest)
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to augment [target]'s chest.</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s chest.</span>")

/datum/surgery_step/add_head //I'm not even sure 'Head' should be an organ without MEGA issues everywhere
	implements = list(/obj/item/robot_parts/head = 100)
	time = 32
	var/obj/item/organ/limb/head/L = null // L because "limb"

/datum/surgery_step/add_head/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = target.getlimb(/obj/item/organ/limb/head)
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to augment [target]'s head.</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s head.</span>")

//ACTUAL SURGERIES

/datum/surgery/leg_replace_r
	name = "augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/saw, /datum/surgery_step/add_leg_r)
	species = list(/mob/living/carbon/human)
	location = "r_leg"

/datum/surgery/leg_replace_l
	name = "augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/saw, /datum/surgery_step/add_leg_l)
	species = list(/mob/living/carbon/human)
	location = "l_leg"

/datum/surgery/arm_replace_r
	name = "augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/saw, /datum/surgery_step/add_arm_r)
	species = list(/mob/living/carbon/human)
	location = "r_arm"

/datum/surgery/arm_replace_l
	name = "augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/saw, /datum/surgery_step/add_arm_l)
	species = list(/mob/living/carbon/human)
	location = "l_arm"

/datum/surgery/chest_replace //Don't ask how you can remove someone's chest without killing them
	name = "augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/saw, /datum/surgery_step/add_chest)
	species = list(/mob/living/carbon/human)
	location = "chest"

/datum/surgery/chest_replace //Still not sure about Head replacements...
	name = "augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/saw, /datum/surgery_step/add_head)
	species = list(/mob/living/carbon/human)
	location = "head"

//SURGERY STEP SUCCESSES

/datum/surgery_step/add_leg_r/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.visible_message("<span class='notice'>[user] successfully augments [target]'s right leg!</span>")
			L.loc = get_turf(target)
			H.organs -= L
			H.organs += new /obj/item/organ/limb/r_leg/robot(src)
			H.update_damage_overlays(0) //Remove the gaping hole in what used to be his old limb but is now his Cyber limb, (Comment this out and perform sugery to see what I mean)
			H.update_body() //Gives them the Cyber limb overlay
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Augmented [target.name]'s right leg ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> Augmented by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) augmented [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
	else
		user.visible_message("<span class='notice'>[user] [target] has no organic right leg there!</span>")
	return 1

/datum/surgery_step/add_leg_l/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.visible_message("<span class='notice'>[user] successfully augments [target]'s left leg!</span>")
			L.loc = get_turf(target)
			H.organs -= L
			H.organs += new /obj/item/organ/limb/l_leg/robot(src)
			H.update_damage_overlays(0) //Remove the gaping hole in what used to be his old limb but is now his Cyber limb, (Comment this out and perform sugery to see what I mean)
			H.update_body() //Gives them the Cyber limb overlay
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Augmented [target.name]'s left leg ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> Augmented by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) augmented [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
	else
		user.visible_message("<span class='notice'>[user] [target] has no organic left leg there!</span>")
	return 1

/datum/surgery_step/add_arm_r/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.visible_message("<span class='notice'>[user] successfully augments [target]'s right arm!</span>")
			L.loc = get_turf(target)
			H.organs -= L
			H.organs += new /obj/item/organ/limb/r_arm/robot(src)
			H.update_damage_overlays(0) //Remove the gaping hole in what used to be his old limb but is now his Cyber limb, (Comment this out and perform sugery to see what I mean)
			H.update_body() //Gives them the Cyber limb overlay
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Augmented [target.name]'s right arm ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> Augmented by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) augmented [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
	else
		user.visible_message("<span class='notice'>[user] [target] has no organic right arm there!</span>")
	return 1

/datum/surgery_step/add_arm_l/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.visible_message("<span class='notice'>[user] successfully augments [target]'s left arm!</span>")
			L.loc = get_turf(target)
			H.organs -= L
			H.organs += new /obj/item/organ/limb/l_arm/robot(src)
			H.update_damage_overlays(0) //Remove the gaping hole in what used to be his old limb but is now his Cyber limb, (Comment this out and perform sugery to see what I mean)
			H.update_body() //Gives them the Cyber limb overlay
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Augmented [target.name]'s left arm ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> Augmented by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) augmented [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
	else
		user.visible_message("<span class='notice'>[user] [target] has no organic left arm there!</span>")
	return 1

/datum/surgery_step/add_chest/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.visible_message("<span class='notice'>[user] successfully augments [target]'s chest!</span>")
			L.loc = get_turf(target)
			H.organs -= L
			H.organs += new /obj/item/organ/limb/chest/robot(src)
			H.update_damage_overlays(0) //Remove the gaping hole in what used to be his old limb but is now his Cyber limb, (Comment this out and perform sugery to see what I mean)
			H.update_body() //Gives them the Cyber limb overlay
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Augmented [target.name]'s chest ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> Augmented by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) augmented [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
	else
		user.visible_message("<span class='notice'>[user] [target] has no organic chest there!</span>")
	return 1

/datum/surgery_step/add_head/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.visible_message("<span class='notice'>[user] successfully augments [target]'s head!</span>")
			L.loc = get_turf(target)
			H.organs -= L
			H.organs += new /obj/item/organ/limb/head/robot(src)
			H.update_damage_overlays(0) //Remove the gaping hole in what used to be his old limb but is now his Cyber limb, (Comment this out and perform sugery to see what I mean)
			H.update_body() //Gives them the Cyber limb overlay
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Augmented [target.name]'s head ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> Augmented by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) augmented [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
	else
		user.visible_message("<span class='notice'>[user] [target] has no organic head there!</span>")
	return 1

