#define MAX_BRAIN_IMPLANT	2

/datum/surgery/eye_cybernetic_implant/eyes
	name = "eye cybernetic implant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/cybernetic_implant/eyes, /datum/surgery_step/fix_eyes, /datum/surgery_step/close)
	location = "eyes"

/datum/surgery/eye_cybernetic_implant/brain
	name = "brain cybernetic implant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/cybernetic_implant/brain, /datum/surgery_step/close)
	location = "head"

/datum/surgery_step/cybernetic_implant/eyes
	implements = list(/obj/item/cybernetic_implant/eyes = 100)
	time = 32

/datum/surgery_step/cybernetic_implant/brain
	implements = list(/obj/item/cybernetic_implant/brain = 100)
	time = 32

/datum/surgery_step/cybernetic_implant/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/cybernetic_implant/implant, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to implant [target] with [implant].</span>")

/datum/surgery_step/cybernetic_implant/eyes/success(mob/user, mob/living/carbon/target, target_zone, obj/item/cybernetic_implant/eyes/implant, datum/surgery/surgery)
	if(implant)
		var/full = 0
		if(locate(/obj/item/cybernetic_implant/eyes,target.internal_organs))
			full = 1

		insert(user,target,implant,target_zone,full)
		return 1

/datum/surgery_step/cybernetic_implant/brain/success(mob/user, mob/living/carbon/target, target_zone, obj/item/cybernetic_implant/brain/implant, datum/surgery/surgery)
	if(implant)
		var/full = 0
		for(var/obj/item/I in target.contents)
			if(istype(I,/obj/item/cybernetic_implant/brain))
				full++

		if(full < MAX_BRAIN_IMPLANT)
			full = 0

		insert(user,target,implant,target_zone,full)
		return 1


/datum/surgery_step/cybernetic_implant/proc/insert(mob/user, mob/living/carbon/target, obj/item/cybernetic_implant/implant,target_zone,full)
	if(full)
		user.visible_message("<span class='notice'>[user] can't seem to implant anything else into the [target]'s [target_zone].</span>")
	else
		user.visible_message("<span class='notice'>[user] inserts [implant] into the [target]'s [target_zone == "head" ? "brain" : target_zone]!</span>")
		implant.owner = target
		implant.function()
		user.drop_item()
		implant.loc = target
		target.internal_organs |= implant