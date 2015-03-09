#define MAX_BRAIN_IMPLANT	2

/datum/surgery/eye_cybernetic_implant/eyes
	name = "eye cybernetic implant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/cybernetic_implant, /datum/surgery_step/fix_eyes, /datum/surgery_step/close)
	location = "eyes"

/datum/surgery/eye_cybernetic_implant/brain
	name = "brain cybernetic implant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/cybernetic_implant, /datum/surgery_step/close)
	location = "head"

/datum/surgery_step/cybernetic_implant
	implements = list(/obj/item/cybernetic_implant = 100)
	time = 32

/datum/surgery_step/cybernetic_implant/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/cybernetic_implant/implant, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to implant [target] with [implant].</span>")

/datum/surgery_step/cybernetic_implant/success(mob/user, mob/living/carbon/target, target_zone, obj/item/cybernetic_implant/implant, datum/surgery/surgery)
	if(implant)
		var/full = 0
		switch(target_zone)
			if("eyes")
				if(locate(/obj/item/cybernetic_implant/eyes,target.contents))
					full = 1
			if("head")
				var/count = 0
				for(var/obj/item/I in target.contents)
					if(istype(I,/obj/item/cybernetic_implant/brain))
						count++
				if(count >= MAX_BRAIN_IMPLANT)
					full = 1

		if(full)
			user.visible_message("<span class='notice'>[user] can't seem to implant anything else into the [target]'s [target_zone].</span>")
			return 1
		else
			user.visible_message("<span class='notice'>[user] inserts [implant] into the [target]'s [target_zone == "head" ? "brain" : target_zone]!</span>")
			implant.owner = target
			implant.function()
			user.drop_item()
			implant.loc = target
			return 1