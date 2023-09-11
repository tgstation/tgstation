/// When swung, deals damage to plants in the tile you hit.
/// (Normally the swing would go through it, as they are non-dense.)
/datum/element/scythes_plants
	/// Typecache of stuff that counts as a plant we can hit.
	var/static/list/scythe_attackables = typecacheof(list(
		/obj/structure/spacevine,
		/obj/structure/alien/resin/flower_bud,
	))

/datum/element/scythes_plants/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_SWING_ENTERS_TURF, PROC_REF(scythe_plants))

/datum/element/scythes_plants/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_SWING_ENTERS_TURF)

/datum/element/scythes_plants/proc/scythe_plants(obj/item/source, attack_flags, mob/living/attacker, turf/hitting, ...)
	SIGNAL_HANDLER

	. = NONE
	for(var/atom/movable/to_hit as anything in typecache_filter_list(hitting.contents, scythe_attackables))
		to_hit.attacked_by(source, attacker)
		. |= ATTACK_SWING_HIT
