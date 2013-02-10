/datum/surgery_step
	var/list/implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/kitchenknife = 65, /obj/item/weapon/shard = 45)
	var/time = 10


/datum/surgery_step/proc/try_op(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(tool.type in implements)
		if(target_zone == surgery.location)
			initiate(user, target, target_zone, tool, surgery)
			return 1
	return 0


/datum/surgery_step/proc/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	preop(user, target, target_zone, tool)
	if(do_after(user, time))
		var/prob_chance = implements[tool.type]
		if(prob(prob_chance))
			success(user, target, target_zone, tool, surgery)
			surgery.status++
			if(surgery.status > surgery.steps.len)
				surgery.complete(target)
		else
			failure(user, target, target_zone, tool, surgery)


/datum/surgery_step/proc/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to perform surgery on [target].</span>")


/datum/surgery_step/proc/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] succeeds!</span>")


/datum/surgery_step/proc/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user] screws up!</span>")