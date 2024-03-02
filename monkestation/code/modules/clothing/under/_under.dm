
/obj/item/clothing/under
	/// A weak reference to the current accessory that's providing armor.
	var/datum/weakref/current_armored_accessory

/obj/item/clothing/under/proc/refresh_armor()
	SIGNAL_HANDLER
	var/obj/item/clothing/accessory/armored_accesory = current_armored_accessory?.resolve()
	if(armored_accesory)
		set_armor(get_armor().subtract_other_armor(armored_accesory.get_armor()))
		current_armored_accessory = null
	for(var/obj/item/clothing/accessory/accessory as anything in attached_accessories)
		if(QDELETED(accessory))
			continue
		var/datum/armor/armor = accessory.get_armor()
		if(!armor || istype(armor, /datum/armor/none))
			continue
		set_armor(get_armor().add_other_armor(accessory.get_armor()))
		current_armored_accessory = WEAKREF(accessory)
		return

/obj/item/clothing/under/attach_accessory(obj/item/clothing/accessory/accessory, mob/living/user, attach_message = TRUE)
	. = ..()
	if(!.)
		return
	RegisterSignal(accessory, COMSIG_QDELETING, PROC_REF(refresh_armor))
	refresh_armor()

/obj/item/clothing/under/remove_accessory(obj/item/clothing/accessory/removed)
	. = ..()
	UnregisterSignal(removed, COMSIG_QDELETING)
	refresh_armor()
