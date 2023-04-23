/obj/item/rollingtable_dock
	name = "rolling table dock"
	desc = "A collapsed roller table that can be ejected for service on the go. Must be collected or replaced after use."
	icon = 'icons/obj/medical/rollerbed.dmi'
	icon_state = "folded""
	var/obj/structure/table/rolling/loaded = null

/obj/item/rollingtable_dock/Initialize(mapload)
	. = ..()
	loaded = new(src)

/obj/structure/table/rolling/attackby(obj/item/WT, mob/user, params)
	if(istype(WT, /obj/item/rollingtable_dock))
		var/obj/item/rollingtable_dock/RT = WT
		var/turf/target_table = get_turf(src)
		if(RT.loaded)
			to_chat(user, span_warning("You already have a roller table docked!"))
			return
		if(locate(/mob/living) in target_table)
			to_chat(user, span_warning("You can't collect the table with that much on top!"))
			return
		else
			RT.loaded = src
			forceMove(RT)
			user.visible_message(span_notice("[user] collects [src]."), span_notice("You collect [src]."))
		return 1
	else
		return ..()

/obj/item/rollingtable_dock/afterattack(obj/target, mob/user , proximity)
	. = ..()
	var/turf/target_turf = get_turf(target)
	if(!proximity)
		return
	if(target_turf.is_blocked_turf(TRUE))
		return
	if(locate(/mob/living) in target_turf)
		return
	if(isopenturf(target))
		deploy_rollingtable(user, target)

/obj/item/rollingtable_dock/proc/deploy_rollingtable(mob/user, atom/location)
	var/obj/structure/table/rolling/RT = new /obj/structure/table/rolling(location)
	RT.add_fingerprint(user)
	qdel(src)

/obj/item/rollingtable_dock/examine(mob/user)
	. = ..()
	. += "The dock is [loaded ? "loaded" : "empty"]."

/obj/item/rollingtable_dock/deploy_rollingtable(mob/user, atom/location)
	if(loaded)
		loaded.forceMove(location)
		user.visible_message(span_notice("[user] deploys [loaded]."), span_notice("You deploy [loaded]."))
		loaded = null
	else
		to_chat(user, span_warning("The dock is empty!"))
