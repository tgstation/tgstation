/datum/surgery/xenodetail
	name = "xeno deveining"
	steps = list(/datum/surgery_step/alien/armor_check, /datum/surgery_step/alien/saw, /datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/incise, /datum/surgery_step/extract_xenotail, /datum/surgery_step/close)
	species = list(/mob/living/carbon/alien/humanoid)
	location = "groin"


//Got to check if xeno's armor is up


/datum/surgery_step/extract_xenotail
	implements = list(/obj/item/weapon/hemostat = 100, /obj/item/weapon/crowbar = 55)
	time = 64
	var/obj/item/organ/avein/A = null

/datum/surgery_step/extract_xenotail/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	A = locate() in target.internal_organs
	if(A)
		user.visible_message("<span class='notice'>[user] begins to extract [target]'s tail vein.</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for a tail vein in [target].</span>")

/datum/surgery_step/extract_xenotail/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(A)
		user.visible_message("<span class='notice'>[user] successfully removes [target]'s tail vein!</span>")
		A.loc = get_turf(target)
		target.internal_organs -= A
		var/mob/living/carbon/alien/humanoid/B = target
		B.verbs.Remove(/mob/living/carbon/alien/humanoid/proc/resin,/mob/living/carbon/alien/humanoid/proc/corrosive_acid,
			/mob/living/carbon/alien/humanoid/proc/neurotoxin,/mob/living/carbon/alien/humanoid/verb/transfer_plasma,
			/mob/living/carbon/alien/humanoid/verb/plant,/mob/living/carbon/alien/humanoid/drone/verb/evolve)
	else
		user.visible_message("<span class='notice'>[user] can't find a tail vein in [target]!</span>")
	return 1