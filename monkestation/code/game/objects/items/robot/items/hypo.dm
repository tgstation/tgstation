// Move all this code to its original file once tgstation/tgstation/pull/85441 is merged

#define REAGENT_CONTAINER_INTERNAL "internal_beaker"
#define REAGENT_CONTAINER_BEVAPPARATUS "beverage_apparatus"

/obj/item/reagent_containers/borghypo/borgshaker
	var/reagent_search_container = REAGENT_CONTAINER_BEVAPPARATUS

/obj/item/reagent_containers/borghypo/borgshaker/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/user = usr
	switch(action)
		if("reaction_lookup")
			if(!iscyborg(usr))
				return
			if (reagent_search_container == REAGENT_CONTAINER_BEVAPPARATUS)
				var/obj/item/borg/apparatus/beaker/service/beverage_apparatus = (locate() in user.model.modules) || (locate() in user.held_items)
				if (!isnull(beverage_apparatus) && !isnull(beverage_apparatus.stored))
					beverage_apparatus.stored.reagents.ui_interact(user)
			else if (reagent_search_container == REAGENT_CONTAINER_INTERNAL)
				var/obj/item/reagent_containers/cup/beaker/large/internal_beaker = (locate() in user.model.modules) || (locate() in user.held_items)
				if (!isnull(internal_beaker))
					internal_beaker.reagents.ui_interact(user)
		if ("set_preferred_container")
			reagent_search_container = params["value"]


/obj/item/reagent_containers/borghypo/borgshaker/ui_data(mob/user)
	. = ..()

	.["reagentSearchContainer"] = reagent_search_container

	if(iscyborg(user))
		var/mob/living/silicon/robot/cyborg = user
		var/obj/item/borg/apparatus/beaker/service/beverage_apparatus = (locate() in cyborg.model.modules) || (locate() in cyborg.held_items)

		if (isnull(beverage_apparatus))
			to_chat(user, span_warning("This unit has no beverage apparatus. This shouldn't be possible. Delete yourself, NOW!"))
			.["apparatusHasItem"] = FALSE
		else
			.["apparatusHasItem"] = !isnull(beverage_apparatus.stored)


#undef REAGENT_CONTAINER_INTERNAL
#undef REAGENT_CONTAINER_BEVAPPARATUS
