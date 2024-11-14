/datum/component/jousting/Initialize(damage_boost_per_tile, knockdown_chance_per_tile, knockdown_time, max_tile_charge, min_tile_charge, datum/callback/successful_joust_callback)
	. = ..()

	RegisterSignal(parent, COMSIG_PRE_BATON_FINALIZE_ATTACK, PROC_REF(on_successful_baton_attack))

/datum/component/jousting/proc/on_successful_baton_attack(datum/source, mob/living/target, mob/user)
	SIGNAL_HANDLER

	if (!istype(parent, /obj/item/melee/baton/security))
		return

	var/obj/item/melee/baton/security/baton = parent
	var/usable_charge = on_successful_attack(source, target, user)
	if(usable_charge)
		baton.on_successful_joust(target, user, usable_charge)
