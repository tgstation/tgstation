/mob/living/basic/pet/gondola/gondolapod
	name = "gondola"
	real_name = "gondola"
	desc = "The silent walker. This one seems to be part of a delivery agency."
	icon = 'icons/obj/supplypods.dmi'
	icon_state = "gondola"
	icon_living = "gondola"
	SET_BASE_PIXEL(-16, -5) //2x2 sprite
	layer = TABLE_LAYER //so that deliveries dont appear underneath it

	loot = list(
		/obj/effect/decal/cleanable/blood/gibs = 1,
		/obj/item/stack/sheet/animalhide/gondola = 2,
		/obj/item/food/meat/slab/gondola = 2,
	)

	///Boolean on whether the pod is currently open, and should appear such.
	var/opened = FALSE
	///The supply pod attached to the gondola, that actually holds the contents of our delivery.
	var/obj/structure/closet/supplypod/centcompod/linked_pod
	///Static list of actions the gondola is given on creation, and taken away when it successfully delivers.
	var/static/list/gondola_delivering_actions = list(
		/datum/action/innate/deliver_gondola_package,
		/datum/action/innate/check_gondola_contents,
	)

/mob/living/basic/pet/gondola/gondolapod/Initialize(mapload, pod)
	linked_pod = pod || new(src)
	name = linked_pod.name
	desc = linked_pod.desc
	if(!linked_pod.stay_after_drop || !linked_pod.opened)
		grant_actions_by_list(gondola_delivering_actions)
	return ..()

/mob/living/basic/pet/gondola/gondolapod/death()
	QDEL_NULL(linked_pod) //Will cause the open() proc for the linked supplypod to be called with the "broken" parameter set to true, meaning that it will dump its contents on death
	return ..()

/mob/living/basic/pet/gondola/gondolapod/create_gondola()
	return

/mob/living/basic/pet/gondola/gondolapod/update_overlays()
	. = ..()
	if(opened)
		. += "[icon_state]_open"

/mob/living/basic/pet/gondola/gondolapod/examine(mob/user)
	. = ..()
	if (contents.len)
		. += span_notice("It looks like it hasn't made its delivery yet.")
	else
		. += span_notice("It looks like it has already made its delivery.")

/mob/living/basic/pet/gondola/gondolapod/setOpened()
	opened = TRUE
	layer = initial(layer)
	update_appearance()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/, setClosed)), 5 SECONDS)

/mob/living/basic/pet/gondola/gondolapod/setClosed()
	opened = FALSE
	layer = LOW_MOB_LAYER
	update_appearance()

///Opens the gondola pod and delivers its package, one-time use as it removes all delivery-related actions.
/datum/action/innate/deliver_gondola_package
	name = "Deliver"
	desc = "Open your pod and release any contents stored within."
	button_icon = 'icons/hud/screen_gen.dmi'
	button_icon_state = "arrow"
	check_flags = AB_CHECK_PHASED

/datum/action/innate/deliver_gondola_package/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return

	var/mob/living/basic/pet/gondola/gondolapod/gondola_owner = owner
	gondola_owner.linked_pod.open_pod(gondola_owner, forced = TRUE)
	for(var/datum/action/actions as anything in gondola_owner.actions)
		if(actions.type in gondola_owner.gondola_delivering_actions)
			actions.Remove(gondola_owner)
	return TRUE

///Checks the contents of the gondola and lets them know what they're holding.
/datum/action/innate/check_gondola_contents
	name = "Check contents"
	desc = "See how many items you are currently holding in your pod."
	button_icon = 'icons/hud/implants.dmi'
	button_icon_state = "storage"
	check_flags = AB_CHECK_PHASED

/datum/action/innate/check_gondola_contents/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return

	var/mob/living/basic/pet/gondola/gondolapod/gondola_owner = owner
	var/total = gondola_owner.contents.len
	if (total)
		to_chat(gondola_owner, span_notice("You detect [total] object\s within your incredibly vast belly."))
	else
		to_chat(gondola_owner, span_notice("A closer look inside yourself reveals... nothing."))
	return TRUE
