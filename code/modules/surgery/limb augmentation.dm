
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
		var/obj/item/robot_parts/RP = tool
		if(!istype(RP))
			user << "<span class='warning'>That's not a robotic limb!</span>"
			return 0
		if(RP.body_part != L.body_part)
			user << "<span class='warning'>That is the wrong robotic limb for this body part!</span>"
			return 0

		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/turf/Hloc = get_turf(H)
			user.visible_message("[user] successfully augments [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You successfully augment [target]'s [parse_zone(target_zone)].</span>")
			var/obj/item/organ/limb/dummy = new L.type (Hloc)
			dummy.copy_organ(L)
			dummy.embedded_objects.Cut()

			//Deliberately after the copy_organ call, so flesh limbs don't drop robot ones
			L.status = ORGAN_ROBOTIC
			L.augment_icon = RP.augment_icon
			L.augment_icon_state = RP.augment_icon_state
			//It's a "new" limb, so heal it
			L.heal_damage(999, 999, 1)
			for(var/obj/item/I in L.embedded_objects)
				L.embedded_objects -= I
				I.loc = Hloc

			if(L.body_part == CHEST)
				var/datum/surgery_step/xenomorph_removal/xeno_removal = new
				xeno_removal.remove_xeno(user, target)
				for(var/datum/disease/appendicitis/A in H.viruses)
					A.cure(1)

			user.drop_item()
			qdel(tool)
			H.update_damage_overlays(0)
			H.update_augments()
			add_logs(user, target, "augmented", addition="by giving him new [parse_zone(target_zone)] INTENT: [uppertext(user.a_intent)]")
	else
		user << "<span class='warning'>[target] has no organic [parse_zone(target_zone)] there!</span>"
	return 1
