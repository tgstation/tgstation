//reforming
/obj/item/ectoplasm/revenant
	name = "glimmering residue"
	desc = "A pile of fine blue dust. Small tendrils of violet mist swirl around it."
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

/obj/item/ectoplasm/revenant/attack_self(mob/user)
	if(inert)
		return ..()
	user.visible_message(
		span_notice("[user] scatters [src] in all directions."),
		span_notice("You scatter [src] across the area."),
	)
	user.dropItemToGround(src)
	SEND_SIGNAL(src, COMSIG_RESIDUE_DISPERSE)
	qdel(src)

/obj/item/ectoplasm/revenant/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(inert)
		return
	visible_message(span_notice("[src] breaks into particles upon impact, which fade away to nothingness."))
	SEND_SIGNAL(src, COMSIG_RESIDUE_DISPERSE)
	qdel(src)

/obj/item/ectoplasm/revenant/examine(mob/user)
	. = ..()
	if(inert)
		. += span_revennotice("It seems inert.")
	else
		. += span_revenwarning("It is shifting and distorted. It would be wise to destroy this.")

/obj/item/ectoplasm/revenant/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is inhaling [src]! It looks like [user.p_theyre()] trying to visit the shadow realm!"))
	qdel(src)
	return OXYLOSS

/// Actually moves the revenant out of ourself
/obj/item/ectoplasm/revenant/proc/reform()
	if(QDELETED(src) || inert)
		return
	if(!(SEND_SIGNAL(src, COMSIG_RESIDUE_REFORM) & COMPONENT_RESIDUE_REFORM_SUCCESS))
		inert = TRUE
		return
	message_admins("Revenant ectoplasm was left undestroyed for 1 minute and is reforming into a new revenant.")
	visible_message(span_revenboldnotice("[src] suddenly rises into the air before fading away."))
	qdel(src)
