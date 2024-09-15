/// Whether we should show an interactable topic in examines of the wound. href_list["wound_topic"]
/datum/wound/proc/show_wound_topic(mob/user)
	return FALSE

/// Gets the name of the wound with any interactable topic if possible
/datum/wound/proc/get_topic_name(mob/user)
	return show_wound_topic(user) ? "<a href='?src=[REF(src)];wound_topic=1'>[LOWER_TEXT(name)]</a>" : LOWER_TEXT(name)
