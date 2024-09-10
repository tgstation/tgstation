/// Copy traits from one organ to another - e.g. with custom roundstart organs that should still get species traits applied.
/obj/item/organ/proc/copy_traits_from(obj/item/organ/old_organ, copy_actions = FALSE)
	if(isnull(old_organ))
		return

	if(copy_actions)
		// for when you want to make sure the organ gets any actions from the old one
		for(var/datum/action/action as anything in old_organ.actions)
			add_item_action(action.type)
