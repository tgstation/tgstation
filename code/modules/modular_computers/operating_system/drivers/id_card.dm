/datum/driver/id_card

/datum/driver/id_card/proc/get_stored_id()
	return hardware?.stored_id

/datum/driver/id_card/proc/eject_stored_id(mob/user)
	if(!hardware || !hardware.stored_id)
		return

	var/obj/item/card/id/id_card = get_stored_id()
	if(id_card)
		GLOB.manifest.modify(id_card.registered_name, id_card.assignment, id_card.get_trim_assignment())
		hardware.remove_id(user)
	else
		playsound(get_turf(hardware.os.ui_host()) , 'sound/machines/buzz/buzz-sigh.ogg', 25, FALSE)
