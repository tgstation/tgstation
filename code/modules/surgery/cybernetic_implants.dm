//Handled in organ_manipulation.dm

/datum/surgery_step/organ/internal/cyberimp/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/organ/internal/cyberimp/implant, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to implant [target] with [implant].</span>")

//[[[[EYES]]]]
/datum/surgery/organ/internal/cyberimp/eyes
	name = "eye cybernetic implant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/organ/internal/cyberimp/eyes, /datum/surgery_step/fix_eyes, /datum/surgery_step/close)
	possible_locs = list("eyes")

/datum/surgery_step/organ/internal/cyberimp/eyes
	name = "insert eye cybernetic implant"
	implements = list(/obj/item/organ/internal/cyberimp/eyes = 100)
	time = 32

/datum/surgery_step/organ/internal/cyberimp/eyes/success(mob/user, mob/living/carbon/target, target_zone, obj/item/organ/internal/cyberimp/eyes/implant, datum/surgery/surgery)
	if(implant)
		var/full = 0
		if(locate(/obj/item/organ/internal/cyberimp/eyes,target.internal_organs))
			full = 1
		insert(user,target,implant,target_zone,full)
		return 1

//[[[[BRAIN]]]]
/datum/surgery/organ/internal/cyberimp/brain
	name = "brain cybernetic implant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/organ/internal/cyberimp/brain, /datum/surgery_step/close)
	possible_locs = list("head")

/datum/surgery_step/organ/internal/cyberimp/brain
	name = "insert brain cybernetic implant"
	implements = list(/obj/item/organ/internal/cyberimp/brain = 100)
	time = 32

/datum/surgery_step/organ/internal/cyberimp/brain/success(mob/user, mob/living/carbon/target, target_zone, obj/item/organ/internal/cyberimp/brain/implant, datum/surgery/surgery)
	if(implant)
		var/full = 0
		for(var/obj/item/I in target.internal_organs)
			if(istype(I,/obj/item/organ/internal/cyberimp/brain))
				full++

		if(full < MAX_BRAIN_IMPLANT)
			full = 0
		insert(user,target,implant,target_zone,full)
		return 1

//[[[[CHEST]]]]

/datum/surgery/organ/internal/cyberimp/chest
	name = "torso cybernetic implant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/organ/internal/cyberimp/chest, /datum/surgery_step/close)
	possible_locs = list("chest")

/datum/surgery_step/organ/internal/cyberimp/chest
	name = "insert torso cybernetic implant"
	implements = list(/obj/item/organ/internal/cyberimp/chest = 100)
	time = 32

/datum/surgery_step/organ/internal/cyberimp/chest/success(mob/user, mob/living/carbon/target, target_zone, obj/item/organ/internal/cyberimp/chest/implant, datum/surgery/surgery)
	if(implant)
		var/full = 0
		for(var/obj/item/I in target.internal_organs)
			if(istype(I,/obj/item/organ/internal/cyberimp/chest))
				full++
		if(full < MAX_CHEST_IMPLANT)
			full = 0

		if(istype(implant,/obj/item/organ/internal/cyberimp/chest))
			if(locate(/obj/item/organ/internal/cyberimp/chest) in target.internal_organs)
				full = 1

		insert(user,target,implant,target_zone,full)
		return 1

/datum/surgery_step/organ/internal/cyberimp/proc/insert(mob/user, mob/living/carbon/target, obj/item/organ/internal/cyberimp/implant,target_zone,full)
	if(full)
		user.visible_message("<span class='notice'>[user] can't seem to implant anything else into the [target]'s [target_zone].</span>")
	else
		user.visible_message("<span class='notice'>[user] inserts [implant] into the [target]'s [target_zone == "head" ? "brain" : target_zone]!</span>")
		user.drop_item()
		implant.Insert(target)