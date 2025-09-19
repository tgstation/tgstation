/// Generic reagent applicator type for pills and patches
/obj/item/reagent_containers/applicator
	name = "generic reagent applicator"
	desc = "Report this please."
	abstract_type = /obj/item/reagent_containers/applicator
	has_variable_transfer_amount = FALSE
	grind_results = list()
	/// Action string displayed in vis_message
	var/apply_method = "swallow"
	/// Does the item get its name changed as volume when its produced
	var/rename_with_volume = FALSE
	/// How long does it take to apply this item to someone else?
	var/application_delay = 3 SECONDS
	/// How long does it take to apply this item to self?
	var/self_delay = 0

/obj/item/reagent_containers/applicator/Initialize(mapload)
	. = ..()
	if(reagents.total_volume && rename_with_volume)
		name += " ([reagents.total_volume]u)"

/// Consumption effects, must be overriden by children
/obj/item/reagent_containers/applicator/proc/on_consumption(mob/consumer, mob/giver, list/modifiers)
	return

/obj/item/reagent_containers/applicator/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if (!ismob(interacting_with))
		return NONE

	var/mob/target_mob = interacting_with
	if(!canconsume(target_mob, user))
		return ITEM_INTERACT_BLOCKING

	if(target_mob == user)
		target_mob.visible_message(span_notice("[user] attempts to [apply_method] [src]."))
		if(self_delay)
			if(!do_after(user, self_delay, target_mob))
				return ITEM_INTERACT_BLOCKING
		to_chat(target_mob, span_notice("You [apply_method] [src]."))
		on_consumption(user, user, modifiers)
		return ITEM_INTERACT_SUCCESS

	target_mob.visible_message(span_danger("[user] attempts to force [target_mob] to [apply_method] [src]."), span_userdanger("[user] attempts to force you to [apply_method] [src]."))
	if(!do_after(user, CHEM_INTERACT_DELAY(application_delay, user), target_mob))
		return ITEM_INTERACT_BLOCKING

	target_mob.visible_message(span_danger("[user] forces [target_mob] to [apply_method] [src]."), span_userdanger("[user] forces you to [apply_method] [src]."))
	on_consumption(target_mob, user, modifiers)
	return ITEM_INTERACT_SUCCESS
