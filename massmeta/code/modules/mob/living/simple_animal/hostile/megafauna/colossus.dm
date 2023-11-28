#define ACTIVATE_TOUCH "touch"

/obj/machinery/anomalous_crystal/refresher //Deletes and recreates a copy of the item, "refreshing" it.
	observer_desc = "This crystal \"refreshes\" items that it affects, rendering them as new."
	activation_method = ACTIVATE_TOUCH
	cooldown_add = 50
	activation_sound = 'sound/magic/timeparadox2.ogg'
	var/static/list/banned_items_typecache = typecacheof(list(/obj/item/storage, /obj/item/implant, /obj/item/implanter, /obj/item/disk/nuclear, /obj/projectile, /obj/item/spellbook))

/obj/machinery/anomalous_crystal/refresher/ActivationReaction(mob/user, method)
	if(..())
		var/list/L = list()
		var/turf/T = get_step(src, dir)
		new /obj/effect/temp_visual/emp/pulse(T)
		for(var/i in T)
			if(isitem(i) && !is_type_in_typecache(i, banned_items_typecache))
				var/obj/item/W = i
				if(!(W.flags_1 & ADMIN_SPAWNED_1) && !(W.flags_1 & HOLOGRAM_1) && !(W.item_flags & ABSTRACT))
					L += W
		if(L.len)
			var/obj/item/CHOSEN = pick(L)
			new CHOSEN.type(T)
			qdel(CHOSEN)

#undef ACTIVATE_TOUCH

