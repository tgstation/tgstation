
/////AUGMENTATION SURGERIES//////


//SURGERY STEPS

/datum/surgery_step/replace
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 32


/datum/surgery_step/replace/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class ='notice'>[user] begins to sever the muscles on [target]'s [target_zone]!</span>")


/datum/surgery_step/add_limb
	implements = list(/obj/item/robot_parts = 100)
	time = 32
	var/obj/item/organ/limb/L = null // L because "limb"


/datum/surgery_step/add_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)

	if(user.zone_sel.selecting == "r_arm") //Yes all this is Necessary, if I use L = target.getlimb(user.zone_sel.selecting) then the game loses track of the Limb due to user.zone_sel.selecting not being a typepath - RR
		L = target.getlimb(/obj/item/organ/limb/r_arm)
	if(user.zone_sel.selecting == "l_arm")
		L = target.getlimb(/obj/item/organ/limb/l_arm)
	if(user.zone_sel.selecting == "r_leg")
		L = target.getlimb(/obj/item/organ/limb/r_leg)
	if(user.zone_sel.selecting == "l_leg")
		L = target.getlimb(/obj/item/organ/limb/l_leg)
	if(user.zone_sel.selecting == "head")
		L = target.getlimb(/obj/item/organ/limb/head)
	if(user.zone_sel.selecting == "chest")
		L = target.getlimb(/obj/item/organ/limb/chest)
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to augment [target]'s [target_zone].</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s [target_zone].</span>")



//ACTUAL SURGERIES

/datum/surgery/augmentation
	name = "augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/saw, /datum/surgery_step/add_limb)
	species = list(/mob/living/carbon/human)
	location = "anywhere" //Check attempt_initate_surgery() (in code/modules/surgery/helpers) to see what this does if you can't tell

//SURGERY STEP SUCCESSES

/datum/surgery_step/add_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.visible_message("<span class='notice'>[user] successfully augments [target]'s [target_zone]!</span>")
			L.loc = get_turf(target)
			H.organs -= L
			if(user.zone_sel.selecting == "r_leg") //for the surgery to progress this MUST still be the original "location" so it's safe to do this.
				H.organs += new /obj/item/organ/limb/robot/r_leg(src)
			if(user.zone_sel.selecting == "r_arm")
				H.organs += new /obj/item/organ/limb/robot/r_arm(src)
			if(user.zone_sel.selecting == "l_leg")
				H.organs += new /obj/item/organ/limb/robot/l_leg(src)
			if(user.zone_sel.selecting == "l_arm")
				H.organs += new /obj/item/organ/limb/robot/l_arm(src)
			if(user.zone_sel.selecting == "head")
				H.organs += new /obj/item/organ/limb/robot/head(src)
			if(user.zone_sel.selecting == "chest")
				H.organs += new /obj/item/organ/limb/robot/chest(src)
			user.drop_item()
			del(tool)
			H.update_damage_overlays(0) //Remove the gaping hole in what used to be his old limb but is now his Cyber limb.
			H.update_augments() //Gives them the Cyber limb overlay
			user.attack_log += "\[[time_stamp()]\]<font color='red'> Augmented [target.name]'s [target_zone] ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
			target.attack_log += "\[[time_stamp()]\]<font color='orange'> Augmented by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
			log_attack("<font color='red'>[user.name] ([user.ckey]) augmented [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
	else
		user.visible_message("<span class='notice'>[user] [target] has no organic [target_zone] there!</span>")
	return 1
