/obj/item/extinguisher/attack_obj(obj/O, mob/living/user)
	if(attempt_refill_hippie(O, user))
		refilling = TRUE
		return FALSE
	else
		return ..()

/obj/item/extinguisher/proc/attempt_refill_hippie(atom/target, mob/user)
	if(istype(target, /obj/structure/reagent_dispensers) && target.Adjacent(user))
		var/safety_save = safety
		safety = TRUE
		if(reagents.total_volume == reagents.maximum_volume)
			to_chat(user, "<span class='warning'>\The [src] is already full!</span>")
			safety = safety_save
			return 1
		var/obj/structure/reagent_dispensers/watertank/W = target
		var/transferred = W.reagents.trans_to(src, max_water)
		if(transferred > 0)
			to_chat(user, "<span class='notice'>\The [src] has been refilled by [transferred] units.</span>")
			playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
			for(var/datum/reagent/water/R in reagents.reagent_list)
				R.cooling_temperature = cooling_power
		else
			to_chat(user, "<span class='warning'>\The [W] is empty!</span>")
		safety = safety_save
		return 1
	else
		return 0