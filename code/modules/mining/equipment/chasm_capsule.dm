/obj/item/chasm_filler
	name = "chasm filler capsule"
	desc = "A capsule containing a large amount of compressed catwalks, intended to cover chasms."
	icon = 'icons/obj/mining.dmi'
	icon_state = "chasm_filler_capsule"
	w_class = WEIGHT_CLASS_TINY
	/// Has this chasm filler been used?
	var/used = FALSE
	/// The range of which it will fill chasms.
	var/range = 5

/obj/item/chasm_filler/examine(mob/user)
	. = ..()
	. += span_notice("To use, the capsule must be activated first, and then thrown into a chasm.")

/obj/item/chasm_filler/interact(mob/user)
	. = ..()
	if(.)
		return .
	if(used)
		return FALSE
	loc.visible_message(span_warning("[src] begins to shake, throw it into a chasm now!"))
	used = TRUE
	addtimer(CALLBACK(src, PROC_REF(fill_chasm)), 5 SECONDS)
	Shake(duration = 5 SECONDS)
	return TRUE

/obj/item/chasm_filler/proc/fill_chasm()
	if(!istype(loc, /obj/effect/abstract/chasm_storage) && !istype(loc, /turf/open/chasm))
		used = FALSE
		loc.visible_message(span_warning("[src] is not in a chasm, it has nothing to cover!"))
		return
	for(var/turf/open/chasm/chasm in range(range, get_turf(src)))
		if(HAS_TRAIT(chasm, TRAIT_CHASM_STOPPED))
			continue
		new /obj/structure/lattice/catwalk(chasm)
		playsound(chasm, 'sound/items/handling/materials/metal_drop.ogg', 20, vary = TRUE) // not too loud, as a lot of these may play at once.
	qdel(src)
