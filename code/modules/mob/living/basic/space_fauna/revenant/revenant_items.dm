//reforming
/obj/item/ectoplasm/revenant
	name = "glimmering residue"
	desc = "Кучка мелкой голубой пыли. Вокруг неё кружатся маленькие завитки фиолетового тумана."
	icon = 'icons/effects/effects.dmi'
	icon_state = "revenantEctoplasm"
	w_class = WEIGHT_CLASS_SMALL
	// Can the revenant reform?
	var/inert = FALSE

/obj/item/ectoplasm/revenant/Initialize(mapload, revenant)
	. = ..()
	inert = !revenant
	if(revenant)
		AddComponent(/datum/component/revenant_prison, revenant = revenant)
		addtimer(CALLBACK(src, PROC_REF(reform)), 1 MINUTES)

/obj/item/ectoplasm/revenant/Destroy()
	return ..()

/obj/item/ectoplasm/revenant/proc/check_for_mirrors(turf/location, radius)
	PRIVATE_PROC(TRUE)
	for(var/obj/structure/mirror/mirror in view(radius, location))
		if(mirror.cursable && !mirror.GetComponent(/datum/component/revenant_prison))
			return mirror
	return null

/obj/item/ectoplasm/revenant/attack_self(mob/user)
	if(inert)
		return ..()
	user.visible_message(
		span_notice("[user] разбрасывает [declent_ru(ACCUSATIVE)] во все стороны."),
		span_notice("Вы разбрасываете [declent_ru(ACCUSATIVE)] по всей области. Частицы медленно исчезают."),
	)
	var/obj/structure/mirror/nearby_mirror = check_for_mirrors(drop_location(), 5)
	if(nearby_mirror)
		transfer_to_mirror(nearby_mirror)
	user.dropItemToGround(src)
	qdel(src)

/obj/item/ectoplasm/revenant/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(inert)
		return
	var/obj/structure/mirror/nearby_mirror = check_for_mirrors(get_turf(hit_atom), 3)
	if(!nearby_mirror)
		visible_message(span_notice("[declent_ru(ACCUSATIVE)] при ударе распадается на частицы, которые исчезают, превращаясь в ничто."))
	else
		transfer_to_mirror(nearby_mirror)
	qdel(src)

/obj/item/ectoplasm/revenant/proc/transfer_to_mirror(obj/structure/mirror/nearby_mirror)
	PRIVATE_PROC(TRUE)
	nearby_mirror.TakeComponent(GetComponent(/datum/component/revenant_prison))
	nearby_mirror.visible_message(span_revenwarning("A dismal moan echoes as particles of [src] fall onto [nearby_mirror]!"))
	log_game("A revenant was trapped inside [nearby_mirror]")
	message_admins("A revenant was trapped inside [nearby_mirror] [ADMIN_JMP(nearby_mirror)]")

/obj/item/ectoplasm/revenant/examine(mob/user)
	. = ..()
	if(inert)
		. += span_revennotice("Он кажется инертным.")
	else
		. += span_revenwarning("Он смещается и искажается. Было бы разумно уничтожить это.")

/obj/item/ectoplasm/revenant/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] вдыхает [declent_ru(ACCUSATIVE)]! Кажется, [user.ru_p_they()] пытается попасть в царство теней!"))
	qdel(src)
	return OXYLOSS

/// Actually moves the revenant out of ourself
/obj/item/ectoplasm/revenant/proc/reform()
	if(QDELETED(src) || inert)
		return
	if(!GetComponent(/datum/component/revenant_prison))
		return
	message_admins("Revenant ectoplasm was left undestroyed for 1 minute and is reforming into a new revenant.")
	SEND_SIGNAL(src, COMSIG_REVENANT_RELEASE, cause = "ectoplasm reforming")
	visible_message(span_revenboldnotice("[src] внезапно взмывает в воздух, прежде чем исчезнуть."))
	qdel(src)
