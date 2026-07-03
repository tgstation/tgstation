/datum/strippable_item/mob_item_slot/pocket/finish_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if (isnull(item))
		return FALSE

	if (!ismob(source))
		return FALSE

	return finish_unequip_mob_pocket(item, source, user)

/datum/strippable_item/mob_item_slot/pocket/proc/finish_unequip_mob_pocket(obj/item/item, mob/source, mob/user)
	if (!item.doStrip(user, source))
		return FALSE
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/user_human = user
		user_human.put_in_hands(item)

	user.log_message("has stealthy stripped [key_name(source)] of [item].", LOG_ATTACK, color="red")
	source.log_message("has been stealthy stripped of [item] by [key_name(user)].", LOG_VICTIM, color="orange", log_globally=FALSE)

	// Updates speed in case stripped speed affecting item
	source.update_equipment_speed_mods()
