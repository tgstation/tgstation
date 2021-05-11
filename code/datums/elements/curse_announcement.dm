/**
 * # curse announcement element!
 *
 * Bespoke element that sends a harrowing message when you first pick up an item, applying a spooky color outline and renaming the item.
 * Possible improvements for the future: add an option to allow the cursed affix to be a prefix. right now only coded for suffixes
 */
/datum/element/curse_announcement
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	///message sent on announce
	var/announcement_message
	///color of the outline filter on announce
	var/filter_color
	///new name given to the item on announce
	var/new_name

/datum/element/curse_announcement/Attach(datum/target, announcement_message, filter_color, new_name)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	src.announcement_message = announcement_message
	src.filter_color = filter_color
	src.new_name = new_name
	if(isclothing(target))
		RegisterSignal(target, COMSIG_ITEM_EQUIPPED, .proc/announce)
	else
		RegisterSignal(target, COMSIG_ITEM_PICKUP, .proc/announce)

/datum/element/curse_announcement/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_PICKUP))

/datum/element/curse_announcement/proc/announce(obj/item/cursed_item, mob/cursed)
	SIGNAL_HANDLER

	to_chat(cursed, "<span class='userdanger'>[announcement_message]</span>")
	cursed_item.add_filter("cursed_item", 9, list("type" = "outline", "color" = filter_color))\
	cursed_item.name = "[cursed_item][new_name]"
	cursed_item.RemoveElement(/datum/element/curse_announcement)

