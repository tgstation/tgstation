/**
 * ### envenomable caseless element!
 *
 * Non bespoke element (1 in existence) that lets caseless bullets be dippable.
 * When you fire the bullet, it will gain venomous. The casing itself isn't venomous to prevent bullshit
 */
/datum/element/envenomable_casing
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// how much reagent can you dip the caseless in?
	var/amount_allowed

/datum/element/envenomable_casing/Attach(datum/target, amount_allowed = 5)
	. = ..()
	if(!istype(target, /obj/item/ammo_casing))
		return ELEMENT_INCOMPATIBLE
	src.amount_allowed = amount_allowed
	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/element/envenomable_casing/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_AFTERATTACK, COMSIG_PARENT_EXAMINE))

///signal called on the parent attacking an item
/datum/element/envenomable_casing/proc/on_afterattack(obj/item/ammo_casing/casing, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER
	if(!is_reagent_container(target))
		return
	var/obj/item/reagent_containers/venom_container = target
	if(!casing.loaded_projectile)
		user.balloon_alert(user, "casing is already spent!")
		return
	if(!(venom_container.reagent_flags & OPENCONTAINER))
		user.balloon_alert(user, "open the container!")
		return
	var/datum/reagent/venom_applied = venom_container.reagents.get_master_reagent()
	if(!venom_applied)
		return
	var/amount_applied = min(venom_applied.volume, amount_allowed)

	casing.loaded_projectile.AddComponent(/datum/element/venomous, venom_applied.type, amount_applied)
	to_chat(user, span_notice("You coat [casing] in [venom_applied]."))
	venom_container.reagents.remove_reagent(venom_applied.type, amount_applied)
	///stops further poison application
	UnregisterSignal(casing, COMSIG_ITEM_AFTERATTACK)

///signal called on parent being examined
/datum/element/envenomable_casing/proc/on_examine(obj/item/ammo_casing/casing, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!casing.loaded_projectile)
		return
	if(casing.loaded_projectile.GetComponent(/datum/element/venomous))
		examine_list += span_warning("It's coated in some kind of chemical...")
	else
		examine_list += span_notice("You can dip it in a chemical to deliver a poisonous kick.")
