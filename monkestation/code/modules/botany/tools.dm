/obj/item/shovel/spade/pre_attack(atom/A, mob/living/user, params)
	if(A.GetComponent(/datum/component/plant_growing))
		if(!do_after(user, 3 SECONDS, A))
			return ..()
		SEND_SIGNAL(A, COMSIG_PLANTER_REMOVE_PLANTS)
		return TRUE
	. = ..()

/obj/item/cultivator/pre_attack(atom/A, mob/living/user, params)
	if(SEND_SIGNAL(A, COMSIG_GROWING_ADJUST_WEED, -10))
		user.visible_message(span_notice("[user] uproots the weeds."), span_notice("You remove the weeds from [src]."))
		return TRUE
	. = ..()

/obj/item/secateurs/pre_attack(atom/A, mob/living/user, params)
	if(SEND_SIGNAL(A, COMSIG_GROWING_TRY_SECATEUR, user))
		return TRUE
	. = ..()

/obj/item/graft/pre_attack(atom/A, mob/living/user, params)
	if(SEND_SIGNAL(A, COMSIG_GROWER_TRY_GRAFT, user, src))
		return TRUE
	. = ..()

/obj/item/bio_cube/pre_attack(atom/A, mob/living/user, params)
	if(SEND_SIGNAL(A, COMSIG_ATTEMPT_BIOBOOST, total_duration))
		qdel(src)
		return TRUE
	. = ..()
