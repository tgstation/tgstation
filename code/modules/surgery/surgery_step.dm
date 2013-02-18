/datum/surgery_step
	var/list/implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/kitchenknife = 65, /obj/item/weapon/shard = 45)
	var/time = 10
	var/always_advance = 0	//if the user should be able to retry when they fail, or if it should continue to the next step.


/datum/surgery_step/proc/try_op(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(tool.type in implements)
		if(target_zone == surgery.location)
			if(get_location_accessible(target, target_zone))
				initiate(user, target, target_zone, tool, surgery)
				return 1
			else
				user << "<span class='notice'>You need to expose [target]'s [target_zone] to perform surgery on it!</span>"
				return 1	//returns 1 so we don't stab the guy in the dick or wherever.
	return 0


/datum/surgery_step/proc/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	surgery.step_in_progress = 1

	preop(user, target, target_zone, tool)
	if(do_after(user, time))

		var/advance = 0
		var/prob_chance = implements[tool.type]
		prob_chance *= get_location_modifier(target)

		if(prob(prob_chance))
			success(user, target, target_zone, tool, surgery)
			advance = 1
		else
			failure(user, target, target_zone, tool, surgery)

		if(advance || always_advance)
			surgery.status++
			if(surgery.status > surgery.steps.len)
				surgery.complete(target)

	surgery.step_in_progress = 0


/datum/surgery_step/proc/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to perform surgery on [target].</span>")


/datum/surgery_step/proc/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] succeeds!</span>")


/datum/surgery_step/proc/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user] screws up!</span>")