/**
 * # mobs that can wear hats!
 */
/datum/element/hat_wearer
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///offsets of hats we will wear
	var/list/offsets
	///signals to remove the hat on
	var/list/remove_hat_signals
	///traits we check before adding the hat
	var/traits_prevent_checks

/datum/element/hat_wearer/Attach(datum/target, offsets = list(), remove_hat_signals = list(), traits_prevent_checks = list())
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.offsets = offsets
	src.traits_prevent_checks = traits_prevent_checks
	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_overlays_updated))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(exited))
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(target, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attack_by))
	if(!length(remove_hat_signals))
		return
	RegisterSignals(target, remove_hat_signals, PROC_REF(remove_hat))

/datum/element/hat_wearer/Detach(datum/target)
	var/obj/item/hat = (locate(/obj/item/clothing/head) in target)
	if(hat)
		hat.forceMove(get_turf(target))
	UnregisterSignal(target, list(
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ATOM_EXITED,
		COMSIG_ATOM_ENTERED,
		COMSIG_ATOM_ATTACKBY,
	))
	if(length(remove_hat_signals))
		UnregisterSignal(target, remove_hat_signals)
	return ..()

/datum/element/hat_wearer/proc/on_overlays_updated(atom/source, list/overlays)
	SIGNAL_HANDLER

	var/obj/item/hat = (locate(/obj/item/clothing/head) in source)
	if(isnull(hat))
		return
	var/mutable_appearance/hat_overlay = mutable_appearance(hat.worn_icon, hat.icon_state)
	hat_overlay.pixel_w = offsets[1]
	hat_overlay.pixel_z = offsets[2]
	overlays += hat_overlay

/datum/element/hat_wearer/proc/exited(atom/movable/source, atom/movable/exited)
	SIGNAL_HANDLER

	if(!istype(exited, /obj/item/clothing/head))
		return
	source.update_appearance(UPDATE_OVERLAYS)

/datum/element/hat_wearer/proc/on_entered(atom/movable/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!istype(arrived, /obj/item/clothing/head))
		return
	for(var/obj/item/clothing/head/already_worn in source)
		if(already_worn == arrived)
			continue
		already_worn.forceMove(get_turf(source))
	source.update_appearance(UPDATE_OVERLAYS)

/datum/element/hat_wearer/proc/on_attack_by(atom/movable/source, obj/item/item, mob/living/attacker)
	SIGNAL_HANDLER

	if(!istype(item, /obj/item/clothing/head))
		return

	for(var/trait_check in traits_prevent_checks)
		if(HAS_TRAIT(source, trait_check))
			source.balloon_alert(attacker, "not possible right now!")
			return COMPONENT_NO_AFTERATTACK

	INVOKE_ASYNC(src, PROC_REF(place_hat), source, item, attacker)
	return COMPONENT_NO_AFTERATTACK

/datum/element/hat_wearer/proc/place_hat(atom/movable/source, obj/item/item, mob/living/attacker)
	if(!do_after(attacker, delay = 3 SECONDS, target = source))
		source.balloon_alert(attacker, "must stay still!")
		return
	item.forceMove(source)

/datum/element/hat_wearer/proc/remove_hat(atom/movable/source)
	SIGNAL_HANDLER

	var/obj/our_hat = locate(/obj/item/clothing/head) in source
	if(isnull(our_hat))
		return
	our_hat.forceMove(source.drop_location())
