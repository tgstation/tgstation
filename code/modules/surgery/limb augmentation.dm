
/////AUGMENTATION SURGERIES//////


//SURGERY STEPS

/datum/surgery_step/replace
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 32


/datum/surgery_step/replace/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to sever the muscles on [target]'s [parse_zone(user.zone_sel.selecting)].", "<span class ='notice'>You begin to sever the muscles on [target]'s [parse_zone(user.zone_sel.selecting)]...</span>")


/datum/surgery_step/add_limb
	implements = list(/obj/item/robot_parts = 100)
	time = 32
	var/obj/item/organ/limb/L = null // L because "limb"
	allowed_organs = list("r_arm","l_arm","r_leg","l_leg","chest","head")



/datum/surgery_step/add_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = new_organ
	if(L)
		user.visible_message("[user] begins to augment [target]'s [parse_zone(user.zone_sel.selecting)].", "<span class ='notice'>You begin to augment [target]'s [parse_zone(user.zone_sel.selecting)]...</span>")
	else
		user.visible_message("[user] looks for [target]'s [parse_zone(user.zone_sel.selecting)].", "<span class ='notice'>You look for [target]'s [parse_zone(user.zone_sel.selecting)]...</span>")



//ACTUAL SURGERIES

/datum/surgery/augmentation
	name = "augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace, /datum/surgery_step/saw, /datum/surgery_step/add_limb)
	species = list(/mob/living/carbon/human)
	location = "anywhere" //Check attempt_initate_surgery() (in code/modules/surgery/helpers) to see what this does if you can't tell
	has_multi_loc = 1 //Multi location stuff, See multiple_location_example.dm


//SURGERY STEP SUCCESSES

/datum/surgery_step/add_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			switch(L.body_part)
				if(CHEST)
					if(!istype(tool,/obj/item/robot_parts/chest))
						user << "<span class='warning'>That is the wrong robotic limb for this body part.</span>"
						return 0
				if(HEAD)
					if(!istype(tool,/obj/item/robot_parts/head))
						user << "<span class='warning'>That is the wrong robotic limb for this body part.</span>"
						return 0
				if(ARM_LEFT)
					if(!istype(tool,/obj/item/robot_parts/l_arm))
						user << "<span class='warning'>That is the wrong robotic limb for this body part.</span>"
						return 0
				if(ARM_RIGHT)
					if(!istype(tool,/obj/item/robot_parts/r_arm))
						user << "<span class='warning'>That is the wrong robotic limb for this body part.</span>"
						return 0
				if(LEG_LEFT)
					if(!istype(tool,/obj/item/robot_parts/l_leg))
						user << "<span class='warning'>That is the wrong robotic limb for this body part.</span>"
						return 0
				if(LEG_RIGHT)
					if(!istype(tool,/obj/item/robot_parts/r_leg))
						user << "<span class='warning'>That is the wrong robotic limb for this body part.</span>"
						return 0

			if(!user.drop_item())
				return 0
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
					var/datum/surgery_step/xenomorph_removal/xeno_removal = new
					xeno_removal.remove_xeno(user, target) // remove an alien if there is one
					H.organs += new /obj/item/organ/limb/robot/chest(src)
					for(var/datum/disease/appendicitis/A in H.viruses) //If they already have Appendicitis, Remove it
						A.cure(1)
			qdel(tool)
			H.update_damage_overlays(0)
			H.update_augments() //Gives them the Cyber limb overlay
			add_logs(user, target, "augmented", addition="by giving him new [parse_zone(target_zone)] INTENT: [uppertext(user.a_intent)]")
	else
		user << "<span class='warning'>[target] has no organic [parse_zone(target_zone)] there!</span>"
	return 1
