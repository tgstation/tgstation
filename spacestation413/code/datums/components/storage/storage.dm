
/datum/component/storage/concrete/infinity_gauntlet
	rustle_sound = FALSE
	max_items = 6

/datum/component/storage/concrete/infinity_gauntlet/handle_item_insertion(obj/item/I, prevent_warning = FALSE, mob/living/user)
	. = ..()
	var/obj/item/storage/infinity_gauntlet/gauntlet = real_location()
	gauntlet.add_gems_to_owner(user)

//don't need to do remove_from_storage because storage already calls dropped in there
