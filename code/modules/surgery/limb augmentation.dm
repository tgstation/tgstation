
/////AUGMENTATION SURGERIES//////
//Somethings are named odd, "Replace" for example
//No need in renaming them, they are only fluff surgery steps so you shouldn't ever need to touch them.

var/list/organs()

/*

/datum/surgery/arm_replace
	name = "arm augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/replace_arm, /datum/surgery_step/add_arm)
	species = list(/mob/living/carbon/human)
	location = "r_arm"

/datum/surgery_step/replace_arm
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 32


/datum/surgery_step/replace_arm/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class ='notice'>[user] begins to sever the muscles on [target]'s [target_zone]!</span>")



/datum/surgery_step/add_arm
	implements = list(/obj/item/robot_parts/l_arm = 100, /obj/item/robot_parts/r_arm = 100) //This may seem weird but its so both arm types work.
	time = 32

/datum/surgery_step/add_arm/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class ='notice'>[user] begins to attach the Cyber limb to [target]'s [target_zone] muscles!</span>")



/datum/surgery_step/add_arm/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] successfully augments [target]'s arms!</span>")
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.augmented_arms = 1 //"I never asked for this"
		H.apply_damage(-25,"brute","r_arm")
		H.update_damage_overlays() //Remove the gaping hole in what used to be his old arm but is now his Cyber limb, (Comment this out and perform sugery to see what I mean)
		H.update_body() //Gives them the Cyber limb overlay
	user.attack_log += "\[[time_stamp()]\]<font color='red'> Augmented [target.name] ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
	target.attack_log += "\[[time_stamp()]\]<font color='orange'> Augmented by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
	log_attack("<font color='red'>[user.name] ([user.ckey]) augmented [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")


/datum/surgery/leg_replace
	name = "leg augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/replace_leg, /datum/surgery_step/add_leg)
	species = list(/mob/living/carbon/human)
	location = "r_leg"

/datum/surgery_step/add_leg
	implements = list(/obj/item/robot_parts/l_leg = 100, /obj/item/robot_parts/r_leg = 100) //This may seem weird but its so both leg types work.
	time = 32

/datum/surgery_step/add_leg/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class ='notice'>[user] begins to attach the Cyber limb to [target]'s [target_zone] muscles!</span>")

*/
/datum/surgery_step/replace_leg
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 32

/datum/surgery_step/replace_leg/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class ='notice'>[user] begins to sever the muscles on [target]'s [target_zone]!</span>")

/*
/datum/surgery_step/add_leg/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] successfully augments [target]'s legs!</span>")
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.augmented_legs = 1 //"I never asked for this"
		H.apply_damage(-25,"brute","r_leg")
		H.update_damage_overlays() //Remove the gaping hole in what used to be his old arm but is now his Cyber limb, (Comment this out and perform sugery to see what I mean)
		H.update_body() //Gives them the Cyber limb overlay
	user.attack_log += "\[[time_stamp()]\]<font color='red'> Augmented [target.name] ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
	target.attack_log += "\[[time_stamp()]\]<font color='orange'> Augmented by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
	log_attack("<font color='red'>[user.name] ([user.ckey]) augmented [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
*/

//WIP// new shit, if things break, COMMENT IT ALL OUT AND USE THE ABOVE


/datum/surgery/leg_replace_r
	name = "right leg augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/replace_leg, /datum/surgery_step/add_leg_r)
	species = list(/mob/living/carbon/human)
	location = "r_leg"


/datum/surgery_step/add_leg_r
	implements = list(/obj/item/robot_parts/l_leg = 100, /obj/item/robot_parts/r_leg = 100) //This may seem weird but its so both leg types work.
	time = 32
	var/obj/item/organ/limb/r_leg/L = null // L because "limb"


/datum/surgery_step/add_leg_r/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = target.getorgan(/obj/item/organ/limb/r_leg)
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to augment [target]'s right leg.</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s right leg.</span>")


/*
/datum/surgery_step/add_leg_r/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		user.visible_message("<span class='notice'>[user] successfully augments [target]'s right leg!</span>")
		L.loc = get_turf(target)
		target.organs -= L
		target.organs += new /obj/item/organ/limb/r_leg/robot(src)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			H.apply_damage(-25,"brute","r_leg") //See below, also you shouldnt have "pain" in a limb you NO LONGER HAVE, Dammit!
			H.update_damage_overlays() //Remove the gaping hole in what used to be his old arm but is now his Cyber limb, (Comment this out and perform sugery to see what I mean)
			H.update_body() //Gives them the Cyber limb overlay
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Augmented [target.name]'s right leg ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> Augmented by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) augmented [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
	else
		user.visible_message("<span class='notice'>[user] [target] has no right leg there!</span>")
	return 1
*/

/datum/surgery_step/add_leg_r/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.visible_message("<span class='notice'>[user] successfully augments [target]'s right leg!</span>")
			L.loc = get_turf(target)
			H.organs -= L
			H.organs += new /obj/item/organ/limb/r_leg/robot(src)
			H.apply_damage(-25,"brute","r_leg") //See below, also you shouldnt have "pain" in a limb you NO LONGER HAVE, Dammit!
			H.update_damage_overlays() //Remove the gaping hole in what used to be his old arm but is now his Cyber limb, (Comment this out and perform sugery to see what I mean)
			H.update_body() //Gives them the Cyber limb overlay
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Augmented [target.name]'s right leg ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> Augmented by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) augmented [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
	else
		user.visible_message("<span class='notice'>[user] [target] has no right leg there!</span>")
	return 1