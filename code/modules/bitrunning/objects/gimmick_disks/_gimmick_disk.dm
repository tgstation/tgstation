
/**
 * Bitrunning tech disks which let you load full loadouts into the vdom on first avatar generation.
 */
/obj/item/bitrunning_disk/gimmick
	desc = "A disk containing source code. It can be used to preload gimmick loadouts into the virtual domain."
	/// The selected loadout that this grants
	var/datum/bitrunning_gimmick/granted_loadout
	/// The list of loadouts that this can grant
	var/list/datum/bitrunning_gimmick/selectable_loadouts

/obj/item/bitrunning_disk/gimmick/Destroy()
	QDEL_NULL(granted_loadout)
	return ..()

/obj/item/bitrunning_disk/gimmick/load_onto_avatar(mob/living/carbon/human/neo, mob/living/carbon/human/avatar, external_load_flags)
	if(isnull(granted_loadout))
		return BITRUNNER_GEAR_LOAD_FAILED
	return granted_loadout.grant_loadout(neo, avatar, external_load_flags)

/obj/item/bitrunning_disk/gimmick/attack_self(mob/user, modifiers)
	. = ..()

	if(granted_loadout)
		return

	var/names = list()
	for(var/datum/bitrunning_gimmick/loadout as anything in selectable_loadouts)
		names += initial(loadout.name)

	var/choice = tgui_input_list(user, message = "Select a gimmick loadout",  title = "Bitrunning Program", items = names)
	if(isnull(choice) || !user.is_holding(src))
		return

	for(var/datum/bitrunning_gimmick/loadout as anything in selectable_loadouts)
		if(initial(loadout.name) == choice)
			granted_loadout = new loadout()

	balloon_alert(user, "selected")
	playsound(user, 'sound/items/click.ogg', 50, TRUE)
	choice_made = choice


/**
 * The datum used by the gimmick loadout disk to determine what a loadout actually spawns.
 */
/datum/bitrunning_gimmick
	/// Player readable name of the gimmick loadout
	var/name = "Gimmick Loadout"
	/// The list of actions that this will grant
	var/list/datum/action/granted_actions
	/// The list of items that this will grant
	var/list/obj/item/granted_items
	/// The item type we will use as a container for our granted items, given to the avatar
	var/obj/item/container_item_type = /obj/item/storage/briefcase/secure/digital_storage
	/// Prefix our name onto the
	var/prefix_container_name = TRUE

/// Grants out loadout.
/datum/bitrunning_gimmick/proc/grant_loadout(mob/living/carbon/human/neo, mob/living/carbon/human/avatar, external_load_flags)
	var/return_flags = NONE
	return_flags |= grant_items(neo, avatar, external_load_flags)
	return_flags |= grant_abilities(neo, avatar, external_load_flags)
	return return_flags

/datum/bitrunning_gimmick/proc/grant_items(mob/living/carbon/human/neo, mob/living/carbon/human/avatar, external_load_flags)
	if(!length(granted_items))
		return NONE

	if(external_load_flags & DOMAIN_FORBIDS_ITEMS)
		return BITRUNNER_GEAR_LOAD_BLOCKED

	var/obj/item/container_item = new container_item_type()
	if(prefix_container_name)
		container_item.name = "[LOWER_TEXT(name)]'s [initial(container_item.name)]"

	for(var/obj/item/granted_item as anything in granted_items)
		new granted_item(container_item)

	avatar.put_in_hands(container_item)

	return NONE

/datum/bitrunning_gimmick/proc/grant_abilities(mob/living/carbon/human/neo, mob/living/carbon/human/avatar, external_load_flags)
	if(!length(granted_actions))
		return NONE

	if(external_load_flags & DOMAIN_FORBIDS_ABILITIES)
		return BITRUNNER_GEAR_LOAD_BLOCKED

	var/return_flags = NONE

	for(var/datum/action/granted_action as anything in granted_actions)
		if(locate(granted_action) in avatar.actions)
			return_flags |= BITRUNNER_GEAR_LOAD_FAILED
			continue

		var/datum/action/our_action = new granted_action()
		our_action.Grant(avatar)

	return return_flags

