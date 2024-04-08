GLOBAL_LIST_INIT(unlocked_slime_colors, list())

/datum/slime_color
	///the name of the slime color
	var/name = "Generic Color"
	///this is appended to the icon_states of the slime
	var/icon_prefix = "grey"
	///secretion path
	var/secretion_path = /datum/reagent/slime_ooze/grey
	///our slimes true color
	var/slime_color = "#FFFFFF"
	///list of possible mutations from this color
	var/list/possible_mutations = list()

/datum/slime_color/proc/on_add_to_slime(mob/living/basic/slime/slime)
	return

/datum/slime_color/New()
	. = ..()
	if(!(type in GLOB.unlocked_slime_colors))
		on_first_unlock()
		GLOB.unlocked_slime_colors |= type

/datum/slime_color/proc/on_first_unlock()
	return
