/////AUGMENTATION SURGERIES////// This one will only be used for head and chest (due to the way organsystem works,  you can't just remove and replace them)

//SURGERY STEPS

/datum/surgery_step/replace/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to sever the muscles on [target]'s [parse_zone(user.zone_sel.selecting)].", "<span class ='notice'>You begin to sever the muscles on [target]'s [parse_zone(user.zone_sel.selecting)]...</span>")

/datum/surgery_step/add_limb
	name = "add limb"
	implements = list(/obj/item/robot_parts = 100, /obj/item/organ/limb = 100)
	time = 32
	var/datum/organ/limb/L = null // L because "limb"
	var/obj/item/organ/LI = null	//This'll be the tool

/datum/surgery_step/add_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = target.getorgan(target_zone)
	if(isorgan(tool))
		LI = tool
	if(L && !L.exists() && (( LI && L.name == LI.hardpoint) || L.name == tool.icon_state))	//Borg limbs just happen to have the same strings as limb hardpoints
		user.visible_message("[user] begins to place [tool] in [target]'s [parse_zone(user.zone_sel.selecting)].", "<span class ='notice'>You begin to place [tool] in [target]'s [parse_zone(user.zone_sel.selecting)]...</span>")
	else
		user.visible_message("[user] looks for [target]'s [parse_zone(user.zone_sel.selecting)].", "<span class ='notice'>You look for [target]'s [parse_zone(user.zone_sel.selecting)]...</span>")

//ACTUAL SURGERIES

/datum/surgery/limb_transplant
	name = "limb transplant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/add_limb, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human)
	possible_locs = list("r_arm","l_arm","r_leg","l_leg","head")

/datum/surgery/limb_transplant/can_start(mob/user, mob/living/carbon/target, datum/organ/organdata)
	if(organdata && !organdata.exists())
		return 1
	else return 0

//SURGERY STEP SUCCESSES

/datum/surgery_step/add_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L && !L.exists())
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.drop_item()
			if(LI)
				if(LI.Insert(H))
					H.organs += LI
			else	//Robotic limb, time for SNOWFLAKE CODE
				var/obj/item/organ/limb/RL = null
				switch(target_zone)
					if("r_leg")
						RL = new /obj/item/organ/limb/r_leg/robot(src)
					if("l_leg")
						RL = new /obj/item/organ/limb/l_leg/robot(src)
					if("r_arm")
						RL = new /obj/item/organ/limb/r_arm/robot(src)
					if("l_arm")
						RL = new /obj/item/organ/limb/l_arm/robot(src)
					if("head")
						RL = new /obj/item/organ/limb/head/robot(src)
				H.organs += RL
				if(!RL.Insert(H))
					world << "Error inserting [RL] the [RL.type] in [RL.hardpoint]!"
					return -1
				qdel(tool)
			H.update_damage_overlays(0)
			H.update_body_parts() //Gives them the Cyber limb overlay
			user.visible_message("[user] successfully transplants [tool] to [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You successfully transplant [tool] to [target]'s [parse_zone(target_zone)].</span>")
			add_logs(user, target, "augmented", addition="by giving him new [parse_zone(target_zone)] INTENT: [uppertext(user.a_intent)]")
	else
		user << "<span class='warning'>[target] has no room for a [parse_zone(target_zone)] there!</span>"
	return 1