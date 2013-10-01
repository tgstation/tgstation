
/////LIMB REMOVAL SURGERY//////
//This is a First Pass, it is designed to get the job done, I or someone else can clean it later
//RobRichards

//CONTENTS:
//'Replace sugery steps'
//'Add surgery steps'

//Somethings are named odd, "Replace" for example

//You may also notice a distinct lack of any organs, this surgery relies on the augmented variable in human_defines to do things, not an organ system


/datum/surgery/arm_replace
	name = "arm augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/replace_arm, /datum/surgery_step/add_arm)
	species = list(/mob/living/carbon/human)
	location = "r_arm"

/datum/surgery_step/replace_arm
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 32

/datum/surgery_step/add_arm
	implements = list(/obj/item/robot_parts/l_arm = 100, /obj/item/robot_parts/r_arm = 100) //This may seem weird but its so both arm types work.
	time = 32



/datum/surgery_step/add_arm/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] successfully augments [target]'s arms!</span>")
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.augmented_arms = 1 //"I never asked for this"
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


/datum/surgery_step/replace_leg
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 32



/datum/surgery_step/add_leg/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] successfully augments [target]'s legs!</span>")
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.augmented_legs = 1 //"I never asked for this"
		H.update_body() //Gives them the Cyber limb overlay
	user.attack_log += "\[[time_stamp()]\]<font color='red'> Augmented [target.name] ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
	target.attack_log += "\[[time_stamp()]\]<font color='orange'> Augmented by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
	log_attack("<font color='red'>[user.name] ([user.ckey]) augmented [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")



