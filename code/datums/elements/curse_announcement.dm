/**
 * # curse announcement element!
 *
 * Bespoke element that sends a harrowing message when you first pick up an item, applying a spooky color outline and renaming the item.
 * For most items, it will announce when picked up. If the item can be equipped, though, it will only announce when the item is worn.
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
	///optional fantasy component, used in building the name if provided
	var/datum/weakref/fantasy_component

/datum/element/curse_announcement/Attach(datum/target, announcement_message, filter_color, new_name, datum/component/fantasy/fantasy_component)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	var/obj/item/cursed_item = target
	src.announcement_message = announcement_message
	src.filter_color = filter_color
	src.new_name = new_name
	src.fantasy_component = WEAKREF(fantasy_component)
	if(cursed_item.slot_equipment_priority) //if it can equip somewhere, only go active when it is actually done
		RegisterSignal(cursed_item, COMSIG_ITEM_EQUIPPED, .proc/on_equipped)
	else
		RegisterSignal(cursed_item, COMSIG_ITEM_PICKUP, .proc/on_pickup)

/datum/element/curse_announcement/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_PICKUP))

/datum/element/curse_announcement/proc/on_equipped(obj/item/cursed_item, mob/equipper, slot)
	SIGNAL_HANDLER
	if(cursed_item.slot_flags & slot)
		announce(cursed_item, equipper)

/datum/element/curse_announcement/proc/on_pickup(obj/item/cursed_item, mob/grabber)
	SIGNAL_HANDLER
	announce(cursed_item, grabber)

/datum/element/curse_announcement/proc/announce(obj/item/cursed_item, mob/cursed)
	//this is from rpgloot, remove the quality suffix to format the name correctly
	var/quality_suffix_text
	var/datum/component/fantasy/perchance_to_dream = fantasy_component.resolve()
	if(perchance_to_dream)
		quality_suffix_text = " [perchance_to_dream.quality]"
		cursed_item.name = replacetext(cursed_item.name, quality_suffix_text,"")

	//modifications to the item so it looks cursed
	to_chat(cursed, span_userdanger("[announcement_message]"))
	cursed_item.add_filter("cursed_item", 9, list("type" = "outline", "color" = filter_color, "size" = 1))
	cursed_item.name = "[cursed_item][new_name]"

	//this is from rpgloot, readd the quality suffix
	if(quality_suffix_text)
		cursed_item.name += quality_suffix_text
	cursed_item.RemoveElement(/datum/element/curse_announcement)

