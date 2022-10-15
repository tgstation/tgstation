/datum/storage/modsuit

/datum/storage/modsuit/on_attackby(datum/source, obj/item/thing, mob/user, params)
	var/obj/item/mod/control/mod = parent?.resolve()
	var/obj/item/mod/core/plasma/plasma_mod_core = mod.core
	if(istype(plasma_mod_core) && (thing.type in plasma_mod_core.charger_list))
		return

	return ..()
