/obj/item/slimecross/stabilized/rainbow/Destroy()
	if(!QDELETED(regencore))
		regencore.forceMove(drop_location())
	regencore = null
	return ..()

/datum/status_effect/stabilized/rainbow/tick()
	if(owner.health <= 0)
		var/obj/item/slimecross/stabilized/rainbow/extract = linked_extract
		if(!istype(extract) || QDELING(extract) || QDELETED(extract.regencore))
			return
		// bypasses cooldowns, but also removes any existing regen effects
		owner.remove_status_effect(/datum/status_effect/regenerative_extract)
		owner.remove_status_effect(/datum/status_effect/slime_regen_cooldown)
		owner.visible_message(span_hypnophrase("[owner] flashes a rainbow of colors, and [owner.p_their()] skin is coated in a milky regenerative goo!"))
		playsound(owner, 'sound/effects/splat.ogg', vol = 40, vary = TRUE)
		apply_regen(extract.regencore)
		QDEL_NULL(linked_extract)
		qdel(src)
		return
	return ..()


/datum/status_effect/stabilized/rainbow/proc/apply_regen(obj/item/slimecross/regenerative/regen_core)
	regen_core.core_effect_before(owner, owner)
	regen_core.apply_effect(owner)
	regen_core.core_effect(owner, owner)
	qdel(regen_core)

