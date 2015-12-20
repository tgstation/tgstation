//Augment surgeries for replacable limbs. Also ghetto augments like chainsaw arms!

//SURGERY STEPS

/datum/surgery_step/replace/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to sever the muscles on [target]'s [parse_zone(user.zone_sel.selecting)].", "<span class ='notice'>You begin to sever the muscles on [target]'s [parse_zone(user.zone_sel.selecting)]...</span>")

/datum/surgery_step/add_limb
	name = "add limb"
	implements = list(/obj/item/robot_parts = 100, /obj/item/organ/limb = 100, /obj/item/weapon = 100)
	time = 32
	var/datum/organ/limb/L = null // L because "limb"
	var/obj/item/organ/limb/LI = null	//This'll be the tool
	var/success = 0

/datum/surgery_step/add_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = target.get_organ(target_zone)
	if(istype(tool, /obj/item/organ/limb))
		LI = tool
	if(check_validity(tool, target_zone))
		user.visible_message("[user] begins to place [tool] in [target]'s [parse_zone(user.zone_sel.selecting)].", "<span class ='notice'>You begin to place [tool] in [target]'s [parse_zone(user.zone_sel.selecting)]...</span>")
		success = 1
	else
		user.visible_message("[user] looks for [target]'s [parse_zone(user.zone_sel.selecting)].", "<span class ='notice'>You look for [target]'s [parse_zone(user.zone_sel.selecting)]...</span>")
		success = 0

/datum/surgery_step/add_limb/proc/check_validity(var/obj/item/tool, var/target_zone)
	if(!L.exists())
		if((LI && L.name == LI.hardpoint) || L.name == tool.icon_state) //Borg limbs' icon states just happen to have the same strings as limb hardpoints
			return 1
		if (target_zone == "r_arm" || "target_zone" == "l_arm")
			return(tool.is_valid_augment())	//For chainsaw arms and the like
	return 0


//ACTUAL SURGERIES

/datum/surgery/limb_transplant
	name = "limb transplant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/add_limb, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human)
	possible_locs = list("r_arm","l_arm","r_leg","l_leg","head")

/datum/surgery/limb_transplant/can_start(mob/user, mob/living/carbon/target, datum/organ/organdata)
	if(!organdata.exists())
		return 1
	else return 0

//SURGERY STEP SUCCESSES

/datum/surgery_step/add_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!L.exists() && success)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.drop_item()
			if(LI)
				LI.Insert(H)
			else if (istype(tool, /obj/item/robot_parts/))	//Robotic limb, time for SNOWFLAKE CODE
				var/obj/item/organ/limb/RL = null
				switch(target_zone)
					if("r_leg")
						RL = new /obj/item/organ/limb/leg/r_leg/robot(src)
					if("l_leg")
						RL = new /obj/item/organ/limb/leg/l_leg/robot(src)
					if("r_arm")
						RL = new /obj/item/organ/limb/arm/r_arm/robot(src)
					if("l_arm")
						RL = new /obj/item/organ/limb/arm/l_arm/robot(src)
					if("head")
						RL = new /obj/item/organ/limb/head/robot(src)
						RL.create_suborgan_slots()
				if(!RL.Insert(H))
					return -1
				qdel(tool)
			else if (tool.is_valid_augment())	//We're a ghetto aug
				var/obj/item/weapon/W = tool
				var/obj/item/weapon/ghettoaug = new W.augmenttype
				var/obj/item/organ/limb/newlimb = null
				switch(target_zone)
					if("r_arm")
						newlimb = new /obj/item/organ/limb/arm/r_arm/weapon(ghettoaug)
					if("l_arm")
						newlimb = new /obj/item/organ/limb/arm/l_arm/weapon(ghettoaug)
				if(!newlimb.Insert(H))
					return -1
				qdel(tool)
			H.update_damage_overlays(0)
			H.update_body_parts() //Gives them the Cyber limb overlay
			user.visible_message("[user] successfully transplants [tool] to [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You successfully transplant [tool] to [target]'s [parse_zone(target_zone)].</span>")
			add_logs(user, target, "augmented", addition="by giving him new [parse_zone(target_zone)] INTENT: [uppertext(user.a_intent)]")
			return 1
	user << "<span class='warning'>[target] has no room for a [tool] there!</span>"
	return 1