//reforming
/obj/item/ectoplasm/revenant
	name = "glimmering residue"
	desc = "A pile of fine blue dust. Small tendrils of violet mist swirl around it."
	icon = 'icons/effects/effects.dmi'
	icon_state = "revenantEctoplasm"
	w_class = WEIGHT_CLASS_SMALL
	/// Are we currently reforming?
	var/reforming = TRUE
	/// Are we inert (aka distorted such that we can't reform)?
	var/inert = FALSE
	/// The revenant we're currently storing
	var/mob/living/basic/revenant/revenant

/obj/item/ectoplasm/revenant/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(try_reform)), 1 MINUTES)

/obj/item/ectoplasm/revenant/Destroy()
	if(!QDELETED(revenant))
		qdel(revenant)
	return ..()

/obj/item/ectoplasm/revenant/proc/check_for_mirrors(turf/location, radius)
	PRIVATE_PROC(TRUE)
	for(var/obj/structure/mirror/mirror in view(radius, location))
		if(!mirror.revenant && !mirror.broken)
			return mirror
	return null

/obj/item/ectoplasm/revenant/attack_self(mob/user)
	if(!reforming || inert)
		return ..()
	var/obj/structure/mirror/nearby_mirror = check_for_mirrors(drop_location(), 5)
	if(!nearby_mirror)
		user.visible_message(
			span_notice("[user] scatters [src] in all directions."),
			span_notice("You scatter [src] across the area. The particles slowly fade away."),
		)
	else
		nearby_mirror.become_cursed(revenant)
		src.revenant = null
		user.visible_message(
			span_revenwarning("[user] scatters [src] in all directions. A dismal moan echoes as particles of [src] fall onto [nearby_mirror]!"),
			span_revenwarning("You scatter [src] across the area. A dismal moan echoes as particles of [src] fall onto [nearby_mirror]!"),
		)
	user.dropItemToGround(src)
	qdel(src)

/obj/item/ectoplasm/revenant/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(inert)
		return
	var/obj/structure/mirror/nearby_mirror = check_for_mirrors(get_turf(hit_atom), 3)
	if(!nearby_mirror)
		visible_message(span_notice("[src] breaks into particles upon impact, which fade away to nothingness."))
	else
		visible_message(span_revenwarning("A dismal moan echoes as particles of [src] fall onto [nearby_mirror]!"))
		nearby_mirror.become_cursed(revenant)
		revenant = null
	qdel(src)

/obj/item/ectoplasm/revenant/examine(mob/user)
	. = ..()
	if(inert)
		. += span_revennotice("It seems inert.")
	else if(reforming)
		. += span_revenwarning("It is shifting and distorted. It would be wise to destroy this.")

/obj/item/ectoplasm/revenant/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is inhaling [src]! It looks like [user.p_theyre()] trying to visit the shadow realm!"))
	qdel(src)
	return OXYLOSS

/obj/item/ectoplasm/revenant/proc/try_reform()
	if(reforming)
		reforming = FALSE
		reform()
	else
		inert = TRUE
		visible_message(span_warning("[src] settles down and seems lifeless."))

/// Actually moves the revenant out of ourself
/obj/item/ectoplasm/revenant/proc/reform()
	if(QDELETED(src) || inert)
		return

	message_admins("Revenant ectoplasm was left undestroyed for 1 minute and is reforming into a new revenant.")
	forceMove(drop_location()) //In case it's in a backpack or someone's hand

	if(!revenant.reform("by reforming ectoplasm"))
		inert = TRUE
		visible_message(span_revenwarning("[src] settles down and seems lifeless."))
		return
	visible_message(span_revenboldnotice("[src] suddenly rises into the air before fading away."))
	revenant = null
	qdel(src)
