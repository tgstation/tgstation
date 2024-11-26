/obj/item/rolling_table_dock
	name = "rolling table dock"
	desc = "A collapsed roller table that can be ejected for service on the go. Must be collected or replaced after use."
	icon = 'icons/obj/smooth_structures/rollingtable.dmi'
	icon_state = "rollingtable"
	var/obj/structure/table/rolling/loaded = null

/obj/item/rolling_table_dock/Initialize(mapload)
	. = ..()
	loaded = new(src)

/obj/structure/table/rolling/attackby(obj/item/wtable, mob/user, params)
	if(!istype(wtable, /obj/item/rolling_table_dock))
		return ..()
	var/obj/item/rolling_table_dock/rable = wtable
	var/turf/target_table = get_turf(src)
	if(rable.loaded)
		to_chat(user, span_warning("You already have a roller table docked!"))
		return
	if(locate(/mob/living) in target_table)
		to_chat(user, span_warning("You can't collect the table with that much on top!"))
		return
	else
		rable.loaded = src
		forceMove(rable)
		user.visible_message(span_notice("[user] collects [src]."), balloon_alert(user, "you collect the [src]."))
	return TRUE

/obj/item/rolling_table_dock/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/turf/target_turf = get_turf(interacting_with)
	if(target_turf.is_blocked_turf(TRUE) || (locate(/mob/living) in target_turf))
		return NONE
	if(isopenturf(interacting_with))
		deploy_rolling_table(user, interacting_with)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/rolling_table_dock/proc/deploy_rolling_table(mob/user, atom/location)
	var/obj/structure/table/rolling/rable = new /obj/structure/table/rolling(location)
	rable.add_fingerprint(user)
	qdel(src)

/obj/item/rolling_table_dock/examine(mob/user)
	. = ..()
	. += "The dock is [loaded ? "loaded" : "empty"]."

/obj/item/rolling_table_dock/deploy_rolling_table(mob/user, atom/location)
	if(loaded)
		loaded.forceMove(location)
		user.visible_message(span_notice("[user] deploys [loaded]."), balloon_alert(user, "you deploy the [loaded]."))
		loaded = null
	else
		balloon_alert(user, "the dock is Empty!")
